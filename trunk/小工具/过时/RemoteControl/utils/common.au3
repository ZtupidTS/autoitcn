#include <File.au3>
#include <A3LWinAPI.au3>
#include "..\common.au3"
#include-once
Opt("RunErrorsFatal", 0)
Global $MSN_TITLE = getMsnTitle()

Func getMsnTitle()
	$MSN_TITLE = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Chenxu\RC", "MSNTitle")
	If $MSN_TITLE == "" Then
		logger("【" & @ScriptFullPath & "】因获取msn title而失败。")
		Exit
	EndIf
	Return $MSN_TITLE
EndFunc

Func responseByMsn($msg)
	Local $tmp, $start = 1
	Local $msgLen = 350
	Local $timer = TimerInit()
	Do
		WinActivate($MSN_TITLE)
		Sleep(200)
		$tmp = StringMid($msg, $start, $msgLen)
		$start = $start + $msgLen
		
		WinMove($MSN_TITLE, "", Default, Default, 700, 600)
		ClipPut($tmp)
		Sleep(200)
		WinMenuSelectItem($MSN_TITLE, "", "编辑(&E)", "粘贴(&P)")
		Sleep(200)
		ControlClick($MSN_TITLE, "", "[Class:DirectUIHWND]", "left", 1, 490, 514)
		Sleep(1000)
	Until StringLen($msg) <= $start Or TimerDiff($timer) >= 300000 Or Not WinExists($MSN_TITLE) ; 5min
EndFunc

Func responseByMsn_2($msg)
	Local $tmp, $start = 1
	Local $msgLen = 350
	Local $timer = TimerInit()
	WinActivate($MSN_TITLE)
	Sleep(200)
	Local $pos, $x, $y
	$pos = WinGetPos($MSN_TITLE)
	If IsArray($pos) Then
		$x = $pos[2] - 201
		$y = $pos[3] - 42
		RegWrite($REG_BASE, "MouseX", "REG_SZ", $x)
		RegWrite($REG_BASE, "MouseY", "REG_SZ", $y)
		logger($MSN_TITLE& " " & $pos[2] & ", " & $pos[3])
	Else
		$x = RegRead($REG_BASE, "MouseX")
		$y = RegRead($REG_BASE, "MouseY")
		If $x == "" Or $y == "" Then
			logger("因得不到【" & $MSN_TITLE & "】的大小而无法将信息【" & $msg & "】传递出去")
			Return
		EndIf
		logger("因得不到【" & $MSN_TITLE & "】的大小而可能无法将信息【" & $msg & "】传递出去")
	EndIf
	Do
		$tmp = StringMid($msg, $start, $msgLen)
		$start = $start + $msgLen
		WinMove($MSN_TITLE, "", Default, Default, 700, 600)
		ClipPut($tmp)
		Sleep(200)
		WinMenuSelectItem($MSN_TITLE, "", "编辑(&E)", "粘贴(&P)")
		Sleep(200)
		ControlClick($MSN_TITLE, "", "[Class:DirectUIHWND]", "left", 1, $x, $y)
		Sleep(1000)
	Until StringLen($msg) <= $start Or TimerDiff($timer) >= 300000 Or Not WinExists($MSN_TITLE) ; 5min
EndFunc

#region response
;
; 发送响应，这个函数中，千万不能调用 responseByIM()，否则可能产生无限递归。
; 如果通过email发送响应失败，就不再尝试了。
; 
; $msg 可以是一个文件名，如果是一个文件名的话，则会自动把这个文件中的内容读出来当作邮件的内容发送，
; 否则把$msg本身当作内容发送出去。
; $attachments 是一个附件 的列表，如果没有附件，留空就是了。这个数组的第一个参数是附件个数。
;
Func responseByEmail($msg = "", $attachments = "")
	$msg = StringStripWS($msg, 3)
	If FileExists($msg) Then
		logger("即将发送文件：【" & $msg & "】中的内容。")
	Else
		logger("即将发送文本：【" & $msg & "】")
	EndIf
	Local $subject = @ScriptName & " report, " & @ScriptFullPath & " " & $CmdLineRaw
	$subject = StringReplace($subject, '"', "'")
	Local $emailCmd = getRCBase() & '\utils\email.exe "oicqcx@hotmail.com, chen.xu8@zte.com.cn" "" "' & $subject & '" ' & '"' & $msg & '"'
	logger($emailCmd)
	If IsArray($attachments) Then
		$emailCmd = $emailCmd & ' "'
		For $i = 1 To $attachments[0]
			If Not FileExists($attachments[$i]) Then ContinueLoop
			$emailCmd = $emailCmd & $attachments[$i] & '" "'
		Next
		$emailCmd = StringLeft($emailCmd, StringLen($emailCmd) - 2)
	EndIf
	Run ($emailCmd, @ScriptDir)
