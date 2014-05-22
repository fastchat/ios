package com.fastchat.fastchat.test.networking;

import java.io.IOException;

import android.R;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.fastchat.fastchat.models.User;
import com.fastchat.fastchat.networking.NetworkManager;
import com.squareup.okhttp.mockwebserver.MockWebServer;
import com.squareup.okhttp.mockwebserver.RecordedRequest;

import junit.framework.TestCase;

public class AvatarTest extends TestCase {

	MockWebServer server;

	public void setUp(){
		server = new MockWebServer();
		try {
			server.play(3000);
		} catch (IOException e) {
			e.printStackTrace();
		}
		//URL baseUrl = server.getUrl("/");
		NetworkManager.setUrl("http://localhost:3000");
		NetworkManager.setCurrentUser(new User("userId","userName","userToken"));
	}

	public void tearDown(){
		try {
			server.shutdown();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public void testAvatarPOST_Request(){
		Bitmap bmp = BitmapFactory.decodeResource(Resources.getSystem(), R.drawable.ic_menu_camera);
		NetworkManager.postAvatar(bmp);
		try {
			RecordedRequest request = server.takeRequest();
			assertEquals("POST",request.getMethod());
			assertEquals("userToken",request.getHeader("session-token"));
			assertEquals("/user/userId/avatar",request.getPath());
		} catch (InterruptedException e) {
			fail(e.getMessage());
		}
		
	}
}
