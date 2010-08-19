/*
 * @(#)MSNMenuBar.java
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
 *    $Id: MSNMenuBar.java,v 1.16 2004/06/07 06:02:15 xrath Exp $
 */
package rath.jmsn;

import java.awt.*;
import java.awt.event.KeyEvent;
import java.awt.event.InputEvent;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.lang.reflect.Method;
import java.util.Properties;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.Locale;
import javax.swing.*;

import rath.msnm.UserStatus;
import rath.jmsn.ui.WrapMenu;
import rath.jmsn.ui.WrapMenuItem;
import rath.jmsn.ui.WrapPopupMenu;
import rath.jmsn.util.UserStatusBox;
import rath.jmsn.util.Msg;
/**
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: MSNMenuBar.java,v 1.16 2004/06/07 06:02:15 xrath Exp $
 */
public class MSNMenuBar extends JMenuBar implements ToolBox
{
	private JPopupMenu statusPopup = null;

	private JMenuItem menuLogin, menuLogout;
	private JMenuItem menuAddFriend, menuRenameFriend, menuRemoveFriend;
	private JMenuItem menuAddGroup, menuRenameGroup, menuRemoveGroup;
	private JMenuItem menuBlockFriend, menuUnblockFriend;
	private JMenuItem menuBlockGroup, menuUnblockGroup;
	private WrapMenu menuLocale;
	private JMenu menuStat;

	MainFrame main = null;
	JCheckBoxMenuItem menuOffView;

	public MSNMenuBar( MainFrame main, ActionGroup actions )
	{
		this.main = main;

		init(actions);
		disableLogin();
	}

	private void init( ActionGroup actions )
	{
		collectActions(actions);

		statusPopup = new WrapPopupMenu();

		add( createFileMenu() );
		add( createViewMenu() );
		add( createToolMenu() );
		add( createHelpMenu() );
	}

	public void updateUI()
	{
		if( menuLocale!=null )
		{
			menuLocale.removeAll();
			for(Iterator i=Msg.getAvailableLocales().iterator(); i.hasNext(); )
			{
				final Locale loc = (Locale)i.next();
				JMenuItem item = menuLocale.add( loc.getDisplayName(), false );
				item.setFont( FONT );
				item.addActionListener( new ActionListener() {
					public void actionPerformed( ActionEvent e )
					{
						Msg.setLocale( loc );
					}
				});
			}
		}
		if( statusPopup!=null )
			statusPopup.updateUI();
		super.updateUI();
	}

