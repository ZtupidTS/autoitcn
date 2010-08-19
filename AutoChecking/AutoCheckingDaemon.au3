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

Global $MSG_SUCCESS = "����ˢ���ɹ�"
Global $MSG_FAILED = "��������Ч����֤��"
Global $APP_NAME = "AC30 Daemon Tool"

If _Singleton("chenxu_AutoCheckingDaemon", 1) == 0 Then
	MsgBox(8256, $APP_NAME, "��̨�����Ѿ�������...", 10)
	Exit
EndIf

#Region global variables
AutoItSetOption("MouseCoordMode", 0)
AutoItSetOption("PixelCoordMode", 0)
AutoItSetOption("MustDeclareVars", 1)
AutoItSetOption("TrayMenuMode",1)

Global $PROCESS_NAME_GUI = "AutoCheckingGUI.exe"
Global $PROCESS_NAME_HELPER = "AutoCheckingHelper.exe"

Global $MSG_SUCCESS = "����ˢ���ɹ�"
Global $MSG_FAILED = "��������Ч����֤��"
Global $MSG_UNKOWN = "δ֪"

Global $MON_STATUS_DONE = "�ɹ�"
Global $MON_STATUS_EXECUTING = "����ִ��"
Global $MON_STATUS_FAILED = "����ʧ��"
Global $MON_STATUS_RETRIED_DONE = "���Ժ�ɹ�"
Global $MON_STATUS_RETRIED_FAILED = "���Ժ�ʧ��"
Global $MON_STATUS_UNKOWN = "״̬δ֪"

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

;��¼��������顣����һ����ά�����飬�������е㸴����
;��һά������������һΪ1���ܶ�Ϊ2����������
;�ڶ�ά�ǵ�������ı�ʶ�����ÿ�������ֻ��2����������ڴ�������õ�����ע������ж���Ļ���ȡǰ2��
;����ά������Сʱ�ͷ�������һ���������������������ģ�08:00������5����ĸ��ɣ�������ʱ���Сʱ�ͷ���
;    �ֿ��洢������ʹ�á�
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
	MsgBox(8208, $APP_NAME, "���ش���JDK/JRE·��δ���ã�")
	Exit
