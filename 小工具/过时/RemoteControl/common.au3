#include <File.au3>
#include-once

Global $REG_BASE = "HKEY_LOCAL_MACHINE\SOFTWARE\Chenxu\RC"

Func getTmpFile($extention = "txt")
	Local $tmp = getTmpPath()
	If Not FileExists($tmp) Then
		DirCreate($tmp)
	EndIf
	Return $tmp & "\" & String(TimerInit()) & "." & $extention
EndFunc

Func getTmpPath()
	Return getRCBase() & "\utils\tmp"
EndFunc

Func getRCBase()
	Return RegRead($REG_BASE, "BaseDir")
EndFunc

Func logger($msg)
	Local $logFile = getRCBase() & "\log.log"
	_FileWriteLog($logFile, @ScriptName & ": " & $msg)
EndFunc

Func countChineseChar($s)
	Local $a = StringSplit($s, "")
	Local $iNonLatin = 0
	For $i = 1 To $a[0]
		If AscW($a[$i]) >= 0x250 Then  $iNonLatin += 1
	Next
	Return $iNonLatin
EndFunc

