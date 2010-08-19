;~ Opt("WinTitleMatchMode", 2)


HotKeySet("!s", "search")

While 1
	Sleep(200000)
WEnd

Func search()
	WinMenuSelectItem ("UEStudio", "", "搜索(&S)", "在文件中查找(&I)")
	WinWaitActive("在文件中查找", "查找(&N):", 2)
	$selected = ControlCommand("在文件中查找", "查找(&N):", 1001, "GetSelected", "")
	ClipPut($selected)
	ControlSetText("在文件中查找", "查找(&N):", 1001, '"' & $selected & '"')
	ControlSend("在文件中查找", "查找(&N):", 1 ,"{enter}")
EndFunc
