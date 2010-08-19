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
Global $tm_release = TrayCreateItem("立即释放已占用的Lisence")
TrayItemSetState ($tm_release, $TRAY_DISABLE)
TrayItemSetOnEvent($tm_release, "release")
TrayCreateItem("")
TrayItemSetOnEvent(TrayCreateItem("关于"), "about")
TrayCreateItem("")
TrayItemSetOnEvent(TrayCreateItem("退出"), "quit")

Global $path = ""
Global $cleartool = ""

_getCCLicense()

Func _getCCLicense()
	$path = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Atria\ClearCase\2.0", "ProductHome") & "\bin"
	$cleartool = $path  & "\cleartool.exe"
	If Not FileExists($cleartool) Then
		MsgBox(64, "抢CC", "cc未安装或者安装错误")
		Exit
	EndIf
	TrayTip("抢CC", "正在抢CC Licence，结束后会有提醒给你，请耐心等待...", 20)
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
				Local $iMsgBoxAnswer = MsgBox(262212, "抢CC", _
								"恭喜恭喜，已经抢到CC了" & @CRLF & _
								"耗时：" & Int(TimerDiff($timer)/60000) & "分钟，不容易呀！" & @CRLF & @CRLF & _
								"是否打开CC？", 300)
				If $iMsgBoxAnswer == 6 Then
					If WinExists("Rational ClearCase Explorer", "Menu bar") Then
						ControlSend("Rational ClearCase Explorer", "Menu bar", 2, "{f5}")
						WinActivate("Rational ClearCase Explorer", "Menu bar")
					Else
						Run($path & "\clearexplorer.exe", $path)
					EndIf
				EndIf
				$iMsgBoxAnswer = MsgBox(262212, "抢CC", "是否保活CC？", 900)
				If $iMsgBoxAnswer == 6 Then
					_keepCCLive()
				Else
					Exit
				EndIf
			EndIf
			If @error Then ExitLoop
		WEnd
		$n += 1
		TraySetToolTip("重试次数：" & $n & "，已经耗时：" & Int(TimerDiff($timer)/60000) & "分钟。")
		StdioClose($foo)
	WEnd
EndFunc

Func _keepCCLive()
	TraySetState (8)
	TraySetToolTip("正在保活CC License...")
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
				MsgBox($MB_OK + $MB_ICONASTERISK,"抢CC", _
					"无法继续保活CC License。" & @CRLF & _
					"可能是由于保活功能一直持续到一个不允许使用CC的时段，" & @CRLF & _
					"例如从上午到下午或者从下午到第二天上午。" & @CRLF & _
					"如果不是由于这个原因，那这可能是一个bug，请和 陈旭145812 联系。");,1200)
				Exit
			EndIf
			If @error Then ExitLoop
		WEnd
		Sleep(1200000)
		TrayTip("抢CC", "已经占用 lisence 时间：" & Int(TimerDiff($timer)/60000) & "分钟。" & @CRLF & _
						"请在没必要的时候释放CC License给其它人使用，" & @CRLF & _
						"不要一直占据不释放，谢谢。", 60)
	WEnd
EndFunc

Func release()
	Local $iMsgBoxAnswer = MsgBox(292,"抢CC", _
				"可以马上释放已经占用的Lisence给其它人，" & @CRLF & _
				"如果你需要使用CC，那就需要再抢一次了。" & @CRLF & @CRLF & _
				"是否马上释放已经占据的Lisence？")
	If $iMsgBoxAnswer == 7 Then Return
	Run(@ComSpec & ' /c "' & $path & "\clearlicense -release" & '"', $path, @SW_HIDE)
	Exit
EndFunc

Func about()
	MsgBox(64, "抢CC", "当前版本：" & $ver & @CRLF & _
			"作者：陈旭145812" & @CRLF & _
			"欢迎交流。", 60)
EndFunc   ;==>about

Func quit()
	Local $iMsgBoxAnswer = MsgBox(36, "抢CC", "是否马上释放已经占据的Lisence？")
	If $iMsgBoxAnswer == 6 Then
		Run(@ComSpec & ' /c "' & $path & "\clearlicense -release" & '"', $path, @SW_HIDE)
	EndIf
	Exit
EndFunc   ;==>quit