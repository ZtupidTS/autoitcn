#include <Misc.au3>
#include "CommonConsts.au3"
#include "FTP.au3"
;#include <Array.au3>

;~ $taskName = "tn"
;~ Dim $args[3]
;~ $args[0] = 2
;~ $args[1] = "a1"
;~ $args[2] = "a2"
;~ TaskSave($taskName, $args)

;~ $task = taskObtain()
;~ If $task[0] == "" Then
;~ 	MsgBox(0, "savingTask", "no task")
;~ 	Exit
;~ EndIf
;~ $text = "name: " & $task[0] & @CRLF & _
;~ 		"args: " & $task[1] & @CRLF
;~ For $i = 2 to $task[1] + 1
;~ 	$text = $text & "arg" & ($i - 1) & ": " & $task[$i] & @CRLF
;~ Next
;~ MsgBox(0, "savingTask", $text)


;~ parseCmdLine("ac	:	now,   ar2,   ar3   ,    ar4")


;~ receive()


execReg()


;===============================================================================
;
; Function Name:	receive()
; Description:		接收任务，保存任务
; Parameter(s):		无
; Return Value(s):  On Success - 无
;                   On Failure - 无
; Error Code:		10051 ~ 10060
; Author(s):        Chenxu
;
;===============================================================================
Func receive()
	$cmd = recvCmdFromNotes()
	If $cmd == "" Then
		Return
	EndIf
	$task = parseCmdLine($cmd)
	If $task[0] == "" Then
		$var1 = $cmd
		_logger(10051)
		SetError(10051)
		Return
	EndIf
	$ret = taskSaveReg($task)
	If $ret == -1 Or $ret > 0 Then
		; error occured while saving task
		$var1 = $cmd
		_logger(10052)
		SetError(10052)
	EndIf
EndFunc

;===============================================================================
;
; Function Name:	execReg()
; Description:		执行任务。读取注册表中的任务信息
; Parameter(s):		无
; Return Value(s):  On Success - 返回 0
;                   On Failure - 错误码 or -1
; Error Code:		10061 ~ 10070
; Author(s):        Chenxu
;
;===============================================================================
Func execReg()
	$task = taskObtainReg()
	$implementedTask = @ScriptDir & "\Implements\" & $task[0] & ".exe"
	If Not FileExists($implementedTask) Then
		$var1 = $implementedTask
		_logger(10061)
		SetError(10061)
		Return 10061
	EndIf
	Run($implementedTask, @ScriptDir & "\Implements")
EndFunc

;===============================================================================
;
; Function Name:	taskSave()
; Description:		保存任务到内存中。
; Parameter(s):		$task		- 数组，第一个元素为taskName，第二个元素是参数个数
;								第三个以后的元素是该任务的参数
; Return Value(s):  On Success - 返回 0
;                   On Failure - 错误码 or -1
; Error Code:		10071 ~ 10080
; Author(s):        Chenxu
;
;===============================================================================
Func taskSave($task)
	
EndFunc

