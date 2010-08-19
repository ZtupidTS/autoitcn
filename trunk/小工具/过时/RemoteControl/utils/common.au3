#include <File.au3>
#include <A3LWinAPI.au3>
#include "..\common.au3"
#include-once
Opt("RunErrorsFatal", 0)
Global $MSN_TITLE = getMsnTitle()

Func getMsnTitle()
	$MSN_TITLE = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Chenxu\RC", "MSNTitle")
	If $MSN_TITLE == "" Then
		logger("��" & @ScriptFullPath & "�����ȡmsn title��ʧ�ܡ�")
		Exit
	EndIf
	Return $MSN_TITLE
EndFunc

Func responseByMsn($msg)
	Local $tmp, $start = 1
	Local $msgLen = 350
	Local $timer = TimerInit()
	Do
		WinActivate($MSN_TITLE)
		Sleep(200)
		$tmp = StringMid($msg, $start, $msgLen)
		$start = $start + $msgLen
		
		WinMove($MSN_TITLE, "", Default, Default, 700, 600)
		ClipPut($tmp)
		Sleep(200)
		WinMenuSelectItem($MSN_TITLE, "", "�༭(&E)", "ճ��(&P)")
		Sleep(200)
		ControlClick($MSN_TITLE, "", "[Class:DirectUIHWND]", "left", 1, 490, 514)
		Sleep(1000)
	Until StringLen($msg) <= $start Or TimerDiff($timer) >= 300000 Or Not WinExists($MSN_TITLE) ; 5min
EndFunc

Func responseByMsn_2($msg)
	Local $tmp, $start = 1
	Local $msgLen = 350
	Local $timer = TimerInit()
	WinActivate($MSN_TITLE)
	Sleep(200)
	Local $pos, $x, $y
	$pos = WinGetPos($MSN_TITLE)
	If IsArray($pos) Then
		$x = $pos[2] - 201
		$y = $pos[3] - 42
		RegWrite($REG_BASE, "MouseX", "REG_SZ", $x)
		RegWrite($REG_BASE, "MouseY", "REG_SZ", $y)
		logger($MSN_TITLE& " " & $pos[2] & ", " & $pos[3])
	Else
		$x = RegRead($REG_BASE, "MouseX")
		$y = RegRead($REG_BASE, "MouseY")
		If $x == "" Or $y == "" Then
			logger("��ò�����" & $MSN_TITLE & "���Ĵ�С���޷�����Ϣ��" & $msg & "�����ݳ�ȥ")
			Return
		EndIf
		logger("��ò�����" & $MSN_TITLE & "���Ĵ�С�������޷�����Ϣ��" & $msg & "�����ݳ�ȥ")
	EndIf
	Do
		$tmp = StringMid($msg, $start, $msgLen)
		$start = $start + $msgLen
		WinMove($MSN_TITLE, "", Default, Default, 700, 600)
		ClipPut($tmp)
		Sleep(200)
		WinMenuSelectItem($MSN_TITLE, "", "�༭(&E)", "ճ��(&P)")
		Sleep(200)
		ControlClick($MSN_TITLE, "", "[Class:DirectUIHWND]", "left", 1, $x, $y)
		Sleep(1000)
	Until StringLen($msg) <= $start Or TimerDiff($timer) >= 300000 Or Not WinExists($MSN_TITLE) ; 5min
EndFunc

#region response
;
; ������Ӧ����������У�ǧ���ܵ��� responseByIM()��������ܲ������޵ݹ顣
; ���ͨ��email������Ӧʧ�ܣ��Ͳ��ٳ����ˡ�
; 
; $msg ������һ���ļ����������һ���ļ����Ļ�������Զ�������ļ��е����ݶ����������ʼ������ݷ��ͣ�
; �����$msg���������ݷ��ͳ�ȥ��
; $attachments ��һ������ ���б����û�и��������վ����ˡ��������ĵ�һ�������Ǹ���������
;
Func responseByEmail($msg = "", $attachments = "")
	$msg = StringStripWS($msg, 3)
	If FileExists($msg) Then
		logger("���������ļ�����" & $msg & "���е����ݡ�")
	Else
		logger("���������ı�����" & $msg & "��")
	EndIf
	Local $subject = @ScriptName & " report, " & @ScriptFullPath & " " & $CmdLineRaw
	$subject = StringReplace($subject, '"', "'")
	Local $emailCmd = getRCBase() & '\utils\email.exe "oicqcx@hotmail.com, chen.xu8@zte.com.cn" "" "' & $subject & '" ' & '"' & $msg & '"'
	logger($emailCmd)
	If IsArray($attachments) Then
		$emailCmd = $emailCmd & ' "'
		For $i = 1 To $attachments[0]
			If Not FileExists($attachments[$i]) Then ContinueLoop
			$emailCmd = $emailCmd & $attachments[$i] & '" "'
		Next
		$emailCmd = StringLeft($emailCmd, StringLen($emailCmd) - 2)
	EndIf
	Run ($emailCmd, @ScriptDir)
