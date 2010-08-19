/*
 * @(#)LoginDialog.java
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
 *    $Id: LoginDialog.java,v 1.7 2004/06/07 11:18:29 xrath Exp $
 */
package rath.jmsn.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

import java.io.File;

import java.util.Enumeration;
import java.util.Properties;

import rath.msnm.util.StringList;
import rath.msnm.UserStatus;
import rath.msnm.LocalCopy;
import rath.jmsn.ToolBox;
import rath.jmsn.MainFrame;
import rath.jmsn.util.GlobalProp;
import rath.jmsn.util.UserStatusBox;
import rath.jmsn.util.Msg;
/**
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: LoginDialog.java,v 1.7 2004/06/07 11:18:29 xrath Exp $
 */
public class LoginDialog extends DefaultDialog implements ToolBox
{
	private boolean isConfirm = false;
	private Frame owner = null;
	private JComboBox loginBox = null;
	private JPasswordField passField = null;
	private JComboBox statusBox = null;
	private JCheckBox rememberPassBox = null;

	public LoginDialog( Frame owner )
	{
		super( owner );

		setTitle( Msg.get("title.login") );

		this.owner = owner;
		createComponents();

		// 이전 설정 읽기
		GlobalProp prop = MainFrame.getGlobalProp();
		String loginName = prop.get( "last.login" );
		String password = "";
		if( loginName!=null )
		{
		    int i0 = loginName.indexOf(":");
			if( i0!=-1 )
			{
				password = loginName.substring( i0+1 );
				loginName = loginName.substring( 0, i0 );
				passField.setText( password );
			}
		    loginBox.setSelectedItem( loginName );
		}
	}

	private void createComponents()
	{
		setSize( 350, 215 );

		JPanel panel = (JPanel)getContentPane();

		JPanel mainPanel = new JPanel();
		BoxLayout box = new BoxLayout(mainPanel, BoxLayout.Y_AXIS);
		mainPanel.setLayout( box );
		mainPanel.setBorder( BorderFactory.createEmptyBorder(5,5,5,5) );

		JLabel loginLabel = new JLabel(Msg.get("label.loginname"));
		JLabel passLabel = new JLabel(Msg.get("label.password"));
		loginLabel.setFont( FONT );
		passLabel.setFont( FONT );

		ActionListener actionLogin = new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				doConfirm();
			}
		};

		String[] users = getLoggedUsers();
		loginBox = new JComboBox(users);
		loginBox.setFont( FONT );
		loginBox.setEditable(true);
		//loginBox.addActionListener( actionLogin );

		passField = new JPasswordField(18);
		passField.setFont( FONT );
		passField.setEchoChar('*');
		passField.addActionListener( actionLogin );
		rememberPassBox	= new JCheckBox( Msg.get("label.remember.password") );
		rememberPassBox.setFont( FONT );

		JPanel loginPanel = new JPanel();
		loginPanel.add( loginLabel );
		loginPanel.add( loginBox );
		JPanel passPanel = new JPanel();
		passPanel.add( passLabel );
		passPanel.add( passField );
		passPanel.add( rememberPassBox );

		JPanel statusPanel = createStatusPanel();

		mainPanel.add( loginPanel );
		mainPanel.add( passPanel );
		mainPanel.add( rememberPassBox );
		mainPanel.add( statusPanel );

		JPanel buttonPanel = new JPanel(new FlowLayout());
		JButton confirmButton = new JButton(Msg.get("button.ok"));
		confirmButton.setFont( FONT );
		confirmButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				doConfirm();
			}
		});
		JButton cancelButton = new JButton(Msg.get("button.cancel"));
		cancelButton.setFont( FONT );
		cancelButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				doCancel();
			}
		});
		buttonPanel.add( confirmButton );
		buttonPanel.add( cancelButton );

		panel.add( mainPanel, "Center" );
		panel.add( buttonPanel, "South" );
	}

	private JPanel createStatusPanel()
	{
		JPanel panel = new JPanel();

		JLabel label = new JLabel(Msg.get("label.initstatus"));
		label.setFont( FONT );

		statusBox = new JComboBox();
		statusBox.setFont( FONT );
		Properties prop = UserStatusBox.getStatusSet();
		for(Enumeration e=prop.propertyNames(); e.hasMoreElements(); )
		{
			String code = (String)e.nextElement();
			if( code.equals(UserStatus.OFFLINE) )
				continue;
			statusBox.addItem( prop.getProperty(code) );
		}

		statusBox.setSelectedItem( prop.getProperty(UserStatus.ONLINE) );

		panel.add( label, "West" );
		panel.add( statusBox, "Center" );

		return panel;
	}

	public String[] getLoggedUsers(){
		LocalCopy local = new LocalCopy();
		File homedir = local.getHomeDirectory();
		File[] file = homedir.listFiles();
		StringList users = new StringList();
		for(int i=0; i<file.length; i++)
		{
			if(file[i].isDirectory())
			{
				if(isValidEmail(file[i].getName()))
					users.add(file[i].getName());
			}
		}
		return users.toArray();
	}
	
	/**
		E-mail 주소가 적절한 것인지 판단
		현재기준
		- @이 한개가 아니면 false
		- @을 기준으로 id와 dns 부분으로 나누고, 
		  id 부분에 .이 있으면 false
		  dns 부분에 .이 없으면 false
		먼가 부족하다 싶으시면 추가하시기 바람
	*/
	public boolean isValidEmail(String email)
	{
		int at1 = email.indexOf('@');
		int at2 = email.indexOf('@',at1+1);
		if(at1==-1 || at2!=-1)
			return false;

		String id = email.substring(0, at1);
		String dns = email.substring(at1+1, email.length());

		if(id.indexOf('.')!=-1)
			return false;

		if(dns.indexOf('.')==-1)
			return false;

		return true;
	}

	public boolean isConfirm()
	{
		return this.isConfirm;
	}

	protected boolean checkValidate()
	{
		if( loginBox.getSelectedItem().toString().trim().length()==0 )
			return false;
		if( passField.getPassword().length==0 )
			return false;

		return true;
	}

	public String getLoginName()
	{
		return this.loginBox.getSelectedItem().toString();
	}

	public String getPassword()
	{
		char[] passwd = passField.getPassword();
		if( passwd.length > 16 )
			return new String(passwd, 0, 16);
		return new String(passwd);
	}

	public boolean isRememberPassword()
	{
	    return this.rememberPassBox.isSelected();
	}

	public String getInitialStatus()
	{
		String format = (String)statusBox.getSelectedItem();
		String code = UserStatusBox.getStatusAtFormattedValue( format );

		return code;
	}

	public void doConfirm()
	{
		if( checkValidate() )
			isConfirm = true;
		dispose();
	}

	public void doCancel()
	{
		dispose();
	}
}
