package com.example.fastchat;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

public class MessageFragment extends Fragment implements OnClickListener {

	private static View rootView;
	
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		rootView = inflater.inflate(R.layout.message_main, container,
				false);
		Button button = (Button) rootView.findViewById(R.id.send_button);
	     button.setOnClickListener(this);
	     MessageViewController.connect();
		return rootView;
	}
	
	public static void addMessage(String message, boolean is_own_message){
		final TextView tv = new TextView(MainActivity.activity);
		tv.setText(message);
		if(is_own_message){
			tv.setGravity(Gravity.RIGHT);
			MessageViewController.sendMessage(message);
		}else{
			tv.setGravity(Gravity.LEFT);
		}
		tv.setVisibility(View.VISIBLE);
		final LinearLayout container = (LinearLayout) rootView.findViewById(R.id.messages_container);
		MainActivity.activity.runOnUiThread(new Runnable(){
			public void run(){
				container.addView(tv);
			}
		});
		
	}

	@Override
	public void onClick(View arg0) {
		
		EditText messageBox = (EditText) rootView.findViewById(R.id.my_message);
		String messsage = messageBox.getText().toString();
		addMessage(messsage,true);
	}
}
