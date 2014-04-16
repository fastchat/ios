package com.fastchat.fastchat.fragments;

import java.io.IOException;
import java.util.HashMap;

import com.fastchat.fastchat.MainActivity;
import com.fastchat.fastchat.R;
import com.fastchat.fastchat.Utils;
import com.fastchat.fastchat.networking.NetworkManager;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;

import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Bitmap.Config;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.provider.MediaStore.MediaColumns;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

public class ProfileFragment extends Fragment implements OnClickListener {

	private static View rootView;
	//YOU CAN EDIT THIS TO WHATEVER YOU WANT
	private static final int SELECT_PICTURE = 1;

	private String selectedImagePath;

	private ImageView avatarView;
	private Bitmap currentBitmap;
	private static final int BITMAP_SIZE = 300; // 300px X 300px
	private static Bitmap defaultBitmap=null;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		MainActivity.activity.getActionBar().setTitle("Profile");
		rootView = inflater.inflate(R.layout.profile, container,
				false);
		avatarView = (ImageView) rootView.findViewById(R.id.avatar);
		currentBitmap = NetworkManager.getCurrentUser().getBitmap();
		avatarView.setImageBitmap(currentBitmap);
		TextView tv = (TextView) rootView.findViewById(R.id.profile_username);
		tv.setText(NetworkManager.getCurrentUser().getUsername());
		Button selectAvatar = (Button) rootView.findViewById(R.id.new_avatar);
		selectAvatar.setOnClickListener(this);
		Button saveAvatar = (Button) rootView.findViewById(R.id.save_avatar);
		saveAvatar.setOnClickListener(this);
		return rootView;
	}
	
	public void onStart(){
		Tracker t = MainActivity.tracker;
		t.setScreenName("Profile View");

        // Send a screen view.
        t.send(new HitBuilders.AppViewBuilder().build());
        super.onStart();
	}

	public void onClick(View arg0) {

		// in onCreate or any event where your want the user to
		// select a file
		if(arg0.getId()==R.id.new_avatar){
			/*Intent intent = new Intent();
	        intent.setType("image/*");
	        intent.setAction(Intent.ACTION_GET_CONTENT);
	        startActivityForResult(Intent.createChooser(intent,
	                "Select Picture"), SELECT_PICTURE);*/
			Intent intent = new Intent(Intent.ACTION_PICK, 
					android.provider.MediaStore.Images.Media.INTERNAL_CONTENT_URI);

			intent.setType("image/*");
			intent.putExtra("crop", "true");
			intent.putExtra("scale", true);
			intent.putExtra("outputX", BITMAP_SIZE);
			intent.putExtra("outputY", BITMAP_SIZE);
			intent.putExtra("aspectX", 1);
			intent.putExtra("aspectY", 1);
			intent.putExtra("return-data", true);
			startActivityForResult(intent, 1);
		}else if(arg0.getId()==R.id.save_avatar){
			NetworkManager.getCurrentUser().setBitmap(currentBitmap);
			NetworkManager.postAvatar(currentBitmap);
		}
	}




	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode == MainActivity.RESULT_OK) {
			Uri selectedImageUri = data.getData();
			if (requestCode == SELECT_PICTURE) {
				
				final Bundle extras = data.getExtras();
				if(selectedImageUri==null){
					selectedImagePath = null;
				}else{
					selectedImagePath = getPath(selectedImageUri);
				}
				
				
				if (extras != null) {
					System.out.println("Cropped image");
					Bitmap photo = extras.getParcelable("data");
					currentBitmap = Bitmap.createScaledBitmap(photo,BITMAP_SIZE, BITMAP_SIZE, false);
					currentBitmap = getRoundedCornerBitmap(currentBitmap);
					avatarView.setImageBitmap(currentBitmap);
				}

				else if(selectedImagePath!=null){
					Log.d("URI VAL", "selectedImageUri = " + selectedImageUri.toString());
					// IF LOCAL IMAGE, NO MATTER IF ITS DIRECTLY FROM GALLERY (EXCEPT PICASSA ALBUM),
					// OR OI/ASTRO FILE MANAGER. EVEN DROPBOX IS SUPPORTED BY THIS BECAUSE DROPBOX DOWNLOAD THE IMAGE 
					// IN THIS FORM - file:///storage/emulated/0/Android/data/com.dropbox.android/...
					System.out.println("local image"); 
					try {
						currentBitmap = MediaStore.Images.Media.getBitmap(MainActivity.activity.getContentResolver(), selectedImageUri);
						currentBitmap = Bitmap.createScaledBitmap(currentBitmap,BITMAP_SIZE, BITMAP_SIZE, false);
						currentBitmap = getRoundedCornerBitmap(currentBitmap);
						avatarView.setImageBitmap(currentBitmap);
					} catch (IOException e) {
						e.printStackTrace();
						Utils.makeToast(e);
					}
				}
			}
			else{
				System.out.println("picasa image!");
				loadPicasaImageFromGallery(selectedImageUri);
			}
		}
	}


	// NEW METHOD FOR PICASA IMAGE LOAD
	private void loadPicasaImageFromGallery(final Uri uri) {
		String[] projection = {  MediaColumns.DATA, MediaColumns.DISPLAY_NAME };
		Cursor cursor = MainActivity.activity.getContentResolver().query(uri, projection, null, null, null);
		if(cursor != null) {
			cursor.moveToFirst();

			int columnIndex = cursor.getColumnIndex(MediaColumns.DISPLAY_NAME);
			if (columnIndex != -1) {
				new Thread(new Runnable() {
					// NEW THREAD BECAUSE NETWORK REQUEST WILL BE MADE THAT WILL BE A LONG PROCESS & BLOCK UI
					// IF CALLED IN UI THREAD 
					public void run() {
						try {
							currentBitmap = android.provider.MediaStore.Images.Media.getBitmap(MainActivity.activity.getContentResolver(), uri);
							currentBitmap = Bitmap.createScaledBitmap(currentBitmap,BITMAP_SIZE, BITMAP_SIZE, false);
							currentBitmap = getRoundedCornerBitmap(currentBitmap);
							avatarView.setImageBitmap(currentBitmap);
							// THIS IS THE BITMAP IMAGE WE ARE LOOKING FOR.
						} catch (Exception ex) {
							ex.printStackTrace();
							Utils.makeToast(ex);
						}
					}
				}).start();
			}
		}
		cursor.close();
	}


	public String getPath(Uri uri) {
		String[] projection = {  MediaColumns.DATA};
		Cursor cursor = MainActivity.activity.getContentResolver().query(uri, projection, null, null, null);
		if(cursor != null) {
			//HERE YOU WILL GET A NULLPOINTER IF CURSOR IS NULL
			//THIS CAN BE, IF YOU USED OI FILE MANAGER FOR PICKING THE MEDIA
			cursor.moveToFirst();
			int columnIndex = cursor.getColumnIndexOrThrow(MediaColumns.DATA);
			String filePath = cursor.getString(columnIndex);
			cursor.close();
			return filePath;
		}
		else 
			return uri.getPath();               // FOR OI/ASTRO/Dropbox etc
	}

	public static Bitmap getRoundedCornerBitmap(Bitmap bitmap) {
		Bitmap output = Bitmap.createBitmap(bitmap.getWidth(),
				bitmap.getHeight(), Config.ARGB_8888);
		Canvas canvas = new Canvas(output);

		final int color = 0xff424242;
		final Paint paint = new Paint();
		final Rect rect = new Rect(0, 0, bitmap.getWidth(), bitmap.getHeight());
		final RectF rectF = new RectF(rect);
		final float roundPx = bitmap.getWidth();

		paint.setAntiAlias(true);
		canvas.drawARGB(0, 0, 0, 0);
		paint.setColor(color);
		canvas.drawRoundRect(rectF, roundPx, roundPx, paint);

		paint.setXfermode(new PorterDuffXfermode(android.graphics.PorterDuff.Mode.SRC_IN));
		canvas.drawBitmap(bitmap, rect, rect, paint);

		return output;
	}

	public static Bitmap getDefaultBitmap(){
		if(defaultBitmap==null){
			defaultBitmap = BitmapFactory.decodeResource(MainActivity.activity.getResources(), R.drawable.profile_dark);
			defaultBitmap = getRoundedCornerBitmap(defaultBitmap);
		}
		return defaultBitmap;
	}
}
