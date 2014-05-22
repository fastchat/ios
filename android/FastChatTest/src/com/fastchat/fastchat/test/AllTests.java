package com.fastchat.fastchat.test;

import com.fastchat.fastchat.test.networking.AllNetworking;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

public class AllTests extends TestCase {

	public static Test suite() {
		TestSuite suite = new TestSuite(AllTests.class.getName());
		//$JUnit-BEGIN$
		suite.addTest(AllNetworking.suite());
		//$JUnit-END$
		return suite;
	}

}
