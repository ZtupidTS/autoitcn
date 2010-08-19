/*
 * @(#)BuddyRenderer.java
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
 *    $Id: BuddyRenderer.java,v 1.16 2002/08/24 16:27:15 pistos Exp $
 */
package rath.jmsn;

import java.awt.*;
import java.awt.event.MouseEvent;
import java.net.URL;
import java.util.Iterator;
import java.util.Hashtable;
import java.util.Enumeration;
import javax.swing.*;
import javax.swing.tree.*;

import rath.msnm.MSNMessenger;
import rath.msnm.BuddyList;
import rath.msnm.UserStatus;
import rath.msnm.LocalCopy;
import rath.msnm.entity.MsnFriend;
import rath.msnm.entity.Group;

import rath.jmsn.util.UserStatusBox;
/**
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: BuddyRenderer.java,v 1.16 2002/08/24 16:27:15 pistos Exp $
 */
public class BuddyRenderer extends DefaultTreeCellRenderer implements ToolBox
{
	public static final int VIEW_FRIENDLY_NAME = 1;
	public static final int VIEW_LOGIN_NAME = 2;
	public static final int VIEW_MYFRIENDLY_NAME = 10;

	private MsnFriend friend = null;
	private boolean sel = false;
	private Object obj = null;
	private Color selectedBack = new Color( 0x80666699 );
	private Color backColor = new Color( 0x80FFFFFF );
	private Color selectedFore = Color.white;
	private Color foreColor = Color.black;

	private Color dragFore = new Color( 0xfaac30 );
	private int draggingGroup = -1;

	/**
	 * Determine buddy's friendly name has shown. or login name.
	 */
	private int viewMode = VIEW_FRIENDLY_NAME;

	private ImageIcon imageOnline, imageOffline, imageBRB, imageBusy, imageLunch,
		imagePhone, imageAway, imageIdle, imageBlock;
	BuddyList forward = null;
	BuddyList block = null;

	public BuddyRenderer()
	{
		setOpaque( false );
		setFont( FONT_10 );
	
		imageOnline = new ImageIcon(getIconResource("online.gif"));
		imageOffline = new ImageIcon(getIconResource("offline.gif"));
		imageBusy = new ImageIcon(getIconResource("busy.gif"));
		imageBRB = new ImageIcon(getIconResource("brb.gif"));
		imageLunch = new ImageIcon(getIconResource("lunch.gif"));
		imagePhone = new ImageIcon(getIconResource("call.gif"));
		imageIdle = new ImageIcon(getIconResource("autoleft.gif"));
		imageAway = new ImageIcon(getIconResource("left.gif"));
		imageBlock = new ImageIcon(getIconResource("fuck.gif"));	
	}

	public void setForeColor( Color c )
	{
		this.foreColor = c;
	}

	public Color getForeColor()
	{
		return this.foreColor;	
	}

	public void setDraggingGroup( int index )
	{
	    this.draggingGroup = index;
	}

	public int getDraggingGroup()
	{
	    return this.draggingGroup;
	}

	/**
	 * 친구들을 어떠한 mode로 볼것인지 결정하는 것으로,
	 * VIEW_FRIENDLY_NAME, VIEW_LOGIN_NAME, VIEW_MYFRIENDLY_NAME을 설정할 수 있다.
	 */
	public void setBuddyView( int mode )
	{
		this.viewMode = mode;
	}

	public int getBuddyView()
	{
		return this.viewMode;
	}

	private URL getIconResource( String name )
	{
		return this.getClass().getResource( "/resources/icon/" + name );
	}

	protected String getGroupText( DefaultMutableTreeNode groupNode, String str )
	{
		if( forward==null ) 	
			return "";
		Integer groupIndex = ((Group)groupNode.getUserObject()).getIndex();

		int total = 0;
		for(Iterator i=forward.iterator(); i.hasNext(); )
		{
			MsnFriend friend = (MsnFriend)i.next();
			if( groupIndex.equals(friend.getGroupIndex()) )
				total++;
		}

		int online = 0;
		for(Enumeration e=groupNode.children(); e.hasMoreElements(); )
		{
			MsnFriend friend = (MsnFriend)
				(((DefaultMutableTreeNode)e.nextElement()).getUserObject());
			if( !friend.getStatus().equals(UserStatus.OFFLINE) )
				online++;
		}
		return str + " (" + online + "/" + total + ")";
	}

