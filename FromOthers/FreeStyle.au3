$FS_version=0.93
;#=#INDEX#==================================================================================================================#
;#	Title .........: FreeStyle v 0.93	for AutoIt3																			#
;#	Date ..........: 12.7.08																									#
;#	Theme..........: 1.) Administrate Includes Library, full text search, find, view and edit Global Constants and UDF		# 
;#					 2.) Browse, find and run single UDF helpfiles and examples												#
;#					 3.) Patch scripts, free them from Includes, insert Global Constant Values and necessary UDF			#
;#					 4.) FreeStyle customized Editor (under construction)													#
;#	Object.........: make scripts resistant to 'script-breaking changes' in AutoIt											#
;#					 improve handling and testing of includes, examples and helpfiles										#
;#					 UDF resources and Information Central																	#
;#	Status.........: beta testing version, most features available															#
;#					 Library functions almost completely working, duplicates handling under heavy construction				#
;#					 At this state, please ignore or overwrite duplicates, do not enumerate them !							#
;#					 Enumerating entries still experimental																	#
;#					 Library perfectly handles Enums, Arrays and even PaulIA's linebreaking dll definitions ! :-)			#
;#					 Patching still slow but working, in nearly all cases without additional manual work					#
;#					 Exception: IE.au3 and Word.au3 don't work yet															#
;#					 drag and droppable for Includes, scripts and directoriers, drop-pass-thru 99% working					#
;#					 Search function (almost?) complete																		#
;#					 Editor still very basic, only one window possible yet													#
;#					 clip working, paste not yet																			#
;#					 log and history features (restore points) not yet implemented											#
;#					 skipped files and summary reports (messageboxes) are still nonsense, please ignore them				#
;#					 lots of planned features to be added																	#
;#					 command line param handling to be added																#
;#					 integration to SciTE and AutoIt preprocessing function planned, context menu and SciTE hotkey			#
;#					 this program is constantly scraping AutoIt limitations and works beyond them							#
;#	OS.............: Win XP SP2, does not work on Win9x (I presume)															#
;#					 Vista not tested !																						#
;#	AutoIt Version.: v 3.2.8.1 and above (no includes, no need to update, no dependency on future AutoIt changes)			#
;#	Author ........: jennico (jennicoattminusonlinedotde)																	#
;#	Credits to.....: Smoke for advanced and incredibly fast (!!!) ini section reading										#
;#					 lokster, who helped me out with scilexer.dll and _scilexer.au3											#
;#					 all the others who may find parts of their scriplets in here											#
;#					 the complete AutoIt team for their brilliant work and constant improving								#
;#  My Wishes......: Someone(s) to help me speed up scanning, searching and patching processes with StrRegExp/Replace		#
;#					 Someone(s) to help me patching scripts with IE.au3 and Word.au3 included (object error)				#
;#==========================================================================================================================#
#Region;---config----------------------------------------------------------------
TraySetIcon("shell32.dll",239)
Opt("GUIDataSeparatorChar","?");kommandozeilenparameter
$msg=StringSplit(FileGetVersion("AutoIt3.exe"),".")
If $msg[3]<12 Then Opt("RunErrorsFatal",0)
Dim $s_GUI,$Sci,$user32=DllOpen("user32.dll"),$kernel32=DllOpen("kernel32.dll"),$c_copy[2],$c_state[2]=[0,1],$scriptlist,$pathlist,$scriptarray,$patharray,$chosen,$filecount,$msg=1,$Skipped,$Case=4,$c_Double=1,$f_Double=1,$Handle,$TabShown
Dim $d_array,$i_array,$c_array,$f_array,$ref="0123456789ABCDEF",$Keyword="Enter Keyword",$s_ini="FS_Library\Settings.ini",$maxstrlen=IniRead($s_ini,"Data","MaxStrLen",0)
If IniRead($s_ini,"Update","Version","")<>$FS_version Then _Changelog()
Dim $d_ini="FS_Library\Directories.ini",$i_ini="FS_Library\Includes.ini",$f_ini="FS_Library\Functions.ini",$p_ini="FS_Library\Parameters.ini",$c_ini="FS_Library\Constants.ini"
Dim $d_null="All registered Directories",$i_null="All registered Include Files",$f_null="Select a Function ...",$c_null="Select a Constant ...",$igntxt="FS_Library\Ignore.txt",$FS_Engine="FS_Search\FS_Search_Engine.au3"
Dim $alphaPath=RegRead("HKLM\SOFTWARE\AutoIt v3\AutoIt","InstallDir"),$betaPath=RegRead("HKLM\SOFTWARE\AutoIt v3\AutoIt","betaInstallDir"),$alphaVersion=StringReplace(RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\AutoIt","Version"),"v",""),$betaVersion=StringReplace(RegRead("HKLM\SOFTWARE\AutoIt v3\AutoIt","betaVersion"),"v","")
Dim $editPath=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\AutoIt3Script\Shell\Open\Command",""),$scitePath=StringReplace(RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SciTE.exe",""),"SciTE.exe",""),$sciteBuild=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SciTE4AutoIt3","DisplayName");=SciTE4AutoIt3 9/9/2007 (reg_sz);"C:\Programme\AutoIt3\SciTE\SciTE.exe" "%1"
If $betaPath="" Then $betaPath="unknown"
If $betaVersion="" Then $betaVersion="unknown"
If $editPath="" Then MsgBox(0,"Configuration Error","Failed to detect SciTE Editor on your system.         "&@LF&"Please enter path to SciTE Editor        "&@LF&"manually in the 'Settings' compartment.         ")
If StringInStr($editPath,"SciTE.exe")=0 Then
	MsgBox(0,"SciTE not shell default","Your default .au3-Editor is        "&@LF&$editPath&"        "&@LF&@LF&"Please check Editor settings           "&@LF&"in the 'Settings' compartment.         ")
	MsgBox(0,"FreeStyle Improvement Center","You may encounter problems with        "&@LF&"the editing features of FreeStyle.        "&@LF&@LF&"Please inform FSIC what editor you        "&@LF&"use and how it can be integrated !        ")
Else
	$sciteVersion=FileGetVersion($scitePath&"SciTE.exe")
	If FileExists("SciLexer.dll")=0 And FileExists(@SystemDir&"/SciLexer.dll")=0 Then
		$msg=FileCopy($scitePath&"SciLexer.dll",@ScriptDir&"\")
		If $msg=0 Then MsgBox(0,"Configuration Error","Could not find 'SciLexer.dll' on your System.        "&@LF&@LF&"Please place it manually into the script directory        "&@LF&"or the System32 drectory.")
	;	InetGet("http://www.dllbank.com/zip/s/scilexer.dll.zip","scilexer.dll.zip",1,1)
		;http://www.dllbank.com/zip/s/scilexer.dll.zip;http://www.dll-download-system.com/docman/s-dlls-not-system-/scilexer.dll/download.html
		FileCopy($scitePath&"SciLexer.dll",@SystemDir&"\")
	EndIf
EndIf
If FileExists($igntxt)=0 Then
	$igopen=FileOpen($igntxt,10)
	FileWrite($igopen,"$State?")
	FileClose($igopen)
EndIf
$ignorelist=FileRead($igntxt)
;customize installation paths and versions
#EndRegion
#Region;---gui-------------------------------------------------------------------
$m_GUI=GUICreate("  FreeStyle  ©  2008 by jennico",300,350,Default,Default,-1,16);0x00000018);
GUISetIcon("shell32.dll",239)	;indizieren dicf 0123
$tab=GUICtrlCreateTab(0,0,300,350);guienhance für yahtzee
	$on_top=GUICtrlCreateCheckbox("",282,6,14,14);282;max286
		GUICtrlSetTip(-1,"Set on Top")
	$general=GUICtrlCreateTabItem("Library Inventory")
		GUICtrlCreateGroup("",10,25,280,100)
			GUICtrlCreateLabel("Autoit Version: "&$alphaVersion,15,35,130,15)
			$a_reg=GUICtrlCreateLabel("Library Version: "&IniRead($s_ini,"AutoIt","Alpha Version"," unknown"),15,50,130,15)
			$a_icon=GUICtrlCreateIcon("shell32.dll",239,250,35,32,32)
			If FileExists($s_ini) And $alphaVersion<>IniRead($s_ini,"AutoIt","Alpha Version","") Then GUICtrlSetImage(-1,"user32.dll",101,1)
			$a_path=GUICtrlCreateLabel("Installation Path: "&IniRead($s_ini,"AutoIt","Alpha Path"," unknown"),15,70,280,15)
			$a_lower=GUICtrlCreateCheckbox("Additionally register non-uppercase Constants",48,90,235,15,0x0220)
				$msg=IniRead($s_ini,"Settings","A Lower",0)
				GUICtrlSetState(-1,$msg+128*($msg=1))
				GUICtrlSetTip(-1,"Non-uppercase constants sometimes lack reliability")
				GUICtrlSetCursor(-1,0);duplicates prompt
			GUICtrlCreateLabel("Ignore duplicate Constants / Functions",60,105,187,15);82
			$a_con=GUICtrlCreateCheckbox("",247,106,14,14,6)
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","A Con",1))
				GUICtrlSetTip(-1,"Checked = Ignore duplicate Global Constants (keep first occurrence)"&@LF&"Greyed Out = Overwrite duplicate Global Constants (keep last occurrence)"&@LF&"Unchecked = Enumerate duplicate Global Constants (keep them all)","Duplicate Global Constants Handling")
				GUICtrlSetCursor(-1,0)
			GUICtrlCreateLabel("/",262,106,5,15)
			$a_func=GUICtrlCreateCheckbox("",270,106,14,14,6);,0x0226)
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","A Func",1))
				GUICtrlSetTip(-1,"Checked = Ignore duplicate Functions (keep first occurrence)"&@LF&"Greyed Out = Overwrite duplicate Functions (keep last occurrence)"&@LF&"Unchecked = Enumerate duplicate Functions (keep them all)","Duplicate Functions Handling")
				GUICtrlSetCursor(-1,0); logs und inventory backups !!!!!!
		GUICtrlCreateGroup("",10,125,280,115)
			GUICtrlCreateLabel("Beta Version: "&$betaVersion,15,135,200,15)
			$b_reg=GUICtrlCreateLabel("Library Version: "&IniRead($s_ini,"AutoIt","Beta Version"," unknown"),15,150,200,15)
			$b_path=GUICtrlCreateLabel("Beta Path: "&IniRead($s_ini,"AutoIt","Beta Path"," unknown"),15,170,280,15)
			$b_beta=GUICtrlCreateCheckbox("Add Beta Include Directory to Library",90,190,193,15,0x0220)
				If IniRead($s_ini,"Settings","Beta","")=1 Then GUICtrlSetState(-1,129)
				GUICtrlSetCursor(-1,0)
			$b_icon=GUICtrlCreateIcon("shell32.dll",239,250,135,32,32)
			$b_lower=GUICtrlCreateCheckbox("Additionally register non-uppercase Constants",48,205,235,15,0x0220);6);wieso 3state ?
				$msg=IniRead($s_ini,"Settings","B Lower",0)
				GUICtrlSetState(-1,$msg+128*($msg=1))
				GUICtrlSetTip(-1,"Non-uppercase constants sometimes lack reliability")
				GUICtrlSetCursor(-1,0);duplicates prompt
			GUICtrlCreateLabel("Ignore duplicate Constants / Functions",60,220,187,15);82
			$b_con=GUICtrlCreateCheckbox("",247,221,14,14,6)
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","B Con",1))
				GUICtrlSetTip(-1,"Checked = Ignore duplicate Global Constants (keep first occurrence)"&@LF&"Greyed Out = Overwrite duplicate Global Constants (keep last occurrence)"&@LF&"Unchecked = Enumerate duplicate Global Constants (keep them all)","Duplicate Global Constants Handling")
				GUICtrlSetCursor(-1,0)
			GUICtrlCreateLabel("/",262,221,5,15)
			$b_func=GUICtrlCreateCheckbox("",270,221,14,14,6);,0x0226)
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","B Func",1))
				GUICtrlSetTip(-1,"Checked = Ignore duplicate Functions (keep first occurrence)"&@LF&"Greyed Out = Overwrite duplicate Functions (keep last occurrence)"&@LF&"Unchecked = Enumerate duplicate Functions (keep them all)","Duplicate Functions Handling")
				GUICtrlSetCursor(-1,0);auch disablen !
		GUICtrlCreateGroup("",45,243,210,75)
			$ges_dir=GUICtrlCreateLabel("Total scanned Directories:",50,254,200,15)
			$ges_incl=GUICtrlCreateLabel("Total registered Include files:",50,269,200,15)
			$ges_const=GUICtrlCreateLabel("Total registered Global Constants:",50,284,200,15)
			$ges_func=GUICtrlCreateLabel("Total registered Functions:",50,299,200,15)
		$g_update=GUICtrlCreateButton("Update Library",210,315,80,25)
			GUICtrlSetCursor(-1,0)
		GUICtrlSetBkColor(GUICtrlCreateLabel("",145,332,65,1),0x808080)
			GUICtrlSetState(-1,128)
		GUICtrlSetBkColor(GUICtrlCreateLabel("",145,333,65,1),0xFFFFFF)
			GUICtrlSetState(-1,128)
		GUICtrlCreateLabel("Delete Existing Entries",37,325,108,15)
		$g_delall=GUICtrlCreateCheckbox("",188,325,14,14)
			GUICtrlSetTip(-1,"Delete Entire Library")
			GUICtrlSetCursor(-1,0)
		$g_dellow=GUICtrlCreateCheckbox("",169,325,14,14)
			GUICtrlSetTip(-1,"Remove non-uppercase Constants")
			GUICtrlSetCursor(-1,0)
		$g_deldup=GUICtrlCreateCheckbox("",150,325,14,14)
			GUICtrlSetTip(-1,"Remove Duplicates")
			GUICtrlSetCursor(-1,0)
	$admin=GUICtrlCreateTabItem("Administrate")
		GUICtrlCreateGroup("Search",10,25,280,56)
			$s_edit=GUICtrlCreateEdit($Keyword,15,40,120,20)
				GUICtrlSetTip(-1,"Please AVOID spaces (results MAY be inaccurate)")
				GUICtrlSetCursor(-1,0)
				GUICtrlSetStyle(-1,0)
			$s_combo=GUICtrlCreateCombo("Search in ...",140,40,115,20,2097155);BitOR($CBS_DROPDOWNLIST,$WS_VSCROLL)
				GUICtrlSetData(-1,"Entire Library?Specified Directory?Specified File?Global Constants?Functions Library?Function Declarations")
				GUICtrlSetCursor(-1,0)
			$s_button=GUICtrlCreateButton("",260,38,24,24,0x41)
				GUICtrlSetImage(-1,"shell32.dll",23,0)
				GUICtrlSetTip(-1,"Perform Search")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$s_forum=GUICtrlCreateCheckbox("Search AutoIt Forum",15,61,116,18)
				GUICtrlSetTip(-1,@CRLF&"Limit Forum Search to Subforums by adding '§' & Forum Number to Keyword:"&@CRLF&@CRLF&"§11"&@TAB&"= General"&@CRLF&"§1"&@TAB&"= --- Announcements and Site News"&@CRLF&"§6"&@TAB&"= --- Chat"&@CRLF&"§12"&@TAB&"= AutoIt v3"&@CRLF&"§2"&@TAB&"= --- General Help and Support"&@CRLF&"§10"&@TAB&"= --- Graphical User Interface (GUI) Help and Support"&@CRLF&"§14"&@TAB&"= --- ActiveX/COM Help and Support"&@CRLF&"§9"&@TAB&"= --- Example Scripts"&@CRLF&"§26"&@TAB&"= --- Bug Reports and Feature Requests"&@CRLF&"§7"&@TAB&"= --- Developer Chat"&@CRLF&"§24"&@TAB&"= Archives"&@CRLF&"§25"&@TAB&"= --- Archived Forums"&@CRLF&"§3"&@TAB&"= --- Old Bug Reports"&@CRLF&"§16"&@TAB&"= ------ v3 Bug Reports (Open)"&@CRLF&"§15"&@TAB&"= ------ v3 Bug Reports (Fixed)"&@CRLF&"§18"&@TAB&"= ------ v3 Bug Reports (No Bug)"&@CRLF&"§4"&@TAB&"= --- Old AutoIt Feature Requests"&@CRLF&"§5"&@TAB&"= --- Old AutoIt v2 Help and Support"&@CRLF&"§8"&@TAB&"= --- Old Gaming and 'Bots"&@CRLF&@CRLF&"And/Or:"&@CRLF&@CRLF&"To Filter by Member Name, add '§' & Member Name to Keyword.","Advanced AutoIt Forum Search")
				GUICtrlSetCursor(-1,0)
			$s_comments=GUICtrlCreateCheckbox("Search in comments,too",140,62,133,17)
				GUICtrlSetCursor(-1,0)
				GUICtrlSetState(-1,1)
		GUICtrlCreateGroup("Directory Options",10,82,280,63)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",35,134,45,1),0x808080)
				GUICtrlSetState(-1,128)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",35,135,45,1),0xFFFFFF)
				GUICtrlSetState(-1,128)
			$d_combo=GUICtrlCreateCombo($d_null,15,98,270,20,2097155);BitOR($CBS_DROPDOWNLIST,$WS_VSCROLL)
				GUICtrlSetCursor(-1,0)
			$d_delete=GUICtrlCreateButton("",265,121,20,20,0x40)
				GUICtrlSetTip(-1,"Delete Directory from Library")
				GUICtrlSetImage(-1,"shell32.dll",240,0)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$d_add=GUICtrlCreateButton("",15,121,20,20,0x40)
				GUICtrlSetTip(-1,"Add new Directory to Library")
				GUICtrlSetImage(-1,"shell32.dll",146,0)
				GUICtrlSetCursor(-1,0)
			$d_open=GUICtrlCreateButton("",171,121,20,20,0x40)
				GUICtrlSetImage(-1,"shell32.dll",5,0)
				GUICtrlSetTip(-1,"Open Directory")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$d_lower=GUICtrlCreateCheckbox("",42,127,14,14)
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","D Lower",4))
				GUICtrlSetTip(-1,"Include Non-Uppercase Constants")
				GUICtrlSetCursor(-1,0);125
			$d_con=GUICtrlCreateCheckbox("",62,127,14,14,6)
				GUICtrlSetTip(-1,"Checked = Ignore duplicate Global Constants (keep first occurrence)"&@LF&"Greyed Out = Overwrite duplicate Global Constants (keep last occurrence)"&@LF&"Unchecked = Enumerate duplicate Global Constants (keep them all)","Duplicate Global Constants Handling")
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","D Con",1))
				GUICtrlSetCursor(-1,0)
			$d_func=GUICtrlCreateCheckbox("",80,127,14,14,6);	GUICtrlSetTip(-1,"1 = never"&@LF&"2 = always"&@LF&"3 = prompt")
				GUICtrlSetTip(-1,"Checked = Ignore duplicate Functions (keep first occurrence)"&@LF&"Greyed Out = Overwrite duplicate Functions (keep last occurrence)"&@LF&"Unchecked = Enumerate duplicate Functions (keep them all)","Duplicate Functions Handling")
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","D Func",1))
				GUICtrlSetCursor(-1,0)
		$i_group=GUICtrlCreateGroup("Include File Options",10,145,280,63)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",35,197,45,1),0x808080)
				GUICtrlSetState(-1,128)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",35,198,45,1),0xFFFFFF)
				GUICtrlSetState(-1,128)
			$i_combo=GUICtrlCreateCombo($i_null,15,161,270,20,2097155);BitOR($CBS_DROPDOWNLIST,$WS_VSCROLL)
				GUICtrlSetCursor(-1,0)
			$i_delete=GUICtrlCreateButton("",265,184,20,20,0x40)
				GUICtrlSetTip(-1,"Delete Include File from Library")
				GUICtrlSetImage(-1,"shell32.dll",240,0)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$i_ignore=GUICtrlCreateButton("",240,184,20,20,0x40)
				GUICtrlSetTip(-1,"Put Include File to Ignore List")
				GUICtrlSetImage(-1,"shell32.dll",32+($ignorelist<>""),0)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$i_add=GUICtrlCreateButton("",15,184,20,20,0x40)
				GUICtrlSetTip(-1,"Add new Include File to Library")
				GUICtrlSetImage(-1,"shell32.dll",235,0)
				GUICtrlSetCursor(-1,0)
			$i_open=GUICtrlCreateButton("",146,184,20,20,0x40)
				GUICtrlSetTip(-1,"Open Include File in Editor")
				GUICtrlSetImage(-1,"shell32.dll",281,0)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$i_lower=GUICtrlCreateCheckbox("",42,190,14,14)
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","I Lower",4))
				GUICtrlSetTip(-1,"Include Non-Uppercase Constants")
				GUICtrlSetCursor(-1,0);188
			$i_con=GUICtrlCreateCheckbox("",62,190,14,14,6)
				GUICtrlSetTip(-1,"Checked = Ignore duplicate Global Constants (keep first occurrence)"&@LF&"Greyed Out = Overwrite duplicate Global Constants (keep last occurrence)"&@LF&"Unchecked = Enumerate duplicate Global Constants (keep them all)","Duplicate Global Constants Handling")
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","I Con",1))
				GUICtrlSetCursor(-1,0)
			$i_func=GUICtrlCreateCheckbox("",80,190,14,14,6);	GUICtrlSetTip(-1,"1 = never"&@LF&"2 = always"&@LF&"3 = prompt")
				GUICtrlSetTip(-1,"Checked = Ignore duplicate Functions (keep first occurrence)"&@LF&"Greyed Out = Overwrite duplicate Functions (keep last occurrence)"&@LF&"Unchecked = Enumerate duplicate Functions (keep them all)","Duplicate Functions Handling")
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","I Func",1))
				GUICtrlSetCursor(-1,0)
		GUICtrlCreateGroup("Global Constants Options",10,208,280,71)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",183,268,33,1),0x808080)
				GUICtrlSetState(-1,128)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",183,269,33,1),0xFFFFFF)
				GUICtrlSetState(-1,128)
			$c_combo=GUICtrlCreateCombo($c_null,15,224,270,20,2097155);BitOR($CBS_DROPDOWNLIST,$WS_VSCROLL)
				GUICtrlSetCursor(-1,0)
			$c_edit=GUICtrlCreateEdit("",15,251,70,20)
				GUICtrlSetStyle(-1,0x0802)
				GUICtrlSetTip(-1,"Value")
			$c_hex=GUICtrlCreateRadio("Hex",90,248,40,14)
				GUICtrlSetCursor(-1,0)
			$c_dec=GUICtrlCreateRadio("Dec",90,262,40,14)
				GUICtrlSetCursor(-1,0)
				GUICtrlSetState(-1,1)
			GUIStartGroup()
			$c_copy[0]=GUICtrlCreateRadio("Const",139,248,45,14,0x220)
				GUICtrlSetTip(-1,"Copy / Paste Constant Term")
				GUICtrlSetCursor(-1,0)
			GUIStartGroup()
			$c_copy[1]=GUICtrlCreateRadio("Value",139,262,45,14,0x220)
				GUICtrlSetTip(-1,"Copy / Paste Constant Value")
				GUICtrlSetCursor(-1,0)
				GUICtrlSetState(-1,1)
			$c_delete=GUICtrlCreateButton("",265,255,20,20,0x40)
				GUICtrlSetTip(-1,"Delete Global Constant from Library")
				GUICtrlSetImage(-1,"shell32.dll",240,0)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$c_ignore=GUICtrlCreateButton("",240,255,20,20,0x40)
				GUICtrlSetTip(-1,"Put Global Constant to Ignore List")
				GUICtrlSetImage(-1,"shell32.dll",32+($ignorelist<>""),0)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$c_clip=GUICtrlCreateButton("",215,255,20,20,0x40)
				GUICtrlSetTip(-1,"Copy Value to Clipboard")
				GUICtrlSetImage(-1,"shell32.dll",35,0)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$c_paste=GUICtrlCreateButton("",190,255,20,20,0x40)
				GUICtrlSetImage(-1,"shell32.dll",246,0)
				GUICtrlSetTip(-1,"Copy & Paste into script")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
		$f_group=GUICtrlCreateGroup("Functions Options",10,279,280,63)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",165,331,50,1),0x808080)
				GUICtrlSetState(-1,128)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",165,332,50,1),0xFFFFFF)
				GUICtrlSetState(-1,128)
			$f_combo=GUICtrlCreateCombo($f_null,15,295,270,20,2097155);BitOR($CBS_DROPDOWNLIST,$WS_VSCROLL)
				GUICtrlSetCursor(-1,0)
			$f_delete=GUICtrlCreateButton("",265,318,20,20,0x40)
				GUICtrlSetTip(-1,"Delete Funtion from Library")
				GUICtrlSetImage(-1,"shell32.dll",240,0)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$f_ignore=GUICtrlCreateButton("",240,318,20,20,0x40)
				GUICtrlSetTip(-1,"Put Function to Ignore List")
				GUICtrlSetImage(-1,"shell32.dll",32+($ignorelist<>""),0)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$f_clip=GUICtrlCreateButton("",215,318,20,20,0x40)
				GUICtrlSetTip(-1,"Copy Function to Clipboard")
				GUICtrlSetImage(-1,"shell32.dll",35,0)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$f_paste=GUICtrlCreateButton("",190,318,20,20,0x40)
				GUICtrlSetImage(-1,"shell32.dll",246,0);255
				GUICtrlSetTip(-1,"Copy & Paste into script")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$f_comment=GUICtrlCreateCheckbox("",171,324,14,14)
				GUICtrlSetTip(-1,"If available, include Headers")
				GUICtrlSetState(-1,128+IniRead($s_ini,"Settings","Comments",4))
				GUICtrlSetCursor(-1,0)
			$f_view=GUICtrlCreateButton("",146,318,20,20,0x40)
				GUICtrlSetImage(-1,"shell32.dll",281,0)
				GUICtrlSetTip(-1,"View Function")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$f_help=GUICtrlCreateButton("",15,318,20,20,0x40)
				GUICtrlSetImage(-1,"shell32.dll",289,0)
				GUICtrlSetTip(-1,"View Helpfile")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$f_run=GUICtrlCreateButton("",40,318,20,20,0x40)
				GUICtrlSetImage(-1,"shell32.dll",153,0);25,0)
				GUICtrlSetTip(-1,"Run Example")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$f_example=GUICtrlCreateButton("",65,318,20,20,0x40)
				GUICtrlSetImage(-1,"shell32.dll",151,0)
				GUICtrlSetTip(-1,"View Example")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
		$copy=GUICtrlCreateLabel("° = Duplic.",90,327,50,14);68
			GUICtrlSetColor(-1,0x808080)
			GUICtrlSetState(-1,32)
		GUICtrlSetBkColor(GUICtrlCreateLabel("",10,144,1,7),0x808080)
		GUICtrlSetBkColor(GUICtrlCreateLabel("",11,144,1,7),0xFFFFFF)
		GUICtrlSetBkColor(GUICtrlCreateLabel("",10,278,1,7),0x808080)
		GUICtrlSetBkColor(GUICtrlCreateLabel("",11,278,1,7),0xFFFFFF)
		GUICtrlSetBkColor(GUICtrlCreateLabel("",288,144,1,7),0x808080)
		GUICtrlSetBkColor(GUICtrlCreateLabel("",289,144,1,7),0xFFFFFF)
		GUICtrlSetBkColor(GUICtrlCreateLabel("",288,278,1,7),0x808080)
		GUICtrlSetBkColor(GUICtrlCreateLabel("",289,278,1,7),0xFFFFFF)
	$apply=GUICtrlCreateTabItem("Patch Script")
		$p_myScripts=GUICtrlCreateGroup("My Scripts",10,25,280,70)
			$p_list=GUICtrlCreateList("",45,42,210,47,0xA00103)
				GUICtrlSetCursor(-1,0)
			$p_open=GUICtrlCreateButton("",20,44,20,20,0x40)
				GUICtrlSetImage(-1,"shell32.dll",235,0);281 view
				GUICtrlSetTip(-1,"Load new Script(s) to be processed")
				GUICtrlSetCursor(-1,0)
			$p_delete=GUICtrlCreateButton("",20,66,20,20,0x40)
				GUICtrlSetImage(-1,"shell32.dll",240,0)
				GUICtrlSetTip(-1,"Remove selected Script from Process List")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$p_view=GUICtrlCreateButton("",260,44,20,20,0x40);edit
				GUICtrlSetImage(-1,"shell32.dll",281,0);
				GUICtrlSetTip(-1,"View / Edit selected Script")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$p_select=GUICtrlCreateButton("",260,66,20,20,0x40);
				GUICtrlSetImage(-1,"shell32.dll",255,0);
				GUICtrlSetTip(-1,"Load selected Script to Administration Tab")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
		GUICtrlCreateGroup("Patch Options",10,95,280,110)
			$p_all=GUICtrlCreateCheckbox("Patch selected only",15,110,120,15)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$p_fly=GUICtrlCreateCheckbox("Patch on the fly",15,125,95,15)
				GUICtrlSetTip(-1,"Unchecked = FreeStyle prompts every step")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
				GUICtrlSetState(-1,1)
	;		GUICtrlCreateCheckbox("Exec. Algebraic Terms",15,140,130,15)
	;			GUICtrlSetTip(-1,'e.g. "BitOR($WS_CHILD,$WS_VISIBLE,$WS_TABSTOP))" will be executed to "1342242816" resp. "0x50010000".')
	;			GUICtrlSetCursor(-1,0)
			$p_exc=GUICtrlCreateCheckbox("Exchange Constants",140,110,120,15,6);3state
				GUICtrlSetTip(-1,"Checked = Global Constants will be exchanged on occurrence by their values within the scriptline."&@LF&"Greyed out = Global Constants will be defined in head of script."&@LF&"Unchecked = Global Constants will not be processed."&@LF&"Attention: In this case, Functions may have to be renamed by FreeDrive.","Patching mode for Global Constants")
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","Con",1))
				GUICtrlSetCursor(-1,0)
				GUICtrlSetState(-1,1)
			$p_com=GUICtrlCreateCheckbox("Comment original Line",160,125,123,15)
				GUICtrlSetTip(-1,"The original script line will be preserved as a comment")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$p_dec=GUICtrlCreateCheckbox("Use Decimal",160,140,80,15)
				GUICtrlSetTip(-1,"Checked = Hexadecimal expression of value is used")
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","Hex",1))
				GUICtrlSetCursor(-1,0)
				GUICtrlSetState(-1,1)
			$p_exf=GUICtrlCreateCheckbox("Add Functions to Bottom",140,155,135,15)
				GUICtrlSetTip(-1,"Unchecked = (UD) Functions will not be processed."&@LF&"Attention: In this case, Global Functions declarations may have to be renamed by FreeDrive.","Patching mode for (UD) Functions")
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","Fun",1))
				GUICtrlSetCursor(-1,0)
				GUICtrlSetState(-1,1)
			$p_head=GUICtrlCreateCheckbox("Include Headers",160,170,98,15)
				GUICtrlSetTip(-1,"When checked, there's a little bug when header itself contains Declarations !")
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","Header",4))
				GUICtrlSetCursor(-1,0)
