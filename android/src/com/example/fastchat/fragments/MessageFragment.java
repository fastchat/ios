package com.example.fastchat.fragments;

import com.example.fastchat.MainActivity;
import com.example.fastchat.R;
import com.example.fastchat.models.Message;
import com.example.fastchat.networking.SocketIoController;
import com.example.fastchat.networking.NetworkManager;
import com.example.fastchat.notifications.GcmIntentService;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

public class MessageFragment extends Fragment implements OnClickListener {

	private static View rootView;
	

    //DEFINING A STRING ADAPTER WHICH WILL HANDLE THE DATA OF THE LISTVIEW
    private static MessageAdapter adapter;
	
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		if(NetworkManager.getCurrentGroup().getMessages().isEmpty()){
			NetworkManager.getCurrentGroupMessages();
		}
		MainActivity.activity.getActionBar().setTitle(NetworkManager.getCurrentGroup().getName());
		rootView = inflater.inflate(R.layout.message_main, container,
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
	     updateUI();
		return rootView;
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
	
	public static void addMessage(Message message){
		
		NetworkManager.getCurrentGroup().getMessages().add(message);
		updateUI();
		
	}

	@Override
	public void onClick(View arg0) {
		
		EditText messageBox = (EditText) rootView.findViewById(R.id.my_message);
		String message = messageBox.getText().toString();
		messageBox.setText("");
		messageBox.clearFocus();
		InputMethodManager in = (InputMethodManager) MainActivity.activity.getSystemService(MainActivity.INPUT_METHOD_SERVICE);
        in.hideSoftInputFromWindow(messageBox.getApplicationWindowToken(),InputMethodManager.HIDE_NOT_ALWAYS);
        Message messageObject = new Message(message,NetworkManager.getCurrentUser());
		addMessage(messageObject);
		SocketIoController.sendMessage(messageObject);
	}
}
