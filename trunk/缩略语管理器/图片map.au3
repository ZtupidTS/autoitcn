

MsgBox(64,"����","�û�ͼ����Ҫ��ȡarea��ͼƬ��" & @CRLF & _
	"����Ƶ����ε����Ͻǻ������½ǣ���F3��ȡ���ꡣ" & @CRLF & _
	"����������������������ͬ��Ŀ¼��ִ�С�")

Opt("WinTitleMatchMode", 2)

If Not WinExists("- ��ͼ", "Ҫ��ð��������ڡ��������˵��У��������������⡱��") Then
	MsgBox(64,"����","�û�ͼ����Ҫ��ȡarea��ͼƬ��" & @CRLF & _
		"����Ƶ����ε����Ͻǻ������½ǣ���F3��ȡ���ꡣ" & @CRLF & _
		"����������������������ͬ��Ŀ¼��ִ�С�")
	Run("mspaint.exe")
EndIf

Global $flag = False, $name = "", $out = "", $lastCoor
Global $hWnd = ControlGetHandle("- ��ͼ", "Ҫ��ð��������ڡ��������˵��У��������������⡱��", 59393)

HotKeySet ("{F3}", "_go")

WinActivate("- ��ͼ", "Ҫ��ð��������ڡ��������˵��У��������������⡱��")
While 1
	Sleep(3000)
WEnd

Func _go()
	$flag = Not $flag
	If $flag Then
		$lastCoor = StatusbarGetText ("- ��ͼ", "Ҫ��ð��������ڡ��������˵��У��������������⡱��", 2) & ','
	Else
		$lastCoor &= StatusbarGetText ("- ��ͼ", "Ҫ��ð��������ڡ��������˵��У��������������⡱��", 2)
		
		$name = InputBox("������Ϣ","���뵱ǰarea������",""," ","-1","120","-1","-1")
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
;~ 	MsgBox(64,"����","�Ѿ������������а��ˡ�")
EndFunc