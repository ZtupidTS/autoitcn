#include "common.au3"
#include <INet.au3>

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
	$subject = "Զ�̿������� - �����ʼ�"
	$content = ""
EndIf

_INetMail($sendTo, $subject, $content)
WinWait("�½���� - Lotus Notes", "�½����", 60)
ControlSend("�½���� - Lotus Notes", "�½����", "[Class:IRIS.tedit; Instance:6; ID:2347]", $ccTo)
Sleep(200)

If $args >= 5 Then
	$attCount = $args - 4
	For $i = 0 To ($attCount - 1)
		$attatchment = RegRead($REG_BASE_CURRENT_TASK, "arg" & ($i + 5))
		If Not FileExists($attatchment) Then
			ContinueLoop
		EndIf
		WinMenuSelectItem("�½���� - Lotus Notes", "�½����", "�ļ�(&F)", "����(&A)...")
		WinWait("��������", "���ҷ�Χ(&I):", 60)
		ControlSend("��������", "���ҷ�Χ(&I):", "[Class:Edit; Instance:1; ID:1152]", $attatchment)
		Sleep(200)
		ControlSend("��������","���ҷ�Χ(&I):", "[Class:Button: Instance:2; ID:1]", "{ENTER}")
		WinWaitClose("��������", "���ҷ�Χ(&I):", 60)
	Next
EndIf









