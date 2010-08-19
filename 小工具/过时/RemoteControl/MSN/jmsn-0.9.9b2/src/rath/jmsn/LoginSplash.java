/*
 * @(#)LoginSplash.java
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
 *    $Id: LoginSplash.java,v 1.4 2002/03/15 09:55:42 xrath Exp $
 */
package rath.jmsn;

import java.awt.*;
import javax.swing.*;
import rath.msnm.entity.MsnFriend;
import rath.msnm.SwitchboardSession;
import rath.msnm.msg.MimeMessage;
import rath.msnm.ftp.VolatileTransferServer;
import rath.msnm.ftp.VolatileDownloader;
import rath.msnm.event.MsnListener;

import rath.jmsn.util.Msg;
/**
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: LoginSplash.java,v 1.4 2002/03/15 09:55:42 xrath Exp $
 */
public class LoginSplash extends JPanel implements ToolBox
{
	private String INIT_MESSAGE = Msg.get("label.splash.clickme");
	private String message = INIT_MESSAGE;

	public LoginSplash()
	{
		setBackground( Color.white );
	}

	public void paintComponent( Graphics g )
	{
		int width = getSize().width;
		int height = getSize().height;

		g.setColor( getBackground() );
		g.fillRect( 0, 0, width, height );

		g.setFont( FONT );
		FontMetrics fm = g.getFontMetrics( FONT );

		g.setColor( Color.black );
		g.drawString( message,
			(width-fm.stringWidth(message))>>1,
			(height/3) - (fm.getAscent()>>1) + (fm.getDescent()>>1) );
	}

	public void setInitialText()
	{
		this.message = INIT_MESSAGE;
	}

	public void setText( String message )
	{
		this.message = message;
		repaint();
	}

	public void updateUI()
	{
		this.INIT_MESSAGE = Msg.get("label.splash.clickme");
		this.message = Msg.get("label.splash.clickme");
		super.updateUI();
	}
}
