package com.example.fastchat.fragments;

import java.util.ArrayList;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.example.fastchat.MainActivity;
import com.example.fastchat.R;
import com.example.fastchat.models.Group;
import com.example.fastchat.networking.NetworkManager;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;

public class GroupsFragment extends Fragment {

	private static View rootView;
	
	//LIST OF ARRAY STRINGS WHICH WILL SERVE AS LIST ITEMS
    private static ArrayList<Group> groups=new ArrayList<Group>();

    //DEFINING A STRING ADAPTER WHICH WILL HANDLE THE DATA OF THE LISTVIEW
    private static GroupsAdapter adapter;

	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		MainActivity.activity.getActionBar().setTitle("Groups");
		rootView = inflater.inflate(R.layout.groups_main, container,
				false);
		rootView.requestFocus();
		
		 adapter=new GroupsAdapter(getActivity(),groups);
		 final ListView lv = (ListView) rootView.findViewById(R.id.room_list);
		 lv.setOnItemClickListener(new AdapterView.OnItemClickListener() {

			  @Override
			  public void onItemClick(AdapterView<?> arg0, View arg1, int position, long arg3) {
			    System.out.println("Selected Room #:"+position);
			    MessageFragment mf = new MessageFragment();
			    NetworkManager.setCurrentRoom((Group) adapter.getItem(position));
			    MainActivity.switchView(mf);
			    
			  }
			});
		 MainActivity.activity.runOnUiThread(new Runnable(){
			 public void run(){
				 
				 lv.setAdapter(adapter);
				 
			 }
		 });
		 if(NetworkManager.getAllGroups()==null || NetworkManager.getAllGroups().isEmpty()){
			 NetworkManager.getGroups();
		 }
		 
		return rootView;
	}
	
	public static void addGroups(JSONArray array){
		groups.clear();
		HashMap<String,Group> groupsMap = new HashMap<String,Group>();
		for(int i=0;i<array.length();i++){
			try {
				JSONObject o = array.getJSONObject(i);
				Group tempGroup = new Group(o);
				groupsMap.put(tempGroup.getId(),tempGroup);
				groups.add(tempGroup);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		NetworkManager.setGroups(groupsMap);
		MainActivity.activity.runOnUiThread(new Runnable(){
			 public void run(){
				 adapter.notifyDataSetChanged();
			 }
		 });
		
	}
}
