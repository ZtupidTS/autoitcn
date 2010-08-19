#include <INet.au3>
#include "common.au3"

Opt("TrayIconDebug", 1)

Global $task[0]

email()

;===============================================================================
;
; Function Name:	email()
; Description:		发送电子邮件
; Parameter(s):		sendTo:			发送人，默认：oicqcx@hotmail.com
; 					ccTo:			cc人，默认：无
; 					subject:		主题，默认：远程控制命令 - 发送邮件
; 					content:		内容，默认：无
; 					attatchments:	数组，附件文件名列表，默认：无
; 					
; Return Value(s):  On Success - 无
;                   On Failure - 无
; Error Code:		10081 ~ 10090
; Author(s):        Chenxu
;
;===============================================================================
Func email()
	$taskName = RegRead($REG_BASE_CURRENT_TASK, "taskName")
	If $taskName <> "email" Then
		; 调用了email命令，但是任务却不是email
		_logger(10081)
		SetError(10081)
		Exit
	EndIf
	$args = RegRead($REG_BASE_CURRENT_TASK, "args")
	If $args == "" Or $args == 0 Then
		; no arguments, set default
		$sendTo = "oicqcx@hotmail.com"
		$ccTo = ""
		$subject = "RC Command - Sending E-Mail"
		$content = ""
	Else
		$sendTo = RegRead($REG_BASE_CURRENT_TASK, "arg1")
		If $sendTo == "" Then $sendTo = "oicqcx@hotmail.com"
		$ccTo = RegRead($REG_BASE_CURRENT_TASK, "arg2")
		If $ccTo == "" Then $ccTo = ""
		$subject = RegRead($REG_BASE_CURRENT_TASK, "arg3")
		If $subject == "" Then $subject = "RC Command - Sending E-Mail"
		$content = RegRead($REG_BASE_CURRENT_TASK, "arg4")
		If $content == "" Then $content = ""
	EndIf

	_logger("[RC的实现：email] Send To: " & $sendTo)
	ConsoleWrite("[RC的实现：email] CC To: " & $ccTo)
	ConsoleWrite("[RC的实现：email] Subject: " & $subject)

	_INetMail($sendTo, $subject, $content)
	WinWait("新建便笺 - Lotus Notes", "新建便笺", 60)
	If $ccTo <> "" Then
		ControlSend("新建便笺 - Lotus Notes", "新建便笺", "[Class:IRIS.tedit; Instance:6; ID:2347]", $ccTo)
	EndIf
	Sleep(200)

	If $args >= 5 Then
		$attCount = $args - 4
		For $i = 0 To ($attCount - 1)
			$attatchment = RegRead($REG_BASE_CURRENT_TASK, "arg" & ($i + 5))
			If Not FileExists($attatchment) Then
				ConsoleWrite("[RC的实现：email] Attatchment not exists: " & $attatchment)
				ContinueLoop
			EndIf
			ConsoleWrite("[RC的实现：email] Attatchment: " & $attatchment)
			ControlFocus("新建便笺 - Lotus Notes", "新建便笺", "[Class:NotesRichText; Instance:1]")
			Sleep(200)
			WinMenuSelectItem("新建便笺 - Lotus Notes", "新建便笺", "文件(&F)", "附加(&A)...")
			WinWait("创建附件", "查找范围(&I):", 60)
			ControlSend("创建附件", "查找范围(&I):", "[Class:Edit; Instance:1; ID:1152]", $attatchment)
			Sleep(200)
			ControlSend("创建附件","查找范围(&I):", "[Class:Button: Instance:2; ID:1]", "{ENTER}")
			WinWaitClose("创建附件", "查找范围(&I):", 60)
			
			Sleep(timeWait(FileGetSize($attatchment)))
		Next
	EndIf
	ControlSend("新建便笺 - Lotus Notes", "新建便笺", "[Class:NotesLineView; Instance:1]", "!1")
	ConsoleWrite("[RC的实现：email] Done!")
EndFunc


Func getPara()
	If $CmdLine[0] == 2 Then
		ReDim $task = $CmdLine[1]
	Else
		; not gonna finish it, exit
		Exit
		
;~ 		$taskName = RegRead($REG_BASE_CURRENT_TASK, "taskName")
;~ 		If $taskName <> "email" Then
;~ 			; 调用了email命令，但是任务却不是email
;~ 			_logger(10081)
;~ 			SetError(10081)
;~ 			Return
;~ 		EndIf
;~ 		$args = RegRead($REG_BASE_CURRENT_TASK, "args")
;~ 		If $args == "" Then
;~ 			$args = 5
;~ 		EndIf
;~ 		ReDim $task[$args + 1]
;~ 		$task[0] = $taskName
;~ 		
;~ 		$sendTo = RegRead($REG_BASE_CURRENT_TASK, "arg1")
;~ 		If $sendTo == "" Then $sendTo = "oicqcx@hotmail.com"
;~ 		$ccTo = RegRead($REG_BASE_CURRENT_TASK, "arg2")
;~ 		If $ccTo == "" Then $ccTo = ""
;~ 		$subject = RegRead($REG_BASE_CURRENT_TASK, "arg3")
;~ 		If $subject == "" Then $subject = "RC Command - Sending E-Mail"
;~ 		$content = RegRead($REG_BASE_CURRENT_TASK, "arg4")
;~ 		If $content == "" Then $content = ""
	EndIf
EndFunc

Func timeWait($size)
	If $size < 100000 Then ;100k
		Return 400
	ElseIf $size < 1000000 Then ;1M
		Return 3000
	ElseIf $size < 10000000 Then ;10M
		Return 7000
	Else
		Return 30000
	EndIf
	Return 0
EndFunc






