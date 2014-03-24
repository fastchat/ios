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
	
	private static final String url ="http://powerful-cliffs-9562.herokuapp.com/login";
	
	private static JSONObjectCallback callback = new AsyncHttpClient.JSONObjectCallback() {
	    // Callback is invoked with any exceptions/errors, and the result, if available.
	    public void onCompleted(Exception e, AsyncHttpResponse response, JSONObject result) {
	        if (e != null) {
	            e.printStackTrace();
	            return;
	        }
	        System.out.println("I got a JSONObject: " + result);
	    }
	};
	
	
	public static Future<JSONObject> postLogin(String username, String password){
		
		return postLogin(username,password,callback);
	}
	
	public static Future<JSONObject> postLogin(String username, String password,JSONObjectCallback callback){
		
		AsyncHttpPost post = new AsyncHttpPost(url);
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
		System.out.println(body);
		return AsyncHttpClient.getDefaultInstance().executeJSONObject(post, callback);
	}
	
	
}
