#include "common.au3"

#AutoIt3Wrapper_icon = "ico\daemon.ico"

Global $APP_NAME = "AC30 Helper"
Global $PROCESS_NAME_GUI = "AutoCheckingGUI.exe"
Global $APP_NAME_DAEMON = "AutoCheckingDaemon.exe"
Global $MSG_SUCCESS = "����ˢ���ɹ�"
Global $MSG_FAILED = "��������Ч����֤��"
Global $MSG_TIME_INVALID = "ˢ��ʱ����Ч"
Global $MSG_UNKOWN = "δ֪"

AutoItSetOption("TrayMenuMode", 1)
TraySetState(2)

$result = $MSG_UNKOWN
$flag = False
While 1
	Sleep(500)
	If WinExists("������ҳ����Ϣ", $MSG_SUCCESS) Then
		$result = $MSG_SUCCESS
	ElseIf WinExists("������ҳ����Ϣ", $MSG_FAILED) Then
		$result = $MSG_FAILED
	ElseIf WinExists("������ҳ����Ϣ", $MSG_TIME_INVALID) Then
		$result = $MSG_TIME_INVALID
	Else
		ContinueLoop
	EndIf
	RegWrite($regBase & "\swap", "result", "REG_SZ", $result)
	Sleep(20)
	ControlClick("������ҳ����Ϣ", $result, "[CLASS:Button; INSTANCE:1]")
	Exit
WEnd


