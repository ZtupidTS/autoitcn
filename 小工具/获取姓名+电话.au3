#include 'file.au3'
#include 'array.au3'

Opt('MustDeclareVars', 1)

;~ _analyseNames()
_getPhoneFromFile('d:\tmp\tg.txt')
;~ WinClose('ϵͳ��ʾ', 'û�з��������ĺ�����Ϣ��')

Func _getPhoneFromFile($file)
	If Not WinExists('��������', '������') Then
		MsgBox(16, "�绰��", "���������ġ�����Ի��򲻴��ڣ����ֹ�������")
		Return
	EndIf

	Local $arr[1]
	Local $phone, $name
	_FileReadToArray($file, $arr)
	For $i = 1 To $arr[0]
		$arr[$i] = _adjustName($arr[$i])
		If $arr[$i] == '' Then ContinueLoop
		ControlSetText('��������', '������', 1001, $arr[$i])
		ControlSend('��������', '������', 1001, '{end}{enter}')
		$phone = _waitAndGetData()
		If $phone <> '' Then
			$name = StringMid($phone, 2, StringInStr($phone, ')') - 2)
			$phone = StringMid($phone, StringInStr($phone, '-', Default, -1) + 1, 11)
		Else
			$name = $arr[$i]
			$phone = '�鲻��'
		EndIf

		ConsoleWrite('index=' & $i & ', name=' & $name & ', phone=' & $phone & @CRLF)
		Sleep(1000)
	Next
EndFunc   ;==>_getPhoneFromFile

; ���ڹ����е���6λ�ģ��е���8λ�ģ���Ҫȫ������Ϊ8λ��
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
	Local $i, $data, $orgData = ControlGetText('��������', '������', 1001)
	For $i = 1 To 200
		Sleep(100)
		$data = ControlGetText('��������', '������', 1001)
		If $data == '' Or WinExists('ϵͳ��ʾ', 'û�з��������ĺ�����Ϣ��') Then
			Sleep(200)
			WinClose('ϵͳ��ʾ', 'û�з��������ĺ�����Ϣ��')
			Return ''
		EndIf
		If $data <> $orgData Then
			Return $data
		EndIf
	Next
	Return ''
EndFunc   ;==>_waitAndGetData

Func _getPhone()
	If Not WinExists('��������', '������') Then
		MsgBox(16, "�绰��", "���������ġ�����Ի��򲻴��ڣ����ֹ�������")
		Return
	EndIf

	Local $sectinos = IniReadSectionNames('F:\�ҵĹ�����¼\000 COMM\����\orz.ini')
	Local $from = IniRead('F:\�ҵĹ�����¼\000 COMM\����\orz.ini', 'main', 'from', 1)
	;Ϊ�˰�ȫ�����ÿ��ͻ�ȡ30���绰����
	Local $to = $from + 200
	Local $phone, $name
	For $i = $from To $to
		ControlSetText('��������', '������', 1001, $sectinos[$i])
		ControlSend('��������', '������', 1001, '{end}{enter}')
		$phone = _waitAndGetData()
		If $phone <> '' Then
			$name = StringMid($phone, 2, StringInStr($phone, ')') - 2)
			$phone = StringMid($phone, StringInStr($phone, '-', Default, -1) + 1, 11)
		Else
			$name = ''
			$phone = '�鲻��'
		EndIf
		IniWrite('F:\�ҵĹ�����¼\000 COMM\����\orz.ini', $sectinos[$i], 'name', $name)
		IniWrite('F:\�ҵĹ�����¼\000 COMM\����\orz.ini', $sectinos[$i], 'phone', $phone)

		ConsoleWrite('index=' & $i & ', name=' & $name & ', phone=' & $phone & @CRLF)
		Sleep(1000)
	Next
	IniWrite('F:\�ҵĹ�����¼\000 COMM\����\orz.ini', 'main', 'from', $to + 1)
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
;~ 		If (IniRead('F:\�ҵĹ�����¼\000 COMM\����\orz.ini', $id, 'phone', '___not_exist___') == '___not_exist___') Then
;~ 			IniWrite('F:\�ҵĹ�����¼\000 COMM\����\orz.ini', $id, 'name', $name)
;~ 			IniWrite('F:\�ҵĹ�����¼\000 COMM\����\orz.ini', $id, 'phone', 'unkown')
;~ 		EndIf
;~ 	Next
;~ EndFunc   ;==>_analyseNames

;~ Func _getName($row)
;~ 	Local $idx = StringInStr($row, '(', Default, -1)
;~ 	If $idx == 0 Then Return ''

;~ 	Local $idx2 = StringInStr($row, '/', Default, -2)
;~ 	If $idx2 == 0 Then Return ''

;~ 	Local $name = StringMid($row, $idx + 1, $idx2 - $idx - 1)

;~ 	;Ϊ���ż���00
;~ 	$name = StringLeft($name, StringLen($name) - 5) & '00' & StringRight($name, 5)
;~ 	Return $name
;~ EndFunc   ;==>_getName

;~ Func _test()
;~ 	Dim $arr[1]
;~ 	_FileReadToArray('d:\tmp\names.txt', $arr)

;~ 	For $i = 1 To $arr[0]
;~ 		IniWrite('F:\�ҵĹ�����¼\000 COMM\����\orz.ini', $arr[$i], 'name', 'unkown')
;~ 		IniWrite('F:\�ҵĹ�����¼\000 COMM\����\orz.ini', $arr[$i], 'phone', 'unkown')
;~ 	Next
;~ EndFunc   ;==>_test