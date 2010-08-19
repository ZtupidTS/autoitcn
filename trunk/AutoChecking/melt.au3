#include <file.au3>
#include <array.au3>

Opt("MustDeclareVars", True)

;~ ConsoleWrite(10/23 & @CRLF)
;~ Exit

Global Const $APP_NAME = "AC30 Daemon Tool"
Global Const $CHAR_MODEL_INI = @ScriptDir & "\conf\chars.ini"

Global $charModel = _getCharModel()

Local $sections = IniReadSectionNames("log.ini")
Local $true = 0, $false = 0
For $i = 1 To $sections[0]
	Local $txtArr = _getPicText($sections[$i])
;~ 	MsgBox(0, "", _getValidateCode($txtArr))
	Local $code = _getValidateCode($txtArr)
	Local $res = $code == $sections[$i]
	If $res Then
		$true += 1
	Else
		$false += 1
	EndIf
	ConsoleWrite($code & " v.s. " & $sections[$i] & " : " & ($res) & @CRLF)
;~ 	ExitLoop
Next
ConsoleWrite("$true=" & $true & " $false=" & $false & @CRLF)

Func _getValidateCode($txtArr)
	Local $point = _getFirstLeftTopPoin($txtArr, "*",0, 4, 61, 16)
	If Not IsArray($point) Then Return "error"
	
	Local $char[5], $i = 0, $length
	For $i = 0 To 4
		$char[$i] = _getOneValidateCode($txtArr, $point[1])
		$length = IniRead(@ScriptDir & "\conf\chars.ini", $char[$i], "length", "10")
;~ 		ConsoleWrite("$char[$i]=" & $char[$i] & " $point[0]=" & $point[0] & " $point[1]=" & $point[1] & " $length=" & $length & @CRLF)
		_melt($txtArr, $point, $length)
		$point = _getFirstLeftTopPoin($txtArr, "*", $point[1] + $length, 4, 12, 16)
	Next
	Local $code = ""
	For $i = 0 To 4
		$code &= $char[$i]
	Next
	ConsoleWrite($code & @CRLF)
	Return $code
EndFunc

; $point 数组，表示从这个点开始融化
; $length 是当前字符的宽度，从配置文件中读取
Func _melt(ByRef $txtArr, $point, $length)
	$txtArr[$point[0]][$point[1]] = "_"
	$txtArr[$point[0]][$point[1] + 1] = "1"
	$txtArr[$point[0] + 1][$point[1]] = "1"
	Local $p = _getFirstLeftTopPoin($txtArr, "1", $point[1], 4, $length, 16)
	While IsArray($p)
		$txtArr[$p[0]][$p[1]] = "_"
		If $p[1] + 1 < $point[1] + $length And _
			$txtArr[$p[0]][$p[1] + 1] == "*" Then $txtArr[$p[0]][$p[1] + 1] = "1"
		If $txtArr[$p[0] + 1][$p[1]] == "*" Then $txtArr[$p[0] + 1][$p[1]] = "1"
		If $p[1] > $point[1] And _
			$txtArr[$p[0]][$p[1] - 1] == "*" Then $txtArr[$p[0]][$p[1] - 1] = "1"
		If $txtArr[$p[0] - 1][$p[1]] == "*" Then $txtArr[$p[0] - 1][$p[1]] = "1"
		$p = _getFirstLeftTopPoin($txtArr, "1", $point[1], 4, $length, 16)
;~ 		_printTxtArr($txtArr)
;~ 		MsgBox(0, "paused", "paused")
	WEnd
;~ 	_printTxtArr($txtArr)
EndFunc

Func _getFirstLeftTopPoin($txtArr, $type, $left, $top, $width, $heigh)
;~ 	ConsoleWrite("$type=" & $type & " $left=" & $left & " $top=" & $top & " $width=" & $width & " $heigh=" & $heigh)
	Local $i, $j
	If $left > 0 Then $left -= 1
	For $j = $left To $width + $left - 1
		For $i = $top To $heigh - 1
			If $j > 60 Then Return
			If $txtArr[$i][$j] == $type Then
				Dim $point[2] = [$i, $j]
;~ 				ConsoleWrite(" $i=" & $i & " $j=" & $j & @CRLF)
				Return $point
			EndIf
		Next
	Next
	Return
