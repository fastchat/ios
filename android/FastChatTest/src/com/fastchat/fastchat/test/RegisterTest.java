package com.fastchat.fastchat.test;

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

	protected void setUp() throws Exception {
		super.setUp();
		NetworkManager.setUrl("http://localhost:3000");
	}

	protected void tearDown() throws Exception {
		super.tearDown();
	}
	
	public void testRegister_Request(){
		// Create a MockWebServer. These are lean enough that you can create a new
	    // instance for every unit test.
	    MockWebServer server = new MockWebServer();

	    // Schedule some responses.
	    server.enqueue(new MockResponse().setBody("{\"error\":\"Incorrect\"}").setResponseCode(400));
	    try {
	    // Start the server.
	    server.play(3000);

	    // Ask the server for its URL. You'll need this to make HTTP requests.
	    URL baseUrl = server.getUrl("/post");

	   NetworkManager.postRegisterUser("testUsername", "testPassword");
	    RecordedRequest request1 = server.takeRequest();
	    assertEquals("/user", request1.getPath());
	    assertEquals(request1.getMethod(),"POST");
	    Gson gson = new Gson();
	  //convert the json string back to object
	  JSONObject obj = gson.fromJson(new String(request1.getBody()), JSONObject.class);
	  assertEquals(obj.get("username"),"testUsername");
	  assertEquals(obj.get("password"),"testPassword");
	    // Shut down the server. Instances cannot be reused.
	    
			server.shutdown();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	    catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
