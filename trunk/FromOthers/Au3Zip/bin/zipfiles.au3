;MsgBox(4096,"CmdLineRaw",$CmdLineRaw)
#compiler_plugin_funcs=_ZipCreate,_ZipAdd,_ZipAddDir,_ZipAddFolder,_ZipGetList,_ZipUnZip,_ZipClose,_ZipAddFileToZip,_ZipDeleteFile,_ZipFormatMessage,_PointerTest
;;compile this script to exe.
;;In codeblocks, goto Tools>> Configure Tools...>> Add.
;; for Name use something like, ZipUp Project
;; Executable >> the path to this compiled script
;;for Parameters, use this line:  ${PROJECT_DIR}\${PROJECT_NAME}.zip ${PROJECT_FILENAME} ${ALL_PROJECT_FILES}
;;set the radio button for Launch tool hidden with standard output redirected.
;;click Ok and Ok.
If $CmdLine[0] < 3 Then Exit
If Not FileExists(@ScriptDir & "\Au3Zip.dll") Then
	MsgBox(4096, "Error:", "A file required to execute this script could not be found." & @LF _
			 & "Please locate the file 'Au3Zip.dll' and place it in the same" & @LF _
			 & "dir as this script.")
	Exit
EndIf
Local $handle
If (($handle = PluginOpen("Au3Zip.dll")) <> 0) Then
	Local $ZR_RECENT = 1 ;use this flag to get the last set zip error message from functions that return handles.
	Local $hFile = _ZipCreate ($CmdLine[1], 0)
	ConsoleWrite("_ZipCreate:return code>" & $hFile & @LF)
	ConsoleWrite(_ZipFormatMessage ($ZR_RECENT) & @LF)
	If $hFile Then
	Local $drive
	Local $internal
	Local $fullpath
	Local $v_ret
	Local $begin = StripFileName($CmdLine[1])
	For $x =2 To $CmdLine[0]
		$fullpath = GetFullPath($begin, $CmdLine[$x])
		$drive = StringInStr($fullpath, ":\")
		If $drive > 0 Then $drive += 1
		$internal = StringTrimLeft($fullpath, $drive)
		ConsoleWrite("Adding " & $fullpath & " to zip." & @LF)
		$v_ret = _ZipAdd ($hFile, $fullpath, $internal)
		ConsoleWrite(_ZipFormatMessage ($v_ret) & @LF)
	Next
	_ZipClose ($hFile)
	ConsoleWrite("The file "&$CmdLine[1]&" has been created."&@LF)
EndIf
	PluginClose($handle)
EndIf
Exit

Func StripFileName($path)
	Local $szPtr = DllStructCreate("char["&StringLen($path)+1&"]")
	DllStructSetData($szPtr,1,$path)
	$vret = DllCall("shlwapi.dll","int","PathRemoveFileSpec","ptr",DllStructGetPtr($szPtr))
	consoleWrite("--->"&DllStructGetData($szPtr,1)&@LF)
	Return DllStructGetData($szPtr,1)
EndFunc

Func GetFullPath($base, $relative)
	Local $back = 0
	$base = StringStripWS($base, 3)
	$relative = StringStripWS($relative, 3)
	$base = StringReplace($base, "/", "\")
	$base = StringReplace($base, "\\", "\")
	While (StringRight($base, 1) = "\")
		$base = StringTrimRight($base, 1)
	WEnd
	If StringInStr($relative, ":\") Then
		$full = $relative
	Else
		If StringInStr($relative, "..\") Then
			While StringLeft($relative, 3) = "..\"
				$back += 1
				$relative = StringTrimLeft($relative, 3)
			WEnd
			If $back Then
				$full = StringLeft($base, StringInStr($base, "\", 0, -$back)) & $relative
			Else
				$full = $base & "\" & $relative
			EndIf
		Else
			If StringLeft($relative, 2) = ".\" Then
				While StringLeft($relative, 2) = ".\"
					$relative = StringTrimLeft($relative, 2)
				WEnd
			EndIf
			$full = $base & "\" & $relative
		EndIf
	EndIf
	ConsoleWrite("FullPath>>"&$full&@LF)
	Return $full
EndFunc   ;==>GetFullPath