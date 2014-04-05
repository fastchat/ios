package com.example.fastchat;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.concurrent.atomic.AtomicInteger;

import com.example.fastchat.fragments.LoginFragment;
import com.example.fastchat.fragments.GroupsFragment;
import com.example.fastchat.fragments.MessageFragment;
import com.example.fastchat.fragments.NewGroupFragment;
import com.example.fastchat.models.Group;
import com.example.fastchat.models.User;
import com.example.fastchat.networking.SocketIoController;
import com.example.fastchat.networking.NetworkManager;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.gcm.GoogleCloudMessaging;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v7.app.ActionBarActivity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.WindowManager;


public class MainActivity extends ActionBarActivity {

	public static MainActivity activity;
	public static FragmentManager manager;
	public static final String EXTRA_MESSAGE = "message";
	public static final String PROPERTY_REG_ID = "registration_id";
	private static final String PROPERTY_APP_VERSION = "appVersion";
	private static final String USERNAME = "username";
	private static final String SESSION_TOKEN="session_token";
	private static final String USER_ID="user_id";
	private final static int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;

	/**
	 * Substitute you own sender ID here. This is the project number you got
	 * from the API Console, as described in "Getting Started."
	 */
	String SENDER_ID = "466998629506";

	GoogleCloudMessaging gcm;
	AtomicInteger msgId = new AtomicInteger();
	SharedPreferences prefs;

	public static String regid;


	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		activity = this;
		setContentView(R.layout.activity_main);
		manager = getSupportFragmentManager();
		if (savedInstanceState == null) {
			ArrayList<String> credentials = getLoginCredentials();
			if(credentials.size()<3){
				getSupportFragmentManager().beginTransaction()
				.add(R.id.container, new LoginFragment()).commit();
			}
			else{
				User currentUser = new User(credentials.get(0),credentials.get(1),credentials.get(2));
				NetworkManager.setCurrentUser(currentUser);
				getSupportFragmentManager().beginTransaction()
				.add(R.id.container, new GroupsFragment()).commit();
			}
		}
		