EndFunc

Func responseByIM($msg = "")
	Local $hWnd = _getIMWinHandle()
	If $hWnd == 0 Then
		responseByEmail("���IM��handleʧ�ܣ�ͨ��IM������Ӧʧ�ܡ�ԭ��Ӧ���ݡ�" & $msg & "��")
		Return
	EndIf
	If Not _API_IsWindowVisible($hWnd) Then
		_API_ShowWindow($hWnd, $SW_RESTORE)
		Sleep(1000)
	EndIf
	If WinMenuSelectItem("��ʱЭͬ", "���¹���", "����(&T)", "��������(&S)...") == 0 Then
		; IM�����ڻ�������ԭ�����޷�������˵�����������һ��IM���Կ���
		If Not _startAndLoginIM() Then
			responseByEmail("����IMʧ�ܣ�ͨ��IM������Ӧʧ�ܡ�ԭ��Ӧ���ݡ�" & $msg & "��")
			Return ""
		EndIf
		$hWnd = _getIMWinHandle()
		If $hWnd == 0 Then
			responseByEmail("���IM��handleʧ�ܣ�ͨ��IM������Ӧʧ�ܡ�ԭ��Ӧ���ݡ�" & $msg & "��")
			Return
		EndIf
		If Not _API_IsWindowVisible($hWnd) Then
			_API_ShowWindow($hWnd, $SW_RESTORE)
			Sleep(1000)
		EndIf
		If WinMenuSelectItem("��ʱЭͬ", "���¹���", "����(&T)", "��������(&S)...") == 0 Then
			responseByEmail("�Ҳ����������ĵĲ˵���ͨ��IM������Ӧʧ�ܡ�ԭ��Ӧ���ݡ�" & $msg & "��")
			Return
		EndIf
	EndIf
	If WinWait("��������", "��������", 30) == 0 Then
		responseByEmail("�򿪶�������ʧ�ܣ�ͨ��IM������Ӧʧ�ܡ�ԭ��Ӧ���ݡ�" & $msg & "��")
		Return
	EndIf
	ControlSetText("��������", "��������", 1001, "13913870410")
	ControlSetText("��������", "��������", 1685, $msg)
	ControlClick("��������", "��������", 1687)
	If WinWait("IM", "ȷ��", 60) == 0 Then
		responseByEmail("IM���Ͷ���ʧ�ܡ�ԭ��Ӧ���ݡ�" & $msg & "��")
		WinClose("��������", "��������")
		WinWaitClose("��������", "��������")
		Return
	EndIf
	If WinExists("IM", "���ŷ��ͳɹ�") Then
		logger("IM������Ӧ�ɹ���")
	Else
		responseByEmail("IM���Ͷ���ʧ�ܡ�ԭ��Ӧ���ݡ�" & $msg & "��")
	EndIf
	WinClose("IM", "ȷ��")
	WinWaitClose("IM", "ȷ��")
	WinClose("��������", "��������")
	WinWaitClose("��������", "��������")
EndFunc

Func _startAndLoginIM()
	If ProcessExists("IM.exe") Then
		ProcessClose("IM.exe")
		If ProcessWaitClose("IM.exe", 60) == 0 Then
			logger("ɱ��IMʧ�ܣ�")
			Return False
		EndIf
	EndIf
	Local $imPath = RegRead($REG_BASE, "IM")
	If Not FileExists($imPath & "\IM.exe") Then
		logger("IM·�����ô�����������ע��������޸ġ�HKEY_LOCAL_MACHINE\SOFTWARE\Chenxu\RC\IM��")
		Return False
	EndIf
	Run ($imPath & "\IM.exe", $imPath)
	If WinWait("��ʱЭͬ", "����(&S)", 120) == 0 Then
		logger("IM�޷�������δ֪�����޷�ͨ��IM������Ӧ��")
		Return False
	EndIf
	ControlClick("��ʱЭͬ", "����(&S)", 1081)
	If WinWait("��¼", "�û�����", 20) == 0 Then
		logger("�򿪵�½���ڴ���")
		Return False
	EndIf
	ControlSetText("��¼", "�û�����", 1001, 145812)
	ControlSetText("��¼", "�û�����", 1015, "chX!145812", 1)
	ControlClick("��¼", "�û�����", 1)
	; ���IM�ڱ�ĵط�����¼���ˣ�����Ҫȷ�ϵ�¼��
	; ˳��ȴ�20����
	If WinWait("ϵͳ��ʾ", "�����˺��Ѿ������������ϵ�¼���Ƿ�Ҫ������¼��", 20) Then
		ControlSend("ϵͳ��ʾ", "�����˺��Ѿ������������ϵ�¼���Ƿ�Ҫ������¼��", 6, "{enter}")
		Sleep(20000)
	EndIf
	If WinWait("��ʱЭͬ", "���¹���", 180) == 0 Then
		If WinExists("ϵͳ��ʾ", "������������µ�¼��") Then
			logger("����������޸����롣")
		Else
			logger("IM�޷���½��δ֪����")
		EndIf
		Return False
	EndIf
	; �ٴ�ȷ��IM�����ɹ���IM�����ǲ��ȶ���û�취
	If Not WinExists("��ʱЭͬ", "���¹���") Then Return False
	; �����ɹ��ˣ������װ�
	Return True
