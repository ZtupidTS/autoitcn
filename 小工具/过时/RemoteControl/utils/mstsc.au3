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
	If WinExists($ip & " - Զ������", $ip & " - Զ������") Then
		MsgBox(0, "", "win existed")
		If WinExists("�Ͽ� Windows �Ự", "ȷ��") Then
			ControlClick("�Ͽ� Windows �Ự", "ȡ��", 2)
			If WinWaitClose("�Ͽ� Windows �Ự", "ȡ��", 30) == 0 Then
				logger("�޷�ȡ�����Ͽ� Windows �Ự���Ի���")
			EndIf
		EndIf
		responseByIM("Ŀ��Զ�̵�½�����Ѿ����ڡ�")
		Exit
	EndIf

	Run("C:\WINDOWS\system32\mstsc")
	If WinWait("Զ����������", "�����(&C):", 20) == 0 Then
		responseByIM("��mstscʧ�ܡ�")
		Exit
	EndIf
	If WinExists("Զ����������", "ѡ��(&O) >>") Then
		ControlClick("Զ����������", "ѡ��(&O) >>", 903)
		If WinWait("Զ����������", "ѡ��(&O) <<", 20) == 0 Then
			responseByIM("��mstscʧ�ܡ�")
			Exit
		EndIf
	EndIf
	ControlSetText("Զ����������", "ѡ��(&O) <<", 1007, $ip)
	ControlSetText("Զ����������", "ѡ��(&O) <<", 1009, $userName)
	ControlSetText("Զ����������", "ѡ��(&O) <<", 1010, $pwd)
	ControlClick("Զ����������", "ѡ��(&O) <<", 1)
	If WinWait($ip & " - Զ������", $ip & " - Զ������", 30) == 0 Then
		responseByIM("��¼" & $ip & "ʧ�ܡ�")
		Exit
	EndIf
	responseByIM("��¼" & $ip & "�ɹ���")
EndFunc

Func close()
	If Not WinExists($ip & " - Զ������", $ip & " - Զ������") Then
		responseByIM("Ŀ��Զ�̵�¼����" & $ip & "�����ڡ�")
		Exit
	EndIf
	WinClose($ip & " - Զ������", $ip & " - Զ������")
	If WinWait("�Ͽ� Windows �Ự", "ȷ��", 30) == 0 Then
		responseByIM("�ر�Ŀ��Զ�̵�¼����" & $ip & "ʧ�ܡ�")
		Exit
	EndIf
	ControlSend("�Ͽ� Windows �Ự", "ȷ��", 605, "{enter}")
	If WinWaitClose($ip & " - Զ������", $ip & " - Զ������", 30) == 0 Then
		responseByIM("�ر�Ŀ��Զ�̵�¼����" & $ip & "ʧ�ܡ�")
	Else
		responseByIM("�ر�Ŀ��Զ�̵�¼����" & $ip & "�ɹ���")
	EndIf
EndFunc


