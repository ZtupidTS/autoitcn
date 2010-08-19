#include "TaskManager.au3"
#include <Array.au3>


Global $SLEEP_INTERVAL = 5 * 60 * 1000 ; 5 mins
Global $CONF = "RemoteControllingConf.ini"

;~ Dim $task[5] = [ "tn", "3", "a1", "a3", "a2"]

main()

Func main()
	While 1
;~ 		Sleep($SLEEP_INTERVAL)
		Sleep(5000)
		$task = receive()
;~ 		_ArrayDisplay( $task, "RemoteController" )
		If $task[0] == "" Then
			; no task received
			TrayTip("RemoteController", "no task received", 20)
			ContinueLoop
		EndIf
		
		If $task[0] == "email" Then
			sendEmail($task)
			ContinueLoop
		EndIf
		
		$taskPath = IniRead($CONF, "TaskMapping", $task[0], "___ERROR___")
		If $taskPath == "___ERROR___" Then
			$var1 = $task[0]
			_logger(10003)
			SetError(10003)
			ContinueLoop
		EndIf
		If Not FileExists($taskPath) Then
			$var1 = $task[0]
			$var2 = $taskPath
			_logger(10004)
			SetError(10004)
			ContinueLoop
		EndIf
		$cmd = $taskPath
		For $i = 1 to $task[1]
			$cmd = $cmd & " " & $task[$i + 1]
		Next
		$var1 = $cmd
		_logger("[RemoteController] ÷¥––√¸¡Ó°æ&1°ø")
		Run($cmd)
	WEnd
	
EndFunc


Func sendEmail($task)
	
EndFunc









