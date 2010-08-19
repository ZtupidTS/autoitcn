#include "..\common.au3"
#NoTrayIcon

Local $file = ""
If $cmdLine[0] > 0 And FileExists($cmdLine[1]) Then
	$file = $cmdLine[1]
Else
	Exit
EndIf
Local $arg = ""
If $cmdLine[0] > 2 Then
	$arg = $cmdLine[2]
EndIf

Local $ext = getExt($file)
If $ext == "exe" Or $ext == "bat" Then
	Run ($file & " " & $arg, getPath($file))
	responseByIM("成功运行命令【" & $file & " " & $arg & "】")
ElseIf $ext == "" Then ; a directory
	Run ("C:\WINDOWS\explorer.exe " & $file, getPath($file))
	responseByIM("成功打开目录【" & "C:\WINDOWS\explorer.exe " & $file & " " & $arg & "】")
Else ;common file, maybe
	ShellExecute($file, $arg, getPath($file), "open")
	responseByIM("成功打开文件【" & $file & "】")
EndIf


Func getExt($file)
	Local $n = StringInStr($file, ".", 0, -1)
	If $n == 0 Then
		; it is a directory
		Return ""
	EndIf
	Return StringRight($file, StringLen($file) - $n)
EndFunc

Func getPath($file)
	Local $n = StringInStr($file, "\", 0, -1)
	If $n == 0 Then
		; impossible
		Return ""
	EndIf
	Return StringLeft($file, $n)
EndFunc
