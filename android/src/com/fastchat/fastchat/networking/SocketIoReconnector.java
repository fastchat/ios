package com.fastchat.fastchat.networking;

import java.util.concurrent.ExecutionException;

import android.graphics.Color;
import android.util.Log;

import com.fastchat.fastchat.fragments.MessageFragment;
import com.koushikdutta.async.future.Future;
import com.koushikdutta.async.http.socketio.SocketIOClient;

public class SocketIoReconnector implements Runnable {

	private static SocketIOClient client = null;
	
	private static final String TAG=SocketIoReconnector.class.getSimpleName();
	
	private static Boolean running;
	
	public SocketIoReconnector(){
		running=true;
	}
	
	public void run(){
		int attempt = 1;
		int connected = 1;
		 while(running){ // While the app is running.
			client = SocketIoController.getClient();
			if(client == null){  //Client has not connected to the server
				MessageFragment.changeServerStatus("Connecting...", Color.RED);
				Log.d(TAG,"Connect Attempt: "+attempt);
				Future<SocketIOClient> future = SocketIoController.connect();
				try {
					client = future.get();
				} catch (InterruptedException e) {
				} catch (ExecutionException e) {
				}
				attempt+=1;
				connected=1;
			}
			else if(!client.isConnected() && attempt>3){ // Reconnecting is failing. Start new connection
				client.disconnect();
				SocketIoController.setClient(null);
				client=null;
				
			}
			else if(!client.isConnected()) //Attempt to reconnect to the server
			{
				MessageFragment.changeServerStatus("Reconnecting...", Color.RED);
				Log.d(TAG,"Reconnect Attempt: "+attempt);
				client.disconnect();
				client.reconnect();
				try {
					Thread.sleep(2500); //Wait 2 seconds for client to finish reconnecting
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				attempt+=1;
				connected=1;
			}
			else{  // Client is connected to the socket.io server.
				attempt=1;
				if(connected==10){
					MessageFragment.changeServerStatus("", Color.WHITE);
					connected+=1;
				}
				else if(connected<10){
					connected+=1;
					MessageFragment.changeServerStatus("Connected", Color.GREEN);
				}
				
			}
			try { // Sleep .5 seconds before testing connection.
				Thread.sleep(500);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public static void stopReconnect(){
		running=false;
	}
}