;			GUICtrlCreateCheckbox("Ignore Comments",15,140,101,15)
;				GUICtrlSetState(-1,128)
;				GUICtrlSetCursor(-1,0)
			GUICtrlCreateCheckbox("Prefer Beta",15,140,85,15)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			GUICtrlCreateCheckbox("Delete #includes",15,155,100,15)
				GUICtrlSetTip(-1,"Well, that's what it's all about !"&@LF&"Anyway, if unchecked, #includes will be commented out.")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$p_backup=GUICtrlCreateCheckbox("Backup Script",15,170,85,15)
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","Backup",1))
				GUICtrlSetCursor(-1,0)
				GUICtrlSetState(-1,1)
			$p_remove=GUICtrlCreateCheckbox("Remove Script",15,185,90,15)
				GUICtrlSetTip(-1,"Remove Script from List when processed.")
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","Remove",1))
				GUICtrlSetCursor(-1,0)
				GUICtrlSetState(-1,1)
			$p_log=GUICtrlCreateCheckbox("Create Log",140,185,70,15);option; nicht in comments suchen kommentierte berücksichtigen
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","Log",1))
				GUICtrlSetCursor(-1,0);ignore comments;ignore commented lines
				GUICtrlSetState(-1,1);Show Progress
			GUICtrlSetBkColor(GUICtrlCreateLabel("",10,94,1,7),0x808080)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",11,94,1,7),0xFFFFFF)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",288,94,1,7),0x808080)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",289,94,1,7),0xFFFFFF)
			;kill spaces
		GUICtrlCreateGroup("Ignore List",10,206,280,134)
			$ign_main=GUICtrlCreateCheckbox("Apply Ignore List",15,224,97,15)
				GUICtrlSetTip(-1,"Exclude Ignore List Item(s) from Patch process")
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","Ignore",1))
				If $ignorelist="" Then GUICtrlSetState(-1,132)
				GUICtrlSetCursor(-1,0)
			$ign_list=GUICtrlCreateList("",14,241,247,95,0xA00103)
				GUICtrlSetData(-1,$ignorelist)
				GUICtrlSetCursor(-1,0)
			$ign_view=GUICtrlCreateButton("",264,292,20,20,0x40);edit
				If $ignorelist="" Then GUICtrlSetState(-1,128)
				GUICtrlSetTip(-1,"View / Edit selected Item")
				GUICtrlSetImage(-1,"shell32.dll",281,0);
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$ign_restore=GUICtrlCreateButton("",264,314,20,20,0x40)
				GUICtrlSetTip(-1,"Remove selected Item from Ignore List")
				If $ignorelist="" Then GUICtrlSetState(-1,128)
				GUICtrlSetImage(-1,"shell32.dll",290,0);"user32.dll",103,0);"shell32.dll",255,0)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",10,204,1,8),0x808080)
			GUICtrlSetBkColor(GUICtrlCreateLabel("",11,204,1,8),0xFFFFFF)
		$p_patch=GUICtrlCreateIcon("shell32.dll",239,232,182,60,60);,0x12)
			GUICtrlSetTip(-1,"Patch Script(s)");		GUICtrlSetImage(-1,"shell32.dll",239,0)
			GUICtrlSetCursor(-1,0)
	$about=GUICtrlCreateTabItem("About");About;Opts
		GUICtrlCreateGroup("About",10,25,280,175)
			GUICtrlCreateLabel("FreeStyle Include Library and au3 Patcher v "&$FS_version,20,50,260,20,1)
			GUICtrlCreateLabel("©  2008 by jennico",20,65,260,20,1)
			$_logo=GUICtrlCreateIcon("shell32.dll",239,110,80,80,80);,0x12)
				GUICtrlSetTip(-1,"Click here for Support, Updates, Downloads")
				GUICtrlSetCursor(-1,0)
	;	GUICtrlCreatePic("http.www.nx24.com.uploads.pics.paypal_16.gif",30,100,42,45)
	;	GUICtrlCreatePic("paypal_logo.gif",100,165,114,31)
	;	GUICtrlCreatePic("btn_donate_SM.gif",100,165,74,21)
		;fehlt donation !
			GUICtrlCreateLabel("All rights reserved.",20,165,260,20,1)
			GUICtrlCreateLabel("Distribution without permission strictly prohibited.",20,180,260,20,1)
		GUICtrlCreateGroup("General Settings",10,207,280,133)
			$o_open=GUICtrlCreateButton("",263,222,20,20,0x40);219
				GUICtrlSetImage(-1,"shell32.dll",281,0);281 view
				GUICtrlSetTip(-1,'Browse ".au3" and ".log.au3" files')
				GUICtrlSetCursor(-1,0)
			$o_history=GUICtrlCreateButton("",263,245,20,20,0x40)
				GUICtrlSetImage(-1,"shell32.dll",21,0);281 view
				GUICtrlSetTip(-1,"View / Restore FreeStyle History")
				GUICtrlSetCursor(-1,0)
			$o_drop=GUICtrlCreateCheckbox("All tabs drop to Patch List",15,227,139,15)
				GUICtrlSetTip(-1,"Checked = all dropped files will be passed to Patch list."&@LF&"Unchecked = files dropped to Administrate Tab will be added to Library.","Drag and Drop Handling")
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","Drop",4))
				GUICtrlSetCursor(-1,0)
			$o_through=GUICtrlCreateCheckbox("Pass dropped through",15,242,122,15)
				GUICtrlSetTip(-1,"Dropped Scripts will be passed to patch process immediately.","Pass dropped through")
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","Pass",4))
				GUICtrlSetCursor(-1,0)
			$o_sounds=GUICtrlCreateCheckbox("Sounds",165,227,55,15)
				$sounds=IniRead($s_ini,"Settings","Sounds",1)
				GUICtrlSetState(-1,$sounds)
				GUICtrlSetCursor(-1,0)
			$o_save=GUICtrlCreateCheckbox("Save Settings",165,242,87,15)
				GUICtrlSetState(-1,IniRead($s_ini,"Settings","Save",1))
				GUICtrlSetCursor(-1,0)
			$o_Sync=GUICtrlCreateCheckbox("Synchronize SciTe and FreeStyle Libraries",15,260,225,15)
				GUICtrlSetTip(-1,"Hence, e.g. ALL registered UDF will be colorated light blue in SciTE like they are in FreeStyle Editor.")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			GUICtrlCreateCheckbox("Use Beta keywords in SciTE and FreeStyle Editor",15,275,255,15)
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
		;backup library + view history (changes)
		;restore former library
			$o_FreeStyle=GUICtrlCreateRadio("FreeStyle Editor",15,295,95,15)
				GUICtrlSetTip(-1,"Open every Script in FreeStyle Editor (recommended).")
				If $msg>0 Then GUICtrlSetState(-1,1)
				If $msg=0 Then GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$o_SciTE=GUICtrlCreateRadio("SciTE Editor",115,295,80,15)
				If StringInStr($editPath,"SciTE.exe")=0 Then GUICtrlSetState(-1,128)
				GUICtrlSetTip(-1,"Open every Script in SciTE Editor.")
				If $msg=0 Then GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$o_instance=GUICtrlCreateCheckbox("New Instance",200,295,87,15)
				GUICtrlSetTip(-1,"Open every Script in a new SciTE instance (no tabs).")
				GUICtrlSetState(-1,128)
				GUICtrlSetCursor(-1,0)
			$o_editor=GUICtrlCreateButton("",15,313,20,20,0x40)
				GUICtrlSetImage(-1,"shell32.dll",235,0);281 view
				GUICtrlSetTip(-1,"Choose custom editor");'Enter custom Editor path with Command line parameter, e.g.: Run("C:\AutoIt3\SciTE\Scite.exe open C:\test.au3").')
				GUICtrlSetCursor(-1,0)
			$o_edit=GUICtrlCreateEdit("C:\AutoIt3\SciTE\Scite.exe",40,313,245,20,0x0800);nicht readonly !  ;'Run("C:\SciTE\Scite.exe {ScriptFullPath}")'
				If $scitePath Then GUICtrlSetData(-1,$scitePath&"SciTE.exe")
				GUICtrlSetTip(-1,"This is just an example !")
				$msg=IniRead($s_ini,"SciTE","Editor","")
				If $msg Then
					GUICtrlSetData(-1,$msg)
					GUICtrlSetTip(-1,$msg)
				EndIf
				GUICtrlSetCursor(-1,0);hotkey		;duplikate		;tooltip bei hex und dec !
	GUICtrlCreateTabItem("")
