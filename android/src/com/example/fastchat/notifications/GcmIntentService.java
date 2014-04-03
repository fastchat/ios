package com.example.fastchat.notifications;

import com.example.fastchat.MainActivity;
import com.example.fastchat.R;
import com.google.android.gms.gcm.GoogleCloudMessaging;

import android.app.IntentService;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

public class GcmIntentService extends IntentService {
    public static final int NOTIFICATION_ID = 1;
    NotificationCompat.Builder builder;
    private static final String TAG = "FastChat-GcmIntentService";
    private static final String NOTIFICATIONS = "notifications";
    private static final String NUM_NOTIFICATIONS = "num_notifications";
    private static GcmIntentService service;
    public GcmIntentService() {
        super("GcmIntentService");
        service=this;
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        Bundle extras = intent.getExtras();
        GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(this);
        // The getMessageType() intent parameter must be the intent you received
        // in your BroadcastReceiver.
        String messageType = gcm.getMessageType(intent);
        if (!extras.isEmpty()) {  // has effect of unparcelling Bundle
        	Log.i(TAG, "Received: " + extras.toString());
            /*
             * Filter messages based on message type. Since it is likely that GCM
             * will be extended in the future with new message types, just ignore
             * any message types you're not interested in, or that you don't
             * recognize.
             */
        	
            if (GoogleCloudMessaging.
                    MESSAGE_TYPE_SEND_ERROR.equals(messageType)) {
                sendNotification("Send error: " + extras.toString());
            } else if (GoogleCloudMessaging.
                    MESSAGE_TYPE_DELETED.equals(messageType)) {
                sendNotification("Deleted messages on server: " +
                        extras.toString());
            // If it's a regular GCM message, do some work.
            } else if (GoogleCloudMessaging.
                    MESSAGE_TYPE_MESSAGE.equals(messageType)) {
                // Post notification of received message.
                sendNotification(extras.getString("text"));
                
                Log.i(TAG, "Received: " + extras.getString("text"));
            }
        }
        // Release the wake lock provided by the WakefulBroadcastReceiver.
        GcmBroadcastReceiver.completeWakefulIntent(intent);
    }

    // Put the message into a notification and post it.
    // This is just one simple example of what you might choose to do with
    // a GCM message.
    private void sendNotification(String msg) {
    	SharedPreferences preferences = getSharedPreferences(GcmIntentService.class.getSimpleName(),
				Context.MODE_PRIVATE);
    	String notifications = preferences.getString(NOTIFICATIONS, "");
    	int num_notifications = preferences.getInt(NUM_NOTIFICATIONS, 0);
    	notifications+=msg+"\n";
    	num_notifications+=1;
    	
    	Editor editor = preferences.edit();
    	editor.putString(NOTIFICATIONS, notifications);
    	editor.putInt(NUM_NOTIFICATIONS, num_notifications);
    	editor.commit();
    	
    	NotificationCompat.Builder builder =  
                new NotificationCompat.Builder(this)  
                .setSmallIcon(R.drawable.ic_launcher)  
                .setContentTitle(num_notifications+" New Messages")  
                .setContentText(notifications)
                .setDefaults(Notification.DEFAULT_VIBRATE | Notification.DEFAULT_SOUND | Notification.FLAG_SHOW_LIGHTS)
                .setLights(Color.MAGENTA, 500, 500)
                .setStyle(new NotificationCompat.BigTextStyle()
                .bigText(notifications));

        Intent notificationIntent = new Intent(this, MainActivity.class);  
        PendingIntent contentIntent = PendingIntent.getActivity(this, 0, notificationIntent,   
                PendingIntent.FLAG_UPDATE_CURRENT);  
        builder.setContentIntent(contentIntent);  

        // Add as notification  
        NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);  
        manager.notify(NOTIFICATION_ID, builder.build());
    }
    
    public static void clearNotifications(){
    	if(service==null){
    		return;
    	}
    	SharedPreferences preferences = service.getSharedPreferences(GcmIntentService.class.getSimpleName(),
				Context.MODE_PRIVATE);
    	Editor editor = preferences.edit();
    	editor.remove(NOTIFICATIONS);
    	editor.remove(NUM_NOTIFICATIONS);
    	editor.commit();
    	NotificationManager manager = (NotificationManager) service.getSystemService(Context.NOTIFICATION_SERVICE);  
        manager.cancel(NOTIFICATION_ID);
    }
}