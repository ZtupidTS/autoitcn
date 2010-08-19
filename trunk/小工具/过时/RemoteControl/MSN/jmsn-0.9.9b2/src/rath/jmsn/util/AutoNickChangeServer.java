/*
 * @(#)AutoNickChangeServer.java
 *
 * Copyright (c) 1997-2003, Jang-Ho Hwang
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
 *    $Id: AutoNickChangeServer.java,v 1.2 2004/06/07 11:18:30 xrath Exp $
 */
package rath.jmsn.util;

import java.io.*;
import java.net.*;

import rath.msnm.MSNMessenger;
import rath.jmsn.MainFrame;
/**
 *
 * @author Jang-Ho Hwang, rath@xrath.com
 * @version 1.0.000
 */
public class AutoNickChangeServer implements Runnable 
{
	private int port = 7190; /* Default UDP Bind port */
	private DatagramSocket socket;
	private Thread thread;

	private static AutoNickChangeServer INSTANCE;

	private AutoNickChangeServer()
	{

	}

	public static AutoNickChangeServer getInstance()
	{
		if( INSTANCE==null )
		{
			INSTANCE = new AutoNickChangeServer();
		}
		return INSTANCE;
	}

	public void setPort( int port )
	{
		this.port = port;
	}

	public int getPort()
	{
		return this.port;
	}

	public void start() throws IOException
	{
		if( socket!=null )
			return;

		socket = new DatagramSocket(this.port);
		thread = new Thread(this);
		thread.start();
	}

	public void run()
	{
		long lastReceived = System.currentTimeMillis();
		while(true)
		{
			DatagramPacket pkt = new DatagramPacket(new byte[2048], 2048);

			try
			{				
				socket.receive(pkt);

				if( System.currentTimeMillis() > lastReceived + 1000L )
					process( pkt.getData(), pkt.getOffset(), pkt.getLength() );

				lastReceived = System.currentTimeMillis();
			}
			catch( Exception e ) 
			{
				e.printStackTrace();
				break; // Oops -.-;
			}
		}
	}

	protected void process( byte[] data, int off, int len ) throws Exception
	{
		int i0 = -1;
		for(int i=off, max=off+len; i<max; i++)
		{
			if( data[i]==0x01 )
			{
				i0 = i;
				break;
			}
		}

		if( i0==-1 )
			return;

		String requestPass = new String(data, off, i0-off);
		String requestNick = new String(data, i0+1, len-(i0-off)-1);

		String prefix = MainFrame.LOCALCOPY.getProperty( MainFrame.AUTONICK + ".prefix", "" );
		String postfix = MainFrame.LOCALCOPY.getProperty( MainFrame.AUTONICK + ".postfix", "" );
		String password = MainFrame.LOCALCOPY.getProperty( MainFrame.AUTONICK + ".password", "jmsn");

		if( !requestPass.equals(password) )
			return;

		String newNick = prefix + requestNick + postfix;

		MSNMessenger msnm = MainFrame.INSTANCE.getMessenger();
		if( msnm!=null && msnm.isLoggedIn() )
			msnm.setMyFriendlyName( newNick );
	}

	public void stop() throws IOException
	{
		socket.close();
		socket = null;

		thread.interrupt();
	}
}
