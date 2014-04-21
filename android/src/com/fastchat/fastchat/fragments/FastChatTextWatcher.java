package com.fastchat.fastchat.fragments;

import com.fastchat.fastchat.models.Group;
import com.fastchat.fastchat.networking.NetworkManager;
import com.fastchat.fastchat.networking.SocketIoController;

import android.text.Editable;
import android.text.TextWatcher;

public class FastChatTextWatcher implements TextWatcher{
   	 private static Long lastTyping=null;
   	 private static Thread typingThread;
   	 private static Group currGroup;
   	 private static final long RESET_TIME = 2000L;
   	 
   	private static final String TAG=FastChatTextWatcher.class.getName();
   	
   	public FastChatTextWatcher(){
   	}
   	 
        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
        	if(lastTyping==null){
        		lastTyping = System.currentTimeMillis();
        		currGroup = NetworkManager.getCurrentGroup();
        		SocketIoController.sendStartTyping();
        		typingThread = new Thread(new Runnable(){
        			public void run(){
        				while(true){
        					Long timeDifference = System.currentTimeMillis()-FastChatTextWatcher.getLastTyping();
        					if(timeDifference>=RESET_TIME){//If the user has stopped typing for 1 seconds. Send stop typing.
        						SocketIoController.sendStopTyping(currGroup);
        						break;
        					}
        					try {
								Thread.sleep(RESET_TIME-timeDifference+5);
							} catch (InterruptedException e) {
								// TODO Auto-generated catch block
								SocketIoController.sendStopTyping(currGroup);
								e.printStackTrace();
								break;
							}
        				}
        			}
        		});
        		typingThread.start();
        	}else{
           	 lastTyping=System.currentTimeMillis();
        	}
        }

        @Override
        public void beforeTextChanged(CharSequence s, int start, int count,
                int after) {
        }

        @Override
        public void afterTextChanged(Editable s) {

        }
        
        
        public static Long getLastTyping(){
        	return lastTyping;
        }
        
        public static void resetTextWatcher(){
        	lastTyping=null;
        	typingThread=null;
        }
}
