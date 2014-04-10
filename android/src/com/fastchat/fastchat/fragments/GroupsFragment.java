package com.fastchat.fastchat.fragments;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.fastchat.fastchat.MainActivity;
import com.fastchat.fastchat.R;
import com.fastchat.fastchat.models.Group;
import com.fastchat.fastchat.networking.NetworkManager;
import com.fastchat.fastchat.networking.SocketIoController;

import android.app.AlertDialog;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;

public class GroupsFragment extends Fragment {

	private static View rootView;

	//LIST OF ARRAY STRINGS WHICH WILL SERVE AS LIST ITEMS
	private static ArrayList<Group> groups=new ArrayList<Group>();

	private static List<String> menuItems=Arrays.asList("Invite User","Leave Group");

	//DEFINING A STRING ADAPTER WHICH WILL HANDLE THE DATA OF THE LISTVIEW
	private static GroupsAdapter adapter;

	@Override
	public void onCreateContextMenu(ContextMenu menu, View v,
			ContextMenuInfo menuInfo) {
		if(v.getId()==R.id.room_list){
			AdapterView.AdapterContextMenuInfo info = (AdapterView.AdapterContextMenuInfo)menuInfo;
			menu.setHeaderTitle(groups.get(info.position).getName());
			MainActivity.activity.runOnUiThread(new Runnable(){
				public void run(){
					MainActivity.activity.getActionBar().setDisplayHomeAsUpEnabled(false);
				}
			});
			for(String item : menuItems){
				menu.add(item);
			}
		}
	}

	@Override
	public boolean onContextItemSelected(MenuItem item) {
		AdapterView.AdapterContextMenuInfo info = (AdapterView.AdapterContextMenuInfo)item.getMenuInfo();
		//int menuItemIndex = item.getItemId();
		final Group selectedGroup = groups.get(info.position);
		//String menuClicked = menuItems.get(menuItemIndex);
		String menuClicked = item.getTitle().toString();
		System.out.println("Clicked: "+menuClicked+" on group: "+selectedGroup.getName());
		switch(menuClicked){
		case "Invite User":
			NetworkManager.setCurrentRoom(selectedGroup);
			MainActivity.switchView(new InviteUserFragment());
			break;
		case "Leave Group":
			NetworkManager.putLeaveGroup(selectedGroup);
			MainActivity.activity.runOnUiThread(new Runnable(){
				public void run(){
					groups.remove(selectedGroup);
					adapter.notifyDataSetChanged();
				}
			});
			
			break;
		default:
			break;
		}
		return true;
	}

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
				NetworkManager.setCurrentRoom((Group) adapter.getItem(position));
				MessageFragment mf = new MessageFragment();

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
		System.out.println("Getting here :"+SocketIoController.isConnected());
		if(!SocketIoController.isConnected()){
			SocketIoController.connect();
		}
		registerForContextMenu(lv);
		return rootView;
	}

	public static void addGroups(JSONArray array){
		MainActivity.activity.runOnUiThread(new Runnable(){
			public void run(){
				groups.clear();
				adapter.notifyDataSetChanged();
			}
		});
		HashMap<String,Group> groupsMap = new HashMap<String,Group>();
		for(int i=0;i<array.length();i++){
			try {
				JSONObject o = array.getJSONObject(i);
				final Group tempGroup = new Group(o);
				groupsMap.put(tempGroup.getId(),tempGroup);
				MainActivity.activity.runOnUiThread(new Runnable(){
					public void run(){
						groups.add(tempGroup);
						adapter.notifyDataSetChanged();
					}
				});

			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		NetworkManager.setGroups(groupsMap);

	}
}