GUISetState()
Dim $pos=WinGetPos($m_GUI),$size=WinGetClientSize($m_GUI),$border=$pos[3]-$size[1],$FSLog=FileOpen("FS_Library\FreeStyle.log",9)
; bei jedem start registry_Keychecken !
;RegWrite("HKEY_CLASSES_ROOT\AutoIt3Script\Shell\Patch script with FreeStyle","(Standard)","REG_SZ","Patch")
;RegWrite("HKEY_CLASSES_ROOT\AutoIt3Script\Shell\Patch script with FreeStyle\Command","(Standard)","REG_SZ",'"'&$alphaPath&'\AutoIt3.exe" "'&@ScriptFullPath&'" "%1"')
;HKEY_CLASSES_ROOT\AutoIt3ScriptBeta\Shell\Compile\Command	beta
If FileExists(@SystemDir&"\7z.exe")=0 Then	;http://downloads.sourceforge.net/sevenzip/7z457.exe
;	InetGet("http://kent.dl.sourceforge.net/sourceforge/sevenzip/7z457.exe",@SystemDir&"\7z.exe",1,1)
EndIf
If FileExists($s_ini)=0 Then
	_Log($FSLog,"First Start - Welcome to FreeStyle  ©  2008 by jennico")
	DirCreate("FS_Backup\Temp")
	DirCreate("FS_Library\History")
	$return=_Scan($alphaPath&"\Include")
EndIf
If $betaVersion<>IniRead($s_ini,"AutoIt","Beta Version","") Or GUICtrlRead($b_beta)=4 Then
	GUICtrlSetImage($b_icon,"user32.dll",101,1)
	GUICtrlSetData($b_reg,"Library Version: not registered yet")
EndIf
If $alphaVersion<>IniRead($s_ini,"AutoIt","Alpha Version","") Then
	GUICtrlSetImage($a_icon,"user32.dll",101,1)
	$msg=MsgBox(270388," Library out of date !","The current AutoIt version does not         "&@LF&"correspond to the library version."&@LF&@LF&"FreeStyle library has to be updated.         "&@LF&'Choose "No" only if you want to'&@LF&"backup files first.")
	If $msg=6 Then
		_Update()
		GUICtrlSetImage($a_icon,"shell32.dll",239,1)
	EndIf
EndIf
Dim $d_str=FileRead("FS_Library\Directories.txt"),$i_str=FileRead("FS_Library\Includes.txt"),$c_str=FileRead("FS_Library\Constants.txt"),$f_str=FileRead("FS_Library\Functions.txt"),$a_help=FileRead($alphaPath&"\UDFs3.chm"),$b_help=FileRead($betaPath&"\UDFs3.chm")
If $d_str And $i_str And $c_str And $f_str Then
	Dim $d_array=StringSplit($d_str,"?"),$i_array=StringSplit($i_str,"?"),$c_array=StringSplit($c_str,"?"),$f_array=StringSplit($f_str,"?")
	_lib_Update()
Else;	@InetGetActive = 1 while downloading, or 0 when finished.
	_Sort();	@InetGetBytesRead
EndIf
If $Skipped Then _Report($return[2],$return[0],$return[1])
If FileExists($FS_Engine)=0 Or StringMid(FileReadLine($FS_Engine,1),2)<>$FS_version Then _Engine()
GUICtrlSetData($d_combo,$d_str)
GUICtrlSetData($i_combo,$i_str)
GUICtrlSetData($c_combo,$c_str)
GUICtrlSetData($f_combo,$f_str)
GUICtrlSetState($general,16)
#EndRegion
#Region;---main------------------------------------------------------------------
While 1;akustische hinweise bei drop und nach splash !
	$msg=GUIGetMsg()
	If $Handle<>WinGetHandle("") Then ToolTip("")
	If $s_GUI And WinActive($s_GUI) Then
		GUIRegisterMsg(78,"_WM_NOTIFY")
		GUIRegisterMsg(0x0233,"")
		$g=DllCall("user32.dll","int","GetAsyncKeyState","int","0x01")
		If @error=0 And $g[0]<>0 Then _GetWord()
		If $msg=-3 Or $msg=$s_exit Then _sciExit()
	ElseIf WinActive($m_GUI) Then
		If $Handle<>WinGetHandle($m_GUI) Then GUICtrlSetState(GUICtrlRead($tab,2),16)
		If $TabShown<>GUICtrlRead($tab,2) Then ToolTip("")
		GUIRegisterMsg(0x0233,"_Drop")
		GUIRegisterMsg(78,"");_GUICtrlComboAutoComplete ($Combo, $old_string)
		If $msg=-3 Then _Exit();geöffnetes tab refreshen
		If $msg=-13 Then _Drop()
		If $msg=$d_add Then _d_Add()
		If $msg=$i_add Then _i_Add()
		If $msg=$p_open Then _p_Open()
		If $msg=$o_open Then _o_open()
		If $msg=$i_open Then _SciTe(0)
		If $msg=$f_view Then _SciTe(1)
		If $msg=$d_combo Then _d_Combo()
		If $msg=$i_combo Then _i_Combo()
		If $msg=$c_combo Then _c_Combo()
		If $msg=$f_combo Then _f_Combo()
		If $msg=$s_button Then _Search()
		If $msg=$g_update Then _Update()
		If $msg=$p_select Then _p_Select()
		If $msg=$o_editor Then _o_Editor()
		If $msg=$c_copy[0] Then _c_Copy(0)
		If $msg=$c_copy[1] Then _c_Copy(1)
		If $msg=$p_delete Then _p_Delete($chosen)
		If $msg=$o_Sync Then _Sync(GUICtrlRead($msg))
		If $msg=$p_exc Then _p_exc(GUICtrlRead($p_exc))
		If $msg=$p_list Then _p_List(GUICtrlRead($msg))
		If $msg=$p_view Then _p_View($patharray[$chosen])
		If $msg=$s_combo Or $msg=$s_forum Then _s_Combo()
		If $msg=$c_clip Or $msg=$c_paste Then _c_ClipPut()
		If $msg=$f_clip Or $msg=$f_paste Then _f_ClipPut()
		If $msg=$f_help Then _f_help(GUICtrlRead($f_combo))
		If $msg=$p_patch Then _PatchIt(GUICtrlRead($p_fly))
		If $msg=$ign_list Then _ign_List(GUICtrlRead($msg))
		If $msg=$d_delete Then _Delete(GUICtrlRead($d_combo))
		If $msg=$i_delete Then _Delete(GUICtrlRead($i_combo))
		If $msg=$c_delete Then _Delete(GUICtrlRead($c_combo))
		If $msg=$f_delete Then _Delete(GUICtrlRead($f_combo))
		If $msg=$c_ignore Then _Ignore(GUICtrlRead($c_combo))
		If $msg=$f_ignore Then _Ignore(GUICtrlRead($f_combo))
		If $msg=$ign_view Then _ign_View(GUICtrlRead($ign_list))
		If $msg=$d_open Then Run("Explorer "&GUICtrlRead($d_combo))
		If $msg=$ign_restore Then _ign_Restore(GUICtrlRead($ign_list))
		If $msg=$on_top Then WinSetOnTop($m_GUI,"",GUICtrlRead($msg)=1)
		If $msg=$f_run Then _f_run(GUICtrlRead($d_combo)&GUICtrlRead($f_combo))
		If $msg=$o_save Then IniWrite($s_ini,"Settings","Save",GUICtrlRead($msg))
		If $msg=$p_exf Then GUICtrlSetState($p_head,68+64*(GUICtrlRead($p_exf)=4))
		If $msg=$f_example Then _f_example(GUICtrlRead($d_combo)&GUICtrlRead($f_combo))
		If $msg=$i_ignore Then _Ignore(GUICtrlRead($d_combo)&"\"&GUICtrlRead($i_combo))
		If GUICtrlRead($tab,1)=$admin And GUICtrlRead($s_edit)<>$Keyword Then _s_Combo()
		If ($msg=$g_deldup Or $msg=$g_dellow) And GUICtrlRead($msg)=1 Then GUICtrlSetState($g_delall,4)
		If $msg=$p_log And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","Log",GUICtrlRead($msg))
		If $msg=$p_exc And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","Con",GUICtrlRead($msg))
		If $msg=$p_exf And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","Fun",GUICtrlRead($msg))
		If $msg=$p_dec And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","Hex",GUICtrlRead($msg))
		If $msg=$d_con And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","D Con",GUICtrlRead($msg))
		If $msg=$i_con And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","I Con",GUICtrlRead($msg))
		If $msg=$o_drop And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","Drop",GUICtrlRead($msg))
		If $msg=$d_func And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","D Func",GUICtrlRead($msg))
		If $msg=$i_func And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","I Func",GUICtrlRead($msg))
		If $msg=$p_head And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","Header",GUICtrlRead($msg))
		If $msg=$o_through And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","Pass",GUICtrlRead($msg))
		If $msg=$d_lower And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","D Lower",GUICtrlRead($msg))
		If $msg=$i_lower And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","I Lower",GUICtrlRead($msg))
		If $msg=$ign_main And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","Ignore",GUICtrlRead($msg))
		If $msg=$p_backup And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","Backup",GUICtrlRead($msg))
		If $msg=$p_remove And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","Remove",GUICtrlRead($msg))
		If $msg=$o_sounds And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","Sounds",GUICtrlRead($msg))
		If $msg=$c_hex And GUICtrlRead($c_edit) Then GUICtrlSetData($c_edit,"0x"&_DecToHex(GUICtrlRead($c_edit)))
		If $msg=$f_comment And GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"Settings","Comments",GUICtrlRead($msg))
		If $msg=$c_dec And GUICtrlRead($c_edit) Then GUICtrlSetData($c_edit,IniRead($c_ini,"Con",GUICtrlRead($c_combo),""))
		If $msg=$_logo Then ShellExecute("http://www.autoitscript.com/forum/index.php?showtopic=75487&view=findpost&p=547560")
		If ($msg=$a_func Or $msg=$b_func) And GUICtrlRead($msg)>1 Then ToolTip("you can try it, but don't rely it !",Default,Default,"Duplicates handling still experimental",0,3)
		If ($msg=$a_func Or $msg=$b_func) And GUICtrlRead($msg)=1 Then ToolTip("")
		$TabShown=GUICtrlRead($tab,2)
	EndIf
	$Handle=WinGetHandle("")	
