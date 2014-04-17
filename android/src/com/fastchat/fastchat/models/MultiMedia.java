package com.fastchat.fastchat.models;

import java.util.Arrays;
import java.util.List;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;
import android.webkit.MimeTypeMap;

public class MultiMedia {
	
	private static List<String> imageMime = Arrays.asList("image/jpeg","image/bmp","image/png");
	
	private String fileName;
	
	private String mime_type;
	
	private byte[] data;
	
	private Bitmap bitmap;
	
	private boolean isImage=false;
	
	private static final String TAG=MultiMedia.class.getName();

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
			opts.inSampleSize = 4;
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
	
	public Bitmap getBitmap(){
		return this.bitmap;
	}
	public boolean isImage(){
		return this.isImage;
	}
}
