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
 * MSN演示程序
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
		// 捕捉Ctrl+C的输入以便注销MSN的登录
		Runtime.getRuntime().addShutdownHook(new MSNDaemon());
	}

	/**
	 * 掉线的时候
	 */
	public void run() {
		msn.logout();
		System.out.println(msn.getOwner().getLoginName() + "掉线了...");
		while (true) {
			try {
				Thread.sleep(10000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			if (msn.isLoggedIn()) {
				continue;
			}
			System.out.println(msn.getOwner().getLoginName() + "尝试重新登录...");
			msn.login();
		}
	}
}
/**
 * MSN消息事件处理类
 * 
 * @author Liudong
 */

class MSNAdapter extends MsnAdapter {
	MSNMessenger messenger;

	public MSNAdapter(MSNMessenger messenger) {
		this.messenger = messenger;
	}

	/**
	 * 某人正在输入信息
	 */
	public void progressTyping(SwitchboardSession ss, MsnFriend friend,
			String typingUser) {
		//System.out.println(friend.getLoginName() + "正在输入信息...");
	}

	/**
	 * 收到消息的时候执行该方法
	 */
	public void instantMessageReceived(SwitchboardSession ss, MsnFriend friend,
			MimeMessage mime) {
		System.out.print("接收到消息：" + friend.getFriendlyName() + "->");
		String cmd = mime.getMessage();
		System.out.println(cmd);
		try {
			new Worker(cmd, messenger, friend).run();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 登录成功后执行该方法
	 */
	public void loginComplete(MsnFriend own) {
		System.out.println(own.getLoginName() + " Login OK");
	}

	/**
	 * 登录失败后执行该方法
	 */
	public void loginError(String header) {
		System.out.println("Login Failed: " + header);
	}

	/**
	 * 好友离线时执行该方法
	 */
	public void userOffline(String loginName) {
		//System.out.println("USER " + loginName + " Logout.");
	}

	/**
	 * 好友上线时执行该方法
	 */
	public void userOnline(MsnFriend friend) {
		//System.out.println("USER " + friend.getFriendlyName() + " Login.");
	}

	/**
	 * 有人加我为好友时执行
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
	 * 有人把我从好友列表中删除时执行
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
