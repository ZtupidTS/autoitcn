/*
 * @(#)MainFrame.java
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
 *    $Id: MainFrame.java,v 1.22 2004/08/04 07:05:49 xrath Exp $
 */
package rath.jmsn;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

import java.io.File;

import rath.msnm.LocalCopy;
import rath.msnm.UserStatus;
import rath.msnm.MSNMessenger;
import rath.msnm.event.MsnAdapter;
import rath.msnm.entity.MsnFriend;

import rath.jmsn.ui.AddConfirmDialog;
import rath.jmsn.util.Msg;
import rath.jmsn.util.MusicBox;
import rath.jmsn.util.GlobalProp;
import rath.jmsn.util.Emoticon;
import rath.jmsn.util.AutoNickChangeServer;
import rath.jmsn.util.LocalPassword;

// For Windows platform.
import rath.NotSupportedPlatformException;
import rath.tools.Win32Toolkit;
import rath.tools.tray.*;
/**
 * MSN Messenger application entry point class
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: MainFrame.java,v 1.22 2004/08/04 07:05:49 xrath Exp $
 */
public class MainFrame extends JFrame
{
	public static final String DOWNLOAD_PROP = "download.dir";
	public static final String CHATLOG_PROP = "chatlog.dir";
	public static final String BACKIMAGE_PROP = "background.image";
	public static final String SOUND_LOGIN_PROP = "Sound.login";
	public static final String SOUND_MESSAGE_PROP = "Sound.message";
	public static final String AUTO_ACCEPT_FILE_PROP = "File.auto.accept";
	public static final String SOUND_MESSAGE_1_PROP = "Sound.message.1";
	public static final String SOUND_MESSAGE_2_PROP = "Sound.message.2";
	public static final String TIMESTAMP_DISPLAY = "timestamp.display";
	public static final String EMOTICON_DISPLAY = "emoticon.display";
	public static final String BUDDYLIST_FONT_COLOR = "buddylist.font.color";
	public static final String USE_FIXED_CHAT_FONT = "font.fixed.on.chat";
	public static final String AUTONICK = "autonick.change";
	public static final String PHOTO_PROP = "user.photo";
	public static final String PHOTO_PROP_USE = PHOTO_PROP + ".use";
	public static final String PHOTO_PROP_SHOW = PHOTO_PROP + ".show.other";
	public static final String PHOTO_PROP_LOCATION = PHOTO_PROP + ".location";

	public static LocalCopy LOCALCOPY;
	public static MainFrame INSTANCE;
	public BuddyTree buddies = null;
	private static GlobalProp global = new GlobalProp();

	MSNMenuBar menuBar = null;
	LoginSplash splash = null;

	private ActionGroup actions = null;
	private MSNMessenger msnm = null;
	private JScrollPane buddyPane = null;

	private EventViewer eventView = null;
	private Image frameIcon = null;

	private MouseAdapter loginTrigger = new LoginTrigger();
	private NativeToolkit nt = NativeToolkit.getInstance();

	public MainFrame( String title )
	{
		super( title );

		INSTANCE = this;
		frameIcon = new ImageIcon(getClass().getResource("/resources/icon/icon.jpg")).getImage();
		global.load();

		setIconImage( frameIcon );
		initialize();
		setJMenuBar( menuBar=new MSNMenuBar(this, actions) );

		/* Turn off auto file receive option. */
		rath.msnm.ftp.FileMessageProcessor.setAutoReceive( false );

		Runtime.getRuntime().addShutdownHook( new Thread(new Runnable() {
			public void run()
			{
				Point p = getLocation();
				Dimension size = getSize();
				global.set( "application.x", p.x );
				global.set( "application.y", p.y );
				global.set( "application.width", size.width );
				global.set( "application.height", size.height );
				global.store();
			}
		}) );

		/*
		 * Pre-ready to load various Emoticons 
		 */
		Emoticon.getInstance();

		int i0;
		String logstr = global.get("last.login");
		if( logstr!=null && (i0=logstr.indexOf(':'))!=-1 )
		{
		    showLogging();
			String id = logstr.substring(0, i0);
			String pass = logstr.substring(i0+1);
			msnm.login(
				id, LocalPassword.getInstance().decode(id, pass));
		}
	}

