#NoTrayIcon

While True
	$p = ProcessExists("ServMgr.exe")
	If $p == 0 Then
		ContinueLoop
	EndIf
	ProcessClose($p)
	Sleep(3600000)
WEnd


