  
  $Id: README.TXT,v 1.6 2002/04/18 19:11:42 xrath Exp $
  Running JMSN 0.9.7
  ==================

  1. Requirements
  
     - Java Runtime Environment 1.3 or greater. 
       http://java.sun.com/j2se/1.4/download.html
     - jmsn.jar
     - lib/msnm.jar

  2. Running JMSN Messenger 

     - Simple type 	
       > java -jar jmsn.jar 

       if your platform is win32, Launch this! 
	   > jmsn.exe

  3. For Windows ME/2000/XP users 
     If rath_awt.dll located in lib directory and you launch jmsn with
     jmsn.exe, you can use the following additional features.
     You need (jmsn.exe, jmsn.prop, lib/rath_awt.dll). 
     These files were include by JMSN 0.9.5 distribution.

     Warning: On some windows platform with dll, JRE 1.3.x VM crashed.
              In this case, use JRE 1.4.

     + System TrayIcon
     + Transparency layered windows
     + Always on top

  4. For Linux (Korean) users.
     - Visit the following URL and you can see Hangul correctly.
       http://www.xrath.com/board/read.jsp?db=tiptech&id=48
       or
       http://kltp.kldp.org/stories.php?story=01/05/19/3275554

  5. For OS/2 Warp 4.5 users
     - Michele Della Guardia <michele.dg@libero.it> post some useful 
       starting script on OS/2 Warp 4.5.
       (where x:\ has to be changed with your own path)
     -----------------------------------
     @echo off
     set beginlibpath=x:\java13\jre\dll;
     set path=x:\java13\jre\bin;%path%
     java -jar jmsn.jar
     -----------------------------------
