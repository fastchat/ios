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
	
	private static List<String> imageMime = Arrays.asList("image/jpeg","image/bmp","image/png", "image/jpg");
	
	private String fileName;
	
	private String mime_type;
	
	private byte[] data;
	
	private Bitmap bitmap;
	
	private boolean isImage=false;
	
	private static final String TAG=MultiMedia.class.getName();
	
	private boolean isResized = false;

	public MultiMedia(String fileName,String mime_type,byte[] data){
		this.fileName=fileName;
		this.mime_type=mime_type;
		this.data=data;
		
		if(mime_type.isEmpty()){
			String extension = MimeTypeMap.getFileExtensionFromUrl(fileName);
			this.mime_type=MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
		}
		Log.d(TAG,"File Name: "+this.fileName+" MIME_TYPE: "+this.mime_type+" Data Length:"+this.data.length);
		if(imageMime.contains(this.mime_type)){
			BitmapFactory.Options opts = new BitmapFactory.Options();
			this.bitmap=BitmapFactory.decodeByteArray(this.data, 0,this.data.length,opts);
			this.isImage=true;
		}
		
	}
	
	
	public String getFileName(){
		return this.fileName;
	}
	
	public String getMimeType(){
		return this.mime_type;
	}
	
	public byte[] getData(){
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
			this.bitmap=Bitmap.createScaledBitmap(this.bitmap, width, height, false);
		}
		
		return this.bitmap;
	}
	public boolean isImage(){
		return this.isImage;
	}
}
