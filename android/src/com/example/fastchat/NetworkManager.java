package com.example.fastchat;

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
	
	private static final String url ="http://minty.shawnsthompson.com:3000";
	private static String session_token = "";
	private static JSONObject currentRoom;
	
	
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
	
	
	public static Future<JSONArray> getGroups(){
		
		AsyncHttpGet get = new AsyncHttpGet(url+"/group");
		get.setHeader("session-token", session_token);
		return AsyncHttpClient.getDefaultInstance().executeJSONArray(get,groupsCallback);
		
	}
	
	
	public static Future<JSONObject> postLogin(String username, String password){
		
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
	
	public static String getURL(){
		return url;
	}

	public static String getToken() {
		return session_token;
	}
	
	public static JSONObject getCurrentRoom(){
		return currentRoom;
	}
	
	public static void setCurrentRoom(JSONObject room){
		currentRoom = room;
	}
}
