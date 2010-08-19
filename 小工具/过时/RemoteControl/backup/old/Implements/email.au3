#include <INet.au3>
#include "common.au3"

Opt("TrayIconDebug", 1)

Global $task[0]

email()

;===============================================================================
;
; Function Name:	email()
; Description:		���͵����ʼ�
; Parameter(s):		sendTo:			�����ˣ�Ĭ�ϣ�oicqcx@hotmail.com
; 					ccTo:			cc�ˣ�Ĭ�ϣ���
; 					subject:		���⣬Ĭ�ϣ�Զ�̿������� - �����ʼ�
; 					content:		���ݣ�Ĭ�ϣ���
; 					attatchments:	���飬�����ļ����б�Ĭ�ϣ���
; 					
; Return Value(s):  On Success - ��
;                   On Failure - ��
; Error Code:		10081 ~ 10090
; Author(s):        Chenxu
;
;===============================================================================
Func email()
	$taskName = RegRead($REG_BASE_CURRENT_TASK, "taskName")
	If $taskName <> "email" Then
		; ������email�����������ȴ����email
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

	_logger("[RC��ʵ�֣�email] Send To: " & $sendTo)
	ConsoleWrite("[RC��ʵ�֣�email] CC To: " & $ccTo)
	ConsoleWrite("[RC��ʵ�֣�email] Subject: " & $subject)

	_INetMail($sendTo, $subject, $content)
	WinWait("�½���� - Lotus Notes", "�½����", 60)
	If $ccTo <> "" Then
		ControlSend("�½���� - Lotus Notes", "�½����", "[Class:IRIS.tedit; Instance:6; ID:2347]", $ccTo)
	EndIf
	Sleep(200)

	If $args >= 5 Then
		$attCount = $args - 4
		For $i = 0 To ($attCount - 1)
			$attatchment = RegRead($REG_BASE_CURRENT_TASK, "arg" & ($i + 5))
			If Not FileExists($attatchment) Then
				ConsoleWrite("[RC��ʵ�֣�email] Attatchment not exists: " & $attatchment)
				ContinueLoop
			EndIf
			ConsoleWrite("[RC��ʵ�֣�email] Attatchment: " & $attatchment)
			ControlFocus("�½���� - Lotus Notes", "�½����", "[Class:NotesRichText; Instance:1]")
			Sleep(200)
			WinMenuSelectItem("�½���� - Lotus Notes", "�½����", "�ļ�(&F)", "����(&A)...")
			WinWait("��������", "���ҷ�Χ(&I):", 60)
			ControlSend("��������", "���ҷ�Χ(&I):", "[Class:Edit; Instance:1; ID:1152]", $attatchment)
			Sleep(200)
			ControlSend("��������","���ҷ�Χ(&I):", "[Class:Button: Instance:2; ID:1]", "{ENTER}")
			WinWaitClose("��������", "���ҷ�Χ(&I):", 60)
			
			Sleep(timeWait(FileGetSize($attatchment)))
		Next
	EndIf
	ControlSend("�½���� - Lotus Notes", "�½����", "[Class:NotesLineView; Instance:1]", "!1")
	ConsoleWrite("[RC��ʵ�֣�email] Done!")
EndFunc


Func getPara()
	If $CmdLine[0] == 2 Then
		ReDim $task = $CmdLine[1]
	Else
		; not gonna finish it, exit
		Exit
		
;~ 		$taskName = RegRead($REG_BASE_CURRENT_TASK, "taskName")
;~ 		If $taskName <> "email" Then
;~ 			; ������email�����������ȴ����email
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






