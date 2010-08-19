#include <File.au3>
#include <a3lwinapi.au3>
#include "common.au3"


Global $MSG_ACCEPTED = "接受了使用远程协助的邀请。"
Global $MSG_WAITING = "请等待回应或取消 (Alt+Q) 该待定的邀请。"
Global $MSG_REFUSED = "拒绝了您开始远程协助的邀请。"
Global $MSG_RESTART = "重新开始"
Global $MSG_CANNT_SEND_INVITATION = "发送使用远程协助 邀请。"
Global $MSG_DROP = "结束"
Global $MSG_CANNT_SEND_Y = "已经等待到窗口：远程协助窗口，但是无法发送Alt+Y指令。"
Global $MSG_SEND_Y_DONE = "已经等待到窗口：远程协助窗口，而且已经发送Alt+Y指令。"
Global $MSG_ACCEPTED_CONTROL_DONE = "成功接受控制，功能完成。"
Global $MSG_ERROR = "$MSG_ERROR"

If $cmdLine[0] == 0 Then
	WinClose("远程协助 -- 网页对话框")
	WinClose("远程协助")
	Local $status = sendRequest()
	If $status <> $MSG_SEND_Y_DONE Then
		logger("请求远程协助失败。")
		Exit
	EndIf
EndIf

WinClose("远程协助 -- 网页对话框")
If $cmdLine[0] >= 1 Then
	responseByMsn("等待获取控制命令。")
EndIf
acceptControl()



Func sendRequest()
	Local $status = $MSG_ERROR
	If Not WinMenuSelectItem($MSN_TITLE, "", "操作(&A)", "请求远程协助(&R)") Then
		logger("对应的菜单无法找到，请求远程协助无法完成")
		Return $MSG_ERROR
	EndIf

	Local $timer = TimerInit()
	Do
		If WinWait("远程协助", "", 20) Then
			For $i = 1 To 5
				Sleep(5000)
				If ControlSend("远程协助", "", "[Class:Internet Explorer_Server; Instance:3]", "!y") Then
					$status = $MSG_SEND_Y_DONE
					logger("状态【" & $status & "】")
					ExitLoop
				EndIf
			Next
			ExitLoop
		EndIf
		$status = getStatusMsn()
		logger("状态【" & $status & "】")
		If $status == $MSG_WAITING Or $status == $MSG_ACCEPTED Then
			ContinueLoop
		ElseIf $status == $MSG_REFUSED Or _
			$status == $MSG_RESTART Or _
			$status == $MSG_CANNT_SEND_INVITATION Or _
			$status == $MSG_ERROR Then
			If Not WinMenuSelectItem($MSN_TITLE, "", "操作(&A)", "请求远程协助(&R)") Then
				logger("对应的菜单无法找到，请求远程协助无法完成")
				Return $MSG_ERROR
			EndIf
		ElseIf $status == $MSG_DROP Then
			WinClose("远程协助", "")
			Return $MSG_DROP
		ElseIf $status == $MSG_SEND_Y_DONE Then
			ExitLoop
		EndIf
	Until TimerDiff($timer) >= 1800000 Or Not WinExists($MSN_TITLE); 30min
	Return $status
EndFunc

Func acceptControl()
	Local $timer = TimerInit()
	Local $pos, $status = $MSG_ERROR
	Do
		If WinWait("远程协助 -- 网页对话框", "", 20) Then
			logger("远程协助 -- 网页对话框  窗口出现。")
			Sleep(2000)
			$pos = WinGetPos("远程协助 -- 网页对话框")
			If $pos[3] == 165 Then
				logger("由于网络或者其它原因导致远程连接断开。")
				WinClose("远程协助 -- 网页对话框")
				Sleep(2000)
				WinClose("远程协助")
			ElseIf $pos[3] == 270 Then
				logger("接受控制对话框出现。")
				For $i = 1 To 5
					Sleep(5000)
					If ControlSend("远程协助 -- 网页对话框", "", "[Class:Internet Explorer_Server; Instance:1]", "!y") Then
						$status = $MSG_ACCEPTED_CONTROL_DONE
						logger("状态【" & $status & "】")
						Exit
					EndIf
				Next
			EndIf
			ExitLoop
		EndIf
		$status = getStatusMsn()
		If $status == $MSG_RESTART Then
			WinClose("远程协助")
		EndIf
	Until TimerDiff($timer) >= 1800000 Or Not WinExists($MSN_TITLE) ; 30min
EndFunc

Func getStatusMsn()
	WinMenuSelectItem($MSN_TITLE, "", "文件(&F)", "另存为(&A)...")
	If WinWait("另存为", "保存在(&I):", 20) == 0 Then
		logger("从MSN对话中接收消息失败。1")
		Return $MSG_ERROR
	EndIf
	Local $tmpFile = getTmpFile("txt")
	ControlSetText("另存为", "保存在(&I):", 1148, $tmpFile, 1)
	ControlCommand("另存为", "保存在(&I):", 1136, "SelectString", '纯文本文档')
	Sleep(100)
	ControlSend("另存为", "保存在(&I):", 1, "{enter}")
	If WinWait("Windows Live Messenger", "确定", 20) == 0 Then
		logger("从MSN对话中接收消息失败。2")
		Return $MSG_ERROR
	EndIf
	ControlClick("Windows Live Messenger", "确定", 1)
	For $i = 1 To 100
		Sleep(100)
		If FileExists($tmpFile) Then ExitLoop
	Next
	Local $msg = StringStripWS(FileRead($tmpFile), 3)
	If @error Or $msg == "" Then
		Return $MSG_ERROR
	EndIf
	Local $n = StringInStr($msg, @CRLF, 0, -1)
	If $n == 0 Then
		Return $msg
	EndIf
	Local $cmd =  StringStripWS(StringRight($msg, StringLen($msg) - $n), 3)
	logger("来自getStatusMsn：" & $cmd)
	If StringInStr($cmd, $MSG_WAITING) Then
		Return $MSG_WAITING
	ElseIf StringInStr($cmd, $MSG_RESTART) Then
		Return $MSG_RESTART
	ElseIf StringInStr($cmd, $MSG_ACCEPTED) Then
		Return $MSG_ACCEPTED
	ElseIf StringInStr($cmd, $MSG_REFUSED) Then
		Return $MSG_REFUSED
	Else
		Return $MSG_ERROR
	EndIf
EndFunc