;~ 	ConsoleWrite(" $i=* $j=*" & @CRLF)
EndFunc

Func _getOneValidateCode($txtArr, $col)
	Local $char[5][2], $oneChar = "", $count = 0, $sum = 0, $rate = 0
	Local $i, $j, $k
	For $i = 1 To 18
		For $j = 4 To 15
			For $k = $col To $col + 11
				If $txtArr[$j][$k] == $charModel[$i][$j - 3][$k - $col] Then
					$count += 1
				EndIf
				If $charModel[$i][$j - 3][$k - $col] <> "" Then
					$sum += 1
				EndIf
			Next
		Next
		If $count/$sum > $rate Then
			$rate = $count/$sum
			$oneChar = $charModel[$i][0][0]
		EndIf
		$count = 0
		$sum = 0
	Next
	ConsoleWrite($oneChar & @TAB & $rate & @CRLF)
	Return $oneChar
;~ 	MsgBox(0, $rate, $oneChar)
EndFunc

; 放在初始化里，不需要每次都读
Func _getCharModel()
	Local $sections = IniReadSectionNames($CHAR_MODEL_INI)
	If @error Or Not IsArray($sections) Or $sections[0] == 0 Then
		;MsgBox features: Title=Yes, Text=Yes, Buttons=OK, Icon=Critical, Modality=Task Modal
		MsgBox(8208, $APP_NAME, "读取字模配置文件chars.ini失败！")
		Exit
	EndIf
	Local $model[$sections[0] + 1][13][12], $i, $j, $k, $line
	$model[0][0][0] = $sections[0]
	For $i = 1 To $sections[0]
		For $j = 1 To 12
			$line = IniRead($CHAR_MODEL_INI, $sections[$i], "line" & $j, "000000000000")
			$line = StringSplit($line, "")
			$model[$i][0][0] = $sections[$i]
			For $k = 1 To $line[0]
				$model[$i][$j][$k - 1] = $line[$k]
			Next
		Next
	Next
;~ _print($model)
	Return $model
EndFunc

Func _getPicText($code)
;~ 	Local $txt = StringReplace(FileRead(@ScriptDir & "\conf\pic-txt.txt"), " ", "0")
	Local $txt = _getPicText2($code)
	Local $line = StringSplit($txt, @CRLF, 1)
	If @error Then $line = StringSplit($txt, @LF) ; Unix @LF is next most common
	If @error Then $line = StringSplit($txt, @CR) ; Finally try Mac @CR
	$line[0] = $line[0] - 1
	Local $col = StringLen($line[1])
	If $col >= 61 Then $col = 61
	Dim $txtArr[20][$col]
	Local $i, $j, $arr
	For $i = 1 To 20
		$arr = StringSplit($line[$i], "")
;~ 	_ArrayDisplay($arr)
		For $j = 1 To $col
			$txtArr[$i - 1][$j - 1] = $arr[$j]
		Next
	Next
;~ 	_ArrayDisplay($txtArr)
	Return $txtArr
EndFunc

Func _getPicText2($code)
	Local $txt = ""
	$txt &= "                                                               " & @CRLF & _
			"                                                               " & @CRLF & _
			"                                                               " & @CRLF & _
			"                                                               " & @CRLF & _
			StringReplace(IniRead("log.ini", $code, "txt", ""), "_CRLF_", @CRLF) & @CRLF & _
			"                                                               " & @CRLF & _
			"                                                               " & @CRLF & _
			"                                                               " & @CRLF & _
			"                                                               "
	Return $txt
EndFunc

Func _printTxtArr($txtArr)
	Local $i, $j
	For $i = 0 To 19
		For $j = 0 To 60
			ConsoleWrite($txtArr[$i][$j])
		Next
		ConsoleWrite(@CRLF)
	Next
	ConsoleWrite(@CRLF)
	ConsoleWrite(@CRLF)
EndFunc

Func _printModel($model)
	For $i = 1 To 18
		For $j = 1 To 13
			For $k = 1 To 12
				ConsoleWrite($model[$i][$j - 1][$k - 1])
			Next
			ConsoleWrite(@CRLF)
		Next
	ConsoleWrite(@CRLF)
	Next
EndFunc
