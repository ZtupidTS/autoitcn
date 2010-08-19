/*
 * @(#)MusicBox.java
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
 *    $Id: MusicBox.java,v 1.1.1.1 2002/03/08 21:20:45 xrath Exp $
 */
package rath.jmsn.util;

import java.io.*;
import java.net.URL;
import java.util.Hashtable;
import javax.sound.sampled.*;

import rath.msnm.LocalCopy;
import rath.jmsn.MainFrame;
/**
 * 길에서 걸어다니면서 음악을 들을 수 있다는
 * 그 유명한 워크맨.
 * Wav 포맷 외에는 테스트해본적 없으니 주의.
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: MusicBox.java,v 1.1.1.1 2002/03/08 21:20:45 xrath Exp $
 */
public class MusicBox
{
	public static final String SOUND_LOGIN = "Login";
	public static final String SOUND_MESSAGE_1 = "Message.1";
	public static final String SOUND_MESSAGE_2 = "Message.2";

	private static LineListener clipListener = new ClipListener();
	private static Hashtable waveMap = new Hashtable();
	private static Hashtable acceptMap = new Hashtable();

	/**
	 * 설정을 읽어 각 사운드 데이터를 메모리로 올린다.
	 */
	public static void init()
	{
		Class cl = MusicBox.class;
		LocalCopy local = MainFrame.LOCALCOPY;
		try
		{
			URL urlLogin = new URL(
				local.getProperty(MainFrame.SOUND_LOGIN_PROP,
				cl.getResource("/resources/sounds/login.wav").toString()) );
			URL urlMessage1 = new URL(
				local.getProperty(MainFrame.SOUND_MESSAGE_1_PROP,
				cl.getResource("/resources/sounds/message1.wav").toString()) );
			URL urlMessage2 = new URL(
				local.getProperty(MainFrame.SOUND_MESSAGE_2_PROP,
				cl.getResource("/resources/sounds/message2.wav").toString()) );

			waveMap.put( SOUND_LOGIN, readBytes(urlLogin) );
			waveMap.put( SOUND_MESSAGE_1, readBytes(urlMessage1) );
			waveMap.put( SOUND_MESSAGE_2, readBytes(urlMessage2) );
		}
		catch( Exception e ) { e.printStackTrace(); }
	}

	private static byte[] readBytes( URL url ) throws IOException
	{
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] buf = new byte[ 8192 ];
		InputStream in = url.openStream();
		try
		{
			int readlen;
			while( (readlen=in.read(buf))>0 )
				bos.write( buf, 0, readlen );
		}
		finally
		{
			in.close();
		}
		return bos.toByteArray();
	}

	public static void setEnabled( String name, boolean enable )
	{
		if( enable )
			acceptMap.put( name, "" );
		else
			acceptMap.remove( name );
	}

	public static boolean isEnabled( String name )
	{
		return acceptMap.containsKey(name);
	}

	/**
	 * 해당 이름에 해당하는 Wave 파일을 연주한다.
	 * 이 method는 비동기로써, 곧바로 return된다.
	 */
	public synchronized static void play( String name )
	{
		byte[] dat = (byte[])waveMap.get(name);
		if( dat==null )
			return;

		if( !acceptMap.containsKey(name) )
			return;

		try
		{
			AudioInputStream ais = AudioSystem.getAudioInputStream(
				new ByteArrayInputStream(dat) );

			AudioFormat format = ais.getFormat();
			DataLine.Info info = new DataLine.Info( Clip.class, ais.getFormat(),
				((int)ais.getFrameLength() * format.getFrameSize()) );
			Clip clip = (Clip)AudioSystem.getLine( info );
			clip.addLineListener( clipListener );
			clip.open( ais );
			clip.start();
		}
		catch( Exception e )
		{
			e.printStackTrace();
		}
	}

	/**
	 * 연주가 끝나면 해당 Clip을 close하기 위한 리스너이다.
	 * 구지 Thread를 생성하는 것은, Redhat 7.1, JDK 1.4에서
	 * 곧바로 close() 할경우 VM Panic을 일으켰기 때문이다.
	 */
	private static class ClipListener implements LineListener
	{
		public void update( final LineEvent e )
		{
			if( e.getType().equals(LineEvent.Type.STOP) )
			{
				new Thread( new Runnable() {
					public void run()
					{
						synchronized( AudioSystem.class )
						{
							e.getLine().close();
						}
					}
				}).start();
			}
		}
	}
}
