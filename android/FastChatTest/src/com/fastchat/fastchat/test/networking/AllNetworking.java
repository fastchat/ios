package com.fastchat.fastchat.test.networking;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

public class AllNetworking extends TestCase {

	public static Test suite() {
		TestSuite suite = new TestSuite(AllNetworking.class.getName());
		//$JUnit-BEGIN$
		suite.addTestSuite(LoginTest.class);
		suite.addTestSuite(LogoutTest.class);
		suite.addTestSuite(RegisterTest.class);
		suite.addTestSuite(ProfileTest.class);
		suite.addTestSuite(AvatarTest.class);
		//$JUnit-END$
		return suite;
	}

}
