#include <File.au3>

Dim $arr[1]
_FileReadToArray("d:\tmp\tg.txt", $arr)

$isSame = False
For $i = 1 To $arr[0]
	$row = $arr[$i]

	$name = _getName($row)
	If $isSame Then
		$type = ''
		$cotton = ''
		$color = ''
		$num = ''
		$place = ''
		If _getNeedAttension($row) Then
			ConsoleWrite('' & @TAB & $type & @TAB & $cotton & @TAB & $color & @TAB & $num & @TAB & $place & @TAB & $row & @CRLF)
		Else
			ConsoleWrite('' & @TAB & $type & @TAB & $cotton & @TAB & $color & @TAB & $num & @TAB & $place & @TAB & $row & @TAB & '**' & @CRLF)
		EndIf
	Else
		$type = _getType($row)
		$cotton = _needCotton($row)
		$color = _getColor($row)
		$num = _getNumber($row)
		$place = _getPlace($row)
		If _getNeedAttension($row) Then
			ConsoleWrite($name & @TAB & $type & @TAB & $cotton & @TAB & $color & @TAB & $num & @TAB & $place & @TAB & $row & @CRLF)
		Else
			ConsoleWrite($name & @TAB & $type & @TAB & $cotton & @TAB & $color & @TAB & $num & @TAB & $place & @TAB & $row & @TAB & '**' & @CRLF)
		EndIf
	EndIf

	If $i == $arr[0] Then
		$nextRow = ''
	Else
		$nextRow = $arr[$i + 1]
	EndIf
	$isSame = ($name == _getName($nextRow) Or $name == '')

Next

Func _getName(ByRef $row)
	$idx = StringInStr($row, '(', Default, -1)
	If $idx == 0 Then Return ''

	$idx2 = StringInStr($row, '/')
	If $idx2 == 0 Then Return ''

	$result = StringMid($row, $idx + 1, $idx2 - $idx - 1)
	$row = StringStripWS(StringLeft($row, $idx - 1), 1 + 2)
	Return $result
EndFunc   ;==>_getName

Func _getType($row)
	$idx = StringInStr($row, '101')
	If $idx <> 0 Then Return 'WX-101'

	$idx = StringInStr($row, '102')
	If $idx <> 0 Then Return 'WX-102'

	Return 'unkown'
EndFunc   ;==>_getType

Func _getPlace($row)
	$idx = StringInStr($row, '����')
	If $idx <> 0 Then Return '����'
	$idx = StringInStr($row, '2��')
	If $idx <> 0 Then Return '����'

	$idx = StringInStr($row, 'һ��')
	If $idx <> 0 Then Return 'һ��'
	$idx = StringInStr($row, '1��')
	If $idx <> 0 Then Return 'һ��'

	$idx = StringInStr($row, '����')
	If $idx <> 0 Then Return '����'

	$idx = StringInStr($row, '��ǿ')
	If $idx <> 0 Then Return '��ǽ��'
	$idx = StringInStr($row, '��ǽ')
	If $idx <> 0 Then Return '��ǽ��'
	$idx = StringInStr($row, '���N')
	If $idx <> 0 Then Return '��ǽ��'
	$idx = StringInStr($row, '��Ǿ')
	If $idx <> 0 Then Return '��ǽ��'

	$idx = StringInStr($row, '����')
	If $idx <> 0 Then Return '����'

	Return 'unkown'
EndFunc   ;==>_getPlace

Func _getColor($row)
	$idx = StringInStr($row, '��')
	If $idx <> 0 Then Return '��ɫ'
	$idx = StringInStr($row, '��')
	If $idx <> 0 Then Return '��ɫ'

	$idx = StringInStr($row, '��')
	If $idx <> 0 Then Return '��ɫ'

	$idx = StringInStr($row, '��')
	If $idx <> 0 Then Return '��ɫ'

	$idx = StringInStr($row, '��')
	If $idx <> 0 Then Return '����ɫ'

	Return 'unkown'
EndFunc   ;==>_getColor

Func _needCotton($row)
	$idx = StringInStr($row, '����')
	If $idx <> 0 Then Return '������'
	$idx = StringInStr($row, 'Ҫ����')
	If $idx <> 0 Then Return '������'
	Return ''
EndFunc   ;==>_needCotton

Func _getNumber($row)
	$idx = StringInStr($row, '�ĸ�')
	If $idx <> 0 Then Return '4'
	$idx = StringInStr($row, '4��')
	If $idx <> 0 Then Return '4'
	$idx = StringInStr($row, '4 ��')
	If $idx <> 0 Then Return '4'
	$idx = StringInStr($row, '+4')
	If $idx <> 0 Then Return '4'
	$idx = StringInStr($row, '��4')
	If $idx <> 0 Then Return '4'

	$idx = StringInStr($row, '����')
	If $idx <> 0 Then Return '3'
	$idx = StringInStr($row, '3��')
	If $idx <> 0 Then Return '3'
	$idx = StringInStr($row, '3 ��')
	If $idx <> 0 Then Return '3'
	$idx = StringInStr($row, '+3')
	If $idx <> 0 Then Return '3'
	$idx = StringInStr($row, '��3')
	If $idx <> 0 Then Return '3'

	$idx = StringInStr($row, '����')
	If $idx <> 0 Then Return '2'
	$idx = StringInStr($row, '����')
	If $idx <> 0 Then Return '2'
	$idx = StringInStr($row, '2��')
	If $idx <> 0 Then Return '2'
	$idx = StringInStr($row, '2 ��')
	If $idx <> 0 Then Return '2'
	$idx = StringInStr($row, '+2')
	If $idx <> 0 Then Return '2'
	$idx = StringInStr($row, '��2')
	If $idx <> 0 Then Return '2'

	$idx = StringInStr($row, 'һ��')
	If $idx <> 0 Then Return '1'
	$idx = StringInStr($row, '1��')
	If $idx <> 0 Then Return '1'
	$idx = StringInStr($row, '1 ��')
	If $idx <> 0 Then Return '1'
	$idx = StringInStr($row, '+1')
	If $idx <> 0 Then Return '1'
	$idx = StringInStr($row, '��1')
	If $idx <> 0 Then Return '1'

	Return 'unkown'
EndFunc   ;==>_getNumber

Func _getNeedAttension($row)
	$idx = StringInStr($row, '��')
	If $idx <> 0 Then Return False
	Return True
EndFunc





