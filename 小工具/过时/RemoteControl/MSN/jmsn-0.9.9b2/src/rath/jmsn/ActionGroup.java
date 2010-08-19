/*
 * @(#)ActionGroup.java
 *
 * Copyright (c) 2002, Jang-Ho Hwang
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 	1. Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * 	2. Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 	3. Neither the name of the Jang-Ho Hwang nor the names of its contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *    $Id: ActionGroup.java,v 1.15 2004/06/07 11:18:29 xrath Exp $
 */
package rath.jmsn;

import java.io.IOException;
import java.awt.event.ActionEvent;
import javax.swing.JOptionPane;
import java.util.ArrayList;
import java.util.Iterator;

import rath.msnm.UserStatus;
import rath.msnm.BuddyList;
import rath.msnm.MSNMessenger;
import rath.msnm.entity.MsnFriend;
import rath.msnm.entity.Group;
import rath.jmsn.ui.*;
import rath.jmsn.util.GlobalProp;
import rath.jmsn.util.UserStatusBox;
import rath.jmsn.util.Msg;
import rath.jmsn.util.LocalPassword;
/**
 * 사용되는 ActionEvent들을 보관하는 클래스이다.
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: ActionGroup.java,v 1.15 2004/06/07 11:18:29 xrath Exp $
 */
public class ActionGroup implements UserStatus
{
	private MainFrame main = null;
	private MSNMessenger msnm = null;
	private BuddyTree buddies = null;

	private ReportDialog dialogBugReport = null;
	private ReportDialog dialogFeatureReq = null;

	public ActionGroup( MainFrame main, BuddyTree buddies )
	{
		this.main = main;
		this.buddies = buddies;
		this.msnm = main.getMessenger();
	}

	public boolean actionLogin()
	{
		LoginDialog dialog = new LoginDialog(main);
		dialog.setVisible(true);

		if( dialog.isConfirm() )
		{
			String login = dialog.getLoginName();
			String pass = dialog.getPassword();
		    processLogin( login, pass, dialog.getInitialStatus() );
			if( dialog.isRememberPassword() )
			{
				login = login + ":" + 
					LocalPassword.getInstance().encode(login,pass);
			}
			MainFrame.getGlobalProp().set( "last.login", login );
			return true;
		}
		return false;
	}

	public void actionLogout()
	{
		main.logout();
	}

	private void processLogin( String login, String pass, String status )
	{
		msnm.setInitialStatus( status );
		msnm.login( login, pass );
		main.showLogging();
	}

	/**
	 * 오프라인 사용자 보기, 안보기 toggle
	 */
	public void actionToggleOffView()
	{
		buddies.toggleOfflineView();
	}

	/**
	 * 새로운 친구를 등록하기 위한 다이얼로그를 띄운다.
	 */
	public void actionAddFriend()
	{
		AddFriendDialog add = new AddFriendDialog( main, msnm );
		add.setVisible(true);
	}

	public void actionBlockFriend()
	{
		MsnFriend friend = buddies.getSelectedFriend();
		if( friend!=null )
		{
			String loginName = friend.getLoginName();

			try
			{
				msnm.blockFriend( loginName );
			}
			catch( IOException e ) { e.printStackTrace(); }
		}
	}

	public void actionUnblockFriend()
	{
		MsnFriend friend = buddies.getSelectedFriend();
		if( friend!=null )
		{
			String loginName = friend.getLoginName();

			try
			{
				msnm.unBlockFriend( loginName );
			}
			catch( IOException e ) { e.printStackTrace(); }
		}
	}

	private ArrayList getSelectedGroupUsers()
	{
		Group group = buddies.getSelectedGroup();
		int groupIndex = -1;
		if( group==null )
		{
			MsnFriend friend = buddies.getSelectedFriend();
			if( friend!=null )
				groupIndex = friend.getGroupIndex().intValue();
		}
		else
			groupIndex = group.getIndexInt();

		if( groupIndex==-1 )
			return null;

		ArrayList list = new ArrayList(10);
		BuddyList fl = msnm.getBuddyGroup().getForwardList();
		for(Iterator i=fl.iterator(); i.hasNext(); )
		{
			MsnFriend f = (MsnFriend)i.next();
			if( f.getGroupIndex().intValue()==groupIndex )
				list.add( f );
		}
		return list;
	}

	private boolean confirmGroupProcess( ArrayList friends, String title )
	{
		StringBuffer sb = new StringBuffer(256);
		for(Iterator i=friends.iterator(); i.hasNext(); )
		{
			MsnFriend f = (MsnFriend)i.next();
			sb.append( f.getLoginName() );
			sb.append( " " );
			sb.append( f.getFormattedFriendlyName() );
			sb.append( "\n" );
		}

		if( JOptionPane.showConfirmDialog(main, 
			sb.toString(), title, JOptionPane.WARNING_MESSAGE, 
			JOptionPane.OK_CANCEL_OPTION)==JOptionPane.OK_OPTION )
			return true;
		return false;
	}

	/**
	 * 
	 */
	public void actionBlockGroup()
	{
		ArrayList users = getSelectedGroupUsers();
		if( users==null )
			return;

		if( !confirmGroupProcess(users, "") )
			return;

		for(Iterator i=users.iterator(); i.hasNext(); )
		{
			MsnFriend f = (MsnFriend)i.next();
			try
			{
				msnm.blockFriend( f.getLoginName() );
			}
			catch( IOException e ) { e.printStackTrace(); }
		}
	}

