/*
 * @(#)NativeToolkit.java
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
 *    $Id: NativeToolkit.java,v 1.6 2004/06/07 06:02:15 xrath Exp $
 */
package rath.jmsn;

import java.awt.*;

import rath.NotSupportedPlatformException;
import rath.tools.Win32Toolkit;
import rath.tools.tray.*;
/**
 * Native toolkit class
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version 1.0.000, 2002/03/17
 */
public class NativeToolkit
{
	private static NativeToolkit tk = null;
	private Win32Toolkit win32tk;
	private TrayIconManager tim;
	public boolean isWin9x;
	public boolean isWin2k;
	public boolean isWindows;
	public boolean isMacOS;

	private NativeToolkit()
	{
		prepareWindows();
		prepareMacOSX();
	}

	private void prepareWindows()
	{
		String os = System.getProperty("os.name");
		if( os.startsWith("Windows 9") ||
			os.startsWith("Windows N") )
		{
			try
			{
			    win32tk = Win32Toolkit.getInstance();
				isWin9x = true;
				isWindows = true;
			}
			catch( NotSupportedPlatformException e ) {}
			catch( UnsatisfiedLinkError e ) {}
		}
		else
		{
			try
			{
				win32tk = Win32Toolkit.getInstance();
				isWin2k = true;
				isWindows = true;
			}
			catch( NotSupportedPlatformException e ) {}
			catch( UnsatisfiedLinkError e ) {}
		}
		if( os.startsWith("Windows") )
		{
			if( win32tk!=null )
			    tim = new TrayIconManager( win32tk );
		}
	}

	private void prepareMacOSX()
	{
		isMacOS = false;
	}

	public void makeTransparency( Window window, int alpha )
	{
	    if( isWin2k )
			win32tk.makeTransparency(window, alpha);
	}

	public void makeTopMost( Window window, boolean enable )
	{
	    if( isWindows )
		    win32tk.makeTopMost(window, enable);
	}

	/**
	 * Win32 only.
	 *
	 * @param icon
	 * @param listener
	 */
	public void addTrayIcon( TrayIcon icon )
	{
	    if( isWin9x || isWin2k )
		{
			tim.addTrayIcon( icon, new TrayEventAdapter() {
				public void mouseDblClicked( Point p )
				{
					MainFrame.INSTANCE.setVisible(true);
				}
			});
		}
	}

	public void setTrayIcon( TrayIcon icon, int field )
	{
	    if( isWindows )
		{
		    tim.modifyTrayIcon( icon, field );
		}
	}

	public synchronized static NativeToolkit getInstance()
	{
		if( tk==null )
		{
		    tk = new NativeToolkit();
		}
		return tk;
	}
}