EndIf
If Not FileExists($jdkPath & "\bin\java.exe") Then
	MsgBox(8208, $APP_NAME, "���ش��󣺴����JDK/JRE·���������˳���")
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
TrayTip($APP_NAME, "��̨����ɹ�����", 5)

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
; ����web������Ľ���
; 
; ��������䣺10041~10050
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
; ��¼��atm��
; 
; ��������䣺10051~10060
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
; �����֤�룬���뵽webҳ���е��ı�����ȥ
; 
; ��������䣺10011~10020
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
		Local $gui_varify = GUICreate("��֤��Ա�", 275, 99, 0, 0, Default, $WS_EX_MDICHILD, $guiHandle)
		GUICtrlCreatePic(@ScriptDir & "\pic.bmp", 205, 3, 63, 22, _
			BitOR($SS_NOTIFY,$WS_GROUP,$WS_CLIPSIBLINGS))
		GUICtrlSetResizing(-1, $GUI_DOCKAUTO)
		GUICtrlCreateLabel("����õ�����֤���ǣ�" & $code, 8, 8)
		GUICtrlCreateLabel("��ͼƬ����ʾ����֤���Ƿ�һ�£�", 8, 32)
		Local $btn_yes = GUICtrlCreateButton("��", 112, 64, 75, 25, 0)
		Local $btn_no = GUICtrlCreateButton("��", 192, 64, 75, 25, 0)
		GUISetState(@SW_SHOW)

		Local $nMsg
		While 1
			$nMsg = GUIGetMsg()
			Switch $nMsg
				Case $btn_yes
					GUIDelete($gui_varify)
					ExitLoop
				Case $btn_no
					MsgBox(8208,$APP_NAME,"����ʧ�ܣ�")
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
		MsgBox(8256,$APP_NAME,"���Գɹ���")
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
; ���н�����������֤��
; 
; ��������䣺10001~10010
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
; ���н�����������֤��
; 
; ��������䣺10021~10030
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
; ��������Ƿ���Ҫ��ʼִ��
; 
; ��������䣺10031~10040
;
;**************************************************************************************
Func scheduler()
	;�Ѿ�����ִ�е�����������ִ��ʧ�ܣ����Դ�������10�Σ���������
	If $monitor == $MON_STATUS_EXECUTING And $monitorCount < $maxRetryTime Then
		logger(10031)
		checkNow()
		If @error Then
			Return
		EndIf
		TrayTip($APP_NAME, "���񣺡�" & $curTaskDetailInfo & "������" & $monitorCount & "�κ�ɹ���", 86400, 1)      ;86400 seconds = 1 day, long enough
		sms("���񣺡�" & $curTaskDetailInfo & "������" & $monitorCount & "�κ�ɹ���")
		logger(10032)
		monitorClose($MON_STATUS_RETRIED_DONE)
		Return
	EndIf
	;�Ѿ�����ִ�е�����������ִ��ʧ�ܣ����Դ�������10�Σ��������ԣ�����������Ϣ
	If $monitor == $MON_STATUS_EXECUTING And $monitorCount >= $maxRetryTime Then
		logger(10033)
		;���ﻹ��Ҫ�������������ʱ��
		TrayTip($APP_NAME, "���񣺡�" & $curTaskDetailInfo & "��ʧ�ܣ����飡", 86400, 3)
		TraySetToolTip(getTrayToolTip("���񣺡�" & $curTaskDetailInfo & "��ʧ�ܣ����飡"))
		sms("���񣺡�" & $curTaskDetailInfo & "��ʧ�ܣ����飡")
		monitorClose($MON_STATUS_RETRIED_FAILED)
		Return
	EndIf
	Local $wday = @WDAY - 2
	If $wday == -1 Then
		$wday = 6
	EndIf
	If $timer[$wday][0][0] == @HOUR And _
		$timer[$wday][0][1] == @MIN And _
		(@HOUR & ":" & @MIN) <> $curTask Then ;���(@HOUR & ":" @MIN) <> $curTask ΪTrue����ʾ��ǰ�����Ѿ�ִ�й��ˣ�����Ҫ�ظ�ִ��
		sleepRandomSec(3, 8)
		monitorInit()
		checkNow()
		If @error Then
			logger(10001)
			SetError(10001)
			Return
		EndIf
		TrayTip($APP_NAME, "���񣺡�" & $curTaskDetailInfo & "���ɹ���", 86400, 1)      ;86400 = 1 day, long enough
		TraySetToolTip(getTrayToolTip("���񣺡�" & $curTaskDetailInfo & "���ɹ���"))
		sms("���񣺡�" & $curTaskDetailInfo & "���ɹ���")
		logger(10000)
		monitorClose($MON_STATUS_DONE)
	EndIf
	If $timer[$wday][1][0] == @HOUR And _
		$timer[$wday][1][1] == @MIN And _
		(@HOUR & ":" & @MIN) <> $curTask Then ;���(@HOUR & ":" @MIN) <> $curTask ΪTrue����ʾ��ǰ�����Ѿ�ִ�й��ˣ�����Ҫ�ظ�ִ��
		sleepRandomSec(3, 8)
		monitorInit()
		checkNow()
		If @error Then
			logger(10001)
			SetError(10001)
			Return
		EndIf
		TrayTip($APP_NAME, "���񣺡�" & $curTaskDetailInfo & "���ɹ���", 86400, 1)      ;86400 = 1 day, long enough
		TraySetToolTip(getTrayToolTip("���񣺡�" & $curTaskDetailInfo & "���ɹ���"))
		sms("���񣺡�" & $curTaskDetailInfo & "���ɹ���")
		logger(10000)
		monitorClose($MON_STATUS_DONE)
	EndIf
EndFunc

