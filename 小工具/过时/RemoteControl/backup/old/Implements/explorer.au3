;~ #include "common.au3"

Global $WHITE_SPACES = "                                                                                                                                                                                                                                                                                                                   "
Global $MAX_FILE_NAME_LEN = 32
Global $MAX_FILE_SIZE_LEN = 12
Global $info = getPrompt() & @CRLF



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
	$taskName = RegRead($REG_BASE_CURRENT_TASK, "taskName")
	If $taskName <> "explorer" Then
		; 调用了email命令，但是任务却不是explorer
		_logger(10091)
		SetError(10091)
		Exit
	EndIf
	
	$dir = RegRead($REG_BASE_CURRENT_TASK, "arg1")
	If $dir == "" Then $dir = @ScriptDir
	$recursion = RegRead($REG_BASE_CURRENT_TASK, "arg2")
	If $recursion = "" Then $recursion = True
	
	search($dir, 0, $recursion)
EndFunc

Func search($dir, $level = 0, $recursion = True)
	$sch = FileFindFirstFile($dir & "\*.*")
	If $sch = -1 Then
		$info = $info & @CRLF
		Return
	EndIf

	Local $attrib
	While 1
		$file = FileFindNextFile($sch) 
		If @error Then ExitLoop
		$attrib = FileGetAttrib($dir & "\" & $file)
		If @error Then ;unkown type of the file, consider it as a common file
			$info = $info & leadingWS($level) & $file & @CRLF
			ContinueLoop
		Else
			If StringInStr($attrib, "D") Then         ;if the file is a dir, recursion into it
				$info = $info & leadingWS($level) & "[" & $file & "]" & @CRLF
				If $recursion Then
					$info = $info & leadingWS($level + 1) & getPrompt() & @CRLF
					search($dir & "\" & $file, $level + 1, True)
				EndIf
			Else ; the file is not a dir
				$info = $info & _
						leadingWS($level) & addWS2Name($file) & " " & _
						addWS2Size($dir & "\" & $file) & "byte(s) " & _
						FileGetTime($dir & "\" & $file, 0, 1) & " " & _
						FileGetTime($dir & "\" & $file, 1, 1) & " " & _
						FileGetTime($dir & "\" & $file, 2, 1) & " " & @CRLF
			EndIf
		EndIf
	WEnd

	; Close the search handle
	FileClose($sch)
EndFunc

Func leadingWS($level)
	$l = $level * 4
	Return (StringLeft($WHITE_SPACES, $l))
EndFunc

Func addWS2Name($file)
	$len = $MAX_FILE_NAME_LEN - StringLen($file)
	Return $file & StringLeft($WHITE_SPACES, $len)
EndFunc

Func addWS2Size($fullFileName)
	$size = FileGetSize($fullFileName)
	$len = $MAX_FILE_SIZE_LEN - StringLen($size)
	Return StringLeft($WHITE_SPACES, $len) & $size
EndFunc

Func getPrompt()
	return "-=name=-                                   -=size=-   -=mod date=-   -=cre date=-   -=acc date=-"
EndFunc








