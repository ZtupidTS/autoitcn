
;~ WinActivate("10.44.109.105:21099")
;~ For $i = 100 To 220
;~ 	MouseClick("left", 241, 83, 1, 0)
;~ 	WinWait("�½��û�")
;~ 	Send("thisisasuerwithalonglonglon" & $i)
;~ 	Sleep(500)
;~ 	Send("{enter}")
;~ 	WinWait("ȷ��")
;~ 	Send("{enter}")
;~ 	Sleep(1000)
;~ Next

WinActivate("�û���")
For $i = 100 To 220
	Send("thisisasuerwithalonglonglon" & $i)
	Sleep(500)
	Send("!a")
	Sleep(300)
Next
