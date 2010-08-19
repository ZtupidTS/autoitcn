/*
 * @(#)ChatDialog.java
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
 *    $Id: ChatDialog.java,v 1.38 2004/08/04 07:05:49 xrath Exp $
 */
package rath.jmsn.ui;

import java.awt.*;
import java.awt.event.*;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;
import java.util.Properties;
import java.util.Vector;
import java.util.Hashtable;
import javax.swing.*;
import javax.swing.filechooser.*;
import javax.swing.text.*;

import rath.msnm.UserStatus;
import rath.msnm.LocalCopy;
import rath.msnm.MSNMessenger;
import rath.msnm.SwitchboardSession;
import rath.msnm.event.MsnAdapter;
import rath.msnm.entity.MsnFriend;
import rath.msnm.msg.MimeMessage;
import rath.msnm.msg.MimeUtility;
import rath.msnm.ftp.VolatileDownloader;
import rath.msnm.ftp.VolatileTransferServer;

import rath.jmsn.ToolBox;
import rath.jmsn.MainFrame;
import rath.jmsn.NativeToolkit;
import rath.jmsn.entity.FileItem;
import rath.jmsn.file.FileProgress;
import rath.jmsn.file.ChatLogWriter;
import rath.jmsn.util.MusicBox;
import rath.jmsn.util.Msg;
import rath.util.HangulJamoUtil;

/**
 * 대화할때 사용되는 다이얼로그이다.
 *
 * @author Jang-Ho Hwang, rath@xrath.com
 * @version $Id: ChatDialog.java,v 1.38 2004/08/04 07:05:49 xrath Exp $
 */
public class ChatDialog extends JFrame implements ToolBox, DialogAppender
{
    private static final SimpleDateFormat ts = new SimpleDateFormat("[HH:mm]" );
	private static final SimpleDateFormat sdf = new SimpleDateFormat("mm:ss");

	private MSNMessenger msnm = null;
	private MsnFriend me = null;
	private JScrollPane chatPane = null;
	private JScrollPane inputPane = null;
	private JButton filesendButton = null;
	private ChatArea chatArea = null;

	private JTextArea inputArea = null;
	private JLabel statusLabel = null;
	private SwitchboardSession session = null;
	private boolean isSessionClose = false;
	private WindowListener wl = null;

	private JLabel photoMe = null;
	private JLabel photoYou = null;
	private JPanel photoPanel = null;

	private JPanel topPanel = null;
	private JPanel mainPanel = null;
	private JPanel bottomPanel = null;

	private MsnFriend you = null;
	private ArrayList queue = new ArrayList();
	private ChatLogWriter log = null;

	private Vector fileQueue = new Vector();
	private Hashtable fileCookieMap = new Hashtable();
	private MsnAdapter fileAdapter = new FileAdapter();

	private ArrayList historyQueue = new ArrayList();
	private int historyIndex = -1;

	private long lastMessagingTime = 0L;
	private boolean isViewTimestamp = MainFrame.LOCALCOPY.getPropertyBoolean(MainFrame.TIMESTAMP_DISPLAY, false);
	private boolean useFixedFont = MainFrame.LOCALCOPY.getPropertyBoolean(MainFrame.USE_FIXED_CHAT_FONT, false);

	public ChatDialog( Frame owner, MSNMessenger msnm, String targetName, MsnFriend i )
	{
		setTitle( targetName );

		this.me = i;
		this.msnm = msnm;

		init();
	}

	/**
	 * 상대방으로부터 쪽지창이 열렸을때 사용되는 constructor이다.
	 */
	public ChatDialog( Frame owner, MSNMessenger msnm, SwitchboardSession session,
		MsnFriend i )
	{
		setTitle( session.getMsnFriend().getLoginName() );

		this.me = i;
		this.you = session.getMsnFriend();
		this.msnm = msnm;
		this.session = session;

		MusicBox.play( MusicBox.SOUND_MESSAGE_2 );
		prepareLogWriter( you.getLoginName() );
		init();
	}

	private void init()
	{
		createComponents();
		createKeyMap();
		
		this.addComponentListener( new DialogStatus() );
		super.addWindowListener( new WindowAdapter() {
			/**
			 * To fix focus problem in MacOS X
			 */ 
			public void windowActivated( WindowEvent e )
			{
				 chatArea.requestFocus();
				 inputArea.requestFocus();
			}
		});
		this.msnm.addMsnListener( fileAdapter );

		Dimension size = Toolkit.getDefaultToolkit().getScreenSize();
		int x = (int)(Math.random() * (double)(size.height-getSize().width));
		int y = (int)(Math.random() * (double)(size.height-getSize().height));

		setLocation( x, y );
		setDefaultCloseOperation( DISPOSE_ON_CLOSE );
	}

