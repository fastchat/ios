package com.example.fastchat;

public class Message {

	private String text;
	private boolean mine;
	private String from;
	
	public Message(String text,boolean mine,String from){
		this.text=text;
		this.mine=mine;
		this.from=from;
		if(from==null){
			this.from="";
		}
	}
	
	public String getText(){
		return this.text;
	}
	
	public boolean isMine(){
		return this.mine;
	}
	
	public String getFrom(){
		return this.from;
	}
}
