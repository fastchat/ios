package com.example.fastchat.fragments;


import java.util.ArrayList;

import com.example.fastchat.MainActivity;
import com.example.fastchat.R;
import com.example.fastchat.Utils;
import com.example.fastchat.networking.NetworkManager;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Adapter;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

public class NewGroupFragment extends Fragment implements OnClickListener {

	private View rootView;
	
	ArrayList<String> usersToInvite = new ArrayList<String>();
	
	//DEFINING A STRING ADAPTER WHICH WILL HANDLE THE DATA OF THE LISTVIEW
	private static ArrayAdapter<String> adapter;
	
	public NewGroupFragment() {
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		MainActivity.activity.getActionBar().setTitle("New Group");
		rootView = inflater.inflate(R.layout.new_group_main, container,
				false);
		Button button = (Button) rootView.findViewById(R.id.button_send_invite);
	     button.setOnClickListener(this);
	     button = (Button) rootView.findViewById(R.id.button_add_user);
	     button.setOnClickListener(this);
	    adapter=new ArrayAdapter<String>(getActivity(),android.R.layout.simple_list_item_1,usersToInvite);
		final ListView lv = (ListView) rootView.findViewById(R.id.users_to_invite);
		MainActivity.activity.runOnUiThread(new Runnable(){
			public void run(){

				lv.setAdapter(adapter);

			}
		});
		return rootView;
	}

	@Override
	public void onClick(View arg0) {
		if(arg0.getId()==R.id.button_add_user){
			EditText et = (EditText) rootView.findViewById(R.id.invite_users);
			final String userName = et.getText().toString();
			MainActivity.activity.runOnUiThread(new Runnable(){
				public void run(){
					usersToInvite.add(userName);
					adapter.notifyDataSetChanged();
				}
			});
		}else{
			EditText groupName = (EditText) rootView.findViewById(R.id.group_name);
			EditText messageBox = (EditText) rootView.findViewById(R.id.invite_message);
			if(groupName.length()==0 || messageBox.length()==0 || usersToInvite.size()==0){
				Utils.makeToast("Please fill out all of the information");
				return;
			}
			
			NetworkManager.postCreateGroup(usersToInvite, groupName.getText().toString(), messageBox.getText().toString());
		}
		
	}
	
	public void addUserToList(final String user){
		MainActivity.activity.runOnUiThread(new Runnable(){
			public void run(){
				usersToInvite.add(user);
				adapter.notifyDataSetChanged();
			}
		});
	}
}
