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
	If WinExists("RemoteControllingCommandSender — 对话") Then
		$title = "RemoteControllingCommandSender — 对话"
	ElseIf WinExists("*sierra(M) 陈旭 - (L)China — 对话") Then
		$title = "*sierra(M) 陈旭 - (L)China — 对话"
	Else
		Return
	EndIf
	WinMenuSelectItem($title, "", "文件(&F)", "另存为(&A)...")
	If WinWait("另存为", "保存在(&I):", 20) == 0 Then
		logger("从MSN对话中接收消息失败。1")
		WinClose($title)
		Return
	EndIf
	Local $tmpFile = getTmpFile("txt")
	ControlSetText("另存为", "保存在(&I):", 1148, $tmpFile, 1)
	ControlCommand("另存为", "保存在(&I):", 1136, "SelectString", '纯文本文档')
	Sleep(100)
	ControlSend("另存为", "保存在(&I):", 1, "{enter}")
	If WinWait("Windows Live Messenger", "确定", 20) == 0 Then
		logger("从MSN对话中接收消息失败。2")
		WinClose("另存为", "保存在(&I):")
		WinClose($title)
		Return
	EndIf
	ControlClick("Windows Live Messenger", "确定", 1)
	For $i = 1 To 100
		Sleep(100)
		If FileExists($tmpFile) Then ExitLoop
	Next
	Local $cmd = getCmd($tmpFile)
	If $cmd == "" Then
		logger("从MSN对话中接收消息失败。3")
		WinClose($title)
		Return
	EndIf
	Local $info = parseCmd($cmd)
	
	; 检查RCServer内部命令，内部命令的优先级高于其他命令
	If $info[1] == "switch" Then;切换msn帐号
		WinClose($title)
		Return
	EndIf
	Local $cmdLine
	Local $n, $timer, $pid, $isWait, $timeout
	For $i = 1 To $commands[0][0]
		If $commands[$i][0] == $info[1] Then
			$cmdLine = $commands[$i][1]
			If Not FileExists($cmdLine) Then
				logger("命令【" & $info[1] & "】对应的可执行路径无效【" & $cmdLine & "】")
				WinClose($title)
				Return
			EndIf
			For $j = 2 To $info[0]
				$cmdLine = $cmdLine & ' "' & $info[$j] & '"'
			Next
			$n = StringInStr($commands[$i][1], "\", 0, -1)
			logger("命令行【" & $cmdLine & "】")
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
				logger("命令行【" & $cmdLine & "】因执行超时而被强制杀掉。")
				ProcessClose($pid)
			EndIf
			WinClose($title)
			Return
		EndIf
	Next
	logger("命令【" & $info[1] & "】无匹配的配置项，请检查。")
	WinClose($title)
EndFunc

Func init()
;~ 	Local $imPath = RegRead($REG_BASE, "IM")
;~ 	Local $isContinue
;~ 	If Not FileExists($imPath & "\IM.exe") Then
;~ 		$isContinue = MsgBox(36, "远程控制","无效的IM参数，" & @CRLF & _
;~ 				"不影响RC Server，但是无法使用IM发送响应，是否继续？")
;~ 		If $isContinue == 7 Then
;~ 			Exit
;~ 		EndIf
;~ 	EndIf
;~ 	If Not FileExists(@ScriptDir & "\helper\com\cx\test\FileConverter.class") Then
;~ 		$isContinue = MsgBox(36, "远程控制","转换工具FileConverter不存在" & @CRLF & _
;~ 				"无法对中文字符进行正确的解析" & @CRLF & _
;~ 				"但是不影响对英文字符的解析，是否继续？")
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
	If StringInStr($cmd, "对方正在使用手机MSN,详见http://mobile.msn.com.cn。") Then
		; 第一次用msn发送消息，会被加上这么一句话，需要去掉
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
