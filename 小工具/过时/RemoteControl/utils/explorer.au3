#include "common.au3"
#NoTrayIcon

;
; 最多找500个文件，如果超过这个数，则返回
; $info[n][0] 文件名
; $info[n][1] 文件大小
; $info[n][2] 文件修改日期
; $info[n][3] 文件创建日期
; $info[n][4] 文件访问日期
;
Global $MAX_FILE_COUNT = 300
Global $info[$MAX_FILE_COUNT + 3][5]  
Global $maxLen = StringLen("-=name=-")
Global $index = 1
explorer()
;~ Global $file = getTmpFile("txt")
;~ FileWrite($file, @ScriptFullPath & " " & $CmdLineRaw & @CRLF & @CRLF & getText())
responseByMsn(getText())

;===============================================================================
;
; Function Name:	explorer()
; Description:		查看一个目录下的文件
; Parameter(s):		dir:			需要查看的目录，默认：程序的当前目录
; 					recursion:		是否递归访问子目录，默认：是
; 					
; Return Value(s):  On Success - 无
;                   On Failure - 无
; Error Code:		10091 ~ 10100
; Author(s):        Chenxu
;
;===============================================================================

Func explorer()
	$dir = @ScriptDir
	$recursion = False
	Switch $cmdLine[0]
	Case 0
		$dir = @ScriptDir
		$recursion = False
	Case 1
		$dir = $cmdLine[1]
		$recursion = False
	Case 2
		$dir = $cmdLine[1]
		$recursion = $cmdLine[2]
	EndSwitch
	If $dir == "" Then
		$dir = @ScriptDir
	ElseIf StringLen($dir) == 3 Then ;like e:\
		$dir = StringLeft($dir, 2)
	EndIf
	If StringLower($recursion) == "true" Then
		$recursion = True
	Else
		$recursion = False
	EndIf
	
	search($dir, $recursion)
	$info[0][0] = $index - 1
	$maxLen = $maxLen + 1
	
EndFunc


Func search($dir, $recursion = True)
	ConsoleWrite($index & @CRLF)
	$sch = FileFindFirstFile($dir & "\*.*")
	If $sch = -1 Then
		responseByMsn("文件夹：【" & $dir & "】不存在！")
		Return
	EndIf

	Local $attrib
	Local $len
	While 1
		$file = FileFindNextFile($sch) 
		If @error Then ExitLoop
		$attrib = FileGetAttrib($dir & "\" & $file)
		If @error Then ;unkown type of the file, consider it as a common file
			$len = StringLen($dir & "\" & $file) + countChineseChar($dir & "\" & $file)
			If $len > $maxLen Then $maxLen = $len
			If $index > $MAX_FILE_COUNT Then Return
			$info[$index][0] = $dir & "\" & $file
			$info[$index][1] = FileGetSize($dir & "\" & $file)
			$info[$index][2] = FileGetTime($dir & "\" & $file, 0, 1)
			$info[$index][3] = FileGetTime($dir & "\" & $file, 1, 1)
			$info[$index][4] = FileGetTime($dir & "\" & $file, 2, 1)
			$index = $index + 1
			ContinueLoop
		EndIf
		If StringInStr($attrib, "D") Then         ;if the file is a dir, recursion into it
			$len = StringLen("* " & $dir & "\" & $file) + countChineseChar($dir & "\" & $file)
			If $len > $maxLen Then $maxLen = $len
			If $index > $MAX_FILE_COUNT Then Return
			$info[$index][0] =  "* " & $dir & "\" & $file
			$info[$index][1] = "Directory"
			$info[$index][2] = FileGetTime($dir & "\" & $file, 0, 1)
			$info[$index][3] = FileGetTime($dir & "\" & $file, 1, 1)
			$info[$index][4] = FileGetTime($dir & "\" & $file, 2, 1)
			$index = $index + 1
			If $recursion Then search($dir & "\" & $file, True)
		Else
			$len = StringLen($dir & "\" & $file) + countChineseChar($dir & "\" & $file)
			If $len > $maxLen Then $maxLen = $len
			If $index > $MAX_FILE_COUNT Then Return
			$info[$index][0] = $dir & "\" & $file
			$info[$index][1] = FileGetSize($dir & "\" & $file)
			$info[$index][2] = FileGetTime($dir & "\" & $file, 0, 1)
			$info[$index][3] = FileGetTime($dir & "\" & $file, 1, 1)
			$info[$index][4] = FileGetTime($dir & "\" & $file, 2, 1)
			$index = $index + 1
		EndIf
	WEnd
	; Close the search handle
	FileClose($sch)
EndFunc

Func getText()
	Local $text = getPrompt()
	For $i = 1 To $info[0][0]
		$text = $text & feedSP($info[$i][0], $maxLen) & " | "
		$text = $text & feedSP($info[$i][1], 14) & " | "
		$text = $text & feedSP($info[$i][2], 16) & " | "
		$text = $text & feedSP($info[$i][3], 15) & " | "
		$text = $text & feedSP($info[$i][4], 16) & @CRLF
	Next
	If $index > $MAX_FILE_COUNT Then $text = $text & "And more..." & @CRLF
	Return $text
EndFunc

Func getPrompt()
	Local $prmp = "-=name=-"
	For $i = StringLen("-=name=-") To $maxLen + 1
		$prmp = $prmp & " "
	Next
	$prmp = $prmp & "|  -=file size=-  | -=modified date=- | -=created date=- | -=accessed date=-" & @CRLF
	Return $prmp
EndFunc

Func feedSP($str, $maxlength)
	Local $n = StringLen($str)
	If $n >= $maxlength Then Return $str
	Local $m = countChineseChar($str)
	For $i = $n To $maxlength - $m
		$str = $str & " "
	Next
	Return $str
EndFunc


