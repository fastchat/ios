package com.fastchat.fastchat.networking;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.fastchat.fastchat.Utils;
import com.fastchat.fastchat.fragments.FastChatTextWatcher;
import com.fastchat.fastchat.fragments.MessageFragment;
import com.fastchat.fastchat.models.Group;
import com.fastchat.fastchat.models.Message;
import com.koushikdutta.async.future.Future;
import com.koushikdutta.async.http.AsyncHttpClient;
import com.koushikdutta.async.http.socketio.Acknowledge;
import com.koushikdutta.async.http.socketio.ConnectCallback;
import com.koushikdutta.async.http.socketio.DisconnectCallback;
import com.koushikdutta.async.http.socketio.EventCallback;
import com.koushikdutta.async.http.socketio.JSONCallback;
import com.koushikdutta.async.http.socketio.ReconnectCallback;
import com.koushikdutta.async.http.socketio.SocketIOClient;
import com.koushikdutta.async.http.socketio.SocketIORequest;
import com.koushikdutta.async.http.socketio.StringCallback;

public class SocketIoController {

	private static SocketIOClient client;
	
	private static Future<SocketIOClient> clientFuture;
	
	public static Future<SocketIOClient> connect(){
		String newURL = NetworkManager.getURL();
		System.out.println("Socket.io connect:"+newURL+"token:"+NetworkManager.getToken());
		SocketIORequest request = new SocketIORequest(newURL,null,"token="+NetworkManager.getToken());
		//request.setHeader("token", NetworkManager.getToken());
		if(clientFuture !=null){
			if(!clientFuture.isDone()){
				return clientFuture;
			}
		}
		if(client!=null){
			if(client.isConnected())
			{
				client.disconnect();
			}
		}
		clientFuture = SocketIOClient.connect(AsyncHttpClient.getDefaultInstance(), request, new ConnectCallback() {
		    @Override
		    public void onConnectCompleted(Exception ex, SocketIOClient client) {
		        if (ex != null) {
		            ex.printStackTrace();
		            Utils.makeToast(ex);
		            return;
		        }
		        
		        client.setStringCallback(new StringCallback() {

					@Override
					public void onString(String string, Acknowledge acknowledge) {
						System.out.println("onString:"+string);
						
					}
		        });
		        client.on("message", new EventCallback() {

					@Override
					public void onEvent(JSONArray argument,
							Acknowledge acknowledge) {
						System.out.println("onEvent:"+argument);
						try {
							JSONObject messageObject = argument.getJSONObject(0);
							Message message = new Message(messageObject);
							if(message.getGroupId().equals(NetworkManager.getCurrentGroup().getId())){
								MessageFragment.addMessage(message);
							}else{
								NetworkManager.getAllGroups().get(message.getGroupId()).addMessage(message);
							}
						} catch (JSONException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						
					}
		        });
		        client.on("typing",new EventCallback(){
		        	@Override
					public void onEvent(JSONArray argument,
							Acknowledge acknowledge) {
		        		System.out.println(argument);
		        		JSONObject typingObject;
						try {
							typingObject = argument.getJSONObject(0);
			        		String userId = typingObject.getString("from");
			        		boolean isTyping = typingObject.getBoolean("typing");
			        		String groupId = typingObject.getString("group");
			        		Group group = NetworkManager.getCurrentGroup();
			        		if(group==null && !groupId.equals(NetworkManager.getCurrentGroup().getId())){
			        			return;
			        		}
			        		if(isTyping){
			        			MessageFragment.showTyping(NetworkManager.getCurrentGroup().getUsername(userId));
			        		}
			        		else{
			        			MessageFragment.hideTyping(NetworkManager.getCurrentGroup().getUsername(userId));
			        		}
						} catch (JSONException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
							Utils.makeToast(e);
						}
		        	}
		        });
		        client.setJSONCallback(new JSONCallback() {

					@Override
					public void onJSON(JSONObject json, Acknowledge acknowledge) {
						System.out.println("onJSON:"+json);
						
					}
		        });
		        SocketIoController.client=client;
		        client.setDisconnectCallback(new DisconnectCallback(){
					@Override
					public void onDisconnect(Exception e) {
						Utils.makeToast("Lost connection with the server");
					}
		        });
		        client.setReconnectCallback(new ReconnectCallback(){
					@Override
					public void onReconnect() {
						Utils.makeToast("Reconnected to the server");
					}
		        });
		    }
		});
		return clientFuture;
	}
	
	public static void disconnect(){
		
		if(clientFuture!=null){
			clientFuture.cancel();
		}
		if(client!=null){
			client.setDisconnectCallback(null);
			client.disconnect();
		}
	}
	
	public static void sendMessage(final Message m){
		if(client==null || !client.isConnected()){
			Utils.makeToast("Couldn't send message. Try again later");
			MessageFragment.removeMessage(m);
		}else{
			client.emit("message",m.getSendFormat());
		}
		
	}
	
	public static void sendStartTyping(){
		JSONArray array = new JSONArray();
		JSONObject object = new JSONObject();
		try {
			object.put("typing", true);
			object.put("from", NetworkManager.getCurrentUser().getId());
			object.put("group", NetworkManager.getCurrentGroup().getId());
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		array.put(object);
		if(client!=null){
			client.emit("typing",array);
		}
	}
	
	public static void sendStopTyping(){
		FastChatTextWatcher.resetTextWatcher();
		JSONArray array = new JSONArray();
		JSONObject object = new JSONObject();
		try {
			object.put("typing", false);
			object.put("from", NetworkManager.getCurrentUser().getId());
			object.put("group", NetworkManager.getCurrentGroup().getId());
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		array.put(object);
		if(client!=null){
			client.emit("typing",array);
		}
	}

	public static boolean isConnected() {
		if(client==null){
			return false;
		}
		return client.isConnected();
	}
}
