package com.example.fastchat;

import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.support.v4.app.Fragment;

import com.koushikdutta.async.future.Future;
import com.koushikdutta.async.http.AsyncHttpClient;
import com.koushikdutta.async.http.AsyncHttpClient.JSONArrayCallback;
import com.koushikdutta.async.http.AsyncHttpClient.JSONObjectCallback;
import com.koushikdutta.async.http.AsyncHttpGet;
import com.koushikdutta.async.http.AsyncHttpPost;
import com.koushikdutta.async.http.AsyncHttpResponse;
import com.koushikdutta.async.http.body.JSONObjectBody;

public class NetworkManager {

	private static final String url ="http://powerful-cliffs-9562.herokuapp.com:80";
	//private static final String url ="http://minty.shawnsthompson.com:3000";
	private static String session_token = "";
	private static String username ="";
	private static JSONObject currentRoom;
	private static HashMap<String, String> currentRoomUsers = new HashMap<String,String>();


	private static final JSONObjectCallback loginCallback = new AsyncHttpClient.JSONObjectCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
			if (e != null) {
				e.printStackTrace();
				Utils.makeToast(e);
				return;
			}
			try {
				session_token = result.getString("session-token");
				System.out.println("I got a JSONObject: " + result);
				Fragment fragment = new RoomsFragment();
				postDeviceId(MainActivity.regid);
				MainActivity.saveLoginCredentials(username, session_token);
				MainActivity.switchView(fragment);
			} catch (JSONException e1) {
				Utils.makeToast("Invalid Username and/or Password");
				e1.printStackTrace();
			}



		}
	};

	private static final JSONArrayCallback groupsCallback = new AsyncHttpClient.JSONArrayCallback() {
		// Callback is invoked with any exceptions/errors, and the result, if available.
		public void onCompleted(Exception e, AsyncHttpResponse response, JSONArray result) {
			if (e != null) {
				e.printStackTrace();
				Utils.makeToast(e);
				return;
			}

			System.out.println(result);
			RoomsFragment.addRoom(result);
		}
	};


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
					String message = messageObject.getString("text");
					String from = currentRoomUsers.get(messageObject.getString("from"));
					if(from.equals(username)){
						MessageFragment.addMessage(message, true,from);
					}else{
						MessageFragment.addMessage(message, false,from);
					}
					
				} catch (JSONException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				
			}
			System.out.println(result);
		}
	};

	public static Future<JSONArray> getGroups(){

		AsyncHttpGet get = new AsyncHttpGet(url+"/group");
		get.setHeader("session-token", session_token);
		return AsyncHttpClient.getDefaultInstance().executeJSONArray(get,groupsCallback);

	}


	public static Future<JSONArray> getCurrentGroupMessages()
	{
		String groupId="";
		try {
			groupId = currentRoom.getString("_id");
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		AsyncHttpGet get = new AsyncHttpGet(url+"/group/"+groupId+"/messages");
		get.setHeader("session-token", session_token);
		return AsyncHttpClient.getDefaultInstance().executeJSONArray(get,groupMessagesCallback);

	}



	public static Future<JSONObject> postLogin(String username, String password){
		NetworkManager.username=username;
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



	public static Future<JSONObject> postDeviceId(String reg_id){
		if(reg_id==null || reg_id.equals("")){
			return null;
		}
		AsyncHttpPost post = new AsyncHttpPost(url+"/user/device");
		post.setHeader("session-token", session_token);
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

	public static String getURL(){
		return url;
	}

	public static String getToken() {
		return session_token;
	}
	
	public static void setToken(String token){
		session_token=token;
	}

	public static JSONObject getCurrentRoom(){
		return currentRoom;
	}

	public static void setCurrentRoom(JSONObject room){
		currentRoom = room;
		JSONArray users;
		try {
			users = room.getJSONArray("members");

			for(int i=0;i<users.length();i++){
				JSONObject userObject = users.getJSONObject(i);
				currentRoomUsers.put(userObject.getString("_id"), userObject.getString("username"));
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			Utils.makeToast(e);
		}
	}

	public static String getUsername(){
		return username;
	}
	
	public static void setUsername(String user){
		username=user;
	}
}