WEnd
#EndRegion
#Region;---primary functions-----------------------------------------------------
Func _d_Combo($d=0);zusammenfassen
	$y=GUICtrlRead($d_combo)
	If StringInStr($y,"\")=0 Then
		GUICtrlSetState($d_delete,128)
		GUICtrlSetState($d_open,128)
		GUICtrlSetTip($d_combo,"")
		If $y=$d_null And $d=0 Then
			_SplashOn()
			GUICtrlSetData($s_edit,"Enter Keyword")
			GUICtrlSetData($i_combo,"?"&$i_null&"?"&$i_str,$i_null)
			_i_Combo(2);eigentlich reicht doch i_str ?
			_cf_null();eigentlich reicht doch cf_str ?	oder ?
		EndIf
		_s_Combo()
		_SplashOff()
		Return
	EndIf
	GUICtrlSetState($d_delete,64)
	GUICtrlSetState($d_open,64)
	GUICtrlSetTip($d_combo,$y)
	If $d=1 Then Return
	_SplashOn()
	Dim $x="",$tp=$y,$k,$v;$tp notwendig ?
	_IniReadSection($d_ini,"Dir",$k,$v)
	For $i=1 To $k[0]
		If $v[$i]=$tp Then
			If $x="" Then $first=$k[$i]
			$x&="?"&$k[$i]
		EndIf
	Next
	GUICtrlSetData($i_combo,$x,$first)
	_i_Combo(2)
	_c_Update($tp,"No Global Constants in Directory")
	_f_Update($tp,"No Functions in Directory")
	_SplashOff()
	_s_Combo()
EndFunc

Func _i_Combo($d=0)
	$y=GUICtrlRead($i_combo)
	If StringRight(StringReplace($y,"°",""),4)<>".au3" Then
		GUICtrlSetState($i_delete,128)
		GUICtrlSetState($i_ignore,128)
		GUICtrlSetState($i_open,128)
		GUICtrlSetTip($i_combo,"")
		If $y=$i_null And $d=0 Then
			_SplashOn()
			GUICtrlSetData($d_combo,"?"&$d_null&"?"&$d_str,$d_null)
			_d_Combo(1);eigentlich reicht doch d_str ?
			_cf_null();eigentlich reicht doch cf_str ?	oder ?
		EndIf
		_s_Combo()
		_SplashOff()
		Return
	EndIf
	GUICtrlSetState($i_delete,64)
	GUICtrlSetState($i_ignore,64)
	GUICtrlSetState($i_open,64)
	GUICtrlSetTip($i_combo,$y)
	If $d=2 Then Return
	$a=IniRead($d_ini,"Dir",$y,"")
	If $a="" Then _Error($d_ini,$y,"Dir")
	GUICtrlSetData($d_combo,$a)
	_d_Combo(1)
	If $d=1 Then Return
	_SplashOn()
	_c_Update($y)
	_f_Update($y)
	_SplashOff()
	_s_Combo()
EndFunc

Func _c_Combo($d=0)
	ToolTip("")
	$y=GUICtrlRead($c_combo)
	GUICtrlSetState($c_hex,64)
	GUICtrlSetState($c_dec,64)
	GUICtrlSetState($f_group,16)	
	If StringLeft($y,1)<>"$" Then
		GUICtrlSetState($c_delete,128)
		GUICtrlSetState($c_ignore,128)
		GUICtrlSetState($c_paste,128)
		GUICtrlSetState($c_clip,128)
		GUICtrlSetData($c_edit,"")
		GUICtrlSetTip($c_combo,"")
		Return
	EndIf
	GUICtrlSetState($c_delete,64)
	GUICtrlSetState($c_ignore,64)
	GUICtrlSetState($c_paste,64)
	GUICtrlSetState($c_clip,64)
	GUICtrlSetTip($c_combo,$y)
	$x=IniRead($c_ini,"Con",StringReplace(StringReplace($y,"[","´"),"]","`"),"")
	If $x="" Then _Error($c_ini,$y,"Con")
	If StringIsInt($x) Then
		If GUICtrlRead($c_hex)=1 Then $x="0x"&_DecToHex($x)
		GUICtrlSetData($c_edit,$x)
	Else
		GUICtrlSetData($c_edit,"")
		GUICtrlSetState($c_hex,128)
		GUICtrlSetState($c_dec,128)
		$pos=WinGetPos($m_GUI)
		$pos1=WinGetClientSize($m_GUI)
		$pos2=ControlGetPos($m_GUI,"",$c_edit)
		ToolTip(StringReplace(StringReplace(StringReplace($x,"´","["),"`","]"),"~",Chr(34)),$pos[0]+$pos2[0]+($pos[2]-$pos1[0])/2+1,$pos[1]+$pos2[1]+$pos[3]-$pos1[1]-($pos[2]-$pos1[0])/2+1,"",0,4)
	EndIf
	$a=IniRead($i_ini,"Inc",StringReplace(StringReplace($y,"[","´"),"]","`"),"")
	If $a="" Then _Error($i_ini,$y,"Inc")
	If $d=0 Then _id_Update($a)
EndFunc

Func _f_Combo($d=0)
	$y=GUICtrlRead($f_combo)
	GUICtrlSetState($f_run,128)
	GUICtrlSetState($f_help,128)
	GUICtrlSetState($f_example,128)
	If StringInStr($y," ") Then
		GUICtrlSetState($f_comment,128)
		GUICtrlSetState($f_delete,128)
		GUICtrlSetState($f_ignore,128)
		GUICtrlSetState($f_paste,128)
		GUICtrlSetState($f_clip,128)
		GUICtrlSetState($f_view,128)
		GUICtrlSetTip($f_combo,"")
		Return
	EndIf
	GUICtrlSetState($f_comment,64)
	GUICtrlSetState($f_delete,64)
	GUICtrlSetState($f_ignore,64)
	GUICtrlSetState($f_paste,64)
	GUICtrlSetState($f_clip,64)
	GUICtrlSetState($f_view,64)
	GUICtrlSetTip($f_combo,$y)
	Dim $a=IniRead($f_ini,"Fun",StringReplace($y,"=","\"),""),$x1=StringLeft($a,StringInStr($a,"\Include\",2)),$x2=StringLeft($y,StringInStr($y,"(")-1)
	If $a="" Then _Error($f_ini,StringReplace($y,"=","\"),"Fun")
	If FileExists($x1&"Examples\Helpfile\"&$x2&".au3") Then
		GUICtrlSetState($f_example,64)
		GUICtrlSetState($f_run,64)
	EndIf
	If ($x1=$alphaPath&"\" And StringInStr($a_help,"/"&$x2&".",2)) Or ($x1=$betaPath&"\" And StringInStr($b_help,"/"&$x2&".",2)) Then GUICtrlSetState($f_help,64)
	If $d=0 Then _id_Update($a)
EndFunc

Func _id_Update($a)
	$t=StringMid($a,StringInStr($a,"\",2,-1)+1)
	GUICtrlSetData($i_combo,$t)
	GUICtrlSetData($d_combo,StringReplace($a,"\"&$t,""))
	_i_Combo(1)
	_d_Combo(1)
;	_f_Update($y)
EndFunc

Func _c_Update($p,$first="No Global Constants in File");sort !!! ?
	Dim $x="",$k,$v
	_IniReadSection($i_ini,"Inc",$k,$v)
	For $i=1 To $k[0]
		If StringInStr($v[$i],"\"&$p,2) Then
			If $x="" Then $first=$k[$i]
			$x&="?"&$k[$i]
		EndIf
	Next
	If $x="" Then $x="?"&$first;nur icomboread reicht doch nicht ?
	GUICtrlSetData($c_combo,StringReplace(StringReplace($x,"´","["),"`","]"),StringReplace(StringReplace($first,"´","["),"`","]"))
	_c_Combo(1)
EndFunc

Func _f_Update($p,$first="No Functions in File");sort !!! ?
	Dim $x="",$k,$v
	_IniReadSection($f_ini,"Fun",$k,$v)
	For $i=1 To $k[0]
		If StringInStr($v[$i],"\"&$p,2) Then
			$k[$i]=StringReplace($k[$i],"\","=")
			If $x="" Then $first=$k[$i]
			$x&="?"&$k[$i]
		EndIf
	Next
	If $x="" Then $x="?"&$first
	GUICtrlSetData($f_combo,$x,$first)
	_f_Combo(1)
EndFunc

Func _d_Add()
	$x=FileSelectFolder("Please choose Include Folder","::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
	If @error=1 Then Return
	Dim $Case=GUICtrlRead($d_lower),$c_Double=GUICtrlRead($d_con),$f_Double=GUICtrlRead($d_func)
	_Add_Dir($x)
;	FileChangeDir(@ScriptDir)
EndFunc

Func _i_Add()
	$x=FileOpenDialog("Please choose Include File(s)","","AutoIt3 source code (*.au3)",7)
	If @error=1 Then Return
	FileChangeDir(@ScriptDir)
	Dim $Case=GUICtrlRead($i_lower),$c_Double=GUICtrlRead($i_con),$f_Double=GUICtrlRead($i_func)
	_Add_File($x)
EndFunc

Func _Delete($y);bei add müssen auch übergeordnete ebenen(incl+dir) addiert werden
	GUISetState(@SW_DISABLE,$m_GUI)
	If ($msg=$d_delete And $d_array[0]=1) Or ($msg=$i_delete And $i_array[0]=1) Then
		MsgBox(262192,"Empty Library ?","You cannot delete the last Library Entry !        ")
		GUISetState(@SW_ENABLE,$m_GUI)
		Return
	EndIf
	$ret=MsgBox(270372,"  '"&$y&"'","Do you really want to delete this Library entry ?      ")
	If $ret=7 Then
		GUISetState(@SW_ENABLE,$m_GUI)
		Return
	EndIf
	WinActivate($m_GUI)	
	_SplashOn()
	If $msg=$d_delete Then _d_Delete($y)
	If $msg=$i_delete Then _i_Delete($y)
	If $msg=$c_delete Then
		_Correct($y,$c_array,$c_str,"Constants")
		IniDelete($i_ini,"Inc",StringReplace(StringReplace($y,"[","´"),"]","`"))
		IniDelete($c_ini,"Con",StringReplace(StringReplace($y,"[","´"),"]","`"))
		If _Recurse() Then _c_Update(GUICtrlRead($i_combo))
	EndIf
	If $msg=$f_delete Then
		_Correct($y,$f_array,$f_str,"Functions")
		IniDelete($f_ini,"Fun",StringReplace($y,"=","\"))
		IniDelete($p_ini,"Par",StringLeft($y,StringInStr($y,"(")-1))
		If _Recurse() Then _f_Update(GUICtrlRead($i_combo))
	EndIf
	_lib_Update()
	GUISetState(@SW_ENABLE,$m_GUI)
	_SplashOff()
EndFunc

Func _d_Delete($y,$k=0,$v=0);checken !!!
	_Correct($y,$d_array,$d_str,"Directories")
	GUICtrlSetData($d_combo,"?"&$d_null&"?"&$d_str,$d_null)
	If IsArray($k)=0 Then _IniReadSection($d_ini,"Dir",$k,$v)
	For $i=1 To $k[0]
		If $v[$i]=$y Then
			IniDelete($d_ini,"Dir",$k[$i])
			$i_str=StringReplace($i_str&"?",$k[$i]&"?","")
		EndIf
	Next
	Dim $i_array=StringSplit($i_str,"?"),$x=0
	GUICtrlSetData($i_combo,"?"&$i_null&"?"&$i_str,$i_null)
	_IniReadSection($i_ini,"Inc",$k,$v)
	For $i=1 To $k[0]
		If StringInStr($i_str,StringMid($v[$i],StringInStr($v[$i],"\",2,-1)+1)) Then
			IniDelete($i_ini,"Inc",$k[$i])
			IniDelete($c_ini,"Con",$k[$i])
			Dim $c_str=StringReplace($c_str&"?",$k[$i]&"?",""),$x=1
		EndIf
	Next
	If $x=1 Then
		Dim $c_array=StringSplit($c_str,"?"),$x=0
		GUICtrlSetData($c_combo,"?"&$c_null&"?"&$c_str,$c_null)
	EndIf
	_IniReadSection($f_ini,"Fun",$k,$v)
	For $i=1 To $k[0]
		If StringInStr($i_str,StringMid($v[$i],StringInStr($v[$i],"\",2,-1)+1)) Then
			IniDelete($f_ini,"Fun",StringReplace($k[$i],"\","="))
			IniDelete($p_ini,"Par",StringLeft($k[$i],StringInStr($k[$i],"(")-1))
			$f_str=StringReplace($f_str&"?",StringReplace($k[$i],"\","=")&"?","")
			$x=1
		EndIf
	Next
	If $x=1 Then
		$f_array=StringSplit($f_str,"?")
		GUICtrlSetData($f_combo,"?"&$f_null&"?"&$f_str,$f_null)
	EndIf
EndFunc

Func _i_Delete($y,$k1=0,$v1=0,$k2=0,$v2=0);dir besser am anfang ! ?
	_Correct($y,$i_array,$i_str,"Includes");checken !!!
	If IsArray($k1)=0 Then _IniReadSection($i_ini,"Inc",$k1,$v1)
	For $i=1 To $k1[0]
		If StringInStr($v1[$i],$y) Then
			IniDelete($i_ini,"Inc",$k1[$i])
			IniDelete($c_ini,"Con",$k1[$i])
			$c_str=StringReplace($c_str&"?",StringReplace(StringReplace($k1[$i]&"?","´","["),"`","]")&"?","")
			If StringRight($c_str,1)="?" Then $c_str=StringTrimRight($c_str,1)
		EndIf
	Next
	$c_array=StringSplit($c_str,"?")
	If IsArray($k2)=0 Then _IniReadSection($f_ini,"Fun",$k2,$v2)
	For $i=1 To $k2[0]
		If StringInStr($v2[$i],$y) Then
			IniDelete($f_ini,"Fun",$k2[$i])
			IniDelete($p_ini,"Par",StringLeft($k2[$i],StringInStr($k2[$i],"(")-1))
			$f_str=StringReplace($f_str&"?",StringReplace($k2[$i],"\","=")&"?","")
		EndIf
	Next
	_cf_null()
	Dim $f_array=StringSplit($f_str,"?"),$x=GUICtrlRead($d_combo)
	IniDelete($d_ini,"Dir",$y)
	_IniReadSection($d_ini,"Dir",$k1,$v1)
	For $i=1 To $k1[0]
		If $v1[1]=$x Then
			GUICtrlSetData($i_combo,"?"&$i_null&"?"&$i_str,$i_null)
			Return
		EndIf
	Next
	_d_Delete($x,$k1,$v1)
EndFunc

Func _Correct($y,ByRef $array,ByRef $str,$txt)
	$str=StringReplace("?"&$str&"?","?"&$y&"?","?")
	If StringLeft($str,1)="?" Then $str=StringMid($str,2)
	If StringRight($str,1)="?" Then $str=StringTrimRight($str,1)
	$array=StringSplit($str,"?")
	_WriteFile($txt,$str)
EndFunc

Func _Recurse()
	Dim $k1,$v1,$k2,$v2,$x=GUICtrlRead($i_combo)
	_IniReadSection($i_ini,"Inc",$k1,$v1)
	For $i=1 To $v1[0]
		If StringInStr($v1[$i],$x) Then Return 1
	Next
	_IniReadSection($f_ini,"Fun",$k2,$v2)
	For $i=1 To $v2[0]
		If StringInStr($v2[$i],$x) Then Return 1
	Next
	_i_Delete($x,$k1,$v1,$k2,$v2);;;;;;;;;;;
EndFunc

Func _cf_null()
	GUICtrlSetData($c_combo,"?"&$c_null&"?"&$c_str,$c_null)
	_c_Combo(1)
	GUICtrlSetData($f_combo,"?"&$f_null&"?"&$f_str,$f_null)
	_f_Combo(1)
EndFunc
#EndRegion
#Region;---secondary functions---------------------------------------------------
Func _c_ClipPut()
	Dim $y="",$x=""
	If GUICtrlRead($c_copy[0])=1 Then $y=GUICtrlRead($c_combo)
	If GUICtrlRead($c_copy[1])=1 Then
		If $y Then $y&=" = "
		$x=GUICtrlRead($c_edit)
		If StringIsInt($x)=0 And StringLeft($x,2)<>"0x" Then $x=StringReplace(StringReplace(StringReplace(IniRead($c_ini,"Con",StringReplace(StringReplace(GUICtrlRead($c_combo),"[","´"),"]","`"),""),"~",Chr(34)),"´","["),"`","]")
	EndIf
	ClipPut(StringReplace($y&$x,"°",""))
	If $msg=$c_clip Then Return
	;c_paste
EndFunc

Func _c_Copy($x)
	$c_state[$x]=($c_state[$x]=0)
	GUICtrlSetState($c_copy[$x],$c_state[$x]+3*($c_state[$x]=0))
	If GUICtrlRead($c_copy[0])=4 And GUICtrlRead($c_copy[1])=4 Then
		GUICtrlSetState($c_copy[$x=0],1)
		$c_state[$x=0]=1
	EndIf
EndFunc

Func _f_ClipPut($g=0)
	ClipPut(_f_Copy(FileRead(IniRead($f_ini,"Fun",StringReplace(GUICtrlRead($f_combo),"=","\"),"")),GUICtrlRead($f_combo),GUICtrlRead($f_comment),$g))
	If $msg=$f_clip Then Return
	;f_paste
EndFunc

Func _f_Copy($content,$y,$comment,ByRef $b);iniread dauert zu lange !
	Dim $t=StringSplit($content,@CRLF,1),$start=0,$max=$maxstrlen,$header=0,$pre=0
	While 1
		For $i=1 To $t[0]
			$x=StringStripWS($t[$i],8)
			If StringInStr($x,"Func"&StringLeft($y,$max))=1 Then $start=$i
			If $comment=1 And $start=0 Then
				If $header>0 And StringLeft($x,1)<>";" And StringLeft($x,1)<>"" Then $header=0
				If StringLeft($x,1)=";" And $header=0 Then $header=$i
				If StringInStr($x,"#cs") Then $pre=$i
			EndIf
			If $start>0 And StringLeft($x,7)="EndFunc" Then ExitLoop
		Next
		If $comment=1 Then
			If $header>0 Then $start=$header
			If $pre>0 And $pre<$start Then $start=$pre
		EndIf
		Dim $ret="",$b=2
		For $j=$start To $i
			If $j>$t[0] Then
				$max-=50
				$b=0
				ExitLoop
			EndIf
			$ret&=$t[$j]&@CRLF
			$b+=1
		Next
		If $b>1 Then ExitLoop
	WEnd
	Return $ret
EndFunc

Func _f_example($y)
	$a=StringReplace(StringLeft($y,StringInStr($y,"(")-1),"Include","Examples\Helpfile\")&".au3"
	_SciGUI($a,FileRead($a),-1)
EndFunc

Func _f_run($y)
	Run(@AutoItExe&" "&FileGetShortName(StringReplace(StringLeft($y,StringInStr($y,"(")-1),"Include","Examples\Helpfile\")&".au3"))
EndFunc

Func _f_help($y); ShellExecute geht leider nicht ?
	Run(@WindowsDir&"\hh.exe ms-its:"&StringReplace(StringReplace(GUICtrlRead($d_combo),"\Include",""),"\","/")&"/UDFs3.chm::/html/libfunctions/"&StringLeft($y,StringInStr($y,"(")-1)&".htm")
EndFunc

Func _p_List($x)
	If $x="" Then Return
	For $i=1 To $scriptarray[0]
		If $x=$scriptarray[$i] Then ExitLoop
	Next
	If $i>$scriptarray[0] Then Return
	$chosen=$i
	GUICtrlSetTip($p_list,$patharray[$chosen])
	GUICtrlSetState($p_select,64)
	GUICtrlSetState($p_delete,64)
	GUICtrlSetState($p_view,64)
	GUICtrlSetState($p_all,64)
EndFunc

Func _p_Delete($i)
	$pathlist=StringReplace($pathlist,$patharray[$i]&"?","")
	$scriptlist=StringReplace("?"&$scriptlist,"?"&$scriptarray[$i]&"?","?")
	If StringLeft($scriptlist,1)="?" Then $scriptlist=StringMid($scriptlist,2)
	$filecount-=1
	Dim $scriptarray=StringSplit($scriptlist,"?"),$patharray=StringSplit($pathlist,"?"),$x="",$s="s";,$i=0	?
	If $filecount=1 Then $s=""
	If $filecount Then $x="  ["&$filecount&" Item"&$s&"] "
	GUICtrlSetData($p_myScripts,"My Scripts"&$x)
	GUICtrlSetData($p_list,"?"&$scriptlist)
	GUICtrlSetState($p_select,128)
	GUICtrlSetState($p_delete,128)
	GUICtrlSetState($p_view,128)
	GUICtrlSetState($p_all,128)
EndFunc

Func _p_exc($x)
	GUICtrlSetState($p_com,68+64*($x>1))
	GUICtrlSetState($p_dec,68+64*($x=4))
EndFunc

Func _p_Open()
	$a=FileOpenDialog("Open .au3 script(s)","","AutoIt files (*.au3)",7)
	If @error Then Return
	GuiSetState(@SW_DISABLE,$m_GUI)
	FileChangeDir(@ScriptDir)
	$a=StringSplit($a,"|")
	If $a[0]=1 Then
		_List($a[1])
	Else
		For $i=2 to $a[0]
			_List($a[1]&"\"&$a[$i])
		Next
	EndIf
	Dim $scriptarray=StringSplit($scriptlist,"?"),$patharray=StringSplit($pathlist,"?")
	GuiSetState(@SW_ENABLE,$m_GUI)
EndFunc

Func _p_View($a)
	If GUICtrlRead($o_FreeStyle)=1 Then _SciGUI($a,FileRead($a),0)
	If GUICtrlRead($o_SciTE)=1 Then
	;	bei neuer instanz vorher patchen
	;	wenn ini ="" dann gehts nicht
	;	wenn ini =0 dann lassen
	;	wenn ini =anders dann replace mit ini
	;	wenn ini #fse dann den ganzen satz replacen
		Run($scitePath&"SciTE.exe "&$a);option
	;	zurückpasten
	EndIf
EndFunc

Func _p_Select()	;	admin

EndFunc
#EndRegion
#Region;---minor functions-------------------------------------------------------
Func _Ignore($x)
	If StringInStr("?"&$ignorelist,"?"&$x&"?") Then Return
	If $sounds Then DllCall("winmm.dll","int","mciSendStringA","str","play "&FileGetShortName(@WindowsDir&"\Media\recycle.wav"),"str","","int",65534,"hwnd",0)
	GUICtrlSetData($ign_list,$x,$x)
	GUICtrlSetState($ign_main,65)
	GUICtrlSetImage($i_ignore,"shell32.dll",33,0)
	GUICtrlSetImage($f_ignore,"shell32.dll",33,0)
	GUICtrlSetImage($c_ignore,"shell32.dll",33,0)
	$ignorelist&=$x&"?"
EndFunc

Func _ign_List($x)
	GUICtrlSetTip($ign_list,_ign_View($x))
	GUICtrlSetState($ign_view,64+64*(StringRight(StringReplace($x,"°",""),4)<>".au3" And StringLeft($x,1)="$"))
	GUICtrlSetState($ign_restore,64)
EndFunc

Func _ign_View($x)
	If StringRight(StringReplace($x,"°",""),4)=".au3" Then
		If $msg=$ign_list Then Return $x
		If $msg=$ign_view Then _p_View($x)
	ElseIf StringLeft($x,1)="$" Then
		$x1=StringReplace(StringReplace($x,"[","´"),"]","`")	
		Return $x&" = "&StringReplace(StringReplace(StringReplace(IniRead($c_ini,"Con",$x1,""),"~",'"'),"´","["),"`","]")&@LF&IniRead($i_ini,"Inc",$x1,"")
	ElseIf StringInStr($x,"(") And StringInStr($x,")") Then
		Dim $ret=IniRead($f_ini,"Fun",StringReplace($x,"=","\"),""),$ret2=0
		If $msg=$ign_list Then Return $x&@LF&$ret
		$ret1=_f_Copy(FileRead($ret),$x,1,$ret2)
		If $msg=$ign_view Then _SciGUI($ret,$ret1,$ret2);???????
	EndIf
EndFunc

Func _ign_Restore($x)
	If $x="" Then Return
	If $sounds Then DllCall("winmm.dll","int","mciSendStringA","str","play "&FileGetShortName(@WindowsDir&"\Media\recycle.wav"),"str","","int",65534,"hwnd",0)
	$ignorelist=StringReplace("?"&$ignorelist,"?"&$x&"?","?")
	If StringLeft($ignorelist,1)="?" Then $ignorelist=StringMid($ignorelist,2)
	GUICtrlSetTip($ign_list,"")
	GUICtrlSetState($ign_view,128)
	GUICtrlSetState($ign_restore,128)
	GUICtrlSetData($ign_list,"?"&$ignorelist)
	If $ignorelist Then Return
	GUICtrlSetState($ign_main,132)
	GUICtrlSetImage($i_ignore,"shell32.dll",32,0)
	GUICtrlSetImage($c_ignore,"shell32.dll",32,0)
	GUICtrlSetImage($f_ignore,"shell32.dll",32,0)
EndFunc

Func _o_Editor()
	$a=FileOpenDialog("Choose your custom Editor",@HomeDrive,"Executables (*.exe)",3)
	If @error Then Return
	GUICtrlSetTip($o_edit,$a)
	GUICtrlSetData($o_edit,$a)
	GUICtrlSetState($o_SciTE,4)
	GUICtrlSetState($o_FreeStyle,4)
	GUICtrlSetState($o_instance,132)
	If GUICtrlRead($o_save)=1 Then IniWrite($s_ini,"SciTE","Editor",$a)
EndFunc

Func _o_open()
	$a=FileOpenDialog("Open Script or FreeStyle log file",@ScriptDir&"\FS_Backup","AutoIt3 and FreeStyle log files (*.au3)",3)
	If @error=0 Then _p_View($a)
EndFunc
; wenn "z" in edit, dann absturz
Func _s_Combo();drop suchbegriff geht nicht
	ToolTip("")
	$y=GUICtrlRead($s_combo)
	$Keyword=GUICtrlRead($s_edit)
	GUICtrlSetState($s_button,128)
	GUICtrlSetTip($s_button,"Perform Search")
	If $y="Function Declarations" Then ToolTip("A Function Search may last quite a long time !",Default,Default,"Attention !",2,5)
	If StringStripWS($Keyword,8)="" Or $Keyword="Enter Keyword" Then Return
	If $y="Entire Library" Or $y="Global Constants" Or $y="Function Declarations" Or $y="Functions Library" Then GUICtrlSetState($s_button,64)
	If $y="Specified Directory" Then GUICtrlSetState($s_button,128-64*(StringInStr(GUICtrlRead($d_combo),"\")>0))
	If $y="Specified File" Then GUICtrlSetState($s_button,128-64*(StringRight(StringReplace(GUICtrlRead($i_combo),"°",""),4)=".au3"))
	If GUICtrlRead($s_forum)=1 And StringLen(StringStripWS($Keyword,8))>2 Then GUICtrlSetState($s_button,64)
	GUICtrlSetState($s_edit,256)
	GUICtrlSetData($s_edit,$Keyword)
	If StringLeft($Keyword,1)="$" Then;oder c ohne $ ?
		$t=StringInStr("?"&$c_str,"?"&$Keyword)
		If $t=0 Then Return
		Dim $t1=StringMid($c_str,$t),$t2=StringInStr($t1,"?")
		GUICtrlSetData($c_combo,StringLeft($t1,$t2-1))
		_c_Combo()
		Return
	EndIf
	$t=StringInStr("?"&$f_str,"?"&$Keyword)
	If $t=0 Then Return
	Dim $t1=StringMid($f_str,$t),$t2=StringInStr($t1,"?")
	GUICtrlSetData($f_combo,StringLeft($t1,$t2-1))
	_f_Combo()
EndFunc;kürzel für forumsuche (general,gui,examples)
#EndRegion
#Region;---major functions-------------------------------------------------------
Func _Search()
	ToolTip("")
	GUISetState(@SW_DISABLE,$m_GUI)
	_SplashOn()
	Dim $Keyword=GUICtrlRead($s_edit),$region=GUICtrlRead($s_combo),$b=0,$result="",$old=""
	If GUICtrlRead($s_forum)=1 Then; noch search options
		IniWrite("FS_Search\FS_Search_Engine.ini","Search","Keyword",$Keyword)
		Run(@AutoItExe&" "&FileGetShortName(@ScriptDir&"\"&$FS_Engine))
		If $region="Search in ..." Then Sleep(5000)
	EndIf
	If StringInStr($region,"Function") Then
		For $i=1 To $f_array[0]
			If StringInStr($f_array[$i],$Keyword,2)=0 Then
				If $region="Functions Library" Then ContinueLoop
				$t=IniRead($f_ini,"Fun",StringReplace($f_array[$i],"=","\"),"")
				If $old=$t Then ContinueLoop
				$con=FileRead($t)
				If StringInStr($con,$Keyword,2)=0 Then
					$old=$t
					ContinueLoop
				EndIf
				If StringInStr(_f_Copy($con,$f_array[$i],GUICtrlRead($s_comments),$b),$Keyword,2)=0 Then ContinueLoop
			EndIf;hier stringreplace \ =
			$result&="?"&StringReplace($f_array[$i],"\","=")
		Next
		GUICtrlSetData($f_combo,"?Search Results for "&$Keyword&$result,"Search Results for "&$Keyword)
	ElseIf $region="Global Constants" Then
		For $i=1 To $c_array[0];con?
			If StringInStr($c_array[$i]&StringReplace(StringReplace(StringReplace(IniRead($c_ini,"Con",StringReplace(StringReplace($c_array[$i],"[","´"),"]","`"),""),"~",'"'),"´","["),"`",")"),$Keyword,2) Then $result&="?"&$c_array[$i]
		Next
		GUICtrlSetData($c_combo,"?Search Results for "&$Keyword&$result,"Search Results for "&$Keyword)
	ElseIf $region="Specified File" Then
		$y=GUICtrlRead($i_combo)
		$content=FileRead(IniRead($d_ini,"Dir",$y,"")&"\"&StringReplace($y,"°",""))
	;	If StringInStr($content,$Keyword,2) Then => scite editor
	ElseIf $region<>"Search in ..." Then
		If $region="Specified Directory" Then $y=GUICtrlRead($d_combo)
		For $i=1 To $i_array[0];entire library auch c und f namen !
			If $region="Entire Library" Then $y=IniRead($d_ini,"Dir",$i_array[$i],"")
			If (($region="Specified Directory" And IniRead($d_ini,"Dir",$i_array[$i],"")=$y) Or $region="Entire Library") And StringInStr(FileRead($y&"\"&$i_array[$i]),$Keyword) Then $result&="?"&$i_array[$i]
		Next
		If $region="Entire Library" Then GUICtrlSetData($d_combo,"All registered Directories")
		GUICtrlSetData($i_combo,"?Search Results for "&$Keyword&$result,"Search Results for "&$Keyword)
	EndIf;sollten jeweils auch c und f updated werden ?
	_SplashOff()
	GUISetState(@SW_ENABLE,$m_GUI)
	If $region="Search in ..." Then Return
	If $result Then
		$t=StringSplit(StringMid($result,2),"?"); text ändern für entire libraries  ...Entries in region 
		MsgBox(262192,"FreeStyle Search",'Search Text "'&$Keyword&'" found '&$t[0]&" time(s) in "&$region&".        ")
		Return
	EndIf
	MsgBox(262192,"FreeStyle Search","'"&$Keyword&"' could not be found in "&$region&".        ")
EndFunc;accept zips and html
;beim droppen wird möglicherweise falsch überschrieben ???
Func _Drop($hWnd,$Msg,$wParam,$lParam);stimmt was nicht bei schon vorhanden !
	WinActivate($m_GUI)
	GuiSetState(@SW_DISABLE,$m_GUI)
	GUIRegisterMsg(0x0233,"")
	Dim $drop=0,$x=DllStructCreate("char[260]"),$c=DllCall("shell32.dll","int","DragQueryFile","hwnd",$wParam,"uint",-1,"ptr",DllStructGetPtr($x),"int",DllStructGetSize($x))
	If GUICtrlRead($o_through)=1 And (GUICtrlRead($tab,1)<>$admin Or GUICtrlRead($o_drop)=1) Then Dim $drop=1,$dropcount=$filecount,$droplist=$scriptlist,$droppath=$pathlist
	For $i=0 To $c[0]-1
		DllCall("shell32.dll","int","DragQueryFile","hwnd",$wParam,"uint",$i,"ptr",DllStructGetPtr($x),"int",DllStructGetSize($x))
		_List(DllStructGetData($x,1),1);	_c_Update();	_f_Update()
    Next
    DllCall("shell32.dll","int","DragFinish","hwnd",$wParam)
	If $drop=1 And $droplist<>$scriptlist Then
		If $droplist Then Dim $scriptlist=StringReplace($scriptlist,$droplist,""),$pathlist=StringReplace($pathlist,$droppath,"")
		Dim $scriptarray=StringSplit($scriptlist,"?"),$patharray=StringSplit($pathlist,"?")
		_PatchIt(GUICtrlRead($p_fly),$dropcount)
		Dim $scriptlist=$droplist,$pathlist=$droppath
	EndIf
	Dim $scriptarray=StringSplit($scriptlist,"?"),$patharray=StringSplit($pathlist,"?")
	GuiSetState(@SW_ENABLE,$m_GUI)
	GUIRegisterMsg(0x0233,"_Drop")
	Return "$GUI_RUNDEFMSG"	;nicht wenn admin
EndFunc

Func _List($y,$so="")
	Dim $b=FileGetAttrib($y)
	If StringInStr($b,"D") Then
		If GUICtrlRead($o_drop)=4 And GUICtrlRead($tab,1)=$admin Then
			_Add_Dir($y)
			Return
		EndIf
		Dim $file=FileFindFirstFile($y&"\*.au3"),$t=""
		While 1;unterverzeichnisse mit wildcard und in der schleife aussortieren
			$t1=FileFindNextFile($file)
			If @error Then ExitLoop
			$t&="|"&$y&"\"&$t1
		WEnd
		FileClose($file)
		If $t="" Then Return
		$y=StringMid($t,2)
	EndIf
	If GUICtrlRead($o_drop)=4 And GUICtrlRead($tab,1)=$admin And StringRight($y,4)=".au3" And $y<>@ScriptFullPath Then
		_Add_File($y)
		Return
	EndIf	;if admin tab und nicht _p_open und .au3 und nicht scriptfullpath dann _add_file contloop
	$t=StringSplit($y,"|")
	For $j=1 To $t[0]
		$b=FileGetAttrib($t[$j]);stimmt was nicht bei schon vorhanden !
	;	If StringInStr($b,"D") Then _List($t[$j],$so)	;	geht nicht !!!
		If StringRight($t[$j],4)<>".au3" Or StringInStr($pathlist,$t[$j])<>0 Or $t[$j]=@ScriptFullPath Then ContinueLoop
		If StringInStr($b,"R") Then;nicht bei admin tab
			MsgBox(0,$t[$j],"File is readonly."&@LF&@LF&"Please remove flag first.        ")
			WinActivate($m_GUI)
			ContinueLoop
		EndIf
		$a=StringMid($t[$j],StringInStr($t[$j],"\",2,-1)+1)
		If StringInStr("?"&$i_str&"?","?"&$a&"?") Then;nicht bei admin tab
			$b=IniRead($d_ini,"Dir",$a,"")
			If $b&"\"&$a=$t[$j] Then
				MsgBox(0,$t[$j],"Include Files must not be processed !         ")
				WinActivate($m_GUI)
				ContinueLoop
			EndIf
		EndIf;Windows XP-Ping.wav;Windows XP-Standard.wav;chimes.wav;ding.wav;chord.wav;notify.wav
		If $sounds And $so Then DllCall("winmm.dll","int","mciSendStringA","str","play "&FileGetShortName(@WindowsDir&"\Media\Windows XP-Start.wav"),"str","","int",65534,"hwnd",0)
		$scriptlist&=$a&"?"
		$pathlist&=$t[$j]&"?"
		$filecount+=1
		$s="s"
		If $filecount=1 Then $s=""
		GUICtrlSetData($p_list,$a)
		GUICtrlSetData($p_myScripts,"My Scripts  ["&$filecount&" Item"&$s&"] ")
	Next	
EndFunc

Func _PatchIt($fly,$dropcount="");problem: stringlen ($patchfile) $a over limit ?
	If $pathlist="" Or (GUICtrlRead($p_exc)=4 And GUICtrlRead($p_exf)=4) Then
		MsgBox(270384,"FreeStyle Error","Nothing to process !        ")
		Return
	EndIf
	$pos=WinGetPos($m_GUI)
	GUISetState(@SW_DISABLE,$m_GUI)
	SplashTextOn("Splash",@LF&"Please stand by ..."&@LF,200,100,$pos[0]+$pos[2]/2-100,$pos[1]+$pos[3]/2-50,17)
	Dim $script[3]=[2,$patharray[$chosen],""],$scra=$scriptarray,$steps[2],$conlist[2],$funclist[2],$exc=GUICtrlRead($p_exc),$exf=GUICtrlRead($p_exf),$dec=GUICtrlRead($p_dec),$ign=GUICtrlRead($ign_main)*($ignorelist<>"")
	If GUICtrlRead($p_all)=4 Or $dropcount Then Dim $script=$patharray,$steps[$patharray[0]+1],$conlist[$patharray[0]+1],$funclist[$patharray[0]+1],$chosen=1
	For $i=1 To $script[0]-1;$conlist[2],$funclist[2] muss nicht unbedingt array sein !
		GUICtrlSetData($p_list,$scra[$chosen]);nur für prompts ???
		If FileExists($script[$i])=0 Then
			MsgBox(270384,"FreeStyle Error",'File "'&$script[$i]&'"        '&@LF&"does not exist any more and will be skipped !        ")
			If GUICtrlRead($p_remove)=1 Then _p_Delete($i)
			ContinueLoop
		EndIf
		Dim $begin=TimerInit(),$fileopen=FileOpen($script[$i],0),$a=FileRead($fileopen),$linecount=StringSplit($a,@CRLF,1),$speed=IniRead($s_ini,"Data","Speed",2),$estimated=$linecount[0]*$speed,$logfile=0,$top="",$bottom="",$step=0,$count=0,$gdiplus=0,$_ie=0,$word=0
		FileClose($fileopen)
		If GUICtrlRead($p_log)=1 Then;	ca 100 lines / min !
			Dim $log="FS_Backup\"&@YEAR&@MON&@MDAY&@HOUR&@MIN&@SEC&"."&StringTrimRight($scra[$i],3)&"log.au3",$logfile=FileOpen($log,10)
			_Log($logfile,'Patching of ['&$script[$i]&'] iniciated.')
		EndIf
		If GUICtrlRead($p_backup)=1 Then
			$x="FS_Backup\"&@YEAR&@MON&@MDAY&@HOUR&@MIN&@SEC
			FileCopy($script[$i],$x&"."&$scra[$i])
			If $logfile Then _Log($logfile,'['&$script[$i]&'] backed up to ['&@ScriptDir&'\FS_Backup\'&$x&"."&$scra[$i]&'].')
		EndIf;	zeit in splash
		;	_Log($logfile,'Elapsed time: '&Int($time/60)&" min "&Int($time-Int($time/60)*60)&" sec.")
		;	bereits hier comments aus $a rausschneiden "
		While 1	;	wenn script klein, dann anders !
			$step+=1
			Dim $a1=StringReplace(StringReplace($a&$bottom,@TAB,"")," ",""),$a2=StringReplace(StringReplace($top&$a&$bottom,@TAB,"")," ","")
			ControlSetText("Splash","","Static1",@LF&"Analyzing Script"&@LF&$i&" of "&$script[0]-1&@LF&"Step "&$step,1)
			If $exc<4 Then; Headers, comments, "", '' dürfen nicht durchsucht werden !!
				For $j=1 To $c_array[0]	;		constantsearch
					$find=$c_array[$j]
					If StringInStr($find,"[") Then $find=StringLeft($find,StringInStr($find,"["))
					If StringInStr($a2,$find,2)=0 Or StringInStr($a2,@CRLF&"GlobalConst"&$c_array[$j]&"=",2) Then ContinueLoop
					$x=StringInStr($a2,$c_array[$j]&"=")
					If $x Then;	wenn kommentiert ?;or enum or =
						$t=StringInStr(StringLeft($a2,$x),@LF,2,-1)
						$u=StringMid($a2,$t,$x-$t)
						If StringInStr($u,";")=0 Or StringLeft($u,2)<>"If" Then
							If $logfile Then _Log($logfile,'Global Const '&$c_array[$j]&' skipped ... already defined.')
							ContinueLoop
						EndIf
					EndIf
					If $ign=1 And (StringInStr("?"&$ignorelist,"?"&$c_array[$j]&"?") Or (StringInStr($ignorelist,".au3?") And StringInStr("?"&$ignorelist,"?"&IniRead($i_ini,"Inc",StringReplace(StringReplace($c_array[$j],"[","´"),"]","`"),"")&"?"))) Then
						If $logfile Then _Log($logfile,'Global Const '&$c_array[$j]&' ignored.')
						ContinueLoop
					EndIf
					Dim $occ=0,$found=0,$text=""
					While 1
						$occ+=1
						$x=StringInStr($a&$bottom,$find,2,$occ)
						If $x=0 Then ExitLoop
						$Char=StringMid($a&$bottom,$x+StringLen($find),1)
						If $find=$c_array[$j] And StringInStr(" &,+-*/^)]}<=>",$Char,2)=0 And $Char<>@TAB And $Char<>@LF And $Char<>@CR Then ContinueLoop
						$conlist[$i]&="|"&$c_array[$j]&$Char;wird in top erst def.
						$found+=1
						If $exc=2 Or $find<>$c_array[$j] Then ExitLoop
					WEnd
					$steps[$i]+=$found
					If ($x=0 And $found=0) Or $logfile=0 Then ContinueLoop
					If $exc=1 Then $text=$found&" occurrence(s) of "
					_Log($logfile,$text&'Global Const '&$c_array[$j]&' found.')
				Next
				If $logfile Then
					_Log($logfile,"Search for Global Const completed.")
					If $conlist[$i]="" Then _Log($logfile,'Not found any Global Const in ['&$script[$i]&'].')
				EndIf
			EndIf
			If $exf=1 Then
				For $j=1 To $f_array[0]	;		funcsearch
					Dim $y=StringLeft($f_array[$j],StringInStr($f_array[$j],"(",2)-1),$occ=0
					If StringInStr($a1,$y&"(",2)=0 Or StringInStr($a1,@CRLF&"Func"&$y&"(",2) Then ContinueLoop
					If $ign=1 And (StringInStr("?"&$ignorelist,"?"&$f_array[$j]&"?") Or (StringInStr($ignorelist,".au3?") And StringInStr("?"&$ignorelist,"?"&IniRead($p_ini,"Par",$y,"")&"?"))) Then
						If $logfile Then _Log($logfile,'(UD) Func '&$y&' ignored.')
						ContinueLoop
					EndIf
					While 1;	vorher checken, ob #cs ? egal ? in _scilex beispiel
						$occ+=1
						$x1=StringInStr($a&$bottom,$y,2,$occ)
						$x=StringInStr($a1,$y,2,$occ)
						If $x1=0 Then ExitLoop
						If StringMid($a1,$x+StringLen($y),1)<>"(" Then ContinueLoop
						$Char=StringMid($a&$bottom,$x1-1,1)
						If $Char<>" " And $Char<>@TAB And $Char<>@LF And $Char<>@CR Then
							$Char=StringMid($a1,$x-1,1)
							If StringInStr("&,+-*/^([{<=>",$Char,2)=0 And $Char<>@LF And $Char<>@CR Then ContinueLoop
						EndIf
						If $logfile Then _Log($logfile,'(UD) Func '&$y&'() found.')
						$funclist[$i]&="|"&$y
						$steps[$i]+=1
						ExitLoop
					WEnd
				Next
				If $logfile Then
					_Log($logfile,"Search for (UD) Functions completed.")
					If $funclist[$i]="" Then _Log($logfile,'Not found any (UD) Functions in ['&$script[$i]&'].')
				EndIf
			EndIf; kontrollieren, ob andere const (const=) oder func (func();	MsgBox(0,TimerDiff($begin)/1000,$conlist[$i]&@LF&@LF&$funclist[$i]&@LF&@LF&$steps[$i])
			If $funclist[$i]="" And $conlist[$i]="" Then ExitLoop
			If $conlist[$i] Then;	If $fly=4 Then;tasks	;step by step frage
				$task=StringSplit(StringMid($conlist[$i],2),"|")
				For $j=1 To $task[0]
					ControlSetText("Splash","","Static1",@LF&"Patching Script "&$i&"/"&$script[0]-1&@LF&"Task "&$j&" of "&$steps[$i]&@LF&"Step "&$step,1);flag1=redraw
					$ref=IniRead($i_ini,"Inc",StringReplace(StringReplace(StringTrimRight($task[$j],1),"[","´"),"]","`"),"")
					If $gdiplus=0 Then $gdiplus=_lex_GDIPlus($ref);noch anders
					If $_ie=0 Then $_ie=_lex_IE($ref)
					If $word=0 Then $word=_lex_Word($ref)
					$val=StringReplace(StringReplace(StringReplace(IniRead($c_ini,"Con",StringReplace(StringReplace(StringTrimRight($task[$j],1),"[","´"),"]","`"),""),"~",Chr(34)),"´","["),"`","]")
					If StringIsInt($val) And $dec=4 Then $val="0x"&_DecToHex($val)
					$count+=1
					If $exc=1 And StringInStr($task[$j],"[")=0 Then	;	checken " oder ' ?
						;if comment.....
						$a=StringReplace($a,$task[$j],$val&StringRight($task[$j],1),1);"the number of replacements performed is stored in @extended."
						$bottom=StringReplace($bottom,$task[$j],$val&StringRight($task[$j],1),1);"the number of replacements performed is stored in @extended."
						If $logfile Then _Log($logfile,"Task "&$count&" of "&$steps[$i]&' Replace '&StringTrimRight($task[$j],1)&' with '&$val&' .... processed. Referenced file: ['&$ref&'].')
					Else;nach den includes ? strinstr(,,2,-1) "[optional] Which occurrence of the substring to find in the string. Use a negative occurrence to search from the right side."
						$top&="Global Const "&StringTrimRight($task[$j],1)&" = "&$val&@CRLF
						If $logfile Then _Log($logfile,"Task "&$count&" of "&$steps[$i]&' Add Global Const '&StringTrimRight($task[$j],1)&" = "&$val&' to top of script .... processed. Referenced file: ['&$ref&'].')
					EndIf
				Next
				$conlist[$i]=""
			EndIf
			If $funclist[$i] Then
				$task=StringSplit(StringMid($funclist[$i],2),"|")
				For $j=1 To $task[0]
					$count+=1
					ControlSetText("Splash","","Static1",@LF&"Patching Script "&$i&"/"&$script[0]-1&@LF&"Task "&$j&" of "&$steps[$i]&@LF&"Step "&$step,1);zusammenfassen ?
					$ref=IniRead($p_ini,"Par",$task[$j],"")
					If $gdiplus=0 Then $gdiplus=_lex_GDIPlus($ref);noch anders
					If $_ie=0 Then $_ie=_lex_IE($ref)
					If $word=0 Then $word=_lex_Word($ref)
					$bottom&=@CRLF&_f_Copy(FileRead(IniRead($p_ini,"Par",$task[$j],"")),$task[$j],GUICtrlRead($p_head),$x)
					If $logfile Then _Log($logfile,"Task "&$count&" of "&$steps[$i]&' Add Func '&$task[$j]&'(......) ...... EndFunc to bottom of script .... processed. Referenced file: ['&$ref&'].')
				Next
				$funclist[$i]=""
			EndIf
			If $logfile Then _Log($logfile,"All tasks processed."&@LF&"Recursing (Step "&$step&") ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...")
		WEnd
		If $gdiplus=1 Then;zusammenfassen
			$count+=1
			$top&=@CRLF&"Global $ghGDIPBrush = 0, $ghGDIPDll = 0, $ghGDIPPen = 0, $giGDIPRef = 0, $giGDIPToken = 0"&@CRLF
			If $logfile Then _Log($logfile,"Task "&$count&" of "&$count&' Detected GDIPlus.au3 references - Added special GDIPlus.au3 Declarations to top of script.')
		EndIf
		If $_ie=1 Then
			$count+=1
			$top&=@CRLF&"Global $__IELoadWaitTimeout = 300000, $__IEAU3Debug = False, $__IEAU3V1Compatibility, $_IEErrorNotify = True, $oIEErrorHandler, $sIEUserErrorHandler, $IEComErrorNumber, $IEComErrorNumberHex, $IEComErrorDescription, $IEComErrorScriptline, $IEComErrorWinDescription, $IEComErrorSource, $IEComErrorHelpFile, $IEComErrorHelpContext, $IEComErrorLastDllError, $IEComErrorComObj, $IEComErrorOutput"&@CRLF
			If $logfile Then _Log($logfile,"Task "&$count&" of "&$count&' Detected IE.au3 references - Added special IE.au3 Declarations to top of script.')
		EndIf
		If $word=1 Then
			$count+=1
			$top&=@CRLF&"Global $__WordAU3Debug = False, $_WordErrorNotify = True, $oWordErrorHandler, $sWordUserErrorHandler, $WordComErrorNumber, $WordComErrorNumberHex, $WordComErrorDescription, $WordComErrorScriptline, $WordComErrorWinDescription, $WordComErrorSource, $WordComErrorHelpFile, $WordComErrorHelpContext, $WordComErrorLastDllError, $WordComErrorComObj, $WordComErrorOutput"&@CRLF
			If $logfile Then _Log($logfile,"Task "&$count&" of "&$count&' Detected Word.au3 references - Added special Word.au3 Declarations to top of script.')
		EndIf
		If StringInStr(StringReplace(StringReplace($a1,"'","~"),'"',"~"),"Opt(~MustDeclareVars~,1)",2) Then
			$count+=1	; problem: opt mustdeclvals, dann nur const in top möglich !
			$occ=1
			While 1
				Dim $x=StringInStr($a,"MustDeclareVars",2,$occ),$t=$x+16
				If $x=0 Then ExitLoop
				Do
					$t+=1
					If StringMid($a,$t,1)="1" Then ExitLoop(2)
				Until StringMid($a,$t,1)="0"
				$occ+=1
			WEnd
			If $x>0 Then
				$a=StringReplace($a,$t,"0")
				If $logfile Then _Log($logfile,"Task "&$count&" of "&$count&' Replace Opt("MustDeclareVars",1) with Opt("MustDeclareVars",0) .... processed. (This step may not be necessary in particular cases.)')
			EndIf
		EndIf
		$occ=1		;splash
		While 1;nur wenn nicht angekreuzt
			$x=StringInStr($a,"#Include",2,$occ)
			If $x=0 Then ExitLoop
			If StringMid($a,$x-1,1)<>";" Then $a=StringReplace($a,"#Include",";#Include")
			$occ+=1
		WEnd;splash
		If $occ>1 Then
			$top&=" "
			If $logfile Then _Log($logfile,"Task "&$count+1&" of "&$count+1&" Comment out #Include ... ("&$occ-1&" occurrence(s)) .... processed.")
		EndIf
		Dim $com1=@CRLF&@CRLF&"#Region --- Script patched by FreeStyle code Start "&@MDAY&"."&@MON&"."&@YEAR&" - "&@HOUR&":"&@MIN&":"&@SEC&@CRLF,$com2=@CRLF&"#EndRegion --- Script patched by FreeStyle code End"&@CRLF
		If $bottom Then $bottom=$com1&$bottom&@CRLF&$com2
		If $top Then $top=$com1&$top&$com2
		If $bottom="" And $top="" Then $top=StringReplace(StringReplace($com1&$com2,"patched","analyzed"),"code End","code End - no patching necessary")
		$a=$top&$a&$bottom
		$fileopen=FileOpen($script[$i],10)
		FileWrite($fileopen,$a)
		FileClose($fileopen)
		If GUICtrlRead($p_remove)=1 Then _p_Delete($chosen+$dropcount)
		$time=Round(TimerDiff($begin)/1000,2)
		If $logfile Then
			_Log($logfile,'Patching of ['&$script[$i]&'] successfully completed.')
			_Log($logfile,'Elapsed time: '&Int($time/60)&" min "&Int($time-Int($time/60)*60)&" sec.")
			FileClose($logfile)
		EndIf
		IniWrite($s_ini,"Data","Speed",$linecount[0]/$time)
	Next
	SplashOff()
	GUICtrlSetState($apply,16)
	If $logfile Then;zusammenfassen
		$msg=MsgBox(270404,"FreeStyle","All Files processed.        "&@LF&@LF&"Do you want to view the logfile(s) ?        ")
		If $msg=6 Then
			If $i>2 Then
				$msg=FileOpenDialog(" Open FreeStyle log file",@ScriptDir&"\FS_Backup","FreeStyle log files (*.log.au3)",3,$log)
				If $msg Then $log=StringMid($msg,StringInStr($msg,"\",2,-1)+1)
				FileChangeDir(@ScriptDir)
			EndIf
			If $msg Then
				_SciGUI($log&" - FreeStyle Log",FileRead($log),-1)
				Sleep(5000)
			EndIf
		EndIf
	EndIf
	$msg=MsgBox(270404,"FreeStyle","All Files processed.        "&@LF&@LF&"Do you want to view the patched script(s) ?        ")
	If $msg=6 Then
		If $i>2 Then
			$log=StringMid($script[$i-1],StringInStr($script[$i-1],"\",2,-1)+1)
			$msg=FileOpenDialog(" Open au3 script file",StringReplace($script[$i-1],"\"&$log,""),"Autoit Source files (*.au3)",3,$log)
			FileChangeDir(@ScriptDir)
		EndIf
		If $msg Then
			_SciGUI($script[$i-1]&" - FreeStyle Log",FileRead($script[$i-1]),-1)
			Sleep(5000)
		EndIf
	EndIf
	$msg=MsgBox(270404,"FreeStyle","All Files processed.        "&@LF&@LF&"Do you want to run the patched script(s) ?        ")
	If $msg=6 Then
		If $i>2 Then
			$log=StringMid($script[$i-1],StringInStr($script[$i-1],"\",2,-1)+1)
			$msg=FileOpenDialog(" Open au3 script file",StringReplace($script[$i-1],"\"&$log,""),"Autoit Source files (*.au3)",3,$log)
			FileChangeDir(@ScriptDir)
		EndIf
		If $msg Then Run(@AutoItExe&" "&FileGetShortName($script[$i-1]))
	EndIf
	GUISetState(@SW_ENABLE,$m_GUI)
	GUICtrlSetState($apply,16)
EndFunc

Func _Sync($b,$a=0);klappt noch nicht wg. tabs ?  " \"&@crlf&@tab
	Dim $x1=$scitePath&"\au3.keywords.properties",$y1=$scitePath&"\au3.keywords.properties.old"
	$begin=TimerInit()
	If $b=1 Then
		If $a=0 Then $a=FileRead("FS_Library\FreeStyle.udfs.properties")
		If FileExists($x1) And FileExists($y1)=0 Then FileCopy($x1,$y1)
		If FileExists($x1)=0 Then Return
		$x=FileRead($x1)
		$y=StringSplit($x,"au3.keywords.udfs=",1)
		$y=StringSplit($y[2],@CRlf&"au3.",1)
		$t1=0
		$t2=0
		While 1
			$t2+=1
			Do
				$t1+=1
				$t=StringInStr($a," ",2,$t1)
				If $t=0 Then ExitLoop(2)
			Until $t>100*$t2
			$a=StringLeft($a,$t)&"\"&@CRLF&@TAB&StringMid($a,$t+1)
		WEnd
		$open=FileOpen($x1,2)
		FileWrite($open,StringReplace($x,$y[1],$a))
		FileClose($open)
		IniWrite($s_ini,"SciTE","Sync",1)
		MsgBox(0,"",TimerDiff($begin/1000))
		Return
	EndIf
;min 83 incl " " max 121 incl
EndFunc;bei neuer scite version muss old gelöscht werden
#EndRegion
#Region;---Array / Ini writing --------------------------------------------------
Func _Sort()
	GUISetState(@SW_DISABLE,$m_GUI)
	_SplashOn(1)
	Dim $k,$v,$p_array,$begin=TimerInit()
	_IniReadSection($d_ini,"Dir",$k,$d_array)
	_IniReadSection($d_ini,"Dir",$i_array,$v)
	_IniReadSection($c_ini,"Con",$c_array,$v)
	_IniReadSection($f_ini,"Fun",$f_array,$v)
	_IniReadSection($p_ini,"Par",$p_array,$v)
	$a=FileRead("FS_Library\FreeStyle.udfs.properties")
	For $i=1 To $p_array[0];oder neue kategorie
		If StringInStr(" "&$a," "&$p_array[$i]&" ")=0 Then $a&=StringLower($p_array[$i])&" "
	Next;constants zu specials oder macros in properties hier einlesen !
	$open=FileOpen("FS_Library\FreeStyle.udfs.properties",2)
	FileWrite($open,$a)	
	FileClose($open)
	If GUICtrlRead($o_Sync)=1 Then _Sync(1,$a)
	_IniToArray("Directories",$d_array,$d_str)
	_IniToArray("Includes",$i_array,$i_str)
	_IniToArray("Constants",$c_array,$c_str)
	_IniToArray("Functions",$f_array,$f_str)
	_lib_Update()
	SplashOff()
	GUISetState(@SW_ENABLE,$m_GUI)
	IniWrite($s_ini,"Update","Sort",Round(TimerDiff($begin)/1000))
EndFunc

Func _Scan($a)
	GUISetState(@SW_DISABLE,$m_GUI)
	_SplashOn(2)
	$begin=TimerInit()
	$t=1+(GUICtrlRead($g_delall)=1)
	$open_dir=FileOpen($d_ini,$t)
	$open_const=FileOpen($c_ini,$t)
	$incl_func=FileOpen($i_ini,$t)
	$open_func=FileOpen($f_ini,$t)
	$open_para=FileOpen($p_ini,$t)
	IniWrite($s_ini,"AutoIt","Alpha Version",$alphaVersion)
	IniWrite($s_ini,"AutoIt","Beta Version",$betaVersion)
	IniWrite($s_ini,"AutoIt","Alpha Path",$alphaPath)
	IniWrite($s_ini,"AutoIt","Beta Path",$betaPath)
	IniWrite($s_ini,"SciTE","Path",$scitePath)
	IniWrite($s_ini,"SciTE","Version",$sciteVersion)
	IniWrite($s_ini,"SciTE","Build",$sciteBuild)
	IniWrite($s_ini,"Update","Date",@YEAR&"-"&@MON&"-"&@MDAY)
	IniWrite($s_ini,"Update","Time",@HOUR&":"&@MIN&":"&@SEC)
	$instance=FileRead(@UserProfileDir&"\SciTEUser.properties")
	$z=StringInStr($instance,"check.if.already.open=");property:<key>=<value> Set a property to a value. 
	If $z>0 And StringMid($instance,$z-1,1)<>"#" Then; ControlCommand
		IniWrite($s_ini,"SciTE","Instance","check.if.already.open="&StringMid($instance,$z+22,1))
	Else
		$z=StringSplit($instance,"#Background",1)
		If $z[0]<>2 Then
			GUICtrlSetState($o_instance,128)
		Else
			IniWrite($s_ini,"SciTE","Instance","# FreeStyle Editor")
			If StringInStr($instance,"# FreeStyle Editor")=0 Then
				$instance=$z[1]&"# FreeStyle Editor"&@CRLF&"#Background"&$z[2]
				$fileopen=FileOpen(@UserProfileDir&"\SciTEUser.properties",2)
				FileWrite($fileopen,$instance)
				FileClose($fileopen)
			EndIf
		EndIf
	EndIf
	GUICtrlSetData($a_reg,"Library Version: "&$alphaVersion)
	GUICtrlSetData($b_reg,"Library Version: "&$betaVersion)
	GUICtrlSetData($a_path,"Installation Path: "&$alphaPath)
	GUICtrlSetData($b_path,"Beta Path: "&$betaPath)
	$ret=_FolderToIni($a)
	_MetaSearch()
	IniWrite($s_ini,"Update","Scan",Round(TimerDiff($begin)/1000))
	IniWrite($s_ini,"Data","MaxStrLen",$maxstrlen)
	FileClose($open_dir)
	FileClose($open_const)
	FileClose($incl_func)
	FileClose($open_func)
	FileClose($open_para)
	_Properties(FileExists($scitePath&"\Defs\beta\au3.keywords.properties"))
	_SplashOff()
	GUISetState(@SW_ENABLE,$m_GUI)
	GUICtrlSetState($general,16)
	Return $ret
EndFunc

Func _Properties($i=1);constants und funcs einlesen !
	;$i=read $o_beta ?
	If $i=0 Then $open=FileOpen($scitePath&"\Defs\Production\au3.keywords.properties",0);alpha
	If $i=1 Then $open=FileOpen($scitePath&"\Defs\beta\au3.keywords.properties",0);beta
	If $open=-1 Then
		MsgBox(270384,"Scite properties not found","Please install Scite if you want to use FreeStyle Editor")
		Return
	EndIf
	$a=FileRead($open)
	FileClose($open)
	$a=StringSplit($a,"au3.keywords.",1)
	For $i=2 To $a[0];8
		$b=StringSplit($a[$i],"=")
		$b[2]=StringReplace($b[2],"\","")
		$b[2]=StringReplace($b[2],@TAB,"")
		$b[2]=StringReplace($b[2],@CRLF,"")
		$open=FileOpen("FS_Library\FreeStyle."&$b[1]&".properties",10)
		FileWrite($open,$b[2])
		FileClose($open)
	Next
EndFunc

Func _Update()
	Dim $Case=GUICtrlRead($a_lower),$c_Double=GUICtrlRead($a_con),$f_Double=GUICtrlRead($a_func),$ret=_Scan($alphaPath&"\Include"),$ret1[3]
	GUICtrlSetState($g_delall,4)
	If GUICtrlRead($b_beta)=1 Then Dim $Case=GUICtrlRead($b_lower),$c_Double=GUICtrlRead($b_con),$f_Double=GUICtrlRead($b_func),$ret1=_Scan($betaPath&"\Include")
	_Sort()
	If GUICtrlRead($b_beta)=1 Then GUICtrlSetImage($b_icon,"shell32.dll",239,1)
	IniWrite($s_ini,"Settings","A Con",GUICtrlRead($a_con))
	IniWrite($s_ini,"Settings","B Con",GUICtrlRead($b_con))
	IniWrite($s_ini,"Settings","A Func",GUICtrlRead($a_func))
	IniWrite($s_ini,"Settings","B Func",GUICtrlRead($b_func))
	IniWrite($s_ini,"Settings","A Lower",GUICtrlRead($a_lower))
	IniWrite($s_ini,"Settings","B Lower",GUICtrlRead($b_lower))
	IniWrite($s_ini,"Settings","Beta",GUICtrlRead($b_beta))
	GUICtrlSetData($d_combo,"?"&$d_null&"?"&$d_str,$d_null)
	GUICtrlSetData($i_combo,"?"&$i_null&"?"&$i_str,$i_null)
	GUICtrlSetData($c_combo,"?"&$c_null&"?"&$c_str,$c_null)
	GUICtrlSetData($f_combo,"?"&$f_null&"?"&$f_str,$f_null)
	GUICtrlSetState($general,16)
	_Report($ret[2]+$ret1[2],$ret[0]+$ret1[0],$ret[1]+$ret1[1])
EndFunc

Func _lib_Update()
	If StringInStr($i_str&$c_str&$f_str,"°") Then GUICtrlSetState($copy,32)
	GUICtrlSetData($ges_dir,"Total scanned Directories: "&$d_array[0])
	GUICtrlSetData($ges_incl,"Total registered Include files: "&$i_array[0])
	GUICtrlSetData($ges_const,"Total registered Global Constants: "&$c_array[0])
	GUICtrlSetData($ges_func,"Total registered Functions: "&$f_array[0])
EndFunc

Func _Add_Dir($x)
	Dim $Case=GUICtrlRead($d_lower),$c_Double=GUICtrlRead($d_con),$f_Double=GUICtrlRead($d_func)
	_SplashOn()
	$ret=_FolderToIni($x)
	If $ret[2]*($ret[0]+$ret[1])=0 Then
		MsgBox(262192,$x,"The chosen folder does not contain relevant data.       ")
		WinActivate($m_GUI)
		_SplashOff()
		Return
	EndIf
	_MetaSearch()
	_Sort()
	GUICtrlSetData($d_combo,$x,$x)
	_d_Combo()
	_Report($ret[2],$ret[0],$ret[1])
EndFunc

Func _Add_File($x)
	Dim $Case=GUICtrlRead($i_lower),$c_Double=GUICtrlRead($i_con),$f_Double=GUICtrlRead($i_func)
	_SplashOn()
	If StringInStr($x,"|") Then
		$a=StringSplit($x,"|")
		Dim $t1=0,$t2=0,$y=$a[0]-1,$b=$a[1]
		For $i=2 To $a[0]
			$ret=_FileToIni($a[1],$a[$i])
			If $ret[0]+$ret[1]=0 Then $y-=1
			$t1+=$ret[0]
			$t2+=$ret[1]
		Next
		$a=$a[2]
	Else
		Dim $y=1,$a=StringMid($x,StringInStr($x,"\",2,-1)+1)
		$b=StringReplace($x,"\"&$a,"")
		$ret=_FileToIni($b,$a)
		$t1=$ret[0]
		$t2=$ret[1]
	;	$a=$a[$a[0]]
	EndIf
	If $t1=0 And $t2=0 Then
		_SplashOff()
		Return
	EndIf
	_MetaSearch()
	_Sort()
	GUICtrlSetData($d_combo,$b,$b);hier fehlt noch einmal ordnen
	GUICtrlSetData($i_combo,$a,$a)
	_i_Combo()
	_Report($y,$t1,$t2)
EndFunc

Func _FolderToIni($a);recursion ?
	Dim $ret1[3]=[0,0,0]
	$search=FileFindFirstFile($a&"\*.au3")
	If @error=0 Then
		While 1
			$file=FileFindNextFile($search)
			If @error=1 Then ExitLoop
			$ret=_FileToIni($a,$file)
			If $ret[0]+$ret[1]>0 Then $ret1[2]+=1
			$ret1[0]+=$ret[0]
			$ret1[1]+=$ret[1]
		WEnd
		FileClose($search);3510
	EndIf
	Return $ret1
EndFunc

Func _FileToIni($a,$b)
	Dim $ret2[2],$app=""
	$include=FileOpen($a&"\"&$b,0)	;wenn nicht existiert?
;bei duplicates
;	While IniRead($d_ini,"Dir",$b&$app,"") And StringInStr("?"&$d_str&"?","?"&$a&"?")=0
;		$app&="°";doppelte betas => au3° berücksichtigen !!!
;	WEnd;stimmt nicht, wird auch schon bei alphas verdoppelt nur wenn pfad anders
	While 1
		$x=""
		While 1
			$line=FileReadLine($include)
			If @error=-1 Then ExitLoop(2);@error=1 ?
			If StringInStr($line,"#cs") Then
				Do
					$line=FileReadLine($include)
					If @error=-1 Then ExitLoop(3)
				Until StringInStr($line,"#ce")
			EndIf	;		If StringLeft(StringStripWS($line,8),11)="GlobalConst" And (StringInStr(StringStripWS($line,8),'="') Or StringInStr(StringStripWS($line,8),"='")) And (StringInStr($line,";") Or StringInStr($line," ")) Then
			For $i=34 To 39 Step 5;paulia's long dll structs
				If StringInStr($line,Chr($i))=0 Then ContinueLoop
				$t1=StringSplit($line,Chr($i))
				If $t1[0]=2 Then ContinueLoop
				For $j=2 To $t1[0] Step 2
					If StringInStr($t1[$j],";")=0 And StringInStr($t1[$j]," ")=0 Then ContinueLoop
					$t2=StringReplace(StringReplace($t1[$j],";","§")," ","#")
					$line=StringReplace($line,Chr($i)&$t1[$j]&Chr($i),Chr($i)&$t2&Chr($i))
				Next
			Next
			$line=StringSplit($line,";")
			$line=StringStripWS($line[1],8)
			$x&=$line
			If StringRight($line,1)<>"_" Then ExitLoop
			$x=StringTrimRight($x,1);2
		WEnd
		If StringLeft($x,11)="GlobalConst" Then	$ret2[0]+=_ConstToIni(StringMid(StringReplace(StringReplace($x,"[","´"),"]","`"),12),$a,$b,$app)
		If StringLeft($x,10)="GlobalEnum" Then $ret2[0]+=_EnumToIni(StringMid($x,11),$a,$b,$app)
		If StringLeft($x,4)="Func" Then $ret2[1]+=_FuncToIni(StringMid($x,5),$a,$b,$app);StringReplace(StringReplace($x,"[","´"),"]","`"); keine func mit [] gefunden !!!
	WEnd;		==> _ArrayToIni() ==> duplicates ?
	FileClose($include)
	If $ret2[0]+$ret2[1]=0 Then
		$Skipped&=$a&"\"&$b&@CRLF;nicht immer !!!!
	Else
		IniWrite($d_ini,"Dir",$b&$app,$a);doppelte betas => au3° berücksichtigen !!!
	EndIf
	Return $ret2
EndFunc
; duplicates: funzt bei func, nicht bei const !
Func _ConstToIni($a,$p1,$p2,$app)
	Dim $b[2]=[1,$a],$ret=0
	If StringInStr($a,"=",1,2)>0 Then $b=StringSplit($a,",")
	For $j=1 To $b[0]
		$a=StringSplit($b[$j],"=")
		If $a[0]=1 Then ContinueLoop;return ?
		$a[2]=StringReplace(StringReplace(StringReplace(StringReplace($a[2],"'","~"),'"',"~"),"§",";"),"#"," ")
		If StringInStr($a[2],"$")=0 And StringInStr($a[2],"~")=0 Then
			If StringLeft($a[2],2)="0x" And $a[2]<0 Then $a[2]=_HexToDec(StringMid($a[2],3))
			$a[2]=Execute($a[2]);hex muss nicht am anfang stehen !
		EndIf
		If $Case=4 And _Case(StringReplace(StringReplace(StringReplace(StringReplace(StringReplace($a[1],"`",""),"´",""),"$",""),"_",""),"°","")) Then ContinueLoop
		If $c_Double<>2 Then
			$t=StringReplace(StringReplace(IniRead($c_ini,"Con",$a[1],.5),"´","["),"`","]")
			If $t<>.5 Then; noch mal d_add und i_add und drop ändern !
				If $c_Double=1 Then ContinueLoop
				If $t<>$a[2] Then
					Do
						$a[1]&="°";con bedingung ?
						$t=StringReplace(IniRead($i_ini,"Inc",$a[1],""),"°","")
					Until $t="" Or $t=$p1&"\"&$p2;$t muss ° replaced werden?
					If $t Then ContinueLoop;patching nur, wenn duplis auf ignorelist
				EndIf; ° bei patching, view function, clip und combotooltip berücksichtigen !!!!!
			EndIf
		EndIf
		If StringLen($a[2])>$maxstrlen Then $maxstrlen=StringLen($a[2])
		IniWrite($i_ini,"Inc",$a[1],$p1&"\"&$p2&$app)
		IniWrite($c_ini,"Con",$a[1],$a[2])
		$ret+=1
	Next
	Return $ret;$b[0]
EndFunc

Func _EnumToIni($a,$p1,$p2,$app)
	Dim $t=StringSplit($a,","),$off=0,$opera=0,$step=1
	If StringLeft($t[1],4)="Step" Then
		Dim $y=StringSplit(StringMid($t[1],5),"$"),$step=$y[1]
		If StringLeft($y[1],1)="*" Then Dim $off=1,$opera=1,$step=StringMid($y[1],2)
		$t[1]="$"&$y[2]
	EndIf
	For $i=1 To $t[0]
		Dim $y=StringSplit($t[$i],"="),$xt=0
		If $y[0]>1 Then $off=$y[2]
; 	==>	duplicates handling
		If $c_Double<>2 Then
			$x=StringReplace(IniRead($i_ini,"Inc",$y[1],""),"°","")
			If $x Then;was ist mit der con bedingung ?
				If $c_Double=1 Or $x=$p1&"\"&$p2 Then
					$xt=1
				Else
					If IniRead($c_ini,"Con",$y[1],.5)<>$off Or $c_Double=4 Then
						Do
							$y[1]&="°"
							$x=StringReplace(IniRead($i_ini,"Inc",$y[1],""),"°","")
						Until $x="" Or $x=$p1&"\"&$p2
						If $x Then $xt=1
					EndIf
				EndIf
			EndIf
		EndIf
		If $xt=0 And $Case=4 Then $xt=_Case($y[1])
		If $xt=0 Then
			IniWrite($c_ini,"Con",$y[1],$off)
			IniWrite($i_ini,"Inc",$y[1],$p1&"\"&$p2&$app)
		EndIf
		If $opera=0 Then $off+=$step
		If $opera=1 Then $off*=$step
	Next
	Return $t[0]	
EndFunc

Func _FuncToIni($a,$p1,$p2,$app);bei f überprüfen, ob txt geändert
	$a=StringReplace($a,"=","\")
; 	==>	duplicates handling
	If $f_Double<>2 Then
;		$t=IniRead($f_ini,"Fun",$a,"")
		$t=IniRead($p_ini,"Par",StringLeft($a,StringInStr($a,"(",2)-1),"")
		If $t Then;was ist mit der con bedingung ?
			If $f_Double=1 Or $t=$p1&"\"&$p2 Then Return
			Do
				$a&="°"
				$t=StringReplace(IniRead($i_ini,"Inc",$a,""),"°","")
			Until $t="" Or $t=$p1&"\"&$p2
			If $t Then Return
		EndIf
	EndIf
	If StringLen($a)>$maxstrlen Then $maxstrlen=StringLen($a)
;	problem: par kann überschrieben werden, fun nicht, oder ????
	IniWrite($p_ini,"Par",StringLeft($a,StringInStr($a,"(",2)-1),$p1&"\"&$p2&$app)
	IniWrite($f_ini,"Fun",$a,$p1&"\"&$p2&$app)
	Return 1
EndFunc

Func _Case($t)
	$i=-1
	While StringIsUpper($t)=0
		$i+=1
		If $i=10 Then Return 1
		$t=StringReplace($t,String($i),"")
	WEnd
EndFunc

Func _MetaSearch()
	Dim $k,$v
	For $h=0 To 1
		_IniReadSection($c_ini,"Con",$k,$v)
		For $j=1 To $k[0]
			If StringInStr($v[$j],"&")=0 And StringInStr($v[$j],"$")=0 Or StringInStr($v[$j],"$\") Then ContinueLoop
			$b=StringSplit($v[$j],"$")
			For $i=2 To $b[0]
				$t=StringSplit($b[$i],"&*+-,")
				$t=StringReplace($t[1],")","")
				$t1="$"&$t
				$t2=IniRead($c_ini,"Con",$t1,"")
				If $t2="" Then
					MsgBox(0,$k[0],$t1)
					_Error($c_ini,"Con",$t1)
				EndIf
				$v[$j]=StringReplace($v[$j],$t1,$t2)
			Next
			If StringInStr($v[$j],"$")=0 And StringInStr($v[$j],"~")=0 Then
				If StringLeft($v[$j],2)="0x" And $v[$j]<0 Then $v[$j]=_HexToDec(StringMid($v[$j],3))
				$v[$j]=Execute($v[$j]);hex muss nicht am anfang stehen !
			EndIf
			$v[$j]=StringReplace(StringReplace(StringReplace($v[$j],"~&~",""),"~&",""),"&~","")
			If StringLen($v[$j])>$maxstrlen Then $maxstrlen=StringLen($v[$j])
			IniWrite($c_ini,"Con",$k[$j],$v[$j])	
		Next
	Next	
EndFunc

Func _IniToArray($b,ByRef $a,ByRef $x)
	$x=1
	If $a[0]>1 And $b<>"Directories" Then _ArraySort($a,$x,$a[0])
	$x=""
	For $i=1 To $a[0]
		If $b="Directories" And StringInStr($x,$a[$i]) Then ContinueLoop
		$x&="?"&$a[$i]
	Next
	$x=StringMid($x,2)
	If $b="Functions" Then $x=StringReplace($x,"\","=")
	If $b="Includes" Or $b="Constants" Then $x=StringReplace(StringReplace($x,"´","["),"`","]")
	_WriteFile($b,$x)
	If $b="Directories" Then $a=StringSplit($x,"?")
EndFunc

Func _WriteFile($b,$x)
	IniWrite($s_ini,"Data",$b,StringLen($x))
	$open=FileOpen("FS_Library\"&$b&".txt",2)
	FileWrite($open,$x)
	FileClose($open)
EndFunc
#EndRegion
#Region;---appendix--------------------------------------------------------------
Func _lex_GDIPlus($ref)
	If StringRight($ref,12)="\GDIPlus.au3" Or StringRight($ref,15)="\A3LGDIPlus.au3" Then Return 1
EndFunc

Func _lex_IE($ref)
	If StringRight($ref,7)="\IE.au3" Then Return 1
EndFunc
	
Func _lex_Word($ref)
	If StringRight($ref,9)="\Word.au3" Then Return 1
EndFunc

Func _Report($t1,$t2,$t3); timestamp noch nicht gut
	_Log($FSLog,"------ Update: "&GUICtrlRead($a_lower)&GUICtrlRead($a_func)&GUICtrlRead($b_beta)&GUICtrlRead($b_lower)&GUICtrlRead($b_func)&" ------")
	$x="Added "&$t1&" Include File(s) to Library.        "&@LF&"Added "&$t2&" Global Constant(s) to Library.        "&@LF&"Added "&$t3&" Function(s) to Library."
	_Log($FSLog,$x)
	MsgBox(270384,"Done",$x&@LF&@LF&"Please check the additions.")
	If $Skipped="" Then Return
	_Log($FSLog,"Skipped:"&@CRLF&$Skipped)
	MsgBox(270400,"The following files have been omitted:","(This report has been saved to FreeStyle.log.)"&@LF&@LF&$Skipped&@LF&"Either because the files did not contain relevant data.        "&@LF&@LF&"Or because an identical file has been registered before.        "&@LF&@LF&"Or because they only contain duplicate information.        "&@LF&"In the latter cases you may check the Duplicates Settings.            ")
	$Skipped=""
	;=> history listiew
EndFunc

Func _ArraySort(ByRef $array,ByRef $left,ByRef $right)
	If $right-$left<15 Then
		For $i=$left+1 To $right
			Dim $t=$array[$i],$j=$i
			While $j>$left And $array[$j-1]>$t
				$array[$j]=$array[$j-1]
				$j-=1
			WEnd
			$array[$j]=$t
		Next
		Return
	EndIf
	Dim $mid=$array[Int(($left+$right)/2)],$L=$left,$R=$right
	Do
		While $array[$L]<$mid
			$L+=1
		WEnd
		While $array[$R]>$mid
			$R-=1
		WEnd
		If $L<=$R Then
			$t=$array[$L]
			$array[$L]=$array[$R]
			$array[$R]=$t
			$L+=1
			$R-=1
		EndIf
	Until $L>$R
	_ArraySort($array,$left,$R)
	_ArraySort($array,$L,$right)
EndFunc

Func _Changelog()
	$changelog='08-07-08 v 9.0 First release Beta Version - Downloads: 48'&@CRLF
	$changelog&='09-07-08 v 9.1 - Downloads: 4'&@CRLF
	$changelog&=@TAB&'Fixed Bug: Difference in linecounts between "Parameters.ini" and "Functions.ini" causing wrong references.'&@CRLF
	$changelog&=@TAB&'Fixed Bug: Bad checkbox style a_lower & b_lower.'&@CRLF
	$changelog&=@TAB&'Fixed Bug: Commented out Duplicate mark relic "°".'&@CRLF
	$changelog&=@TAB&'Fixed Bug: Footnote "°=Duplicate".'&@CRLF
	$changelog&=@TAB&'Fixed Syntax Bugs (1).'&@CRLF
	$changelog&=@TAB&'Fixed Issue: _SciGui Height.'&@CRLF
	$changelog&=@TAB&'Added feature "Lex GDIPlus": Special GDIPlus.au3 / A3LGDIPlus.au3 variables will be added.'&@CRLF
	$changelog&=@TAB&'Added feature: FreeStyle Version will be checked / Changelog.txt added.'&@CRLF
	$changelog&=@TAB&'Added feature: All Settings can be saved now.'&@CRLF
	$changelog&=@TAB&'Added feature: "Example View" in Functions Group.'&@CRLF
	$changelog&=@TAB&'Added feature: "Run Example" in Functions Group.'&@CRLF
	$changelog&=@TAB&'N.B.: Examples are taken from the "Examples\Helpfile" Directory. Lots of them are NOT working ! NOT my fault !'&@CRLF
	$changelog&='09-07-08 v 9.2 - Downloads: 32'&@CRLF
	$changelog&=@TAB&'Fixed bug: Using Registry Key instead of "@AutoItVersion".'&@CRLF
	$changelog&=@TAB&'Fixed bug: Adding multiple Include files.'&@CRLF
	$changelog&=@TAB&'Added feature: "View Helpfile" in Functions Group.'&@CRLF
	$changelog&='12-07-08 v 9.3'&@CRLF
	$changelog&=@TAB&'Fixed bug: Using FileGetVersion() instead of "@AutoItVersion".'&@CRLF
	$changelog&=@TAB&'Fixed bug: Improved distinction of functions names with trailing double or triple strings (e.g. "_IEErrorNotify" and "__IEErrorNotify") on patching.'&@CRLF
	$changelog&=@TAB&'Fixed Syntax Bugs (3).'&@CRLF
	$changelog&=@TAB&'Changed: Patch log.'&@CRLF
	$changelog&=@TAB&'Added feature "Lex IE": Special IE.au3 variables will be added.'&@CRLF
	$changelog&=@TAB&'Added feature "Lex Word": Special Word.au3 variables will be added.'&@CRLF
	$changelog&=@TAB&'Added feature: Proper Array Constants Patching, e.g. <$IEAU3VersionInfo[6]=["V",2,3,1,"20070813","V2.3-1"]>.'&@CRLF
	$changelog&=@TAB&'Added feature: Separate Duplicates handling for Constants and Functions.'&@CRLF
	$changelog&=@TAB&'Added feature: Delete Duplicates and Non-uppercase Constants on Update.'&@CRLF
	$changelog&=@TAB&'Added feature: Search for Keyword in AutoIt Forum. In order to avoid fatal errors search will be processed outside of script.'&@CRLF
	$changelog&=@TAB&'Added feature: Advanced Forum Search: Option for Member Search and Subforum Search added.'&@CRLF
	IniWrite($s_ini,"Update","Version",$FS_version)
	$chlog=FileOpen("FS_Library\Changelog.txt",2)
	FileWrite($chlog,$changelog)
	FileClose($chlog)
EndFunc

Func _Engine()
	$txt=';'&$FS_version&@CRLF
	$txt&='Opt("TrayAutoPause",0)'&@CRLF&'TraySetIcon("shell32.dll",14)'&@CRLF&'$ini=@ScriptDir&"\FS_Search_Engine.ini"'&@CRLF&'$oIE=ObjCreate("InternetExplorer.Application")'&@CRLF&'$oIE.visible=0'&@CRLF&'$oIE.navigate("http://www.autoitscript.com/forum/index.php?act=Search")'&@CRLF
	$txt&='Do'&@CRLF&'	Sleep(20)'&@CRLF&'Until String($oIE.readyState)="complete" Or $oIE.readyState=4'&@CRLF
	$txt&='Do'&@CRLF&'	Sleep(20)'&@CRLF&'Until String($oIE.document.readyState)="complete" Or $oIE.document.readyState=4'&@CRLF&'$oForm=$oIE.document.forms.item("sForm",0)'&@CRLF&'$oText=$oForm.elements.item("keywords",0)'&@CRLF
	$txt&='Do'&@CRLF&'	Sleep(20)'&@CRLF&'	$Keyword=IniRead($ini,"Search","Keyword","")'&@CRLF&'Until $Keyword'&@CRLF&'FileDelete($ini)'&@CRLF&'$Keyword=StringSplit($Keyword,"§")'&@CRLF&'$oText.value=$Keyword[1]'&@CRLF
	$txt&='If $Keyword[0]>1 Then'&@CRLF&'	$oMember=$oForm.elements.item("namesearch")'&@CRLF&'	If Number(StringStripWS($Keyword[2],8)) Then'&@CRLF&'		$oSub=$oForm.elements.item("forums[]")'&@CRLF&'		$oSub.value=StringStripWS($Keyword[2],8)'&@CRLF
	$txt&='	Else'&@CRLF&'		$oMember.value=$Keyword[2]'&@CRLF&'	EndIf'&@CRLF&'	If $Keyword[0]>2 Then $oMember.value=$Keyword[3]'&@CRLF&'EndIf'&@CRLF&'$oWin=$oForm.document.parentWindow'&@CRLF&'$oForm.submit'&@CRLF
	$txt&='Do'&@CRLF&'	Sleep(100)'&@CRLF&'Until String($oWin.document.readyState)="complete" Or $oWin.document.readyState=4'&@CRLF
	$txt&='Do'&@CRLF&'	Sleep(100)'&@CRLF&'Until String($oWin.top.document.readyState)="complete" Or $oWin.top.document.readyState=4'&@CRLF&'$oIE.visible=1'&@CRLF
	$txt&='Do'&@CRLF&'	Sleep(100)'&@CRLF&'	$text=$oIE.document.body.innerHTML'&@CRLF&'	If StringInStr($text,"The error returned was:") Or StringInStr($text,"Unfortunately your search didn") Or StringInStr($text,"res://shdoclc.dll/pagerror.gif") Then Exit'&@CRLF&'Until StringInStr($text,"Your topics")'&@CRLF
	$txt&='$msg=MsgBox(262148,"FreeStyle Search Engine","Do you want to save the search result for "&Chr(34)&$Keyword[1]&Chr(34)&" ?")'&@CRLF&'If $msg=7 Then Exit'&@CRLF
	$txt&='$url=$oIE.locationURL'&@CRLF&'FileCreateShortcut($url,@ScriptDir&"\Search Results for "&$Keyword[1]&".lnk","","","Free Style Search Engine - AutoIt Forum Search Result for "&Chr(34)&$Keyword[1]&Chr(34)&".lnk")'
	$open=FileOpen($FS_Engine,10)
	FileWrite($open,$txt)
	FileClose($open)
EndFunc

Func _Log($lgf,$txt)
	FileWriteLine($lgf,@MDAY&"."&@MON&"."&@YEAR&" - "&@HOUR&":"&@MIN&":"&@SEC&" "&$txt)
EndFunc

Func _SplashOn($z=0)
	$pos=WinGetPos($m_GUI)
	If $z=0 Then SplashTextOn("Splash",@LF&"Please stand by ...",200,60,$pos[0]+$pos[2]/2-101,$pos[1]+$pos[3]/2-30,17)
	If $z=1 Then SplashTextOn("Splash","Please be patient."&@LF&@LF&"Sorting arrays ..."&@LF&"Populating Combos ..."&@LF&@LF&"Approximately "&IniRead($s_ini,"Update","Sort",10)&" sec.",200,123,$pos[0]+$pos[2]/2-101,$pos[1]+$pos[3]/2-61.5,17)
	If $z=2 Then SplashTextOn("Splash","Please be patient."&@LF&@LF&"Building Libraries ..."&@LF&"Registering Constants ..."&@LF&"Registering Enums ..."&@LF&"Registering Functions ..."&@LF&@LF&"Approximately "&IniRead($s_ini,"Update","Scan",30)&" sec.",200,163,$pos[0]+$pos[2]/2-101,$pos[1]+$pos[3]/2-81.5,17)
EndFunc

Func _SplashOff()
	$msg=""
	SplashOff()
	GUICtrlSetState($i_group,16)	
	GUICtrlSetState($f_group,16)
	WinActivate($m_GUI)	
EndFunc

Func _Tooltip()
	ToolTip("")
	If $s_GUI Then GUICtrlSetState($s_link,128)
	AdlibDisable()
EndFunc

Func _Error($x="",$y="",$z="")
	$msg=MsgBox(270356+31*($x<>""),"Library Corruption Error !",@LF&"A database error occured"&@lf&"in "&$x&".         "&@LF&"Key: "&$y&".        "&@LF&@LF&"FreeStyle will be reset."&@LF&"All libraries will be deleted."&@LF&"Please restart Freetyle."&@LF&@LF&"              Continue ?"&@LF&@LF&"Choose No to just delete the Key.                 "&@LF&"Choose Cancel to ignore this Error.                 ")
	If $msg=7 Then IniDelete($x,$z,$y);no
	If $msg=6 Then DirRemove("Library",1);yes
	Exit;2=cancel
EndFunc

Func _Exit()
	$igopen=FileOpen($igntxt,2)
	If GUICtrlRead($o_save)=1 Then
		FileWrite($igopen,$ignorelist)
	Else
		IniDelete($s_ini,"Settings")
		IniWrite($s_ini,"Settings","Save",4)
	EndIf
	FileClose($igopen)
	FileClose($FSLog)
	DllClose($user32)
	DllClose($kernel32)
	Exit
EndFunc
#EndRegion
#Region;---scitegui--------------------------------------------------------------
Func _GetText()
	$a=_SendMessage(2182,0,0)
	$b=DllStructCreate("byte["&$a&"]")
	DllCall($user32,"long","SendMessageA","long",$Sci,"int",2182,"int",$a,"ptr",DllStructGetPtr($b))
	Return BinaryToString(DllStructGetData($b,1))
EndFunc

Func _SciTe($b);	indizieren !
	If $b=0 And GUICtrlRead($o_SciTE)=1 Then
;Or, run the command "start" which will automatically work out how to execute the file for you:    RunWait(@COMSPEC & " /c Start myfile.msi")
;Or, use the ShellExecuteWait function which will automatically work out how to execute the file for you:    ShellExecuteWait("myfile.msi")
		;vorher instance
		Run($scitePath&"SciTE.exe "&GUICtrlRead($d_combo)&"\"&StringReplace(GUICtrlRead($i_combo),"°",""))
		Return
	EndIf
;	$a=IniRead($f_ini,"Fun",StringReplace(GUICtrlRead($f_combo),"=","\"),"")
	$a=GUICtrlRead($d_combo)&"\"&StringReplace(GUICtrlRead($i_combo),"°","")
	$content=FileRead($a)
	If $b=1 Then $content=_f_Copy($content,GUICtrlRead($f_combo),GUICtrlRead($f_comment),$b)
	_SciGUI($a,$content,$b)
EndFunc

Func _SciGUI($title,$txt,$b)
	If $b=-1 Then
		$b=StringSplit($txt,@CRLF,1)
		$b=$b[0]
	EndIf
	If 17*$b>@DesktopHeight-$border Then $b=0
	If $b>0 And 17*$b<119 Then $b=7
	;jetzt indexen und verwalten !
	If $s_GUI Then _sciExit();
	$s_GUI=GUICreate(" "&$title&" - FreeStyle Editor",660,(@DesktopHeight-$border-30)*($b=0)+17*$b-2,200*($b>0)+1,50*($b>0)+1);nächste einrücken
	GUISetIcon("shell32.dll",239)
	DllCall($kernel32,"int","LoadLibrary","str","SciLexer.DLL")
	$Sci=_CreateWindowEx(2,2,618,(@DesktopHeight-$border-35)*($b=0)+17*$b-2*($b>0)-2)
		_SendMessage(4001,60,0)
		_SendMessage(2090,_SendMessage(4011,0,0),0)
		_SendMessage(2036,4,0)
		_SendMessage(2132,True,0)
		_SendMessage(2373,-1,0)
		_SendMessageString(4005,0,FileRead("FS_Library\FreeStyle.keywords.properties"))
		_SendMessageString(4005,1,FileRead("FS_Library\FreeStyle.functions.properties"))
		_SendMessageString(4005,2,FileRead("FS_Library\FreeStyle.macros.properties"))
		_SendMessageString(4005,3,FileRead("FS_Library\FreeStyle.sendkeys.properties"))
		_SendMessageString(4005,4,FileRead("FS_Library\FreeStyle.preprocessor.properties"))
		_SendMessageString(4005,5,FileRead("FS_Library\FreeStyle.special.properties"))
		;_SendMessageString(4005,6,"")					;constants rein
		_SendMessageString(4005,7,FileRead("FS_Library\FreeStyle.udfs.properties"))
		_SendMessage(2240,0,1)
		_SendMessage(2242,0,_SendMessageString(2276,33,"_99999"))
		_SendMessage(2242,1,16)
		_SendMessage(2106,Asc(@CR),0)
		_SendMessage(2115,True,0)						;	eigene farbe
		_SetStyle(32,0x000000,0xFFFFFF,10,"Courier New");$STYLE_DEFAULT
		_SendMessage(2050,0,0)							;$SCI_STYLECLEARALL
		_SetStyle(35,0x009966,0xFFFFFF,0,"",0,1)		;$STYLE_BRACEBAD
		_SetStyle(0,0x000000,0xFFFFFF)					;$SCE_AU3_DEFAULT
		_SetStyle(1,0x339900,0xFFFFFF)					;$SCE_AU3_COMMENT
		_SetStyle(2,0x009966,0xFFFFFF)					;$SCE_AU3_COMMENTBLOCK
		_SetStyle(3,0xA900AC,0xFFFFFF,0,"",1)			;$SCE_AU3_NUMBER
		_SetStyle(4,0xAA0000,0xFFFFFF,0,"",1,1)		;1	;$SCE_AU3_FUNCTION
		_SetStyle(5,0xFF0000,0xFFFFFF,0,"",1)		;0	;$SCE_AU3_KEYWORD
		_SetStyle(6,0xFF33FF,0xFFFFFF,0,"",1)		;2	;$SCE_AU3_MACRO
		_SetStyle(7,0xCC9999,0xFFFFFF,0,"",1)			;$SCE_AU3_STRING
		_SetStyle(8,0x0000FF,0xFFFFFF,0,"",1)			;$SCE_AU3_OPERATOR
		_SetStyle(9,0x000090,0xFFFFFF,0,"",1)			;$SCE_AU3_VARIABLE
		_SetStyle(10,0x0080FF,0xFFFFFF,0,"",1)		;3	;$SCE_AU3_SENT
		_SetStyle(11,0xFF00F0,0xFFFFFF,0,"",0,0)	;4	;$SCE_AU3_PREPROCESSOR
		_SetStyle(12,0xF00FA0,0xFFFFFF,0,"",0,1)	;5	;$SCE_AU3_SPECIAL
		_SetStyle(13,0x0000FF,0xFFFFFF,0,"",1)			;$SCE_AU3_EXPAND
		_SetStyle(14,0xFF0000,0xFFFFFF,0,"",1,1)		;$SCE_AU3_COMOBJ
		_SetStyle(15,0xFF8000,0xFFFFFF,0,"",1,1)	;7	;$SCE_AU3_UDF
		_SetProperty("fold")
		_SetProperty("fold.compact")
		_SetProperty("fold.comment")
		_SetProperty("fold.preprocessor")
		_SendMessage(2242,2,0)
		_SendMessage(2240,2,0)
		_SendMessage(2244,2,0xFE000000)
		_SendMessage(2242,2,20)
		_SendMessage(2040,30,2)
		_SendMessage(2040,31,6)
		_SendMessage(2040,25,2)
		_SendMessage(2040,27,11)
		_SendMessage(2040,26,6)
		_SendMessage(2040,29,9)
		_SendMessage(2040,28,10)
		_SendMessage(2233,16,0)
		_SendMessage(2041,30,0xFFFFFF)
		_SendMessage(2042,29,0x808080)
		_SendMessage(2042,25,0x808080)
		_SendMessage(2041,25,0xFFFFFF)
		_SendMessage(2042,28,0x808080)
		_SendMessage(2042,27,0x808080)
		_SendMessage(2042,30,0x808080)
		_SendMessage(2041,31,0xFFFFFF)
		_SendMessage(2042,31,0x808080)
		_SendMessage(2041,26,0xFFFFFF)
		_SendMessage(2042,26,0x808080)
		_SendMessage(2246,2,1)
		_SendMessage(2042,0,0x0000FF)
	Global $s_link=GUICtrlCreateIcon("shell32.dll",290,625,5,32,32)
		GUICtrlSetTip(-1,"Browse Function");@DesktopHeight-$border-106
		GUICtrlSetState(-1,128)
		GUICtrlSetCursor(-1,0)
	Global $s_save=GUICtrlCreateIcon("shell32.dll",45,625,42,32,32)
		GUICtrlSetTip(-1,"Save Changes");@DesktopHeight-$border-69
		GUICtrlSetCursor(-1,0);vorher backup erstellen ?
	;zurückbutton
		;tooltip bei hex und dec ! noch ein button oder click
		;rechnungen ausführen ! noch ein button
		;const austauschen ! noch ein button
		;vor zurück home
		;browse file + func
	Global $s_exit=GUICtrlCreateIcon("shell32.dll",28,625,79,32,32)
		GUICtrlSetTip(-1,"Exit");@DesktopHeight-$border-32
		GUICtrlSetCursor(-1,0)
	GUIRegisterMsg(78,"_WM_NOTIFY")
	$old=_SendMessage(2166,_SendMessage(2008,0,0),0)+1
	_SendMessage(2024,-1,0)
	$a=StringSplit($txt,"")
	DllCall($user32,"long","SendMessageA","long",$Sci,"int",2001,"int",$a[0],"str",$txt)
	_SendMessage(2024,$old-1,0)
	GUISetState(@SW_SHOW,$s_GUI)
EndFunc

Func _CreateWindowEx($X=0,$Y=0,$nWidth=0,$nHeight=0);geht oben nicht !?
	$ret=DllCall($user32,"long","GetWindowLong","hwnd",$s_GUI,"int",-6)
	$ret=DllCall($user32,"hwnd","CreateWindowEx","long",512,"str","Scintilla","str","SciLexer","long",1378942976,"int",$X,"int",$Y,"int",$nWidth,"int",$nHeight,"hwnd",$s_GUI,"hwnd",0,"long",$ret[0],"ptr",0)
	Return $ret[0]
EndFunc

Func _GetWord(); hier gibts falsche ergebnisse !! zb func oder return
	_Tooltip()
	Dim $Pos=_SendMessage(2008,0,0),$ret=Chr(_SendMessage(2007,$Pos,0))
	If $ret="" Or $ret=@TAB Or $ret=@LF Or $ret=@CR Then Return ""
	For $j=-1 To 1 Step 2
		$i=1
		While 1
			Dim $Get=_SendMessage(2007,$Pos+$i*$j,0),$Char=Chr($Get)
			If $Get="" Or StringInStr(" &,+-*/(){^][<=>{'",$Char) Or $Char='"' Or $Char=@TAB Or $Char=@LF Or $Char=@CR Then ExitLoop
			If $j=-1 Then $ret=$Char&$ret
			If $j=1 Then $ret&=$Char
			$i+=1
		WEnd
	Next; dieses wird auch zum copy pasten gebraucht !
	If StringLeft($ret,1)="$" Then;	const
		$a=StringInStr("?"&$c_str,"?"&$ret)
		If $a Then;test a3lgdiplus.au3 : ~ satatt "  	ie3.au3 : kein popup bei []
			Dim $a=StringReplace(StringReplace($ret,"[","´"),"]","`"),$t=IniRead($i_ini,"Inc",$a,""),$x=StringReplace(StringReplace(IniRead($c_ini,"Con",$a,""),"´","["),"`","]")
			If $x Then _PopUp($t,$ret&" = "&$x&"  ( 0x"&_DecToHex($x)&" )")
		EndIf;						strrepl(~,") wenn str,dann nicht hex !
	Else	;If $Char="(" Then;	func oder(,)
		$a=StringInStr("?"&$f_str,"?"&$ret); hier gibts falsche ergebnisse !! zb func oder return
		If $a Then
			$t=IniRead($p_ini,"Par",$ret,"");text
			For $i=1 To $f_array[0]
				If StringInStr($f_array[$i],$ret) Then ExitLoop
			Next
			If $i<=$f_array[0] Then _PopUp($t,$f_array[$i])
		EndIf
	EndIf
EndFunc;wenn click, dann admin !

Func _PopUp($t,$ret)
	If StringInStr(WinGetTitle(""),$t) Then $t="this script"
	ToolTip("Origin: "&$t,Default,Default,$ret)
	AdlibEnable("_Tooltip",10000)
	GUICtrlSetState($s_link,64)
	Sleep(200)
EndFunc;globalen string mit func od const returnen

Func _sciExit()
	$msg=""
	GUIDelete($s_GUI)
	$s_GUI=""
	_Tooltip()
EndFunc

Func _WM_NOTIFY($hWndGUI,$MsgID,$wParam,$lParam);noch rechtsklick abfangen
	$tagNMHDR=DllStructCreate("int;int;int;int;int;int;int;ptr;int;int;int;int;int;int;int;int;int;int;int",$lParam)
	$event=DllStructGetData($tagNMHDR,3)
	$position=DllStructGetData($tagNMHDR,4)
	If $event=2010 Then _SendMessage(2231,_SendMessage(2166,$position,0),0)
	Return "$GUI_RUNDEFMSG"
EndFunc

Func _SetStyle($style,$fore,$back,$size=0,$font="",$bold=0,$italic=0,$underline=0)
	_SendMessage(2051,$style,$fore)
	_SendMessage(2052,$style,$back)
	If $size Then _SendMessage(2055,$style,$size)
	If $font Then _SendMessageString(2056,$style,$font)
	_SendMessage(2053,$style,$bold)
	_SendMessage(2054,$style,$italic)
	_SendMessage(2059,$style,$underline)
EndFunc

Func _SetProperty($property);nach oben ?
	DllCall($user32,"int","SendMessageA","hwnd",$Sci,"int",4004,"str",$property,"str",1)
EndFunc

Func _SendMessage($msg,$wp,$lp)
	$ret=DllCall($user32,"long","SendMessageA","long",$Sci,"int",$msg,"int",$wp,"int",$lp)
	Return $ret[0]
EndFunc

Func _SendMessageString($msg,$wp,$str)
	$ret=DllCall($user32,"int","SendMessageA","hwnd",$Sci,"int",$msg,"int",$wp,"str",$str)
	Return $ret[0]
EndFunc
#EndRegion
#Region;---these functions are made to override AutoIt limitations :-( ----------
Func _HexToDec($x)
	Dim $ret="",$j=0,$y=StringSplit($x,"")
	For $i=$y[0] To 1 Step -1
		$t=StringInStr($ref,$y[$i])-1
		$ret+=$t*16^$j
		$j+=1
	Next
	Return $ret
EndFunc

Func _DecToHex($x)
	If $x=0 Then
		$ret="00"
	Else
		If $x<2147483647 Then;4294967296 falsch !
			$ret=Hex($x)
		Else
			$ret=""
			For $i=15 To 0 Step -1
				$y=16^$i-1	;	If $ret="" And $limit=16 And $y>$x Then ContinueLoop
				$t=Int($x/($y+1))	;	If $ret="" And $limit=16 And $i>0 And $t=0 Then ContinueLoop
				$ret&=StringMid($ref,$t+1,1)
				$x-=$t*($y+1)
			Next
		EndIf
		While StringLeft($ret,2)="00" Or (StringLeft($ret,1)="0" And Mod(StringLen($ret),2)=1)
			$ret=StringMid($ret,2)
		WEnd
	EndIf
	Return $ret
EndFunc

Func _IniReadSection($x,$y,ByRef $i_key,ByRef $i_val)
	$t=StringRegExp(@CRLF&FileRead($x)&@CRLF&"[","(?s)(?i)\n\s*\[\s*"&$y&"\s*\]\s*\r\n(.*?)\[",3)
	$Key=StringRegExp(@LF&$t[0],"\n\s*(.*?)\s*=",3);hier ist fehler beim droppen aufgetreten $t[0] kein array 
	$Val=StringRegExp(@LF&$t[0],"\n\s*.*?\s*=(.*?)\r",3);	If UBound($Key)<>UBound($Val) Then MsgBox(0,$Key[UBound($Key)-1],$Val[UBound($Val)-1])
	Dim $t=UBound($Key),$i_key[$t+1],$i_val[$t+1]
    $i_key[0]=$t
	$i_val[0]=$t
    For $i=0 To $t-1
        $i_key[$i+1]=$Key[$i]
        $i_val[$i+1]=$Val[$i]
    Next
EndFunc
#EndRegion