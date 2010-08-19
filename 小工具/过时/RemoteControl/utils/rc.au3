#include <File.au3>
#include <a3lwinapi.au3>
#include "common.au3"


Global $MSG_ACCEPTED = "������ʹ��Զ��Э�������롣"
Global $MSG_WAITING = "��ȴ���Ӧ��ȡ�� (Alt+Q) �ô��������롣"
Global $MSG_REFUSED = "�ܾ�������ʼԶ��Э�������롣"
Global $MSG_RESTART = "���¿�ʼ"
Global $MSG_CANNT_SEND_INVITATION = "����ʹ��Զ��Э�� ���롣"
Global $MSG_DROP = "����"
Global $MSG_CANNT_SEND_Y = "�Ѿ��ȴ������ڣ�Զ��Э�����ڣ������޷�����Alt+Yָ�"
Global $MSG_SEND_Y_DONE = "�Ѿ��ȴ������ڣ�Զ��Э�����ڣ������Ѿ�����Alt+Yָ�"
Global $MSG_ACCEPTED_CONTROL_DONE = "�ɹ����ܿ��ƣ�������ɡ�"
Global $MSG_ERROR = "$MSG_ERROR"

If $cmdLine[0] == 0 Then
	WinClose("Զ��Э�� -- ��ҳ�Ի���")
	WinClose("Զ��Э��")
	Local $status = sendRequest()
	If $status <> $MSG_SEND_Y_DONE Then
		logger("����Զ��Э��ʧ�ܡ�")
		Exit
	EndIf
EndIf

WinClose("Զ��Э�� -- ��ҳ�Ի���")
If $cmdLine[0] >= 1 Then
	responseByMsn("�ȴ���ȡ�������")
EndIf
acceptControl()



Func sendRequest()
	Local $status = $MSG_ERROR
	If Not WinMenuSelectItem($MSN_TITLE, "", "����(&A)", "����Զ��Э��(&R)") Then
		logger("��Ӧ�Ĳ˵��޷��ҵ�������Զ��Э���޷����")
		Return $MSG_ERROR
	EndIf

	Local $timer = TimerInit()
	Do
		If WinWait("Զ��Э��", "", 20) Then
			For $i = 1 To 5
				Sleep(5000)
				If ControlSend("Զ��Э��", "", "[Class:Internet Explorer_Server; Instance:3]", "!y") Then
					$status = $MSG_SEND_Y_DONE
					logger("״̬��" & $status & "��")
					ExitLoop
				EndIf
			Next
			ExitLoop
		EndIf
		$status = getStatusMsn()
		logger("״̬��" & $status & "��")
		If $status == $MSG_WAITING Or $status == $MSG_ACCEPTED Then
			ContinueLoop
		ElseIf $status == $MSG_REFUSED Or _
			$status == $MSG_RESTART Or _
			$status == $MSG_CANNT_SEND_INVITATION Or _
			$status == $MSG_ERROR Then
			If Not WinMenuSelectItem($MSN_TITLE, "", "����(&A)", "����Զ��Э��(&R)") Then
				logger("��Ӧ�Ĳ˵��޷��ҵ�������Զ��Э���޷����")
				Return $MSG_ERROR
			EndIf
		ElseIf $status == $MSG_DROP Then
			WinClose("Զ��Э��", "")
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
		If WinWait("Զ��Э�� -- ��ҳ�Ի���", "", 20) Then
			logger("Զ��Э�� -- ��ҳ�Ի���  ���ڳ��֡�")
			Sleep(2000)
			$pos = WinGetPos("Զ��Э�� -- ��ҳ�Ի���")
			If $pos[3] == 165 Then
				logger("���������������ԭ����Զ�����ӶϿ���")
				WinClose("Զ��Э�� -- ��ҳ�Ի���")
				Sleep(2000)
				WinClose("Զ��Э��")
			ElseIf $pos[3] == 270 Then
				logger("���ܿ��ƶԻ�����֡�")
				For $i = 1 To 5
					Sleep(5000)
					If ControlSend("Զ��Э�� -- ��ҳ�Ի���", "", "[Class:Internet Explorer_Server; Instance:1]", "!y") Then
						$status = $MSG_ACCEPTED_CONTROL_DONE
						logger("״̬��" & $status & "��")
						Exit
					EndIf
				Next
			EndIf
			ExitLoop
		EndIf
		$status = getStatusMsn()
		If $status == $MSG_RESTART Then
			WinClose("Զ��Э��")
		EndIf
	Until TimerDiff($timer) >= 1800000 Or Not WinExists($MSN_TITLE) ; 30min
EndFunc

Func getStatusMsn()
	WinMenuSelectItem($MSN_TITLE, "", "�ļ�(&F)", "���Ϊ(&A)...")
	If WinWait("���Ϊ", "������(&I):", 20) == 0 Then
		logger("��MSN�Ի��н�����Ϣʧ�ܡ�1")
		Return $MSG_ERROR
	EndIf
	Local $tmpFile = getTmpFile("txt")
	ControlSetText("���Ϊ", "������(&I):", 1148, $tmpFile, 1)
	ControlCommand("���Ϊ", "������(&I):", 1136, "SelectString", '���ı��ĵ�')
	Sleep(100)
	ControlSend("���Ϊ", "������(&I):", 1, "{enter}")
	If WinWait("Windows Live Messenger", "ȷ��", 20) == 0 Then
		logger("��MSN�Ի��н�����Ϣʧ�ܡ�2")
		Return $MSG_ERROR
	EndIf
	ControlClick("Windows Live Messenger", "ȷ��", 1)
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
	logger("����getStatusMsn��" & $cmd)
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



