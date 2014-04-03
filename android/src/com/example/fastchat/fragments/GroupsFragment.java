package com.example.fastchat.fragments;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.example.fastchat.MainActivity;
import com.example.fastchat.R;
import com.example.fastchat.networking.NetworkManager;
import com.example.fastchat.notifications.GcmIntentService;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;

public class GroupsFragment extends Fragment {

	private static View rootView;
	
	//LIST OF ARRAY STRINGS WHICH WILL SERVE AS LIST ITEMS
    private static ArrayList<String> groupNames=new ArrayList<String>();
    
    private static ArrayList<JSONObject> groups=new ArrayList<JSONObject>();

    //DEFINING A STRING ADAPTER WHICH WILL HANDLE THE DATA OF THE LISTVIEW
    private static ArrayAdapter<String> adapter;

	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		MainActivity.activity.getActionBar().setTitle("Groups");
		rootView = inflater.inflate(R.layout.groups_main, container,
				false);
		rootView.requestFocus();
		
		 adapter=new ArrayAdapter<String>(getActivity(),
		            android.R.layout.simple_list_item_1,
		            groupNames);
		 final ListView lv = (ListView) rootView.findViewById(R.id.room_list);
		 lv.setOnItemClickListener(new AdapterView.OnItemClickListener() {

			  @Override
			  public void onItemClick(AdapterView<?> arg0, View arg1, int position, long arg3) {
			    System.out.println("Selected Room #:"+position);
			    MessageFragment mf = new MessageFragment();
			    NetworkManager.setCurrentRoom(groups.get(position));
			    MainActivity.switchView(mf);
			    
			  }
			});
		 MainActivity.activity.runOnUiThread(new Runnable(){
			 public void run(){
				 
				 lv.setAdapter(adapter);
				 
			 }
		 });
		 NetworkManager.getGroups();
		 
		return rootView;
	}
	
	public static void addGroups(JSONArray array){
		groups.clear();
		groupNames.clear();
		for(int i=0;i<array.length();i++){
			try {
				JSONObject o = array.getJSONObject(i);
				groups.add(o);
				String groupName = o.getString("name");
				groupNames.add(groupName);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		MainActivity.activity.runOnUiThread(new Runnable(){
			 public void run(){
				 adapter.notifyDataSetChanged();
			 }
		 });
		
	}
}
