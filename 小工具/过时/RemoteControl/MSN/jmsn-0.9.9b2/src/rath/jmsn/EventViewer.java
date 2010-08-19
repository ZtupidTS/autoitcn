/*
 * @(#)EventViewer.java
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
 *    $Id: EventViewer.java,v 1.4 2002/08/15 15:33:20 xrath Exp $
 */
package rath.jmsn;

import java.awt.*;
import javax.swing.*;

import java.util.Date;
import java.text.SimpleDateFormat;

import rath.msnm.entity.MsnFriend;
/**
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: EventViewer.java,v 1.4 2002/08/15 15:33:20 xrath Exp $
 */
public class EventViewer extends JComboBox implements ToolBox
{
	private SimpleDateFormat sdf = new SimpleDateFormat("[HH:mm]");
	private int limitSize = 30;

	public EventViewer()
	{
		setFont( FONT );
	}

	/**
	 * 이 Event viewer가 한번에 보여줄 수 있는 최대 크기를 결정한다.
	 */
	public void setLimitSize( int size )
	{
		this.limitSize = size;
	}

	public int getLimitSize()
	{
		return this.limitSize;
	}

	private boolean fireEvent = true;

	public void addEvent( String msg, MsnFriend friend )
	{
		String view = sdf.format(new Date()) + " " + msg;
		insertItemAt( new Event(view, friend), 0 );
		ensureLimitOverflow();

		fireEvent = false;
		setSelectedIndex( 0 );
		fireEvent = true;
	}

	protected void ensureLimitOverflow()
	{
		if( getItemCount()>limitSize )
		{
			for(int i=getItemCount()-1; i>=limitSize; i--)
				removeItemAt(i);
		}
	}

	/**
	 * Override. Only accept to EventDispatchThread call.
	 */
	protected void fireActionEvent()
	{
		if( fireEvent )
			super.fireActionEvent();
	}

	public static class Event
	{
		private String msg;
		private MsnFriend friend;

		private Event( String msg, MsnFriend friend )
		{
			this.msg = msg;
			this.friend = friend;
		}

		public MsnFriend getFriend()
		{
			return this.friend;
		}

		public String toString()
		{
			return this.msg;
		}
	};

	public void clear()
	{

	}
}
