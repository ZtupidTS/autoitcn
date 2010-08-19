#include <File.au3>

Global $REG_BASE = "HKEY_LOCAL_MACHINE\SOFTWARE\CHX\RemoteControl"
Global $REG_BASE_TASKS = $REG_BASE & "\Tasks"
Global $REG_BASE_CURRENT_TASK = $REG_BASE & "\_CurrentTask_"

Global $LOGGER_FILE = "rclog.log"

Global $CMD_SEPARATOR = ":"
Global $ARG_SEPARATOR = ","

Global $URL_INNER = "ftp://rmtctrl:rmtctrl@10.40.70.170:2121/CmdLine.txt"
Global $URL_OUTER = "ftp://ghost:ghost#^(@61.160.65.3/cx/CmdLine.txt"

Global $var1
Global $var2
Global $var3
Global $var4
Global $var5

;===============================================================================
; Function Name:	errText()
; Description:		���ݴ������ô�����ı�
; Parameter(s):		
; Return Value(s):  On Success - �������Ӧ���ı�
;                   On Failure - ������ʧ�ܰɣ������㷨��������
; Author(s):        Chenxu
;===============================================================================
Func _errText($code = -1)
	Switch $code
	Case 10011
		$msg = "[taskSave] unkown error occured while saving task"
	Case 10012
		$msg = "[taskSave] unkown error occured while saving max id"
	Case 10013
		$msg = "[taskSave] unkown error occured while saving number of arguments"
	Case 10014
		$msg = "[taskSave] unkown error occured while saving arguments"
		
	Case 10021
		$msg = "[taskObtain] ����������Ϣ��������Ϊ��"

	Case 10031
		$msg = "[parseCmdLine] ������Ϊ��"
		
	Case 10041
		$msg = "[recvCmdFromNotes] Lotus Notesδ�������޷���������"
	Case 10042
		$msg = "[recvCmdFromNotes] ���յ����&1"
		
	Case 10051
		$msg = "[receive] ���յ��������&1����Ч"
	Case 10052
		$msg = "[receive] ���������&1��ʧ�ܣ�ԭ��δ֪"
		
	Case 10061
		$msg = "[execReg] RC��ʵ�֣���&1��������"
		
	Case 10081
		$msg = "[RC��ʵ�֣�email] ������email�����������ȴ����email���϶��еط�����ˣ���һ�°�"
		
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













