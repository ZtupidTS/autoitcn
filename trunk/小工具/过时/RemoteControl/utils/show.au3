#include <A3LScreenCap.au3>
#include "..\common.au3"
#NoTrayIcon

Global $TYPE_TASK = "task"
Global $TYPE_SCREEN = "screen"
Global $TYPE_ARG_WINDOW = "window"
Global $TYPE_ARG_WINDOWS = "windows"
Global $TYPE_ARG_PROCESS = "process"

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
; Author(s):        Chenxu
;
;===============================================================================
Func show()
	$type = $TYPE_TASK
	$argument = $TYPE_ARG_PROCESS
	Switch $cmdLine[0]
	Case 0
	$type = $TYPE_TASK
	$argument = $TYPE_ARG_PROCESS
	Case 1
		$type = StringLower($cmdLine[1])
		$argument = $TYPE_ARG_PROCESS
	Case 2
		$type = StringLower($cmdLine[1])
		$argument = StringStripWS($cmdLine[2], 3)
	EndSwitch
	Local $info = "Invalid Arguments..."
	If $type == $TYPE_TASK Then
		If $argument == $TYPE_ARG_WINDOW Or $argument == $TYPE_ARG_WINDOWS Then
			$info = showWindows()
		ElseIf $argument == $TYPE_ARG_PROCESS Then
			$info = showProcess()
		EndIf
		Local $file = getTmpFile("txt")
		FileWrite($file, @ScriptFullPath & " " & $CmdLineRaw & @CRLF & @CRLF & $info)
		responseByEmail($file)
	ElseIf $type == $TYPE_SCREEN Then
		Local $jpgFile = showScreen($argument)
		Local $attachments[2] = [1, $jpgFile]
		responseByEmail(@ScriptFullPath & " " & $CmdLineRaw & @CRLF & @CRLF, $attachments)
	EndIf
EndFunc

Func showProcess()
	$list = ProcessList()
	$info = ""
	Local $append = @TAB
	for $i = 1 to $list[0][0]
		If StringLen($list[$i][1]) <= 2 Then
			$append = @TAB & @TAB
		Else
			$append = @TAB
		EndIf
		$info = $info & "id: " & $list[$i][1] & "," & $append & "name: " & $list[$i][0] & @CRLF
	next
	Return $info
EndFunc

Func showWindows()
	$info = ""
	$var = WinList()
	For $i = 1 to $var[0][0]
		; Only display visble windows that have a title
		If $var[$i][0] <> "" AND IsVisible($var[$i][1]) Then
			$info = $info & "handle: [" & $var[$i][1] & "], title: [" & $var[$i][0] & "]" & @CRLF
		EndIf
	Next
	Return $info
EndFunc

Func showScreen($win)
	Local $file = getTmpFile("jpg")
	If WinExists($win) Then
		WinActivate($win)
		Sleep(1000)
		Local $hWnd = WinGetHandle($win)
		_ScreenCap_CaptureWnd($file, $hWnd)
	Else
		_ScreenCap_Capture($file)
	EndIf
	; wait for the file being created
	For $i = 1 To 100
		Sleep(200)
		If FileExists($file) Then ExitLoop
	Next
	Return $file
EndFunc

Func IsVisible($handle)
	If BitAnd( WinGetState($handle), 2 ) Then 
		Return 1
	Else
		Return 0
	EndIf
EndFunc