;===============================================================================
;
; Function Name:	taskSaveReg()
; Description:		保存任务到注册表中
; Parameter(s):		$task		- 数组，第一个元素为taskName，第二个元素是参数个数
;								第三个以后的元素是该任务的参数
; Return Value(s):  On Success - 返回 0
;                   On Failure - 错误码 or -1
; Error Code:		10011 ~ 10020
; Author(s):        Chenxu
;
;===============================================================================
Func taskSaveReg($task)
	; save task name
	$taskName = $task[0]
	If $taskName == "" Then
		; no valid task to save
		Return -1
	EndIf
	$maxId = RegRead($REG_BASE_TASKS, "maxTaskID")
	If $maxId == "" Then
		$maxId = 0
	EndIf
	$maxId = $maxId + 1
	$ret = RegWrite($REG_BASE_TASKS & "\" & $maxId, "taskName", "REG_SZ", $taskName)
	If $ret == 0 Then
		; unkown error occured while saving task
		_logger(10011)
		SetError(10011)
		Return 10011
	EndIf
	
	$ret = RegWrite($REG_BASE_TASKS, "maxTaskID", "REG_SZ", $maxId)
	If $ret == 0 Then
		; unkown error occured while saving max id
		_logger(10012)
		SetError(10012)
		Return 10012
	EndIf
	
	
	; save arguments
	If $task[1] == 0 Then
		; no argument to save
		Return 0
	EndIf
	$ret = RegWrite($REG_BASE_TASKS & "\" & $maxId, "args", "REG_SZ", $task[1])
	If $ret == 0 Then
		; unkown error occured while saving number of arguments
		_logger(10013)
		SetError(10013)
		Return 10013
	EndIf
	For $i = 2 To ($task[1] + 1)
		$ret = RegWrite($REG_BASE_TASKS & "\" & $maxId, "arg" & ($i - 1), "REG_SZ", $task[$i])
		If $ret == 0 Then
			; unkown error occured while saving arguments
			_logger(10014)
			SetError(10014)
			Return 10014
		EndIf
	Next
EndFunc

;===============================================================================
;
; Function Name:	taskObtainReg()
; Description:		从注册表中获取最近的第一个任务，解析成一个数组返回，
; 					同时写入_CurrentTask_中
; Parameter(s):		
; Return Value(s):  On Success - 数组，第一个元素为taskName，第二个元素是参数个数
;								第三个以后的元素是该任务的参数
;                   On Failure - 数组，第一个元素为 ""
; Error Code:		10021 ~ 10030
; Author(s):        Chenxu
;
;===============================================================================
Func taskObtainReg()
	$taskID = RegEnumKey($REG_BASE_TASKS, 1)
	If @error <> 0 then
		; no task saved
		; we can reset the max id of task here,
		; but, save the id seems to a good idea, it records how many tasks received
		Dim $task[1]
		$task[0] = ""
		Return $task
	EndIf
	
	$reg = $REG_BASE_TASKS & "\" & $taskID
	$taskName = RegRead($reg, "taskName")
	If $taskName == "" Then
		; invalid task, delete it
		RegDelete($reg)
		Dim $task[1]
		$task[0] = ""
		_logger(10021)
		SetError(10021)
		Return $task
	EndIf
	RegDelete($REG_BASE_TASKS & "\_CurrentTask_")
	RegWrite($REG_BASE_TASKS & "\_CurrentTask_", "taskName", "REG_SZ", $taskName)
	$args = RegRead($reg, "args")
	If $args == "" Then
		; no arguments, return the task
		Dim $task[2]
		$task[0] = $taskName
		$task[1] = 0
		RegDelete($reg)
		Return $task
	EndIf
	
	RegWrite($REG_BASE_TASKS & "\_CurrentTask_", "args", "REG_SZ", $args)
	Dim $task[$args + 2]
	$task[0] = $taskName
	$task[1] = $args
	For $i = 2 To $args + 1
		$task[$i] = RegRead($reg, "arg" & ($i - 1))
		RegWrite($REG_BASE_TASKS & "\_CurrentTask_", "arg" & ($i - 1), "REG_SZ", $task[$i])
	Next
	RegDelete($reg)
	Return $task
EndFunc

;===============================================================================
;
; Function Name:	parseCmdLine()
; Description:		将命令行解析成任务名称，任务参数等信息返回
; Parameter(s):		$line		- 命令行文本
; Return Value(s):  On Success - 数组，第一个元素为taskName，第二个元素是参数个数
;								第三个以后的元素是该任务的参数
;                   On Failure - 数组，第一个元素为 ""
; Error Code:		10031 ~ 10040
; Author(s):        Chenxu
;
; ■自动刷卡
; ac%%<add|del|show>, week, time
; ac%%add, 1, 0800
; ac%%del, 1, 2015
; ac%%show
;
; ■发送email
; email%%<sendTo>, [ccTo], [subject], [content], [attatchments]
; email%%oicqcx@hotmail.com, , suject, content, c:\att.rar
; email%%oicqcx@hotmail.com, , suject, file: c:\tmpcontent.txt, c:\att_1.rar, c:\att_2.rar
;
; ■开启windows的远程登录功能
; enable-windows-rmtctrl%%
;
; ■显示程序窗口实时图片，任务状态等
; show%%task, [window|process]
; task：用文本方式返回当前任务状态。
; 参数：window的时候返回所有在任务栏上的任务的名称
;       process的时候返回所有进程的名称
; show%%screen, [window_name]
; screen：用图片方式返回当前屏幕的内容。参数：缺省，当前窗口的抓图；window_name返回指定窗口名称的抓图，
; 如果window_name不存在，则按照缺省处理
;===============================================================================
Func parseCmdLine($line)
	If $line == "" Then
		; null line error
		_logger(10031)
		SetError(10031)
		Dim $task[1]
		$task[0] = ""
		Return $task
	EndIf
	
	$n = StringInStr($line, $CMD_SEPARATOR)
	If $n == 0 Then
		; no argument, only name of task
		Dim $task[2]
		$task[0] = $line
		$task[1] = 0
		Return $task
	EndIf
	$taskName = StringStripWS(StringLeft($line, $n - 1), 1 + 2)
	$argsLine = StringStripWS(StringMid($line, $n + 1), 1 + 2)
	$args = StringSplit($argsLine, $ARG_SEPARATOR)
	Dim $task[$args[0] + 2]
	$task[0] = $taskName
	$task[1] = $args[0]
	For $i = 2 To $args[0] + 1
		$task[$i] = StringStripWS($args[$i - 1], 1 + 2)
	Next
	Return $task
;~ 	_ArrayDisplay( $task, "Updated Array" )
;~ 	ConsoleWrite($n & @CRLF)
;~ 	ConsoleWrite($taskName & @CRLF)
;~ 	ConsoleWrite($argsLine & @CRLF)
EndFunc

Func recvCmdFromOuterFTP()

	$dllop=DllOpen('wininet.dll')
	$outerFtp = _FTPOpen("gv", 1, "proxysh.zte.com.cn", "80")

;~ 	$outerFtp = _FTPOpen("proxysh.zte.com.cn:80")
	ConsoleWrite($outerFtp & @CRLF)
	If @error == -1 Then
		ConsoleWrite("open ftp failed!" & @CRLF)
	EndIf
	$outerFtpConn = _FTPConnect($outerFtp, "61.160.65.3", "ghost", "ghost#^(", 21)
;~ 	$outerFtpConn = _FTPConnect($outerFtp, "10.40.70.170", "rmtctrl", "rmtctrl", 2121)
	If $outerFtpConn == 0 Then
		ConsoleWrite("conn ftp failed!" & @CRLF)
	EndIf
	_FTPPutFile($outerFtpConn, "E:\AutoItWork\RemoteControl\CmdLine.txt", "cx\CmdLine.txt")
	If @error == -1 Then
		ConsoleWrite("put file failed!" & @CRLF)
	EndIf
	_FTPClose($outerFtp)
	
	DllClose($dllop)

EndFunc

Func recvCmdFromInnerFTP()
	
EndFunc

;===============================================================================
;
; Function Name:	recvCmdFromNotes()
; Description:		在Lotus Notes中去接收包含命令的邮件，然后解析出命令行
; Parameter(s):		无
; Return Value(s):  On Success - 命令文本
;                   On Failure - ""
; Error Code:		10041 ~ 10050
; Author(s):        Chenxu
;
;===============================================================================
Func recvCmdFromNotes()
	If Not ProcessExists("NLNOTES.EXE") Then
		; Lotus Note not running, run it or do nothing
		_logger(10041)
		SetError(10041)
		Return ""
	EndIf
	
	Opt("WinTitleMatchMode", 2)
	Opt("TrayIconDebug",1)
	
	$file = @ScriptDir & "\TempFiles\" & TimerInit() & ".txt"
	
	If WinExists ( "Lotus Notes", "新建便笺" ) Then
		WinActivate("Lotus Notes", "新建便笺")
		WinWaitActive("Lotus Notes", "新建便笺")
	Else
		; activate Lotus Notes
		Run('"C:\Program Files\lotus\notes\notes.exe" "=C:\Program Files\lotus\notes\notes.ini"', "C:\Program Files\lotus\notes\")
		Sleep(30000)
	EndIf

	; 让notes打开RemoteControl页面，如果RemoteControl页面已经被打开，则需要切换到别的页面中来马上接收邮件
	If WinExists("陈旭145812 - !RemoteControlling - Lotus Notes", "陈旭145812") Then
		ControlSend("Lotus Notes", "陈旭145812", "[Class:NotesLineView; Instance:1]", "!b")
		Sleep(200)
		ControlSend("Lotus Notes", "陈旭145812", "[Class:NotesLineView; Instance:1]", "2")
		WinWait("陈旭145812 - !Empty - Lotus Notes", "陈旭145812")
	EndIf
	ControlSend("Lotus Notes", "陈旭145812", "[Class:NotesLineView; Instance:1]", "!b")
	Sleep(200)
	ControlSend("Lotus Notes", "陈旭145812", "[Class:NotesLineView; Instance:1]", "1")
	WinWait("陈旭145812 - !RemoteControlling - Lotus Notes", "陈旭145812")

	; 检查是否存在含有命令的邮件，如果不存在，返回 ""
	$tmp = ""
	ClipPut($tmp)
	WinMenuSelectItem("陈旭145812 - !RemoteControlling - Lotus Notes", "", "编辑(&E)", "拷贝选中内容为表格(&Y)")
	Sleep(500)
	$tmp = ClipGet ( )
	If $tmp == "" Then
		; no command received yet, return "" to caller
		Return ""
	EndIf
	
	; 存在含有命令的邮件，到处邮件的内存到文本文件中去，并且获得该命令文本
	WinMenuSelectItem("陈旭145812 - !RemoteControlling - Lotus Notes", "陈旭145812", "文件(&F)", "引出(&E)...")
	WinWait("引出", "保存在(&I):", 60)
	ControlSend("引出", "保存在(&I):", "[Class:Edit; Instance:1; ID:1152]", $file)
	Sleep(200)
	ControlSend("引出", "保存在(&I):", "[Class:Button; Instance:2; ID:1]", "{ENTER}")
	WinWait("引出结构化文本", "引出内容", 60)
	ControlSend("引出结构化文本", "引出内容", "[Class:Edit; Instance:2; ID:8]", "999")
	ControlSend("引出结构化文本", "引出内容", "[Class:Button; Instance:8; ID:1]", "{ENTER}")
	WinWaitClose("引出结构化文本", "引出内容", 20)
	ControlSend("陈旭145812 - !RemoteControlling - Lotus Notes", "陈旭145812", "[Class:NotesLineView; Instance:1]", "+{DEL}")
	$fileHdl = FileOpen($file, 0)
	Do
		$line = StringStripWS( FileReadLine($fileHdl), 1 + 2 )
		If $line == "" Then
			ExitLoop
		EndIf
	Until @error == -1
	If @error == -1 Then
		Return ""
	EndIf
	$line = StringStripWS( FileReadLine($fileHdl), 1 + 2 )
	$var1 = $line
	_logger("[recvCmdFromNotes] 接收到命令：&1")
	
	Return $line
EndFunc

Func isWorkingHour()
	; working hour: 08:00 ~ 17:59
	Return _Iif(@HOUR >= 8 and @HOUR <= 17, True, False)
EndFunc















