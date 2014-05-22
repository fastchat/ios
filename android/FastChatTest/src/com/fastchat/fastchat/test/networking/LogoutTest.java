package com.fastchat.fastchat.test.networking;

import java.io.IOException;

import com.fastchat.fastchat.models.User;
import com.fastchat.fastchat.networking.NetworkManager;
import com.squareup.okhttp.mockwebserver.MockWebServer;
import com.squareup.okhttp.mockwebserver.RecordedRequest;

import junit.framework.TestCase;

public class LogoutTest extends TestCase {

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
	
	public void testLogout_Request(){
		NetworkManager.postLogout();
		try {
			RecordedRequest request = server.takeRequest();
			assertEquals("DELETE",request.getMethod());
			assertEquals("userToken",request.getHeader("session-token"));
			assertEquals("/logout",request.getPath());
		} catch (InterruptedException e) {
			fail(e.getMessage());
		}
		
	}
	
	public void testLogoutAll_Request(){
		NetworkManager.postLogoutAll();
		try {
			RecordedRequest request = server.takeRequest();
			assertEquals("DELETE",request.getMethod());
			assertEquals("userToken",request.getHeader("session-token"));
			assertEquals("/logout?all=true",request.getPath());
		} catch (InterruptedException e) {
			fail(e.getMessage());
		}
		
	}
}
