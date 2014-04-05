package com.example.fastchat.fragments;


import com.example.fastchat.MainActivity;
import com.example.fastchat.R;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;

public class NewGroupFragment extends Fragment implements OnClickListener {

	private View rootView;
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

		return rootView;
	}

	@Override
	public void onClick(View arg0) {
		EditText groupName = (EditText) rootView.findViewById(R.id.group_name);
		EditText usersBox = (EditText) rootView.findViewById(R.id.invite_users);
		EditText messageBox = (EditText) rootView.findViewById(R.id.invite_message);
		
	}
}
