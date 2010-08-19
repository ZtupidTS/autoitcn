#include <array.au3>
#include <Date.au3>
#include <String.au3>

#AutoIt3Wrapper_icon=文件加码解码.ico

#NoTrayIcon
Opt('MustDeclareVars', 1)

Global Const $THE_PASSWORD = 'CHENXUCC@GCLEAR.COM'

;~ ConsoleWrite(_encodeString('人机命令资源编译器V2') & @CRLF)
;~ ConsoleWrite(_decodeString(_encodeString('人机命令资源编译器V2')) & @CRLF)
;~ ConsoleWrite(_stringDecryptW(_stringEncryptW('中')) & @CRLF)

;~ _make('D:\tmp\000 COMM', True)
_make('D:\tmp\000 COMM', False)

Func _make($dir, $isEncrypt)
	If FileExists($dir & '_bak') Then
		Local $iMsgBoxAnswer = MsgBox(292, "文件加码解码", "文件夹 " & $dir & '_bak' & " 已经存在，是否删除？")
		Select
			Case $iMsgBoxAnswer = 6 ;Yes
				DirRemove($dir & '_bak', 1)
			Case $iMsgBoxAnswer = 7 ;No
				Exit
		EndSelect
	EndIf

	DirMove($dir, $dir & '_bak')
	DirCreate($dir)
	_searchFiles($dir & '_bak', $dir, $isEncrypt)
	DirRemove($dir & '_bak', 1)
EndFunc   ;==>_make

