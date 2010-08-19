#include 'file.au3'
#include 'array.au3'

Opt('MustDeclareVars', 1)

;~ _analyseNames()
_getPhoneFromFile('d:\tmp\tg.txt')
;~ WinClose('系统提示', '没有符合条件的号码信息！')

Func _getPhoneFromFile($file)
	If Not WinExists('短信中心', '收信人') Then
		MsgBox(16, "电话本", "“短信中心”这个对话框不存在，请手工打开它。")
		Return
	EndIf

	Local $arr[1]
	Local $phone, $name
	_FileReadToArray($file, $arr)
	For $i = 1 To $arr[0]
		$arr[$i] = _adjustName($arr[$i])
		If $arr[$i] == '' Then ContinueLoop
		ControlSetText('短信中心', '收信人', 1001, $arr[$i])
		ControlSend('短信中心', '收信人', 1001, '{end}{enter}')
		$phone = _waitAndGetData()
		If $phone <> '' Then
			$name = StringMid($phone, 2, StringInStr($phone, ')') - 2)
			$phone = StringMid($phone, StringInStr($phone, '-', Default, -1) + 1, 11)
		Else
			$name = $arr[$i]
			$phone = '查不到'
		EndIf

		ConsoleWrite('index=' & $i & ', name=' & $name & ', phone=' & $phone & @CRLF)
		Sleep(1000)
	Next
EndFunc   ;==>_getPhoneFromFile

; 由于工号有的是6位的，有的是8位的，需要全部处理为8位的
Func _adjustName($name)
	Local $arr = StringSplit(StringStripWS($name, 3), '')
	For $i = 1 To $arr[0]
		If $arr[$i] == '0' Or _
				$arr[$i] == '1' Or _
				$arr[$i] == '2' Or _
				$arr[$i] == '3' Or _
				$arr[$i] == '4' Or _
				$arr[$i] == '5' Or _
				$arr[$i] == '6' Or _
				$arr[$i] == '7' Or _
				$arr[$i] == '8' Or _
				$arr[$i] == '9' Then
			ExitLoop
		EndIf
	Next
	$i -= 1
	Local $code = StringRight($name, StringLen($name) - $i )
	$name = StringLeft($name, $i)
	If StringLen($code) == 6 Then
		$code = StringLeft($code, 1) & '00' & StringRight($code, 5)
	EndIf
	return $name & $code
EndFunc   ;==>_adjustName

Func _waitAndGetData()
	Local $i, $data, $orgData = ControlGetText('短信中心', '收信人', 1001)
	For $i = 1 To 200
		Sleep(100)
		$data = ControlGetText('短信中心', '收信人', 1001)
		If $data == '' Or WinExists('系统提示', '没有符合条件的号码信息！') Then
			Sleep(200)
			WinClose('系统提示', '没有符合条件的号码信息！')
			Return ''
		EndIf
		If $data <> $orgData Then
			Return $data
		EndIf
	Next
	Return ''
EndFunc   ;==>_waitAndGetData

Func _getPhone()
	If Not WinExists('短信中心', '收信人') Then
		MsgBox(16, "电话本", "“短信中心”这个对话框不存在，请手工打开它。")
		Return
	EndIf

	Local $sectinos = IniReadSectionNames('F:\我的工作记录\000 COMM\资料\orz.ini')
	Local $from = IniRead('F:\我的工作记录\000 COMM\资料\orz.ini', 'main', 'from', 1)
	;为了安全起见，每天就获取30个电话号码
	Local $to = $from + 200
	Local $phone, $name
	For $i = $from To $to
		ControlSetText('短信中心', '收信人', 1001, $sectinos[$i])
		ControlSend('短信中心', '收信人', 1001, '{end}{enter}')
		$phone = _waitAndGetData()
		If $phone <> '' Then
			$name = StringMid($phone, 2, StringInStr($phone, ')') - 2)
			$phone = StringMid($phone, StringInStr($phone, '-', Default, -1) + 1, 11)
		Else
			$name = ''
			$phone = '查不到'
		EndIf
		IniWrite('F:\我的工作记录\000 COMM\资料\orz.ini', $sectinos[$i], 'name', $name)
		IniWrite('F:\我的工作记录\000 COMM\资料\orz.ini', $sectinos[$i], 'phone', $phone)

		ConsoleWrite('index=' & $i & ', name=' & $name & ', phone=' & $phone & @CRLF)
		Sleep(1000)
	Next
	IniWrite('F:\我的工作记录\000 COMM\资料\orz.ini', 'main', 'from', $to + 1)
EndFunc   ;==>_getPhone

;~ Func _analyseNames()
;~ 	Local $arr[1]
;~ 	_FileReadToArray('d:\tmp\tg.txt', $arr)
;~ 	Local $file = FileRead('d:\tmp\names.txt')

;~ 	For $i = 1 To $arr[0]
;~ 		Local $name = _getName($arr[$i])
;~ 		If $name == '' Then ContinueLoop
;~ 		Local $id = StringRight($name, 8)
;~ 		If StringInStr($file, $id) Then ContinueLoop

;~ 		ConsoleWrite('name=' & $name & @CRLF)
;~ 		If (IniRead('F:\我的工作记录\000 COMM\资料\orz.ini', $id, 'phone', '___not_exist___') == '___not_exist___') Then
;~ 			IniWrite('F:\我的工作记录\000 COMM\资料\orz.ini', $id, 'name', $name)
;~ 			IniWrite('F:\我的工作记录\000 COMM\资料\orz.ini', $id, 'phone', 'unkown')
;~ 		EndIf
;~ 	Next
;~ EndFunc   ;==>_analyseNames

;~ Func _getName($row)
;~ 	Local $idx = StringInStr($row, '(', Default, -1)
;~ 	If $idx == 0 Then Return ''

;~ 	Local $idx2 = StringInStr($row, '/', Default, -2)
;~ 	If $idx2 == 0 Then Return ''

;~ 	Local $name = StringMid($row, $idx + 1, $idx2 - $idx - 1)

;~ 	;为工号加上00
;~ 	$name = StringLeft($name, StringLen($name) - 5) & '00' & StringRight($name, 5)
;~ 	Return $name
;~ EndFunc   ;==>_getName

;~ Func _test()
;~ 	Dim $arr[1]
;~ 	_FileReadToArray('d:\tmp\names.txt', $arr)

;~ 	For $i = 1 To $arr[0]
;~ 		IniWrite('F:\我的工作记录\000 COMM\资料\orz.ini', $arr[$i], 'name', 'unkown')
;~ 		IniWrite('F:\我的工作记录\000 COMM\资料\orz.ini', $arr[$i], 'phone', 'unkown')
;~ 	Next
;~ EndFunc   ;==>_test