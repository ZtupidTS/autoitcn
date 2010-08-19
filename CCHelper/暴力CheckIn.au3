
#AutoIt3Wrapper_Icon = .\ico\27.ico
;~ ProcessClose("CQINTS~2.exe")
;~ Opt("TrayMenuMode",1)

;~ $exititem		= TrayCreateItem("Exit")

Local $t = TimerInit()
While 1
	TrayTip("暴力CheckIn", "正在暴力CheckIn代码，结束后请手工关闭本程序，单击任务栏可以关闭本程序。" & @CRLF & _
		"或者本程序启动后15分钟后会自动关闭。", 30)
	If TimerDiff($t) > 15 * 60 * 1000 Then Exit
	Sleep(500)
	If Not WinExists("Checkin", "&Associated Records:") Then ContinueLoop
	If Not ProcessExists("CQINTS~2.exe") Then
		MsgBox(48,"暴力CheckIn","发生未知错误，请重试。")
		Exit
	EndIf
	ProcessClose("CQINTS~2.exe")
	If WinWait("trigger_coci", "运行时错误", 30) == 0 Then
		MsgBox(48,"暴力CheckIn","发生未知错误，请重试。")
		Exit
	EndIf
	WinClose("trigger_coci", "运行时错误")
WEnd