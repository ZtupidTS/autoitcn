/*
 * @(#)FontDialog.java
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
 *    $Id: FontDialog.java,v 1.9 2002/08/12 03:01:11 xrath Exp $
 */
package rath.jmsn.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;
import javax.swing.border.TitledBorder;
import javax.swing.border.EtchedBorder;

import rath.msnm.LocalCopy;

import rath.jmsn.MainFrame;
import rath.jmsn.ToolBox;
import rath.jmsn.util.Msg;
/**
 * 폰트 설정하는 다이얼로그
 *
 * @author Jang-Ho Hwang, rath@linuxkorea.co.kr
 * @version $Id: FontDialog.java,v 1.9 2002/08/12 03:01:11 xrath Exp $
 */
public class FontDialog extends DefaultDialog implements ToolBox, ActionListener
{
	private JLabel preview = null;
	private JTextField fontNameField = null;
	private JTextField fontSizeField = null;
	private JList fontName = null;
	private DefaultListModel fontNameModel = null;
	private JList fontSize = null;
	private DefaultListModel fontSizeModel = null;
	private JCheckBox italic = null;
	private JCheckBox bold = null;
	private JCheckBox underline = null;
	private JCheckBox strikethrough = null;
	private JCheckBox isRandomColor = null;
	private JButton fontColor = null;
	private static final String DEFAULT_FONT_NAME = "굴림체";
	private static final int DEFAULT_FONT_SIZE = 12;

	public FontDialog( Frame owner )
	{
		super( owner );
		setTitle( Msg.get("title.changefont") );
		createComponents();
		loadProperties();
	}