EndFunc

Func _getIMWinHandle()
	Local $im = _WinGetHandleByPID("IM.exe", -1)
	If @error Then
		logger("IMδ���л����д��󣬳�������IM...")
		If Not _startAndLoginIM() Then
			responseByEmail("����IMʧ�ܣ�ͨ��IM������Ӧʧ�ܡ�")
			Return 0
		EndIf
		$im = _WinGetHandleByPID("IM.exe", -1)
		If @error Then
			logger("IM��������")
			Return 0
		EndIf
	EndIf
	If $im[0][0] == 0 Then
		logger("IMδ���л����д��󣬳�������IM...")
		If Not _startAndLoginIM() Then
			responseByEmail("�޷�ȡ��IM��handle��ͨ��IM������Ӧʧ�ܡ�")
			Return 0
		EndIf
		$im = _WinGetHandleByPID("IM.exe", -1)
		If @error Then
			logger("IM��������")
			Return 0
		EndIf
	EndIf
	Local $hWnd
	For $i = 1 To $im[0][0]
		If $im[$i][0] == "��ʱЭͬ" Then
			Return $im[$i][1]
		EndIf
	Next
	Return 0
EndFunc

; Get Window Handle by PID
;$nVisible = -1 "All (Visble or not)", $nVisible = 0 "Not Visible Only", $nVisible = 1 "Visible Only"
Func _WinGetHandleByPID($vProc, $nVisible = 1)
    $vProc = ProcessExists($vProc);
    If Not $vProc Then Return SetError(1, 0, 0)
    Local $aWL = WinList()
    Local $aTemp[UBound($aWL)][2], $nAdd = 0
    For $iCC = 1 To $aWL[0][0]
        If $nVisible = -1 And WinGetProcess($aWL[$iCC][1]) = $vProc Then
            $nAdd += 1
            $aTemp[$nAdd][0] = $aWL[$iCC][0]
            $aTemp[$nAdd][1] = $aWL[$iCC][1]
        ElseIf $nVisible = 0 And WinGetProcess($aWL[$iCC][1]) = $vProc And _
                BitAND(WinGetState($aWL[$iCC][1]), 2) = 0 Then
            $nAdd += 1
            $aTemp[$nAdd][0] = $aWL[$iCC][0]
            $aTemp[$nAdd][1] = $aWL[$iCC][1]
        ElseIf $nVisible > 0 And WinGetProcess($aWL[$iCC][1]) = $vProc And _
                BitAND(WinGetState($aWL[$iCC][1]), 2) Then
            $nAdd += 1
            $aTemp[$nAdd][0] = $aWL[$iCC][0]
            $aTemp[$nAdd][1] = $aWL[$iCC][1]
        EndIf
    Next
    If $nAdd = 0 Then Return SetError(2, 0, 0);No windows found
    ReDim $aTemp[$nAdd + 1][2]
    $aTemp[0][0] = $nAdd
    Return $aTemp
EndFunc

#endregion
;;;;;;;

Func OnAutoItStart ()
	$MSN_TITLE = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Chenxu\RC", "MSNTitle")
	If $MSN_TITLE == "" Then
		Exit
	EndIf
	WinMove($MSN_TITLE, "", Default, Default, 700, 600)
	ClipPut("�յ����" & @ScriptFullPath & " " & $CmdLineRaw & "��")
	Sleep(200)
	WinMenuSelectItem($MSN_TITLE, "", "�༭(&E)", "ճ��(&P)")
	Sleep(200)
	ControlClick($MSN_TITLE, "", "[Class:DirectUIHWND]", "left", 1, 490, 514)
	Sleep(500)
EndFunc

Func OnAutoItExit ( )
    If @error Then
		logger(@ScriptFullPath & "����δ֪������;�˳���")
		responseByMsn(@ScriptFullPath & "����δ֪������;�˳���")
		Exit
	EndIf
	logger (@ScriptFullPath & "�����˳���")
	responseByMsn(@ScriptFullPath & "�����˳���")
EndFunc

