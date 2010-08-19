Func countChineseChar($s)
	Local $a = StringSplit($s, "")
	Local $iNonLatin = 0
	For $i = 1 To $a[0]
		If AscW($a[$i]) >= 0x250 Then  $iNonLatin += 1
	Next
	Return $iNonLatin
EndFunc

