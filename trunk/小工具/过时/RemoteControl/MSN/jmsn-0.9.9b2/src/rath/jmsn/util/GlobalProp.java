/*
 * @(#)GlobalProp.java
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
 *    $Id: GlobalProp.java,v 1.1 2002/03/10 04:58:19 xrath Exp $
 */
package rath.jmsn.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;
import rath.msnm.LocalCopy;
/**
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: GlobalProp.java,v 1.1 2002/03/10 04:58:19 xrath Exp $
 */
public class GlobalProp extends Properties
{
	private final File settingFile;

    public GlobalProp()
    {
		this.settingFile = new File( LocalCopy.DEFAULT_HOME_DIR, "Global.prop" );
    }

	public void load()
	{
		if( !settingFile.exists() )
		    return;

		try
		{
			FileInputStream fis = new FileInputStream( settingFile.getAbsolutePath() );
			load( fis );
			fis.close();
		}
		catch( IOException e )
		{
		    System.err.println( "GlobalProp.load: " + e );
		}
	}

	public void store()
	{
		try
		{
			FileOutputStream fos = new FileOutputStream( settingFile.getAbsolutePath() );
			store( fos, "JMSN Global setting file" );
			fos.flush();
			fos.close();
		}
		catch( IOException e )
		{
		    System.err.println( "Global.store: " + e );
		}
	}

	public int getInt( String key )
	{
		String str = getProperty(key);
		if( str!=null )
			return Integer.parseInt(str);
		setProperty( key, str );
		return -1;
	}

	/**
	 * key를 검색하고, 없으면 def를 반환한다. 그리고 반환된 후에는
	 * 요청했던 key, value가 put되어있을 것이다.
	 *
	 * @param key
	 * @param def
	 * @return
	 */
	public int getInt( String key, int def )
	{
	    String str = getProperty(key);
		if( str!=null )
			return Integer.parseInt(str);
		setProperty( key, String.valueOf(def) );
		return def;
	}

	public String get( String key )
	{
	    return getProperty(key);
	}

	public String get( String key, String def )
	{
	    return getProperty(key, def);
	}

	public void set( String key, int value )
	{
	    set( key, String.valueOf(value) );
	}

	public void set( String key, String value )
	{
		setProperty( key, value );
	}
}