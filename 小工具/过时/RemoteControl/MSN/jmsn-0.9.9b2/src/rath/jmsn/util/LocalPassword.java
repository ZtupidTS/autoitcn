/*
 * @(#)LocalPassword.java
 *
 * Copyright (c) 2001-2004, Jang-Ho Hwang
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
 *    $Id: LocalPassword.java,v 1.1 2004/06/08 00:47:34 xrath Exp $
 */
package rath.jmsn.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.InvalidKeyException;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.spec.SecretKeySpec;
/**
 * If you use 'Remember password' feature, 
 * your password will be stored in Global.prop file as 
 * clear-text format.
 * <p>
 * Okay, this class provides crypted password in 
 * your jmsn configuration file by DES crypto library.
 * <p>
 * I use JCE library that default included in jdk 1.4.
 * If you use jdk 1.2/1.3, you can download JCE manually.
 * See the following URL, 
 * <p>
 * <a href="http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=JCE-1_2_2-G-JS&TransactionId=Try">http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=JCE-1_2_2-G-JS&TransactionId=Try</a>
 * <p>
 * Good luck.
 * 
 * @author Jang-Ho Hwang, rath@xrath.com
 * @version 1.0.000, 2004/06/08
 */
public class LocalPassword
{
	private static LocalPassword THIS = null;
	private Cipher cipher = null;

	private LocalPassword() 
	{
		try
		{
			cipher = Cipher.getInstance("DES");	
		}
		catch( NoSuchPaddingException e ) 
		{

		}
		catch( NoSuchAlgorithmException e )
		{

		}
	}

	public String encode( String userid, String password )
	{
		String ret = null;
		try
		{
			cipher.init( Cipher.ENCRYPT_MODE, makeKey(userid) );
			byte[] out = cipher.doFinal( password.getBytes() );
			ret = toHexString(out);
		}
		catch( InvalidKeyException e ) 
		{
			System.err.println( "LocalPassword encode failed: " + e );
		}
		catch( IllegalBlockSizeException e )
		{
			System.err.println( "LocalPassword encode failed: " + e );
		}
		catch( BadPaddingException e )
		{
			System.err.println( "LocalPassword encode failed: " + e );
		}
		catch( NoSuchAlgorithmException e )
		{
			System.err.println( "LocalPassword cannot make a key: " + e );
		}
		return ret;
	}

	public String decode( String userid, String encoded )
	{
		String ret = null;
		try
		{
			cipher.init( Cipher.DECRYPT_MODE, makeKey(userid) );
			byte[] out = cipher.doFinal( fromHexString(encoded) );
			ret = new String(out);
		}
		catch( InvalidKeyException e ) 
		{
			System.err.println( "LocalPassword decode failed: " + e );
		}
		catch( IllegalBlockSizeException e )
		{
			System.err.println( "LocalPassword decode failed: " + e );
		}
		catch( BadPaddingException e )
		{
			System.err.println( "LocalPassword decode failed: " + e );
		}
		catch( NoSuchAlgorithmException e )
		{
			System.err.println( "LocalPassword cannot make a key: " + e );
		}
		return ret;	
	}

	/**
	 * Make a SecretKey instance from User
	 */
	protected SecretKey makeKey( String userid ) 
		throws NoSuchAlgorithmException
	{
		MessageDigest md5 = MessageDigest.getInstance("md5");
		byte[] k = md5.digest(userid.getBytes());
		return new SecretKeySpec(k, 0, 8, "DES");
	}

	/** 
	 *
	 */
	protected String toHexString( byte[] b )
	{
		StringBuffer sb = new StringBuffer();
		for(int i=0; i<b.length; i++)
		{
			int v = b[i] < 0 ? (int)b[i] + 0x100 : (int)b[i];
			String hex = Integer.toHexString(v);
			if( hex.length()==1 )
				sb.append( '0' );
			sb.append( hex );
		}
		return sb.toString();
	}

	protected byte[] fromHexString( String hex )
	{
		byte[] ret = new byte[ hex.length() / 2 ];
		for(int i=0, len=hex.length(); i<len; i+=2)
		{
			int v = Integer.parseInt(hex.substring(i, i+2), 16);
			ret[i/2] = (byte)v;
		}
		return ret;
	}
	
	/**
	 * Get LocalPassword instance as singleton.
	 */
	public static LocalPassword getInstance() 
	{
		if( THIS!=null )
			return THIS;

		try
		{
			// Check that JCE exists.
			Class.forName("javax.crypto.Cipher");
			THIS = new LocalPassword();
		}
		catch( ClassNotFoundException e )
		{
			THIS = new NoJCE();
		}
		return THIS;
	}

	/**
	 * When user have not JCE lib, this LocalPassword provider 
	 * would be launched!
	 */
	static class NoJCE extends LocalPassword
	{
		private NoJCE() 
		{

		}

		public String encode( String userid, String password )
		{
			return password;
		}

		public String decode( String userid, String encoded )
		{
			return encoded;
		}
	}
}
