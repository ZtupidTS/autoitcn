#AutoIt3Wrapper_Icon = .\ico\Jazz Jackrabbit.ico
#include <Constants.au3>
#include <Misc.au3>

If _Singleton("chenxu_qiangzhancc", 1) == 1 Then
	Exit
EndIf

Global $ver = "1.2.1"

Opt("TrayOnEventMode", 1)
Opt("TrayMenuMode", 1)
Opt("MustDeclareVars", 1)
Global $tm_release = TrayCreateItem("�����ͷ���ռ�õ�Lisence")
TrayItemSetState ($tm_release, $TRAY_DISABLE)
TrayItemSetOnEvent($tm_release, "release")
TrayCreateItem("")
TrayItemSetOnEvent(TrayCreateItem("����"), "about")
TrayCreateItem("")
TrayItemSetOnEvent(TrayCreateItem("�˳�"), "quit")

Global $path = ""
Global $cleartool = ""

_getCCLicense()

Func _getCCLicense()
	$path = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Atria\ClearCase\2.0", "ProductHome") & "\bin"
	$cleartool = $path  & "\cleartool.exe"
	If Not FileExists($cleartool) Then
		MsgBox(64, "��CC", "ccδ��װ���߰�װ����")
		Exit
	EndIf
	TrayTip("��CC", "������CC Licence��������������Ѹ��㣬�����ĵȴ�...", 20)
	Local $timer = TimerInit()
	Local $n = 0
	While True
		Local $foo = Run(@ComSpec & ' /c "' & $cleartool & '"', $path, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
;~ 		ConsoleWrite($foo & @CRLF)
		While 1
			Sleep(10)
			If StdoutRead($foo) <> "" Then
				TraySetState (4)
				TrayTip("", "", 0)
				Local $iMsgBoxAnswer = MsgBox(262212, "��CC", _
								"��ϲ��ϲ���Ѿ�����CC��" & @CRLF & _
								"��ʱ��" & Int(TimerDiff($timer)/60000) & "���ӣ�������ѽ��" & @CRLF & @CRLF & _
								"�Ƿ��CC��", 300)
				If $iMsgBoxAnswer == 6 Then
					If WinExists("Rational ClearCase Explorer", "Menu bar") Then
						ControlSend("Rational ClearCase Explorer", "Menu bar", 2, "{f5}")
						WinActivate("Rational ClearCase Explorer", "Menu bar")
					Else
						Run($path & "\clearexplorer.exe", $path)
					EndIf
				EndIf
				$iMsgBoxAnswer = MsgBox(262212, "��CC", "�Ƿ񱣻�CC��", 900)
				If $iMsgBoxAnswer == 6 Then
					_keepCCLive()
				Else
					Exit
				EndIf
			EndIf
			If @error Then ExitLoop
		WEnd
		$n += 1
		TraySetToolTip("���Դ�����" & $n & "���Ѿ���ʱ��" & Int(TimerDiff($timer)/60000) & "���ӡ�")
		StdioClose($foo)
	WEnd
EndFunc

Func _keepCCLive()
	TraySetState (8)
	TraySetToolTip("���ڱ���CC License...")
	TrayItemSetState ($tm_release, $TRAY_ENABLE)
	Local $p = 0
	Local $timer = TimerInit()
	While True
		Local $foo = Run(@ComSpec & ' /c "' & $cleartool & '"', $path, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		While 1
			Sleep(10)
			If StderrRead($foo) <> "" Then
				While ProcessExists("cleartool.exe")
					ProcessClose("cleartool.exe")
				WEnd
				MsgBox($MB_OK + $MB_ICONASTERISK,"��CC", _
					"�޷���������CC License��" & @CRLF & _
					"���������ڱ����һֱ������һ��������ʹ��CC��ʱ�Σ�" & @CRLF & _
					"��������絽������ߴ����絽�ڶ������硣" & @CRLF & _
					"��������������ԭ�����������һ��bug����� ����145812 ��ϵ��");,1200)
				Exit
			EndIf
			If @error Then ExitLoop
		WEnd
		Sleep(1200000)
		TrayTip("��CC", "�Ѿ�ռ�� lisence ʱ�䣺" & Int(TimerDiff($timer)/60000) & "���ӡ�" & @CRLF & _
						"����û��Ҫ��ʱ���ͷ�CC License��������ʹ�ã�" & @CRLF & _
						"��Ҫһֱռ�ݲ��ͷţ�лл��", 60)
	WEnd
EndFunc

Func release()
	Local $iMsgBoxAnswer = MsgBox(292,"��CC", _
				"���������ͷ��Ѿ�ռ�õ�Lisence�������ˣ�" & @CRLF & _
				"�������Ҫʹ��CC���Ǿ���Ҫ����һ���ˡ�" & @CRLF & @CRLF & _
				"�Ƿ������ͷ��Ѿ�ռ�ݵ�Lisence��")
	If $iMsgBoxAnswer == 7 Then Return
	Run(@ComSpec & ' /c "' & $path & "\clearlicense -release" & '"', $path, @SW_HIDE)
	Exit
EndFunc

Func about()
	MsgBox(64, "��CC", "��ǰ�汾��" & $ver & @CRLF & _
			"���ߣ�����145812" & @CRLF & _
			"��ӭ������", 60)
EndFunc   ;==>about

Func quit()
	Local $iMsgBoxAnswer = MsgBox(36, "��CC", "�Ƿ������ͷ��Ѿ�ռ�ݵ�Lisence��")
	If $iMsgBoxAnswer == 6 Then
		Run(@ComSpec & ' /c "' & $path & "\clearlicense -release" & '"', $path, @SW_HIDE)
	EndIf
	Exit
EndFunc   ;==>quit