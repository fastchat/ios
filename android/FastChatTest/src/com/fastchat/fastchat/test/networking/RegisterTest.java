package com.fastchat.fastchat.test.networking;

import java.io.IOException;
import java.net.URL;

import org.json.JSONException;
import org.json.JSONObject;

import com.fastchat.fastchat.networking.NetworkManager;
import com.google.gson.Gson;
import com.squareup.okhttp.mockwebserver.MockResponse;
import com.squareup.okhttp.mockwebserver.MockWebServer;
import com.squareup.okhttp.mockwebserver.RecordedRequest;

import junit.framework.TestCase;

public class RegisterTest extends TestCase {

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
	}

	public void tearDown(){
		try {
			server.shutdown();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void testRegister_Request(){

		NetworkManager.postRegisterUser("testUsername", "testPassword");
		RecordedRequest request1;
		try {
			request1 = server.takeRequest();

			assertEquals("/user", request1.getPath());
			assertEquals(request1.getMethod(),"POST");
			
			JSONObject obj = new JSONObject(new String(request1.getBody()));
			
			assertEquals(obj.get("username"),"testUsername");
			assertEquals(obj.get("password"),"testPassword");
			
		} catch (InterruptedException e) {
			fail(e.getMessage());
		} catch (JSONException e) {
			fail(e.getMessage());
		}
	}

}
