#include "..\common.au3"
#NoTrayIcon

Global $pid = ""
Global $terminate = ""
Switch $cmdLine[0]
Case 0
	$pid = ""
	$terminate = ""
Case 1
	$pid = $cmdLine[1]
	$terminate = ""
Case 2
	$pid = $cmdLine[1]
	$terminate = $cmdLine[2]
EndSwitch

If $pid == "" Then
	responseByIM("参数pid的值是空，无法继续。")
	Exit
EndIf
If StringLower($pid) == "rcserver.exe" Then
	responseByIM("参数pid的值是RCServer.exe的进程号，不能自杀，无法继续。")
	Exit
EndIf

If ProcessExists($pid) Then
	ProcessClose($pid)
	If ProcessWaitClose($pid, 120) == 0 Then
		responseByIM("关闭进程【" & $pid & "】失败。")
		Exit
	EndIf
	responseByIM("关闭进程【" & $pid & "】成功。")
	Exit
EndIf

If Not WinExists($pid) Then
	responseByIM("窗口【" & $pid & "】不存在，无法继续。")
	Exit
EndIf

WinClose($pid)
If WinWaitClose($pid, "", 60) == 0 Then
	Local $p = WinGetProcess($pid, "")
	If $p == -1 Then
		responseByIM("窗口【" & $pid & "】无法关闭，并且对应的pid找不到。")
		Exit
	EndIf
	ProcessClose($p)
	If ProcessWaitClose($p, 120) == 0 Then
		responseByIM("窗口【" & $pid & "】无法关闭，等待60秒后，杀掉进程失败。")
		Exit
	EndIf
	responseByIM("窗口【" & $pid & "】无法关闭，等待60秒后，杀掉进程成功。")
EndIf
responseByIM("窗口【" & $pid & "】被成功关闭。")









