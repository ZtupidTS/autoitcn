/*
 * Created on 2008-5-7
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package jmsn.rcsvr;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import rath.msnm.MSNMessenger;
import rath.msnm.SwitchboardSession;
import rath.msnm.entity.MsnFriend;
import rath.msnm.msg.MimeMessage;


/**
 * @author Administrator
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class Worker implements Runnable {
	public static void main(String[] args) throws Exception {
		Process pr = Runtime.getRuntime().exec("E:\\AutoItWork\\RemoteControl\\utils\\test.exe arg1");
		InputStream is = pr.getInputStream();
        InputStreamReader isr  =   new  InputStreamReader(is);
        BufferedReader reader  =   new  BufferedReader(isr);
        String str = reader.readLine();
        while (str != null) {
        	System.out.println(str);
        	str = reader.readLine();
        }
	}
	private String cmd;
	private MSNMessenger msn;
	private MsnFriend friend;
	private SwitchboardSession ss;
	
	public Worker(String cmd, MSNMessenger msn, MsnFriend friend/*, SwitchboardSession ss*/) {
		this.cmd = cmd;
		this.msn = msn;
		this.friend = friend;
		
	}

	/* (non-Javadoc)
	 * @see java.lang.Runnable#run()
	 */
	public void run() {
		Process pr;
		try {
			pr = Runtime.getRuntime().exec(cmd);
			InputStream is = pr.getInputStream();
	        InputStreamReader isr = new InputStreamReader(is);
	        BufferedReader reader = new BufferedReader(isr);
	        String str = reader.readLine();
	        MimeMessage mime = new MimeMessage(str);
	        mime.setKind(MimeMessage.KIND_MESSAGE);
	        while (str != null) {
	        	System.out.println(str);
	        	mime.setMessage(str);
	        	msn.sendMessage(friend.getLoginName(), mime);
	        	str = reader.readLine();
	        }
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
