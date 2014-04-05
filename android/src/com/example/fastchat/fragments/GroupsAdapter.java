package com.example.fastchat.fragments;

import java.util.ArrayList;

import com.example.fastchat.R;
import com.example.fastchat.models.Group;
import com.example.fastchat.models.Message;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.RelativeSizeSpan;
import android.text.style.StyleSpan;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout.LayoutParams;
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
		return mGroups.get(position);
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
        holder.message.setText(group.getName());

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