	public Component getTreeCellRendererComponent( JTree tree, Object value, boolean sel,
		boolean expanded, boolean leaf, int row, boolean hasFocus )
	{
		DefaultMutableTreeNode node = (DefaultMutableTreeNode)value;
		Object obj = node.getUserObject();
		this.obj = obj;
		int groupIndex = -1;
		if( obj instanceof MsnFriend )
		{
			this.friend = (MsnFriend)obj;

		    groupIndex = friend.getGroupIndex().intValue();
			String status = friend.getStatus();
			if( status==null || status.equals(UserStatus.ONLINE) )
			{
				status = "";
				setIcon( imageOnline );
			}
			else
			{
				setIcon( imageOnline );

				if( status.equals(UserStatus.BE_RIGHT_BACK) )
					setIcon( imageBRB );
				else
				if( status.equals(UserStatus.IDLE) )
					setIcon( imageIdle );
				else
				if( status.equals(UserStatus.AWAY_FROM_COMPUTER) )
					setIcon( imageAway );
				else
				if( status.equals(UserStatus.BUSY) )
					setIcon( imageBusy );
				else
				if( status.equals(UserStatus.ON_THE_LUNCH) )
					setIcon( imageLunch );
				else
				if( status.equals(UserStatus.ON_THE_PHONE) )
					setIcon( imagePhone );
				else
				if( status.equals(UserStatus.OFFLINE) ||
					status.equals(UserStatus.INVISIBLE) )
					setIcon( imageOffline );

				status = " (" + UserStatusBox.getFormattedUserStatus(friend.getStatus()) + ")";
			}

			if( block!=null && 
				block.get(friend.getLoginName())!=null )
				setIcon( imageBlock );

			switch( viewMode )
			{
			case VIEW_FRIENDLY_NAME:
				setText( friend.getFormattedFriendlyName().concat(status) );
				break;
			case VIEW_LOGIN_NAME:
				setText( friend.getLoginName().concat(status) );
				break;
			case VIEW_MYFRIENDLY_NAME:
				String myName = MainFrame.LOCALCOPY.getProperty( friend.getLoginName() );
				if(myName==null)
					myName = friend.getFormattedFriendlyName();
				setText( myName.concat(status) );
				break;
			case VIEW_LOGIN_NAME | VIEW_FRIENDLY_NAME:
				StringBuffer sb = new StringBuffer();
				sb.append( friend.getFormattedFriendlyName() );
				sb.append( '(' );
				sb.append( friend.getLoginName() );
				sb.append( ") " );
				sb.append( status );
				setText( sb.toString() );
				break;				
			}
		}
		else
		if( obj instanceof Group )
		{
			Group group = (Group)obj;
			groupIndex = group.getIndexInt();
			setIcon( null );
			setText( getGroupText(node, group.getFormattedName())  );
		}

		this.sel = sel;
		setBackground( sel ? selectedBack : backColor );
		setForeground( sel ? selectedFore : (this.draggingGroup==groupIndex) ? dragFore : foreColor );

		return this;
	}

	public void paint( Graphics g )
	{
		if( obj instanceof MsnFriend ||
			obj instanceof Group )
		{
			int x = 1;
			int w = getWidth();
			int h = getHeight();
			ImageIcon icon = (ImageIcon)getIcon();
			String text = getText();
			FontMetrics fm = g.getFontMetrics(getFont());

			if( icon!=null )
			{
				g.drawImage( icon.getImage(), x, (h-icon.getIconHeight())>>1, this );
				x += icon.getIconWidth();
			}
			if( sel )
			{
			    g.setColor( getBackground() );
				g.fillRect( x, 0, w, h );
			}
			g.setFont( getFont() );
			g.setColor( getForeground() );
			int y = (h>>1)+(fm.getAscent()>>1)-(fm.getDescent()>>1)-1;
			g.drawString( text, x+2, y );
		}
		else
			super.paint( g );
	}
}