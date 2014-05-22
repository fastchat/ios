package com.fastchat.fastchat.test.networking;

import java.io.IOException;
import java.util.concurrent.ExecutionException;

import org.json.JSONException;
import org.json.JSONObject;

import com.fastchat.fastchat.models.User;
import com.fastchat.fastchat.networking.NetworkManager;
import com.koushikdutta.async.future.Future;
import com.squareup.okhttp.mockwebserver.MockResponse;
import com.squareup.okhttp.mockwebserver.MockWebServer;
import com.squareup.okhttp.mockwebserver.RecordedRequest;

import junit.framework.TestCase;

public class ProfileTest extends TestCase {

	MockWebServer server;

	String profileJson = "{\"profile\":{\"__v\":143,\"_id\":\"5341cfbd1dfa700200000012\",\"password\":\"$2a$10$1QFLqEDo9nkCgX5Sh/C9S.0RZub5mv0Sa09UDOMGwL8Dvh6CXLlq.\",\"username\":\"shawn\",\"avatar\":\"8058a9e9-4098-46f1-8e3e-9af07c20ff69.jpg\",\"groupSettings\":[{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"5341dafe118f86020000001a\",\"_id\":\"5341dafe118f86020000001c\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"5341f3b7f5f7980200000016\",\"_id\":\"5341f3b7f5f7980200000018\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"5342d15b46869f0200000001\",\"_id\":\"5342d15b46869f0200000004\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"5342dfe446869f020000000e\",\"_id\":\"5342dfe446869f020000000f\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"53432e1316ade00200000008\",\"_id\":\"53432e1316ade00200000009\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"53437f28bcbe780200000005\",\"_id\":\"53437f28bcbe780200000007\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"53482fc3e8f0f10200000016\",\"_id\":\"53482fc3e8f0f10200000018\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"53484f085a29d20200000019\",\"_id\":\"53484f085a29d2020000001b\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"534c929c5748ff0200000003\",\"_id\":\"534c929c5748ff0200000006\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"534ea0281613ff0200000004\",\"_id\":\"534ea0281613ff0200000005\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"534eb40dd4b2360200000019\",\"_id\":\"534eb40dd4b236020000001c\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"534f1ee6ccdf8c0200000014\",\"_id\":\"534f1ee6ccdf8c0200000015\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"534f1f2a991a200200000001\",\"_id\":\"534f1f2a991a200200000002\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"535d61026f980d0200000014\",\"_id\":\"535d61026f980d0200000016\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"5363b8b15324150200000001\",\"_id\":\"5363b8b15324150200000002\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"5373fb7a7e42030200000049\",\"_id\":\"5373fb7a7e4203020000004a\",\"__v\":0,\"unread\":0,\"notifications\":true},{\"user\":\"5341cfbd1dfa700200000012\",\"group\":\"5376bd4ecd9e3902000000ad\",\"_id\":\"5376bd4ecd9e3902000000ae\",\"__v\":0,\"unread\":0,\"notifications\":true}],\"devices\":[\"5341d10e1dfa700200000014\",\"53436c0e5276210200000001\",\"5345b056b30b9a0200000005\",\"534626749b68310200000001\",\"534d419845023e0200000001\",\"534d53963d7f350200000001\",\"53501e58b812b90200000001\",\"535050c9a0f8370200000015\",\"535ac3f230e1000200000001\",\"53757251a0411d020000012a\",\"537bbd02c3992502000000a0\",\"537bbfb2c3992502000000b7\"],\"leftGroups\":[\"53432e1316ade00200000008\",\"53437f28bcbe780200000005\",\"53482fc3e8f0f10200000016\",\"534f1ee6ccdf8c0200000014\",\"534eb40dd4b2360200000019\"],\"groups\":[{\"_id\":\"5341dafe118f86020000001a\",\"name\":\"FastChat\",\"id\":\"5341dafe118f86020000001a\"},{\"_id\":\"5341f3b7f5f7980200000016\",\"name\":\"Android-dev\",\"id\":\"5341f3b7f5f7980200000016\"},{\"_id\":\"5342d15b46869f0200000001\",\"name\":\"Senior Project\",\"id\":\"5342d15b46869f0200000001\"},{\"_id\":\"5342dfe446869f020000000e\",\"name\":\"shawn_test\",\"id\":\"5342dfe446869f020000000e\"},{\"_id\":\"53484f085a29d20200000019\",\"name\":\"mom's group\",\"id\":\"53484f085a29d20200000019\"},{\"_id\":\"534c929c5748ff0200000003\",\"name\":\"test987654\",\"id\":\"534c929c5748ff0200000003\"},{\"_id\":\"534ea0281613ff0200000004\",\"name\":\"Shawn\",\"id\":\"534ea0281613ff0200000004\"},{\"_id\":\"534f1f2a991a200200000001\",\"name\":\"Everyone\",\"id\":\"534f1f2a991a200200000001\"},{\"_id\":\"535d61026f980d0200000014\",\"name\":null,\"id\":\"535d61026f980d0200000014\"},{\"_id\":\"5363b8b15324150200000001\",\"name\":\"EHall\",\"id\":\"5363b8b15324150200000001\"},{\"_id\":\"5373fb7a7e42030200000049\",\"name\":\" \",\"id\":\"5373fb7a7e42030200000049\"},{\"_id\":\"5376bd4ecd9e3902000000ad\",\"name\":\"friends\",\"id\":\"5376bd4ecd9e3902000000ad\"}],\"accessToken\":[\"2e6687ea132ca8729029647c7d8e1c075d7ede796ff468c1a89e742424a54304df739ec72fdc628b9c5cf70377999f4c\",\"1b1c2ff503413e97571e70e33b2f7b51549e1d6209902e4bf725e3b683cdb1913f9479a2def0333b760d3461cebc3dd1\"]}}";
	
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

	public void testProfile_Request(){
		NetworkManager.setCurrentUser(new User(null, "testUsername", "testToken"));
		NetworkManager.getProfile();
		try {
			RecordedRequest request = server.takeRequest();
			assertEquals(request.getMethod(),"GET");
			assertEquals(request.getHeader("session-token"),"testToken");
			assertEquals(request.getPath(),"/user");
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
	
	public void testProfile_SettingUserId(){
		server.enqueue(new MockResponse().setBody(profileJson));
		NetworkManager.setCurrentUser(new User("testId", "testUsername", "testToken"));
		Future<JSONObject> future = NetworkManager.getProfile();
		try {
			future.get();
			Thread.sleep(100);
			System.out.println("Testing user id");
			assertEquals("5341cfbd1dfa700200000012",NetworkManager.getCurrentUser().getId());
		} catch (InterruptedException e) {
			e.printStackTrace();
		} catch (ExecutionException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
