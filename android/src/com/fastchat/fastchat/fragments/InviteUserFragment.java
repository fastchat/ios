package com.fastchat.fastchat.fragments;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.support.v4.app.Fragment;

import com.fastchat.fastchat.MainActivity;
import com.fastchat.fastchat.R;
import com.fastchat.fastchat.networking.NetworkManager;

public class InviteUserFragment extends Fragment implements OnClickListener{

	private View rootView;
	
	private static final String TAG=InviteUserFragment.class.getName();
	
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		MainActivity.activity.getActionBar().setTitle("Invite User");
		rootView = inflater.inflate(R.layout.invite_user, container,
				false);
		Button button = (Button) rootView.findViewById(R.id.invite_button);
	     button.setOnClickListener(this);

		return rootView;
	}

	@Override
	public void onClick(View arg0) {
		EditText usernameTextBox = (EditText) rootView.findViewById(R.id.invite_username);
		String username = usernameTextBox.getText().toString();
		Log.d(TAG,"Invited: "+username);
		NetworkManager.putInviteUser(username, NetworkManager.getCurrentGroup());
		MainActivity.goBackToBeginning();
	}
	
}
