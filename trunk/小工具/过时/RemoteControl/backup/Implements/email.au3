#include "common.au3"
#include <INet.au3>

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
	$subject = "远程控制命令 - 发送邮件"
	$content = ""
EndIf

_INetMail($sendTo, $subject, $content)
WinWait("新建便笺 - Lotus Notes", "新建便笺", 60)
ControlSend("新建便笺 - Lotus Notes", "新建便笺", "[Class:IRIS.tedit; Instance:6; ID:2347]", $ccTo)
Sleep(200)

If $args >= 5 Then
	$attCount = $args - 4
	For $i = 0 To ($attCount - 1)
		$attatchment = RegRead($REG_BASE_CURRENT_TASK, "arg" & ($i + 5))
		If Not FileExists($attatchment) Then
			ContinueLoop
		EndIf
		WinMenuSelectItem("新建便笺 - Lotus Notes", "新建便笺", "文件(&F)", "附加(&A)...")
		WinWait("创建附件", "查找范围(&I):", 60)
		ControlSend("创建附件", "查找范围(&I):", "[Class:Edit; Instance:1; ID:1152]", $attatchment)
		Sleep(200)
		ControlSend("创建附件","查找范围(&I):", "[Class:Button: Instance:2; ID:1]", "{ENTER}")
		WinWaitClose("创建附件", "查找范围(&I):", 60)
	Next
EndIf









