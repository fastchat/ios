package com.example.fastchat.fragments;


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
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;

public class LoginFragment extends Fragment implements OnClickListener {

	private View rootView;
	public LoginFragment() {
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		MainActivity.activity.getActionBar().setTitle("Login");
		rootView = inflater.inflate(R.layout.home_main, container,
				false);
		Button button = (Button) rootView.findViewById(R.id.login_button);
	     button.setOnClickListener(this);

		return rootView;
	}

	@Override
	public void onClick(View arg0) {
		final EditText username = (EditText) rootView.findViewById(R.id.text_username);
		final EditText password = (EditText) rootView.findViewById(R.id.text_password);
		InputMethodManager in = (InputMethodManager) MainActivity.activity.getSystemService(MainActivity.INPUT_METHOD_SERVICE);
        in.hideSoftInputFromWindow(username.getApplicationWindowToken(),InputMethodManager.HIDE_NOT_ALWAYS);
        in.hideSoftInputFromWindow(password.getApplicationWindowToken(),InputMethodManager.HIDE_NOT_ALWAYS);
		String usernameText = username.getText().toString();
		String passwordText = password.getText().toString();
		System.out.println("Login Clicked!"+usernameText+":"+passwordText);
		if(usernameText.length()<1){
			Utils.makeToast("Please Enter a username");
		}
		else if(passwordText.length()<1){
			Utils.makeToast("Please Enter a password");
		}else{
			NetworkManager.postLogin(usernameText, passwordText);
			username.setText("");
			password.setText("");
		}
	}
}