	private void prepareLogWriter( String targetName )
	{
		if( this.log!=null )
			return;

		String logdir = msnm.getLocalCopy().getProperty( MainFrame.CHATLOG_PROP );
		File file = new File( logdir, targetName + ".txt" );
		try {
			this.log = new ChatLogWriter( file );
		} catch( IOException e ) { System.err.println( "can't write log file." ); }
	}

	private class FileAdapter extends MsnAdapter
	{
		public void fileReceiveStarted( VolatileDownloader down )
		{
			String cookie = down.getCookie();
			FileProgress prog = null;
			if( (prog=(FileProgress)fileCookieMap.remove(cookie))!=null )
			{
				prog.setTransfer( down );
			}
		}

		public void fileSendStarted( VolatileTransferServer vts )
		{
			String cookie = vts.getCookie();

			FileProgress prog = null;
			if( (prog=(FileProgress)fileCookieMap.remove(cookie))!=null )
			{
				prog.setTransfer( vts );
			}
		}

		public void fileSendError( VolatileTransferServer server, Throwable e )
		{
			e.printStackTrace();
		}

		public void fileSendAccepted( SwitchboardSession ss, int cookie )
		{
			if( session==null ) return;

			if( ss.getSessionId().equals( session.getSessionId() ) )
			{
				final FileProgress prog = new FileProgress( ChatDialog.this );
				fileCookieMap.put( String.valueOf(cookie), prog );

				SwingUtilities.invokeLater( new Runnable() {
					public void run()
					{
						topPanel.add( prog );
						topPanel.doLayout();
						topPanel.validate();
					}
				});

				MimeMessage msg = new MimeMessage();
				msg.setMessage( Msg.get("chatdlg.filesend.accept", you.getLoginName()) );
				appendMessage( msg );
			}
		}

		public void fileSendRejected( SwitchboardSession ss, int cookie, String reason )
		{
			if( session==null ) return;

			if( ss.getSessionId().equals( session.getSessionId() ) )
			{
				MimeMessage msg = new MimeMessage();
				msg.setMessage( Msg.get("chatdlg.filesend.reject", you.getLoginName()) );
				appendMessage( msg );
			}
		}
	}

	public void addFileItem( final FileItem item )
	{
		fileQueue.add(item);

		MimeMessage msg = new MimeMessage();
		msg.setMessage( Msg.get("chatdlg.filerecv.notify",
			you.getFormattedFriendlyName(), item.getName()+"("+item.getKBSize()+")") );
		appendMessage( msg );

		if( Boolean.getBoolean("jmsn.file.auto.accept") )
			acceptFileRequest();
	}