;**************************************************************************************
;
; ִ��������������в������κε�������MsgBox�����ĶԻ��򵯳���������ܻ����
; һ�еĴ�����Ϣ��ͨ����־��¼����
; 
; ��������䣺10061~10070
;
;**************************************************************************************
Func checkNow($flag = True)
	$monitorCount = $monitorCount + 1

	TrayTip($APP_NAME, "����ִ������...", 60)
	
	If Not FileExists(@ScriptDir & "\" & $PROCESS_NAME_HELPER) Then
		logger(10072)
		TraySetIcon("warning")
		TrayTip($APP_NAME, "Helper����" & @ScriptDir & "\" & $PROCESS_NAME_HELPER & "�������ڣ�����һ�����صĴ������鲢��������̨����", 60)
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
; ���Ͷ���Ϣ��ָ�����ֻ�����
; 
; ��������䣺10081 ~ 10090
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
	If WinMenuSelectItem("��ʱЭͬ", "���¹���", "����(&T)", "��������(&S)...") == 0 Then
		; IM�����ڻ�������ԭ�����޷�������˵�����������һ��IM���Կ���
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
		If WinMenuSelectItem("��ʱЭͬ", "���¹���", "����(&T)", "��������(&S)...") == 0 Then
			Return
		EndIf
	EndIf
	If WinWait("��������", "��������", 30) == 0 Then
		Return
	EndIf
	ControlSetText("��������", "��������", 1001, $cellNo)
	ControlSetText("��������", "��������", 1685, $msg)
	ControlClick("��������", "��������", 1687)
	If WinWait("IM", "ȷ��", 60) == 0 Then
		WinClose("��������", "��������")
		WinWaitClose("��������", "��������")
		Return
	EndIf
	WinClose("IM", "ȷ��")
	WinWaitClose("IM", "ȷ��")
	WinClose("��������", "��������")
	WinWaitClose("��������", "��������")
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
	If WinWait("��ʱЭͬ", "����(&S)", 120) == 0 Then
		Return False
	EndIf
	ControlClick("��ʱЭͬ", "����(&S)", 1081)
	If WinWait("��¼", "�û�����", 20) == 0 Then
		Return False
	EndIf
	ControlSetText("��¼", "�û�����", 1001, RegRead($regBase, "id"))
	ControlSetText("��¼", "�û�����", 1015, RegRead($regBase, "pwd"), 1)
	ControlClick("��¼", "�û�����", 1)
	; ���IM�ڱ�ĵط�����¼���ˣ�����Ҫȷ�ϵ�¼��
	; ˳��ȴ�20����
	If WinWait("ϵͳ��ʾ", "�����˺��Ѿ������������ϵ�¼���Ƿ�Ҫ������¼��", 20) Then
		ControlSend("ϵͳ��ʾ", "�����˺��Ѿ������������ϵ�¼���Ƿ�Ҫ������¼��", 6, "{enter}")
		Sleep(20000)
	EndIf
	If WinWait("��ʱЭͬ", "���¹���", 180) == 0 Then
		Return False
	EndIf
	; �ٴ�ȷ��IM�����ɹ���IM�����ǲ��ȶ���û�취
	If Not WinExists("��ʱЭͬ", "���¹���") Then Return False
	; �����ɹ��ˣ������װ�
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
		logger("IMδ���л����д��󣬳�������IM...")
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
		If $im[$i][0] == "��ʱЭͬ" Then
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
; �漴����һ��ʱ�䣬����[$min*60, ($max-1)*60 + �������]֮��
; 
; ��������䣺null
;
;**************************************************************************************
Func sleepRandomSec($min, $max)
	Local $rdmMin = Random($min, $max - 1, 1)
	Local $rdmSec = Random(0, 59, 1)
	Local $millisecond = $rdmMin * 60 * 1000 + $rdmSec * 1000
	TrayTip($APP_NAME, "����ӳ�" & $millisecond/1000 & "���Ӻ�ʼִ������..." & @CRLF & _
						"����ʼ�����е����ͼ��̵Ķ�����ȫ�����赲��" & @CRLF & _
						"��Ctrl+Alt+Del�������»�ö����ͼ��̵Ŀ��ơ�", $millisecond/1000, 1)
	Sleep($millisecond)
EndFunc

;**************************************************************************************
;
; ������������ʾ��Ϣ
; 
; ��������䣺null
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
		"          ��һ     �ܶ�      ����     ����     ����     ����      " & @CRLF & @CRLF & _
		"�ϣ�  " & _
		_Iif($timer[0][0][0] <> "", $timer[0][0][0], "    " ) & ":" & _Iif($timer[0][0][1] <> "", $timer[0][0][1], "    " ) & "    " & _
		_Iif($timer[1][0][0] <> "", $timer[1][0][0], "    " ) & ":" & _Iif($timer[1][0][1] <> "", $timer[1][0][1], "    " ) & "    " & _
		_Iif($timer[2][0][0] <> "", $timer[2][0][0], "    " ) & ":" & _Iif($timer[2][0][1] <> "", $timer[2][0][1], "    " ) & "    " & _
		_Iif($timer[3][0][0] <> "", $timer[3][0][0], "    " ) & ":" & _Iif($timer[3][0][1] <> "", $timer[3][0][1], "    " ) & "    " & _
		_Iif($timer[4][0][0] <> "", $timer[4][0][0], "    " ) & ":" & _Iif($timer[4][0][1] <> "", $timer[4][0][1], "    " ) & "    " & _
		_Iif($timer[5][0][0] <> "", $timer[5][0][0], "    " ) & ":" & _Iif($timer[5][0][1] <> "", $timer[5][0][1], "    " ) & "    " & @CRLF & _
		"�£�  " & _
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
	MsgBox(8256, $APP_NAME, "�ɹ�ˢ������ʱ�����ã����������ý��������ã�", 60)
EndFunc

Func immediateCheck()
	MsgBox(8256, $APP_NAME, "5���Ӻ�ʼִ�����񣡻��߻ش�����Ի�������ִ������", 5)
	$curTask = @HOUR & ":" & @MIN
	$curTaskDetailInfo = @YEAR & "-" & @MON & "-" & @MDAY & " " & $curTask
	$monitor = $MON_STATUS_EXECUTING
	checkNow()
	If @error Then
		$monitor = $MON_STATUS_FAILED
		TrayTip($APP_NAME, "���񣺡�" & $curTaskDetailInfo & "��ʧ�ܣ����飡", 86400, 3)
		TraySetToolTip(getTrayToolTip("���񣺡�" & $curTaskDetailInfo & "��ʧ�ܣ����飡"))
		sms("���񣺡�" & $curTaskDetailInfo & "��ʧ�ܣ����飡")
		Return
	EndIf
	$monitor = $MON_STATUS_DONE
	TrayTip($APP_NAME, "���񣺡�" & $curTaskDetailInfo & "���ɹ���", 86400, 1)
	TraySetToolTip(getTrayToolTip("���񣺡�" & $curTaskDetailInfo & "���ɹ���"))
EndFunc

Func immediateCheckTest()
	MsgBox(8256, $APP_NAME, "5���Ӻ�ʼִ�в��ԣ�", 5)
	checkNow(False)
	TrayTip("", "", 0)
EndFunc

Func showTaskInfo()
	MsgBox(8256, $APP_NAME, "��һ�������ǣ�" & $curTaskDetailInfo & "������ǣ�" & $monitor, 60)
EndFunc

Func reloadConf()
	; id and pwd
	$id = RegRead($regBase, "id")
	$pwd = RegRead($regBase, "pwd")

	; jdk path
	$jdkPath = RegRead($regBase, "jdkPath")
	If @error == 1 Then
		MsgBox(8208, $APP_NAME, "���ش���JDK/JRE·��δ���ã�")
		Exit
	EndIf
	Local $flag = FileExists($jdkPath & "\bin\java.exe")
	If $flag == 0 Then
		MsgBox(8208, $APP_NAME, "���ش��󣺴����JDK/JRE·���������˳���")
		Exit
	EndIf

	; notify conf
	$isNotify = RegRead($regBase, "notify")
	$cellNo = RegRead($regBase, "cellphoneNo")
	
	MsgBox ( _
		8256, $APP_NAME, _
		"�µ��������£�" & @CRLF & _
		"�������ţ�" & $id & @CRLF & _
		"�ܡ����룺" & $pwd & @CRLF & _
		"JDK ·����" & $jdkPath & @CRLF & _
		"����֪ͨ��" & $isNotify & @CRLF & _
		"�ֻ����룺" & $cellNo, 60 _
	)
EndFunc

;**************************************************************************************
;
; ����������¾���һ������Ҫά���ĺ����ˣ��������еĴ�����Ͷ�Ӧ����������
; ������AutoIt����Ĵ����룬���ִ��һ��AutoIt�ĺ�������UDF������������
; ���õĺ����з�������Macro����Ĵ����롣
; 
; �������10000��ʼ����
;
; ����������������������£�
; [Function Name] Description
; ���磺[login] δ֪����
;
; ���鰴��Function Name�����࣬����ÿһ��Function������10�������뱸��
;
;**************************************************************************************
Func getErrorTextByErrorCode($code)
	Local $msg
	Switch $code
	Case 10000
		$msg = "[AutoChecking] ˢ���ɹ�" & @CRLF & _
			"============================================================================="
	Case 10001
		$msg = "[AutoChecking] ˢ��ʧ�ܣ�monitor�������Ա�������..."
	
	case 10002
		$msg = "[getValidateCode] ���ļ���conf\result.txt����"
	case 10003
		$msg = "[getValidateCode] ������֤�����"
	case 10004
		$msg = "[getValidateCode] ������֤������bug�����´��������"
	case 10005
		$msg = "[getValidateCode] �����֤��ͼƬ���ı��ļ�����"
	
	case 10011
		$msg = "[putValidateCode] ����UDF��_IEFormGetObjByNameʧ�ܣ������룺$_IEStatus_InvalidDataType"
	case 10012
		$msg = "[putValidateCode] ����UDF��_IEFormGetObjByNameʧ�ܣ������룺$_IEStatus_NoMatch"
	case 10013
		$msg = "[putValidateCode] ����UDF��_IEFormElementGetObjByNameʧ�ܣ������룺$_IEStatus_InvalidDataType"
	case 10014
		$msg = "[putValidateCode] ����UDF��_IEFormElementGetObjByNameʧ�ܣ������룺$_IEStatus_InvalidObjectType"
	case 10015
		$msg = "[putValidateCode] ����UDF��_IEFormElementGetObjByNameʧ�ܣ������룺$_IEStatus_NoMatch"
	case 10016
		$msg = "[putValidateCode] ���ش�����֤�����"
	case 10017
		$msg = "[putValidateCode] ����UDF��_IEFormElementSetValueʧ�ܣ������룺$_IEStatus_InvalidDataType"
	case 10018
		$msg = "[putValidateCode] ����UDF��_IEFormElementSetValueʧ�ܣ������룺$_IEStatus_InvalidObjectType"
	Case 10019
		$msg = "[putValidateCode] ����UDF��_IEGetObjByName ���������룺($_IEStatus_NoMatch) = No Match"
	Case 10020
		$msg = "[putValidateCode] ��֤�����"
		
	Case 10021
		$msg = "[getTimer] ������������ע������"
	Case 10022
		$msg = "[getTimer] ����δ����"
		
	Case 10031
		$msg = "[scheduler] ���һ������ִ��ʧ�ܣ�����..."
	Case 10032
		$msg = "[scheduler] ���һ���������Գɹ�"  & @CRLF & _
			"============================================================================="
	Case 10033
		$msg = "[scheduler] �������Դ�������������Դ�������Ϊ����ʧ��"  & @CRLF & _
			"============================================================================="
		
	Case 10053
		$msg = "[login] ����UDF��_IEGetObjByName ���������룺($_IEStatus_NoMatch) = No Match"
	Case 10041
		$msg = "[setLayout] ����UDF��_IEErrorHandlerRegister ���������룺$_IEStatus_GeneralError"
	Case 10042
		$msg = "[setLayout] ����UDF��_IECreateEmbedded ���������룺$_IEStatus_GeneralError"
	Case 10043
		$msg = "[setLayout] ����GUI����the window cannot be created"
	Case 10044
		$msg = "[setLayout] _IENavigate���������룺($_IEStatus_GeneralError) = General Error"
	Case 10045
		$msg = "[setLayout] _IENavigate���������룺($_IEStatus_LoadWaitTimeout) = Load Wait Timeout"
	Case 10046
		$msg = "[setLayout] _IENavigate���������룺($_IEStatus_AccessIsDenied) = Access Is Denied"
	Case 10047
		$msg = "[setLayout] _IELoadWait���������룺($_IEStatus_LoadWaitTimeout) = Load Wait Timeout"
	
	Case 10051
		$msg = "[login] ����UDF��_IEFormGetObjByName���������룺($_IEStatus_NoMatch) = No Match"
	Case 10052
		$msg = "[login] ����UDF��_IEFormElementGetObjByName���������룺($_IEStatus_NoMatch) = No Match"
	Case 10053
		$msg = "[login] ����UDF��_IEGetObjByName ���������룺($_IEStatus_NoMatch) = No Match"
	Case 10054
		$msg = "[login] _IELoadWait���������룺($_IEStatus_LoadWaitTimeout) = Load Wait Timeout"
	Case 10055
		$msg = "[login] _IELoadWait���������룺($_IEStatus_LoadWaitTimeout) = Load Wait Timeout"
		
	Case 10061
		$msg = "[checkNow] ����setLayout����"
	Case 10062
		$msg = "[checkNow] ����login����"
	Case 10063
		$msg = "[checkNow] ����putValidateCode����"
		
	Case 10071
		$msg = "[keepHelperAlive] Helper����δ���У�"
	Case 10072
		$msg = "[keepHelperAlive] Helper���򲻴��ڣ�"
		
	Case 10081
		$msg = "[sms] IMδ���У��޷����Ͷ���"
	Case 10082
		$msg = "[sms] �޷��򿪶������Ľ��档"
		
	Case Else
		$msg = "[unkown function] δ֪����"
	EndSwitch
	
	Return $msg
EndFunc


