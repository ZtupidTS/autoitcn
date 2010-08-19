

MsgBox(64,"提醒","用画图打开需要获取area的图片，" & @CRLF & _
	"鼠标移到矩形的左上角或者右下角，按F3获取坐标。" & @CRLF & _
	"本工具最好在缩略语管理器同个目录下执行。")

Opt("WinTitleMatchMode", 2)

If Not WinExists("- 画图", "要获得帮助，请在“帮助”菜单中，单击“帮助主题”。") Then
	MsgBox(64,"提醒","用画图打开需要获取area的图片，" & @CRLF & _
		"鼠标移到矩形的左上角或者右下角，按F3获取坐标。" & @CRLF & _
		"本工具最好在缩略语管理器同个目录下执行。")
	Run("mspaint.exe")
EndIf

Global $flag = False, $name = "", $out = "", $lastCoor
Global $hWnd = ControlGetHandle("- 画图", "要获得帮助，请在“帮助”菜单中，单击“帮助主题”。", 59393)

HotKeySet ("{F3}", "_go")

WinActivate("- 画图", "要获得帮助，请在“帮助”菜单中，单击“帮助主题”。")
While 1
	Sleep(3000)
WEnd

Func _go()
	$flag = Not $flag
	If $flag Then
		$lastCoor = StatusbarGetText ("- 画图", "要获得帮助，请在“帮助”菜单中，单击“帮助主题”。", 2) & ','
	Else
		$lastCoor &= StatusbarGetText ("- 画图", "要获得帮助，请在“帮助”菜单中，单击“帮助主题”。", 2)
		
		$name = InputBox("输入信息","输入当前area的名字",""," ","-1","120","-1","-1")
		$out &= '<area shape=RECT alt="'
		$out &= IniRead("data.ini", $name, "brief", $name)
		$out &= '" coords=' & $lastCoor
		$out &= ' href="../' & $name & '/' & $name & '.html">' & @CRLF
		$lastCoor = ""
;~ 		ConsoleWrite($out & @CRLF)
	EndIf
EndFunc

Func OnAutoItExit()
	Local $file = @TempDir & "\res.txt"
	FileDelete($file)
	FileWrite($file, $out)
	Run("notepad " & $file)
;~ 	MsgBox(64,"提醒","已经将结果放入剪切板了。")
EndFunc