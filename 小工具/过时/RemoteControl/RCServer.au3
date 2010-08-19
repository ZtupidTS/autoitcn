#include <File.au3>
#include "common.au3"
opt("MustDeclareVars", 1)
Opt("RunErrorsFatal", 0)

Global $msgFilePath
Global $jrePath
Global $commands[1]
init()


AdlibEnable("checkMessage", 2000)

While 1
	Sleep(20000)
WEnd

Func checkMessage()
	Local $title = ""
	If WinExists("RemoteControllingCommandSender �� �Ի�") Then
		$title = "RemoteControllingCommandSender �� �Ի�"
	ElseIf WinExists("*sierra(M) ���� - (L)China �� �Ի�") Then
		$title = "*sierra(M) ���� - (L)China �� �Ի�"
	Else
		Return
	EndIf
	WinMenuSelectItem($title, "", "�ļ�(&F)", "���Ϊ(&A)...")
	If WinWait("���Ϊ", "������(&I):", 20) == 0 Then
		logger("��MSN�Ի��н�����Ϣʧ�ܡ�1")
		WinClose($title)
		Return
	EndIf
	Local $tmpFile = getTmpFile("txt")
	ControlSetText("���Ϊ", "������(&I):", 1148, $tmpFile, 1)
	ControlCommand("���Ϊ", "������(&I):", 1136, "SelectString", '���ı��ĵ�')
	Sleep(100)
	ControlSend("���Ϊ", "������(&I):", 1, "{enter}")
	If WinWait("Windows Live Messenger", "ȷ��", 20) == 0 Then
		logger("��MSN�Ի��н�����Ϣʧ�ܡ�2")
		WinClose("���Ϊ", "������(&I):")
		WinClose($title)
		Return
	EndIf
	ControlClick("Windows Live Messenger", "ȷ��", 1)
	For $i = 1 To 100
		Sleep(100)
		If FileExists($tmpFile) Then ExitLoop
	Next
	Local $cmd = getCmd($tmpFile)
	If $cmd == "" Then
		logger("��MSN�Ի��н�����Ϣʧ�ܡ�3")
		WinClose($title)
		Return
	EndIf
	Local $info = parseCmd($cmd)
	
	; ���RCServer�ڲ�����ڲ���������ȼ�������������
	If $info[1] == "switch" Then;�л�msn�ʺ�
		WinClose($title)
		Return
	EndIf
	Local $cmdLine
	Local $n, $timer, $pid, $isWait, $timeout
	For $i = 1 To $commands[0][0]
		If $commands[$i][0] == $info[1] Then
			$cmdLine = $commands[$i][1]
			If Not FileExists($cmdLine) Then
				logger("���" & $info[1] & "����Ӧ�Ŀ�ִ��·����Ч��" & $cmdLine & "��")
				WinClose($title)
				Return
			EndIf
			For $j = 2 To $info[0]
				$cmdLine = $cmdLine & ' "' & $info[$j] & '"'
			Next
			$n = StringInStr($commands[$i][1], "\", 0, -1)
			logger("�����С�" & $cmdLine & "��")
			RegWrite($REG_BASE, "MSNTitle", "REG_SZ", $title)
			Sleep(200)
			$pid = Run($cmdLine, StringLeft($commands[$i][1], $n), @SW_HIDE)
			$isWait = StringLower(IniRead(@ScriptDir & "\config.ini", $i, "isWait", "true"))
			If $isWait <> "true" Then
				WinClose($title)
				Return
			EndIf
			$timeout = IniRead(@ScriptDir & "\config.ini", $i, "timeout", "300")
			If Not IsNumber($timeout) Then $timeout = 300
			$timer = TimerInit()
			If ProcessWaitClose($pid, $timeout) == 0 Then ; 5min
				logger("�����С�" & $cmdLine & "����ִ�г�ʱ����ǿ��ɱ����")
				ProcessClose($pid)
			EndIf
			WinClose($title)
			Return
		EndIf
	Next
	logger("���" & $info[1] & "����ƥ�����������顣")
	WinClose($title)
EndFunc

Func init()
;~ 	Local $imPath = RegRead($REG_BASE, "IM")
;~ 	Local $isContinue
;~ 	If Not FileExists($imPath & "\IM.exe") Then
;~ 		$isContinue = MsgBox(36, "Զ�̿���","��Ч��IM������" & @CRLF & _
;~ 				"��Ӱ��RC Server�������޷�ʹ��IM������Ӧ���Ƿ������")
;~ 		If $isContinue == 7 Then
;~ 			Exit
;~ 		EndIf
;~ 	EndIf
;~ 	If Not FileExists(@ScriptDir & "\helper\com\cx\test\FileConverter.class") Then
;~ 		$isContinue = MsgBox(36, "Զ�̿���","ת������FileConverter������" & @CRLF & _
;~ 				"�޷��������ַ�������ȷ�Ľ���" & @CRLF & _
;~ 				"���ǲ�Ӱ���Ӣ���ַ��Ľ������Ƿ������")
;~ 		If $isContinue == 7 Then
;~ 			Exit
;~ 		EndIf
;~ 	EndIf
	Local $sec = IniReadSectionNames(@ScriptDir & "\config.ini")
	ReDim $commands[ $sec[0] + 1 ][2]
	$commands[0][0] = $sec[0]
	For $i = 1 To $sec[0]
		$commands[$i][0] = IniRead(@ScriptDir & "\config.ini", $sec[$i], "cmdName", "error12345")
		$commands[$i][1] = IniRead(@ScriptDir & "\config.ini", $sec[$i], "cmdPath", "error12345")
			Next
	RegWrite($REG_BASE, "BaseDir", "REG_SZ", @ScriptDir)
EndFunc

Func getCmd($file)
	If Not FileExists($file) Then
		Return ""
	EndIf
	Local $msg = StringStripWS(FileRead($file), 3)
	If @error Or $msg == "" Then
		Return ""
	EndIf
	Local $n = StringInStr($msg, @CRLF, 0, -1)
	If $n == 0 Then
		Return $msg
	EndIf
	Local $cmd =  StringStripWS(StringRight($msg, StringLen($msg) - $n), 3)
	If StringInStr($cmd, "�Է�����ʹ���ֻ�MSN,���http://mobile.msn.com.cn��") Then
		; ��һ����msn������Ϣ���ᱻ������ôһ�仰����Ҫȥ��
		$cmd = StringRight($cmd, StringLen($cmd) - 40)
	EndIf
	Return $cmd
EndFunc

Func parseCmd($cmd)
	Local $n = StringInStr($cmd, ":")
	If $n == 0 Then
		Local $cmdInfo[3]
		$cmdInfo[0] = 2
		$cmdInfo[1] = StringStripWS($cmd, 3)
		$cmdInfo[2] = ""
		Return $cmdInfo
	EndIf
	$n = $n - 1
	Local $cn = StringStripWS(StringLeft($cmd, $n), 3)
	Local $arg = StringRight($cmd, StringLen($cmd) - $n - 1)
	Local $argArr = StringSplit($arg, ",")
	Local $cmdInfo[$argArr[0] + 2]
	$cmdInfo[0] = $argArr[0] + 1
	$cmdInfo[1] = $cn
	For $i = 1 To $argArr[0]
		$cmdInfo[$i + 1] = StringStripWS($argArr[$i], 3)
	Next
	Return $cmdInfo
EndFunc
