; *******************************************************
; 
; 
; 
; *******************************************************
;
#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <IE.au3>
#include <File.au3>
#include <Misc.au3>
#include <GDIPlus.au3>
#Include <WinAPI.au3>
#include <ScreenCapture.au3>
#include "common.au3"
#AutoIt3Wrapper_icon = ".\ico\daemon.ico"

Global $MSG_SUCCESS = "网上刷卡成功"
Global $MSG_FAILED = "请输入有效的验证码"
Global $APP_NAME = "AC30 Daemon Tool"

If _Singleton("chenxu_AutoCheckingDaemon", 1) == 0 Then
	MsgBox(8256, $APP_NAME, "后台程序已经在运行...", 10)
	Exit
EndIf

#Region global variables
AutoItSetOption("MouseCoordMode", 0)
AutoItSetOption("PixelCoordMode", 0)
AutoItSetOption("MustDeclareVars", 1)
AutoItSetOption("TrayMenuMode",1)

Global $PROCESS_NAME_GUI = "AutoCheckingGUI.exe"
Global $PROCESS_NAME_HELPER = "AutoCheckingHelper.exe"

Global $MSG_SUCCESS = "网上刷卡成功"
Global $MSG_FAILED = "请输入有效的验证码"
Global $MSG_UNKOWN = "未知"

Global $MON_STATUS_DONE = "成功"
Global $MON_STATUS_EXECUTING = "正在执行"
Global $MON_STATUS_FAILED = "任务失败"
Global $MON_STATUS_RETRIED_DONE = "重试后成功"
Global $MON_STATUS_RETRIED_FAILED = "重试后失败"
Global $MON_STATUS_UNKOWN = "状态未知"

Global $guiHandle
Global $oIE
Global $GUIActiveX	

Global $trayItemAbout
Global $trayItemExit

; save the pid of myself
RegWrite($regBase, "pid", "REG_SZ", @AutoItPID)

;nonitor of task, if its value is "done", this is saying that the task is done
;if its value is "executing", this is saying that the task is been executing
;and maybe some error has happened
;in the situation, the scheduler() would try the task again
Global $monitor = $MON_STATUS_UNKOWN
;count of monitor retried times, generally, if the task has been retried for 10
;times and we still failed to finish it, we can say there is some unkown error has
;happened, stop retrying and give a warning to the user
Global $monitorCount = 0
;current task info
Global $MON_CURTASK_STATUS = "none"
Global $curTask = $MON_CURTASK_STATUS
Global $curTaskDetailInfo = $MON_CURTASK_STATUS

;记录任务的数组。这是一个三维的数组，看起来有点复杂了
;第一维是星期数，周一为1，周二为2，依此类推
;第二维是当天任务的标识，这里，每天的任务只有2个，如果由于错误的配置导致在注册表中有多个的话，取前2个
;第三维是区分小时和分钟数。一个任务都是由类似于这样的：08:00这样的5个字母组成，解析的时候把小时和分钟
;    分开存储，方便使用。
Global $timer[7][2][2] = [   _
		[["", ""], ["", ""]], _
		[["", ""], ["", ""]], _
		[["", ""], ["", ""]], _
		[["", ""], ["", ""]], _
		[["", ""], ["", ""]], _
		[["", ""], ["", ""]] ]

Global $picTxtPath = @ScriptDir & "\..\conf\pic-txt.txt"
Global $noticeFilePath = @ScriptDir & "\.."

Global $id = RegRead($regBase, "id")
Global $pwd = RegRead($regBase, "pwd")

Global $begin = TimerInit()
Global $totalTimeRan = RegRead($regBase, "totalTimeRan")
Global $interval =  17000  ;5 seconds
Global $maxRetryTime = 3

Global $jdkPath = RegRead($regBase, "jdkPath")
If @error == 1 Then
	MsgBox(8208, $APP_NAME, "严重错误：JDK/JRE路径未配置！")
	Exit
EndIf
If Not FileExists($jdkPath & "\bin\java.exe") Then
	MsgBox(8208, $APP_NAME, "严重错误：错误的JDK/JRE路径，程序将退出！")
	Exit
EndIf
Global $trayTips = "AC30 Daemon started successfully!"
TraySetToolTip($trayTips)

Global $isNotify = RegRead($regBase, "notify")
Global $cellNo = RegRead($regBase, "cellphoneNo")
#EndRegion
;

getTimer()
RegWrite($regBase, $REG_MESSAGE_KEY, "REG_SZ", "")
AdlibEnable("checkRegister4Command")
TrayTip($APP_NAME, "后台程序成功启动", 5)

While 1
	scheduler()
	Sleep($interval)
	Local $dif = TimerDiff($begin)
	If $dif >= 1200000 Then ;save the time diff very 20 min
		Local $begin = TimerInit()
		$totalTimeRan = $totalTimeRan + $dif
		saveTimeInfo()
	EndIf
WEnd

Func logger($code)
	;Log File
	Local $logFile = @ScriptDir & "\..\log.txt"
	_FileWriteLog($logFile, getErrorTextByErrorCode($code))
