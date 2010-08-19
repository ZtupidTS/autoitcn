#include <GUIConstants.au3>
#include <GuiListView.au3>
#Include "_ZipPlugin.au3"

#Region ### START Koda GUI section ### Form=
$ZipPluginTest = GUICreate("ZipPluginTest", 633, 447, 193, 115)
$btnExit = GUICtrlCreateButton("Exit", 320, 410, 75, 25, 0)
$btnGo = GUICtrlCreateButton("Go", 240, 410, 75, 25, 0)
$edtListView = GuiCtrlCreateListView(" |Name       |Ctime|Mtime|Size|Ratio|Packed",10,10,610,185)
	GUICtrlSendMsg($edtListView, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_GRIDLINES, $LVS_EX_GRIDLINES)
	GUICtrlSendMsg($edtListView, 0x101E, 1, 150)
	;GUICtrlSendMsg($ListView1, 0x101E, 1, 150)

$edtOutput = GUICtrlCreateEdit("", 10, 200, 610, 184)
GUICtrlSetData(-1, "")
GUICtrlSetFont(-1, 10, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0xFFFF00)
GUICtrlSetBkColor(-1, 0x000000)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
GuiCtrlSetState($btnExit,$GUI_ENABLE)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $btnExit
			Exit
		Case $btnGo
		GuiCtrlSetState($btnExit,$GUI_DISABLE)
		Test()
		GuiCtrlSetState($btnExit,$GUI_ENABLE)
	EndSwitch
WEnd	
Func Test()
Local $handle, $v_ret,$msg
if (($handle = PluginOpen("C:\Au3Zip\bin\Au3Zip.dll")) <> 0) Then
$ZR_RECENT =1 ;use this flag to get the last set zip error message from functions that return handles.
;MsgBox(266288,"Au3Zip Plugin",_ZipPluginAbout());
;==============================================================================
;These function below take the file handle as returned by _ZipCreate
;	_ZipAdd
;	_ZipAddFolder
;	_ZipAddDir
;	_ZipClose
;==============================================================================
;create a new zip> returns a FILE handle
;==============================================================================

$hFile = _ZipCreate("test.zip")
_AddMessage($edtOutput,'_ZipCreate("\test.zip",0)')
_AddMessage($edtOutput,"_ZipCreate:return code>"&$hFile)
_AddMessage($edtOutput,_ZipFormatMessage($ZR_RECENT))

