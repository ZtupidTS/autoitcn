#include <File.au3>
#include <INet.au3>

Global $REG_BASE = "HKEY_LOCAL_MACHINE\SOFTWARE\CHX\RemoteControl"
Global $REG_BASE_TASKS = $REG_BASE & "\Tasks"
Global $REG_BASE_CURRENT_TASK = $REG_BASE_TASKS & "\_CurrentTask_"

Global $LOGGER_FILE = "rclog.log"

Global $CMD_SEPARATOR = ":"
Global $ARG_SEPARATOR = ","

Global $URL_INNER = "ftp://rmtctrl:rmtctrl@10.40.70.170:2121/CmdLine.txt"
Global $URL_OUTER = "ftp://ghost:ghost#^(@61.160.65.3/cx/CmdLine.txt"

Global $var1 = ""
Global $var2 = ""
Global $var3 = ""
Global $var4 = ""
Global $var5 = ""

;===============================================================================
;
; Function Name:	email()
; Description:		发送电子邮件
; Parameter(s):		$task		- 数组，第一个元素为taskName，第二个元素是参数个数
;								第三个以后的元素是该任务的参数
; 					
; Return Value(s):  On Success - 无
;                   On Failure - 无
; Error Code:		10081 ~ 10090
; Author(s):        Chenxu
;
;===============================================================================
Func emailByArray($task)
	If $task[0] == "" Then
		$task[0] = "UnnamedTask"
	EndIf
	$args = $task[1]
	If $args < 4 Then
		; wrong arguments
		_logger(10081)
		SetError(10081)
		Return
	EndIf
	
	$sendTo = $task[2]
	If $sendTo == "" Then $sendTo = "oicqcx@hotmail.com"
	$ccTo = $task[3]
	If $ccTo == "" Then $ccTo = ""
	$subject = $task[4]
	If $subject == "" Then $subject = "RC Command - Sending E-Mail"
	$content = $task[5]

	_logger("[email: " & $task[0] & "] Send To: " & $sendTo)
	_logger("[email: " & $task[0] & "] CC To: " & $ccTo)
	_logger("[email: " & $task[0] & "] Subject: " & $subject)

	_INetMail($sendTo, $subject, $content)
	WinWait("新建便笺 - Lotus Notes", "新建便笺", 60)
	If $ccTo <> "" Then
		ControlSend("新建便笺 - Lotus Notes", "新建便笺", "[Class:IRIS.tedit; Instance:6; ID:2347]", $ccTo)
	EndIf
	Sleep(200)

	For $i = 6 To $args + 1
		$attatchment = $task[$i]
		If Not FileExists($attatchment) Then
			_logger("[email: " & $task[0] & "] Attatchment not exists: " & $attatchment)
			ContinueLoop
		EndIf
		_logger("[email: " & $task[0] & "] Attatchment: " & $attatchment)
		ControlFocus("新建便笺 - Lotus Notes", "新建便笺", "[Class:NotesRichText; Instance:1]")
		Sleep(200)
		WinMenuSelectItem("新建便笺 - Lotus Notes", "新建便笺", "文件(&F)", "附加(&A)...")
		WinWait("创建附件", "查找范围(&I):", 60)
		ControlSend("创建附件", "查找范围(&I):", "[Class:Edit; Instance:1; ID:1152]", $attatchment)
		Sleep(200)
		ControlSend("创建附件","查找范围(&I):", "[Class:Button: Instance:2; ID:1]", "{ENTER}")
		WinWaitClose("创建附件", "查找范围(&I):", 60)
		
		Sleep(__timeWait(FileGetSize($attatchment)))
	Next
	ControlSend("新建便笺 - Lotus Notes", "新建便笺", "[Class:NotesLineView; Instance:1]", "!1")
	_logger("[email: " & $task[0] & "] Done!")
EndFunc

