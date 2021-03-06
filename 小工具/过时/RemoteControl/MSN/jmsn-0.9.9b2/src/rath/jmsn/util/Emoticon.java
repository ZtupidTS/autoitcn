/*
 * @(#)Emoticon.java
 *
 * Copyright (c) 2002, Kim Min Jong
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
 *    $Id: Emoticon.java,v 1.4 2002/09/01 11:19:16 xrath Exp $
 */
package rath.jmsn.util;

import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.net.URL;

import rath.msnm.util.StringUtil;
import java.util.Enumeration;
import java.util.Hashtable;
import java.awt.*;
import javax.swing.ImageIcon;
/**
 *
 * @author Kim, Min Jong, pistos@skypond.snu.ac.kr
 * @version $Id: Emoticon.java,v 1.4 2002/09/01 11:19:16 xrath Exp $, since 2002/03/24
 */
public class Emoticon
{
	private Hashtable emoticons = new Hashtable();
	private static Emoticon INSTANCE = null;
	
	private Emoticon()
	{
	}

	public static Emoticon getInstance()
	{
		if( INSTANCE==null )
		{
			INSTANCE = new Emoticon();
			INSTANCE.loadEmoticons(
				Emoticon.class.getResource("/resources/text/emoticon.properties") );
		}
		return INSTANCE;
	}

	private void loadEmoticons( URL url )
	{		
		BufferedReader br = null;
		try
		{
			br = new BufferedReader(new InputStreamReader(url.openStream()));
			String line = null;
			while( (line=br.readLine())!=null )
			{
				if( line.trim().length()==0 || line.charAt(0)=='#' )
					continue;
				int i0 = line.indexOf('=');
				if(i0!=-1 )
				{
					String key = line.substring(0, i0).trim();
					String value = line.substring(i0+1).trim();
					value = StringUtil.replaceString(value, "\\n", "\n");
					URL eUrl = Emoticon.class.getResource("/resources/emoticon/"+value);
					if( eUrl!=null )
					    emoticons.put( key, new ImageIcon(eUrl) );
				}
			}
		}
		catch( Exception e ) { e.printStackTrace(); }
		finally 
		{
			if( br!=null )
			{
				try { br.close(); } catch( Exception e ) {}
			}
		}
	}

	/**
	 * 지원되는 Emoticon을 반환한다. 
	 * @return
	 */
	public Enumeration getEmoticons()
	{
		return emoticons.keys();
	}

	public ImageIcon get( String key )
	{
	    return (ImageIcon)emoticons.get(key);
	}
}	
