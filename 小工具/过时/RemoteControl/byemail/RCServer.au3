#Include <File.au3>
#include <Misc.au3>
#include "_pop3.au3"
#include "common.au3"

If _Singleton("chenxu_remote_control_server", 1) == 0 Then
	Exit
EndIf

_checkArg()
_FileWriteLog($LOG_FILE, "==============================================", 0)
AdlibEnable("check", 600000)
While 1
	Sleep(4000)
WEnd

Func check()
	_pop3Connect($POP3_SERVER, $POP3_USER, $POP3_PWD, $POP3_PORT)
	If @error <> 3 And @error <> 0 Then; @error == 3 already connected
		_FileWriteLog($LOG_FILE, "���ش�������POP3������ʧ�ܣ������룺" & @error, 0)
		Return
	EndIf
	Local $stat = _Pop3Stat()
	If Not IsArray($stat) Then
		_FileWriteLog($LOG_FILE, "����ʼ���ʱ����δ֪����" & $stat, 0)
		_Pop3Quit()
		_pop3Disconnect()
		Return
	EndIf
	If $stat[1] == 0 Then
		_Pop3Quit()
		_pop3Disconnect()
		Return
	EndIf
	
	;�յ��ʼ���
	Local $list = _Pop3List()
	If Not IsArray($list) Then
		_FileWriteLog($LOG_FILE, "List�ʼ���ʱ����δ֪����", 0)
		_Pop3Quit()
		_pop3Disconnect()
		Return
	EndIf
	Local $i, $mail, $sender, $cmd, $cmdInfo
	For $i = 1 To $list[0]
		$mail = _Pop3Retr($i)
		If @error Then
			_FileWriteLog($LOG_FILE, "�����ʼ���ʱ�������󣬴����룺" & @error, 0)
			ContinueLoop
		EndIf
		If Not _isSenderValid($mail) Then
			_FileWriteLog($LOG_FILE, "���յ�ɧ���ʼ���ɾ��֮��", 0)
			If Not _Pop3Dele($i)  Then _FileWriteLog($LOG_FILE, "ɾ���ʼ�ʧ�ܣ����ݣ�" & $cmd, 0)
			ContinueLoop
		EndIf
		$cmd = _getBody($mail)
		If $cmd == "" Then
			_FileWriteLog($LOG_FILE, "���յ���Ч����", 0)
			If Not _Pop3Dele($i)  Then _FileWriteLog($LOG_FILE, "ɾ���ʼ�ʧ�ܣ����ݣ�" & $cmd, 0)
			ContinueLoop
		EndIf
		_FileWriteLog($LOG_FILE, "���յ����" & $cmd, 0)
		If Not _Pop3Dele($i)  Then _FileWriteLog($LOG_FILE, "ɾ���ʼ�ʧ�ܣ����ݣ�" & $cmd, 0)
		$cmdInfo  = _parseCmd($cmd)
		_exe($cmdInfo)
	Next
	_Pop3Quit()
	_pop3Disconnect()
EndFunc

Func _exe($cmdInfo)
	If Not IsArray($cmdInfo) Then
		_FileWriteLog($LOG_FILE, "����� cmdInfo: " & $cmdInfo, 0)
		Return
	EndIf
	If $cmdInfo[1] == "" Then
		_FileWriteLog($LOG_FILE, "����ʶ������" & $cmdInfo[1], 0)
		Return
	EndIf
	FileChangeDir(@ScriptDir)
	Local $path = IniRead($INI_FILE, $cmdInfo[1], "path", "error")
	If Not FileExists($path) Then
		_commandResponseByEmail("���" & $cmdInfo[1] & "����·����Ч��")
		Return
	EndIf
	Local $i
	$path &= ' '
	For $i = 2 To $cmdInfo[0] + 1
		$path &= '"' & $cmdInfo[$i] & '" '
	Next
	_FileWriteLog($LOG_FILE, "ִ�����" & $path, 0)
	Run($path, ".\utils", @SW_HIDE)
EndFunc

#Region server functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;~ $cmdInfo[0] = ��������
;~ $cmdInfo[1] = ��������
;~ $cmdInfo[2...n] = �������
;~ $cmdInfo[n+1] = ԭʼ������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func _parseCmd($cmd)
	Local $n = StringInStr($cmd, ":")
	If $n == 0 Then
		Local $cmdInfo[3]
		$cmdInfo[0] = 0
		$cmdInfo[1] = StringStripWS($cmd, 3)
		$cmdInfo[2] = $cmd
		Return $cmdInfo
	EndIf
	$n = $n - 1
	Local $cn = StringStripWS(StringLeft($cmd, $n), 3)
	Local $arg = StringRight($cmd, StringLen($cmd) - $n - 1)
	Local $argArr = StringSplit($arg, ",")
	Local $cmdInfo[$argArr[0] + 3]
	$cmdInfo[0] = $argArr[0]
	$cmdInfo[1] = $cn
	For $i = 1 To $argArr[0]
		$cmdInfo[$i + 1] = StringStripWS($argArr[$i], 3)
	Next
	$cmdInfo[$i + 1] = $cmd
	Return $cmdInfo
EndFunc

Func _isSenderValid($mail)
	Return StringInStr($mail, $AGENT_EMAIL_ADDR)
EndFunc

Func _getBody($mail)
	Local $n = StringInStr($mail, "Content-Transfer-Encoding: quoted-printable")
	If $n == 0 Then
		Return _getBodyMobile($mail)
	EndIf
	$n = StringInStr($mail, @CR, 0, 1, $n) + 1
	If $n == 0 Then
		Return _getBodyMobile($mail)
	EndIf
	Local $m = StringInStr($mail, "------=_NextPart_", 0, 1, $n)
	If $m == 0 Or $m <= $n Then
		Return _getBodyMobile($mail)
	EndIf
	Local $body = StringStripWS(StringMid($mail, $n, $m - $n), 3)
	If $body <> "" Then Return  $body
	Return _getBodyMobile($mail)
EndFunc

Func _getBodyMobile($mail)
	Local $n = StringInStr($mail, "Content-Type:")
	If $n == 0 Then
		Return ""
	EndIf
	$n = StringInStr($mail, @CR, 0, 1, $n) + 1
	If $n == 0 Then
		Return ""
	EndIf
	Local $m = StringInStr($mail, "<br>", 0, 1, $n)
	If $m == 0 Or $m <= $n Then
		Return ""
	EndIf
	Return StringStripWS(StringMid($mail, $n, $m - $n), 3)
EndFunc

Func _checkArg()
	If $POP3_SERVER == "error" Or _
		$SMTP_SERVER == "error" Or _
		$POP3_USER == "error" Or _
		$POP3_PWD == "error" Or _
		$POP3_PORT == "error" Or _
		$SMTP_PORT == "error" Or _
		$AGENT_EMAIL_ADDR == "error" Then
		;MsgBox features: Title=No, Text=Yes, Buttons=OK, Icon=Critical
		MsgBox(16,"","���ش���POP3���������������")
		Exit
	EndIf
EndFunc
#EndRegion
;