	private void initialize()
	{
		pack();
		Dimension size = Toolkit.getDefaultToolkit().getScreenSize();

		int x = global.getInt("application.x", 100);
		int y = global.getInt("application.y", 100);
		int w = global.getInt("application.width", 280);
		int h = global.getInt("application.height", 420);

		if( (x+w)>size.width )
			x = size.width - w - 15;
		if( (y+h)>size.height )
			y = size.height - h - 15;

		setSize( w, h );
		setLocation( x, y );

		setDefaultCloseOperation( DO_NOTHING_ON_CLOSE );
		addWindowListener( new WindowAdapter() {
			public void windowClosing( WindowEvent e )
			{
				if( nt.isWindows )
					setVisible( false );
				else
				{
					if( msnm.isLoggedIn() && JOptionPane.showConfirmDialog(
						(Component)e.getSource(),
						"JMSN will be terminated with all opened dialog.\n" +
						"Do you really want to continue?", "Quit",
						JOptionPane.YES_NO_OPTION)==JOptionPane.NO_OPTION )
						return;
					System.exit( 0 );
				}
			}
			public void windowDeiconified( WindowEvent e )
			{
				actions.actionRefresh();
			}
		});
		if( nt.isWindows )
			setTrayIcon();

		msnm = new MSNMessenger( "", "" );
		msnm.setInitialStatus( UserStatus.ONLINE );
		msnm.addMsnListener( new MsnAdapter() {
			public void loginComplete( MsnFriend friend )
			{
				processInit( friend.getLoginName() );
				showBuddyList();
			}
			public void loginError( String header )
			{
				if( header.equals("911") )
					JOptionPane.showMessageDialog( MainFrame.this,
						Msg.get("err.911"),	Msg.get("title.loginfail"),
						JOptionPane.ERROR_MESSAGE );
				else
				if( header.equals("921") )
					JOptionPane.showMessageDialog( MainFrame.this,
						Msg.get("err.921"),	Msg.get("title.loginfail"),
						JOptionPane.ERROR_MESSAGE );
				// 아래 2 method를 절대 OptionPane보다 먼저 호출하지 마라.
				// 제대로 바보된다.
				msnm.logout();
				showLogin();
			}
			public void whoAddedMe( MsnFriend friend )
			{
				AddConfirmDialog cd = new AddConfirmDialog(MainFrame.this, friend);
				cd.setVisible(true);
			}
		});

		this.splash = new LoginSplash();
		this.buddies = new BuddyTree(this);
		this.actions = new ActionGroup(this, buddies);

		splash.addMouseListener( loginTrigger );

		JPanel panel = new JPanel(new BorderLayout()) {
			public void updateUI()
			{
				rath.jmsn.util.UserStatusBox.collectAll();
				super.updateUI();
			}
		};
		setContentPane( panel );
		buddyPane = new JScrollPane(buddies);
		buddyPane.setBackground( Color.white );
		buddyPane.setBorder( BorderFactory.createEmptyBorder(4,4,4,4) );

		eventView = new EventViewer();
		eventView.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				EventViewer.Event ex = 
					(EventViewer.Event)eventView.getSelectedItem();
				if( ex==null )
					return;
				MsnFriend f = ex.getFriend();
				if( f!=null )
					buddies.createNewSession( f );
			}
		});

		panel.add( splash, "Center" );
		panel.add( eventView, "South" );

		System.setProperty("jmsn.transparency", "-1");
	}

	public void setVisible( boolean show )
	{
		if( show )
		{
			nt.makeTransparency(this, Integer.getInteger("jmsn.transparency", 255).intValue());
		}

	    super.setVisible(show);
	}

	public static GlobalProp getGlobalProp()
	{
	    return INSTANCE.global;
	}

	private void processInit( String loginName )
	{
		LOCALCOPY = msnm.getLocalCopy();
		LocalCopy local = LOCALCOPY;
		File root = local.getHomeDirectory();
		root = new File( root, loginName );

		String downdir = local.getProperty( DOWNLOAD_PROP );
		if( downdir==null )
		{
			File dir = new File( root, "files" );
			dir.mkdirs();
			downdir = dir.getAbsolutePath();
			local.setProperty( DOWNLOAD_PROP, downdir );
		}

		String logdir = local.getProperty( CHATLOG_PROP );
		if( logdir==null )
		{
			File dir = new File( root, "logs" );
			dir.mkdirs();
			logdir = dir.getAbsolutePath();
			local.setProperty( CHATLOG_PROP, logdir );
		}

		new File(downdir).mkdirs();
		new File(logdir).mkdirs();

		boolean isEnableLoginSound = local.getPropertyBoolean(
			SOUND_LOGIN_PROP + ".enable", true );
		boolean isEnableMessageSound = local.getPropertyBoolean(
			SOUND_MESSAGE_PROP + ".enable", true );
		boolean isEnableAutoAccept = local.getPropertyBoolean(
			AUTO_ACCEPT_FILE_PROP, false );
		boolean isEnableTimestamp = local.getPropertyBoolean(
			TIMESTAMP_DISPLAY, false );
		boolean isEnableEmoticon = local.getPropertyBoolean(
			EMOTICON_DISPLAY, true );
		boolean isEnableAutoNick = local.getPropertyBoolean(
			AUTONICK + ".enable", false);

		String buddyFontColor = local.getProperty( BUDDYLIST_FONT_COLOR, "000000" );
		try 
		{
			Color c0 = new Color(Integer.parseInt(buddyFontColor));
			buddies.renderer.setForeColor(c0);
		}
		catch( NumberFormatException ex ) {}

		if( local.getPropertyBoolean(PHOTO_PROP_USE, false) )
		{
			String file = local.getProperty(PHOTO_PROP_LOCATION);
			if( file!=null )
			{
				File f = new File(file);
				if( f.exists() )
				{
					try
					{
						msnm.setMyPhoto(f);
					}
					catch( Exception e )
					{
						e.printStackTrace();
						local.setProperty(PHOTO_PROP_LOCATION, "");
						local.setProperty(PHOTO_PROP_USE, false);
					}
				}
			}
		}

		local.setProperty( SOUND_LOGIN_PROP + ".enable", String.valueOf(isEnableLoginSound) );
		local.setProperty( SOUND_MESSAGE_PROP + ".enable", String.valueOf(isEnableMessageSound) );
		local.setProperty( AUTO_ACCEPT_FILE_PROP, String.valueOf(isEnableAutoAccept) );
		local.setProperty( TIMESTAMP_DISPLAY, String.valueOf(isEnableTimestamp) );
		local.setProperty( EMOTICON_DISPLAY, String.valueOf(isEnableEmoticon) );
		local.setProperty( BUDDYLIST_FONT_COLOR,  buddyFontColor );
		local.setProperty( AUTONICK + ".enable", String.valueOf(isEnableAutoNick) );

		if( isEnableAutoNick )
		{
			try
			{
				AutoNickChangeServer.getInstance().start();
			}
			catch( Exception ex ) {}
		}

		MusicBox.setEnabled( MusicBox.SOUND_LOGIN, isEnableLoginSound );
		MusicBox.setEnabled( MusicBox.SOUND_MESSAGE_1, isEnableMessageSound );
		MusicBox.setEnabled( MusicBox.SOUND_MESSAGE_2, isEnableMessageSound );
		System.setProperty( "jmsn.file.auto.accept", String.valueOf(isEnableAutoAccept) );

		boolean offView = local.getPropertyBoolean("View.buddy.offline", true);
		buddies.setOfflineView( offView );
		menuBar.menuOffView.setSelected( !offView );

		String backImage = local.getProperty( BACKIMAGE_PROP );
		if( backImage!=null && new File(backImage).exists() )
		{
			ImageIcon icon = new ImageIcon( backImage );
		    buddies.setBackgroundImage( icon.getImage() );
		}
		else
			buddies.setBackgroundImage( null );
		local.storeInformation();
		MusicBox.init();
	}

	public void addEvent( String msg, MsnFriend friend )
	{
		eventView.addEvent( msg, friend );
	}

	private class LoginTrigger extends MouseAdapter
	{
		public void mouseClicked( MouseEvent e )
		{
			actions.actionLogin();
		}
	};

	public void showLogin()
	{
		SwingUtilities.invokeLater( new Runnable() {
			public void run()
			{
				menuBar.disableLogin();
				splash.setInitialText();
				splash.removeMouseListener( loginTrigger );
				splash.addMouseListener( loginTrigger );
				splash.repaint();

				JPanel panel = (JPanel)getContentPane();
				panel.doLayout();
				panel.validate();
			}
		});
	}

	public void showLogging()
	{
		splash.removeMouseListener( loginTrigger );
		menuBar.setLoginEnabled( false );
		splash.setText( Msg.get("label.splash.onlogin") );
	}

	public void showBuddyList()
	{
		SwingUtilities.invokeLater( new Runnable() {
			public void run()
			{
				JPanel panel = (JPanel)getContentPane();
				panel.remove( splash );
				panel.add( buddyPane, "Center" );
				panel.doLayout();
				panel.validate();
			}
		});
	}

	public void logout()
	{
		JPanel panel = (JPanel)getContentPane();
		panel.remove( buddyPane );
		panel.add( splash, "Center" );
		panel.doLayout();
		panel.validate();

		splash.setText( Msg.get("label.splash.onlogout") );
		msnm.logout();

		showLogin();
	}

	public MSNMessenger getMessenger()
	{
		return this.msnm;
	}

	public void setMyStatus( String mode )
	{
		buddies.setMyStatus( mode );
	}

	public void updateUIAll()
	{
		SwingUtilities.updateComponentTreeUI( this );
		buddies.updateAllDialogs();
	}

	public void setTrayIcon()
	{
		ImageIcon icon = new ImageIcon( getClass().getResource("/resources/icon/icon.jpg") );
		TrayIcon tray = new TrayIcon( new NativeIcon(icon.getImage()), "JMSN" );

		nt.addTrayIcon( tray );
	}
}
