
#AutoIt3Wrapper_Icon = .\ico\27.ico
;~ ProcessClose("CQINTS~2.exe")
;~ Opt("TrayMenuMode",1)

;~ $exititem		= TrayCreateItem("Exit")

Local $t = TimerInit()
While 1
	TrayTip("����CheckIn", "���ڱ���CheckIn���룬���������ֹ��رձ����򣬵������������Թرձ�����" & @CRLF & _
		"���߱�����������15���Ӻ���Զ��رա�", 30)
	If TimerDiff($t) > 15 * 60 * 1000 Then Exit
	Sleep(500)
	If Not WinExists("Checkin", "&Associated Records:") Then ContinueLoop
	If Not ProcessExists("CQINTS~2.exe") Then
		MsgBox(48,"����CheckIn","����δ֪���������ԡ�")
		Exit
	EndIf
	ProcessClose("CQINTS~2.exe")
	If WinWait("trigger_coci", "����ʱ����", 30) == 0 Then
		MsgBox(48,"����CheckIn","����δ֪���������ԡ�")
		Exit
	EndIf
	WinClose("trigger_coci", "����ʱ����")
WEnd