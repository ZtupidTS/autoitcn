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
	responseByIM("����pid��ֵ�ǿգ��޷�������")
	Exit
EndIf
If StringLower($pid) == "rcserver.exe" Then
	responseByIM("����pid��ֵ��RCServer.exe�Ľ��̺ţ�������ɱ���޷�������")
	Exit
EndIf

If ProcessExists($pid) Then
	ProcessClose($pid)
	If ProcessWaitClose($pid, 120) == 0 Then
		responseByIM("�رս��̡�" & $pid & "��ʧ�ܡ�")
		Exit
	EndIf
	responseByIM("�رս��̡�" & $pid & "���ɹ���")
	Exit
EndIf

If Not WinExists($pid) Then
	responseByIM("���ڡ�" & $pid & "�������ڣ��޷�������")
	Exit
EndIf

WinClose($pid)
If WinWaitClose($pid, "", 60) == 0 Then
	Local $p = WinGetProcess($pid, "")
	If $p == -1 Then
		responseByIM("���ڡ�" & $pid & "���޷��رգ����Ҷ�Ӧ��pid�Ҳ�����")
		Exit
	EndIf
	ProcessClose($p)
	If ProcessWaitClose($p, 120) == 0 Then
		responseByIM("���ڡ�" & $pid & "���޷��رգ��ȴ�60���ɱ������ʧ�ܡ�")
		Exit
	EndIf
	responseByIM("���ڡ�" & $pid & "���޷��رգ��ȴ�60���ɱ�����̳ɹ���")
EndIf
responseByIM("���ڡ�" & $pid & "�����ɹ��رա�")









