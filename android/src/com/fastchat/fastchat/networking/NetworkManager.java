package com.fastchat.fastchat.networking;

import java.net.URI;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.support.v4.app.Fragment;

import com.fastchat.fastchat.MainActivity;
import com.fastchat.fastchat.Utils;
import com.fastchat.fastchat.fragments.GroupsFragment;
import com.fastchat.fastchat.fragments.MessageFragment;
import com.fastchat.fastchat.models.Group;
import com.fastchat.fastchat.models.Message;
import com.fastchat.fastchat.models.User;
import com.koushikdutta.async.future.Future;
import com.koushikdutta.async.http.AsyncHttpClient;
import com.koushikdutta.async.http.AsyncHttpClient.JSONArrayCallback;
import com.koushikdutta.async.http.AsyncHttpClient.JSONObjectCallback;
import com.koushikdutta.async.http.AsyncHttpGet;
import com.koushikdutta.async.http.AsyncHttpPost;
import com.koushikdutta.async.http.AsyncHttpRequest;
import com.koushikdutta.async.http.AsyncHttpResponse;
import com.koushikdutta.async.http.body.JSONObjectBody;

public class NetworkManager {

	private static final String url ="http://powerful-cliffs-9562.herokuapp.com:80";
	//private static final String url ="http://minty.shawnsthompson.com:3000";
	private static User currentUser;
	private static Group currentGroup;
	// HashMap <groupId, Groups>
	private static HashMap<String,Group> groups = new HashMap<String,Group>();


	private static final JSONObjectCallback loginCallback = new AsyncHttpClient.JSONObjectCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
			if (e != null) {
				e.printStackTrace();
				Utils.makeToast(e);
				return;
			}
			System.out.println("I got a JSONObject: " + result);
			int responseCode = response.getHeaders().getHeaders().getResponseCode();
			if(responseCode==401){
				Utils.makeToast("Incorrect username or password!");
				return;
			}else if(responseCode!=200){
				Utils.makeToast(responseCode+" "+result);
			}
			Fragment fragment = new GroupsFragment();
			
