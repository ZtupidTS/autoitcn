#Include <file.au3>
#include "common.au3"
#NoTrayIcon

Local $s_ToAddress = "oicqcx@hotmail.com"
Local $s_CcAddress = ""
Local $s_Subject = "unkown title"
Local $as_Body = "unkown body"
Local $s_AttachFiles = ""
Switch $cmdLine[0]
	Case 0
		_commandResponseByEmail(@ScriptFullPath & "无效参数。")
		Exit
	Case 1
		$s_ToAddress = $cmdLine[1]
		$s_Subject = ""
		$as_Body = ""
		$s_AttachFiles = ""
	Case 2
		$s_ToAddress = $cmdLine[1]
		$s_Subject = $cmdLine[2]
		$as_Body = ""
		$s_AttachFiles = ""
	Case 3
		$s_ToAddress = $cmdLine[1]
		$s_Subject = $cmdLine[2]
		$as_Body = $cmdLine[3]
		$s_AttachFiles = ""
	Case Else
		$s_ToAddress = $cmdLine[1]
		$s_Subject = $cmdLine[2]
		$as_Body = $cmdLine[3]
		Local $i
		For $i = 4 To $cmdLine[0]
			If Not FileExists($cmdLine[$i]) Then ContinueLoop
			$s_AttachFiles &= $cmdLine[$i] & ";"
		Next
		$s_AttachFiles = StringLeft($s_AttachFiles, StringLen($s_AttachFiles) - 1)
EndSwitch
	
_INetSmtpMailCom($s_ToAddress, $s_Subject, $as_Body, $s_AttachFiles)






