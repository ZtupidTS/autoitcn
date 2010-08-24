#include <array.au3>
#include <Date.au3>
#include <String.au3>
#include <GUIConstantsEx.au3>

#AutoIt3Wrapper_icon=icon.ico

#NoTrayIcon
Opt('MustDeclareVars', 1)

Global Const $THE_PASSWORD = 'CHENXUCC@GCLEAR.COM'

Local $Form = GUICreate("���ܽ��ܹ�����", 203, 137)
Local $btnEncryptFolder = GUICtrlCreateButton("�����ļ���", 8, 8, 91, 25)
Local $btnDecryptFolder = GUICtrlCreateButton("�����ļ���", 104, 8, 91, 25)
Local $btnEncryptFile = GUICtrlCreateButton("�����ļ�", 8, 40, 91, 25)
Local $btnDecryptFile = GUICtrlCreateButton("�����ļ�", 104, 40, 91, 25)
Local $btnEncryptString = GUICtrlCreateButton("�����ַ���", 8, 72, 91, 25)
Local $btnDecryptString = GUICtrlCreateButton("�����ַ���", 104, 72, 91, 25)
Local $btnClose = GUICtrlCreateButton("�ر�", 8, 104, 188, 25)
GUISetState(@SW_SHOW)

While 1
	Local $nMsg = GUIGetMsg()
	Local $path, $file, $files, $string, $pos
	Select
		Case $nMsg = $btnEncryptFolder
			$path = FileSelectFolder('ѡ��һ���ļ���', '', 2, IniRead('�ļ��������.ini', 'main', 'path', ''), $Form)
			_writeLog('ѡ����ļ����� ' & $path)
			If $path <> '' Then
				IniWrite('�ļ��������.ini', 'main', 'path', $path)
				If FileExists($path) Then
					_disableAll()
					_make($path, True)
					_enableAll()
				Else
					MsgBox(48, "�ļ��������", "��ѡ��һ���Ѿ����ڵ��ļ��С�", Default, $Form)
				EndIf
			EndIf
		Case $nMsg = $btnDecryptFolder
			$path = FileSelectFolder('ѡ��һ���ļ���', '', 2, IniRead('�ļ��������.ini', 'main', 'path', ''), $Form)
			_writeLog('ѡ����ļ����� ' & $path)
			If $path <> '' Then
				IniWrite('�ļ��������.ini', 'main', 'path', $path)
				If FileExists($path) Then
					_disableAll()
					_make($path, False)
					_enableAll()
				Else
					MsgBox(48, "�ļ��������", "��ѡ��һ���Ѿ����ڵ��ļ��С�", Default, $Form)
				EndIf
			EndIf
		Case $nMsg = $btnEncryptFile Or $nMsg = $btnDecryptFile
			$files = FileOpenDialog('ѡ��һ���ļ�', '', '�����ļ� (*.*)', 7, '', $Form)
			_writeLog('ѡ����ļ��� ' & $files)
			If $files <> '' Then
				_disableAll()
				$files = StringSplit($files, '|')
				If Not IsArray($files) Then
					MsgBox(48, "�ļ��������", "ѡ����ļ������������ǷǷ��ġ�", Default, $Form)
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
							_writeLog("--->  �ļ��Ѿ����ܣ������޷��������ļ� " & $files[1])
							MsgBox(48, "�ļ��������", "�ļ��Ѿ����ܣ������޷��������ļ� " & $files[1], Default, $Form)
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
							_writeLog("--->  �ļ��Ѿ����ܣ������޷��������ļ� " & $files[1] & '\' & $files[$i])
							MsgBox(48, "�ļ��������", "�ļ��Ѿ����ܣ������޷��������ļ� " & $files[1] & '\' & $files[$i], Default, $Form)
						EndIf
					Next
				EndIf
				_enableAll()
			EndIf
		Case $nMsg = $btnEncryptString
			$pos = WinGetPos("���ܽ��ܹ�����", '�ر�')
			$string = InputBox('�����ַ���', '����һ���ַ���', '', '', 200, 80, _
					($pos[2] - 200) / 2 + $pos[0], ($pos[3] - 100) / 2 + $pos[1], Default, $Form)
			If $string <> '' Then MsgBox(64, "�ļ��������", "���ܺ���ַ�����" & @CRLF & _encodeString($string), Default, $Form)
		Case $nMsg = $btnDecryptString
			$pos = WinGetPos("���ܽ��ܹ�����", '�ر�')
			$string = InputBox('�����ַ���', '����һ���ַ���', '', '', 200, 80, _
					($pos[2] - 200) / 2 + $pos[0], ($pos[3] - 100) / 2 + $pos[1], Default, $Form)
			If $string <> '' Then MsgBox(64, "�ļ��������", "���ܺ���ַ�����" & @CRLF & _decodeString($string), Default, $Form)
		Case $nMsg = $GUI_EVENT_CLOSE
			Exit
		Case $nMsg = $btnClose
			Exit
	EndSelect
WEnd

Func _make($dir, $isEncrypt)
	If FileExists($dir & '_bak') Then
		Local $iMsgBoxAnswer = MsgBox(292, "�ļ��������", "�ļ��� " & $dir & '_bak' & " �Ѿ����ڣ��Ƿ�ɾ����")
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
				_writeLog('--->  �������ļ�����̫�����޷��ƶ��ļ��� ' & $dirNew & "\" & $text & ', source=' & $dir & "\" & $file)
				$file = _renameFile($file, $dir)

				If $isEncrypt Then
					$text = _encodeString($file)
				Else
					$text = _decodeString($file)
				EndIf
				_writeLog('--->  �Ѿ��������ļ����µ��ļ����� ' & $dir & "\" & $file & ' �µ�Ŀ�ĵ��� ' & $dirNew & '\' & $text)
;~ 				$ret = FileMove($dir & "\" & $file, $dirNew & "\" & $text, 1 + 8)
				$ret = FileCopy($dir & "\" & $file, $dirNew & "\" & $text, 1 + 8)
				If $ret == 0 Then
					MsgBox(48, "�ļ��������", "�ļ�������̫���ˣ��Ѿ������޸��ļ����ٱ��룬������Ȼ�޷��ƶ��ļ���" & @CRLF & _
							"����һ�����صĴ��󣬱����򼴽��˳���")
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
	ConsoleWrite(_StringReverse('32����')& @CRLF)


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
	_writeLog('--->  �������ļ� ԭ���� ' & $path & '\' & $file & ' ��Ϊ ' & $path & '\' & $newFile)

	If FileExists($path & '\' & $newFile) Then
		MsgBox(64, "�ļ��������", '�����������ļ� ԭ���� ' & @CRLF & _
				$path & '\' & $file & @CRLF & _
				' ��Ϊ ' & $path & '\' & $newFile & @CRLF & _
				'����Ŀ���ļ��Ѿ����ڣ������������ǣ���ش�˶Ի���֮ǰ�����ݴ��ļ�')
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
	Local $file = @ScriptDir & '\�ļ��������.log'

	FileWrite($file, $message)
	ConsoleWrite($message)
EndFunc   ;==>_writeLog