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













