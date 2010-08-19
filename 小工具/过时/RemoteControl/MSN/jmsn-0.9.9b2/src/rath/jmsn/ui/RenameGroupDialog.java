/*
 * @(#)ChangeGroupDialog.java
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
 *    $Id: RenameGroupDialog.java,v 1.1 2002/03/28 17:54:29 pistos Exp $
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
 * 그룹명을 바꾸는 다이얼로그
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: RenameGroupDialog.java,v 1.1 2002/03/28 17:54:29 pistos Exp $
 */
public class RenameGroupDialog extends DefaultDialog implements ToolBox, ActionListener
{
	private MSNMessenger msnm = null;
	private JTextField nameField = null;
	private Integer gi = null;
	private String groupName = null;

	public RenameGroupDialog( Frame owner, MSNMessenger msnm , Integer gi, String groupName)
	{
		super( owner );
		setTitle( Msg.get("title.renamegroup") );
	
		this.gi = gi;
		this.groupName = groupName;
		System.out.println(gi +","+ groupName);
		this.msnm = msnm;
		createComponents();
	}

	private void createComponents()
	{
		setSize( 280, 110 );
		JPanel panel = (JPanel)getContentPane();

		JPanel centerPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 5, 10));
		JPanel mainPanel = new JPanel(new BorderLayout(5,5) );
		JLabel l0 = new JLabel( Msg.get("remgdlg.query.gname") );
		l0.setFont( FONT );
		nameField = new JTextField();
		nameField.setText(groupName);
		nameField.setFont( FONT );

		mainPanel.add( l0, "West" );
		mainPanel.add( nameField, "Center" );
		mainPanel.setPreferredSize( new Dimension(240, 24) );
		centerPanel.add( mainPanel );

		JPanel buttonPanel = new JPanel( new FlowLayout(FlowLayout.CENTER, 10, 4) );
		JButton okButton = new JButton( Msg.get("button.ok") );
		okButton.setFont( FONT );
		okButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				String gName = nameField.getText().trim();
				if( gName.length()!=0 )
				{
					dispose();
				    processRename( gName );
				}
				else
					nameField.requestFocus();
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
		buttonPanel.add( okButton );
		buttonPanel.add( cancelButton );

		panel.add( centerPanel, "Center" );
		panel.add( buttonPanel, "South" );
	}

	public void actionPerformed( ActionEvent e )
	{

	}

	protected void processRename( String groupName )
	{
		try
		{
			msnm.renameGroup( gi.intValue(), groupName );
		}
		catch( Exception e )
		{
		    e.printStackTrace();
		}
	}
}
