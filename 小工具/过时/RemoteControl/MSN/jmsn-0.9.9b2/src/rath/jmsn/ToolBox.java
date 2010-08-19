/*
 * @(#)ToolBox.java
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
 *    $Id: ToolBox.java,v 1.1.1.1 2002/03/08 21:20:45 xrath Exp $
 */
package rath.jmsn;

import java.awt.Color;
import java.awt.Font;
/**
 * All fonts and color to use whole application
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: ToolBox.java,v 1.1.1.1 2002/03/08 21:20:45 xrath Exp $
 */
public interface ToolBox
{
	public static final Font MENU_HEADER_FONT = new Font("Dialog", Font.PLAIN, 12);
	public static final Font MENU_FONT = new Font("Dialog", Font.PLAIN, 12);
	public static final Font FONT = new Font("Dialog", Font.PLAIN, 12);
	public static final Font FONT_10 = new Font("Dialog", Font.PLAIN, 12);
	public static final Font FONT_BOLD = new Font("Dialog", Font.BOLD, 12);
}