Func email($sendTo, _
				$taskName = "UnnamedTask", _
				$ccTo = "", _
				$subject = "RC Command - Sending E-Mail", _
				$content = "", _
				$att1 = "", _
				$att2 = "", _
				$att3 = "", _
				$att4 = "", _
				$att5 = "", _
				$att6 = "", _
				$att7 = "", _
				$att8 = "", _
				$att9 = "", _
				$att0 = "")
				
	Dim $task[16]
	$atts = 4
	If $att1 <> "" Then
		$atts = $atts + 1
		$task[6] = $att1
	EndIf
	If $att2 <> "" Then
		$atts = $atts + 1
		$task[7] = $att2
	EndIf
	If $att3 <> "" Then
		$atts = $atts + 1
		$task[8] = $att3
	EndIf
	If $att4 <> "" Then
		$atts = $atts + 1
		$task[9] = $att4
	EndIf
	If $att5 <> "" Then
		$atts = $atts + 1
		$task[10] = $att5
	EndIf
	If $att6 <> "" Then
		$atts = $atts + 1
		$task[11] = $att6
	EndIf
	If $att7 <> "" Then
		$atts = $atts + 1
		$task[12] = $att7
	EndIf
	If $att8 <> "" Then
		$atts = $atts + 1
		$task[13] = $att8
	EndIf
	If $att9 <> "" Then
		$atts = $atts + 1
		$task[14] = $att9
	EndIf
	If $att0 <> "" Then
		$atts = $atts + 1
		$task[15] = $att0
	EndIf
		
	$task[0] = $taskName
	$task[1] = $atts
	$task[2] = $sendTo
	$task[3] = $ccTo
	$task[4] = $subject
	$task[5] = $content
	
	emailByArray($task)
EndFunc

Func __timeWait($size)
	If $size < 100000 Then ;100k
		Return 400
	ElseIf $size < 1000000 Then ;1M
		Return 3000
	ElseIf $size < 10000000 Then ;10M
		Return 7000
	Else
		Return 30000
	EndIf
	Return 0
EndFunc

;===============================================================================
; Function Name:	errText()
; Description:		根据错误码获得错误的文本
; Parameter(s):		
; Return Value(s):  On Success - 错误码对应的文本
;                   On Failure - 不可能失败吧，鸵鸟算法，不管了
; Author(s):        Chenxu
;===============================================================================
Func _errText($code = -1)
	Switch $code
		Case 10001
			$msg = "[RemoteController] 命令成功"
		Case 10002
			$msg = "[RemoteController] 命令失败"
		Case 10003
			$msg = "[RemoteController] 命令：【&1】未配置路径"
		Case 10004
			$msg = "[RemoteController] 命令：【&1】在路径【&2】下不存在"
		Case 10005
			$msg = "[RemoteController] 执行命令【&1】"
		
		Case 10011
			$msg = "[taskSave] unkown error occured while saving task"
		Case 10012
			$msg = "[taskSave] unkown error occured while saving max id"
		Case 10013
			$msg = "[taskSave] unkown error occured while saving number of arguments"
		Case 10014
			$msg = "[taskSave] unkown error occured while saving arguments"
			
		Case 10021
			$msg = "[taskObtain] 错误任务信息，任务名为空"

		Case 10031
			$msg = "[parseCmdLine] 命令行为空"
			
		Case 10041
			$msg = "[recvCmdFromNotes] Lotus Notes未启动，无法接收命令"
		Case 10042
			$msg = "[recvCmdFromNotes] 接收到命令：&1"
		Case 10043
			$msg = "[recvCmdFromNotes] 打开临时文件【&1】出错"
			
		Case 10051
			$msg = "[receive] 接收到的命令：【&1】无效"
		Case 10052
			$msg = "[receive] 保存命令：【&1】失败，原因未知"
			
		Case 10061
			$msg = "[execReg] RC的实现：【&1】不存在"
			
		Case 10081
			$msg = "[email] 参数错误"
			
		Case 10091
			$msg = "[RC的实现：explorer] 调用了explorer命令，但是任务却不是explorer，肯定有地方搞错了，查一下吧"
			
		Case 10101
			$msg = "[RC的实现：show] 调用了show命令，但是任务却不是show，肯定有地方搞错了，查一下吧"
			
		Case -1
			$msg = "[unkown] unkown"
			
		Case Else
			$msg = "[unkown] unkown"
	EndSwitch

	Return $msg
EndFunc

Func _logger($code = -1)
	Local $MAX_VAR_COUNT = 5
	
	If StringIsDigit($code) Then
		$msg = _errText($code)
	Else
		$msg = $code
	EndIf
;~ 	$msg = $code
	While 1
		$n = StringInStr($msg, "&")
		If $n == 0 Then
			ExitLoop
		EndIf
		$tmp = StringMid($msg, $n + 1, 1)
		If $tmp >= 1 And $msg <= $MAX_VAR_COUNT Then
			Switch $tmp
				Case 1
					$tmp = $var1
				Case 2
					$tmp = $var2
				Case 3
					$tmp = $var3
				Case 4
					$tmp = $var4
				Case 5
					$tmp = $var5
				case Else
					$tmp = $var1
			EndSwitch
			$msg = StringLeft($msg, $n - 1) & $tmp & StringMid($msg, $n + 2)
		EndIf
	WEnd
	
	_FileWriteLog($LOGGER_FILE, $msg)
;~ 	ConsoleWrite($msg)
	If @error Then
		;unable to open or write to the specified log file, do something here
	EndIf
EndFunc













