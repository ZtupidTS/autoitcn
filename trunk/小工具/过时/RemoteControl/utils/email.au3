#include <INet.au3>
#Include <file.au3>
#include "..\common.au3"
#NoTrayIcon
;##################################
; Variables
;##################################
$s_ToAddress = "oicqcx@hotmail.com"
$s_CcAddress = ""
$s_Subject = "unkown title"
$as_Body = "unkown body"
Switch $cmdLine[0]
	Case 0
		Exit
	Case 1
		$s_ToAddress = $cmdLine[1]
		$s_CcAddress = ""
		$s_Subject = ""
		$as_Body = ""
	Case 2
		$s_ToAddress = $cmdLine[1]
		$s_CcAddress = $cmdLine[2]
		$s_Subject = ""
		$as_Body = ""
	Case 3
		$s_ToAddress = $cmdLine[1]
		$s_CcAddress = $cmdLine[2]
		$s_Subject = $cmdLine[3]
		$as_Body = ""
	Case 4
		$s_ToAddress = $cmdLine[1]
		$s_CcAddress = $cmdLine[2]
		$s_Subject = $cmdLine[3]
		$as_Body = getBody($cmdLine[4])
		
EndSwitch

If $cmdLine[0] < 4 Then
	_INetMail ( $s_ToAddress, $s_Subject, "The mail gets no body..." & @CRLF )
	If WinWait("�½���� - Lotus Notes", "�½����", 60) == 0 Then
		logger("Notesδ���������޷��½��ʼ���")
		Exit
	EndIf
	ControlClick("�½���� - Lotus Notes", "�½����", "[Text:����]")
	Exit
EndIf

Local $attachs[$cmdLine[0] - 2]
$attachs[0] = $cmdLine[0] - 3
Local $file = getTmpFile("txt")
FileWrite($file, $as_Body)
$attachs[1] = $file
For $i = 2 To $attachs[0]
	$attachs[$i] = $cmdLine[$i + 3]
Next
_INetMail ( $s_ToAddress, $s_Subject, "See file: " & $file & @CRLF )
If WinWait("�½���� - Lotus Notes", "�½����", 60) == 0 Then
	logger("Notesδ���������޷��½��ʼ���")
	Exit
EndIf
ControlFocus("�½���� - Lotus Notes", "�½����", "[Class:NotesRichText; Instance:1]")
For $i = 1 To $attachs[0]
	If Not FileExists($attachs[$i]) Then ContinueLoop
	WinMenuSelectItem("�½���� - Lotus Notes", "�½����", "�ļ�(&F)", "����(&A)...")
	If WinWait("��������", "���ҷ�Χ(&I):", 20) == 0 Then
		logger("��Ӹ�����" & $attachs[$i] & "��ʧ�ܡ�")
		ContinueLoop
	EndIf
	Local $attach = $attachs[$i]
	Local $ext = getExt($attachs[$i])
	If getExt($attachs[$i]) == "exe" Or _
		$ext == "vbs" Then
		; ֱ�ӷ���exe�ļ�һ���ʧ�ܡ������Ŀ���ļ�������һ����ط�Ȼ������֡�
		FileCopy($attachs[$i], getTmpPath() & "\" & getFileName($attachs[$i]), 1)
		$attach = getTmpPath() & "\" & getFileName($attachs[$i])
	EndIf
	ControlSetText("��������", "���ҷ�Χ(&I):", 1152, $attach)
	ControlSend("��������", "���ҷ�Χ(&I):", 1, "{enter}")
	If FileGetSize($attach) < 1024000 Then
		Sleep(2000)
	ElseIf FileGetSize($attach) < 10240000 Then
		Sleep(10000)
	Else
		Sleep(30000)
	EndIf
Next
ControlClick("�½���� - Lotus Notes", "�½����", "[Text:����]")
Exit

Func getFileName($file)
	Local $n = StringInStr($file, "\", 0, -1)
	Local $m = StringInStr($file, ".", 0, -1)
	If $n == 0 Then
		; it is a directory
		Return ""
	EndIf
	Return StringMid($file, $n + 1, $m - $n - 1)
EndFunc

Func getExt($file)
	Local $n = StringInStr($file, ".", 0, -1)
	If $n == 0 Then
		; it is a directory
		Return ""
	EndIf
	Return StringRight($file, StringLen($file) - $n)
EndFunc

Func getBody($file)
	If Not FileExists($file) Then
		Return $file
	EndIf
	Return FileRead($file)
EndFunc
