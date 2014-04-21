package com.fastchat.fastchat.fragments;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

import com.fastchat.fastchat.MainActivity;
import com.fastchat.fastchat.R;
import com.fastchat.fastchat.models.Group;
import com.fastchat.fastchat.models.Message;
import com.fastchat.fastchat.models.MultiMedia;
import com.fastchat.fastchat.models.User;
import com.fastchat.fastchat.networking.NetworkManager;
import com.fastchat.fastchat.networking.SocketIoController;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.ContextMenu;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

public class MessageFragment extends Fragment implements OnClickListener {

	private static View rootView;
    
    private static MessageAdapter adapter;
    
    private static final int SELECT_FILE=1;
    
    
    private static MultiMedia multiMedia;
    
    private static final String TAG=MessageFragment.class.getName();
    
    
    @Override
	public void onCreateContextMenu(ContextMenu menu, View v,
			ContextMenuInfo menuInfo) {
		if(v.getId()==R.id.messages_container){
			//AdapterView.AdapterContextMenuInfo info = (AdapterView.AdapterContextMenuInfo)menuInfo;
			menu.setHeaderTitle("Message");
			MainActivity.activity.runOnUiThread(new Runnable(){
				public void run(){
					MainActivity.activity.getActionBar().setDisplayHomeAsUpEnabled(false);
				}
			});
			menu.add("Copy Text");
		}
    }
	
    @Override
	public boolean onContextItemSelected(MenuItem item) {
    	AdapterView.AdapterContextMenuInfo info = (AdapterView.AdapterContextMenuInfo)item.getMenuInfo();
		//int menuItemIndex = item.getItemId();
		final Message selectedMessage = NetworkManager.getCurrentGroup().getMessages().get(info.position);
		ClipboardManager clipboard = (ClipboardManager) MainActivity.activity.getSystemService(MainActivity.CLIPBOARD_SERVICE); 
		 ClipData clip = ClipData.newPlainText("FastChat copied message", selectedMessage.getText());
		 clipboard.setPrimaryClip(clip);
    	return true;
    }
    
    private boolean isMessagesUpToDate(){
    	Group currGroup = NetworkManager.getCurrentGroup();
    	if(currGroup == null){
    		return false;
    	}
    	ArrayList<Message> mess = currGroup.getMessages();
    	if(mess==null || mess.isEmpty()){
    		return false;
    	}
    	Message latestWeHave = mess.get(mess.size()-1);
    	
    	Message latestFromGroup = currGroup.getLastMessage();
    	User currUser = NetworkManager.getCurrentUser();
    	if((latestWeHave.getId()==null || latestWeHave.getId().isEmpty()) && latestFromGroup.getFrom()==currUser){
    		return true;
    	}
    	else if(latestWeHave.getId().equals(latestFromGroup.getId())){
    		return true;
    	}
    	return false;
    }
    
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		
		
