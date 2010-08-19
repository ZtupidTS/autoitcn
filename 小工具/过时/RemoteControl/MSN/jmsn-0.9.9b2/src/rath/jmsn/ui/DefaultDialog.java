/*
 * @(#)DefaultDialog.java
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
 *    $Id: DefaultDialog.java,v 1.5 2004/06/07 06:02:15 xrath Exp $
 */
package rath.jmsn.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

/**
 * Common abstract Dialog class.
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: DefaultDialog.java,v 1.5 2004/06/07 06:02:15 xrath Exp $
 */
public abstract class DefaultDialog extends JDialog
{
	protected DefaultDialog( Frame owner )
	{
		super( owner, true );

		init();
	}

	private void init()
	{
		AbstractAction action = new AbstractAction() {
			public void actionPerformed( ActionEvent e )
			{
				dispose();
			}
		};

		JPanel panel = (JPanel)getContentPane();
		ComponentInputMap im = new ComponentInputMap(panel);
		im.put( KeyStroke.getKeyStroke(KeyEvent.VK_ESCAPE, 0), "Dispose" );
		ActionMap am = panel.getActionMap();
		am.put( "Dispose", action );
		panel.setInputMap( JComponent.WHEN_IN_FOCUSED_WINDOW, im );

		this.addKeyListener( new KeyAdapter() {
			public void keyPressed( KeyEvent e )
			{
				if( e.getKeyCode()==KeyEvent.VK_ESCAPE )
					dispose();
			}
		});

		setDefaultCloseOperation( DISPOSE_ON_CLOSE );
		pack();
	}

	public void setVisible( boolean show )
	{
		if( show )
		{
			Point p = getOwner().getLocationOnScreen();
			Dimension size = getOwner().getSize();
			Dimension ssize = Toolkit.getDefaultToolkit().getScreenSize();

			int x = p.x + ((size.width-getSize().width)>>1);
			int y = p.y + ((size.height-getSize().height)>>1);

			if( x < 5 ) x = 5;
			if( y < 5 ) y = 5;
			if( (x+getSize().width) > ssize.width )
				x = ssize.width - getSize().width;
			if( (y+getSize().height) > ssize.height )
				y = ssize.height - getSize().height;

			setLocation( x, y );

			rath.jmsn.NativeToolkit.getInstance().makeTransparency(this,
				Integer.getInteger("jmsn.transparency", -1).intValue());
			super.setVisible(true);
			rath.jmsn.NativeToolkit.getInstance().makeTransparency(this,
				Integer.getInteger("jmsn.transparency", -1).intValue());
		}
		else
			super.setVisible(false);
	}
};