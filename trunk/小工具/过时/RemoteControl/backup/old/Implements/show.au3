#include <A3LScreenCap.au3>
#include "common.au3"


show()



;===============================================================================
;
; Function Name:	show()
; Description:		显示程序窗口实时图片，任务状态等
; 					show%%task, [window|process]
; 					task：用文本方式返回当前任务状态。缺省screen
; 					参数：window的时候返回所有在任务栏上的任务的名称
; 					process的时候返回所有进程的名称
; 					show%%screen, [window_name]
; 					screen：用图片方式返回当前屏幕的内容。参数：
; 					缺省，当前窗口的抓图；window_name返回指定窗口名称的抓图，
; 					如果window_name不存在，则按照缺省处理
; Parameter(s):		type:			查看的类型，取task或者screen，缺省screen
; 					arg:			task: 	window 当前正在运行的所有窗口，缺省
; 											process 当前正在运行的所有进程
; 									screen: window_name，如果windows_name为空，
; 														则当前显示当前窗口
; 					
; Return Value(s):  On Success - 无
;                   On Failure - 无
; Error Code:		10101 ~ 10110
; Author(s):        Chenxu
;
;===============================================================================
Func show()
	$taskName = RegRead($REG_BASE_CURRENT_TASK, "taskName")
	If $taskName <> "show" Then
		; 调用了email命令，但是任务却不是email
		_logger(10101)
		SetError(10101)
		Exit
	EndIf

	$task = RegRead($REG_BASE_CURRENT_TASK, "arg1")
	ConsoleWrite("$task_raw: " & $task & @CRLF)
	If $task <> "task" And $task <> "screen" Then
		$task = "screen"
	EndIf
	$arg = RegRead($REG_BASE_CURRENT_TASK, "arg2")
	If $arg <> "window" And $arg <> "process" Then
		If $task == "task" Then
			$arg = "window"
		Else
			$arg = ""
		EndIf
	EndIf
	
	ConsoleWrite($task & @CRLF)
	ConsoleWrite($arg & @CRLF)
	
	If $task == "task" And $arg == "window" Then
		$info = showWindows()
	EndIf
	If $task == "task" And $arg == "process" Then
		$info = showProcess()
	EndIf
	If $task == "screen" Then
		$info = showScreen($arg)
	EndIf
	
	ConsoleWrite($info & @CRLF)
EndFunc

Func showProcess()
	$list = ProcessList()
	$info = ""
	for $i = 1 to $list[0][0]
		$info = $info & "name: " & $list[$i][0] & ", id: " & $list[$i][1] & @CRLF
	next
	Return $info
EndFunc

Func showWindows()
	$info = ""
	$var = WinList()
	For $i = 1 to $var[0][0]
		; Only display visble windows that have a title
		If $var[$i][0] <> "" AND IsVisible($var[$i][1]) Then
			$info = $info & "title=" & $var[$i][0] & ", handle=" & $var[$i][1] & @CRLF
		EndIf
	Next
	Return $info
EndFunc

Func showScreen($win)
	If WinExists($win) Then
		WinActivate($win)
	EndIf
	$file = @ScriptDir & "\..\TempFiles\" & TimerInit() & ".jpg"
	_ScreenCap_Capture($file)
	Return $file
EndFunc

Func IsVisible($handle)
	If BitAnd( WinGetState($handle), 2 ) Then 
		Return 1
	Else
		Return 0
	EndIf
EndFunc













