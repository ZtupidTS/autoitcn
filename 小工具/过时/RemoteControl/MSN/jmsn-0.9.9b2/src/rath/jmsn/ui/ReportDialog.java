/*
 * @(#)ReportDialog.java
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
 *    $Id: ReportDialog.java,v 1.2 2002/03/13 09:40:39 xrath Exp $
 */
package rath.jmsn.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

import java.net.*;
import java.io.*;

import rath.msnm.MSNMessenger;
import rath.msnm.entity.MsnFriend;

import rath.jmsn.ToolBox;
import rath.jmsn.util.Msg;
/**
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: ReportDialog.java,v 1.2 2002/03/13 09:40:39 xrath Exp $
 */
public class ReportDialog extends DefaultDialog implements ToolBox
{
	public static final String REPORT_BUG = "BUG";
	public static final String REPORT_FEATURE = "FEATURE REQUEST";

	private MSNMessenger msnm = null;
	private JTextField lnField = null;
	private JTextField fnField = null;
	private JTextField subjectField = null;
	private JTextArea contentArea = null;

	private String kind;

	public ReportDialog( Frame owner, MSNMessenger msnm, String title, String kind )
	{
		super( owner );

		this.msnm = msnm;
		this.kind = kind;

		setTitle( title );
		setModal( false );

		createUI();
	}

	private void createUI()
	{
		setSize( 350, 300 );

		JPanel panel = (JPanel)getContentPane();
		panel.setLayout( new BorderLayout() );

		panel.add( createMainPanel(), "Center" );
		panel.add( createBottomPanel(), "South" );
	}

	private JPanel createMainPanel()
	{
		JPanel panel = new JPanel();
		BoxLayout box = new BoxLayout(panel, BoxLayout.Y_AXIS);
		panel.setBorder( BorderFactory.createEmptyBorder(5,5,5,5) );
		panel.setLayout( box );

		JPanel lnPanel = new JPanel(new BorderLayout());
		lnPanel.setMaximumSize( new Dimension(Short.MAX_VALUE, 26) );
		JLabel l0 = new JLabel(Msg.get("label.loginname"));
		l0.setFont( FONT );
		lnField = new JTextField( 20 );
		lnField.setFont( FONT );
		lnPanel.add( l0, "West" );
		lnPanel.add( lnField, "Center" );
		panel.add( lnPanel );

		panel.add( createDummyPanel(3) );

		JPanel fnPanel = new JPanel(new BorderLayout());
		fnPanel.setMaximumSize( new Dimension(Short.MAX_VALUE, 26) );
		JLabel l1 = new JLabel(Msg.get("label.friendlyname"));
		l1.setFont( FONT );
		fnField = new JTextField( 20 );
		fnField.setFont( FONT );
		fnPanel.add( l1, "West" );
		fnPanel.add( fnField, "Center" );
		panel.add( fnPanel );

		MsnFriend me = msnm.getOwner();
		if( me!=null )
		{
			lnField.setText( me.getLoginName() );
			lnField.setEnabled( false );
			fnField.setText( me.getFormattedFriendlyName() );
			fnField.setEnabled( false );
		}

		panel.add( createDummyPanel(3) );

		JPanel sjPanel = new JPanel(new BorderLayout());
		sjPanel.setMaximumSize( new Dimension(Short.MAX_VALUE, 26) );
		JLabel l2 = new JLabel(Msg.get("label.subject"));
		l2.setFont( FONT );
		subjectField = new JTextField( 20 );
		subjectField.setFont( FONT );
		sjPanel.add( l2, "West" );
		sjPanel.add( subjectField, "Center" );
		panel.add( sjPanel );

		contentArea = new JTextArea();
		JScrollPane pane = new JScrollPane(contentArea);
		pane.setBorder( BorderFactory.createLineBorder( Color.black, 1 ) );

		panel.add( createDummyPanel(3) );
		panel.add( pane );

		return panel;
	}

	private JPanel createDummyPanel( int height )
	{
		JPanel panel = new JPanel();
		panel.setMaximumSize( new Dimension(Short.MAX_VALUE, height) );
		return panel;
	}

	private JPanel createBottomPanel()
	{
		JPanel panel = new JPanel(new FlowLayout(FlowLayout.CENTER, 10, 5));
		final JButton sendButton = new JButton(Msg.get("button.submit"));
		sendButton.setFont( FONT );
		sendButton.setMnemonic('S');
		sendButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				sendButton.setEnabled( false );
				sendImpl();
				dispose();
			}
		});
		JButton cancelButton = new JButton(Msg.get("button.cancel"));
		cancelButton.setFont( FONT );
		cancelButton.setMnemonic('C');
		cancelButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				dispose();
			}
		});

		panel.add( sendButton );
		panel.add( cancelButton );

		return panel;
	}

	private String encode( String str ) throws UnsupportedEncodingException
	{
		return rath.msnm.msg.MimeUtility.getURLEncodedString( str, "UTF-8" );
	}

	protected void sendImpl()
	{
		try
		{
			URLConnection con = new URL("http://xrath.com/report.jsp").openConnection();
			con.setDoInput( true );
			con.setDoOutput( true );
			con.setRequestProperty( "Content-Type", "application/x-www-form-urlencoded" );

			OutputStream out = con.getOutputStream();
			DataOutputStream dos = new DataOutputStream( out );
			dos.writeBytes( "ln=" + encode(lnField.getText()) +
				"&fn=" + encode(fnField.getText()) +
				"&subject=" + encode(subjectField.getText()) +
				"&kind=" + kind +
				"&os=" + System.getProperty("os.name") +
				"&jvm=" + System.getProperty("java.vm.version") +
				"&content=" + encode(contentArea.getText()) + "\r\n\r\n" );
			dos.flush();

			InputStream in = con.getInputStream();
			BufferedReader br = new BufferedReader( new InputStreamReader(in) );
			String buf = null;
			while( (buf=br.readLine())!=null );

			in.close();
			out.close();

			dos.close();
			br.close();
		}
		catch( Exception e )
		{
			e.printStackTrace();
		}
	}
}