;==============================================================================
; add files to the zip using the open handle
;==============================================================================
$v_ret = _ZipAdd($hFile,"C:\Au3Zip\bin\simple.jpg","Au3Zip\bin\simple.jpg")
_AddMessage($edtOutput,'_ZipAdd($hFile,"C:\Au3Zip\bin\simple.jpg","Au3Zip\bin\simple.jpg")')
_AddMessage($edtOutput,"_ZipAdd:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))

;==============================================================================
; add an empty folder to the zip using the open file handle
;==============================================================================
$v_ret = _ZipAddFolder($hFile,"emptyfolder")
_AddMessage($edtOutput,'_ZipAddFolder($hFile,"emptyfolder")')
_AddMessage($edtOutput,"_ZipAddFolder:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))

;==============================================================================
; add a directory to the zip using the open file handle 0 = recursive, 1 = non-recursive
;==============================================================================
$v_ret = _ZipAddDir($hFile,"C:\Au3Zip\src",0)
_AddMessage($edtOutput,'_ZipAddDir($hFile,"C:\Au3Zip\src",0')
_AddMessage($edtOutput,"_ZipAddDir:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))

;==============================================================================
;~ ; complete the zip by closing the file referenced by the handle.
;==============================================================================
$v_ret = _ZipClose($hFile)
_AddMessage($edtOutput,'_ZipClose($hFile)')
_AddMessage($edtOutput,"_ZipClose:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))
$hFile =0;

;==============================================================================
; get list of files in zip.  This func takes a filename
; note: the plugin returns all info for all enteries associated with the archive
; each entry (file) is deliminated by a line feed.
; attribs for each line are deliminated by a ;
;_ZipGetList($ZipFile)
;==============================================================================
$numitems = _ZipGetCount("test.zip")
_AddMessage($edtOutput,"_ZipGetList:NumItems>"&($numitems))
Local $szZipFiles = _ZipList2Array("test.zip")
Local $msg="File List"&@CRLF
For $x = 0 to UBound($szZipFiles,1)-1
	$msg &= ("Index:"&$szZipFiles[$x][$ZIP_INDEX]&@CRLF)
	$msg &= ("Name :"&$szZipFiles[$x][$ZIP_NAME]&@CRLF)
	$msg &= ("Atime:"&$szZipFiles[$x][$ZIP_ATIME]&@CRLF)
	$msg &= ("Ctime:"&$szZipFiles[$x][$ZIP_CTIME]&@CRLF)
	$msg &= ("Mtime:"&$szZipFiles[$x][$ZIP_MTIME]&@CRLF)
	$msg &= ("CSize:"&$szZipFiles[$x][$ZIP_CSIZE]&@CRLF)
	$msg &= ("USize:"&$szZipFiles[$x][$ZIP_USIZE]&@CRLF)
	$msg &= (@CRLF)
	
Next
;MsgBox(0,"Files",$msg)
_AddMessage($edtOutput,$msg)

;==============================================================================
	if FileExists("C:\PluginTest") Then DirRemove("C:\PluginTest",1)
	DirCreate("C:\PluginTest")
;==============================================================================

;==============================================================================
; The following funcs take a filename to a zip archive.
;
;==============================================================================

;==============================================================================
; unzip the contents of the zip to specified dir.
; _ZipUnZip($ZipFile,$Dest)
;==============================================================================
$v_ret = _ZipUnZip("C:\Au3Zip\bin\dummy2.txt","C:\PluginTest")
ConsoleWrite("@error= "&@error);
_AddMessage($edtOutput,'_ZipUnZip("C:\Au3Zip\bin\dummy2.txt","C:\PluginTest")')
_AddMessage($edtOutput,"_ZipUnZip:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))

;==============================================================================
; add files to an existing zip.
;_ZipAddFileToZip($ZipFile,$PathToFileToAdd,$NameInZip")
;==============================================================================
$v_ret = _ZipAddFileToZip("dummy1.zip","dummy2.txt","dummy2.txt")
_AddMessage($edtOutput,'_ZipAddFileToZip("dummy1.zip","dummy2.txt","dummy2.txt")')
_AddMessage($edtOutput,"_ZipAddFileToZip:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))
$v_ret = _ZipAddFileToZip("dummy1.zip","dummy3.txt","dummy3.txt")
_AddMessage($edtOutput,'_ZipAddFileToZip("dummy1.zip","dummy3.txt","dummy3.txt")')
_AddMessage($edtOutput,"_ZipAddFileToZip:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))
$v_ret = _ZipAddFileToZip("dummy1.zip","dummy4.txt","dummy4.txt")
_AddMessage($edtOutput,'_ZipAddFileToZip("dummy1.zip","dummy4.txt","dummy4.txt")')
_AddMessage($edtOutput,"_ZipAddFileToZip:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))
_AddMessage($edtOutput,'_ZipAddFileToZip("dummy1.zip","dummy4.txt","lorem.txt")')
$v_ret = _ZipAddFileToZip("dummy1.zip","dummy4.txt","lorem.txt")
_AddMessage($edtOutput,"_ZipAddFileToZip:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))
_AddMessage($edtOutput,'_ZipAddFileToZip("test.zip","dummy3.txt","lorem.txt")')
$v_ret= _ZipAddFileToZip("test.zip","dummy3.txt","lorem.txt")
_AddMessage($edtOutput,"_ZipAddFileToZip:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))

;==============================================================================
; Show a list of item info for all files in the zip
;_ZipList2Array($ZipFile)
;==============================================================================
Local $szZipFiles = _ZipList2Array("test.zip") 
For $x = 0 to UBound($szZipFiles,1)-1
	ConsoleWrite($x&@LF)
	if Not @error then
	$msg &= ("Index:"&$szZipFiles[$x][$ZIP_INDEX]&@CRLF)
	$msg &= ("Name :"&$szZipFiles[$x][$ZIP_NAME]&@CRLF)
	$msg &= ("Atime:"&$szZipFiles[$x][$ZIP_ATIME]&@CRLF)
	$msg &= ("Ctime:"&$szZipFiles[$x][$ZIP_CTIME]&@CRLF)
	$msg &= ("Mtime:"&$szZipFiles[$x][$ZIP_MTIME]&@CRLF)
	$msg &= ("CSize:"&$szZipFiles[$x][$ZIP_CSIZE]&@CRLF)
	$msg &= ("USize:"&$szZipFiles[$x][$ZIP_USIZE]&@CRLF)
	$msg &= (@CRLF)
	$item = StringFormat("%s|%s|%s|%s|%s|%s|%s",$szZipFiles[$x][$ZIP_INDEX],$szZipFiles[$x][$ZIP_NAME],$szZipFiles[$x][$ZIP_CTIME], _ 
															$szZipFiles[$x][$ZIP_MTIME],$szZipFiles[$x][$ZIP_USIZE],_ZipGetRatio($szZipFiles[$x][$ZIP_CSIZE],$szZipFiles[$x][$ZIP_USIZE])&"%",$szZipFiles[$x][$ZIP_CSIZE])
	GUICtrlCreateListViewItem($item,$edtListView)
	endif	
Next
_AddMessage($edtOutput,$msg)

;==============================================================================
;deleting a file in an already existing zip.
;_ZipDeleteFile($ZipFile,$FileInZipToRemove)
;==============================================================================
_AddMessage($edtOutput,'_ZipDeleteFile("test.zip","lorem.txt")')
$v_ret = _ZipDeleteFile(@ScriptDir&"\test.zip","lorem.txt")
_AddMessage($edtOutput,"_ZipDeleteFile:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))
$v_ret = _ZipDeleteFile("dummy1.zip","lorem.txt")
_AddMessage($edtOutput,'_ZipDeleteFile("dummy1.zip","lorem.txt")')
_AddMessage($edtOutput,"_ZipDeleteFile:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))

;==============================================================================
; Show a list of file info for a file in the zip
;_ZipItemInfo2Array($ZipFile,$ItemIndex)
;==============================================================================
Local	$szZipFiles = _ZipItemInfo2Array("dummy1.zip",1)
	if Not(@error) Then
	$msg &= ("Index:"&$szZipFiles[$ZIP_INDEX]&@CRLF)
	$msg &= ("Name :"&$szZipFiles[$ZIP_NAME]&@CRLF)
	$msg &= ("Atime:"&$szZipFiles[$ZIP_ATIME]&@CRLF)
	$msg &= ("Ctime:"&$szZipFiles[$ZIP_CTIME]&@CRLF)
	$msg &= ("Mtime:"&$szZipFiles[$ZIP_MTIME]&@CRLF)
	$msg &= ("CSize:"&$szZipFiles[$ZIP_CSIZE]&@CRLF)
	$msg &= ("USize:"&$szZipFiles[$ZIP_USIZE]&@CRLF)
	$msg &= (@CRLF)
	$item = StringFormat("%s|%s|%s|%s|%s|%s|%s",$szZipFiles[$ZIP_INDEX],$szZipFiles[$ZIP_NAME],$szZipFiles[$ZIP_CTIME], _ 
															$szZipFiles[$ZIP_MTIME],$szZipFiles[$ZIP_USIZE],_ZipGetRatio($szZipFiles[$ZIP_CSIZE],$szZipFiles[$ZIP_USIZE])&"%",$szZipFiles[$ZIP_CSIZE])
	GUICtrlCreateListViewItem($item,$edtListView)
	EndIf
	_AddMessage($edtOutput,$msg)

_AddMessage($edtOutput,'_ZipGetList("test.zip")')
_AddMessage($edtOutput,"_ZipGetList:return code>"&($v_ret))
$v_ret = _ZipGetCount("test.zip")
_AddMessage($edtOutput,'_ZipGetCount("test.zip")')
_AddMessage($edtOutput,"_ZipGetCount:return code>"&($v_ret))

;==============================================================================
; Show a list of file info for all files in the zip
;_ZipList2Array($ZipFile)
;==============================================================================
Local $szZipFiles = _ZipList2Array("test.zip") 
For $x = 0 to UBound($szZipFiles,1)-1
	;ConsoleWrite($x&@LF)
	if Not @error then
	$msg &= ("Index:"&$szZipFiles[$x][$ZIP_INDEX]&@CRLF)
	$msg &= ("Name :"&$szZipFiles[$x][$ZIP_NAME]&@CRLF)
	$msg &= ("Atime:"&$szZipFiles[$x][$ZIP_ATIME]&@CRLF)
	$msg &= ("Ctime:"&$szZipFiles[$x][$ZIP_CTIME]&@CRLF)
	$msg &= ("Mtime:"&$szZipFiles[$x][$ZIP_MTIME]&@CRLF)
	$msg &= ("CSize:"&$szZipFiles[$x][$ZIP_CSIZE]&@CRLF)
	$msg &= ("USize:"&$szZipFiles[$x][$ZIP_USIZE]&@CRLF)
	$msg &= (@CRLF)
	$item = StringFormat("%s|%s|%s|%s|%s|%s|%s",$szZipFiles[$x][$ZIP_INDEX],$szZipFiles[$x][$ZIP_NAME],$szZipFiles[$x][$ZIP_CTIME], _ 
															$szZipFiles[$x][$ZIP_MTIME],$szZipFiles[$x][$ZIP_USIZE],_ZipGetRatio($szZipFiles[$x][$ZIP_CSIZE],$szZipFiles[$x][$ZIP_USIZE])&"%",$szZipFiles[$x][$ZIP_CSIZE])
	GUICtrlCreateListViewItem($item,$edtListView)
	endif	
Next
_AddMessage($edtOutput,$msg)

;~ ;unzip to subdir
_AddMessage($edtOutput,'_ZipUnZip("test1.zip","C:\PluginTest\test1")')
$v_ret = _ZipUnZipItem("test1.zip","dummy1.txt","C:\PluginTest\test1")
_AddMessage($edtOutput,"_ZipUnZipItem:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))
_AddMessage($edtOutput,'_ZipUnZipItem("dummy1.zip","dummy1.txt","C:\PluginTest\test1")')
$v_ret = _ZipUnZipItem("dummy1.zip","dummy1.txt","C:\PluginTest\test1")
_AddMessage($edtOutput,"_ZipUnZipItem:return code>"&$v_ret)
_AddMessage($edtOutput,_ZipFormatMessage($v_ret))

PluginClose($handle)
_AddMessage($edtOutput,"Plugin closed")
EndIf

EndFunc

Func _AddMessage($nCtrl,$msg,$flag =1)
	GuiCtrlSetData($nCtrl,$msg&@CRLF,$flag)
EndFunc