EndFunc

Func responseByIM($msg = "")
	Local $hWnd = _getIMWinHandle()
	If $hWnd == 0 Then
		responseByEmail("获得IM的handle失败，通过IM发送响应失败。原响应内容【" & $msg & "】")
		Return
	EndIf
	If Not _API_IsWindowVisible($hWnd) Then
		_API_ShowWindow($hWnd, $SW_RESTORE)
		Sleep(1000)
	EndIf
	If WinMenuSelectItem("即时协同", "人事管理", "工具(&T)", "短信中心(&S)...") == 0 Then
		; IM不存在或者其他原因导致无法打开这个菜单，尝试重启一下IM试试看。
		If Not _startAndLoginIM() Then
			responseByEmail("重启IM失败，通过IM发送响应失败。原响应内容【" & $msg & "】")
			Return ""
		EndIf
		$hWnd = _getIMWinHandle()
		If $hWnd == 0 Then
			responseByEmail("获得IM的handle失败，通过IM发送响应失败。原响应内容【" & $msg & "】")
			Return
		EndIf
		If Not _API_IsWindowVisible($hWnd) Then
			_API_ShowWindow($hWnd, $SW_RESTORE)
			Sleep(1000)
		EndIf
		If WinMenuSelectItem("即时协同", "人事管理", "工具(&T)", "短信中心(&S)...") == 0 Then
			responseByEmail("找不到短信中心的菜单，通过IM发送响应失败。原响应内容【" & $msg & "】")
			Return
		EndIf
	EndIf
	If WinWait("短信中心", "短信中心", 30) == 0 Then
		responseByEmail("打开短信中心失败，通过IM发送响应失败。原响应内容【" & $msg & "】")
		Return
	EndIf
	ControlSetText("短信中心", "短信中心", 1001, "13913870410")
	ControlSetText("短信中心", "短信中心", 1685, $msg)
	ControlClick("短信中心", "短信中心", 1687)
	If WinWait("IM", "确定", 60) == 0 Then
		responseByEmail("IM发送短信失败。原响应内容【" & $msg & "】")
		WinClose("短信中心", "短信中心")
		WinWaitClose("短信中心", "短信中心")
		Return
	EndIf
	If WinExists("IM", "短信发送成功") Then
		logger("IM发送响应成功！")
	Else
		responseByEmail("IM发送短信失败。原响应内容【" & $msg & "】")
	EndIf
	WinClose("IM", "确定")
	WinWaitClose("IM", "确定")
	WinClose("短信中心", "短信中心")
	WinWaitClose("短信中心", "短信中心")
EndFunc

Func _startAndLoginIM()
	If ProcessExists("IM.exe") Then
		ProcessClose("IM.exe")
		If ProcessWaitClose("IM.exe", 60) == 0 Then
			logger("杀掉IM失败！")
			Return False
		EndIf
	EndIf
	Local $imPath = RegRead($REG_BASE, "IM")
	If Not FileExists($imPath & "\IM.exe") Then
		logger("IM路径配置错误，请在下面注册表项中修改【HKEY_LOCAL_MACHINE\SOFTWARE\Chenxu\RC\IM】")
		Return False
	EndIf
	Run ($imPath & "\IM.exe", $imPath)
	If WinWait("即时协同", "中文(&S)", 120) == 0 Then
		logger("IM无法启动，未知错误。无法通过IM发送响应。")
		Return False
	EndIf
	ControlClick("即时协同", "中文(&S)", 1081)
	If WinWait("登录", "用户名：", 20) == 0 Then
		logger("打开登陆窗口错误。")
		Return False
	EndIf
	ControlSetText("登录", "用户名：", 1001, 145812)
	ControlSetText("登录", "用户名：", 1015, "chX!145812", 1)
	ControlClick("登录", "用户名：", 1)
	; 如果IM在别的地方被登录过了，则需要确认登录，
	; 顺便等待20秒钟
	If WinWait("系统提示", "您的账号已经在其它机器上登录，是否要继续登录？", 20) Then
		ControlSend("系统提示", "您的账号已经在其它机器上登录，是否要继续登录？", 6, "{enter}")
		Sleep(20000)
	EndIf
	If WinWait("即时协同", "人事管理", 180) == 0 Then
		If WinExists("系统提示", "密码错误，请重新登录！") Then
			logger("密码错误，请修改密码。")
		Else
			logger("IM无法登陆，未知错误。")
		EndIf
		Return False
	EndIf
	; 再次确认IM启动成功，IM是在是不稳定，没办法
	If Not WinExists("即时协同", "人事管理") Then Return False
	; 启动成功了，不容易啊
	Return True