	/**
	 * 
	 */
	public void actionUnblockGroup()
	{
		ArrayList users = getSelectedGroupUsers();
		if( users==null )
			return;

		if( !confirmGroupProcess(users, "") )
			return;

		for(Iterator i=users.iterator(); i.hasNext(); )
		{
			MsnFriend f = (MsnFriend)i.next();
			try
			{
				msnm.unBlockFriend( f.getLoginName() );
			}
			catch( IOException e ) { e.printStackTrace(); }
		}
	}

	/**
	 * 현재 BuddyTree에 선택된 사용자가 있는지 검사하고 만약 있다면,
	 * 정말 삭제할 것인지, OptionPane으로 한번 커리한후, 삭제 명령을 수행한다.
	 */
	public void actionRemoveFriend()
	{
		MsnFriend friend = buddies.getSelectedFriend();
		if( friend!=null )
		{
			String loginName = friend.getLoginName();
			if( JOptionPane.showConfirmDialog( main,
				Msg.get("remdlg.query.remove.content", loginName),
				Msg.get("remdlg.query.remove.title"),
				JOptionPane.YES_NO_OPTION )==JOptionPane.YES_OPTION )
			{
				try
				{
					msnm.removeFriend( loginName );
				}
				catch( IOException e ) {}
			}
		}
	}
	
	/**
	 * 현재 선택된 사용자의 이름을 내맘대로 지정한다
	 */
	public void actionRenameFriend()
	{
		MsnFriend friend = buddies.getSelectedFriend();
		if( friend!=null)
		{
			String loginName = friend.getLoginName();
			RenameFriendDialog dialog = new RenameFriendDialog( main, msnm, loginName );
			dialog.setVisible(true);
		}
	}

	public void actionAddGroup()
	{
		AddGroupDialog dialog = new AddGroupDialog( main, msnm );
		dialog.setVisible(true);
	}

	// added by pistos - for support group name change
	public void actionRenameGroup()
	{
		Group group = buddies.getSelectedGroup();
		if( group!=null)
		{
			Integer gi = group.getIndex();
			String groupName = group.getName();
			RenameGroupDialog dialog = new RenameGroupDialog( main, msnm, gi, groupName );
			dialog.setVisible(true);
		}		
	}

	public void actionRemoveGroup()
	{
		Group group = buddies.getSelectedGroup();
		if( group!=null )
		{
			Integer gi = group.getIndex();
			BuddyList fl = msnm.getBuddyGroup().getForwardList();
		    for(int i=0, len=fl.size(); i<len; i++)
			{
				MsnFriend friend = fl.get(i);
				if( friend.getGroupIndex().equals(gi) )
				{
					JOptionPane.showMessageDialog( main,
					Msg.get("remgdlg.exist.content"),
					Msg.get("remgdlg.exist.title"),
					JOptionPane.ERROR_MESSAGE);
					return;
				}
			}

			String groupName = group.getName();
			if( JOptionPane.showConfirmDialog( main,
				Msg.get("remgdlg.query.remove.content", groupName),
				Msg.get("remgdlg.query.remove.title"),
				JOptionPane.YES_NO_OPTION )==JOptionPane.YES_OPTION )
			{
				try
				{
					msnm.removeGroup( group.getIndexInt() );
				}
				catch( IOException e ) {}
			}
		}
	}

	public void actionStatusChange( ActionEvent evt )
	{
		String info = evt.getActionCommand();
		String mode = UserStatusBox.getStatusAtFormattedValue(info);
		if( mode==null ) return;
		try
		{
			main.setMyStatus( mode );
			msnm.setMyStatus( mode );
		}
		catch( IOException e ) { e.printStackTrace(); }
	}

	public void actionBuddyView( ActionEvent e )
	{
		String cmd = e.getActionCommand();

		if( cmd.equals(Msg.get("menu.item.friendview.fn")) )
		{
			buddies.setBuddyView( BuddyRenderer.VIEW_FRIENDLY_NAME );
		}
		else
		if( cmd.equals(Msg.get("menu.item.friendview.ln")) )
		{
			buddies.setBuddyView( BuddyRenderer.VIEW_LOGIN_NAME );
		}
		else
		if( cmd.equals(Msg.get("menu.item.friendview.my")) )
		{
			buddies.setBuddyView( BuddyRenderer.VIEW_MYFRIENDLY_NAME );
		}
		if( cmd.equals(Msg.get("menu.item.friendview.fnln")) )
		{
			buddies.setBuddyView(
				BuddyRenderer.VIEW_LOGIN_NAME | BuddyRenderer.VIEW_FRIENDLY_NAME );
		}
	}

	public void actionExit()
	{
		System.exit(0);
	}

	public void actionAbout()
	{
		new AboutDialog(main).setVisible(true);
	}

	public void actionOption()
	{
		new OptionDialog(main, msnm).setVisible(true);
	}

	public void actionBugReport()
	{
		new ReportDialog(main, msnm, Msg.get("title.bugreport"),
			ReportDialog.REPORT_BUG).setVisible(true);
	}

	public void actionFeatureRequest()
	{
		new ReportDialog(main, msnm, Msg.get("title.reqfeature"),
			ReportDialog.REPORT_FEATURE).setVisible(true);
	}

	public void actionRefresh()
	{
		main.buddies.syncAllUsers();
	}

	private boolean isAlwaysOnTop = false;
	public void actionAlwaysOnTop()
	{
		NativeToolkit.getInstance().makeTopMost( main, !isAlwaysOnTop );
		isAlwaysOnTop = !isAlwaysOnTop;
	}
}
