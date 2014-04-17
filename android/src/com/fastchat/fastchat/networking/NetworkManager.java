package com.fastchat.fastchat.networking;


import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URI;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.ContextWrapper;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.fastchat.fastchat.MainActivity;
import com.fastchat.fastchat.Utils;
import com.fastchat.fastchat.fragments.GroupsFragment;
import com.fastchat.fastchat.fragments.LoginFragment;
import com.fastchat.fastchat.fragments.MessageFragment;
import com.fastchat.fastchat.fragments.ProfileFragment;
import com.fastchat.fastchat.models.Group;
import com.fastchat.fastchat.models.Message;
import com.fastchat.fastchat.models.MultiMedia;
import com.fastchat.fastchat.models.User;
import com.koushikdutta.async.ByteBufferList;
import com.koushikdutta.async.future.Future;
import com.koushikdutta.async.http.AsyncHttpClient;
import com.koushikdutta.async.http.AsyncHttpClient.DownloadCallback;
import com.koushikdutta.async.http.AsyncHttpClient.JSONArrayCallback;
import com.koushikdutta.async.http.AsyncHttpClient.JSONObjectCallback;
import com.koushikdutta.async.http.AsyncHttpGet;
import com.koushikdutta.async.http.AsyncHttpPost;
import com.koushikdutta.async.http.AsyncHttpRequest;
import com.koushikdutta.async.http.AsyncHttpResponse;
import com.koushikdutta.async.http.body.FilePart;
import com.koushikdutta.async.http.body.JSONObjectBody;
import com.koushikdutta.async.http.body.MultipartFormDataBody;

public class NetworkManager {

	private static final String url ="http://powerful-cliffs-9562.herokuapp.com:80";
	//private static final String url ="http://129.21.117.122:3000";
	private static String currentUserId = "0";
	private static Group currentGroup;
	// HashMap <groupId, Groups>
	private static HashMap<String,Group> groups = new HashMap<String,Group>();
	private static HashMap<String, User> users  = new HashMap<String,User>();
	private static User fastChatUser = new User(null,"FastChat",null);


	private static final JSONObjectCallback loginCallback = new AsyncHttpClient.JSONObjectCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
			int responseCode = handleResponse(e,response,result);
			System.out.println("I got a JSONObject: " + result);
			if(responseCode<200 || responseCode>299){
				return;
			}
			
