package com.fastchat.fastchat.fragments;

import com.fastchat.fastchat.MainActivity;
import com.fastchat.fastchat.R;
import com.fastchat.fastchat.Utils;
import com.fastchat.fastchat.networking.NetworkManager;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;

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

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		MainActivity.activity.getActionBar().setTitle("Login");
		rootView = inflater.inflate(R.layout.login, container,
				false);
		Button button = (Button) rootView.findViewById(R.id.login_button);
	     button.setOnClickListener(this);
	     button = (Button) rootView.findViewById(R.id.registration_button);
	     button.setOnClickListener(this);

		return rootView;
	}
	
	public void onStart(){
		Tracker t = MainActivity.tracker;
		t.setScreenName("Login View");

        // Send a screen view.
        t.send(new HitBuilders.AppViewBuilder().build());
        super.onStart();
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
			if(arg0.getId()==R.id.login_button){
				NetworkManager.postLogin(usernameText, passwordText);
			}
			else if(arg0.getId()==R.id.registration_button){
				NetworkManager.postRegisterUser(usernameText, passwordText);
			}
			else{
				Utils.makeToast("What button did you press?!");
			}
			username.setText("");
			password.setText("");
		}
	}
}
