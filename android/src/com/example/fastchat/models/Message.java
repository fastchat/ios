package com.example.fastchat.models;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import com.example.fastchat.Utils;
import com.example.fastchat.networking.NetworkManager;

public class Message {

	private String id;
	private String text;
	private User from;
	private String groupId;
	private String sentTime;
	
	public Message(String text,User from){
		this.text=text;
		this.from=from;
	}
	
	public Message(JSONObject messageObject){
		try {
			this.text=messageObject.getString("text");
			this.from= NetworkManager.getUsernameFromId(messageObject.getString("from"));
			this.groupId = messageObject.getString("group");
			this.sentTime= messageObject.getString("sent");
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		
	}
	
	
	public String getDateString(){
		SimpleDateFormat dfOut = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss",Locale.US);
		 Calendar cal = Calendar.getInstance();
		 TimeZone tz = cal.getTimeZone();
		 dfOut.setTimeZone(tz);
		if(this.sentTime==null || this.sentTime.equals("")){
			Date date = new Date();
			return dfOut.format(date);
		}
		 SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",Locale.US);
		 df.setTimeZone(TimeZone.getTimeZone("UTC"));
		try {
			 Date date = df.parse(this.sentTime);
			 
			 return dfOut.format(date);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			Utils.makeToast(e);
		}
		return "";
	}
	
	public String getText(){
		return this.text;
	}
	
	public boolean isMine(){
		return NetworkManager.getCurrentUser().getUsername().equals(this.from.getUsername());
	}
	
	public User getFrom(){
		return this.from;
	}
	
	public String getId(){
		return this.id;
	}
	
	public String getGroupId(){
		return this.groupId;
	}
	
	public JSONArray getSendFormat(){
		JSONObject message = new JSONObject();
		JSONArray array = new JSONArray();
		try {
			message.put("text", text);
			message.put("group", NetworkManager.getCurrentGroup().getId());
			array.put(message);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			Utils.makeToast(e);
		}
		Log.i(this.getClass().getName(),"Send Message:"+array);
		return array;
	}
}
