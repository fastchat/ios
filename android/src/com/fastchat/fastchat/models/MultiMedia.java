package com.fastchat.fastchat.models;

import java.io.File;
import java.util.Arrays;
import java.util.List;

import com.fastchat.fastchat.MainActivity;
import com.fastchat.fastchat.Utils;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.util.Log;
import android.webkit.MimeTypeMap;

public class MultiMedia {
	
	private String fileName;
	
	private String mime_type;
	
	private File data;
	
	private Bitmap bitmap;
	
	private boolean isImage=false;
	
	private static final String TAG=MultiMedia.class.getSimpleName();
	
	private static final String IMAGE_TYPE="image";
	
	private boolean isResized = false;

	public MultiMedia(String fileName,String mime_type,File data){
		this.fileName=fileName;
		this.mime_type=mime_type;
		this.data = data;
		
		if(mime_type.isEmpty()){
			String extension = MimeTypeMap.getFileExtensionFromUrl(fileName);
			this.mime_type=MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
		}
		Log.d(TAG,"File Name: "+this.fileName+" MIME_TYPE: "+this.mime_type+" Data Length:"+this.data.length());
		if(getType(this.mime_type).equals("image")){
			BitmapFactory.Options opts = new BitmapFactory.Options();
			this.bitmap=BitmapFactory.decodeFile(this.data.getAbsolutePath(),opts);
			this.isImage=true;
		}
		
	}
	
	
	public String getFileName(){
		return this.fileName;
	}
	
	public String getMimeType(){
		return this.mime_type;
	}
	
	public File getData(){
		return this.data;
	}
	
	public Bitmap getBitmap(int width){
		if(this.bitmap==null){
			return this.bitmap;
		}
		if(isResized==false){
			isResized=true;
			Log.d(TAG,"Width: "+width+" B Width: "+this.bitmap.getWidth()+" B Height: "+this.bitmap.getHeight());
			double bitmapWidth = this.bitmap.getWidth()*1.0;
			double ratio = this.bitmap.getHeight()/bitmapWidth;
			int height = (int) Math.floor(ratio * width);
			Log.d(TAG,"Ratio: "+ratio+" New Width: "+width+" New Height: "+height);
			this.bitmap.recycle();
			this.bitmap=null;
			System.gc();
			this.bitmap=Bitmap.createScaledBitmap(this.bitmap, width, height, false);
		}
		
		return this.bitmap;
	}
	
	public Bitmap getBitmap(){
		return this.bitmap;
	}
	
	public boolean isImage(){
		return this.isImage;
	}
	
	public static String getType(String mime_type){
		String[] array = mime_type.split("/");
		String type = array[0];
		Log.d(TAG,"mime_type: "+mime_type+" Type: "+type);
		return type;
	}


	public boolean isResized() {
		return this.isResized;
	}
}
