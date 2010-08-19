/*
 * @(#)ZippedDirectoryDialog.java
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
 *    $Id: ZippedDirectoryDialog.java,v 1.2 2002/03/13 09:40:39 xrath Exp $
 */
package rath.jmsn.ui;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

import java.io.File;
import java.io.IOException;

import rath.jmsn.ToolBox;
import rath.jmsn.ui.DefaultDialog;
import rath.jmsn.util.Msg;
import rath.util.ZipManager;
/**
 * 디렉토리를 ProgressBar를 보여주며 압축하고, 압축한 파일을 반환해주는 다이얼로그.
 *
 * @author Jangho Hwang, rath@linuxkorea.co.kr
 * @version $Id: ZippedDirectoryDialog.java,v 1.2 2002/03/13 09:40:39 xrath Exp $
 */
public class ZippedDirectoryDialog extends DefaultDialog implements ToolBox
{
	private File dir = null;
	private File temp = null;
	private ZipManager zip = null;
	private JLabel statusLabel = null;
	private JProgressBar progress = null;

	private boolean isComplete = false;
	private Thread zipThread = null;

    public ZippedDirectoryDialog( Frame owner, File dir )
    {
		super( owner );

		this.dir = dir;
		this.temp = new File( System.getProperty("java.io.tmpdir"), dir.getName() + ".zip" );
		this.zip = new ZipManager() {
			protected void compressComplete( File file )
			{
				increaseProgress();
			}
		};
		this.zip.setArchiveRoot( dir.getAbsolutePath() );
		createUI();
    }

	private void increaseProgress()
	{
		SwingUtilities.invokeLater( new Runnable() {
		    public void run()
			{
				int current = progress.getValue() + 1;
				int max = progress.getMaximum();
				int percent = (int)(((float)current / (float)max) * 100.0f);
				progress.setValue( current );
				progress.setString( percent + "%" );

				if( percent==100 )
				{
					isComplete = true;
					dispose();
				}
			}
		});
	}

	private void processError( final IOException e )
	{
		SwingUtilities.invokeLater( new Runnable() {
			public void run()
			{
				statusLabel.setText( Msg.get("zipdlg.msg.fail", e.getMessage()) );
				try
				{
					Thread.currentThread().sleep( 2000L );
				}
				catch( InterruptedException ex ) {}
				temp = null;
				dispose();
			}
		});
	}

	private void createUI()
	{
		setSize( 250, 100 );

		JPanel panel = (JPanel)getContentPane();
		panel.setLayout( new BorderLayout() );

		statusLabel = new JLabel( Msg.get("zipdlg.msg.ready"), SwingConstants.CENTER );
		statusLabel.setFont( FONT );
		progress = new JProgressBar();
		progress.setStringPainted( true );

		panel.add( statusLabel, "Center" );
		panel.add( progress, "South" );

		addComponentListener( new ComponentAdapter() {
			public void componentShown( ComponentEvent e )
			{
				doStart();
			}
		});
	}

	/**
	 * EventDispatchThread 내부에서 수행된다.
	 */
	protected void doStart()
	{
		if( zipThread==null )
		{
		    progress.setMaximum( getFileCount(dir) );
			statusLabel.setText( Msg.get("zipdlg.msg.working") );

			zipThread = new Thread( new Runnable() {
				public void run()
				{
					try
					{
					    zip.doCompress( dir, temp );
					}
					catch( IOException e )
					{
						processError(e);
					}
				}
			});
			zipThread.start();
		}
	}

	private int getFileCount( File dir )
	{
		return recursiveDirectory( dir );
	}

	private int recursiveDirectory( File dir )
	{
		int count = 0;
		File[] files = dir.listFiles();
		for(int i=0; i<files.length; i++)
		{
			File f = files[i];
			if( f.isDirectory() )
				count += recursiveDirectory(f);
			else
				count++;
		}
		return count;
	}

	public void dispose()
	{
		if( zipThread!=null )
		{
			if( !isComplete )
			{
			    zipThread.interrupt();
				temp.deleteOnExit();
			}
		}
		super.dispose();
	}

	public File getZippedFile()
	{
	    return isComplete ? this.temp : null;
	}
}