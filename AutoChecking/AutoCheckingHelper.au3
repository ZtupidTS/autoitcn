#include "common.au3"

#AutoIt3Wrapper_icon = "ico\daemon.ico"

Global $APP_NAME = "AC30 Helper"
Global $PROCESS_NAME_GUI = "AutoCheckingGUI.exe"
Global $APP_NAME_DAEMON = "AutoCheckingDaemon.exe"
Global $MSG_SUCCESS = "网上刷卡成功"
Global $MSG_FAILED = "请输入有效的验证码"
Global $MSG_TIME_INVALID = "刷卡时间无效"
Global $MSG_UNKOWN = "未知"

AutoItSetOption("TrayMenuMode", 1)
TraySetState(2)

$result = $MSG_UNKOWN
$flag = False
While 1
	Sleep(500)
	If WinExists("来自网页的消息", $MSG_SUCCESS) Then
		$result = $MSG_SUCCESS
	ElseIf WinExists("来自网页的消息", $MSG_FAILED) Then
		$result = $MSG_FAILED
	ElseIf WinExists("来自网页的消息", $MSG_TIME_INVALID) Then
		$result = $MSG_TIME_INVALID
	Else
		ContinueLoop
	EndIf
	RegWrite($regBase & "\swap", "result", "REG_SZ", $result)
	Sleep(20)
	ControlClick("来自网页的消息", $result, "[CLASS:Button; INSTANCE:1]")
	Exit
WEnd


