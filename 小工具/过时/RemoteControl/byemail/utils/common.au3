#Include <File.au3>
#include-once

Opt("MustDeclareVars", 1)

Global Const $LOG_FILE = @ScriptDir & "\log.log"
Global Const $INI_FILE = @ScriptDir & "\..\config.ini"
; 发送 email 服务器信息
Global Const $SMTP_SERVER = IniRead($INI_FILE, "pop3_info", "smtp", "error")
Global Const $SMTP_PORT = IniRead($INI_FILE, "pop3_info", "smtp_port", "error")
Global Const $FROM_NAME = IniRead($INI_FILE, "pop3_info", "from_name", "error")
Global Const $FROM_ADDRESS = IniRead($INI_FILE, "pop3_info", "from_addr", "error")
Global Const $SMTP_USER_NAME = IniRead($INI_FILE, "pop3_info", "user", "error")
Global Const $SMTP_PASSWORD = IniRead($INI_FILE, "pop3_info", "pwd", "error")
Global Const $AGENT_EMAIL_ADDR = IniRead($INI_FILE, "pop3_info", "agent", "error")
Global Const $SMTP_IS_SSL = 0

Func _commandResponseByEmail($body = "", $subject = "Remote Server Response")
	Local $body1
	If $body == "" Then
		$body1 = "来自" & @ScriptFullPath & "的响应。"
	Else
		$body1 = $body
	EndIf
	_FileWriteLog($LOG_FILE, $body1, 0)
	_INetSmtpMailCom($AGENT_EMAIL_ADDR, $subject, $body1)
EndFunc

Func _INetSmtpMailCom($s_ToAddress, $s_Subject = "", $as_Body = "", $s_AttachFiles = "")
	Local $s_SmtpServer = $SMTP_SERVER
	Local $s_FromName = $FROM_NAME
	Local $s_FromAddress = $FROM_ADDRESS
	Local $s_CcAddress = ""
	Local $s_BccAddress = ""
	Local $s_Username = $SMTP_USER_NAME
	Local $s_Password = $SMTP_PASSWORD
	Local $IPPort = $SMTP_PORT
	Local $ssl = $SMTP_IS_SSL
    Local $objEmail = ObjCreate("CDO.Message")
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
                Return 0
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
		Return 0
    EndIf
	Return True
EndFunc ;==>_INetSmtpMailCom

; Com Error Handler
Func _MyErrFunc()
	Local $oMyError = ObjEvent("AutoIt.Error", "_MyErrFunc")
	Local $HexNumber = Hex($oMyError.number, 8)
	Local $oMyRet[2]
	$oMyRet[0] = $HexNumber
	$oMyRet[1] = StringStripWS($oMyError.description,3)
	_FileWriteLog($LOG_FILE, "### COM Error !  Number: " & $HexNumber & "   ScriptLine: " & _
		$oMyError.scriptline & "   Description:" & $oMyRet[1] & @LF, 0) 
	SetError(1); something to check for when this function returns
	Return
EndFunc ;==>_MyErrFunc