	private void createKeyMap()
	{
		JPanel panel = (JPanel)getContentPane();
		ComponentInputMap im = new ComponentInputMap(panel);
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_T, InputEvent.ALT_MASK), "FileAccept" );
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_T, InputEvent.CTRL_MASK), "FileAccept" );
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_D, InputEvent.ALT_MASK), "FileReject" );
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_D, InputEvent.CTRL_MASK), "FileReject" );

		ActionMap am = panel.getActionMap();
		am.put( "FileAccept", new AbstractAction() {
			public void actionPerformed( ActionEvent e )
			{
				acceptFileRequest();
			}
		});
		am.put( "FileReject", new AbstractAction() {
			public void actionPerformed( ActionEvent e )
			{
				if( fileQueue.size()==0 )
					return;

				FileItem item = (FileItem)fileQueue.remove(0);
				SwitchboardSession ss = item.getSession();
				try {
					ss.rejectFileReceive( item.getCookie() );
				} catch( IOException ex ) { ex.printStackTrace(); }

				MimeMessage msg = new MimeMessage();
				msg.setMessage( Msg.get("chatdlg.filerecv.reject") );
				appendMessage( msg );
			}
		});
		panel.setInputMap( JComponent.WHEN_IN_FOCUSED_WINDOW, im );

		addKeyListener( new KeyAdapter() {
			public void keyPressed( KeyEvent e )
			{
				if( e.getKeyCode()==KeyEvent.VK_ESCAPE )
					dispose();
			}
		});
	}

	private class DialogStatus extends ComponentAdapter
	{
		/*
		public void componentShown( ComponentEvent e )
		{
			inputArea.requestFocus();
			ChatDialog.this.show();
		}
		*/

		public void componentResized( ComponentEvent e )
		{
			chatPane.getViewport().scrollRectToVisible( 
				new Rectangle(0, chatArea.getSize().height, 100, 100) );
		}
	}

	private void acceptFileRequest()
	{
		if( fileQueue.size()==0 )
			return;

		FileItem item = (FileItem)fileQueue.remove(0);
		SwitchboardSession ss = item.getSession();
		LocalCopy local = msnm.getLocalCopy();
		FileProgress prog = new FileProgress(this);
		try
		{
			File file = new File(
				local.getProperty(MainFrame.DOWNLOAD_PROP),
				item.getName() );
			fileCookieMap.put( String.valueOf(item.getCookie()), prog );
			ss.acceptFileReceive( item.getCookie(), file );

		}
		catch( IOException ex ) { ex.printStackTrace(); }

		topPanel.add( prog );
		topPanel.doLayout();
		topPanel.validate();
	}

	public void sessionClosed()
	{
		this.session = null;
		isSessionClose = true;
	}

	public void userOffline()
	{
		if( you==null ) return;
		MimeMessage msg = new MimeMessage();
		msg.setMessage( Msg.get("chatdlg.msg.offline", you.getLoginName()) );
		appendMessage( msg );

		filesendButton.setEnabled( false );
		inputArea.setEnabled( false );
		//chatArea.requestFocus();
	}

	public void setMyPhoto( Image img )
	{
		if( img==null )
		{
			photoMe.setIcon( null );
			bottomPanel.remove( photoMe );
			bottomPanel.doLayout();
			bottomPanel.validate();
		}
		else
		{
			photoMe.setIcon( new ImageIcon(img) );
			bottomPanel.add( photoMe, "East" );
			bottomPanel.doLayout();
			bottomPanel.validate();
		}
	}

	public void setFriendPhoto( Image img )
	{
		boolean isShow = 
			MainFrame.LOCALCOPY.getPropertyBoolean(MainFrame.PHOTO_PROP_SHOW, true);

		if( !isShow || img==null )
		{
			photoYou.setIcon( null );
			mainPanel.remove( photoPanel );
			mainPanel.doLayout();
			mainPanel.validate();
		}
		else
		{
			photoYou.setIcon( new ImageIcon(img) );
			mainPanel.add( photoPanel, "East" );
			mainPanel.doLayout();
			mainPanel.validate();
		}
	}

	private void createComponents()
	{
		setSize( 380, 370 );

		JPanel panel = (JPanel)getContentPane();

		chatArea = new ChatArea() {
			public void acceptFiles( List list )
			{
				for(Iterator i=list.iterator(); i.hasNext(); )
					sendFileImpl( (File)i.next() );
			}
		    public void inviteFriend( String loginName )
			{
				if( session!=null )
				{
					try
					{
						session.inviteFriend( loginName );

						MimeMessage msg = new MimeMessage();
						msg.setMessage( Msg.get("chatdlg.msg.invite", loginName) );
						appendMessage( msg );
					}
					catch( IOException e ) {}
				}
			}
		};

		chatArea.setFont( FONT_10 );
		chatArea.append( Msg.get("chatdlg.msg.top") );

		JPanel propertyPane = new JPanel();
		propertyPane.setLayout(new FlowLayout(FlowLayout.LEFT, 5, 2));

		JButton fontButton = new JButton( Msg.get("label.font"));
		fontButton.setFont( FONT );
		fontButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				showFontDialog();
			}
		});

		photoMe = new JLabel();
		photoMe.setPreferredSize(new Dimension(98,98));
		photoMe.setBorder( BorderFactory.createLineBorder(Color.black,1) );

		photoYou = new JLabel();
		photoYou.setPreferredSize(new Dimension(98,98));
		photoYou.setBorder( BorderFactory.createLineBorder(Color.black,1) );

		photoPanel = new JPanel(new BorderLayout());
		photoPanel.add( new JPanel(), "Center" );
		photoPanel.add( photoYou, "North" );

		propertyPane.add(fontButton);

		inputArea = new JTextArea();
		inputArea.setFont( FONT_10 );
		inputArea.setLineWrap( true );

		statusLabel = new JLabel("");
		statusLabel.setFont( FONT_10 );
		statusLabel.setPreferredSize( new Dimension(100, 24) );
		
		chatPane = new JScrollPane( chatArea);
		inputPane = new JScrollPane( inputArea );
		inputPane.setPreferredSize( new Dimension(100, 50) );


		bottomPanel = new JPanel(new BorderLayout());

		JPanel southPanel = new JPanel(new BorderLayout());
		southPanel.add( propertyPane, "North");
		southPanel.add( inputPane, "Center" );
		southPanel.add( statusLabel, "South" );

		bottomPanel.add( southPanel, "Center" );

		topPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 4, 4));
		topPanel.setPreferredSize( new Dimension(100,38) );
		topPanel.setBorder( BorderFactory.createEtchedBorder() );

		filesendButton = new JButton(Msg.get("button.file.send"));
		filesendButton.setFont( FONT );
		filesendButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				prepareSendFile();
			}
		});
		topPanel.add( filesendButton );

		mainPanel = new JPanel(new BorderLayout());
		mainPanel.add( chatPane, "Center" );

		panel.add( topPanel, "North" );
		panel.add( mainPanel, "Center" );
		panel.add( bottomPanel, "South" );

		InputMap im = inputArea.getInputMap();
		ActionMap am = inputArea.getActionMap();

		AbstractAction newlineAction = new AbstractAction()
		{
			public void actionPerformed( ActionEvent e )
			{
				inputArea.append("\n");
			}
		};

		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_ENTER, InputEvent.CTRL_MASK), "newline" );
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_ENTER, InputEvent.SHIFT_MASK), "newline" );
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_ENTER, 0), "send" );
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_ESCAPE, 0), "dispose" );
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_A, InputEvent.ALT_MASK), "TopMost" );
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_UP, 0), "HistoryUp" );
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_NUMPAD8, 0), "HistoryUp" );
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_DOWN, 0), "HistoryDown" );
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_NUMPAD2, 0), "HistoryDown" );

		am.put( "newline", newlineAction );
		am.put( "send", new AbstractAction() {
			public void actionPerformed( ActionEvent e )
			{
				sendMessage();
			}
		});
		am.put( "dispose", new AbstractAction() {
			public void actionPerformed( ActionEvent e )
			{
				dispose();
			}
		});
		am.put( "TopMost", new AbstractAction() {
			boolean isTopMost = false;
			public void actionPerformed( ActionEvent e )
			{
				NativeToolkit tk = NativeToolkit.getInstance();
				tk.makeTopMost( ChatDialog.this, !isTopMost );
				isTopMost = !isTopMost;
			}
		});
		am.put( "HistoryUp", new AbstractAction() {
			public void actionPerformed( ActionEvent e )
			{
				if( historyIndex==-1 )
					return;

				historyIndex--;
				if( historyIndex<0 )
					historyIndex = 0;

				inputArea.setText( (String)historyQueue.get(historyIndex) );
			}
		});
		am.put( "HistoryDown", new AbstractAction() {
			public void actionPerformed( ActionEvent e )
			{
				if( historyIndex==-1 )
					return;

				historyIndex++;
				if( historyIndex >= historyQueue.size() )
					historyIndex = historyQueue.size()-1;

				inputArea.setText( (String)historyQueue.get(historyIndex) );
			}
		});

		LocalCopy local = MainFrame.LOCALCOPY;
		boolean isUse = local.getPropertyBoolean( MainFrame.PHOTO_PROP_USE, false );
		if( isUse )
		{
			setMyPhoto( msnm.getMyPhoto() );
		}
		if( you!=null && you.getPhoto()!=null )
		{
			setFriendPhoto(you.getPhoto());
		}
	}

	public void appendMessage( MimeMessage msg )
	{
		Appender appender = new Appender();
		appender.setAlert( true );
		appender.setMessage( msg );

		if( log!=null )
			log.println( msg.getMessage() );

		if( !SwingUtilities.isEventDispatchThread() )
			SwingUtilities.invokeLater( appender );
		else
			appender.run();
	}

	public void appendMessage( MsnFriend friend, MimeMessage msg )
	{
		Appender appender = new Appender();
		appender.setAlert( false );
		appender.setFriend( friend );
		appender.setMessage( msg );

		if( friend!=me )
			this.lastMessagingTime = System.currentTimeMillis();

		if( log!=null )
			log.println( friend, msg.getMessage() );

		if( !SwingUtilities.isEventDispatchThread() )
			SwingUtilities.invokeLater( appender );
		else
			appender.run();
	}

	protected void showFontDialog()
	{
		FontDialog fd = new FontDialog(this);
		fd.setVisible(true);
	}

	protected void prepareSendFile()
	{
		if( isSessionClose )
		{
			isSessionClose = false;
			try {
				if( msnm.findSwitchboardSession(you.getLoginName())==null )
					msnm.doCall( you.getLoginName() );
			} catch( IOException e ) {}
		}

		String downdir = msnm.getLocalCopy().getProperty(MainFrame.DOWNLOAD_PROP);
		JFileChooser file = new JFileChooser(downdir);
		if( System.getProperty("os.name").equals("Mac OS X") )
		{
			FileView fv = new FileView() {
				public String getName( File f )
				{
					return HangulJamoUtil.getString(f.getName());
				}
			};
			file.setFileView(fv);
		}
		file.setMultiSelectionEnabled( true );
		file.setFileSelectionMode( JFileChooser.FILES_AND_DIRECTORIES );
		if( file.showOpenDialog( this )==JFileChooser.APPROVE_OPTION )
		{
			File[] fs = file.getSelectedFiles();
		    for(int i=0; i<fs.length; i++)
			{
				sendFileImpl( fs[i] );
			}
		}
	}

	/**
	 * 해당 파일을 전송한다, 단 요청한 파일이 디렉토리라면 압축을 할 것인지
	 * 한번 사용자에게 물은 뒤, 디렉토리명.zip 으로 압축하여 전송한다.
	 * <p>
	 * 해당 파일은 시스템 temp directory에 생성되며, 파일 전송이 종료되거나,
	 * 오류로 중단되면, 삭제되어야 한다.
	 *
	 * @param f
	 */
	protected void sendFileImpl( File f )
	{
		if( f.isDirectory() )
		{
			if( JOptionPane.showConfirmDialog( this, Msg.get("chatdlg.query.dirsend.content", f.getName()),
				Msg.get("chatdlg.query.dirsend.title"), JOptionPane.YES_NO_OPTION, JOptionPane.QUESTION_MESSAGE )
				==JOptionPane.NO_OPTION )
				return;
			ZippedDirectoryDialog zd = new ZippedDirectoryDialog(this, f);
			zd.setVisible(true);
			f = zd.getZippedFile();
			f.deleteOnExit();
		}

		if( System.getProperty("os.name").equals("Mac OS X") )
		{
			final String orgName = f.getName();
			f = new File(f.getAbsolutePath()) {
				public String getName() {
					return HangulJamoUtil.getString(orgName);
				}};
		}

		MimeMessage msg = new MimeMessage();
		if( session!=null )
		{
			try {
				msnm.sendFileRequest( you.getLoginName(), f, session );
				msg.setMessage( Msg.get("chatdlg.filesend.request.ok", you.getLoginName(), f.getName()) );
			}
			catch( IOException e )
			{
				msg.setMessage( Msg.get("chatdlg.filesend.request.fail") );
			}
			appendMessage( msg );
		}
		else
		{
			msg.setMessage( Msg.get("chatdlg.filesend.request.fail") );
			appendMessage( msg );
		}
	}

	/**
	 * 단순히 메시지 창에 글을 추가하는 역할을 한다.
	 */
	private class Appender implements Runnable
	{
		boolean alert = false;
		MsnFriend friend;
		MimeMessage msg;
		JViewport view;
		Rectangle rect = new Rectangle();

		public Appender()
		{
			view = chatPane.getViewport();
			rect.x = 0;
			rect.width = 1;
			rect.height = 300;
		}

		public void setAlert( boolean isAlert )
		{
			this.alert = isAlert;
		}

		public void setFriend( MsnFriend friend )
		{
			this.friend = friend;
		}

		public void setMessage( MimeMessage msg )
		{
			this.msg = msg;
		}

		public void run()
		{
			Color co;
			String ef = "";
			String fn = "굴림체";
			try
            {
				Properties p = msg.getProperties();

				String fm = p.getProperty("X-MMS-IM-Format");
				if( fm!=null )
                {
					int si = fm.indexOf("CO");
					int ei = fm.indexOf(";",si);
					String c = fm.substring(si+3,ei);
					if(c.length() < 6)
					{
						StringBuffer sb = new StringBuffer(6);
						for(int i=0, len=6-c.length(); i<len; i++)
							sb.append('0');
						c = sb.toString() + c;
					}
					int r = Integer.parseInt(c.substring(4,6),16);
					int g = Integer.parseInt(c.substring(2,4),16);
					int b = Integer.parseInt(c.substring(0,2),16);
					co = new Color(r, g, b);
					si = fm.indexOf("EF");
					ei = fm.indexOf(";",si);
					ef = fm.substring(si+3,ei);

					si = fm.indexOf("FN");
					ei = fm.indexOf(";",si);

					fn = MimeUtility.getURLDecodedString(fm.substring(si+3,ei), "UTF-8");
				}
                else
                {
					co = msg.getFontColor();
					ef = msg.getEffectCode();
					fn = msg.getFontName();
				}
			}
            catch(Exception eex)
            {
				co = msg.getFontColor();
				ef = msg.getEffectCode();
				fn = msg.getFontName();
			}

            StringBuffer sb = new StringBuffer(50);
            if( isViewTimestamp )
            {
                sb.append( ts.format(new Date()) );
                sb.append( ' ' );
            }

			if( alert )
			{
                sb.append( msg.getMessage() );
                sb.append( '\n' );
				chatArea.append( sb.toString() );
				if( getFocusOwner()==null )
					MusicBox.play( MusicBox.SOUND_MESSAGE_1 );
			}
			else
			{
                sb.append( Msg.get("chatdlg.chat", friend.getFormattedFriendlyName()) );
				chatArea.append( sb.toString() );

				if(useFixedFont){
        				LocalCopy local = MainFrame.LOCALCOPY;
					fn = local.getProperty("font.name");
					if(fn==null)
						fn="굴림체";
			
					int red = 0;
					int green = 0;
					int blue = 0;
					try
				        {
						red = Integer.parseInt(local.getProperty("font.red") );
						green = Integer.parseInt(local.getProperty("font.green") );
						blue = Integer.parseInt(local.getProperty("font.blue") );
					}
				        catch( NumberFormatException e )
				    	{
						 red = green = blue = 0;
				        }
	
				        // Use the getPropertyBoolean method, :)
					StringBuffer ef2 = new StringBuffer();
				        boolean b = local.getPropertyBoolean("font.isBold", false);
				        boolean i = local.getPropertyBoolean("font.isItalic", false);
				        boolean s = local.getPropertyBoolean("font.isStrikeThrough", false);
				        boolean u = local.getPropertyBoolean("font.isUnderline", false);
				        boolean ir = local.getPropertyBoolean("font.israndomcolor", true);

					if(b) ef2.append("B");
					if(i) ef2.append("I");
					if(s) ef2.append("S");
					if(u) ef2.append("U");

					chatArea.append( msg.getMessage() + "\n" ,msg.getFontColor() ,ef2.toString() ,fn);
				}
				else
					chatArea.append( msg.getMessage() + "\n" ,co ,ef ,fn);
					
				if( getFocusOwner()==null && friend!=me )
					MusicBox.play( MusicBox.SOUND_MESSAGE_2 );
			}

			rect.y = chatArea.getSize().height;
			view.scrollRectToVisible( rect );
			statusLabel.setText( "" );
		}
	}

	protected void sendMessage()
	{
		String input = inputArea.getText();
		if( input.trim().length()==0 )
			return;
		inputArea.setText( "" );

		if( me.getStatus().equals(UserStatus.INVISIBLE) )
		{
			inputArea.setText( Msg.get("chatdlg.msg.notsend.offline") );
			filesendButton.setEnabled( false );
			inputArea.setEnabled( false );
			return;
		}

		MimeMessage msg = new MimeMessage(input);
		msg.setKind( MimeMessage.KIND_MESSAGE );

        LocalCopy local = MainFrame.LOCALCOPY;
		String fn = local.getProperty("font.name");
		if(fn==null)
			fn="굴림체";

		int red = 0;
		int green = 0;
		int blue = 0;
		try
        {
			red = Integer.parseInt(local.getProperty("font.red") );
			green = Integer.parseInt(local.getProperty("font.green") );
			blue = Integer.parseInt(local.getProperty("font.blue") );
		}
        catch( NumberFormatException e )
        {
            red = green = blue = 0;
        }

        // Use the getPropertyBoolean method, :)
		StringBuffer ef = new StringBuffer();
        boolean b = local.getPropertyBoolean("font.isBold", false);
        boolean i = local.getPropertyBoolean("font.isItalic", false);
        boolean s = local.getPropertyBoolean("font.isStrikeThrough", false);
        boolean u = local.getPropertyBoolean("font.isUnderline", false);
        boolean ir = local.getPropertyBoolean("font.israndomcolor", true);

		if(b) ef.append("B");
		if(i) ef.append("I");
		if(s) ef.append("S");
		if(u) ef.append("U");

		msg.setFontName(fn);
		if(!ir) 
			msg.setFontColor(new Color(red, green, blue) );
		msg.setEffectCode(ef.toString());

		appendMessage( this.me, msg ); 

		historyQueue.add( input );
		if( historyQueue.size() > 50 )
			historyQueue.remove(0);
		historyIndex = historyQueue.size();

		try
		{
			if( session!=null )
				session.sendInstantMessage( msg );
			else
			{
				queue.add( msg );
				if( isSessionClose )
				{
					isSessionClose = false;
					msnm.doCall( you.getLoginName() );
				}
			}
		}
		catch( java.io.IOException e )
		{
			e.printStackTrace();
		}
	}
	
	public void addWindowListener( WindowListener wl )
	{
		super.addWindowListener( wl );
		this.wl = wl;
	}

	public void dispose()
	{
		chatArea.dispose();
		chatArea = null;
		if( topPanel.getComponentCount()>1 )
		{
			JOptionPane.showMessageDialog(this,
				Msg.get("chatdlg.msg.transfer.4eva"),
				Msg.get("title.alarm"), JOptionPane.INFORMATION_MESSAGE );
		}

		if( log!=null )
			log.close();

		wl.windowClosing(
			new WindowEvent(this, WindowEvent.WINDOW_CLOSING) );
		msnm.removeMsnListener( fileAdapter );
		super.dispose();
		System.gc();
	}

	public void close()
	{
		try
		{
			if( session!=null )
			{
				session.close();
				session = null;
			}
		}
		catch( Exception e )
		{
			System.err.println( e );
		}
	}

	public void setSession( SwitchboardSession session )
	{
		if( this.session!=null )
		{
			if( !this.session.getSessionId().equals(session.getSessionId()) )
			{
				try
				{
					this.session.close();
				}
				catch( IOException e ) {}
			}
		}
		this.session = session;
		this.you = session.getMsnFriend();
		this.lastMessagingTime = System.currentTimeMillis();

		if( you.getPhoto()!=null )
		{
			SwingUtilities.invokeLater( new Runnable() {
				public void run()
				{
					setFriendPhoto(you.getPhoto());
				}
			});
		}

		prepareLogWriter( you.getLoginName() );

		MimeMessage mm = new MimeMessage();
		mm.setMessage( Msg.get("chatdlg.chat.opened") );
		appendMessage( mm );

		synchronized( queue )
		{
			if( queue.size()!=0 )
			{
				for(Iterator i=queue.iterator(); i.hasNext(); )
				{
					MimeMessage msg = (MimeMessage)i.next();
					try {
						session.sendInstantMessage( msg );
					}
					catch( IOException e )
					{
						msg.setMessage( Msg.get("chatdlg.chat.error", msg.getMessage()) );
						appendMessage( msg );
					}
					finally
					{
						i.remove();
					}
				}
			}
		}
	}

	public SwitchboardSession getSession()
	{
		return this.session;
	}

	/**
	 * 현재 대화 세션이 시작된 시간을 반환한다. CPU Time이다.
	 */
	public long getLastMessagingTime()
	{
		return this.lastMessagingTime;
	}

	public void whoTyping( final String userview )
	{
		SwingUtilities.invokeLater( new Runnable() {
			public void run()
			{
				statusLabel.setText( Msg.get("chatdlg.msg.typing", userview, sdf.format(new Date())) );
			}
		});
	}

	public void setVisible( boolean show )
	{
		if( show )
		{
			rath.jmsn.NativeToolkit.getInstance().makeTransparency(this,
				Integer.getInteger("jmsn.transparency", -1).intValue());
			super.setVisible( show );
			rath.jmsn.NativeToolkit.getInstance().makeTransparency(this,
				Integer.getInteger("jmsn.transparency", -1).intValue());
		}
		else
			super.setVisible( show );
	}
}
