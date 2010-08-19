/*
 * @(#)HangulJamoUtil.java
 *
 * Copyright (c) 2002 Jang-Ho Hwang,
 * All Rights Reserved.
 */
package rath.util;

import java.io.CharArrayWriter;
/**
 * Charset Converting utililty for
 * HANGUL_JAMO to HANGUL_SYLLABILIS
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: HangulJamoUtil.java,v 1.2 2002/04/18 17:01:54 xrath Exp $, since 2002/04/18
 */
public class HangulJamoUtil
{
	public static char createChar( int[] chars, int len )
	{
		int ch = 44032;
		switch(len)
		{
		case 1:
			ch += chars[0] * 588;
			break;
		case 2:
			ch += chars[0] * 588 + chars[1] * 28;
			break;
		case 3:
			ch += chars[0] * 588 + chars[1] * 28 + chars[2] + 1;
			break;
		default:
			ch = 0;
		}
		return (char)ch;
	}

	public static String getString( String jamo )
	{
		char[] chs = new char[ jamo.length() ];
		jamo.getChars( 0, chs.length, chs, 0 );

		CharArrayWriter caw = new CharArrayWriter();
		int[] chars = new int[3];

		for(int i=0; i<chs.length; i++)
		{
			chars[0] = chars[1] = chars[2] = 0;

			int ich = (int)chs[i];
			if( ich < 4352 || ich > 4607 )
			{
				caw.write( chs[i] );
				continue;
			}
			if( ich >= 4352 && ich <= 4370 ) // 초성
			{
				chars[0] = ich - 4352;
				if( (i+1)!=chs.length )
				{
					int ich2 = (int)chs[i+1];
					if( ich2 >= 4449 && ich2 <= 4469 )
					{
						i++;
						chars[1] = ich2 - 4449;
						if( (i+1)!=chs.length )
						{
							int ich3 = (int)chs[i+1];

							if( ich3 >= 4520 && ich <= 4546 )
							{
								i++;
								chars[2] = ich3 - 4520;
								// 초성 중성 종성 
								caw.write( createChar(chars, 3) );
							}
							else
								// 초성 중성
								caw.write( createChar(chars, 2) );
						}
					}
					else
						// 초성 하나짜리 
						caw.write( createChar(chars, 1) );
				}
			}
			else
				caw.write( '?' );
		}

		return new String(caw.toCharArray());
	}

	public static void main( String[] args ) throws Exception
	{
		System.out.println( getString("English Korean 하이 -_-") );
	}
}
