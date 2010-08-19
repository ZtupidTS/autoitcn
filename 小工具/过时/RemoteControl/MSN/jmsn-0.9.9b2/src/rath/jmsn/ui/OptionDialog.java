/*
 * @(#)OtionDialog.java
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
 *    $Id: OptionDialog.java,v 1.13 2004/08/04 07:05:49 xrath Exp $
 */
package rath.jmsn.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;
import javax.swing.filechooser.*;

import java.io.File;
import java.io.IOException;

import rath.msnm.MSNMessenger;
import rath.msnm.LocalCopy;
import rath.msnm.entity.MsnFriend;
import rath.msnm.PhotoFormatter;

import rath.jmsn.ToolBox;
import rath.jmsn.MainFrame;
import rath.jmsn.NativeToolkit;
import rath.jmsn.util.MusicBox;
import rath.jmsn.util.Msg;
import rath.jmsn.util.AutoNickChangeServer;
/**
 * Option dialog.
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: OptionDialog.java,v 1.13 2004/08/04 07:05:49 xrath Exp $
 */
public class OptionDialog extends DefaultDialog implements ToolBox
{
	private JTextField nickField = null;
	private JTextField downField = null;
	private JTextField chatlogField = null;

	private JTextField bgImageField = null;

	private JButton findButton0, findButton1, findButton2;
	private JButton colorButton = null;
	private JCheckBox loginCheck = null;
	private JCheckBox messageCheck = null;
	private JCheckBox fileAutoAcceptCheck = null;

    private JCheckBox tstampCheck = null;
	private JCheckBox emoticonCheck = null;
	private JCheckBox fixedFontFaceCheck = null;

	private JCheckBox photoShowMe = null;
	private JCheckBox photoShowOther = null;
	private JTextField photoPath = null;
	private JButton photoChoose = null;
	private JLabel photoView = null;
	private Image photo;

	private MSNMessenger msnm = null;
	private String initFriendlyName = null;

	private JTextField autoPrefixNickField = null;
	private JTextField autoPostfixNickField = null;
	private JTextField autoNickPassField = null;
	private JButton anStartButton = null;
	private JButton anStopButton = null;

	public OptionDialog( Frame owner, MSNMessenger msnm )
	{
		super( owner );

		this.msnm = msnm;

		setTitle( Msg.get("title.option") );
		createUI();
	}

	private void createUI()
	{
		setSize( 400, 360 );

		JPanel panel = (JPanel)getContentPane();

		JTabbedPane pane = new JTabbedPane();
		pane.setBorder( BorderFactory.createEmptyBorder(5,5,5,5) );

		pane.add( createGeneralTab(), "General" );
		pane.add( createMediaTab(), "Graphics" );
		pane.add( createPhotoTab(), "Photo" );
		pane.add( createAutoNickTab(), "Auto Nickname" );

		panel.add( pane, "Center" );
		panel.add( createBottomPanel(), "South" );
	}

	public void useImage()
	{
		String path = photoPath.getText();
		PhotoFormatter pf = new PhotoFormatter();					
		try
		{
			photoView.setIcon( new ImageIcon(pf.resize(new File(path))) );
		}
		catch( IOException ex ) {}
	}

