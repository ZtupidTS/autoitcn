
Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 1)

Global Const $VERSION = "1.0.0"
Global Const $INI_FILE = @ScriptDir & "\conf.ini"
Global Const $PORT_OUT = 45812
Global Const $PORT_IN = 45813
Global Const $SEPERATOR = "_▼_"
Global Const $MAX_MSG_LEN = 1024

Global Const $APP_NAME = "会议室预定"
Global Const $MSG_BOX_INFO_OK = 8256
Global Const $MSG_BOX_CRITICAL_OK = 8208
Global Const $MSG_BOX_ALERT_OK = 8240
Global Const $MSG_BOX_QUESTION_YESNO = 8228
Global Const $MSG_BOX_QUESTION_NOYES = 8484
Global Const $MSG_BOX_QUESTION_YESNOCANCEL = 8227

Global $socketIn
Global $socketOut

Global $svrIp = IniRead($INI_FILE, "main", "serverip", "error")
If $svrIp == "error" Then
	MsgBox($MSG_BOX_CRITICAL_OK, $APP_NAME, "严重错误：请在文件" & $INI_FILE & "中配置正确的服务器地址。")
	Exit
EndIf
_startNerwork()

Func _sendMsg($cmd)
	If Not IsArray($cmd) Then Return False
	Local $i, $cmdRaw = $VERSION & $SEPERATOR
	For $i = 0 To UBound($cmd) - 1
		$cmdRaw &= $cmd[$i] & $SEPERATOR
	Next
	If StringLen($cmdRaw) <= StringLen($SEPERATOR) Then Return False
	$cmdRaw = StringLeft($cmdRaw, StringLen($cmdRaw) - StringLen($SEPERATOR))
	Local $i, $a = StringSplit($cmdRaw, "")
	For $i = 1 To $a[0]
		If AscW($a[$i]) >= 0x250 Then $cmdRaw &= "-"
	Next
	Local $status = UDPSend($socketOut, $cmdRaw)
	ConsoleWrite($cmdRaw & @CRLF)
	If $status == 0 Then Return False
	Return True
EndFunc   ;==>_SendMsg

Func _recvMsg($timeout = 0)
	Local $t = TimerInit(), $msg = ""
	If $timeout == 0 Then $timeout = 99999999
	Do
		$msg = UDPRecv ($socketIn, $MAX_MSG_LEN)
		Sleep(100)
	Until TimerDiff($t) > $timeout Or $msg <> ""
	If $msg == "" Then Return ""
	ConsoleWrite($msg & @CRLF)
	Local $cmd = StringSplit($msg, $SEPERATOR, 1)
	Return $cmd
EndFunc





Func _printMsg($msg)
	Local $i
	For $i = 0 To UBound($msg)-1
		ConsoleWrite("+ " & $msg[$i] & @CRLF)
	Next
EndFunc

Func _countChineseChar($s)
	Local $a = StringSplit($s, "")
	Local $iNonLatin = 0
	For $i = 1 To $a[0]
		If AscW($a[$i]) >= 0x250 Then  $iNonLatin += 1
	Next
	Return $iNonLatin
EndFunc




Func _startNerwork()
	UDPStartup()

	$socketOut = UDPOpen($svrIp, $PORT_OUT)
	If @error Then
		MsgBox(16, "会议室预定", "严重错误：初始化网络失败。")
		Exit
	EndIf
	
	$socketIn = UDPBind(@IPAddress1, $PORT_IN)
	If @error Then
		MsgBox(16, "会议室预定", "严重错误：初始化网络失败。")
		Exit
	EndIf
EndFunc   ;==>OnAutoItStart

Func OnAutoItExit()
    UDPCloseSocket($socketOut)
    UDPCloseSocket($socketIn)
    UDPShutdown()
EndFunc















