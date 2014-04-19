package com.example.fastchat;

import org.json.JSONException;
import org.json.JSONObject;

import com.koushikdutta.async.future.Future;
import com.koushikdutta.async.http.AsyncHttpClient;
import com.koushikdutta.async.http.AsyncHttpClient.JSONObjectCallback;
import com.koushikdutta.async.http.AsyncHttpPost;
import com.koushikdutta.async.http.AsyncHttpResponse;
import com.koushikdutta.async.http.body.JSONObjectBody;

public class NetworkManager {
	
	private static final String url ="http://minty.shawnsthompson.com:3000";
	private static String session_token = "";
	
	
	private static JSONObjectCallback loginCallback = new AsyncHttpClient.JSONObjectCallback() {
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
			     
			} catch (JSONException e1) {
				Utils.makeToast(e1);
				e1.printStackTrace();
			}
	        MessageViewController.connect();
	       
	    }
	};
	
	
	public static Future<JSONObject> postLogin(String username, String password){
		
		return postLogin(username,password,loginCallback);
	}
	
	public static Future<JSONObject> postLogin(String username, String password,JSONObjectCallback callback){
		
		AsyncHttpPost post = new AsyncHttpPost(url+"/login");
		JSONObject object = new JSONObject();
		try {
			object.put("username", username);
			object.put("password", password);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		JSONObjectBody body = new JSONObjectBody(object);
		post.setBody(body);
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(post, callback);
	}
	
	public static String getURL(){
		return url;
	}

	public static String getToken() {
		return session_token;
	}
}
