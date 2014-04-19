package com.example.fastchat;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;

public class LoginFragment extends Fragment implements OnClickListener {

	private View rootView;
	public LoginFragment() {
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		rootView = inflater.inflate(R.layout.fragment_main, container,
				false);
		final Button button = (Button) rootView.findViewById(R.id.login_button);
	     button.setOnClickListener(this);

		return rootView;
	}

	@Override
	public void onClick(View arg0) {
		// TODO Auto-generated method stub
		EditText username = (EditText) rootView.findViewById(R.id.text_username);
		EditText password = (EditText) rootView.findViewById(R.id.text_password);
		String usernameText = username.getText().toString();
		String passwordText = password.getText().toString();
		NetworkManager.postLogin(usernameText, passwordText);
		System.out.println("Login Clicked!"+usernameText+":"+passwordText);
	}
}
