/*
 * @(#)AddFriendDialog.java
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
 *    $Id: AddFriendDialog.java,v 1.3 2002/03/16 19:31:39 xrath Exp $
 */
package rath.jmsn.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

import rath.msnm.MSNMessenger;
import rath.msnm.event.MsnAdapter;
import rath.jmsn.ToolBox;
import rath.jmsn.util.Msg;
/**
 * 친구 등록하는 다이얼로그
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: AddFriendDialog.java,v 1.3 2002/03/16 19:31:39 xrath Exp $
 */
public class AddFriendDialog extends DefaultDialog implements ToolBox, ActionListener
{
	private MSNMessenger msnm = null;

	private JTextField emailField = null;
	private JButton addButton, cancelButton;
	private JLabel commentLabel = null;
	private JProgressBar progress = null;
	private Timer timer = null;
	private MsnAdapter baseAdapter = new Adapter();

	public AddFriendDialog( Frame owner, MSNMessenger msnm )
	{
		super( owner );
		setTitle( Msg.get("title.adduser") );

		this.msnm = msnm;
		this.msnm.addMsnListener( baseAdapter );
		createComponents();
	}

	private class Adapter extends MsnAdapter
	{
		public void addFailed( int err )
		{
			String msg = null;
			switch( err )
			{
			case 210:
				msg = Msg.get("add.fail.overflow");
				break;
			case 215:
				msg = Msg.get("add.fail.exist");
				break;
			case 205:
			case 208:
				msg = Msg.get("add.fail.unknown-user");
				break;
			}

			enableAll(msg);
		}

		public void buddyListModified()
		{
			String email = emailField.getText().trim();
			enableAll( Msg.get("add.ok", email) );
		}
	}

	private void createComponents()
	{
		setSize( 420, 160 );
		JPanel panel = (JPanel)getContentPane();

		JPanel mainPanel = new JPanel();
		JLabel label = new JLabel(Msg.get("add.email"));
		label.setFont( FONT );

		emailField = new JTextField(20);
		emailField.setFont( FONT );
		emailField.addActionListener( this );

		mainPanel.add( label, "West" );
		mainPanel.add( emailField, "Center" );

		FlowLayout fl = new FlowLayout();
		JPanel centerPanel = new JPanel(fl);
		centerPanel.add( mainPanel );

		commentLabel = new JLabel(Msg.get("add.email.detail"));
		commentLabel.setBorder( BorderFactory.createEtchedBorder() );
		commentLabel.setPreferredSize( new Dimension(getSize().width-20, 24) );
		commentLabel.setFont( FONT );

		progress = new JProgressBar( 1, 15 );
		progress.setPreferredSize( new Dimension( getSize().width-20, 16 ) );

		timer = new Timer( 50, new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				progress.setValue( progress.getValue()+1 );
			}
		});

		fl.setAlignment( FlowLayout.LEADING );
		centerPanel.add( progress );
		centerPanel.add( commentLabel );

		JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 15, 5));
		addButton = new JButton(Msg.get("button.add"));
		addButton.setFont( FONT );
		addButton.setMnemonic( 'A' );
		addButton.addActionListener( this );
		cancelButton = new JButton(Msg.get("button.cancel"));
		cancelButton.setFont( FONT );
		cancelButton.addActionListener( this );
		buttonPanel.add( addButton );
		buttonPanel.add( cancelButton );

		panel.add( centerPanel, "Center" );
		panel.add( buttonPanel, "South" );
	}

	public void actionPerformed( ActionEvent e )
	{
		Object src = e.getSource();
		if( src==cancelButton )
		{
			dispose();
		}
		else
		if( src==emailField || src==addButton )
		{
			String email = emailField.getText().trim();
			if( email.length()==0 )
			{
				emailField.requestFocus();
				return;
			}

			processAdd( email );
		}
	}

	protected void disableAll()
	{
		SwingUtilities.invokeLater( new Runnable() {
			public void run()
			{
				emailField.setEnabled( false );
				addButton.setEnabled( false );
				cancelButton.setEnabled( false );
				progress.setValue( 0 );
				timer.start();
			}
		});
	}

	protected void enableAll( final String msg )
	{
		SwingUtilities.invokeLater( new Runnable() {
			public void run()
			{
				commentLabel.setText( msg );
				emailField.setEnabled( true );
				addButton.setEnabled( true );
				cancelButton.setEnabled( true );
				timer.stop();
				progress.setValue( 100 );
			}
		});
	}

	protected void processAdd( String email )
	{
		try
		{
			disableAll();
			msnm.addFriend( email );
		}
		catch( Exception e )
		{

		}
	}

	public void dispose()
	{
		msnm.removeMsnListener( baseAdapter );
		super.dispose();
	}
}
