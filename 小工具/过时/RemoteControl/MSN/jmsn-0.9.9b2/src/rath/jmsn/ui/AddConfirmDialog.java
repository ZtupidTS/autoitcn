/*
 * @(#)AddConfirmDialog.java
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
 *    $Id: AddConfirmDialog.java,v 1.3 2002/03/16 19:31:39 xrath Exp $
 */
package rath.jmsn.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

import java.io.IOException;

import rath.msnm.MSNMessenger;
import rath.msnm.entity.MsnFriend;
import rath.jmsn.MainFrame;
import rath.jmsn.ToolBox;
import rath.jmsn.util.Msg;
/**
 * Notify who added me, and confirm to register specified user or not.
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: AddConfirmDialog.java,v 1.3 2002/03/16 19:31:39 xrath Exp $
 */
public class AddConfirmDialog extends DefaultDialog implements ToolBox
{
	private MainFrame main = null;

	private MsnFriend friend = null;
	private JRadioButton approveButton = null;
	private JRadioButton rejectButton = null;

	public AddConfirmDialog( MainFrame main, MsnFriend friend )
	{
		super( main );

		this.main = main;
		this.friend = friend;
		setModal( false );
		createUI();
	}

	private void createUI()
	{
		setSize( 400, 140 );

		JPanel panel = (JPanel)getContentPane();
		panel.setBorder( BorderFactory.createEmptyBorder(5,5,5,5) );
		BoxLayout bl = new BoxLayout(panel, BoxLayout.Y_AXIS);
		panel.setLayout( bl );

		JLabel label = new JLabel( Msg.get("who.added.me", friend.getLoginName()) );
		label.setFont( FONT );
		panel.add( label );

		approveButton = new JRadioButton( Msg.get("add.approve") );
		approveButton.setFont( FONT );
		approveButton.setSelected( true );

		rejectButton = new JRadioButton( Msg.get("add.reject") );
		rejectButton.setFont( FONT );
		// Not implemented
		rejectButton.setEnabled( false );

		ButtonGroup bg = new ButtonGroup();
		bg.add( approveButton );
		bg.add( rejectButton );

		panel.add( approveButton );
		panel.add( rejectButton );

		JPanel buttonPanel = new JPanel( new FlowLayout(FlowLayout.CENTER,5,5) );
		JButton confirmButton = new JButton( Msg.get("button.ok") );
		confirmButton.setFont( FONT );
		confirmButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				processConfirm();
			}
		});
		JButton cancelButton = new JButton( Msg.get("button.cancel") );
		cancelButton.setFont( FONT );
		cancelButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				dispose();
			}
		});
		buttonPanel.add( confirmButton );
		buttonPanel.add( cancelButton );
		buttonPanel.setAlignmentX( 0.0f );
		buttonPanel.setPreferredSize( new Dimension(Short.MAX_VALUE,30) );

		panel.add( buttonPanel );
	}

	protected void processConfirm()
	{
		boolean isApprove = approveButton.isSelected();
		MSNMessenger msnm = main.getMessenger();

		if( isApprove )
		{
			try
			{
				msnm.addFriend( friend.getLoginName() );
			}
			catch( IOException e )
			{
				e.printStackTrace();
			}
		}
		dispose();
	}
};
