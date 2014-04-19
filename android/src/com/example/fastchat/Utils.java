package com.example.fastchat;

import android.widget.Toast;

public class Utils {

	public static void makeToast(Exception e){
		final String message = e.getMessage();
    	(MainActivity.activity).runOnUiThread(new Runnable(){
    		public void run(){
    			Toast.makeText(MainActivity.activity.getApplicationContext(), message, Toast.LENGTH_LONG).show();
    		}
    	});
	}
}
