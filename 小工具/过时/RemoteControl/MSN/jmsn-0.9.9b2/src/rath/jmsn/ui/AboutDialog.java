/*
 * @(#)AboutDialog.java
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
 *    $Id: AboutDialog.java,v 1.14 2004/08/04 07:05:49 xrath Exp $
 */
package rath.jmsn.ui;

import java.awt.*;
import java.awt.event.*;
import java.net.URL;
import java.util.ArrayList;
import java.util.Iterator;
import javax.swing.*;

import rath.jmsn.ToolBox;
import rath.jmsn.util.Msg;
/**
 *
 * @author Jang-Ho Hwang, rath@xrath.com
 * @version $Id: AboutDialog.java,v 1.14 2004/08/04 07:05:49 xrath Exp $
 */
public class AboutDialog extends DefaultDialog implements ToolBox
{
	private ImageIcon icon, logo;

	public AboutDialog( Frame owner )
	{
		super( owner );

		setTitle( "JMSN Information" );

		logo = new ImageIcon(getIconResource("logo.jpg"));

		createUI();
	}

	private URL getIconResource( String name )
	{
		return this.getClass().getResource( "/resources/icon/" + name );
	}

	private void createUI()
	{
		setSize( 435, 385 );

		JPanel panel = (JPanel)getContentPane();

		JPanel mainPanel = new JPanel();
		mainPanel.setBorder( BorderFactory.createEmptyBorder(5,5,5,5) );
		BoxLayout box = new BoxLayout(mainPanel, BoxLayout.Y_AXIS);
		mainPanel.setLayout( box );

		JLabel logoLabel = new JLabel( logo, SwingConstants.CENTER );
		logoLabel.setText( "JMSN Messenger v0.9.9b1" );
		mainPanel.add( logoLabel );

		JLabel[] copyright = createCopyright();
		for(int i=0; i<copyright.length; i++)
			mainPanel.add( copyright[i] );

		JLabel l0 = new JLabel(" Author   Jang-Ho Hwang, rath@xrath.com ");
		l0.setFont( FONT_BOLD );
		l0.setBorder( BorderFactory.createEtchedBorder() );
		JLabel l1 = new JLabel(" JMSN Homepage    http://jmsn.sourceforge.net/ ");
		l1.setFont( FONT_BOLD );
		l1.setBorder( BorderFactory.createEtchedBorder() );

		Runtime rt = Runtime.getRuntime();
		long usage = (rt.totalMemory() - rt.freeMemory()) >> 10;

		final JLabel l2 = new JLabel(" Memory usage: " + usage + "KB" );
		JButton gcButton = new JButton( "Force GC" );
		gcButton.setFont( FONT );
		gcButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				System.gc();
				Runtime rt = Runtime.getRuntime();
				long usage = (rt.totalMemory() - rt.freeMemory()) >> 10;

				l2.setText( " Memory Usage: " + usage + "KB" );
			}
		});

		JPanel memoryPanel = new JPanel();		
		memoryPanel.setLayout( new BorderLayout() );
		memoryPanel.setAlignmentX( 0.0f );
		memoryPanel.add( l2, "Center" );
		memoryPanel.add( gcButton, "East" );		

		mainPanel.add( l0 );
		mainPanel.add( l1 );
		mainPanel.add( memoryPanel );

		JPanel bottomPanel = new JPanel(new FlowLayout());
		JButton closeButton = new JButton(Msg.get("button.close"));
		closeButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				dispose();
			}
		});
		closeButton.setFont( FONT );
		bottomPanel.add( closeButton );

		panel.add( mainPanel, "Center" );
		panel.add( bottomPanel, "South" );
	}

	private JLabel[] createCopyright()
	{
		ArrayList list = new ArrayList(25);
list.add("");
list.add("Copyright (c) 2001-2004 Jang-Ho Hwang. All rights reserved.");
list.add("");
list.add("Redistribution and use in source and binary forms, with or without");
list.add("modification, are permitted provided that the following conditions");
list.add("are met:");
list.add("1. Redistributions of source code must retain the above copyright");
list.add("   notice, this list of conditions and the following disclaimer.");
list.add("2. Redistributions in binary form must reproduce the above copyright");
list.add("   notice, this list of conditions and the following disclaimer in the");
list.add("   documentation and/or other materials provided with the distribution.");
list.add("3. Neither the name of author nor the names of its contributors may");
list.add("   be used to endorse or promote products derived from this software");
list.add("   without specific prior written permission.");
list.add("");
		JLabel[] l = new JLabel[ list.size() ];
		for(int i=0, len=list.size(); i<len; i++)
		{
			l[i] = new JLabel( (String)list.get(i) );
			l[i].setFont( FONT );
		}
		return l;
	}
};
