package com.example.fastchat;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Color;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout.LayoutParams;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class MessageAdapter extends BaseAdapter {

	private Context mContext;
	private ArrayList<Message> mMessages;
	
	public MessageAdapter(Context context, ArrayList<Message> messages) {
		super();
		this.mContext = context;
		this.mMessages = messages;
	}
	
	@Override
	public int getCount() {
		return mMessages.size();
	}
	@Override
	public Object getItem(int position) {		
		return mMessages.get(position);
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		Message message = (Message) this.getItem(position);

		ViewHolder holder; 
		if(convertView == null)
		{
			holder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.sms_row, parent, false);
			holder.message = (TextView) convertView.findViewById(R.id.message_text);
			convertView.setTag(holder);
		}
		else
			holder = (ViewHolder) convertView.getTag();

		holder.message.setText(message.getText());

		LayoutParams lp = (LayoutParams) holder.message.getLayoutParams();	
		//Check whether message is mine to show green background and align to right
		if(message.isMine())
		{
			holder.message.setBackgroundResource(R.drawable.speech_bubble_green);
			lp.gravity = Gravity.RIGHT;
		}
		//If not mine then it is from sender to show orange background and align to left
		else
		{
			holder.message.setBackgroundResource(R.drawable.speech_bubble_orange);
			lp.gravity = Gravity.LEFT;
		}
		holder.message.setLayoutParams(lp);
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
