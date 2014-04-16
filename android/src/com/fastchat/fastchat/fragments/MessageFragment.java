package com.fastchat.fastchat.fragments;

import com.fastchat.fastchat.MainActivity;
import com.fastchat.fastchat.R;
import com.fastchat.fastchat.models.Message;
import com.fastchat.fastchat.models.User;
import com.fastchat.fastchat.networking.NetworkManager;
import com.fastchat.fastchat.networking.SocketIoController;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.os.Bundle;
import android.support.v4.app.Fragment;
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
    
    
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		if(NetworkManager.getCurrentGroup().getMessages().isEmpty()){
			NetworkManager.getCurrentGroupMessages();
		}
		MainActivity.activity.getActionBar().setTitle(NetworkManager.getCurrentGroup().getName());
		rootView = inflater.inflate(R.layout.message, container,
				false);
		Button button = (Button) rootView.findViewById(R.id.send_button);
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
		System.out.println("Updating message list");
		final ListView lv = (ListView) rootView.findViewById(R.id.messages_container);
		MainActivity.activity.runOnUiThread(new Runnable(){
			public void run(){
				adapter.notifyDataSetChanged();
				lv.setSelection(adapter.getCount() - 1);
			}
		});
	}
	
	public static void addMessage(final Message message){
		NetworkManager.getCurrentGroup().getMessages().add(message);
		updateUI();
	}
	
	public static void removeMessage(Message m){
		NetworkManager.getCurrentGroup().getMessages().remove(m);
		updateUI();
		
	}
	
	public static void showTyping(final User u){
		MainActivity.activity.runOnUiThread(new Runnable(){
			@Override
			public void run() {
				TextView tv = (TextView) rootView.findViewById(R.id.typing_box);
				tv.setVisibility(View.VISIBLE);
				tv.setText(u.getUsername()+" is typing...");
			}
			
		});
		
	}
	
	public static void hideTyping(final User u){
		MainActivity.activity.runOnUiThread(new Runnable(){
			@Override
			public void run() {
				TextView tv = (TextView) rootView.findViewById(R.id.typing_box);
				tv.setText("");
				tv.setVisibility(View.INVISIBLE);
			}
			
		});
		
	}

	@Override
	public void onClick(View arg0) {
		
		EditText messageBox = (EditText) rootView.findViewById(R.id.my_message);
		String message = messageBox.getText().toString();
		messageBox.setText("");
		messageBox.clearFocus();
		InputMethodManager in = (InputMethodManager) MainActivity.activity.getSystemService(MainActivity.INPUT_METHOD_SERVICE);
        in.hideSoftInputFromWindow(messageBox.getApplicationWindowToken(),InputMethodManager.HIDE_NOT_ALWAYS);
        if(message.isEmpty()){
        	return;
        }
        Message messageObject = new Message(message,NetworkManager.getCurrentUser());
		addMessage(messageObject);
		SocketIoController.sendMessage(messageObject);
	}
}
