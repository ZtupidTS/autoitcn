#include-once

Global $_MAX_MASKED_PASSWORD_LENGTH = 128
Func _code($str = "")
	Local $len = StringLen($str)
	Local $maxPasswordLen = $_MAX_MASKED_PASSWORD_LENGTH
	If $len == 0 Or $len > $maxPasswordLen / 2 Then Return $str
	
	Local $a = StringSplit($str, "")
	For $i = 1 To $a[0]
		If AscW($a[$i]) >= 0x250 Then Return $str
	Next
	
	Local $num = Random(0, 0xbf, 1)
	Local $pwd = Chr(Random(33, 126, 1))
	$pwd = $pwd & Chr(Random(33, 126, 1))
	$pwd = $pwd & Hex($num, 2)
	$pwd = $pwd & Chr(Random(33, 126, 1))
	$pwd = $pwd & Chr(Random(33, 126, 1))
	$pwd = $pwd & Hex($num + $len, 2)
	$pwd = $pwd & Chr(Random(33, 126, 1))
	$pwd = $pwd & Chr(Random(33, 126, 1))
	Local $mask = Random(0, 93, 1)
	$pwd = $pwd & Hex($mask, 2)
	$num = Int($maxPasswordLen / $len)
	Local $j
	For $j = 1 To $len
		For $i = 1 To $num - 2
			$pwd = $pwd & Chr(Random(33, 126, 1))
;~ 			$pwd = $pwd & "_"
		Next
		$pwd = $pwd & Hex(Asc($a[$j]) + $mask, 2)
	Next
	For $i = $num * $len + 1 To $maxPasswordLen
		$pwd = $pwd & Chr(Random(33, 126, 1))
;~ 		$pwd = $pwd & "_"
	Next
	Return $pwd
EndFunc

Func _decode($str = "")
	Local $maxPasswordLen = $_MAX_MASKED_PASSWORD_LENGTH
	If StringLen($str) <> $maxPasswordLen + 12 Then Return $str
	Local $n1 = StringMid($str, 3, 2)
	Local $n2 = StringMid($str, 7, 2)
	Local $len = ("0x" & $n2) - ("0x" & $n1)
	Local $mask = "0x" & StringMid($str, 11, 2)
	If $len <= 0 Then Return $str
	Local $i
	Local $n = Int($maxPasswordLen / $len)
	Local $pwd = ""
	$str = StringRight($str, $maxPasswordLen)
	For $i = 1 To $len
		$pwd = $pwd & Chr(("0x" & StringRight(StringMid($str, ($n * ($i - 1) + 1), $n), 2)) - $mask)
	Next
	Return $pwd
EndFunc