			try {
				currentUser.setToken(result.getString("session-token"));
				getProfile();
			} catch (JSONException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			MainActivity.saveLoginCredentials(currentUser);
			NetworkManager.postDeviceId(MainActivity.regid);
			MainActivity.switchView(fragment);



		}
	};

	public static Future<JSONObject> postLogin(String username, String password){
		currentUser = new User(null,username,null);
		AsyncHttpPost post = new AsyncHttpPost(url+"/login");
		JSONObject object = new JSONObject();
		try {
			object.put("username", username);
			object.put("password", password);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			Utils.makeToast(e);
			e.printStackTrace();
		}
		JSONObjectBody body = new JSONObjectBody(object);
		post.setBody(body);
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(post, loginCallback);
	}

	
	private static final JSONArrayCallback groupsCallback = new AsyncHttpClient.JSONArrayCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONArray result) {
			if (e != null) {
				e.printStackTrace();
				Utils.makeToast(e);
				return;
			}
			int responseCode = response.getHeaders().getHeaders().getResponseCode();
			if(responseCode!=200){
				Utils.makeToast(responseCode+" "+result);
				return;
			}

			System.out.println(result);
			GroupsFragment.addGroups(result);
		}
	};
	public static Future<JSONArray> getGroups(){

		AsyncHttpGet get = new AsyncHttpGet(url+"/group");
		get.setHeader("session-token", currentUser.getSessionToken());
		return AsyncHttpClient.getDefaultInstance().executeJSONArray(get,groupsCallback);

	}
	
	private static final JSONObjectCallback deviceRegCallback = new AsyncHttpClient.JSONObjectCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
			if (e != null) {
				e.printStackTrace();
				Utils.makeToast(e);
				return;
			}

			System.out.println(result);
		}
	};


	
	public static Future<JSONObject> postDeviceId(String reg_id){
		if(reg_id==null || reg_id.equals("")){
			return null;
		}
		AsyncHttpPost post = new AsyncHttpPost(url+"/user/device");
		post.setHeader("session-token", currentUser.getSessionToken());
		JSONObject object = new JSONObject();
		try {
			object.put("token", reg_id);
			object.put("type", "android");
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			Utils.makeToast(e);
			e.printStackTrace();
		}
		JSONObjectBody body = new JSONObjectBody(object);
		post.setBody(body);
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(post, deviceRegCallback);
	}
	private static final JSONArrayCallback groupMessagesCallback = new AsyncHttpClient.JSONArrayCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONArray result) {
			if (e != null) {
				e.printStackTrace();
				Utils.makeToast(e);
				return;
			}
			for(int i=0;i<result.length();i++){
				int j = result.length()-i-1;
				try {
					JSONObject messageObject = result.getJSONObject(j);
					MessageFragment.addMessage(new Message(messageObject));
				} catch (JSONException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				
			}
			System.out.println(result);
		}
	};




	public static Future<JSONArray> getCurrentGroupMessages()
	{
		String groupId = currentGroup.getId();
		AsyncHttpGet get = new AsyncHttpGet(url+"/group/"+groupId+"/messages");
		get.setHeader("session-token", currentUser.getSessionToken());
		return AsyncHttpClient.getDefaultInstance().executeJSONArray(get,groupMessagesCallback);

	}

	private static final JSONObjectCallback logoutCallback = new AsyncHttpClient.JSONObjectCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
			if (e != null) {
				e.printStackTrace();
				Utils.makeToast(e);
				return;
			}

			System.out.println(result);
		};
	};
	
	public static Future<JSONObject> postLogout(){
		AsyncHttpRequest http = new AsyncHttpRequest(URI.create(url+"/logout"),"DELETE");
		http.setHeader("session-token", currentUser.getSessionToken());
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(http, logoutCallback);
	}
	
	
	private static final JSONObjectCallback profileCallback = new AsyncHttpClient.JSONObjectCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
			if (e != null) {
				e.printStackTrace();
				Utils.makeToast(e);
				return;
			}
			JSONObject profileObject;
			try {
				profileObject = result.getJSONObject("profile");
				User tempUser = new User(profileObject);
				tempUser.setToken(getToken());
				System.out.println("currentUser: "+tempUser.getId()+":"+tempUser.getUsername()+":"+tempUser.getSessionToken());
				MainActivity.saveLoginCredentials(tempUser);
				NetworkManager.setCurrentUser(tempUser);
			} catch (JSONException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
				Utils.makeToast(e1);
			}
			
			System.out.println(result);
			
		};
	};
	
	public static Future<JSONObject> getProfile(){
		AsyncHttpGet get = new AsyncHttpGet(url+"/user");
		get.setHeader("session-token", currentUser.getSessionToken());
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(get,profileCallback);
	}
	
	private static final JSONObjectCallback leaveGroupCallback = new AsyncHttpClient.JSONObjectCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
			if (e != null) {
				e.printStackTrace();
				Utils.makeToast(e);
				return;
			}
			System.out.println(result);
		};
	};
	
	public static Future<JSONObject> putLeaveGroup(Group g){
		AsyncHttpRequest http = new AsyncHttpRequest(URI.create(url+"/group/"+g.getId()+"/leave"),"PUT");
		http.setHeader("session-token", currentUser.getSessionToken());
		groups.remove(g);
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(http, leaveGroupCallback);
	}
	
	
	private static final JSONObjectCallback createGroupCallback = new AsyncHttpClient.JSONObjectCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
			if (e != null) {
				e.printStackTrace();
				Utils.makeToast(e);
				return;
			}

			System.out.println(result);
			MainActivity.switchView(new GroupsFragment());
			NetworkManager.getGroups();
		};
	};
	
	
	public static Future<JSONObject> postCreateGroup(ArrayList<String> userNames,String groupName, String message){
		AsyncHttpPost post = new AsyncHttpPost(url+"/group");
		post.setHeader("session-token", currentUser.getSessionToken());
		JSONObject object = new JSONObject();
		try {
			object.put("members", new JSONArray(userNames));
			object.put("name", groupName);
			object.put("text", message);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			Utils.makeToast(e);
			e.printStackTrace();
		}
		JSONObjectBody body = new JSONObjectBody(object);
		post.setBody(body);
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(post, createGroupCallback);
	}
	
	private static final JSONObjectCallback inviteUserCallback = new AsyncHttpClient.JSONObjectCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
			if (e != null) {
				e.printStackTrace();
				Utils.makeToast(e);
				return;
			}
			int responseCode = response.getHeaders().getHeaders().getResponseCode();
			if(responseCode!=200){
				Utils.makeToast(responseCode+" "+result);
			}

			System.out.println(result);
			MainActivity.switchView(new GroupsFragment());
			NetworkManager.getGroups();
		};
	};
	
	
	public static Future<JSONObject> putInviteUser(String username, Group g){
		AsyncHttpRequest http = new AsyncHttpRequest(URI.create(url+"/group/"+g.getId()+"/add"),"PUT");
		http.setHeader("session-token", currentUser.getSessionToken());
		JSONObject object = new JSONObject();
		try {
			object.put("invitees", new JSONArray(Arrays.asList(username)));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			Utils.makeToast(e);
			e.printStackTrace();
		}
		JSONObjectBody body = new JSONObjectBody(object);
		http.setBody(body);
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(http, inviteUserCallback);
	}
	
	
	public static String getURL(){
		return url;
	}

	public static String getToken() {
		return currentUser.getSessionToken();
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
		return  currentUser;
	}
	
	public static User getUsernameFromId(String id){
		return currentGroup.getUsername(id);
	}
	
	public static void setCurrentUser(User user){
		currentUser=user;
	}
}