	private JPanel createPhotoTab()
	{
		JPanel panel = new JPanel(new BorderLayout(5,5));
		panel.setBorder( BorderFactory.createEmptyBorder(10,10,10,10) );

		JPanel top = new JPanel();
		top.setLayout( new BoxLayout(top, BoxLayout.Y_AXIS) );

		JLabel l0 = new JLabel(Msg.get("label.photo.title"));
		l0.setFont( FONT );
		top.add( l0 );
		top.add( createDummyPanel(5) );

		photoPath = new JTextField();
		photoPath.setEditable(false);
		photoPath.setFont( FONT );

		photoChoose = new JButton(Msg.get("button.find"));
		photoChoose.setFont( FONT );
		photoChoose.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				File dir = selectFile( photoPath.getText(), new FileFilter() {
				    public boolean accept( File f )
					{
						if( f.isDirectory() ) return true;
						String name = f.getName().toLowerCase();
						if( name.endsWith(".gif") || name.endsWith(".jpg") ||
							name.endsWith(".png") )
							return true;
						return false;
					}
					public String getDescription()
					{
					    return "Image Files (*.gif, *.jpg, *.png)";
					}
				});
				if( dir!=null )
				{
					String path = dir.getAbsolutePath();
					photoPath.setText( path );
					photoShowMe.setSelected( true );
					useImage();
				}
			}
		});

		JPanel p0 = new JPanel(new BorderLayout(4, 4));
		p0.add( photoPath, "Center" );
		p0.add( photoChoose, "East" );
		p0.setMaximumSize( new Dimension(Short.MAX_VALUE, 24) );
		p0.setAlignmentX( 0.0f );

		top.add( p0 );
		top.add( createDummyPanel(8) );

		JPanel center = new JPanel();
		center.setLayout( new BoxLayout(center, BoxLayout.Y_AXIS) );

		photoShowMe = new JCheckBox(Msg.get("label.photo.show.me"));
		photoShowMe.setFont( FONT );
		photoShowMe.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				if( !photoShowMe.isSelected() )
				{
					photoView.setIcon( null );
				}
				else
				{
					useImage();
				}
			}
		});
		photoShowOther = new JCheckBox(Msg.get("label.photo.show.other"));
		photoShowOther.setFont( FONT );

		center.add( photoShowMe );
		center.add( photoShowOther );

		photoView = new JLabel();
		photoView.setPreferredSize(new Dimension(98, 98));
		photoView.setBackground( Color.white );
		photoView.setBorder( BorderFactory.createLineBorder(Color.black,1) );

		JPanel east = new JPanel(new BorderLayout());
		east.add( photoView, "North" );
		east.add( new JPanel(), "Center" );

		panel.add( top, "North" );
		panel.add( center, "Center" );
		panel.add( east, "East" );

		return panel;
	}

	private JPanel createGeneralTab()
	{
		JPanel panel = new JPanel();
		BoxLayout layout = new BoxLayout(panel, BoxLayout.Y_AXIS);
		panel.setBorder( BorderFactory.createEmptyBorder(10,10,10,10) );
		panel.setLayout( layout );

		/* Change the nickname */
		JPanel nickPanel = new JPanel(new BorderLayout(5,5));
		nickPanel.setMaximumSize( new Dimension(Short.MAX_VALUE, 24) );
		nickPanel.setAlignmentX( 0.0f );
		JLabel nickLabel = new JLabel( Msg.get("label.friendlyname") );
		nickLabel.setFont( FONT );
		nickField = new JTextField();
		nickField.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				processConfirm();
			}
		});
		nickField.setFont( FONT );
		nickPanel.add( nickLabel, "West" );
		nickPanel.add( nickField, "Center" );
		panel.add( nickPanel );

		panel.add( createDummyPanel(5) );

		/* Toggle who logined sound effect */
		loginCheck = new JCheckBox(Msg.get("label.sound.login"));
		loginCheck.setFont( FONT );
		/* Toggle whose message received sound effect */
		messageCheck = new JCheckBox(Msg.get("label.sound.msg"));
		messageCheck.setFont( FONT );
		/* Toggle File Auto Accept */
		fileAutoAcceptCheck = new JCheckBox(Msg.get("label.file.auto.accept"));
		fileAutoAcceptCheck.setFont( FONT );

		panel.add( loginCheck );
		panel.add( messageCheck );
		panel.add( fileAutoAcceptCheck );

		panel.add( createDummyPanel(24) );

		JLabel downLabel = new JLabel( Msg.get("label.folder.download") );
		downLabel.setFont( FONT );
		panel.add( downLabel );

		JPanel downPanel = new JPanel(new BorderLayout(5,5));
		downPanel.setAlignmentX( 0.0f );
		downPanel.setMaximumSize( new Dimension(Short.MAX_VALUE,24) );
		downField = new JTextField();
		downField.setEditable( false );
		downField.setFont( FONT );
		findButton0 = new JButton( Msg.get("button.find") );
		findButton0.setFont( FONT );
		findButton0.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				File dir = selectDirectory( downField.getText() );
				if( dir!=null )
					downField.setText( dir.getAbsolutePath() );
			}
		});
		downPanel.add( downField, "Center" );
		downPanel.add( findButton0, "East" );
		panel.add( downPanel );

		panel.add( createDummyPanel(5) );

		JLabel logLabel = new JLabel( Msg.get("label.folder.chatlog") );
		logLabel.setFont( FONT );
		panel.add( logLabel );

		JPanel logPanel = new JPanel(new BorderLayout(5,5));
		logPanel.setAlignmentX( 0.0f );
		logPanel.setMaximumSize( new Dimension(Short.MAX_VALUE,24) );
		chatlogField = new JTextField();
		chatlogField.setEditable( false );
		chatlogField.setFont( FONT );
		findButton1 = new JButton( Msg.get("button.find") );
		findButton1.setFont( FONT );
		findButton1.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				File dir = selectDirectory( chatlogField.getText() );
				if( dir!=null )
					chatlogField.setText( dir.getAbsolutePath() );
			}
		});
		logPanel.add( chatlogField, "Center" );
		logPanel.add( findButton1, "East" );
		panel.add( logPanel );

		return panel;
	}

	private JPanel createMediaTab()
	{
		JPanel panel = new JPanel();
		BoxLayout layout = new BoxLayout(panel, BoxLayout.Y_AXIS);
		panel.setBorder( BorderFactory.createEmptyBorder(10,10,10,10) );
		panel.setLayout( layout );

		JLabel bgImgLabel = new JLabel( Msg.get("label.buddy.backimg") );
		bgImgLabel.setFont( FONT );
		panel.add( bgImgLabel );
		panel.add( createDummyPanel(5) );

		JPanel bgImgPanel = new JPanel(new BorderLayout(5,5));
		bgImgPanel.setAlignmentX( 0.0f );
		bgImgPanel.setMaximumSize( new Dimension(Short.MAX_VALUE,24) );
		bgImageField = new JTextField();
		bgImageField.setFont( FONT );
		findButton2 = new JButton( Msg.get("button.find") );
		findButton2.setFont( FONT );
		findButton2.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				File dir = selectFile( bgImageField.getText(), new FileFilter() {
				    public boolean accept( File f )
					{
						if( f.isDirectory() ) return true;
						String name = f.getName().toLowerCase();
						if( name.endsWith(".gif") || name.endsWith(".jpg") )
							return true;
						return false;
					}
					public String getDescription()
					{
					    return "JPEG, GIF Files (*.gif, *.jpg)";
					}
				});
				if( dir!=null )
					bgImageField.setText( dir.getAbsolutePath() );
			}
		});
		bgImgPanel.add( bgImageField, "Center" );
		bgImgPanel.add( findButton2, "East" );
		panel.add( bgImgPanel );
	
		panel.add( createDummyPanel(4) );

		JPanel buddyFontPanel = new JPanel(new FlowLayout(FlowLayout.LEFT,10,2));
		buddyFontPanel.setAlignmentX( 0.0f );
		buddyFontPanel.setMaximumSize( new Dimension(Short.MAX_VALUE,24) );
		JLabel l0 = new JLabel( Msg.get("label.chooselistfont.color") );
		l0.setFont( FONT );
		colorButton = new JButton("");
		colorButton.setOpaque(true);
		colorButton.setBorder( BorderFactory.createLineBorder(Color.black,1) );
		colorButton.setPreferredSize(new Dimension(45,18));
		colorButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				Color c = JColorChooser.showDialog( OptionDialog.this, Msg.get("label.chooselistfont.color"), colorButton.getBackground() );
				colorButton.setBackground( c );
			}
		});
		buddyFontPanel.add( l0, "Center" );
		buddyFontPanel.add( colorButton, "East" );
		panel.add( buddyFontPanel );

		final NativeToolkit tk = NativeToolkit.getInstance();
		if( tk.isWin2k )
		{
		    panel.add( createDummyPanel(10) );
			JLabel l1 = new JLabel( Msg.get("label.transparent.level") );
			l1.setFont( FONT );
			panel.add( l1 );

			JPanel sliderPanel = new JPanel(new BorderLayout(5,5));
			sliderPanel.setAlignmentX(0.0f);
			sliderPanel.setMaximumSize( new Dimension(Short.MAX_VALUE, 30) );

			final JSlider slider = new JSlider(30, 255);
			slider.setFont( FONT );
			int value = Integer.parseInt(System.getProperty("jmsn.transparency", "255"));
			if( value!=-1 )
				slider.setValue( value );
			else
				slider.setEnabled( false );
		    slider.addChangeListener( new ChangeListener() {
				public void stateChanged( ChangeEvent e )
				{
					int value = slider.getValue();
				    tk.makeTransparency( MainFrame.INSTANCE, value );
				    tk.makeTransparency( OptionDialog.this, value );
					System.setProperty( "jmsn.transparency", String.valueOf(value) );
				}
			});

			final JCheckBox check = new JCheckBox( Msg.get("checkbox.use") );
			check.setFont( FONT );
			check.setSelected( value!=-1 ? true : false );
			check.addActionListener( new ActionListener() {
				public void actionPerformed( ActionEvent e )
				{
					boolean sel = check.isSelected();
					if( sel )
						slider.setValue( slider.getValue() );
					else
					{
						tk.makeTransparency( MainFrame.INSTANCE, -1 );
						tk.makeTransparency( OptionDialog.this, -1 );
						System.setProperty( "jmsn.transparency", "-1" );
					}
					slider.setEnabled( sel );
				}
			});

			sliderPanel.add( slider, "Center" );
			sliderPanel.add( check, "East" );
			panel.add( sliderPanel );
	    }
        panel.add( createDummyPanel(5) );

        // Timestamp property components creation.
        tstampCheck = new JCheckBox( Msg.get("label.timestamp") );
        tstampCheck.setFont( FONT );
        tstampCheck.setAlignmentX( 0.0f );
        tstampCheck.setMaximumSize( new Dimension(Short.MAX_VALUE,24) );
        panel.add( tstampCheck );

		// Toggle Emoticon display.
		emoticonCheck = new JCheckBox( Msg.get("label.emoticon.view") );
		emoticonCheck.setFont( FONT );
		emoticonCheck.setAlignmentX( 0.0f );
		emoticonCheck.setMaximumSize( new Dimension(Short.MAX_VALUE,24) );
		panel.add( emoticonCheck );

		fixedFontFaceCheck = new JCheckBox( Msg.get("label.use.fixed.font") );
		fixedFontFaceCheck.setFont( FONT );
		fixedFontFaceCheck.setAlignmentX( 0.0f );
		fixedFontFaceCheck.setMaximumSize( new Dimension(Short.MAX_VALUE, 24) );
		panel.add( fixedFontFaceCheck );

		return panel;
	}

	private JPanel createAutoNickTab()
	{
		JPanel panel = new JPanel();
		BoxLayout layout = new BoxLayout(panel, BoxLayout.Y_AXIS);
		panel.setBorder( BorderFactory.createEmptyBorder(10,10,10,10) );
		panel.setLayout( layout );
		
		JLabel l0 = new JLabel( "Enter your friendly name as a prefix and postfix" );
		l0.setFont( FONT );
		panel.add( l0 );


		JPanel p0 = new JPanel(new BorderLayout(5,5));
		p0.setAlignmentX( 0.0f );
		p0.setMaximumSize( new Dimension(Short.MAX_VALUE,24) );

		JLabel l1 = new JLabel( "Prefix" );
		l1.setFont( FONT );
		p0.add( l1, "West" );

		autoPrefixNickField = new JTextField();
		autoPrefixNickField.setFont( FONT );
		p0.add( autoPrefixNickField, "Center");		
		panel.add( p0 );

		panel.add( createDummyPanel(5) );

		JPanel p3 = new JPanel(new BorderLayout(5,5));
		p3.setAlignmentX( 0.0f );
		p3.setMaximumSize( new Dimension(Short.MAX_VALUE,24) );

		JLabel l3 = new JLabel( "Postfix" );
		l3.setFont( FONT );
		p3.add( l3, "West" );

		autoPostfixNickField = new JTextField();
		autoPostfixNickField.setFont( FONT );
		p3.add( autoPostfixNickField, "Center");		
		panel.add( p3 );

		panel.add( createDummyPanel(10) );


		JPanel p1 = new JPanel(new BorderLayout(5,5));
		p1.setAlignmentX( 0.0f );
		p1.setMaximumSize( new Dimension(Short.MAX_VALUE,24) );

		JLabel l2 = new JLabel( "Access Password" );
		l2.setFont( FONT );

		autoNickPassField = new JTextField("jmsn");
		autoNickPassField.setFont( FONT );

		p1.add( l2, "West" );
		p1.add( autoNickPassField, "Center" );

		panel.add( p1 );

		panel.add( createDummyPanel(12) );

		JPanel p2 = new JPanel(new FlowLayout(FlowLayout.RIGHT, 4, 4));
		p2.setAlignmentX( 0.0f );
		p2.setMaximumSize( new Dimension(Short.MAX_VALUE,32) );

		anStartButton = new JButton("Start");
		anStartButton.setFont( FONT );
		anStartButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{				
				try
				{
					AutoNickChangeServer.getInstance().start();

					anStopButton.setEnabled( true );
					anStartButton.setEnabled( false );
				}
				catch( Exception ex ) 
				{
					ex.printStackTrace();
				}
			}
		});
		anStopButton = new JButton("Stop");
		anStopButton.setFont( FONT );
		anStopButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				anStopButton.setEnabled( false );
				anStartButton.setEnabled( true );
				
				try
				{
					AutoNickChangeServer.getInstance().stop();
				}
				catch( Exception ex ) {}
			}
		});

		p2.add( anStartButton );
		p2.add( anStopButton );

		panel.add( p2 );

		return panel;
	}

	private JPanel createDummyPanel( int height )
	{
		JPanel d0 = new JPanel();
		d0.setAlignmentX( 0.0f );
		d0.setMaximumSize( new Dimension(Short.MAX_VALUE, height) );
		return d0;
	}

	private JPanel createBottomPanel()
	{
		JPanel bottomPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 10,4));
		JButton confirmButton = new JButton(Msg.get("button.ok"));
		confirmButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				processConfirm();
			}
		});
		confirmButton.setFont( FONT );
		JButton cancelButton = new JButton(Msg.get("button.cancel"));
		cancelButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				dispose();
			}
		});
		cancelButton.setFont( FONT );
		bottomPanel.add( confirmButton );
		bottomPanel.add( cancelButton );
		return bottomPanel;
	}

    /**
     * 사용자가 확인 버튼을 눌렀을때, 현재 설정한 정보들 중 영구보존해야 할 값들이 있다면
     * 이 메소드에서 모두 저장하게 된다.
     * 물론 로그인 되어있지 않다면 무시하고 그냥 dispose 될 것이다.
     */
	private void processConfirm()
	{
		if( !msnm.isLoggedIn() )
		{
			dispose();
			return;
		}

		File downDir = new File( downField.getText() );
		downDir.mkdirs();
		File logDir = new File( chatlogField.getText() );
		logDir.mkdirs();

		boolean sndLogin = loginCheck.isSelected();
		boolean sndMessage = messageCheck.isSelected();
		boolean autoAccept = fileAutoAcceptCheck.isSelected();
        boolean tstampView = tstampCheck.isSelected();
		boolean emoticonView = emoticonCheck.isSelected();
		boolean useFixedFont = fixedFontFaceCheck.isSelected();

		LocalCopy local = msnm.getLocalCopy();
		local.setProperty( MainFrame.DOWNLOAD_PROP, downDir.getAbsolutePath() );
		local.setProperty( MainFrame.CHATLOG_PROP, logDir.getAbsolutePath() );
		local.setProperty( MainFrame.BACKIMAGE_PROP, bgImageField.getText() );
		local.setProperty( MainFrame.SOUND_LOGIN_PROP+".enable", sndLogin );
		local.setProperty( MainFrame.SOUND_MESSAGE_PROP+".enable", sndMessage );
		local.setProperty( MainFrame.AUTO_ACCEPT_FILE_PROP, autoAccept );
        local.setProperty( MainFrame.TIMESTAMP_DISPLAY, tstampView );
		local.setProperty( MainFrame.EMOTICON_DISPLAY, emoticonView );
		local.setProperty( MainFrame.BUDDYLIST_FONT_COLOR,
			 String.valueOf(colorButton.getBackground().getRGB()) );
		local.setProperty( MainFrame.USE_FIXED_CHAT_FONT, useFixedFont );
		local.setProperty( MainFrame.AUTONICK + ".enable", !anStartButton.isEnabled() );
		local.setProperty( MainFrame.AUTONICK + ".prefix", autoPrefixNickField.getText() );
		local.setProperty( MainFrame.AUTONICK + ".postfix", autoPostfixNickField.getText() );
		local.setProperty( MainFrame.AUTONICK + ".password", autoNickPassField.getText() );		
		local.setProperty( MainFrame.PHOTO_PROP_USE, photoShowMe.isSelected() );
		local.setProperty( MainFrame.PHOTO_PROP_LOCATION, photoPath.getText() );
		local.setProperty( MainFrame.PHOTO_PROP_SHOW, photoShowOther.isSelected() );
		local.storeInformation();

		MusicBox.setEnabled( MusicBox.SOUND_LOGIN, sndLogin );
		MusicBox.setEnabled( MusicBox.SOUND_MESSAGE_1, sndMessage );
		MusicBox.setEnabled( MusicBox.SOUND_MESSAGE_2, sndMessage );
		System.setProperty( "jmsn.file.auto.accept", String.valueOf(autoAccept) );

		try
		{
			if( photoShowMe.isSelected() )
			{
				msnm.setMyPhoto( new File(photoPath.getText()) );
				MainFrame.INSTANCE.buddies.setMyPhoto( msnm.getMyPhoto() );
			}
			else
			{
				msnm.setMyPhoto( null );
				MainFrame.INSTANCE.buddies.setMyPhoto( null );
			}
		}
		catch( Exception e )
		{
			e.printStackTrace();
		}

		try
		{
			if( msnm!=null && msnm.isLoggedIn() &&
				!initFriendlyName.equals(nickField.getText()) )
				msnm.setMyFriendlyName( nickField.getText() );

			File file = new File(bgImageField.getText());
			if( file.exists() )
			{
				ImageIcon icon = new ImageIcon( file.getAbsolutePath() );
				MainFrame.INSTANCE.buddies.setBackgroundImage( icon.getImage() );
			}
			else
				MainFrame.INSTANCE.buddies.setBackgroundImage( null );
		}
		catch( IOException e ) {}

		MainFrame.INSTANCE.buddies.renderer.setForeColor( colorButton.getBackground() );
		MainFrame.INSTANCE.buddies.repaint();	
		dispose();
	}

	private File selectDirectory( String current )
	{
		JFileChooser file = new JFileChooser(current);
		file.setFileSelectionMode( JFileChooser.DIRECTORIES_ONLY );
		if( file.showOpenDialog(this)==JFileChooser.APPROVE_OPTION )
		{
			return file.getSelectedFile();
		}
		return null;
	}

	private File selectFile( String current, FileFilter filter )
	{
		JFileChooser file = new JFileChooser(current);
		file.addChoosableFileFilter( filter );
		file.setFileSelectionMode( JFileChooser.FILES_ONLY );
		if( file.showOpenDialog(this)==JFileChooser.APPROVE_OPTION )
		{
			return file.getSelectedFile();
		}
		return null;
	}

	/**
	 * Option Dialog가 생성될때 이전 설정값을 불러오는 등의 준비작업을 한다.
     * 대신 이러한 설정값들은 대부분 사용자별로 각각 저장되는 값이므로,
     * 사용자가 로그인되어있지 않다면, 대부분의 항목을 disable 상태로 만든다.
	 */
	private void processReady()
	{
		if( msnm.isLoggedIn() )
		{
			this.initFriendlyName = msnm.getOwner().getFormattedFriendlyName();
			nickField.setText( initFriendlyName );

			nickField.setEnabled( true );

			loginCheck.setEnabled( true );
			messageCheck.setEnabled( true );
			fileAutoAcceptCheck.setEnabled( true );

            tstampCheck.setEnabled( true );
			emoticonCheck.setEnabled( true );
			colorButton.setEnabled( true );
			fixedFontFaceCheck.setEnabled( true );

			findButton0.setEnabled( true );
			findButton1.setEnabled( true );
			findButton2.setEnabled( true );

			photoChoose.setEnabled( true );
			photoShowMe.setEnabled( true );
			photoShowOther.setEnabled( true );
		}
		else
		{
			nickField.setText( Msg.get("label.login.please") );
			nickField.setEnabled( false );

			loginCheck.setEnabled( false );
			messageCheck.setEnabled( false );
			fileAutoAcceptCheck.setEnabled( false );

            tstampCheck.setEnabled( false );
			emoticonCheck.setEnabled( false );
			colorButton.setEnabled( false );
			fixedFontFaceCheck.setEnabled( false );

			findButton0.setEnabled( false );
			findButton1.setEnabled( false );
			findButton2.setEnabled( false );

			photoChoose.setEnabled( false );
			photoShowMe.setEnabled( false );
			photoShowOther.setEnabled( false );
			return;
		}

		LocalCopy local = msnm.getLocalCopy();

		boolean loginEnable = local.getPropertyBoolean(
			MainFrame.SOUND_LOGIN_PROP + ".enable", true);
		boolean messageEnable = local.getPropertyBoolean(
			MainFrame.SOUND_MESSAGE_PROP + ".enable", true);
		boolean fileAutoAccept = local.getPropertyBoolean(
			MainFrame.AUTO_ACCEPT_FILE_PROP, false);
        boolean tstampEnable = local.getPropertyBoolean(
            MainFrame.TIMESTAMP_DISPLAY, false);
		boolean emoticonEnable = local.getPropertyBoolean(
			MainFrame.EMOTICON_DISPLAY, true);
		boolean fixedFontEnable = local.getPropertyBoolean(
			MainFrame.USE_FIXED_CHAT_FONT, false);
		boolean autoNickEnable = local.getPropertyBoolean(
			MainFrame.AUTONICK + ".enable", false );
		boolean photoUse = local.getPropertyBoolean(
			MainFrame.PHOTO_PROP_USE, false );
		boolean photoOther = local.getPropertyBoolean(
			MainFrame.PHOTO_PROP_SHOW, true );

		loginCheck.setSelected( loginEnable );
		messageCheck.setSelected( messageEnable );
		fileAutoAcceptCheck.setSelected( fileAutoAccept );
        tstampCheck.setSelected( tstampEnable );
		emoticonCheck.setSelected( emoticonEnable );
		fixedFontFaceCheck.setSelected( fixedFontEnable );

		photoShowMe.setSelected( photoUse );
		photoShowOther.setSelected( photoOther );
		photoPath.setText( local.getProperty(MainFrame.PHOTO_PROP_LOCATION, "") );

		if( photoUse )
			useImage();

		anStartButton.setEnabled( !autoNickEnable );
		anStopButton.setEnabled( autoNickEnable );

		String downdir = local.getProperty( MainFrame.DOWNLOAD_PROP );
		String logdir = local.getProperty( MainFrame.CHATLOG_PROP );
		String backImageFile = local.getProperty( MainFrame.BACKIMAGE_PROP, "" );
		String autoNickPrefix = local.getProperty( MainFrame.AUTONICK + ".prefix", "" );
		String autoNickPostfix = local.getProperty( MainFrame.AUTONICK + ".postfix", "" );
		String autoNickPass = local.getProperty( MainFrame.AUTONICK + ".password", "jmsn");

		new File(downdir).mkdirs();
		new File(logdir).mkdirs();

		downField.setText( downdir );
		chatlogField.setText( logdir );
		bgImageField.setText( backImageFile );

		autoPrefixNickField.setText( autoNickPrefix );
		autoPostfixNickField.setText( autoNickPostfix );
		autoNickPassField.setText( autoNickPass );

		String foreColor = local.getProperty( MainFrame.BUDDYLIST_FONT_COLOR, "000000" );
		colorButton.setBackground( new Color(Integer.parseInt(foreColor)) );
	}

	public void setVisible( boolean show )
	{
		if( show )
		{
			processReady();
		}
		super.setVisible( show );
	}
}