package com.fastchat.fastchat.test.networking;

import java.io.IOException;
import java.util.concurrent.ExecutionException;

import org.json.JSONException;
import org.json.JSONObject;

import com.fastchat.fastchat.models.User;
import com.fastchat.fastchat.networking.NetworkManager;
import com.koushikdutta.async.future.Future;

import junit.framework.TestCase;

import com.squareup.okhttp.mockwebserver.MockResponse;
import com.squareup.okhttp.mockwebserver.MockWebServer;
import com.squareup.okhttp.mockwebserver.RecordedRequest;
public class LoginTest extends TestCase {

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

	public void testLogin_Request(){
		// Schedule some responses.
		
		server.enqueue(new MockResponse().setBody("{\"error\" : \"Unauthorized\"}").setResponseCode(401));
		try {

			NetworkManager.postLogin("testUsername", "testPassword");
			RecordedRequest request1 = server.takeRequest();
			assertEquals("/login", request1.getPath());
			assertEquals(request1.getMethod(),"POST");
			//convert the json string back to object
			System.out.println("Body:"+new String(request1.getBody()));
			JSONObject obj = new JSONObject(new String(request1.getBody()));
			assertEquals(obj.getString("username"),"testUsername");
			assertEquals(obj.getString("password"),"testPassword");
			
		} catch (InterruptedException e) {
			fail(e.getMessage());
		}
		catch (JSONException e) {
			fail(e.getMessage());
		}finally{
			
		}
	}
	
	public void testLogin_incorrectCredentials(){
		// Schedule some responses.
		server.enqueue(new MockResponse().setBody("{\"error\" : \"Unauthorized\"}").setResponseCode(401));
		try {
			//NetworkManager.setUrl("http://localhost:3001");
			Future<JSONObject> future = NetworkManager.postLogin("testUsername", "testPassword");
			try {
				future.get();
			} catch (ExecutionException e) {
				e.printStackTrace();
			}
			server.takeRequest();
			User currentUser=NetworkManager.getCurrentUser();
			assertNull(currentUser.getId());
			assertNull(currentUser.getSessionToken());
			assertEquals("testUsername",currentUser.getUsername());
			
		} catch (InterruptedException e) {
			fail(e.getMessage());
		}finally{
		}
	}
	
	public void testLogin_correctCredentials(){
		// Schedule some responses.
		server.enqueue(new MockResponse().setBody("{\"session-token\": \"ABCD1234EF\"}"));
		try {
			//NetworkManager.setUrl("http://localhost:3002");
			Future<JSONObject> future = NetworkManager.postLogin("testUsername", "testPassword");
			
			
			try {
				future.get();
			} catch (ExecutionException e) {
				e.printStackTrace();
			}
			// Login Request
			//server.takeRequest();
			Thread.sleep(10);
			//Profile Request
			//server.takeRequest();
			
			// Device Registration request
			//server.takeRequest();
			User currentUser=NetworkManager.getCurrentUser();
			assertNotNull(currentUser);
			assertNull(currentUser.getId());
			assertEquals("testUsername",currentUser.getUsername());
			assertEquals("ABCD1234EF",currentUser.getSessionToken());

			
		}catch (InterruptedException e) {
			fail(e.getMessage());
		}finally{
		}
	}

	public void tearDown(){
		try {
			server.shutdown();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