EndFunc

Func _getIMWinHandle()
	Local $im = _WinGetHandleByPID("IM.exe", -1)
	If @error Then
		logger("IM未运行或者有错误，尝试重启IM...")
		If Not _startAndLoginIM() Then
			responseByEmail("重启IM失败，通过IM发送响应失败。")
			Return 0
		EndIf
		$im = _WinGetHandleByPID("IM.exe", -1)
		If @error Then
			logger("IM重启错误！")
			Return 0
		EndIf
	EndIf
	If $im[0][0] == 0 Then
		logger("IM未运行或者有错误，尝试重启IM...")
		If Not _startAndLoginIM() Then
			responseByEmail("无法取得IM的handle，通过IM发送响应失败。")
			Return 0
		EndIf
		$im = _WinGetHandleByPID("IM.exe", -1)
		If @error Then
			logger("IM重启错误！")
			Return 0
		EndIf
	EndIf
	Local $hWnd
	For $i = 1 To $im[0][0]
		If $im[$i][0] == "即时协同" Then
			Return $im[$i][1]
		EndIf
	Next
	Return 0
EndFunc

; Get Window Handle by PID
;$nVisible = -1 "All (Visble or not)", $nVisible = 0 "Not Visible Only", $nVisible = 1 "Visible Only"
Func _WinGetHandleByPID($vProc, $nVisible = 1)
    $vProc = ProcessExists($vProc);
    If Not $vProc Then Return SetError(1, 0, 0)
    Local $aWL = WinList()
    Local $aTemp[UBound($aWL)][2], $nAdd = 0
    For $iCC = 1 To $aWL[0][0]
        If $nVisible = -1 And WinGetProcess($aWL[$iCC][1]) = $vProc Then
            $nAdd += 1
            $aTemp[$nAdd][0] = $aWL[$iCC][0]
            $aTemp[$nAdd][1] = $aWL[$iCC][1]
        ElseIf $nVisible = 0 And WinGetProcess($aWL[$iCC][1]) = $vProc And _
                BitAND(WinGetState($aWL[$iCC][1]), 2) = 0 Then
            $nAdd += 1
            $aTemp[$nAdd][0] = $aWL[$iCC][0]
            $aTemp[$nAdd][1] = $aWL[$iCC][1]
        ElseIf $nVisible > 0 And WinGetProcess($aWL[$iCC][1]) = $vProc And _
                BitAND(WinGetState($aWL[$iCC][1]), 2) Then
            $nAdd += 1
            $aTemp[$nAdd][0] = $aWL[$iCC][0]
            $aTemp[$nAdd][1] = $aWL[$iCC][1]
        EndIf
    Next
    If $nAdd = 0 Then Return SetError(2, 0, 0);No windows found
    ReDim $aTemp[$nAdd + 1][2]
    $aTemp[0][0] = $nAdd
    Return $aTemp
EndFunc

#endregion
;;;;;;;

Func OnAutoItStart ()
	$MSN_TITLE = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Chenxu\RC", "MSNTitle")
	If $MSN_TITLE == "" Then
		Exit
	EndIf
	WinMove($MSN_TITLE, "", Default, Default, 700, 600)
	ClipPut("收到命令【" & @ScriptFullPath & " " & $CmdLineRaw & "】")
	Sleep(200)
	WinMenuSelectItem($MSN_TITLE, "", "编辑(&E)", "粘贴(&P)")
	Sleep(200)
	ControlClick($MSN_TITLE, "", "[Class:DirectUIHWND]", "left", 1, 490, 514)
	Sleep(500)
EndFunc

Func OnAutoItExit ( )
    If @error Then
		logger(@ScriptFullPath & "因发生未知错误中途退出。")
		responseByMsn(@ScriptFullPath & "因发生未知错误中途退出。")
		Exit
	EndIf
	logger (@ScriptFullPath & "正常退出。")
	responseByMsn(@ScriptFullPath & "正常退出。")
EndFunc