			try {
				getCurrentUser().setToken(result.getString("session-token"));
				getProfile();
				NetworkManager.postDeviceId(MainActivity.regid);
				
			} catch (JSONException e1) {
				e1.printStackTrace();
				Utils.makeToast(e1);
				return;
			}
		}
	};

	public static Future<JSONObject> postLogin(String username, String password){
		User u = new User(null,username,null);
		setCurrentUser(u);
		AsyncHttpPost post = new AsyncHttpPost(url+"/login");
		JSONObject object = new JSONObject();
		try {
			object.put("username", username);
			object.put("password", password);
		} catch (JSONException e) {
			Utils.makeToast(e);
			e.printStackTrace();
			return null;
		}
		JSONObjectBody body = new JSONObjectBody(object);
		post.setBody(body);
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(post, loginCallback);
	}

	
	public static Future<JSONArray> getGroups(){

		AsyncHttpGet get = new AsyncHttpGet(url+"/group");
		get.setHeader("session-token", getCurrentUser().getSessionToken());
		return AsyncHttpClient.getDefaultInstance().executeJSONArray(get,new AsyncHttpClient.JSONArrayCallback() {
			public void onCompleted(Exception e, AsyncHttpResponse response, JSONArray result) {
				int responseCode = handleResponse(e,response);
				if(responseCode>=200 && responseCode<300){
					GroupsFragment.addGroups(result);
				}else{
					MainActivity.restartFragments(new LoginFragment());
				}
			}
		});

	}
	

	public static Future<JSONObject> postDeviceId(String reg_id){
		if(reg_id==null || reg_id.equals("")){
			return null;
		}
		AsyncHttpPost post = new AsyncHttpPost(url+"/user/device");
		post.setHeader("session-token", getCurrentUser().getSessionToken());
		JSONObject object = new JSONObject();
		try {
			object.put("token", reg_id);
			object.put("type", "android");
		} catch (JSONException e) {
			Utils.makeToast(e);
			e.printStackTrace();
			return null;
		}
		JSONObjectBody body = new JSONObjectBody(object);
		post.setBody(body);
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(post, new AsyncHttpClient.JSONObjectCallback() {
			// Callback is invoked with any exceptions/errors, and the result, if available.
			public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
				handleResponse(e,response,result);
			}
		});
	}
	
	
	
	private static final JSONArrayCallback groupMessagesCallback = new AsyncHttpClient.JSONArrayCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONArray result) {
			int responseCode =handleResponse(e,response);
			if(responseCode<200 || responseCode>299){
				Utils.makeToast("Unable to retrieve groups");
				return;
			}
			for(int i=0;i<result.length();i++){
				int j = result.length()-i-1;
				try {
					JSONObject messageObject = result.getJSONObject(j);
					MessageFragment.addMessage(new Message(messageObject));
				} catch (JSONException e1) {
					e1.printStackTrace();
					Utils.makeToast(e1);
				}
				
			}
			System.out.println(result);
		}
	};


	public static Future<JSONArray> getCurrentGroupMessages()
	{
		String groupId = currentGroup.getId();
		AsyncHttpGet get = new AsyncHttpGet(url+"/group/"+groupId+"/messages");
		get.setHeader("session-token", getCurrentUser().getSessionToken());
		return AsyncHttpClient.getDefaultInstance().executeJSONArray(get,groupMessagesCallback);

	}

	
	public static Future<JSONObject> postLogout(){
		AsyncHttpRequest http = new AsyncHttpRequest(URI.create(url+"/logout"),"DELETE");
		http.setHeader("session-token", getCurrentUser().getSessionToken());
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(http, new AsyncHttpClient.JSONObjectCallback() {
			public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
				handleResponse(e,response,result,"Successfully logged out");
			};
		});
	}
	
	
	private static final JSONObjectCallback profileCallback = new AsyncHttpClient.JSONObjectCallback() {
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
			handleResponse(e,response,result);
			JSONObject profileObject;
			try {
				profileObject = result.getJSONObject("profile");
				User tempUser = new User(profileObject);
				tempUser.setToken(getToken());
				System.out.println("currentUser: "+tempUser.getId()+":"+tempUser.getUsername()+":"+tempUser.getSessionToken());
				NetworkManager.setCurrentUser(tempUser);

				MainActivity.saveLoginCredentials(tempUser);
				NetworkManager.getAvatar(tempUser.getId());
				MainActivity.restartFragments(new GroupsFragment());
			} catch (JSONException e1) {
				e1.printStackTrace();
				Utils.makeToast(e1);
			}
			
			System.out.println(result);
			
		};
	};
	
	public static Future<JSONObject> getProfile(){
		AsyncHttpGet get = new AsyncHttpGet(url+"/user");
		get.setHeader("session-token", getCurrentUser().getSessionToken());
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(get,profileCallback);
	}
	
	public static Future<JSONObject> putLeaveGroup(Group g){
		AsyncHttpRequest http = new AsyncHttpRequest(URI.create(url+"/group/"+g.getId()+"/leave"),"PUT");
		http.setHeader("session-token", getCurrentUser().getSessionToken());
		groups.remove(g);
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(http, new AsyncHttpClient.JSONObjectCallback() {
			public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
				handleResponse(e,response,result,"Successfully left the group");
			};
		});
	}
	
	
	public static Future<JSONObject> postCreateGroup(List<String> userNames,String groupName, String message){
		AsyncHttpPost post = new AsyncHttpPost(url+"/group");
		post.setHeader("session-token", getCurrentUser().getSessionToken());
		JSONObject object = new JSONObject();
		try {
			object.put("members", new JSONArray(userNames));
			object.put("name", groupName);
			object.put("text", message);
		} catch (JSONException e) {
			Utils.makeToast(e);
			e.printStackTrace();
			return null;
		}
		JSONObjectBody body = new JSONObjectBody(object);
		post.setBody(body);
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(post, new AsyncHttpClient.JSONObjectCallback() {
			public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
				handleResponse(e,response,result);
				MainActivity.switchView(new GroupsFragment());
				NetworkManager.getGroups();
			};
		});
	}
	
	
	
	public static Future<JSONObject> putInviteUser(String username, Group g){
		AsyncHttpRequest http = new AsyncHttpRequest(URI.create(url+"/group/"+g.getId()+"/add"),"PUT");
		http.setHeader("session-token", getCurrentUser().getSessionToken());
		JSONObject object = new JSONObject();
		try {
			object.put("invitees", new JSONArray(Arrays.asList(username)));
		} catch (JSONException e) {
			Utils.makeToast(e);
			e.printStackTrace();
			return null;
		}
		JSONObjectBody body = new JSONObjectBody(object);
		http.setBody(body);
		
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(http, new AsyncHttpClient.JSONObjectCallback() {
			// Callback is invoked with any exceptions/errors, and the result, if available.
			public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
				handleResponse(e,response,result);
				MainActivity.switchView(new GroupsFragment());
				NetworkManager.getGroups();
			};
		});
	}
	
	public static Future<JSONObject> postRegisterUser(String username, String password){
		AsyncHttpPost post = new AsyncHttpPost(url+"/user");
		JSONObject object = new JSONObject();
		try {
			object.put("username", username);
			object.put("password", password);
		} catch (JSONException e) {
			Utils.makeToast(e);
			e.printStackTrace();
			return null;
		}
		JSONObjectBody body = new JSONObjectBody(object);
		post.setBody(body);
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(post, new AsyncHttpClient.JSONObjectCallback() {
			// Callback is invoked with any exceptions/errors, and the result, if available.
			public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
				handleResponse(e,response,result,"Registration Successful! Login to continue");
			}
		});
	}
	
	private static final DownloadCallback dataCallback = new AsyncHttpClient.DownloadCallback() {

		@Override
		public void onCompleted(Exception e, AsyncHttpResponse source,
				ByteBufferList result) {
			int responseCode = handleResponse(e,source);
			if(responseCode<200 || responseCode>299){
				return;
			}
			String requestUrl = source.getRequest().getUri().toString();
			String[] urlSplit = requestUrl.split("/");
			String userId = urlSplit[urlSplit.length-2];
			
			byte[] data = result.getAllByteArray();
			System.out.println("Avatar UserID: "+userId+ "Length: "+data.length);
			Bitmap avatar = BitmapFactory.decodeByteArray(data, 0, data.length);
			
			if(avatar==null){
				System.out.println("Avatar null for user:"+userId+"");
				return;
			}
			avatar = ProfileFragment.getRoundedCornerBitmap(avatar);
			NetworkManager.getUsernameFromId(userId).setBitmap(avatar);
		}
		
    };
	
	public static synchronized Future<ByteBufferList> getAvatar(String id) {
		AsyncHttpGet get = new AsyncHttpGet(url+"/user/"+id+"/avatar");
		System.out.println("URL: "+url+"/user/"+id+"/avatar");
		get.setHeader("session-token", getCurrentUser().getSessionToken());
		return AsyncHttpClient.getDefaultInstance().executeByteBufferList(get,dataCallback);
	}
	
	public static Future<String> postAvatar(Bitmap bitmap){
		System.out.println("POSTING user Avatar: "+url+"/user/"+getCurrentUser().getId()+"/avatar");
		AsyncHttpPost post = new AsyncHttpPost(url+"/user/"+getCurrentUser().getId()+"/avatar");
		post.setHeader("session-token", getCurrentUser().getSessionToken());
		MultipartFormDataBody body = new MultipartFormDataBody();
		String fileDirectory = saveToInternalSorage(bitmap)+"/avatar.jpeg";
		FilePart fp = new FilePart("avatar",new File(fileDirectory));
		fp.setContentType("image/jpeg");
		body.addPart(fp);
		post.setBody(body);
		return AsyncHttpClient.getDefaultInstance().executeString(post, new AsyncHttpClient.StringCallback() {

			@Override
			public void onCompleted(Exception e, AsyncHttpResponse response,
					String result) {
				NetworkManager.handleResponse(e, response,null,"Successfully saved avatar");
				System.out.println("Avatar result"+result);
			}
		});
	}
	
	public static Future<String> postMultimediaMessage(Message m){
		System.out.println("POSTING multimedia Message: "+url+"/group/"+m.getGroupId()+"/message/"+m.getId()+"/media");
		AsyncHttpPost post = new AsyncHttpPost(url+"/group/"+m.getGroupId()+"/message/"+m.getId()+"/media");
		post.setHeader("session-token", getCurrentUser().getSessionToken());
		MultipartFormDataBody body = new MultipartFormDataBody();
		FilePart fp = new FilePart(m.getMedia().getFileName(),saveToInternalStorage(m.getMedia().getData()));
		fp.setContentType(m.getMedia().getMimeType());
		body.addPart(fp);
		post.setBody(body);
		return AsyncHttpClient.getDefaultInstance().executeString(post, new AsyncHttpClient.StringCallback() {
			@Override
			public void onCompleted(Exception e, AsyncHttpResponse response,
					String result) {
				NetworkManager.handleResponse(e, response,null,"Successfully sent multimedia message");
			}
		});
	}
	
	private static final DownloadCallback mediaCallback = new AsyncHttpClient.DownloadCallback() {

		@Override
		public void onCompleted(Exception e, AsyncHttpResponse source,
				ByteBufferList result) {
			int responseCode = handleResponse(e,source);
			if(responseCode<200 || responseCode>299){
				return;
			}
			String requestUrl = source.getRequest().getUri().toString();
			String[] urlSplit = requestUrl.split("/");
			String messageId = urlSplit[urlSplit.length-2];
			
			byte[] data = result.getAllByteArray();
			System.out.println("Media MessageID: "+messageId+ "Length: "+data.length);
			String content_type = source.getHeaders().getHeaders().get("Content-type");
			MultiMedia mms = new MultiMedia("test.tmp",content_type,data);
			for(Message m : getCurrentGroup().getMessages()){
				if(m.getId().equals(messageId)){
					m.setMedia(mms);
					MessageFragment.updateUI();
					break;
				}
			}
		}
		
    };
	
	public static synchronized Future<ByteBufferList> getMessageMedia(Message m) {
		AsyncHttpGet get = new AsyncHttpGet(url+"/group/"+m.getGroupId()+"/message/"+m.getId()+"/media");
		System.out.println("URL: "+url+"/group/"+m.getGroupId()+"/message/"+m.getId()+"/media");
		get.setHeader("session-token", getCurrentUser().getSessionToken());
		return AsyncHttpClient.getDefaultInstance().executeByteBufferList(get,mediaCallback);
	}
	
	private static File saveToInternalStorage(byte[] data){
		ContextWrapper cw = new ContextWrapper(MainActivity.activity.getApplicationContext());
        File directory = cw.getDir("directoryName", Context.MODE_PRIVATE);
        File mypath=new File(directory,"file.tmp");

        FileOutputStream fos = null;
        try {
			fos = new FileOutputStream(mypath);
			fos.write(data);
	        fos.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        return mypath.getAbsoluteFile();
	}
	
	private static String saveToInternalSorage(Bitmap bitmapImage){
        ContextWrapper cw = new ContextWrapper(MainActivity.activity.getApplicationContext());
        File directory = cw.getDir("directoryName", Context.MODE_PRIVATE);
        File mypath=new File(directory,"avatar.jpeg");

        FileOutputStream fos = null;
        try {
           // fos = openFileOutput(filename, Context.MODE_PRIVATE);

            fos = new FileOutputStream(mypath);

            // Use the compress method on the BitMap object to write image to the OutputStream
            bitmapImage.compress(Bitmap.CompressFormat.JPEG, 80, fos);
            fos.close();
        } catch (Exception e) {
            e.printStackTrace();
            Utils.makeToast(e);
        }
        return directory.getAbsolutePath();
    }
	
	
	
	
	private static int handleResponse(Exception e,AsyncHttpResponse response){
		return handleResponse(e,response,null,null);
	}
	private static int handleResponse(Exception e,AsyncHttpResponse response,JSONObject result){
		return handleResponse(e,response,result,null);
	}
	
	private static int handleResponse(Exception e,AsyncHttpResponse response,JSONObject result, String correctResponseText){
		if (e != null) {
			e.printStackTrace();
			Utils.makeToast(e);
			return 500;
		}
		int responseCode = response.getHeaders().getHeaders().getResponseCode();
		if(responseCode>=200 && responseCode<300){
			if(correctResponseText!=null){
				Utils.makeToast(correctResponseText);
			}
		}else{
			String errorMessage = "";
			if(result!=null){
				try {
					errorMessage = result.getString("error");
				} catch (JSONException e1) {
					e1.printStackTrace();
				}
			}
			Utils.makeToast(responseCode+": "+errorMessage);
		}
		return responseCode;
		
	}
	
	
	public static String getURL(){
		return url;
	}

	public static String getToken() {
		return getCurrentUser().getSessionToken();
	}

	public static Group getCurrentGroup(){
		return currentGroup;
	}
	
	public static HashMap<String,Group> getAllGroups(){
		return groups;
	}
	
	public static void setGroups(HashMap<String,Group> g){
		groups = g;
	}

	public static void setCurrentRoom(Group group){
		currentGroup = group;
	}

	public static User getCurrentUser(){
		return  users.get(currentUserId);
	}
	
	public static User getUsernameFromId(String id){
		return users.get(id);
	}
	
	public static void setCurrentUser(User user){
		if(users.containsKey("0")){ //Default value for a user is 0.
			users.remove("0");
		}
		
		if(!users.containsKey(user.getId())){
			users.put(user.getId(), user);
		}else{
			User tempUser = users.get(user.getId());
			tempUser.setToken(user.getSessionToken());
			tempUser.setUsername(user.getUsername());
		}
		currentUserId=user.getId();
	}
	
	public static HashMap<String,User> getUsersMap(){
		return users;
	}
	public static User getFastChatUser(){
		return fastChatUser;
	}
}
