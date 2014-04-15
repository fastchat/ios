package com.fastchat.fastchat.fragments;

import com.fastchat.fastchat.MainActivity;
import com.fastchat.fastchat.R;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

public class ProfileFragment extends Fragment {
	
	private static View rootView;
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		MainActivity.activity.getActionBar().setTitle("Profile");
		rootView = inflater.inflate(R.layout.profile, container,
				false);
		
		return rootView;
	}
}
