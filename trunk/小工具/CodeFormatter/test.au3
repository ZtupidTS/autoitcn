;~ Opt("WinTitleMatchMode", 2)


HotKeySet("!s", "search")

While 1
	Sleep(200000)
WEnd

Func search()
	WinMenuSelectItem ("UEStudio", "", "����(&S)", "���ļ��в���(&I)")
	WinWaitActive("���ļ��в���", "����(&N):", 2)
	$selected = ControlCommand("���ļ��в���", "����(&N):", 1001, "GetSelected", "")
	ClipPut($selected)
	ControlSetText("���ļ��в���", "����(&N):", 1001, '"' & $selected & '"')
	ControlSend("���ļ��в���", "����(&N):", 1 ,"{enter}")
EndFunc
