package com.fastchat.fastchat.fragments;

import android.util.Log;

import com.fastchat.fastchat.models.User;
import com.fastchat.fastchat.networking.NetworkManager;

public class LoginSuccessWatcher implements Runnable {

	private static boolean running = true;

	public LoginSuccessWatcher(){
		running=true;
	}

	public void run(){
		while(running){
			User currentUser = NetworkManager.getCurrentUser();
			if(currentUser!=null){
				String token = currentUser.getSessionToken();
				if(token!=null && token.length()>0){
					LoginFragment.loginSuccess();
					running=false;
					break;
				}
			}
			try {
				Thread.sleep(100);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public static void stopRunning(){
		running=false;
	}
}
