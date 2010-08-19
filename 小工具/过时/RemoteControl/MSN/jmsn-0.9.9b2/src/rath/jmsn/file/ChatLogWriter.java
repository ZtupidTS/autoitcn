/*
 * @(#)ChatLogWriter.java
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
 *    $Id: ChatLogWriter.java,v 1.1.1.1 2002/03/08 21:20:45 xrath Exp $
 */
package rath.jmsn.file;

import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.io.IOException;

import java.text.SimpleDateFormat;
import java.util.Date;

import rath.msnm.entity.MsnFriend;
/**
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: ChatLogWriter.java,v 1.1.1.1 2002/03/08 21:20:45 xrath Exp $
 */
public class ChatLogWriter
{
	private static final SimpleDateFormat TIME = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
	private static final String LINE_SEP = System.getProperty("line.separator");

	private FileOutputStream fos = null;
	private PrintWriter out = null;

	public ChatLogWriter( File file ) throws IOException
	{
		prepare(file);
	}

	private void prepare( File file ) throws IOException
	{
		fos = new FileOutputStream(file.getAbsolutePath(), true);
		out = new PrintWriter( fos, true );

		out.println( "-------------------------------------------------------" );
		out.println( TIME.format(new Date()) + " CHAT SESSION STARTED" );
		out.println( "-------------------------------------------------------" );
	}

	public void println( String msg )
	{
		StringBuffer sb = new StringBuffer();
		sb.append( TIME.format(new Date()) );
		sb.append( ' ' );
		sb.append( msg );
		out.println( sb.toString() );
	}

	public void println( MsnFriend say, String msg )
	{
		StringBuffer sb = new StringBuffer();
		sb.append( TIME.format(new Date()) );
		sb.append( ' ' );
		sb.append( say.getLoginName() );
		sb.append( LINE_SEP );
		sb.append( msg );
		out.println( sb.toString() );
	}

	public void close()
	{
		out.println( "-------------------------------------------------------" );
		out.println( TIME.format(new Date()) + " CHAT SESSION CLOSED" );
		out.println( "-------------------------------------------------------" );
		out.println();

		out.flush();
		out.close();

		try {
			fos.close();
		} catch( IOException e ) {}
	}
}
