/*
 * @(#)FileItem.java
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
 *    $Id: FileItem.java,v 1.1.1.1 2002/03/08 21:20:45 xrath Exp $
 */
package rath.jmsn.entity;

import rath.msnm.SwitchboardSession;
/**
 * 수신될 파일을 나타내는 entity 클래스이다.
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: FileItem.java,v 1.1.1.1 2002/03/08 21:20:45 xrath Exp $
 */
public class FileItem
{
	private SwitchboardSession session;
	private int cookie;
	private String filename;
	private int size;

	public FileItem( SwitchboardSession ss, int cookie, String filename, int size )
	{
		this.session = ss;
		this.cookie = cookie;
		this.filename = filename;
		this.size = size;
	}

	public SwitchboardSession getSession()
	{
		return this.session;
	}

	public int getCookie()
	{
		return this.cookie;
	}

	public String getName()
	{
		return this.filename;
	}

	public int getSize()
	{
		return this.size;
	}

	public String getKBSize()
	{
		return String.valueOf( size >> 10 ) + "KB";
	}
}
