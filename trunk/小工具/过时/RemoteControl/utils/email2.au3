#Include <file.au3>
#include "..\common.au3"
#NoTrayIcon
;##################################
; Variables
;##################################
$s_ToAddress = "oicqcx@hotmail.com"
$s_CcAddress = ""
$s_Subject = "unkown title"
$as_Body = "unkown body"
$s_AttachFiles = ""
Switch $cmdLine[0]
	Case 0
		Exit
	Case 1
		$s_ToAddress = $cmdLine[1]
		$s_CcAddress = ""
		$s_Subject = ""
		$as_Body = ""
		$s_AttachFiles = ""
	Case 2
		$s_ToAddress = $cmdLine[1]
		$s_CcAddress = $cmdLine[2]
		$s_Subject = ""
		$as_Body = ""
		$s_AttachFiles = ""
	Case 3
		$s_ToAddress = $cmdLine[1]
		$s_CcAddress = $cmdLine[2]
		$s_Subject = $cmdLine[3]
		$as_Body = ""
		$s_AttachFiles = ""
	Case 4
		$s_ToAddress = $cmdLine[1]
		$s_CcAddress = $cmdLine[2]
		$s_Subject = $cmdLine[3]
		$as_Body = getBody($cmdLine[4])
		$s_AttachFiles = ""
	Case 5
		$s_ToAddress = $cmdLine[1]
		$s_CcAddress = $cmdLine[2]
		$s_Subject = $cmdLine[3]
		$as_Body = getBody($cmdLine[4])
		$s_AttachFiles = $cmdLine[5]
		If Not FileExists($s_AttachFiles) Then
			$s_AttachFiles = ""
		EndIf
		
EndSwitch
; address for the smtp-server to use - REQUIRED
$s_SmtpServer = "smtp.163.com"
; name from who the email was sent
$s_FromName = "gogocx"
;  address from where the mail should come
$s_FromAddress = "gogocx@163.com"
; destination address of the email - REQUIRED
;~ $s_ToAddress = "oicqcx@hotmail.com"
; subject from the email - can be anything you want it to be
;~ $s_Subject = "oicqcx"
; the messagebody from the mail - can be left blank but then you get a blank mail
;~ $as_Body = "testing mail"
; address for cc - leave blank if not needed
;~ $s_CcAddress = ""
; the file you want to attach- leave blank if not needed
;~ $s_AttachFiles = "D:\MyDocuments\我接收到的文件\oicqcx794892358\历史记录\rmtctrl1862034163.xml, D:\MyDocuments\我接收到的文件\oicqcx794892358\历史记录\rongshuyan1101354262.xml"
; address for bcc - leave blank if not needed
$s_BccAddress = ""
; username for the account used from where the mail gets sent  - Optional (Needed for eg GMail)
$s_Username = "gogocx@163.com"
; password for the account used from where the mail gets sent  - Optional (Needed for eg GMail)
$s_Password = "5788312aling"
; port used for sending the mail
$IPPort = 25
; enables/disables secure socket layer sending - put to 1 if using httpS
$ssl = 0
; GMAIL port used for sending the mail
;~ $IPPort=465
; GMAILenables/disables secure socket layer sending - put to 1 if using httpS
;~ $ssl=1

;##################################
; Script
;##################################
Global $oMyRet[2]
Global $oMyError = ObjEvent("AutoIt.Error", "MyErrFunc")
$rc = _INetSmtpMailCom($s_SmtpServer, $s_FromName, $s_FromAddress, $s_ToAddress, $s_Subject, $as_Body, $s_AttachFiles, $s_CcAddress, $s_BccAddress, $s_Username, $s_Password, $IPPort, $ssl)
If @error Then
	logger("Error code:" & @error & "  Rc:" & $rc)
	Exit
EndIf
logger("发送【" & $s_Subject & "】成功！")

Func _INetSmtpMailCom($s_SmtpServer, $s_FromName, $s_FromAddress, $s_ToAddress, $s_Subject = "", $as_Body = "", $s_AttachFiles = "", $s_CcAddress = "", $s_BccAddress = "", $s_Username = "", $s_Password = "",$IPPort=25, $ssl=0)
    $objEmail = ObjCreate("CDO.Message")
    $objEmail.From = '"' & $s_FromName & '" <' & $s_FromAddress & '>'
    $objEmail.To = $s_ToAddress
    Local $i_Error = 0
    Local $i_Error_desciption = ""
    If $s_CcAddress <> "" Then $objEmail.Cc = $s_CcAddress
    If $s_BccAddress <> "" Then $objEmail.Bcc = $s_BccAddress
    $objEmail.Subject = $s_Subject
    If StringInStr($as_Body,"<") and StringInStr($as_Body,">") Then
        $objEmail.HTMLBody = $as_Body 
    Else
        $objEmail.Textbody = $as_Body & @CRLF
    EndIf
    If $s_AttachFiles <> "" Then
        Local $S_Files2Attach = StringSplit($s_AttachFiles, ";")
        For $x = 1 To $S_Files2Attach[0]
            $S_Files2Attach[$x] = _PathFull ($S_Files2Attach[$x])
            If FileExists($S_Files2Attach[$x]) Then
                $objEmail.AddAttachment ($S_Files2Attach[$x])
            Else
                $i_Error_desciption = $i_Error_desciption & @lf & 'File not found to attach: ' & $S_Files2Attach[$x]
                SetError(1)
                return 0
            EndIf
        Next
    EndIf
    $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
    $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = $s_SmtpServer
    $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = $IPPort
;Authenticated SMTP
    If $s_Username <> "" Then
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusername") = $s_Username
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendpassword") = $s_Password
    EndIf
    If $Ssl Then 
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
    EndIf
;Update settings
    $objEmail.Configuration.Fields.Update
; Sent the Message
    $objEmail.Send
    if @error then 
        SetError(2)
        return $oMyRet[1]
    EndIf
EndFunc ;==>_INetSmtpMailCom

Func getBody($file)
	If Not FileExists($file) Then
		Return $file
	EndIf
	Return FileRead($file)
EndFunc


; Com Error Handler
Func MyErrFunc()
    $HexNumber = Hex($oMyError.number, 8)
    $oMyRet[0] = $HexNumber
    $oMyRet[1] = StringStripWS($oMyError.description,3)
;~     ConsoleWrite("### COM Error !  Number: " & $HexNumber & "   ScriptLine: " & $oMyError.scriptline & "   Description:" & $oMyRet[1] & @LF) 
    SetError(1); something to check for when this function returns
    Return
EndFunc ;==>MyErrFunc