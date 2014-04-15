package com.fastchat.fastchat.models;

import java.util.ArrayList;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.fastchat.fastchat.networking.NetworkManager;

public class Group {

	private ArrayList<Message> messages;
	private HashMap<String,User> members;
	private String id;
	private String name;
	
	public Group(JSONObject groupObject){
		this.messages = new ArrayList<Message>();
		this.members = new HashMap<String,User>();
		try {
			this.id = groupObject.getString("_id");
			this.name = groupObject.getString("name");
			JSONArray membersJSON = groupObject.getJSONArray("members");
			for(int i=0;i<membersJSON.length();i++){
				JSONObject userObject = membersJSON.getJSONObject(i);
				User tempUser = new User(userObject);
				HashMap<String,User> users = NetworkManager.getUsersMap();
				if(users.containsKey(tempUser.getId())){
					User u = users.get(tempUser.getId());
					members.put(tempUser.getId(), u);
				}else{
					users.put(tempUser.getId(), tempUser);
					members.put(tempUser.getId(), tempUser);
					NetworkManager.getAvatar(tempUser.getId());
				}
					
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void addMessage(Message m){
		messages.add(m);
	}
	
	public ArrayList<Message> getMessages(){
		return this.messages;
	}
	
	public User getUsername(String id){
		return members.get(id);
	}
	
	public String getId(){
		return this.id;
	}

	public String getName() {
		return this.name;
	}
	
	public HashMap<String,User> getUsers(){
		return members;
	}
}