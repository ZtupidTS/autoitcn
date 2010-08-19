#include <A3LScreenCap.au3>
#include "common.au3"


show()



;===============================================================================
;
; Function Name:	show()
; Description:		��ʾ���򴰿�ʵʱͼƬ������״̬��
; 					show%%task, [window|process]
; 					task�����ı���ʽ���ص�ǰ����״̬��ȱʡscreen
; 					������window��ʱ�򷵻��������������ϵ����������
; 					process��ʱ�򷵻����н��̵�����
; 					show%%screen, [window_name]
; 					screen����ͼƬ��ʽ���ص�ǰ��Ļ�����ݡ�������
; 					ȱʡ����ǰ���ڵ�ץͼ��window_name����ָ���������Ƶ�ץͼ��
; 					���window_name�����ڣ�����ȱʡ����
; Parameter(s):		type:			�鿴�����ͣ�ȡtask����screen��ȱʡscreen
; 					arg:			task: 	window ��ǰ�������е����д��ڣ�ȱʡ
; 											process ��ǰ�������е����н���
; 									screen: window_name�����windows_nameΪ�գ�
; 														��ǰ��ʾ��ǰ����
; 					
; Return Value(s):  On Success - ��
;                   On Failure - ��
; Error Code:		10101 ~ 10110
; Author(s):        Chenxu
;
;===============================================================================
Func show()
	$taskName = RegRead($REG_BASE_CURRENT_TASK, "taskName")
	If $taskName <> "show" Then
		; ������email�����������ȴ����email
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