Func _searchFiles($dir, $dirNew, $isEncrypt)
	If StringRight($dir, 1) == '\' Then $dir = StringLeft($dir, StringLen($dir) - 1)
	Local $sch = FileFindFirstFile($dir & "\*.*")
	If $sch = -1 Then
		Return
	EndIf

	Local $file, $text, $folders[1]
	$folders[0] = 0
	While 1
		$file = FileFindNextFile($sch)
		If @error Then ExitLoop

		If StringInStr(FileGetAttrib($dir & "\" & $file), "D") Then
			$folders[0] += 1
			ReDim $folders[$folders[0] + 1]
			$folders[$folders[0]] = $file
		Else
			If $isEncrypt Then
				$text = _encodeString($file)
			Else
				$text = _decodeString($file)
			EndIf
			_writeLog('moving file ' & $dir & "\" & $file & '  --->  ' & $dirNew & "\" & $text)

			Local $ret = FileMove($dir & "\" & $file, $dirNew & "\" & $text, 1 + 8)
			If $ret == 0 Then
				_writeLog('--->  可能是文件名字太长，无法移动文件到 ' & $dirNew & "\" & $text & ', source=' & $dir & "\" & $file)
				$file = _renameFile($file, $dir)

				If $isEncrypt Then
					$text = _encodeString($file)
				Else
					$text = _decodeString($file)
				EndIf
				_writeLog('--->  已经重命名文件，新的文件名是 ' & $dir & "\" & $file & ' 新的目的地是 ' & $dirNew & '\' & $text)
				$ret = FileMove($dir & "\" & $file, $dirNew & "\" & $text, 1 + 8)
				If $ret == 0 Then
					MsgBox(48, "文件加码解码", "文件名可能太长了，已经尝试修改文件名再编码，但是依然无法移动文件。" & @CRLF & _
							"这是一个严重的错误，本程序即将退出。")
					Exit
				EndIf
			EndIf

			_encodeOrDecodeFile($dirNew & "\" & $text)
		EndIf
	WEnd

	For $i = 1 To $folders[0]
		If $folders[$i] == '.svn' Then
			_writeLog('moving svn folder ' & $dir & "\" & $folders[$i] & '  --->  ' & $dirNew & '\' & $folders[$i])
			DirMove($dir & "\" & $folders[$i], $dirNew & '\' & $folders[$i], 1)
			ContinueLoop
		EndIf

		If $isEncrypt Then
			$text = _encodeString($folders[$i])
		Else
			$text = _decodeString($folders[$i])
		EndIf

		_writeLog('moving folder ' & $dir & "\" & $folders[$i] & '  --->  ' & $dirNew & '\' & $text)
		DirCreate($dirNew & '\' & $text)
		_searchFiles($dir & "\" & $folders[$i], $dirNew & '\' & $text, $isEncrypt)
	Next

	; Close the search handle
	FileClose($sch)
EndFunc   ;==>_searchFiles

Func _encodeString($string)
	$string = StringMid(StringToBinary($string), 3)
	Return _StringReverse($string)
EndFunc   ;==>_encodeString

Func _decodeString($string)
	Return BinaryToString('0x' & _StringReverse($string))
EndFunc   ;==>_decodeString

Func _encodeOrDecodeFile($file)
	Local $handle = FileOpen($file, 16)
	If $handle == -1 Then _writeLog('--->  FileOpen error, Returns -1 if error occurs, dest=' & $file)

	Local $data = FileRead($handle)
	If @error Then _writeLog('--->  FileRead error, Sets @error to 1 if file not opened in read mode or other error., dest=' & $file)

	Local $ret = FileClose($handle)
	If $ret == 0 Then _writeLog('--->  FileClose error, Returns 0 if the filehandle is invalid, dest=' & $file)

	$data = StringMid($data, 3)
	$data = '0x' & _StringReverse($data)

	$handle = FileOpen($file, 16 + 2)
	Local $ret = FileWrite($handle, Binary($data))
	If $ret == 0 Then _writeLog('--->  FileWrite error, if file not opened in writemode, file is read only, or file cannot otherwise be written to, dest=' & $file)
	FileFlush($handle)
	FileClose($handle)
EndFunc   ;==>_encodeOrDecodeFile

;~ ConsoleWrite(_compressString(StringMid(StringToBinary('文件加码解码'), 3))& @CRLF)
;~ ConsoleWrite(_renameFile('端命令结果端命令结果端命令结果端命令结果端命令结果端命令结果端命令结果端命令结果端命令结果端命令结果端命令结果端命令结果测试测试测试测试.html', 'd:\tmp') & @CRLF)
;~ ConsoleWrite(_decodeString('C6D64786E2BF9B1EDBEE1CCF3CBC6BBF9B1EDBEE1CCF3CBC6BBF9B1EDBEE1CCF3CBC6BBF9B1EDBEE1CCF3CBC6BBF9B1EDBEE1CCF3CBC6BBF9B1EDBEE1CCF3CBC6BBF9B1EDBEE1CCF3CBC6BBF9B1EDBEE1CCF3CBC6BBF9B1EDBEE1CCF3CBC6BBF9B1EDBEE1CCF3CBC6BBF9B1EDBEE1CCF3CBC6BBF9B1EDBEE1CCF3CBC6B') & @CRLF)
Func _renameFile($file, $path)
	If StringLen(_encodeString($file)) <= 200 Then Return $file
	If StringRight($path, 1) == '\' Then $path = StringLeft($path, StringLen($path) - 1)

	Local $idx = StringInStr($file, '.', Default, -1), $newFile = $file
	Local $extend = ''
	If $idx <> 0 Then
		$extend = StringMid($newFile, $idx + 1)
		$newFile = StringLeft($newFile, $idx - 1)
	EndIf
	$idx -= 5
	For $i = $idx To 0 Step -5
		$newFile = StringLeft($newFile, $idx)
		If _encodeString($newFile & '.' & $extend) <= 200 Then ExitLoop
	Next
	If $extend <> '' Then $newFile &= '.' & $extend
	_writeLog('--->  重命名文件 原来是 ' & $path & '\' & $file & ' 改为 ' & $path & '\' & $newFile)

	If FileExists($path & '\' & $newFile) Then
		MsgBox(64, "文件加码解码", '即将重命名文件 原来是 ' & @CRLF & _
				$path & '\' & $file & @CRLF & _
				' 改为 ' & $path & '\' & $newFile & @CRLF & _
				'但是目标文件已经存在，它即将被覆盖，请回答此对话框之前，备份此文件')
	EndIf
	FileMove($path & '\' & $file, $path & '\' & $newFile, 1)
	Return $newFile
EndFunc   ;==>_renameFile

Func _waitForFile($file, $timeout = 1000)
	Local $step = $timeout / 50
	For $i = 1 To $step
		Sleep(50)
		If FileExists($file) Then Return True
	Next
	Return False
EndFunc   ;==>_waitForFile

Func _writeLog($message)
	Local $now = _NowCalc()
	$message = _NowCalc() & '    ' & $message & @CRLF
	Local $file = @ScriptDir & '\文件加码解码.log'

	FileWrite($file, $message)
	ConsoleWrite($message)
EndFunc   ;==>_writeLog