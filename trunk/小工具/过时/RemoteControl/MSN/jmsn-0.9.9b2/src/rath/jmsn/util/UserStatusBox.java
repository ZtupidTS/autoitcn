/*
 * @(#)UserStatusBox.java
 *
 * Copyright (c) 2001-2002, JangHo Hwang
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
 * 	3. Neither the name of the JangHo Hwang nor the names of its contributors
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
 *    $Id: UserStatusBox.java,v 1.3 2002/03/15 04:45:42 xrath Exp $
 */
package rath.jmsn.util;

import java.lang.reflect.Field;
import java.util.Enumeration;
import java.util.Properties;

import rath.msnm.UserStatus;
/**
 *
 * @author Jangho Hwang, rath@linuxkorea.co.kr
 * @version 1.0.000, 2002/03/13
 */
public class UserStatusBox
{
    private static Properties statusProp = new Properties();

    static
    {
        collectAll();
    }

    public static void collectAll()
    {
        try
        {
            Field fields[] = (rath.msnm.UserStatus.class).getDeclaredFields();
            for(int i = 0; i < fields.length; i++)
            {
                Field f = fields[i];
                if(f.getType().equals(java.lang.String.class))
                {
                    String name = (String)f.get(null);
                    statusProp.setProperty(name, getFormattedUserStatus(name));
                }
            }

        }
        catch(IllegalAccessException e) { }
    }

    public static Properties getStatusSet()
    {
        return statusProp;
    }

    public static String getStatusAtFormattedValue(String fstr)
    {
        for(Enumeration e = statusProp.propertyNames(); e.hasMoreElements();)
        {
            String code = (String)e.nextElement();
            String fvalue = statusProp.getProperty(code);
            if(fvalue.equals(fstr))
                return code;
        }

        return null;
    }

	/**
	 * UserStatus의 String code의 뜻(사람이 알아보기 쉬운 문자열)을 반환한다.
	 * 예를 들어 code에 <b>UserStatus.ONLINE</b>을 넘겼다면 <b>온라인</b>이 반환될 것이고,
	 * <b>UserStatus.BE_RIGHT_BACK</b>을 넘겼다면 <b>곧 돌아오겠음</b>이라는 문자열이
	 * 반환될 것이다.
	 */
	public static String getFormattedUserStatus( String code )
	{
		if( code.equals(UserStatus.ONLINE) )
			return Msg.get("status.online");
		else
		if( code.equals(UserStatus.OFFLINE) )
			return Msg.get("status.offline");
		else
		if( code.equals(UserStatus.AWAY_FROM_COMPUTER) )
			return Msg.get("status.away");
		else
		if( code.equals(UserStatus.BE_RIGHT_BACK) )
			return Msg.get("status.brb");
		else
		if( code.equals(UserStatus.BUSY) )
			return Msg.get("status.busy");
		else
		if( code.equals(UserStatus.IDLE) )
			return Msg.get("status.idle");
		else
		if( code.equals(UserStatus.INVISIBLE) )
			return Msg.get("status.hidden");
		else
		if( code.equals(UserStatus.ON_THE_LUNCH) )
			return Msg.get("status.eat");
		else
		if( code.equals(UserStatus.ON_THE_PHONE) )
			return Msg.get("status.phone");

		return Msg.get("status.unknown");
	}
}
