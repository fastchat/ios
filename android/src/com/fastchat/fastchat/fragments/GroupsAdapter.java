package com.fastchat.fastchat.fragments;

import java.util.ArrayList;

import com.fastchat.fastchat.R;
import com.fastchat.fastchat.Utils;
import com.fastchat.fastchat.models.Group;
import com.fastchat.fastchat.models.User;
import com.fastchat.fastchat.networking.NetworkManager;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class GroupsAdapter extends BaseAdapter {

	private Context mContext;
	private ArrayList<Group> mGroups;
	
	public GroupsAdapter(Context context, ArrayList<Group> messages) {
		super();
		this.mContext = context;
		this.mGroups = messages;
	}
	
	@Override
	public int getCount() {
		return mGroups.size();
	}
	@Override
	public Object getItem(int position) {
		try{
		Object item = mGroups.get(position);
		return item;
		}catch(IndexOutOfBoundsException e){
			e.printStackTrace();
			Utils.makeToast(e);
			return null;
		}
		
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		Group group = (Group) this.getItem(position);

		ViewHolder holder; 
		if(convertView == null)
		{
			holder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.groups_row, parent, false);
			holder.message = (TextView) convertView.findViewById(R.id.message_text);
			convertView.setTag(holder);
		}else{
			holder = (ViewHolder) convertView.getTag();
		}
		if(group.getName()==null || group.getName().isEmpty()){
			String titleText="";
			for(User u : group.getUsers().values()){
				if(u.getUsername().equals(NetworkManager.getCurrentUser().getUsername())){
					continue;
				}
				if(titleText.equals("")){
					titleText+=u.getUsername();
				}else{
					titleText+=","+u.getUsername();
				}
			}
			holder.message.setText(titleText);
		}else{
			holder.message.setText(group.getName());
		}

		holder.message.setTextColor(Color.BLACK);	
		return convertView;
	}
	private static class ViewHolder
	{
		TextView message;
	}
	@Override
	public long getItemId(int position) {
		return position;
	}

}
