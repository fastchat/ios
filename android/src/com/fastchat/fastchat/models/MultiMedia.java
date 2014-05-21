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
	
	private int width = 0;
	private int height = 0;

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
			opts.inJustDecodeBounds=true;
			this.bitmap=BitmapFactory.decodeFile(this.data.getAbsolutePath(),opts);
			this.width = opts.outWidth;
			this.height= opts.outHeight;
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
	
	public Bitmap getBitmap(int widthParam){
		if(isResized==false){
			isResized=true;
			Log.d(TAG,"Width: "+widthParam+" B Width: "+this.width+" B Height: "+this.height);
			double bitmapWidth = this.width*1.0;
			double ratio = this.height/bitmapWidth;
			int height_new = (int) Math.floor(ratio * widthParam);
			
			if(this.bitmap!=null){
				this.bitmap.recycle();
				this.bitmap=null;
				System.gc();
			}
			BitmapFactory.Options opts= new BitmapFactory.Options();
			opts.outHeight=this.height;
			opts.outWidth=this.width;
			opts.inSampleSize=calculateInSampleSize(opts,widthParam,height_new);
			Log.d(TAG,"Sample Size:"+opts.inSampleSize);
			this.bitmap=BitmapFactory.decodeFile(this.data.getAbsolutePath(), opts);
			Log.d(TAG,"Ratio: "+ratio+" New Width: "+this.bitmap.getWidth()+" New Height: "+this.bitmap.getHeight());
			//this.bitmap=Bitmap.createScaledBitmap(this.bitmap, widthParam, height, false);
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
	
	
	public static int calculateInSampleSize(
            BitmapFactory.Options options, int reqWidth, int reqHeight) {
    // Raw height and width of image
    final int height = options.outHeight;
    final int width = options.outWidth;
    int inSampleSize = 1;

    if (height > reqHeight || width > reqWidth) {

        final int halfHeight = height / 2;
        final int halfWidth = width / 2;

        // Calculate the largest inSampleSize value that is a power of 2 and keeps both
        // height and width larger than the requested height and width.
        while ((halfHeight / inSampleSize) > reqHeight
                && (halfWidth / inSampleSize) > reqWidth) {
            inSampleSize *= 2;
        }
    }

    return inSampleSize;
}


	public boolean isResized() {
		return this.isResized;
	}
}
