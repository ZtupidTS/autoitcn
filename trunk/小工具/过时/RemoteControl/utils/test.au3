
;~ WinActivate("10.44.109.105:21099")
;~ For $i = 100 To 220
;~ 	MouseClick("left", 241, 83, 1, 0)
;~ 	WinWait("新建用户")
;~ 	Send("thisisasuerwithalonglonglon" & $i)
;~ 	Sleep(500)
;~ 	Send("{enter}")
;~ 	WinWait("确认")
;~ 	Send("{enter}")
;~ 	Sleep(1000)
;~ Next

WinActivate("用户名")
For $i = 100 To 220
	Send("thisisasuerwithalonglonglon" & $i)
	Sleep(500)
	Send("!a")
	Sleep(300)
Next