		if(!isMessagesUpToDate()){
			NetworkManager.getCurrentGroupMessages();
		}
		MainActivity.activity.getActionBar().setTitle(NetworkManager.getCurrentGroup().getName());
		rootView = inflater.inflate(R.layout.message, container,
				false);
		Button button = (Button) rootView.findViewById(R.id.send_button);
	     button.setOnClickListener(this);
	     button = (Button) rootView.findViewById(R.id.attach_button);
	     button.setOnClickListener(this);
	     adapter=new MessageAdapter(getActivity(), NetworkManager.getCurrentGroup().getMessages());
	     final ListView lv = (ListView) rootView.findViewById(R.id.messages_container);
	     MainActivity.activity.runOnUiThread(new Runnable(){
			 public void run(){
				 
				 lv.setAdapter(adapter);
				 
			 }
		 });
	     EditText messageBox = (EditText) rootView.findViewById(R.id.my_message);
	     messageBox.addTextChangedListener(new FastChatTextWatcher());
	     registerForContextMenu(lv);
		return rootView;
	}
	
	public void onStart(){
		updateUI();
		Tracker t = MainActivity.tracker;
		t.setScreenName("Message View");

        // Send a screen view.
        t.send(new HitBuilders.AppViewBuilder().build());
        super.onStart();
	}
	
	public static void updateUI(){
		if(rootView==null){
			return;
		}
		final ListView lv = (ListView) rootView.findViewById(R.id.messages_container);
		MainActivity.activity.runOnUiThread(new Runnable(){
			public void run(){
				adapter.notifyDataSetChanged();
				lv.setSelection(adapter.getCount() - 1);
			}
		});
	}
	
	public static void addMessage(final Message message){
		MainActivity.activity.runOnUiThread(new Runnable(){
			public void run(){
				NetworkManager.getCurrentGroup().getMessages().add(message);
				updateUI();
			}
		});
		
	}
	
	public static void removeMessage(final Message m){
		MainActivity.activity.runOnUiThread(new Runnable(){
			public void run(){
				NetworkManager.getCurrentGroup().getMessages().remove(m);
				updateUI();
			}
		});
	}
	
	public static void showTyping(final User u){
		MainActivity.activity.runOnUiThread(new Runnable(){
			@Override
			public void run() {
				TextView tv = (TextView) rootView.findViewById(R.id.typing_box);
				tv.setVisibility(View.VISIBLE);
				try{
					tv.setText(u.getUsername()+" is typing...");
				}catch(NullPointerException e){
					e.printStackTrace();
				}
			}
			
		});
		
	}
	
	public static void hideTyping(final User u){
		MainActivity.activity.runOnUiThread(new Runnable(){
			@Override
			public void run() {
				TextView tv = (TextView) rootView.findViewById(R.id.typing_box);
				tv.setText("");
				tv.setVisibility(View.GONE);
			}
			
		});
		
	}

	@Override
	public void onClick(View arg0) {
		if(arg0.getId()==R.id.send_button){
			EditText messageBox = (EditText) rootView.findViewById(R.id.my_message);
			String message = messageBox.getText().toString();
			messageBox.setText("");
			messageBox.clearFocus();
			InputMethodManager in = (InputMethodManager) MainActivity.activity.getSystemService(MainActivity.INPUT_METHOD_SERVICE);
	        in.hideSoftInputFromWindow(messageBox.getApplicationWindowToken(),InputMethodManager.HIDE_NOT_ALWAYS);
	        if(message.isEmpty()){
	        	return;
	        }
	        Message messageObject = new Message(message,NetworkManager.getCurrentUser(),NetworkManager.getCurrentGroup().getId(),multiMedia);
	        multiMedia=null;
			addMessage(messageObject);
			SocketIoController.sendMessage(messageObject);
		}else if(arg0.getId()==R.id.attach_button){
			Intent intent = new Intent();
	        intent.setType("*/*");
	        intent.setAction(Intent.ACTION_GET_CONTENT);
	        startActivityForResult(Intent.createChooser(intent,
	                "Select File"), SELECT_FILE);
		}
	}
	
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode == MainActivity.RESULT_OK) {
			if (requestCode == SELECT_FILE) {
				try {
					Uri fileUri = data.getData();
					Log.d(TAG,"File Path: "+fileUri.getPath());
					InputStream input = MainActivity.activity.getContentResolver().openInputStream(data.getData());
					String[] proj = {MediaStore.Files.FileColumns.DISPLAY_NAME,MediaStore.Files.FileColumns.MIME_TYPE};
					Cursor cursor = MainActivity.activity.getContentResolver().query(fileUri, proj, null, null, null);
					 String mime_type="";
					 String fileName = "";
					 if (cursor != null && cursor.getCount() != 0) {
				            int columnIndex = cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.DISPLAY_NAME);
				            cursor.moveToFirst();
				            fileName = cursor.getString(columnIndex);
				            columnIndex = cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.MIME_TYPE);
				            cursor.moveToFirst();
				            mime_type = cursor.getString(columnIndex);
				            Log.d(TAG,"File Name:"+fileName+" MIME Type:"+mime_type);
				        }
					byte[] buf = new byte[input.available()];
				    while (input.read(buf) != -1) {
				    }
				    Log.d(TAG,"File Size: "+buf.length);
				    if(fileName==""){
				    	fileName = fileUri.getLastPathSegment();
				    }
				    multiMedia = new MultiMedia(fileName,mime_type,buf);
				} catch (FileNotFoundException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
	}
}
