package com.example.fastchat.fragments;

import com.example.fastchat.networking.SocketIoController;

import android.text.Editable;
import android.text.TextWatcher;

public class FastChatTextWatcher implements TextWatcher{
   	 private static Long lastTyping=null;
   	 private static Thread typingThread;
   	 
        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
        	if(lastTyping==null){
        		SocketIoController.sendStartTyping();
        		typingThread = new Thread(new Runnable(){
        			public void run(){
        				while(true){
        					Long timeDifference = System.currentTimeMillis()-FastChatTextWatcher.getLastTyping();
        					if(timeDifference>2000){//If the user has stopped typing for 2 seconds. Send stop typing.
        						SocketIoController.sendStopTyping();
        						break;
        					}
        					try {
								Thread.sleep(250);
							} catch (InterruptedException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}//Sleep for 250 ms
        				}
        			}
        		});
        		typingThread.start();
        	}
           	 lastTyping=System.currentTimeMillis();
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
