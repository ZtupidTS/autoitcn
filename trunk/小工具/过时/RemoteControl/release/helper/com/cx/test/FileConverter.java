/*
 * Created on 2007-7-24
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package com.cx.test;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

/**
 * @author Administrator
 *
 */
public class FileConverter {
	public static void main(String args[]) throws Exception {
		if (args.length == 0) {
			System.exit(0);
		}
		File file = new File(args[0]);
		FileInputStream fi = new FileInputStream(file);
		
		InputStreamReader ir = new InputStreamReader(fi, "UTF-8");
		char[] ch = new char[(int)file.length()];
		ir.read(ch, 0, ch.length);
		FileOutputStream fo = new FileOutputStream(args[0]);
		BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(fo,"gb2312"));
		bw.write(ch);
		bw.flush();
	}
	
}