EndFunc

Func saveTimeInfo()
	RegWrite($regBase, "totalTimeRan", "REG_SZ", $totalTimeRan)
EndFunc

;**************************************************************************************
;
; 设置web浏览器的界面
; 
; 错误码分配：10041~10050
;
;**************************************************************************************
Func setLayout()
	Local $winHeigh = 480
	Local $winWidth = 640
	Local $browserHeigh = $winHeigh
	Local $browserWidth = $winWidth
	
	_IEErrorHandlerRegister ()
	If @error Then
		logger(10041)
		SetError(10041)
		Return
	EndIf
	$oIE = _IECreateEmbedded ()
	If @error Then
		logger(10042)
		SetError(10042)
		Return
	EndIf
	$guiHandle = GUICreate($APP_NAME, $winWidth, $winHeigh, _
			(@DesktopWidth - $winWidth) / 2, (@DesktopHeight - $winHeigh) / 2, _
			$WS_CAPTION + $WS_SYSMENU + $WS_MINIMIZEBOX + $WS_VISIBLE + $WS_CLIPSIBLINGS)
	If @error Then
		logger(10043)
		SetError(10043)
		Return
	EndIf
	
	$GUIActiveX = GUICtrlCreateObj($oIE, 0, 0, $browserWidth, $browserHeigh)
	
	_IENavigate ($oIE, "http://nj.atm.zte.com.cn")
	Switch @error
	Case 0
		;no error
	case 1
		;($_IEStatus_GeneralError) = General Error
		logger(10044)
		SetError(10044)
		Return
	Case 6
		;($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
		logger(10045)
		SetError(10045)
		Return
	Case 8
		;($_IEStatus_AccessIsDenied) = Access Is Denied
		logger(10046)
		SetError(10046)
		Return
	Case Else
		;($_IEStatus_GeneralError) = General Error
		logger(10044)
		SetError(10044)
		Return
	EndSwitch
		
	_IELoadWait ($oIE)
	If @error == 6 Then
		;($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
		logger(10047)
		SetError(10047)
		Return
	EndIf
	
	GUISetState()       ;Show GUI
	WinWait($APP_NAME, "", 60)
;~ 	WinSetOnTop($APP_NAME, "", 1)
EndFunc

;**************************************************************************************
;
; 登录到atm中
; 
; 错误码分配：10051~10060
;
;**************************************************************************************
Func login()
	Local $oForm = _IEFormGetObjByName ($oIE, "Form1")
	If @error == 7 Then
		logger(10051)
		SetError(10051)
		Return
	EndIf
	Local $oText = _IEFormElementGetObjByName ($oForm, "txtUserId")
	If @error == 7 Then
		logger(10052)
		SetError(10052)
		Return
	EndIf
	_IEFormElementSetValue ($oText, $id)
	Local $oPwd = _IEFormElementGetObjByName ($oForm, "txtPwd")
	_IEFormElementSetValue ($oPwd, $pwd)
	If @error == 7 Then
		logger(10052)
		SetError(10052)
		Return
	EndIf
	Local $oSubmit = _IEGetObjByName ($oIE, "btnLogin")
	If @error == 7 Then
		logger(10053)
		SetError(10053)
		Return
	EndIf
	_IEAction ($oSubmit, "click")
	_IELoadWait ($oIE)
	If @error == 6 Then
		logger(10054)
		SetError(10054)
		Return
	EndIf

	_IENavigate($oIE, "http://nj.atm.zte.com.cn/atm/Application/AboutMy/NetChkinout.aspx?oneName=%e4%b8%8e%e6%88%91%e6%9c%89%e5%85%b3-%e6%88%91%e7%9a%84%e8%80%83%e5%8b%a4-%e7%bd%91%e4%b8%8a%e5%88%b7%e5%8d%a1")
	If @error == 6 Then
		logger(10055)
		SetError(10055)
		Return
	EndIf
	
	_IELoadWait($oIE)
	If @error == 6 Then
		logger(10054)
		SetError(10054)
		Return
	EndIf

EndFunc

;**************************************************************************************
;
; 获得验证码，输入到web页面中的文本框中去
; 
; 错误码分配：10011~10020
;
;**************************************************************************************
Func putValidateCode($flag = True)
	Local $oForm = _IEFormGetObjByName ($oIE, "RemedyFormEplyApy")
	If @error == 3 Then
		logger(10011)
		SetError(10011)
		Return
	ElseIf @error == 7 Then
		logger(10012)
		SetError(10012)
		Return
	EndIf
	
	Local $oText = _IEFormElementGetObjByName ($oForm, "txtpas")
	If @error == 3 Then
		logger(10013)
		SetError(10013)
		Return
	ElseIf @error == 4 Then
		logger(10014)
		SetError(10014)
		Return
	ElseIf @error == 7 Then
		logger(10015)
		SetError(10015)
		Return
	EndIf
	
	Local $code = getValidateCode()
	If @error Then
		logger(10016)
		SetError(10016)
		Return
	EndIf
	
;~ 	Local $flag
	If $flag == True Then
		_IEFormElementSetValue ($oText, $code)
	Else
		WinSetOnTop($APP_NAME, "", 0)
		Local $gui_varify = GUICreate("验证码对比", 275, 99, 0, 0, Default, $WS_EX_MDICHILD, $guiHandle)
		GUICtrlCreatePic(@ScriptDir & "\pic.bmp", 205, 3, 63, 22, _
			BitOR($SS_NOTIFY,$WS_GROUP,$WS_CLIPSIBLINGS))
		GUICtrlSetResizing(-1, $GUI_DOCKAUTO)
		GUICtrlCreateLabel("计算得到的验证码是：" & $code, 8, 8)
		GUICtrlCreateLabel("和图片上显示的验证码是否一致？", 8, 32)
		Local $btn_yes = GUICtrlCreateButton("是", 112, 64, 75, 25, 0)
		Local $btn_no = GUICtrlCreateButton("否", 192, 64, 75, 25, 0)
		GUISetState(@SW_SHOW)

		Local $nMsg
		While 1
			$nMsg = GUIGetMsg()
			Switch $nMsg
				Case $btn_yes
					GUIDelete($gui_varify)
					ExitLoop
				Case $btn_no
					MsgBox(8208,$APP_NAME,"测试失败！")
					GUIDelete($gui_varify)
					Return
			EndSwitch
		WEnd
		_IEFormElementSetValue ($oText, $code & "1")
	EndIf
	If @error == 3 Then
		logger(10017)
		SetError(10017)
		Return
	ElseIf @error == 7 Then
		logger(10018)
		SetError(10018)
		Return
	EndIf
	
	Local $oSubmit = _IEGetObjByName ($oIE, "btnSubmit")
	If @error == 7 Then
		logger(10019)
		SetError(10019)
		Return
	EndIf
	If Not $flag And Not @error Then
		MsgBox(8256,$APP_NAME,"测试成功！")
	EndIf

	; reset the $regBase\swap\result value to unkown
	RegWrite($regBase & "\swap", "result", "REG_SZ", $MSG_UNKOWN)
	_IEAction ($oSubmit, "click")
	Sleep(1000)
	Local $result = RegRead($regBase & "\swap", "result")
	If $result <> $MSG_SUCCESS Then
		logger(10020)
		SetError(10020)
		Return
	EndIf
EndFunc

;**************************************************************************************
;
; 运行解析程序获得验证码
; 
; 错误码分配：10001~10010
;
;**************************************************************************************
Func getValidateCode()
	getPicText()
	If @error Then
		logger(10005)
		SetError(10005)
		Return ""
	EndIf
	RunWait($jdkPath & "\bin\java -cp autoChecking.jar com.cx.autochecking.AutoChecking", _
		@scriptdir, @SW_HIDE)
	Local $resultTxtPath = @ScriptDir & "\..\conf\result.txt"
	Local $code = FileRead($resultTxtPath)
	If @error Then
		logger(10002)
		SetError(10002)
		Return ""
	EndIf
	If $code == "error" Then
		logger(10003)
		SetError(10003)
		Return ""
	EndIf
	Local $n = StringInStr($code, "@")
	If $n <> 0 Then
		logger(10004)
		SetError(10004)
		Return ""
	EndIf
	
	Return $code
EndFunc

Func getPicText()
	Local $gifFile = @ScriptDir & "\pic.gif"
	FileDelete($gifFile)
	Local $bmpFile = @ScriptDir & "\pic.bmp"
	FileDelete($bmpFile)
	InetGet("http://nj.atm.zte.com.cn/atm/Application/AboutMy/CheckCode.aspx", $gifFile, 1)

	_GDIPlus_Startup()
	Local $hGif = _GDIPlus_ImageLoadFromFile ($gifFile)
	Local $hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap ($hGif)
	_ScreenCapture_SaveImage($bmpFile, $hBitmap)
	_GDIPlus_ImageDispose ($hGif)
	_WinAPI_DeleteObject ($hBitmap)
	_GDIPlus_Shutdown()
	Local $file = FileOpen($bmpFile, 16)
	Local $pic = FileRead($file)
	FileClose($file)
	Local $txt = "", $line = "", $i, $n = 0
	For $i = 501 To StringLen($pic) - 378 Step 6
		If StringLower(StringMid($pic, $i, 6)) == "ffffff" Then
			$line &= " "
		Else
			$line &= "*"
		EndIf
		$n += 1
		If $n == 61 Then
			$txt = $line & @CRLF & $txt
			$line = ""
			$i += 18
			$n = 0
		EndIf
	Next
	Local $file = FileOpen($picTxtPath, 2)
	FileWrite($file, $txt)
	FileClose($file)
EndFunc

;**************************************************************************************
;
; 运行解析程序获得验证码
; 
; 错误码分配：10021~10030
;
;**************************************************************************************
Func getTimer()
	$timer[0][0][0] = ""
	$timer[0][1][0] = ""
	$timer[0][0][1] = ""
	$timer[0][1][1] = ""
		
	$timer[1][0][0] = ""
	$timer[1][1][0] = ""
	$timer[1][0][1] = ""
	$timer[1][1][1] = ""
		
	$timer[2][0][0] = ""
	$timer[2][1][0] = ""
	$timer[2][0][1] = ""
	$timer[2][1][1] = ""
		
	$timer[3][0][0] = ""
	$timer[3][1][0] = ""
	$timer[3][0][1] = ""
	$timer[3][1][1] = ""
		
	$timer[4][0][0] = ""
	$timer[4][1][0] = ""
	$timer[4][0][1] = ""
	$timer[4][1][1] = ""
		
	$timer[5][0][0] = ""
	$timer[5][1][0] = ""
	$timer[5][0][1] = ""
	$timer[5][1][1] = ""
	
	Local $var
	For $i = 0 To 5 Step 1
		$var = RegEnumVal($regBase & "\" & $i + 1, 1)
		If @error > 0 Then
			$var = "" 
			logger(10021)
			SetError(10021)
		ElseIf @error == -1 Then
			$var = ""
			logger(10022) 
			SetError(10022)
		EndIf
		If $var <> "" Then
			$timer[$i][0][0] = StringLeft($var, 2)
			$timer[$i][0][1] = StringRight($var, 2)
		EndIf
			
		$var = RegEnumVal($regBase & "\" & $i + 1, 2)
		If @error > 0 Then
			$var = "" 
			logger(10021)
			SetError(10021)
		ElseIf @error == -1 Then
			$var = "" 
			logger(10022)
			SetError(10022)
		EndIf
		If $var <> "" Then
			$timer[$i][1][0] = StringLeft($var, 2)
			$timer[$i][1][1] = StringRight($var, 2)
		EndIf
	Next
EndFunc

;**************************************************************************************
;
; 检查任务是否需要开始执行
; 
; 错误码分配：10031~10040
;
;**************************************************************************************
Func scheduler()
	;已经有在执行的任务并且任务执行失败，重试次数少于10次，继续重试
	If $monitor == $MON_STATUS_EXECUTING And $monitorCount < $maxRetryTime Then
		logger(10031)
		checkNow()
		If @error Then
			Return
		EndIf
		TrayTip($APP_NAME, "任务：【" & $curTaskDetailInfo & "】重试" & $monitorCount & "次后成功！", 86400, 1)      ;86400 seconds = 1 day, long enough
		sms("任务：【" & $curTaskDetailInfo & "】重试" & $monitorCount & "次后成功！")
		logger(10032)
		monitorClose($MON_STATUS_RETRIED_DONE)
		Return
	EndIf
	;已经有在执行的任务并且任务执行失败，重试次数大于10次，放弃重试，给出出错信息
	If $monitor == $MON_STATUS_EXECUTING And $monitorCount >= $maxRetryTime Then
		logger(10033)
		;这里还需要给出出错任务的时间
		TrayTip($APP_NAME, "任务：【" & $curTaskDetailInfo & "】失败，请检查！", 86400, 3)
		TraySetToolTip(getTrayToolTip("任务：【" & $curTaskDetailInfo & "】失败，请检查！"))
		sms("任务：【" & $curTaskDetailInfo & "】失败，请检查！")
		monitorClose($MON_STATUS_RETRIED_FAILED)
		Return
	EndIf
	Local $wday = @WDAY - 2
	If $wday == -1 Then
		$wday = 6
	EndIf
	If $timer[$wday][0][0] == @HOUR And _
		$timer[$wday][0][1] == @MIN And _
		(@HOUR & ":" & @MIN) <> $curTask Then ;如果(@HOUR & ":" @MIN) <> $curTask 为True，表示当前任务已经执行过了，不需要重复执行
		sleepRandomSec(3, 8)
		monitorInit()
		checkNow()
		If @error Then
			logger(10001)
			SetError(10001)
			Return
		EndIf
		TrayTip($APP_NAME, "任务：【" & $curTaskDetailInfo & "】成功！", 86400, 1)      ;86400 = 1 day, long enough
		TraySetToolTip(getTrayToolTip("任务：【" & $curTaskDetailInfo & "】成功！"))
		sms("任务：【" & $curTaskDetailInfo & "】成功！")
		logger(10000)
		monitorClose($MON_STATUS_DONE)
	EndIf
	If $timer[$wday][1][0] == @HOUR And _
		$timer[$wday][1][1] == @MIN And _
		(@HOUR & ":" & @MIN) <> $curTask Then ;如果(@HOUR & ":" @MIN) <> $curTask 为True，表示当前任务已经执行过了，不需要重复执行
		sleepRandomSec(3, 8)
		monitorInit()
		checkNow()
		If @error Then
			logger(10001)
			SetError(10001)
			Return
		EndIf
		TrayTip($APP_NAME, "任务：【" & $curTaskDetailInfo & "】成功！", 86400, 1)      ;86400 = 1 day, long enough
		TraySetToolTip(getTrayToolTip("任务：【" & $curTaskDetailInfo & "】成功！"))
		sms("任务：【" & $curTaskDetailInfo & "】成功！")
		logger(10000)
		monitorClose($MON_STATUS_DONE)
	EndIf
EndFunc

;**************************************************************************************
;
; 执行任务，这个函数中不能有任何的类似于MsgBox这样的对话框弹出，否则可能会出错，
; 一切的错误信息都通过日志记录下来
; 
; 错误码分配：10061~10070
;
;**************************************************************************************
Func checkNow($flag = True)
	$monitorCount = $monitorCount + 1

	TrayTip($APP_NAME, "正在执行任务...", 60)
	
	If Not FileExists(@ScriptDir & "\" & $PROCESS_NAME_HELPER) Then
		logger(10072)
		TraySetIcon("warning")
		TrayTip($APP_NAME, "Helper程序【" & @ScriptDir & "\" & $PROCESS_NAME_HELPER & "】不存在，这是一个严重的错误！请检查并重启本后台程序！", 60)
		SetError(10072)
		Return
	EndIf
	If Not ProcessExists($PROCESS_NAME_HELPER) Then
		Run(@ScriptDir & "\" & $PROCESS_NAME_HELPER)
	EndIf
	
	setLayout()
	If @error Then
		GUIDelete()
		logger(10061)
		BlockInput(0)
		SetError(10061)
		If ProcessExists($PROCESS_NAME_HELPER) Then
			ProcessClose($PROCESS_NAME_HELPER)
		EndIf
		Return
	EndIf
	
	login()
	If @error Then
		GUIDelete()
		logger(10062)
		BlockInput(0)
		SetError(10062)
		If ProcessExists($PROCESS_NAME_HELPER) Then
			ProcessClose($PROCESS_NAME_HELPER)
		EndIf
		Return
	EndIf

	putValidateCode($flag)
	If @error Then
		GUIDelete()
		logger(10063)
		BlockInput(0)
		SetError(10063)
		If ProcessExists($PROCESS_NAME_HELPER) Then
			ProcessClose($PROCESS_NAME_HELPER)
		EndIf
		Return
	EndIf
	Sleep(5000)
	GUIDelete()
EndFunc

;**************************************************************************************
;
; 发送短消息到指定的手机号码
; 
; 错误码分配：10081 ~ 10090
;
;**************************************************************************************
Func sms($msg = "")
	Local $hWnd = _getIMWinHandle()
	If $hWnd == 0 Then
		Return
	EndIf
	If Not _WinAPI_IsWindowVisible($hWnd) Then
		_WinAPI_ShowWindow($hWnd, @SW_RESTORE)
		Sleep(1000)
	EndIf
	If WinMenuSelectItem("即时协同", "人事管理", "工具(&T)", "短信中心(&S)...") == 0 Then
		; IM不存在或者其他原因导致无法打开这个菜单，尝试重启一下IM试试看。
		If Not _startAndLoginIM() Then
			Return
		EndIf
		$hWnd = _getIMWinHandle()
		If $hWnd == 0 Then
			Return
		EndIf
		If Not _WinAPI_IsWindowVisible($hWnd) Then
			_WinAPI_ShowWindow($hWnd, @SW_RESTORE)
			Sleep(1000)
		EndIf
		If WinMenuSelectItem("即时协同", "人事管理", "工具(&T)", "短信中心(&S)...") == 0 Then
			Return
		EndIf
	EndIf
	If WinWait("短信中心", "短信中心", 30) == 0 Then
		Return
	EndIf
	ControlSetText("短信中心", "短信中心", 1001, $cellNo)
	ControlSetText("短信中心", "短信中心", 1685, $msg)
	ControlClick("短信中心", "短信中心", 1687)
	If WinWait("IM", "确定", 60) == 0 Then
		WinClose("短信中心", "短信中心")
		WinWaitClose("短信中心", "短信中心")
		Return
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
			Return False
		EndIf
	EndIf
	Local $imPath = RegRead($regBase, "IM")
	If Not FileExists($imPath & "\IM.exe") Then
		Return False
	EndIf
	Run ($imPath & "\IM.exe", $imPath)
	If WinWait("即时协同", "中文(&S)", 120) == 0 Then
		Return False
	EndIf
	ControlClick("即时协同", "中文(&S)", 1081)
	If WinWait("登录", "用户名：", 20) == 0 Then
		Return False
	EndIf
	ControlSetText("登录", "用户名：", 1001, RegRead($regBase, "id"))
	ControlSetText("登录", "用户名：", 1015, RegRead($regBase, "pwd"), 1)
	ControlClick("登录", "用户名：", 1)
	; 如果IM在别的地方被登录过了，则需要确认登录，
	; 顺便等待20秒钟
	If WinWait("系统提示", "您的账号已经在其它机器上登录，是否要继续登录？", 20) Then
		ControlSend("系统提示", "您的账号已经在其它机器上登录，是否要继续登录？", 6, "{enter}")
		Sleep(20000)
	EndIf
	If WinWait("即时协同", "人事管理", 180) == 0 Then
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
		If Not _startAndLoginIM() Then
			Return 0
		EndIf
		$im = _WinGetHandleByPID("IM.exe", -1)
		If @error Then
			Return 0
		EndIf
	EndIf
	If $im[0][0] == 0 Then
		logger("IM未运行或者有错误，尝试重启IM...")
		If Not _startAndLoginIM() Then
			Return 0
		EndIf
		$im = _WinGetHandleByPID("IM.exe", -1)
		If @error Then
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

;**************************************************************************************
;
; 随即休眠一段时间，介于[$min*60, ($max-1)*60 + 随机秒数]之间
; 
; 错误码分配：null
;
;**************************************************************************************
Func sleepRandomSec($min, $max)
	Local $rdmMin = Random($min, $max - 1, 1)
	Local $rdmSec = Random(0, 59, 1)
	Local $millisecond = $rdmMin * 60 * 1000 + $rdmSec * 1000
	TrayTip($APP_NAME, "随机延迟" & $millisecond/1000 & "秒钟后开始执行任务..." & @CRLF & _
						"任务开始后，所有的鼠标和键盘的东西会全部被阻挡。" & @CRLF & _
						"用Ctrl+Alt+Del可以重新获得对鼠标和键盘的控制。", $millisecond/1000, 1)
	Sleep($millisecond)
EndFunc

;**************************************************************************************
;
; 设置任务栏提示信息
; 
; 错误码分配：null
;
;**************************************************************************************
Func getTrayToolTip($tip = "")
	If $tip == "" Then
		Return $trayTips
	EndIf
	$trayTips = $trayTips & @CRLF & $tip
	Local $n = StringInStr($trayTips, @CRLF, 2, -4)
	If $n == 0 Then
		Return $trayTips
	EndIf
	$trayTips = StringMid($trayTips, $n + 2)
	Return $trayTips
EndFunc

;initiate the monitor
Func monitorInit()
	$monitorCount = 0
	$curTask = @HOUR & ":" & @MIN
	$curTaskDetailInfo = @YEAR & "-" & @MON & "-" & @MDAY & " " & $curTask
	$monitor = $MON_STATUS_EXECUTING
EndFunc

;close the monitor
Func monitorClose($flag)
	$monitorCount = 0
	If $flag <> $MON_STATUS_DONE And _
		$flag <> $MON_STATUS_EXECUTING And _
		$flag <> $MON_STATUS_RETRIED_DONE And _
		$flag <> $MON_STATUS_RETRIED_FAILED And _
		$flag <> $MON_STATUS_UNKOWN Then
		$flag = $MON_STATUS_UNKOWN
	EndIf
	$monitor = $flag
EndFunc


Func checkRegister4Command()
	Local $msg = RegRead($regBase, $REG_MESSAGE_KEY)
	RegWrite($regBase, $REG_MESSAGE_KEY, "REG_SZ", "")
	If $msg == $MESSAGE_SHOW_TASK_INFO Then
		showTaskInfo()
	ElseIf $msg == $MESSAGE_TERMINATE Then
		terminate()
	ElseIf $msg == $MESSAGE_SHOW_CURRENT_TIMER Then
		showCurTimer()
	ElseIf $msg == $MESSAGE_RELOAD_TIMER Then
		reloadTimer()
	ElseIf $msg == $MESSAGE_IMMEDIATE_CHECK Then
		immediateCheck()
	ElseIf $msg == $MESSAGE_IMMEDIATE_CHECK_TEST Then
		immediateCheckTest()
	ElseIf $msg == $MESSAGE_RELOAD_CONF Then
		reloadConf()
	Else
		Return
	EndIf
EndFunc

Func terminate()
	Local $dif = TimerDiff($begin)
	$totalTimeRan = $totalTimeRan + $dif
	saveTimeInfo()
	Exit
EndFunc

Func showCurTimer()
	MsgBox(8256, $APP_NAME, _
		"          周一     周二      周三     周四     周五     周六      " & @CRLF & @CRLF & _
		"上：  " & _
		_Iif($timer[0][0][0] <> "", $timer[0][0][0], "    " ) & ":" & _Iif($timer[0][0][1] <> "", $timer[0][0][1], "    " ) & "    " & _
		_Iif($timer[1][0][0] <> "", $timer[1][0][0], "    " ) & ":" & _Iif($timer[1][0][1] <> "", $timer[1][0][1], "    " ) & "    " & _
		_Iif($timer[2][0][0] <> "", $timer[2][0][0], "    " ) & ":" & _Iif($timer[2][0][1] <> "", $timer[2][0][1], "    " ) & "    " & _
		_Iif($timer[3][0][0] <> "", $timer[3][0][0], "    " ) & ":" & _Iif($timer[3][0][1] <> "", $timer[3][0][1], "    " ) & "    " & _
		_Iif($timer[4][0][0] <> "", $timer[4][0][0], "    " ) & ":" & _Iif($timer[4][0][1] <> "", $timer[4][0][1], "    " ) & "    " & _
		_Iif($timer[5][0][0] <> "", $timer[5][0][0], "    " ) & ":" & _Iif($timer[5][0][1] <> "", $timer[5][0][1], "    " ) & "    " & @CRLF & _
		"下：  " & _
		_Iif($timer[0][1][0] <> "", $timer[0][1][0], "    " ) & ":" & _Iif($timer[0][1][1] <> "", $timer[0][1][1], "    " ) & "    " & _
		_Iif($timer[1][1][0] <> "", $timer[1][1][0], "    " ) & ":" & _Iif($timer[1][1][1] <> "", $timer[1][1][1], "    " ) & "    " & _
		_Iif($timer[2][1][0] <> "", $timer[2][1][0], "    " ) & ":" & _Iif($timer[2][1][1] <> "", $timer[2][1][1], "    " ) & "    " & _
		_Iif($timer[3][1][0] <> "", $timer[3][1][0], "    " ) & ":" & _Iif($timer[3][1][1] <> "", $timer[3][1][1], "    " ) & "    " & _
		_Iif($timer[4][1][0] <> "", $timer[4][1][0], "    " ) & ":" & _Iif($timer[4][1][1] <> "", $timer[4][1][1], "    " ) & "    " & _
		_Iif($timer[5][1][0] <> "", $timer[5][1][0], "    " ) & ":" & _Iif($timer[5][1][1] <> "", $timer[5][1][1], "    " ) & "    ", _
		60)
EndFunc

Func reloadTimer()
	getTimer()
	MsgBox(8256, $APP_NAME, "成功刷新任务时间设置，新任务设置将马上启用！", 60)
EndFunc

Func immediateCheck()
	MsgBox(8256, $APP_NAME, "5秒钟后开始执行任务！或者回答这个对话框立即执行任务！", 5)
	$curTask = @HOUR & ":" & @MIN
	$curTaskDetailInfo = @YEAR & "-" & @MON & "-" & @MDAY & " " & $curTask
	$monitor = $MON_STATUS_EXECUTING
	checkNow()
	If @error Then
		$monitor = $MON_STATUS_FAILED
		TrayTip($APP_NAME, "任务：【" & $curTaskDetailInfo & "】失败，请检查！", 86400, 3)
		TraySetToolTip(getTrayToolTip("任务：【" & $curTaskDetailInfo & "】失败，请检查！"))
		sms("任务：【" & $curTaskDetailInfo & "】失败，请检查！")
		Return
	EndIf
	$monitor = $MON_STATUS_DONE
	TrayTip($APP_NAME, "任务：【" & $curTaskDetailInfo & "】成功！", 86400, 1)
	TraySetToolTip(getTrayToolTip("任务：【" & $curTaskDetailInfo & "】成功！"))
EndFunc

Func immediateCheckTest()
	MsgBox(8256, $APP_NAME, "5秒钟后开始执行测试！", 5)
	checkNow(False)
	TrayTip("", "", 0)
EndFunc

Func showTaskInfo()
	MsgBox(8256, $APP_NAME, "上一次任务是：" & $curTaskDetailInfo & "，结果是：" & $monitor, 60)
EndFunc

Func reloadConf()
	; id and pwd
	$id = RegRead($regBase, "id")
	$pwd = RegRead($regBase, "pwd")

	; jdk path
	$jdkPath = RegRead($regBase, "jdkPath")
	If @error == 1 Then
		MsgBox(8208, $APP_NAME, "严重错误：JDK/JRE路径未配置！")
		Exit
	EndIf
	Local $flag = FileExists($jdkPath & "\bin\java.exe")
	If $flag == 0 Then
		MsgBox(8208, $APP_NAME, "严重错误：错误的JDK/JRE路径，程序将退出！")
		Exit
	EndIf

	; notify conf
	$isNotify = RegRead($regBase, "notify")
	$cellNo = RegRead($regBase, "cellphoneNo")
	
	MsgBox ( _
		8256, $APP_NAME, _
		"新的设置如下：" & @CRLF & _
		"工　　号：" & $id & @CRLF & _
		"密　　码：" & $pwd & @CRLF & _
		"JDK 路径：" & $jdkPath & @CRLF & _
		"短信通知：" & $isNotify & @CRLF & _
		"手机号码：" & $cellNo, 60 _
	)
EndFunc

;**************************************************************************************
;
; 这个函数恐怕就是一个最需要维护的函数了，包含所有的错误码和对应的文字描述
; 不保留AutoIt本身的错误码，如果执行一个AutoIt的函数或者UDF函数出错，则在
; 调用的函数中翻译成这个Macro自身的错误码。
; 
; 错误码从10000开始递增
;
; 错误码的文字描述规则如下：
; [Function Name] Description
; 例如：[login] 未知错误
;
; 建议按照Function Name来归类，并且每一个Function都分配10个错误码备用
;
;**************************************************************************************
Func getErrorTextByErrorCode($code)
	Local $msg
	Switch $code
	Case 10000
		$msg = "[AutoChecking] 刷卡成功" & @CRLF & _
			"============================================================================="
	Case 10001
		$msg = "[AutoChecking] 刷卡失败，monitor将会重试本次任务..."
	
	case 10002
		$msg = "[getValidateCode] 打开文件：conf\result.txt出错"
	case 10003
		$msg = "[getValidateCode] 计算验证码出错"
	case 10004
		$msg = "[getValidateCode] 解析验证码程序的bug，导致错误码出错"
	case 10005
		$msg = "[getValidateCode] 获得验证码图片的文本文件出错"
	
	case 10011
		$msg = "[putValidateCode] 调用UDF：_IEFormGetObjByName失败，错误码：$_IEStatus_InvalidDataType"
	case 10012
		$msg = "[putValidateCode] 调用UDF：_IEFormGetObjByName失败，错误码：$_IEStatus_NoMatch"
	case 10013
		$msg = "[putValidateCode] 调用UDF：_IEFormElementGetObjByName失败，错误码：$_IEStatus_InvalidDataType"
	case 10014
		$msg = "[putValidateCode] 调用UDF：_IEFormElementGetObjByName失败，错误码：$_IEStatus_InvalidObjectType"
	case 10015
		$msg = "[putValidateCode] 调用UDF：_IEFormElementGetObjByName失败，错误码：$_IEStatus_NoMatch"
	case 10016
		$msg = "[putValidateCode] 严重错误：验证码错误"
	case 10017
		$msg = "[putValidateCode] 调用UDF：_IEFormElementSetValue失败，错误码：$_IEStatus_InvalidDataType"
	case 10018
		$msg = "[putValidateCode] 调用UDF：_IEFormElementSetValue失败，错误码：$_IEStatus_InvalidObjectType"
	Case 10019
		$msg = "[putValidateCode] 调用UDF：_IEGetObjByName 出错，错误码：($_IEStatus_NoMatch) = No Match"
	Case 10020
		$msg = "[putValidateCode] 验证码错误"
		
	Case 10021
		$msg = "[getTimer] 访问任务配置注册表出错"
	Case 10022
		$msg = "[getTimer] 任务未配置"
		
	Case 10031
		$msg = "[scheduler] 最近一次任务执行失败，重试..."
	Case 10032
		$msg = "[scheduler] 最近一次任务重试成功"  & @CRLF & _
			"============================================================================="
	Case 10033
		$msg = "[scheduler] 任务重试次数超过最大重试次数，认为任务失败"  & @CRLF & _
			"============================================================================="
		
	Case 10053
		$msg = "[login] 调用UDF：_IEGetObjByName 出错，错误码：($_IEStatus_NoMatch) = No Match"
	Case 10041
		$msg = "[setLayout] 调用UDF：_IEErrorHandlerRegister 出错，错误码：$_IEStatus_GeneralError"
	Case 10042
		$msg = "[setLayout] 调用UDF：_IECreateEmbedded 出错，错误码：$_IEStatus_GeneralError"
	Case 10043
		$msg = "[setLayout] 创建GUI出错，the window cannot be created"
	Case 10044
		$msg = "[setLayout] _IENavigate出错，错误码：($_IEStatus_GeneralError) = General Error"
	Case 10045
		$msg = "[setLayout] _IENavigate出错，错误码：($_IEStatus_LoadWaitTimeout) = Load Wait Timeout"
	Case 10046
		$msg = "[setLayout] _IENavigate出错，错误码：($_IEStatus_AccessIsDenied) = Access Is Denied"
	Case 10047
		$msg = "[setLayout] _IELoadWait出错，错误码：($_IEStatus_LoadWaitTimeout) = Load Wait Timeout"
	
	Case 10051
		$msg = "[login] 调用UDF：_IEFormGetObjByName出错，错误码：($_IEStatus_NoMatch) = No Match"
	Case 10052
		$msg = "[login] 调用UDF：_IEFormElementGetObjByName出错，错误码：($_IEStatus_NoMatch) = No Match"
	Case 10053
		$msg = "[login] 调用UDF：_IEGetObjByName 出错，错误码：($_IEStatus_NoMatch) = No Match"
	Case 10054
		$msg = "[login] _IELoadWait出错，错误码：($_IEStatus_LoadWaitTimeout) = Load Wait Timeout"
	Case 10055
		$msg = "[login] _IELoadWait出错，错误码：($_IEStatus_LoadWaitTimeout) = Load Wait Timeout"
		
	Case 10061
		$msg = "[checkNow] 调用setLayout出错！"
	Case 10062
		$msg = "[checkNow] 调用login出错！"
	Case 10063
		$msg = "[checkNow] 调用putValidateCode出错！"
		
	Case 10071
		$msg = "[keepHelperAlive] Helper程序未运行！"
	Case 10072
		$msg = "[keepHelperAlive] Helper程序不存在！"
		
	Case 10081
		$msg = "[sms] IM未运行，无法发送短信"
	Case 10082
		$msg = "[sms] 无法打开短信中心界面。"
		
	Case Else
		$msg = "[unkown function] 未知错误"
	EndSwitch
	
	Return $msg
EndFunc


