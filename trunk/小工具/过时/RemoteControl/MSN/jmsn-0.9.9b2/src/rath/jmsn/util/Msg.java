/*
 * @(#)Msg.java
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
 *    $Id: Msg.java,v 1.10 2004/05/31 06:21:02 xrath Exp $
 */
package rath.jmsn.util;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.URL;
import java.text.MessageFormat;
import java.util.Properties;
import java.util.Locale;
import java.util.HashMap;
import java.util.Set;
import java.util.Iterator;

import rath.msnm.util.StringUtil;
import rath.jmsn.MainFrame;
/**
 *
 * @author Jangho Hwang, rath@linuxkorea.co.kr
 * @version 1.0.000, 2002/03/13
 */
public class Msg
{
	static Properties current = null;
	static Properties usProp = null;
	static Locale currentLocale = null;
	static HashMap localMap = new HashMap();

	static
	{
		/*
			Can't fully enumerate available locales on Windows XP, JDK 1.4

	    Locale ls[] = Locale.getAvailableLocales();
		for(int i=0; i<ls.length; i++)
		{
			String code = ls[i].getLanguage();
			String country = ls[i].getCountry();
		    URL url = Msg.class.getResource("/resources/text/message.properties." + code + "_" + country);
			Properties prop;
			if( url!=null && (prop=getMessageBundle(url,ls[i]))!=null )
			{
				localMap.put( ls[i], prop );
			}
		}
		*/
		Locale korea = new Locale("ko", "KR", "");
		localMap.put( korea, getMessageBundle(Msg.class.getResource("/resources/text/message.properties.ko_KR"), korea) );
		Locale koreaUTF8 = new Locale("ko", "KR", "UTF-8");
		localMap.put( koreaUTF8, getMessageBundle(Msg.class.getResource("/resources/text/message.properties.ko_KR.UTF-8"), koreaUTF8) );
		Locale english = new Locale("en", "US", "");
		localMap.put( english, getMessageBundle(Msg.class.getResource("/resources/text/message.properties.en_US"), english) );
		Locale fr = new Locale("fr", "FR", "");
		localMap.put( fr, getMessageBundle(Msg.class.getResource("/resources/text/message.properties.fr_FR"), fr) );
		Locale it = new Locale("it", "IT", "");
		localMap.put( it, getMessageBundle(Msg.class.getResource("/resources/text/message.properties.it_IT"), it) );
		Locale de = new Locale("de", "DE", "");
		localMap.put( de, getMessageBundle(Msg.class.getResource("/resources/text/message.properties.de_DE"), it) );

		Locale def = Locale.getDefault();
		String encoding = System.getProperty("file.encoding").toLowerCase();
		if( encoding.equals("utf8") || encoding.equals("utf-8") )
			currentLocale = new Locale(def.getLanguage(), def.getCountry(), "UTF-8"); 
		else
			currentLocale = new Locale(def.getLanguage(), def.getCountry());
		usProp = (Properties)localMap.get(english);

		Properties defProp = (Properties)localMap.get(currentLocale);
        if( defProp==null )
        {
            current = (Properties)localMap.get(english);
            currentLocale = english;
        }
        else
            current = defProp;
	}

	private static Properties getMessageBundle( URL url, Locale locale )
	{
		Properties prop = new Properties();

		String variant = locale.getVariant();
		try
		{
			ByteArrayOutputStream bos = new ByteArrayOutputStream();
			InputStream in = url.openStream();
			int buf;
			while( (buf=in.read())!=-1 )
			{
				if( buf==10 ) // message.properties's editor is me! so only use LF	
				{
					byte[] b = bos.toByteArray();
					bos.reset();
					String line = null;
					if( variant==null || variant.equals("") )
						line = new String( b );
					else
						line = new String( b, variant );
					if( line.trim().length()==0 || line.charAt(0)=='#' )
						continue;
					int i0 = line.indexOf('=');
					if(i0 != -1)
					{
						String key = line.substring(0, i0).trim();
						String value = line.substring(i0+1).trim();
						value = StringUtil.replaceString(value, "\\n", "\n");
					    prop.setProperty( key, value );
					}
				}
				else
					bos.write( buf );
			}
			in.close();
			return prop;
		}
		catch( Exception e ) { e.printStackTrace(); }
		return null;
	}

	/**
	 * 지원되는 Locale을 반환한다. 대신 Country code가 같은 Locale들은 걸러진다.
	 * @return
	 */
	public static Set getAvailableLocales()
	{
		return localMap.keySet();
	}

	public static synchronized void setLocale( Locale locale )
	{
		Locale.setDefault(locale);
	    Properties prop = (Properties)localMap.get(locale);
		currentLocale = locale;
		current = prop==null ? (Properties)localMap.get(new Locale("en", "US", "")) : prop;
		MainFrame.INSTANCE.updateUIAll();
	}

	public static Locale getCurrentLocale()
	{
		return currentLocale;
	}

	public static String get( String key )
	{
		String msg = current.getProperty(key);
		if( msg==null )
			msg = usProp.getProperty(key);
	    return msg;
	}

	public static String get( String key, String param )
	{
		return MessageFormat.format( get(key), new Object[]{param} );
	}

	public static String get( String key, String param1, String param2 )
	{
		return MessageFormat.format( get(key), new Object[]{param1, param2} );
	}

	public static String get( String key, Object[] params )
	{
		return MessageFormat.format( get(key), params );
	}
}