		// Check device for Play Services APK.
		if (checkPlayServices()) {
			// If this check succeeds, proceed with normal processing.
			// Otherwise, prompt user to get valid Play Services APK.
			gcm = GoogleCloudMessaging.getInstance(this);
			regid = getRegistrationId(getApplicationContext());

			if (regid.isEmpty()) {
				//registerInBackground();
				registerInBackground();
			}
		}

	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		getActionBar().setDisplayHomeAsUpEnabled(false);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		int id = item.getItemId();
		switch(id){
		case  android.R.id.home:
			if(manager.getBackStackEntryCount()>0){
		          manager.popBackStack();
		    }
			if(manager.getBackStackEntryCount()==1){
				MainActivity.activity.getActionBar().setDisplayHomeAsUpEnabled(false);
			}
			break;
		case R.id.sign_out:
			clearLoginCredentials();
			 manager.popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);
			break;
		case R.id.profile:
			break;
		case R.id.invitations:
			break;
		case R.id.new_group:
			switchView(new NewGroupFragment());
			break;
		default:
			break;
		}
		return super.onOptionsItemSelected(item);
	}

	public static void switchView(final Fragment f){
		MainActivity.activity.runOnUiThread(new Runnable(){
			public void run(){
				MainActivity.activity.getActionBar().setDisplayHomeAsUpEnabled(true);
				
				manager.beginTransaction()
				.replace(R.id.container, f).addToBackStack(f.getClass().getName()).commit();
			}
		});
		
	}

	public void hideKeyboard(){
		this.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
	}

	// You need to do the Play Services APK check here too.
	@Override
	protected void onResume() {
		super.onResume();
		checkPlayServices();
		ArrayList<String> credentials = getLoginCredentials();
		if(credentials.size()==3){
			SocketIoController.connect();
		}
		if(NetworkManager.getCurrentGroup()!=null){
			NetworkManager.getCurrentGroupMessages();
		}
	}
	
	protected void onStop(){
		SocketIoController.disconnect();
		NetworkManager.getCurrentGroup().getMessages().clear();
		HashMap<String,Group> groups = NetworkManager.getAllGroups();
		for(Group g : groups.values()){
			g.getMessages().clear();
		}
		groups.clear();
		super.onStop();
	}
	
	/**
	 * Check the device to make sure it has the Google Play Services APK. If
	 * it doesn't, display a dialog that allows users to download the APK from
	 * the Google Play Store or enable it in the device's system settings.
	 */
	private boolean checkPlayServices() {
		int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(this);
		if (resultCode != ConnectionResult.SUCCESS) {
			if (GooglePlayServicesUtil.isUserRecoverableError(resultCode)) {
				GooglePlayServicesUtil.getErrorDialog(resultCode, this,
						PLAY_SERVICES_RESOLUTION_REQUEST).show();
			} else {
				Log.i(this.getClass().getName(), "This device is not supported.");
				finish();
			}
			return false;
		}
		return true;
	}

	/**
	 * Gets the current registration ID for application on GCM service.
	 * <p>
	 * If result is empty, the app needs to register.
	 *
	 * @return registration ID, or empty string if there is no existing
	 *         registration ID.
	 */
	private String getRegistrationId(Context context) {
		final SharedPreferences prefs = getGCMPreferences(context);
		String registrationId = prefs.getString(PROPERTY_REG_ID, "");
		if (registrationId.isEmpty()) {
			Log.i(this.getClass().getName(), "Registration not found.");
			return "";
		}
		// Check if app was updated; if so, it must clear the registration ID
		// since the existing regID is not guaranteed to work with the new
		// app version.
		int registeredVersion = prefs.getInt(PROPERTY_APP_VERSION, Integer.MIN_VALUE);
		int currentVersion = getAppVersion(context);
		if (registeredVersion != currentVersion) {
			Log.i(this.getClass().getName(), "App version changed.");
			return "";
		}
		return registrationId;
	}
	
	private ArrayList<String> getLoginCredentials(){
		final SharedPreferences prefs = getGCMPreferences(getApplicationContext());
		String username = prefs.getString(USERNAME, "");
		if (username.isEmpty()) {
			Log.i(this.getClass().getName(), "User not logged in.");
			return new ArrayList<String>(0);
		}
		else{
			Log.i(this.getClass().getName(), "User information found.");
			ArrayList<String> credentials = new ArrayList<String>(0);
			credentials.add(prefs.getString(USER_ID, ""));
			credentials.add(username);
			String token = prefs.getString(SESSION_TOKEN, "");
			credentials.add(token);
			return credentials;
		}
	}
	
	public static void saveLoginCredentials(User user){
		final SharedPreferences prefs = getGCMPreferences(MainActivity.activity.getApplicationContext());
		SharedPreferences.Editor editor = prefs.edit();
		editor.putString(USER_ID, user.getId());
		editor.putString(USERNAME, user.getUsername());
		editor.putString(SESSION_TOKEN, user.getSessionToken());
		editor.commit();
	}
	
	public static void clearLoginCredentials(){
		final SharedPreferences prefs = getGCMPreferences(MainActivity.activity.getApplicationContext());
		SharedPreferences.Editor editor = prefs.edit();
		editor.remove(USERNAME);
		editor.remove(SESSION_TOKEN);
		editor.commit();
	}
	
	/**
	 * @return Application's {@code SharedPreferences}.
	 */
	private static SharedPreferences getGCMPreferences(Context context) {
		return MainActivity.activity.getSharedPreferences(MainActivity.class.getSimpleName(),
				Context.MODE_PRIVATE);
	}

	/**
	 * @return Application's version code from the {@code PackageManager}.
	 */
	private static int getAppVersion(Context context) {
		try {
			PackageInfo packageInfo = context.getPackageManager()
					.getPackageInfo(context.getPackageName(), 0);
			return packageInfo.versionCode;
		} catch (NameNotFoundException e) {
			// should never happen
			throw new RuntimeException("Could not get package name: " + e);
		}
	}
	/**
	 * Stores the registration ID and app versionCode in the application's
	 * {@code SharedPreferences}.
	 *
	 * @param context application's context.
	 * @param regId registration ID
	 */
	private void storeRegistrationId(Context context, String regId) {
		final SharedPreferences prefs = getGCMPreferences(context);
		int appVersion = getAppVersion(context);
		Log.i(this.getClass().getName(), "Saving regId on app version " + appVersion);
		SharedPreferences.Editor editor = prefs.edit();
		editor.putString(PROPERTY_REG_ID, regId);
		editor.putInt(PROPERTY_APP_VERSION, appVersion);
		editor.commit();
	}

	/**
	 * Sends the registration ID to your server over HTTP, so it can use GCM/HTTP
	 * or CCS to send messages to your app. Not needed for this demo since the
	 * device sends upstream messages to a server that echoes back the message
	 * using the 'from' address in the message.
	 */
	private void sendRegistrationIdToBackend() {
	}

	private void registerInBackground(){
		new Thread(){
			public void run(){
				String msg = "";
				try {
					if (gcm == null) {
						gcm = GoogleCloudMessaging.getInstance(getApplicationContext());
					}
					regid = gcm.register(SENDER_ID);
					msg = "Device registered, registration ID=" + regid;

					// You should send the registration ID to your server over HTTP,
					// so it can use GCM/HTTP or CCS to send messages to your app.
					// The request to your server should be authenticated if your app
					// is using accounts.
					sendRegistrationIdToBackend();

					// For this demo: we don't need to send it because the device
					// will send upstream messages to a server that echo back the
					// message using the 'from' address in the message.

					// Persist the regID - no need to register again.
					storeRegistrationId(getApplicationContext(), regid);
				} catch (IOException ex) {
					msg = "Error :" + ex.getMessage();
					// If there is an error, don't just keep trying to register.
					// Require the user to click a button again, or perform
					// exponential back-off.
				}
				Log.i(this.getClass().getName(),msg);
			}

		}.start();
	}
}