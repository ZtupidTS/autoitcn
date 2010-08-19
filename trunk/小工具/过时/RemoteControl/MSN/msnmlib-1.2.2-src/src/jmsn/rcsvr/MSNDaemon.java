/*
 * Created on 2003-11-21 by Liudong
 */
package jmsn.rcsvr;

import rath.msnm.MSNMessenger;
import rath.msnm.SwitchboardSession;
import rath.msnm.UserStatus;
import rath.msnm.entity.MsnFriend;
import rath.msnm.event.MsnAdapter;
import rath.msnm.msg.MimeMessage;

/**
 * MSN��ʾ����
 * 
 * @author Liudong
 */
public class MSNDaemon extends Thread {
	private static MSNMessenger msn;

	public static void main(String[] args) {
		System.setProperty("http.proxySet", "true"); 
		System.setProperty("http.proxyHost", "proxysh.com.zte.cn"); 
		System.setProperty("http.proxyPort", "80"); 
		
		msn = new MSNMessenger("rmtctrl@hotmail.com", "5788312");
		msn.setInitialStatus(UserStatus.ONLINE);
		msn.addMsnListener(new MSNAdapter(msn));
		msn.login();
		System.out.println("Waiting for the response....");
		// ��׽Ctrl+C�������Ա�ע��MSN�ĵ�¼
		Runtime.getRuntime().addShutdownHook(new MSNDaemon());
	}

	/**
	 * ���ߵ�ʱ��
	 */
	public void run() {
		msn.logout();
		System.out.println(msn.getOwner().getLoginName() + "������...");
		while (true) {
			try {
				Thread.sleep(10000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			if (msn.isLoggedIn()) {
				continue;
			}
			System.out.println(msn.getOwner().getLoginName() + "�������µ�¼...");
			msn.login();
		}
	}
}
/**
 * MSN��Ϣ�¼�������
 * 
 * @author Liudong
 */

class MSNAdapter extends MsnAdapter {
	MSNMessenger messenger;

	public MSNAdapter(MSNMessenger messenger) {
		this.messenger = messenger;
	}

	/**
	 * ĳ������������Ϣ
	 */
	public void progressTyping(SwitchboardSession ss, MsnFriend friend,
			String typingUser) {
		//System.out.println(friend.getLoginName() + "����������Ϣ...");
	}

	/**
	 * �յ���Ϣ��ʱ��ִ�и÷���
	 */
	public void instantMessageReceived(SwitchboardSession ss, MsnFriend friend,
			MimeMessage mime) {
		System.out.print("���յ���Ϣ��" + friend.getFriendlyName() + "->");
		String cmd = mime.getMessage();
		System.out.println(cmd);
		try {
			new Worker(cmd, messenger, friend).run();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * ��¼�ɹ���ִ�и÷���
	 */
	public void loginComplete(MsnFriend own) {
		System.out.println(own.getLoginName() + " Login OK");
	}

	/**
	 * ��¼ʧ�ܺ�ִ�и÷���
	 */
	public void loginError(String header) {
		System.out.println("Login Failed: " + header);
	}

	/**
	 * ��������ʱִ�и÷���
	 */
	public void userOffline(String loginName) {
		//System.out.println("USER " + loginName + " Logout.");
	}

	/**
	 * ��������ʱִ�и÷���
	 */
	public void userOnline(MsnFriend friend) {
		//System.out.println("USER " + friend.getFriendlyName() + " Login.");
	}

	/**
	 * ���˼���Ϊ����ʱִ��
	 */
	public void whoAddedMe(MsnFriend friend) {
//		System.out.println("USER " + friend.getLoginName() + " Addme.");
//		try {
//			messenger.addFriend(friend.getLoginName());
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
	}

	/**
	 * ���˰��ҴӺ����б���ɾ��ʱִ��
	 */
	public void whoRemovedMe(MsnFriend friend) {
//		System.out.println("USER " + friend.getLoginName() + " Remove me.");
//		try {
//			messenger.removeFriend(friend.getLoginName());
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
	}
}
