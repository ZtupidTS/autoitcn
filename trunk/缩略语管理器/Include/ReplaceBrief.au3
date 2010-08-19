#include <Array.au3>
#include-once

Func _ReplaceBrief_createLink($html, $parentGUI)
	Local $i, $n, $res
	; 0: 替换开始位置, 1: 替换的字符串
	Local $replacement[1][2] = [[0, ""]]
	GUISetState(@SW_DISABLE, $parentGUI)
	ProgressOn("替换缩略语", "正在搜索...", "", Default, Default, 16)
	For $i = 1 To $data[0]
		$n = StringInStr($html, $data[$i], 1)
		While $n <> 0
			If Not _ReplaceBrief_need2CreateLink($html, $n) Then
				$n = StringInStr($html, $data[$i], 1, 1, $n + StringLen($data[$i]))
				ContinueLoop
			EndIf
			$replacement[0][0] += 1
			ReDim $replacement[$replacement[0][0] + 1][2]
			$replacement[$replacement[0][0]][0] = $n
			$replacement[$replacement[0][0]][1] = $data[$i]
			$n = StringInStr($html, $data[$i], 1, 1, $n + StringLen($data[$i]))
		WEnd
		ProgressSet(Int(($i/$data[0])*85), "正在处理 " & $data[$i])
	Next
	Local $tmpArr = $replacement, $j
	For $i = 1 To $replacement[0][0]
		For $j = 1 To $tmpArr[0][0]
			If $replacement[$i][1] == $tmpArr[$j][1] Then ContinueLoop
			If $replacement[$i][1] == "" Then ContinueLoop
			If StringInStr($tmpArr[$j][1], $replacement[$i][1], 1) And $tmpArr[$j][0] <= $replacement[$i][0] Then
				$replacement[$i][0] = -1
				$replacement[$i][1] = ""
			EndIf
		Next
		ProgressSet(Int(($i/$replacement[0][0])*11)+85, "正在剔除重复项...")
	Next
	ProgressSet(98, "正在排序...")
	_ArraySort($replacement, 1, 1, $replacement[0][0], 0)
;~ 	_ArrayDisplay($replacement)
	For $i = $replacement[0][0] To 1 Step -1
		If $replacement[$i][0] <> -1 Then ExitLoop
		_ArrayDelete($replacement, $i)
		$replacement[0][0] -= 1
	Next
;~ 	_ArrayDisplay($replacement)
	ProgressSet(99, "正在生成代码...")
	$html = _ReplaceBrief_replaceBrief($html, $replacement)
	ProgressSet(100, "完成。")
	Sleep(300)
	ProgressOff()
	GUISetState(@SW_ENABLE, $parentGUI)
	Return $html
EndFunc   ;==>_ReplaceBrief_createLink

Func _ReplaceBrief_need2CreateLink($html, $pos)
	Local $n = StringInStr($html, "<", Default, -1, $pos)
	Local $m1, $m2, $tag, $tags[1]
	While $n <> 0
		$m1 = StringInStr($html, " ", Default, 1, $n)
		$m2 = StringInStr($html, ">", Default, 1, $n)
		If $m2 >= $pos Then ; $pos 位于一对 <>中间，不需要替换了
			Return False
		EndIf
		If $m2 < $m1 Then $m1 = $m2
		$tag = StringLower(StringMid($html, $n + 1, $m1 - $n - 1))
		If $tag <> "br" And _
			$tag <> "p" And _
			$tag <> "img" Then
			_ArrayInsert($tags, 0, $tag)
		EndIf
		$n = StringInStr($html, "<", Default, -1, $n - 1)
	WEnd
	_ArrayDelete($tags, UBound($tags))
	_ReplaceBrief_removeInvalidTags($tags)
;~ 	_ArrayDisplay($tags, $pos)
	For $i = 0 To UBound($tags) - 1
		If $tags[$i] == "a" Or $tags[$i] == "head" Then Return False
	Next
	Return True
EndFunc   ;==>_ReplaceBrief_need2CreateLink

Func _ReplaceBrief_removeInvalidTags(ByRef $tags)
	Local $i, $n1 = 0, $n2 = 0, $isEnd = True
	While 1
		$isEnd = True
		For $i = 0 To UBound($tags) - 1
			If $tags[$i] <> "" Then
				$n1 = $n2
				$n2 = $i
			EndIf
			If StringLeft($tags[$i], 1) <> "/" Then ContinueLoop
			If $tags[$n2] == "/" & $tags[$n1] Then
				$tags[$n1] = ""
				$tags[$n2] = ""
			EndIf
			$isEnd = False
		Next
		If $isEnd Then ExitLoop
	WEnd
EndFunc   ;==>_do

Func _ReplaceBrief_replaceBrief($html, $replacement)
	Local $i
	For $i = 1 To $replacement[0][0]
		$html = StringLeft($html, $replacement[$i][0] - 1) & _
			'<a title="' & IniRead($DATA_INI, $replacement[$i][1], 'brief', $replacement[$i][1]) & _
			'" href="../' & $replacement[$i][1] & '/' & $replacement[$i][1] & '.html">' & $replacement[$i][1] & '</a>' & _
			StringRight($html, StringLen($html) - StringLen($replacement[$i][1]) - $replacement[$i][0] + 1)
	Next
	Return $html
EndFunc   ;==>_ReplaceBrief_replaceBrief
