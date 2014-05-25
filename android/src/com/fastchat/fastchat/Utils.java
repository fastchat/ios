package com.fastchat.fastchat;

import java.io.File;
import java.io.FileOutputStream;

import android.content.Context;
import android.content.ContextWrapper;
import android.graphics.Bitmap;
import android.os.Environment;
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
	
	public static void makeToast(String text){
		final String message = text;
    	(MainActivity.activity).runOnUiThread(new Runnable(){
    		public void run(){
    			Toast.makeText(MainActivity.activity.getApplicationContext(), message, Toast.LENGTH_LONG).show();
    		}
    	});
	}
	
	public static File saveToInternalSorage(Bitmap bitmapImage){
		
		String appDirectoryName = "Fast_Chat";
		File directory = new File(Environment.getExternalStoragePublicDirectory(
		        Environment.DIRECTORY_PICTURES), appDirectoryName);
		if(!directory.exists())//check if file already exists
		{
		    directory.mkdirs();//if not, create it
		}
        File mypath=new File(directory,System.currentTimeMillis()+"fastChat.jpeg");

        FileOutputStream fos = null;
        try {
           // fos = openFileOutput(filename, Context.MODE_PRIVATE);

            fos = new FileOutputStream(mypath);

            // Use the compress method on the BitMap object to write image to the OutputStream
            bitmapImage.compress(Bitmap.CompressFormat.JPEG, 80, fos);
            fos.close();
        } catch (Exception e) {
            e.printStackTrace();
            Utils.makeToast(e);
        }
        return mypath;
	}
}
