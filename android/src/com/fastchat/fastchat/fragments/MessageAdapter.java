package com.fastchat.fastchat.fragments;

import java.io.File;
import java.util.ArrayList;

import com.fastchat.fastchat.MainActivity;
import com.fastchat.fastchat.R;
import com.fastchat.fastchat.Utils;
import com.fastchat.fastchat.models.Message;
import com.fastchat.fastchat.models.MultiMedia;
import com.fastchat.fastchat.models.User;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.RelativeSizeSpan;
import android.text.style.StyleSpan;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.webkit.MimeTypeMap;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout.LayoutParams;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class MessageAdapter extends BaseAdapter {

	private Context mContext;
	private ArrayList<Message> mMessages;
	private static final int MARGINS = 30;
	
	private static final String TAG=MessageAdapter.class.getName();
	
	
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
			convertView = LayoutInflater.from(mContext).inflate(R.layout.message_row, parent, false);
			holder.message = (TextView) convertView.findViewById(R.id.message_text);
			holder.image = (ImageView) convertView.findViewById(R.id.imageView1);
			holder.layout = (LinearLayout) convertView.findViewById(R.id.sms_layout);
			holder.description = (TextView) convertView.findViewById(R.id.multi_media_description);
			convertView.setTag(holder);
		}
		else{
			holder = (ViewHolder) convertView.getTag();
		}
		holder.multiMedia = (ImageView) convertView.findViewById(R.id.multi_media);
		holder.multiMedia.setImageDrawable(null);
		holder.multiMedia.setVisibility(View.GONE);
		if(message.hasMedia()){
			holder.multiMedia.setTag(message);
			holder.multiMedia.setOnClickListener(new OnClickListener(){

				@Override
				public void onClick(View arg0) {
					Message message = (Message) arg0.getTag();
					MultiMedia mms = message.getMedia();
					byte[] data = mms.getData();
					String extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(mms.getMimeType());
					if(extension==null){
						extension="tmp";
					}
				    File f = Utils.saveImageToInternalSorage(data,message.getId()+"."+extension);
				    
				    Intent intent = new Intent();
				    intent.setAction(android.content.Intent.ACTION_VIEW);
				    intent.setDataAndType(Uri.fromFile(f),mms.getMimeType());
				    try{
				    	MainActivity.activity.startActivityForResult(intent, 10);
				    }catch(ActivityNotFoundException e){
				    	Log.d(TAG,"No Activity found to handle intent");
				    }
				}
				
			});
			MultiMedia mms = message.getMedia();
			if(mms!=null && mms.isImage()){
				holder.multiMedia.setVisibility(View.VISIBLE);
				holder.message.setText("TEXT TO MAKE VIEW MAXIMUM LENGTH");
				convertView.measure(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
				int width = convertView.getMeasuredWidth();
				holder.message.setText("");
				//android.view.ViewGroup.LayoutParams imageParams = holder.multiMedia.getLayoutParams();
				holder.multiMedia.setImageBitmap(mms.getBitmap(width));
				holder.description.setVisibility(View.GONE);
			}
			else if(mms!=null && !mms.isImage()){
				holder.description.setVisibility(View.VISIBLE);
				holder.multiMedia.setVisibility(View.VISIBLE);
				holder.multiMedia.setImageResource(R.drawable.paperclip2_black);
				String extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(mms.getMimeType());
				if(extension==null){
					extension=mms.getMimeType();
				}
				holder.description.setText(extension + " File");
			}
			else{
				holder.description.setVisibility(View.GONE);
				holder.multiMedia.setVisibility(View.GONE);
			}
		}
		SpannableString out0 = new SpannableString(message.getText()+"\n"+message.getFrom().getUsername()+" "+message.getDateString());
        StyleSpan boldSpan = new StyleSpan(Typeface.BOLD);
        RelativeSizeSpan smallSpan = new RelativeSizeSpan(0.5f);
        out0.setSpan(boldSpan, 0, message.getText().length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        out0.setSpan(smallSpan, message.getText().length(), out0.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        holder.message.setText(out0);
        Bitmap avatar = message.getFrom().getBitmap();
        if(avatar!=null){
        	holder.image.setImageBitmap(avatar);
        	
        }else{
        	holder.image.setImageBitmap(ProfileFragment.getDefaultBitmap());
        	//holder.image.setBackgroundColor(Color.GRAY);
        }

		LayoutParams lp = (LayoutParams) holder.layout.getLayoutParams();	
		//Check whether message is mine to show green background and align to right
		if(message.isMine())
		{
			LinearLayout ll = (LinearLayout) convertView.findViewById(R.id.innerLayout);
			ll.removeView(holder.image);
			ll.addView(holder.image);
			//holder.layout.setBackgroundResource(R.drawable.speech_bubble_green);
			lp.gravity = Gravity.RIGHT;
			lp.setMargins(MARGINS, 0, 0, 0);
		}
		//If not mine then it is from sender to show orange background and align to left
		else
		{
			LinearLayout ll = (LinearLayout) convertView.findViewById(R.id.innerLayout);
			ll.removeView(holder.image);
			ll.addView(holder.image,0);
			//holder.layout.setBackgroundResource(R.drawable.speech_bubble_orange);
			lp.gravity = Gravity.LEFT;
			lp.setMargins(0, 0, MARGINS, 0);
		}
		holder.layout.setLayoutParams(lp);
		holder.message.setTextColor(Color.BLACK);	
		return convertView;
	}
	private static class ViewHolder
	{
		public TextView description;
		public ImageView multiMedia;
		public LinearLayout layout;
		public ImageView image;
		TextView message;
	}
	@Override
	public long getItemId(int position) {
		return position;
	}
	
	
}
