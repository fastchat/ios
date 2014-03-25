package com.example.fastchat;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;

public class RoomsFragment extends Fragment {

	private static View rootView;
	
	//LIST OF ARRAY STRINGS WHICH WILL SERVE AS LIST ITEMS
    private static ArrayList<String> roomNames=new ArrayList<String>();
    
    private static ArrayList<JSONObject> rooms=new ArrayList<JSONObject>();

    //DEFINING A STRING ADAPTER WHICH WILL HANDLE THE DATA OF THE LISTVIEW
    private static ArrayAdapter<String> adapter;

	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		rootView = inflater.inflate(R.layout.rooms_main, container,
				false);
		rootView.requestFocus();
		
		 adapter=new ArrayAdapter<String>(getActivity(),
		            android.R.layout.simple_list_item_1,
		            roomNames);
		 final ListView lv = (ListView) rootView.findViewById(R.id.room_list);
		 lv.setOnItemClickListener(new AdapterView.OnItemClickListener() {

			  @Override
			  public void onItemClick(AdapterView<?> arg0, View arg1, int position, long arg3) {
			    System.out.println("Selected Room #:"+position);
			    MessageFragment mf = new MessageFragment();
			    NetworkManager.setCurrentRoom(rooms.get(position));
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
	
	public static void addRoom(JSONArray array){
		rooms.clear();
		roomNames.clear();
		for(int i=0;i<array.length();i++){
			try {
				JSONObject o = array.getJSONObject(i);
				rooms.add(o);
				String groupName = o.getString("name");
				roomNames.add(groupName);
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