	protected JMenu createFileMenu()
	{
		ActionMap action = getActionMap();

		JMenu menu = new WrapMenu("menu.file");
		menu.setMnemonic( Msg.get("menu.file.mnemonic").charAt(0) );
		menu.setFont( MENU_HEADER_FONT );

		menuLogin = menu.add( "menu.item.login" );
		menuLogin.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_C, InputEvent.ALT_MASK) );
		menuLogin.setFont( MENU_FONT );
		menuLogin.addActionListener( action.get("actionLogin") );

		menuLogout = menu.add( "menu.item.logout" );
		menuLogout.setFont( MENU_FONT );
		menuLogout.addActionListener( action.get("actionLogout") );

		menu.addSeparator();

		JMenuItem menuExit = menu.add( "menu.item.exit" );
		menuExit.setFont( MENU_FONT );
		menuExit.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_X, InputEvent.ALT_MASK) );
		menuExit.addActionListener( action.get("actionExit") );

		return menu;
	}

	public JPopupMenu getStatusPopupMenu()
	{
		return this.statusPopup;
	}

	protected JMenu createViewMenu()
	{
		ActionMap action = getActionMap();

		JMenu menu = new WrapMenu("menu.view");
		menu.setMnemonic( Msg.get("menu.view.mnemonic").charAt(0) );
		menu.setFont( MENU_HEADER_FONT );

		JMenu menuBuddy = new WrapMenu("menu.item.friendview");
		menuBuddy.setFont( MENU_FONT );

		JMenuItem menuFRView = menuBuddy.add( "menu.item.friendview.fn" );
		menuFRView.setFont( MENU_FONT );
		menuFRView.addActionListener( action.get("actionBuddyView") );
		JMenuItem menuLGView = menuBuddy.add( "menu.item.friendview.ln" );
		menuLGView.setFont( MENU_FONT );
		menuLGView.addActionListener( action.get("actionBuddyView") );
		JMenuItem menuFRLGView = menuBuddy.add( "menu.item.friendview.fnln" );
		menuFRLGView.setFont( MENU_FONT );
		menuFRLGView.addActionListener( action.get("actionBuddyView") );
		JMenuItem menuMyView = menuBuddy.add( "menu.item.friendview.my" );
		menuMyView.setFont( MENU_FONT );
		menuMyView.addActionListener( action.get("actionBuddyView") );

		menu.add( menuBuddy );
		menu.addSeparator();

		JMenuItem menuRefresh = menu.add( "menu.item.refresh" );
		menuRefresh.setFont( MENU_FONT );
		menuRefresh.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_F5, 0) );
		menuRefresh.addActionListener( action.get("actionRefresh") );

		menuOffView = new JCheckBoxMenuItem( Msg.get("menu.item.off.ignore") )
		{
			public void updateUI()
			{
				setText( Msg.get("menu.item.off.ignore") );
				super.updateUI();
			}
		};
		menuOffView.addActionListener( action.get("actionToggleOffView") );
		menuOffView.setFont( MENU_FONT );
		menu.add( menuOffView );

		menu.addSeparator();

		if( NativeToolkit.getInstance().isWindows )
		{
			JCheckBoxMenuItem menuAlwaysTop = new JCheckBoxMenuItem( Msg.get("menu.item.alwaysontop") )
			{
				public void updateUI()
				{
					setText( Msg.get("menu.item.alwaysontop") );
					super.updateUI();
				}
			};
			menuAlwaysTop.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_A, InputEvent.ALT_MASK) );
			menuAlwaysTop.addActionListener( action.get("actionAlwaysOnTop") );
			menuAlwaysTop.setFont( MENU_FONT );
			menu.add( menuAlwaysTop );
		}

		WrapMenu menuUI = new WrapMenu("menu.item.lnf");
		menuUI.setFont( FONT );
		UIManager.LookAndFeelInfo[] lnfs = UIManager.getInstalledLookAndFeels();
		for(int i=0; i<lnfs.length; i++)
		{
			final UIManager.LookAndFeelInfo info = lnfs[i];
			JMenuItem item = menuUI.add( info.getName(), false );
			item.setFont( FONT );
			item.addActionListener( new ActionListener() {
				public void actionPerformed( ActionEvent e )
				{
					try
					{
						UIManager.setLookAndFeel( info.getClassName() );
					}
					catch( Exception ex ) {}
					main.updateUIAll();
				}
			});
		}
		menu.add( menuUI );

		menuLocale = new WrapMenu("menu.item.locale");
		menuLocale.setFont( FONT );

		for(Iterator i=Msg.getAvailableLocales().iterator(); i.hasNext(); )
		{
			final Locale loc = (Locale)i.next();
			JMenuItem item = menuLocale.add( loc.getDisplayName(Msg.getCurrentLocale()), false );
			item.setFont( FONT );
			item.addActionListener( new ActionListener() {
				public void actionPerformed( ActionEvent e )
				{
		    		Msg.setLocale( loc );
				}
			});
		}

		menu.add( menuLocale );

		return menu;
	}

	protected JMenu createToolMenu()
	{
		ActionMap action = getActionMap();

		JMenu menu = new WrapMenu("menu.tool");
		menu.setMnemonic( Msg.get("menu.tool.mnemonic").charAt(0) );
		menu.setFont( MENU_HEADER_FONT );

		menuStat = new WrapMenu( "menu.item.chstatus" );
		menuStat.setFont( MENU_FONT );
		addStatusSet( menuStat, statusPopup, action );
		menu.add( menuStat );
		menu.addSeparator();

		menuAddFriend = menu.add( "menu.item.adduser" );
		menuAddFriend.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_A, InputEvent.ALT_MASK) );
		menuAddFriend.setFont( MENU_FONT );
		menuAddFriend.addActionListener( action.get("actionAddFriend") );

		menuRenameFriend = menu.add( "menu.item.renameuser" );
		menuRenameFriend.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_M, InputEvent.CTRL_MASK) );
		menuRenameFriend.setFont( MENU_FONT );
		menuRenameFriend.addActionListener( action.get("actionRenameFriend") );

		menuBlockFriend = menu.add( "menu.item.blockuser" );
		menuBlockFriend.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_B, InputEvent.CTRL_MASK) );
		menuBlockFriend.setFont( MENU_FONT );
		menuBlockFriend.addActionListener( action.get("actionBlockFriend") );

		menuUnblockFriend = menu.add( "menu.item.unblockuser" );
		menuUnblockFriend.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_U, InputEvent.CTRL_MASK) );
		menuUnblockFriend.setFont( MENU_FONT );
		menuUnblockFriend.addActionListener( action.get("actionUnblockFriend") );

		menuRemoveFriend = menu.add( "menu.item.removeuser" );
		menuRemoveFriend.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_DELETE, 0) );
		menuRemoveFriend.setFont( MENU_FONT );
		menuRemoveFriend.addActionListener( action.get("actionRemoveFriend") );

		menu.addSeparator();
		menuAddGroup = menu.add( "menu.item.addgroup" );
		menuAddGroup.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_A, InputEvent.CTRL_MASK) );
		menuAddGroup.setFont( MENU_FONT );
		menuAddGroup.addActionListener( action.get("actionAddGroup") );

		// added by pistos - for support group name change
		menuRenameGroup = menu.add( "menu.item.renamegroup" );
		menuRenameGroup.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_R, InputEvent.CTRL_MASK) );
		menuRenameGroup.setFont( MENU_FONT );
		menuRenameGroup.addActionListener( action.get("actionRenameGroup") );

		menuBlockGroup = menu.add( "menu.item.blockgroup" );
		menuBlockGroup.setFont( MENU_FONT );
		menuBlockGroup.addActionListener( action.get("actionBlockGroup") );

		menuUnblockGroup = menu.add( "menu.item.unblockgroup" );
		menuUnblockGroup.setFont( MENU_FONT );
		menuUnblockGroup.addActionListener( action.get("actionUnblockGroup") );

		menuRemoveGroup = menu.add( "menu.item.removegroup");
		menuRemoveGroup.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_DELETE, InputEvent.CTRL_MASK) );
		menuRemoveGroup.setFont( MENU_FONT );
		menuRemoveGroup.addActionListener( action.get("actionRemoveGroup") );
		menu.addSeparator();

		JMenuItem menuOption = menu.add( "menu.item.option" );
		menuOption.setMnemonic( Msg.get("menu.item.option.mnemonic").charAt(0) );
		menuOption.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_O, InputEvent.ALT_MASK) );
		menuOption.setFont( MENU_FONT );
		menuOption.addActionListener( action.get("actionOption") );

		return menu;
	}

	private void addStatusSet( JMenu menu, JPopupMenu pop, ActionMap action )
	{
		String[] codes = new String[] {
		    "status.online", "status.away", "status.brb", "status.busy",
			"status.idle", "status.eat", "status.phone", "status.hidden" };
		for(int i=0; i<codes.length; i++)
		{
		    JMenuItem item = menu.add( codes[i] );
			item.setFont( FONT );
			item.addActionListener( action.get("actionStatusChange") );
			JMenuItem popItem = pop.add( codes[i] );
			popItem.setFont( FONT );
			popItem.addActionListener( action.get("actionStatusChange") );
		}
	}

	protected JMenu createHelpMenu()
	{
		ActionMap action = getActionMap();

		JMenu menu = new WrapMenu("menu.help");
		menu.setMnemonic( Msg.get("menu.help.mnemonic").charAt(0) );
		menu.setFont( MENU_HEADER_FONT );

		JMenuItem bugMenu = menu.add( "menu.item.bugreport" );
		bugMenu.setFont( MENU_FONT );
		bugMenu.addActionListener( action.get("actionBugReport") );
		bugMenu.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_F8,0) );

		JMenuItem featureMenu = menu.add( "menu.item.reqfeature" );
		featureMenu.setFont( MENU_FONT );
		featureMenu.addActionListener( action.get("actionFeatureRequest") );
		featureMenu.setAccelerator( KeyStroke.getKeyStroke(KeyEvent.VK_F9,0) );

		menu.addSeparator();

		JMenuItem aboutMenu = menu.add( "menu.item.about" );
		aboutMenu.setFont( MENU_FONT );
		aboutMenu.addActionListener( action.get("actionAbout") );

		return menu;
	}

	public void setLoginEnabled( boolean enable )
	{
		menuLogin.setEnabled( enable );
	}

	public boolean isLoginEnabled()
	{
		return menuLogin.isEnabled();
	}

	public void enableLogin()
	{
		SwingUtilities.invokeLater( new Runnable() {
			public void run()
			{
				menuLogin.setEnabled( false );
				menuLogout.setEnabled( true );

				menuAddFriend.setEnabled( true );
				menuRemoveFriend.setEnabled( true );
				menuAddGroup.setEnabled( true );
				menuRenameGroup.setEnabled( true );
				menuRemoveGroup.setEnabled( true );
				menuStat.setEnabled( true );

				menuBlockFriend.setEnabled( true );
				menuUnblockFriend.setEnabled( true );
				menuBlockGroup.setEnabled( true );
				menuUnblockGroup.setEnabled( true );
				menuRenameFriend.setEnabled( true );
			}
		});
	}

	public void disableLogin()
	{
		SwingUtilities.invokeLater( new Runnable() {
			public void run()
			{
				menuLogin.setEnabled( true );
				menuLogout.setEnabled( false );

				menuAddFriend.setEnabled( false );
				menuRemoveFriend.setEnabled( false );
				menuAddGroup.setEnabled( false );
				menuRenameGroup.setEnabled( false );
				menuRemoveGroup.setEnabled( false );
				menuStat.setEnabled( false );

				menuBlockFriend.setEnabled( false );
				menuUnblockFriend.setEnabled( false );
				menuBlockGroup.setEnabled( false );
				menuUnblockGroup.setEnabled( false );
				menuRenameFriend.setEnabled( false );
			}
		});
	}

	protected void collectActions( final ActionGroup actions )
	{
		ActionMap action = getActionMap();

		Method[] ms = actions.getClass().getMethods();
		for(int i=0; i<ms.length; i++)
		{
			final Method m = ms[i];
			String name = m.getName();
			if( name.startsWith("action") )
			{
				action.put( name, new AbstractAction() {
					public void actionPerformed( ActionEvent e )
					{
						try
						{
							if( m.getParameterTypes().length==0 )
								m.invoke( actions, new Object[] {} );
							else
								m.invoke( actions, new Object[] {e} );
						}
						catch( Exception ex ) {
							ex.printStackTrace();
						}
					}
				});
			}
		}
	}
}