	private void createComponents()
	{
		setSize( 340, 250 );
		JPanel panel = (JPanel)getContentPane();

		preview = new JLabel( Msg.get("label.fontpreviewstring") );
		preview.setPreferredSize(new Dimension(100,50));

		TitledBorder tb = new TitledBorder(new EtchedBorder(), Msg.get("label.fontpreview"));
		tb.setTitleFont( FONT );
		preview.setBorder(tb);
		preview.setAlignmentX(SwingConstants.CENTER);
		JPanel centerPanel = new JPanel(new BorderLayout());

		JPanel fontNamePanel = new JPanel(new BorderLayout());
		tb = new TitledBorder(new EtchedBorder(), Msg.get("label.font"));
		tb.setTitleFont( FONT );
		fontNamePanel.setBorder(tb);
		fontNamePanel.setPreferredSize(new Dimension(165,15));

		fontNameField = new JTextField();
		fontNameField.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				fontNameChangeFromField();
			}
		});

		fontNameModel = new DefaultListModel();
		GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
		String[] fontList = ge.getAvailableFontFamilyNames();
		for(int i=0; i<fontList.length; i++)
			fontNameModel.addElement(fontList[i]);

		fontName = new JList(fontNameModel);
		fontName.addListSelectionListener( new ListSelectionListener() {
			public void valueChanged( ListSelectionEvent e )
			{
				fontNameChangeFromList();
			}
		});

		fontName.setFont( FONT );
		fontNamePanel.add(fontNameField, "North" );
		fontNamePanel.add(new JScrollPane(fontName), "Center");

		JPanel fontSizePanel = new JPanel(new BorderLayout());
		tb = new TitledBorder(new EtchedBorder(), Msg.get("label.fontsize"));
		tb.setTitleFont( FONT );
		fontSizePanel.setBorder(tb);

		fontSizeField = new JTextField();
		fontSizeField.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				fontSizeChangeFromField();
			}
		});

		fontSizeModel = new DefaultListModel();
        for(int i=9; i<=16; i++)
            fontSizeModel.addElement( String.valueOf(i) );
		fontSize = new JList(fontSizeModel);

		fontSize.addListSelectionListener( new ListSelectionListener() {
			public void valueChanged( ListSelectionEvent e )
			{
				fontSizeChangeFromList();
			}
		});
		fontSize.setFont( FONT );
		fontSizePanel.add(fontSizeField, "North" );
		fontSizePanel.add(new JScrollPane(fontSize), "Center");

		JPanel fpPanel = new JPanel();
		tb = new TitledBorder(new EtchedBorder(), Msg.get("label.fontproperties"));
		tb.setTitleFont( FONT );
		fpPanel.setBorder(tb);
		fpPanel.setLayout(new GridLayout(6,1));
		fpPanel.setPreferredSize(new Dimension(110,15));

		bold = new JCheckBox( Msg.get("label.fontbold") );
		bold.setFont( FONT );
		bold.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				setBold();
			}
		});
		italic = new JCheckBox( Msg.get("label.fontitalic") );
		italic.setFont( FONT );
		italic.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				setItalic();
			}
		});
		underline = new JCheckBox( Msg.get("label.fontunderline") );
		underline.setFont( FONT );
		underline.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				setUnderline();
			}
		});
		strikethrough = new JCheckBox( Msg.get("label.fontstrikethrough") );
		strikethrough.setFont( FONT );
		strikethrough.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				setStrikethrough();
			}
		});
		isRandomColor = new JCheckBox( Msg.get("label.israndomcolor") );
		isRandomColor.setFont( FONT );
		isRandomColor.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				setRandomColor();
			}
		});
		fontColor = new JButton();
		fontColor.setBorder(null);
		fontColor.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				setColor();
			}
		});

		fpPanel.add(bold);
		fpPanel.add(italic);
		fpPanel.add(underline);
		fpPanel.add(strikethrough);
		fpPanel.add(isRandomColor);
		fpPanel.add(fontColor);

		centerPanel.add(fontNamePanel, "Center");
		centerPanel.add(fpPanel, "East");

		JPanel buttonPanel = new JPanel( new FlowLayout(FlowLayout.CENTER, 10, 4) );
		JButton okButton = new JButton( Msg.get("button.ok") );
		okButton.setFont( FONT );
		okButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				dispose();
				processChange();
			}
		});

		JButton cancelButton = new JButton( Msg.get("button.cancel") );
		cancelButton.setFont( FONT );
		cancelButton.addActionListener( new ActionListener() {
			public void actionPerformed( ActionEvent e )
			{
				dispose();
			}
		});
		buttonPanel.add( okButton );
		buttonPanel.add( cancelButton );

		panel.add( preview, "North" );
		panel.add( centerPanel, "Center" );
		panel.add( buttonPanel, "South" );
	}

	public void actionPerformed( ActionEvent e )
	{

	}

	protected void setRandomColor()
    {
        fontColor.setEnabled( !isRandomColor.isSelected() );
	}

	protected void setColor()
    {
		Color c =  JColorChooser.showDialog(this, Msg.get("label.choosefontcolor") , fontColor.getBackground() );
		fontColor.setBackground(c);
		preview.setForeground(c);
	}

	protected void setBold()
	{
        int i = italic.isSelected() ? Font.ITALIC : 0;
        Font font = preview.getFont();
        preview.setFont( bold.isSelected() ?
            font.deriveFont(Font.BOLD+i) :
            font.deriveFont(Font.PLAIN+i) );
	}

	protected void setItalic()
	{
		int b = bold.isSelected() ? Font.BOLD : 0;
        Font font = preview.getFont();
        preview.setFont( italic.isSelected() ?
            font.deriveFont(Font.ITALIC+b) :
            font.deriveFont(Font.PLAIN+b) );
	}

	protected void setUnderline()
	{

	}

	protected void setStrikethrough()
	{

	}

	protected void fontNameChangeFromField()
	{
		String fn = fontNameField.getText();
		if(fontNameModel.contains(fn))
        {
			int idx = fontNameModel.indexOf(fn);
			fontName.setSelectedIndex(idx);
			preview.setFont(new Font( fn, preview.getFont().getStyle(), Integer.parseInt(fontSize.getSelectedValue().toString()) ) );
		}
        else
			JOptionPane.showMessageDialog(this,"입력하신 글꼴은 존재하지 않습니다.");
	}

	protected void fontNameChangeFromList()
	{
		String fn = fontName.getSelectedValue().toString();
		fontNameField.setText(fn);
		try
        {
			preview.setFont(new Font( fn, preview.getFont().getStyle(), Integer.parseInt(fontSize.getSelectedValue().toString()) ) );
		}
        catch( NumberFormatException e )
        {
			preview.setFont(new Font( fn, preview.getFont().getStyle(), 12 ) );
		}
	}

	protected void fontSizeChangeFromField()
	{
		String fs = fontSizeField.getText();
		try
        {
            int iFs = Integer.parseInt(fs);
			if( iFs>16 || iFs<9 )
            {
				JOptionPane.showMessageDialog(this,"글자크기는 9~16 사이어야 합니다.");
			}
            else
            {
				if(fontSizeModel.indexOf(fs)!=-1)
                {
					int idx = fontSizeModel.indexOf(fs);
					fontSize.setSelectedIndex(idx);
					preview.setFont( preview.getFont().deriveFont( Float.parseFloat(fs) ) );
				}
                else
					fontSize.clearSelection();
			}
		}
        catch( NumberFormatException e )
        {
			JOptionPane.showMessageDialog(this,"글자크기는 9~16 사이어야 합니다.");
		}
	}

	protected void fontSizeChangeFromList()
	{
		String fs = fontSize.getSelectedValue().toString();
		fontSizeField.setText(fs);
		preview.setFont( preview.getFont().deriveFont( Float.parseFloat(fs) ) );
	}

	protected void loadProperties()
    {
        LocalCopy local = MainFrame.LOCALCOPY;

		String fn = local.getProperty("font.name", DEFAULT_FONT_NAME);
		String fs = local.getProperty("font.size", Integer.toString(DEFAULT_FONT_SIZE));
        boolean ir = local.getPropertyBoolean("font.israndomcolor", true);

		int red = 0;
		int green = 0;
		int blue = 0;
		try
        {
			red = Integer.parseInt(local.getProperty("font.red") );
			green = Integer.parseInt(local.getProperty("font.green") );
			blue = Integer.parseInt(local.getProperty("font.blue") );
		}
        catch( NumberFormatException e )
        {
			red = green = blue = 0;
		}

        boolean b = local.getPropertyBoolean("font.isBold", false);
        boolean i = local.getPropertyBoolean("font.isItalic", false);
        boolean s = local.getPropertyBoolean("font.isStrikeThrough", false);
        boolean u = local.getPropertyBoolean("font.isUnderline", false);

		// font size setting
		try
        {
            int iFs = Integer.parseInt(fs);
			if( iFs>16 || iFs<9 )
            {
				preview.setFont( preview.getFont().deriveFont( DEFAULT_FONT_SIZE ) );
			}
            else
            {
				if(fontSizeModel.indexOf(fs)!=-1)
                {
					int idx = fontSizeModel.indexOf(fs);
					fontSize.setSelectedIndex(idx);
					preview.setFont( preview.getFont().deriveFont( Float.parseFloat(fs) ) );
				}
                else
					fontSize.clearSelection();
			}
		}
        catch( NumberFormatException e )
        {
			preview.setFont( preview.getFont().deriveFont( DEFAULT_FONT_SIZE ) );
		}

		// font name setting
		if(fontNameModel.contains(fn))
        {
			int idx = fontNameModel.indexOf(fn);
			fontName.setSelectedIndex(idx);
			preview.setFont(new Font( fn, Font.PLAIN, Integer.parseInt(fontSize.getSelectedValue().toString()) ) );
		}
        else
			preview.setFont(new Font( DEFAULT_FONT_NAME, Font.PLAIN, Integer.parseInt(fontSize.getSelectedValue().toString()) ) );

		// font type
		bold.setSelected(b);
		setBold();
		underline.setSelected(u);
		strikethrough.setSelected(s);
		isRandomColor.setSelected(ir);
		if(ir)
			fontColor.setEnabled(false);
		
		italic.setSelected(i);
		setItalic();

        Color c = new Color(red, green, blue);
		fontColor.setBackground( c );
		preview.setForeground( c );
	}

	protected void saveProperties()
    {
        LocalCopy local = MainFrame.LOCALCOPY;
		try
		{
            boolean ir = isRandomColor.isSelected();
            local.setProperty("font.israndomcolor", String.valueOf(ir) );
            Color c = fontColor.getBackground();
            local.setProperty("font.red", String.valueOf(c.getRed()) );
            local.setProperty("font.green", String.valueOf(c.getGreen()) );
            local.setProperty("font.blue", String.valueOf(c.getBlue()) );
            local.setProperty("font.size", String.valueOf(fontSize.getSelectedValue()) );
            local.setProperty("font.name", fontName.isSelectionEmpty() ?
                DEFAULT_FONT_NAME : String.valueOf(fontName.getSelectedValue()) );

            local.setProperty("font.isBold", String.valueOf(bold.isSelected()) );
            local.setProperty("font.isItalic", String.valueOf(italic.isSelected()) );
            local.setProperty("font.isStrikeThrough", String.valueOf(strikethrough.isSelected()) );
            local.setProperty("font.isUnderline", String.valueOf(underline.isSelected()) );
			local.storeInformation();
		}
		catch( Exception e )
		{
		    e.printStackTrace();
		}
	}

	protected void processChange()
	{
		saveProperties();
	}
}

