#include <A3LScreenCap.au3>
Global $SPLITED_COUNT = 16
Global $baseChecksum[ $SPLITED_COUNT ][ $SPLITED_COUNT ]
Global $WIDTH_STEP = @DesktopWidth / $SPLITED_COUNT
Global $HEIGHT_STEP = @DesktopHeight / $SPLITED_COUNT

getBaseChecksum()
AdlibEnable("check", 1000)

While 1
	Sleep(200000)
WEnd


Func check()
	Local $sum = -1
	For $i = 0 To $SPLITED_COUNT - 1 ; heigh
		For $j = 0 To $SPLITED_COUNT - 1 ; width
			$sum = PixelChecksum($i * $WIDTH_STEP, $j * $HEIGHT_STEP, _
					($i + 1) * $WIDTH_STEP, ($j + 1) * $HEIGHT_STEP)
			If ($baseChecksum[$j][$i] == $sum) Then
				ContinueLoop
			EndIf
			$baseChecksum[$j][$i] = $sum
			_ScreenCap_Capture("E:\AutoItWork\RemoteControl\byPicture\" & Hex($j) & Hex($i) & ".gif", _
				$i * $WIDTH_STEP, $j * $HEIGHT_STEP, ($i + 1) * $WIDTH_STEP, ($j + 1) * $HEIGHT_STEP)
		Next
	Next
EndFunc

Func getBaseChecksum()
	For $i = 0 To $SPLITED_COUNT - 1 ; heigh
		For $j = 0 To $SPLITED_COUNT - 1 ; width
			$baseChecksum[$j][$i] = PixelChecksum($i * $WIDTH_STEP, _
				$j * $HEIGHT_STEP, ($i + 1) * $WIDTH_STEP, ($j + 1) * $HEIGHT_STEP)
		Next
	Next
EndFunc








;~ $str = ""
;~ For $i = 0 To $SPLITED_COUNT - 1 ; heigh
;~ 	For $j = 0 To $SPLITED_COUNT - 1 ; width
;~ 		$file1 = FileOpen("E:\AutoItWork\RemoteControl\byPicture\1\gif" & $j & $i & ".gif", 16)
;~ 		$file2 = FileOpen("E:\AutoItWork\RemoteControl\byPicture\2\gif" & $j & $i & ".gif", 16)
;~ 		; Read in 1 character at a time until the EOF is reached
;~ 		While 1
;~ 			$chars1 = FileRead($file1)
;~ 			If @error = -1 Then ExitLoop
;~ 			$chars2 = FileRead($file2)
;~ 			If @error = -1 Then ExitLoop
;~ 			If $chars1 <> $chars2 Then
;~ 				$str = $str & "gif" & $j & $i & ".gif" & @CRLF
;~ 				ExitLoop
;~ 			EndIf
;~ 			
;~ 		Wend

;~ 		FileClose($file1)
;~ 		FileClose($file2)
;~ 	Next
;~ Next
;~ ClipPut($str)
;~ MsgBox(0, "found different file: ", $str)
;~ Exit


;~ For $i = 0 To $SPLITED_COUNT - 1 ; heigh
;~ 	For $j = 0 To $SPLITED_COUNT - 1 ; width
;~ 		_ScreenCap_Capture("E:\AutoItWork\RemoteControl\byPicture\gif" & $j & $i & ".gif", _
;~ 			$i * $WIDTH_STEP, $j * $HEIGHT_STEP, ($i + 1) * $WIDTH_STEP, ($j + 1) * $HEIGHT_STEP)
;~ 	Next
;~ Next
