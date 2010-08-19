#include <file.au3>
#include "..\common.au3"
#NoTrayIcon

Local $n = 50
If $cmdLine[0] > 0 Then
	$n = $cmdLine[1]
EndIf
If $n <= 0 Then
	$n = 50
EndIf
Local $logFile = getRCBase() & "\log.log"

If Not FileExists ($logFile) Then
	responseByIM("log文件【" & $logFile & "】不存在。")
	Exit
EndIf
Local $log[1]
_FileReadToArray($logFile, $log)
If $log[0] <= $n Then
	responseByEmail($logFile)
	Exit
EndIf

Local $logCtxt = ""
For $i = $log[0] To $log[0] - $n Step -1
	$logCtxt = $log[$i] & @CRLF & $logCtxt
Next
Local $tmpFile = getTmpFile("txt")
FileWrite($tmpFile, $logCtxt)
responseByEmail($tmpFile)
