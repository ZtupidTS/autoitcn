#include <File.au3>
#include <array.au3>

;~ Dim $arr[1]
;~ _FileReadToArray("d:\tmp\aaa.txt", $arr)

;~ Dim $lastName = 'anything1', $problems = ''
;~ Dim $sum1 = 0, $sum2 = 0
;~ For $i = 1 To $arr[0]
;~ 	$name = _getName($arr[$i])
;~ 	$type = _getType($arr[$i])
;~ 	$quantity = _getQuantity($arr[$i])
;~ 	$money = _getMondy($arr[$i])
;~ 	
;~ 	$sum2 += _getTypeMoney($type) * $quantity
;~ 	
;~ 	If $name <> $lastName  Then
;~ 		If $money <> '' Then
;~ 			If $sum1 <> $sum2 Then ConsoleWrite($name & ', ' & $sum2 & @CRLF)
;~ 			$sum2= 0
;~ 			$lastName = $name
;~ 		Else
;~ 			ContinueLoop
;~ 		EndIf
;~ 	Else
;~ 		If $money <> '' Then $sum1 = $money
;~ 	EndIf
;~ Next

Func _go()
	Send("^c")
	Sleep(200)
	$arr = StringSplit(ClipGet(), @CRLF)
	$sum = 0
	For $i = 1 To $arr[0]
		If $arr[$i] == '' Then ContinueLoop
		$name = _getName($arr[$i])
		$type = _getType($arr[$i])
		$quantity = _getQuantity($arr[$i])
		$sum += _getTypeMoney($type) * $quantity
	Next
	Send("{right}")
	Sleep(10)
	Send($sum)
EndFunc

HotKeySet("{space}", "_go")
While True
	Sleep(20000)
WEnd


Func _getTypeMoney($type)
	Switch $type
		Case '200g�ڴ�ͳ�ɿ���', '150g��ͳ�ɿ���'
			Return 29
		Case '500g��ڴ�ͳ�ɿ���', '250g��װ��Ʒ�ɿ���'
			Return 59
		Case '500g���ͳ�ɿ���'
			Return 67
		Case '250g���ʿ�ɿ���', '250g��Ʒ�ɿ���'
			Return 45
		Case '150g������װ��Ʒ�ɿ���'
			Return 39
		Case '500g��Ʒ�ɿ���'
			Return 79
		Case '100g���㾫Ʒ�ɿ���'
			Return 22
		Case '250g�ŵ��ɿ���'
			Return 42
		Case '500g��ŵ��ɿ���'
			Return 64
	EndSwitch
		
EndFunc

Func _getName(ByRef $row)
	$idx = StringInStr($row, @TAB)
	If $idx == 0 Then Return ''
	$value = StringStripWS(StringLeft($row, $idx), 3)
	$row = StringRight($row, StringLen($row) - $idx)
	Return $value
EndFunc   ;==>_getName

Func _getType(ByRef $row)
	$idx = StringInStr($row, @TAB)
	If $idx == 0 Then Return ''
	$value = StringStripWS(StringLeft($row, $idx), 3)
	$row = StringRight($row, StringLen($row) - $idx)
	Return $value
EndFunc

Func _getQuantity(ByRef $row)
	$idx = StringInStr($row, @TAB)
	If $idx == 0 Then Return ''
	$value = StringStripWS(StringLeft($row, $idx), 3)
	$row = StringRight($row, StringLen($row) - $idx)
	Return $value
EndFunc

Func _getMondy($row)
	$idx = StringInStr($row, @TAB, Default, -1)
	If $idx == 0 Then Return ''
	Return StringRight($row, StringLen($row) - $idx)
EndFunc


