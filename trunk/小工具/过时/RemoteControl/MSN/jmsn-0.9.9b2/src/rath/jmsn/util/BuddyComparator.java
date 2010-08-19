/*
 * @(#)BuddyComparator.java
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
 *    $Id: BuddyComparator.java,v 1.1 2002/03/10 04:58:19 xrath Exp $
 */
package rath.jmsn.util;

import java.util.Comparator;

import rath.msnm.UserStatus;
import rath.msnm.entity.MsnFriend;

import rath.jmsn.BuddyRenderer;
/**
 * 각 버디들의 Node를 Tree에 배치하는 정렬 순서를 결정해주는 Comparator 클래스이다.
 * <p>
 * 비교 순서는 일단 우선순위는 <b>상태</b>이다.
 * 상태는 우선순위는 다음과 같다.
 * <p>
 * 온라인 &gt; 바쁨, 통화중, 식사중 &gt; 자리비움, 자동자리비움 &gt; 오프라인
 * <p>
 * 그리고 같은 상태의 친구들간에는 현재 표시이름(LoginName이던, FriendlyName이던)에 따라
 * 정렬된다.
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: BuddyComparator.java,v 1.1 2002/03/10 04:58:19 xrath Exp $
 */
public class BuddyComparator implements Comparator
{
	private int viewMode = BuddyRenderer.VIEW_FRIENDLY_NAME;

	/**
	 * 현재 보기 상태가 Email인지 아닌지를 설정한다.
	 *
	 * @param viewEmail
	 */
	public void setBuddyView( int mode )
	{
		this.viewMode = mode;
	}

	/**
	 * 현재 보기 상태가 Email인지 아닌지를 확인한다.
	 *
	 * @return Email로 보기라면 true, 아니라면 false를 반환할 것이다.
	 */
	public int getBuddyView()
	{
	    return this.viewMode;
	}

    public int compare(Object o1, Object o2)
    {
		MsnFriend f0 = (MsnFriend)o1;
		MsnFriend f1 = (MsnFriend)o2;

		String s0 = f0.getStatus();
		String s1 = f1.getStatus();

		String name0 = viewMode!=BuddyRenderer.VIEW_FRIENDLY_NAME ? f0.getLoginName() : f0.getFriendlyName();
		String name1 = viewMode!=BuddyRenderer.VIEW_FRIENDLY_NAME ? f1.getLoginName() : f1.getFriendlyName();

		boolean online0 = s0.equals(UserStatus.ONLINE);
		boolean online1 = s1.equals(UserStatus.ONLINE);

		// 한명이 ONLINE이고, 나머지는 ONLINE이 아닐때.
		if( online0 && !online1 ) return -50000;
		if( !online0 && online1 ) return 50000;
		// 둘다 온라인이면 이름으로 비교
	    if( online0 && online1 ) return name0.compareTo( name1 );

		// 여기까지 왔다면, 무조건 온라인은 아니다.
		boolean busy0 =
			s0.equals(UserStatus.BE_RIGHT_BACK) || s0.equals(UserStatus.BUSY) ||
			s0.equals(UserStatus.ON_THE_LUNCH) || s0.equals(UserStatus.ON_THE_PHONE);
		boolean busy1 =
			s1.equals(UserStatus.BE_RIGHT_BACK) || s1.equals(UserStatus.BUSY) ||
			s1.equals(UserStatus.ON_THE_LUNCH) || s1.equals(UserStatus.ON_THE_PHONE);

		if( busy0 && !busy1 ) return -40000;
		if( !busy0 && busy1 ) return 40000;
		if( busy0 && busy1 ) return name0.compareTo( name1 );

		boolean away0 = s0.equals(UserStatus.AWAY_FROM_COMPUTER) || s0.equals(UserStatus.IDLE);
		boolean away1 = s1.equals(UserStatus.AWAY_FROM_COMPUTER) || s1.equals(UserStatus.IDLE);

		if( away0 && !away1 ) return -30000;
		if( !away0 && away1 ) return 30000;
		if( away0 && away1 ) return name0.compareTo( name1 );

		return name0.compareTo( name1 );
    }

    public boolean equals(Object obj)
    {
		return false;
    }
}