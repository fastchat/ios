package com.example.fastchat.models;

import org.json.JSONException;
import org.json.JSONObject;

import com.example.fastchat.Utils;

public class User {
	
	private String id;
	private String username;
	private String sessiontoken;
	
	public User(String id, String username, String token){
		this.id=id;
		this.username=username;
		this.sessiontoken=token;
	}
	
	public User(JSONObject userObject){
		try{
			this.username = userObject.getString("username");
			this.id = userObject.getString("_id");
		}catch(JSONException e){
			Utils.makeToast(e);
			e.printStackTrace();
		}
	}
	
	public String getId(){
		return this.id;
	}
	
	public void setId(String id){
		this.id=id;
	}
	
	public String getUsername(){
		return this.username;
	}
	
	public void setUsername(String username){
		this.username=username;
	}
	
	public void setToken(String token){
		this.sessiontoken=token;
	}
	
	
	public String getSessionToken(){
		return this.sessiontoken;
	}

}