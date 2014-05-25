package com.example.fastchat;

import java.util.concurrent.ExecutionException;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.koushikdutta.async.future.Future;
import com.koushikdutta.async.http.AsyncHttpClient;
import com.koushikdutta.async.http.socketio.Acknowledge;
import com.koushikdutta.async.http.socketio.ConnectCallback;
import com.koushikdutta.async.http.socketio.EventCallback;
import com.koushikdutta.async.http.socketio.JSONCallback;
import com.koushikdutta.async.http.socketio.SocketIOClient;
import com.koushikdutta.async.http.socketio.SocketIORequest;
import com.koushikdutta.async.http.socketio.StringCallback;

public class MessageViewController {

	private static SocketIOClient client;
	
	public static void connect(){
		String newURL = NetworkManager.getURL();
		System.out.println("Socket.io connect:"+newURL+"token:"+NetworkManager.getToken());
		SocketIORequest request = new SocketIORequest(newURL,null,"token="+NetworkManager.getToken());
		//request.setHeader("token", NetworkManager.getToken());
		SocketIOClient.connect(AsyncHttpClient.getDefaultInstance(), request, new ConnectCallback() {
		    @Override
		    public void onConnectCompleted(Exception ex, SocketIOClient client) {
		        if (ex != null) {
		            ex.printStackTrace();
		            Utils.makeToast(ex);
		            return;
		        }
		        MessageViewController.client=client;
		        client.setStringCallback(new StringCallback() {

					@Override
					public void onString(String string, Acknowledge acknowledge) {
						System.out.println("onString:"+string);
						
					}
		        });
		        client.on("someEvent", new EventCallback() {

					@Override
					public void onEvent(JSONArray argument,
							Acknowledge acknowledge) {
						System.out.println("onEvent:"+argument);
						
					}
		        });
		        client.setJSONCallback(new JSONCallback() {

					@Override
					public void onJSON(JSONObject json, Acknowledge acknowledge) {
						System.out.println("onJSON:"+json);
						
					}
		        });
		        MessageViewController.sendMessage("Hello World");
		    }
		});
	}
	
	public static void sendMessage(String text){
		JSONObject message = new JSONObject();
		JSONArray array = new JSONArray();
		try {
			message.put("text", text);
			array.put(message);
			client.emit("message",array);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			Utils.makeToast(e);
		}
		
	}
}