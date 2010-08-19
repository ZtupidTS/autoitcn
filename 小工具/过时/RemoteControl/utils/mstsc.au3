#include "..\common.au3"
#NoTrayIcon

Global $ip = ""
Global $userName = ""
Global $pwd = ""
Switch $cmdLine[0]
Case 0
	$ip = ""
	$userName = ""
	$pwd = ""
Case 1
	$ip = $cmdLine[1]
	$userName = ""
	$pwd = ""
Case 2
	$ip = $cmdLine[1]
	$userName = $cmdLine[2]
	$pwd = ""
Case 3
	$ip = $cmdLine[1]
	$userName = $cmdLine[2]
	$pwd = $cmdLine[3]
EndSwitch

If $ip == "" Or $userName == "" Then Exit
If StringLower($userName) == "close" Then
	close()
	Exit
EndIf
If $pwd == "" Then Exit
open()

Func open()
	If WinExists($ip & " - 远程桌面", $ip & " - 远程桌面") Then
		MsgBox(0, "", "win existed")
		If WinExists("断开 Windows 会话", "确定") Then
			ControlClick("断开 Windows 会话", "取消", 2)
			If WinWaitClose("断开 Windows 会话", "取消", 30) == 0 Then
				logger("无法取消”断开 Windows 会话“对话框。")
			EndIf
		EndIf
		responseByIM("目标远程登陆窗口已经存在。")
		Exit
	EndIf

	Run("C:\WINDOWS\system32\mstsc")
	If WinWait("远程桌面连接", "计算机(&C):", 20) == 0 Then
		responseByIM("打开mstsc失败。")
		Exit
	EndIf
	If WinExists("远程桌面连接", "选项(&O) >>") Then
		ControlClick("远程桌面连接", "选项(&O) >>", 903)
		If WinWait("远程桌面连接", "选项(&O) <<", 20) == 0 Then
			responseByIM("打开mstsc失败。")
			Exit
		EndIf
	EndIf
	ControlSetText("远程桌面连接", "选项(&O) <<", 1007, $ip)
	ControlSetText("远程桌面连接", "选项(&O) <<", 1009, $userName)
	ControlSetText("远程桌面连接", "选项(&O) <<", 1010, $pwd)
	ControlClick("远程桌面连接", "选项(&O) <<", 1)
	If WinWait($ip & " - 远程桌面", $ip & " - 远程桌面", 30) == 0 Then
		responseByIM("登录" & $ip & "失败。")
		Exit
	EndIf
	responseByIM("登录" & $ip & "成功。")
EndFunc

Func close()
	If Not WinExists($ip & " - 远程桌面", $ip & " - 远程桌面") Then
		responseByIM("目标远程登录窗口" & $ip & "不存在。")
		Exit
	EndIf
	WinClose($ip & " - 远程桌面", $ip & " - 远程桌面")
	If WinWait("断开 Windows 会话", "确定", 30) == 0 Then
		responseByIM("关闭目标远程登录窗口" & $ip & "失败。")
		Exit
	EndIf
	ControlSend("断开 Windows 会话", "确定", 605, "{enter}")
	If WinWaitClose($ip & " - 远程桌面", $ip & " - 远程桌面", 30) == 0 Then
		responseByIM("关闭目标远程登录窗口" & $ip & "失败。")
	Else
		responseByIM("关闭目标远程登录窗口" & $ip & "成功。")
	EndIf
EndFunc


