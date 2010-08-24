#include <array.au3>
#include <Date.au3>
#include <String.au3>
#include <GUIConstantsEx.au3>

#AutoIt3Wrapper_icon=icon.ico

#NoTrayIcon
Opt('MustDeclareVars', 1)

Global Const $THE_PASSWORD = 'CHENXUCC@GCLEAR.COM'

Local $Form = GUICreate("加密解密工具箱", 203, 137)
Local $btnEncryptFolder = GUICtrlCreateButton("加密文件夹", 8, 8, 91, 25)
Local $btnDecryptFolder = GUICtrlCreateButton("解密文件夹", 104, 8, 91, 25)
Local $btnEncryptFile = GUICtrlCreateButton("加密文件", 8, 40, 91, 25)
Local $btnDecryptFile = GUICtrlCreateButton("解密文件", 104, 40, 91, 25)
Local $btnEncryptString = GUICtrlCreateButton("加密字符串", 8, 72, 91, 25)
Local $btnDecryptString = GUICtrlCreateButton("解密字符串", 104, 72, 91, 25)
Local $btnClose = GUICtrlCreateButton("关闭", 8, 104, 188, 25)
GUISetState(@SW_SHOW)

While 1
	Local $nMsg = GUIGetMsg()
	Local $path, $file, $files, $string, $pos
	Select
		Case $nMsg = $btnEncryptFolder
			$path = FileSelectFolder('选择一个文件夹', '', 2, IniRead('文件加码解码.ini', 'main', 'path', ''), $Form)
			_writeLog('选择的文件夹是 ' & $path)
			If $path <> '' Then
				IniWrite('文件加码解码.ini', 'main', 'path', $path)
				If FileExists($path) Then
					_disableAll()
					_make($path, True)
					_enableAll()
				Else
					MsgBox(48, "文件加码解码", "请选择一个已经存在的文件夹。", Default, $Form)
				EndIf
			EndIf
		Case $nMsg = $btnDecryptFolder
			$path = FileSelectFolder('选择一个文件夹', '', 2, IniRead('文件加码解码.ini', 'main', 'path', ''), $Form)
			_writeLog('选择的文件夹是 ' & $path)
			If $path <> '' Then
				IniWrite('文件加码解码.ini', 'main', 'path', $path)
				If FileExists($path) Then
					_disableAll()
					_make($path, False)
					_enableAll()
				Else
					MsgBox(48, "文件加码解码", "请选择一个已经存在的文件夹。", Default, $Form)
				EndIf
			EndIf
		Case $nMsg = $btnEncryptFile Or $nMsg = $btnDecryptFile
			$files = FileOpenDialog('选择一个文件', '', '所有文件 (*.*)', 7, '', $Form)
			_writeLog('选择的文件是 ' & $files)
			If $files <> '' Then
				_disableAll()
				$files = StringSplit($files, '|')
				If Not IsArray($files) Then
					MsgBox(48, "文件加码解码", "选择的文件看起来好像是非法的。", Default, $Form)
					ContinueLoop
					_enableAll()
				ElseIf $files[0] == 1 Then
					_writeLog('encoding file ' & $files[1])
					_encodeOrDecodeFile($files[1])
					Local $idx = StringInStr($files[1], '\', Default, -1)
					If $idx <> 0 Then
						$file = StringMid($files[1], $idx + 1)
						If $nMsg == $btnEncryptFile Then
							$file = _encodeString($file)
						Else
							$file = _decodeString($file)
						EndIf
						$path = StringLeft($files[1], $idx)
						_writeLog('moving file ' & $files[1] & '  --->  ' & $path & $file)
						If Not FileMove($files[1], $path & $file, 1 + 9) Then
							_writeLog("--->  文件已经加密，但是无法重命名文件 " & $files[1])
							MsgBox(48, "文件加码解码", "文件已经加密，但是无法重命名文件 " & $files[1], Default, $Form)
						EndIf
					EndIf
				Else
					For $i = 2 To $files[0]
						_writeLog('encoding file ' & $files[1] & '\' & $files[$i])
						_encodeOrDecodeFile($files[1] & '\' & $files[$i])
						If $nMsg == $btnEncryptFile Then
							$file = _encodeString($file)
						Else
							$file = _decodeString($file)
						EndIf
						_writeLog('moving file ' & $files[1] & '\' & $files[$i] & '  --->  ' & $files[1] & '\' & $file)
						If Not FileMove($files[1] & '\' & $files[$i], $files[1] & '\' & $file, 1 + 9) Then
							_writeLog("--->  文件已经加密，但是无法重命名文件 " & $files[1] & '\' & $files[$i])
							MsgBox(48, "文件加码解码", "文件已经加密，但是无法重命名文件 " & $files[1] & '\' & $files[$i], Default, $Form)
						EndIf
					Next
				EndIf
				_enableAll()
			EndIf
		Case $nMsg = $btnEncryptString
			$pos = WinGetPos("加密解密工具箱", '关闭')
			$string = InputBox('加密字符串', '输入一个字符串', '', '', 200, 80, _
					($pos[2] - 200) / 2 + $pos[0], ($pos[3] - 100) / 2 + $pos[1], Default, $Form)
			If $string <> '' Then MsgBox(64, "文件加码解码", "加密后的字符串是" & @CRLF & _encodeString($string), Default, $Form)
		Case $nMsg = $btnDecryptString
			$pos = WinGetPos("加密解密工具箱", '关闭')
			$string = InputBox('解密字符串', '输入一个字符串', '', '', 200, 80, _
					($pos[2] - 200) / 2 + $pos[0], ($pos[3] - 100) / 2 + $pos[1], Default, $Form)
			If $string <> '' Then MsgBox(64, "文件加码解码", "解密后的字符串是" & @CRLF & _decodeString($string), Default, $Form)
		Case $nMsg = $GUI_EVENT_CLOSE
			Exit
		Case $nMsg = $btnClose
			Exit
	EndSelect
WEnd

Func _make($dir, $isEncrypt)
	If FileExists($dir & '_bak') Then
		Local $iMsgBoxAnswer = MsgBox(292, "文件加码解码", "文件夹 " & $dir & '_bak' & " 已经存在，是否删除？")
		Select
			Case $iMsgBoxAnswer = 6 ;Yes
				DirRemove($dir & '_bak', 1)
			Case $iMsgBoxAnswer = 7 ;No
				Return
		EndSelect
	EndIf

	DirMove($dir, $dir & '_bak')
	DirCreate($dir)
	_searchFiles($dir & '_bak', $dir, $isEncrypt)
;~ 	DirRemove($dir & '_bak', 1)
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

;~ 			Local $ret = FileMove($dir & "\" & $file, $dirNew & "\" & $text, 1 + 8)
			Local $ret = FileCopy($dir & "\" & $file, $dirNew & "\" & $text, 1 + 8)
			If $ret == 0 Then
				_writeLog('--->  可能是文件名字太长，无法移动文件到 ' & $dirNew & "\" & $text & ', source=' & $dir & "\" & $file)
				$file = _renameFile($file, $dir)

				If $isEncrypt Then
					$text = _encodeString($file)
				Else
					$text = _decodeString($file)
				EndIf
				_writeLog('--->  已经重命名文件，新的文件名是 ' & $dir & "\" & $file & ' 新的目的地是 ' & $dirNew & '\' & $text)
;~ 				$ret = FileMove($dir & "\" & $file, $dirNew & "\" & $text, 1 + 8)
				$ret = FileCopy($dir & "\" & $file, $dirNew & "\" & $text, 1 + 8)
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
			DirCopy($dir & "\" & $folders[$i], $dirNew & '\' & $folders[$i], 1)
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

Func _dedecodeString($string)
	$string = '0xd'
	ConsoleWrite(_StringReverse('32中文')& @CRLF)


;~ 	$string = StringToBinary($string)
	$string = StringMid($string, 3)
	$string = _StringReverse($string)
	ConsoleWrite($string & @CRLF)
EndFunc

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

Func _disableAll()
	GUICtrlSetState($btnDecryptFolder, $GUI_DISABLE)
	GUICtrlSetState($btnEncryptFolder, $GUI_DISABLE)
	GUICtrlSetState($btnDecryptFile, $GUI_DISABLE)
	GUICtrlSetState($btnEncryptFile, $GUI_DISABLE)
	GUICtrlSetState($btnDecryptString, $GUI_DISABLE)
	GUICtrlSetState($btnEncryptString, $GUI_DISABLE)
	GUICtrlSetState($btnClose, $GUI_DISABLE)
EndFunc   ;==>_disableAll

Func _enableAll()
	GUICtrlSetState($btnDecryptFolder, $GUI_ENABLE)
	GUICtrlSetState($btnEncryptFolder, $GUI_ENABLE)
	GUICtrlSetState($btnDecryptFile, $GUI_ENABLE)
	GUICtrlSetState($btnEncryptFile, $GUI_ENABLE)
	GUICtrlSetState($btnDecryptString, $GUI_ENABLE)
	GUICtrlSetState($btnEncryptString, $GUI_ENABLE)
	GUICtrlSetState($btnClose, $GUI_ENABLE)
EndFunc   ;==>_enableAll

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