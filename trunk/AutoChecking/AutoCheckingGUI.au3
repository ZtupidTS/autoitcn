#include <GUIConstants.au3>
#include "common.au3"
#NoTrayIcon
#AutoIt3Wrapper_icon = "..\ico\gui.ico"


Global $APP_NAME = "AC30 GUI Tool"
Global $DEAMON_NAME = "AutoCheckingDaemon.exe"
Global $DEAMON_STATUS_NORMAL = "正常运行！"
Global $DEAMON_STATUS_NOTRUNNING = "异常！未启动！"

Global $btnClose
Global $btnAbout
Global $tab

Global $trayItemAbout
Global $trayItemExit

Global $tabMain
Global $tabMainRefreshStatus
Global $tabMainChecknow
Global $tabMainActiveDaemon
Global $tabMainReloadTimer
Global $tabMainDispTimer
Global $tabMainDispTaskInfo
Global $tabMainTerminateDaemon
Global $tabMainLabelStatus
Global $tabMainLabelTimeRan
Global $tabMainViewLogFile
Global $tabMainCheckTest

Global $tabTaskManager
Global $tabTaskManagerCombo
Global $tabTaskManagerSet
Global $tabTaskManagerComboSet
Global $tabTaskManagerHelp
Global $tabTaskManagerTextMon1
Global $tabTaskManagerTextMon2
Global $tabTaskManagerTextTue1
Global $tabTaskManagerTextTue2
Global $tabTaskManagerTextWed1
Global $tabTaskManagerTextWed2
Global $tabTaskManagerTextThu1
Global $tabTaskManagerTextThu2
Global $tabTaskManagerTextFri1
Global $tabTaskManagerTextFri2
Global $tabTaskManagerTextSta1
Global $tabTaskManagerTextSta2

Global $tabOptionJdkPath
Global $tabOptionBrowseJdk
Global $tabOptionCellPhone
Global $tabOptionIMPath
Global $tabOptionBrowseIM
Global $tabOptionSaveOptions
Global $tabOptionID
Global $tabOptionPWD
Global $tabOptionHelp
;~ Global $tabOptionRadioClassic
;~ Global $tabOptionRadioNormal
;~ Global $tabOptionRadioOther
;~ Global $tabOptionTextHeigh
Global $tabOptionCheckBoxRunStartup
Global $tabOptionIsNotify

Global $daemonStatus = $DEAMON_STATUS_NORMAL
setLayout()
initData()

While 1
	$msg = GUIGetMsg()
	Select
	;not supported buttons
	Case $msg = $btnAbout Or $msg = $tabOptionHelp
		funNotSupportedYet()
	
	;tab option
	Case $msg = $tabOptionBrowseJdk
		$jdkPath = FileSelectFolder("选择JDK/JRE", "", 4)
		GUICtrlSetData($tabOptionJdkPath , $jdkPath)
	Case $msg = $tabOptionBrowseIM
		$imPath = FileSelectFolder("选择IM路径", "", 4)
		GUICtrlSetData($tabOptionIMPath , $imPath)
	Case $msg = $tabOptionSaveOptions
		funSaveOptions()
	Case $msg = $tabOptionIsNotify
		If GUICtrlRead ($tabOptionIsNotify) == $GUI_CHECKED Then
			GUICtrlSetState($tabOptionCellPhone, $GUI_ENABLE)
			GUICtrlSetState($tabOptionIMPath, $GUI_ENABLE)
			GUICtrlSetState($tabOptionBrowseIM, $GUI_ENABLE)
		Else
			GUICtrlSetState($tabOptionCellPhone, $GUI_DISABLE)
			GUICtrlSetState($tabOptionIMPath, $GUI_DISABLE)
			GUICtrlSetState($tabOptionBrowseIM, $GUI_DISABLE)
		EndIf
	Case $msg = $tabTaskManagerHelp
		$helpMsg = _
			"　　任务设置提供周一到周六的设置。这里分别用“上”和“下”来区分，" & @CRLF & _
			"但是实际上，“上”不代表就是设置上班的任务，“下”不代表就是设" & @CRLF & _
			"置下班的任务，你完全可以在“上”文本框中填入一个下午的时间，所" & @CRLF & _
			"以你有可能看到在一个“上”的文本框中出现“20:15”这样的一个时 " & @CRLF & _
			"间，一点都不用奇怪。" & @CRLF & @CRLF & _
			"　　关于任务的预设类型：这个功能只提供来帮助你快速设置任务，" & @CRLF & _
			"并不真正的把预设任务保存，这一点很重要！" & @CRLF & @CRLF & _
			"■如果某一天你不想执行任何任务，例如周六，这时候你可以把文本框" & @CRLF & _
			"清空保存，这个时候会有个提示可能错误的警告出来，但是这个警告对" & @CRLF & _
			"任务设置没有影响。" & @CRLF & _
			"■如果你想在某天只设置一个任务也可以，把其中一个文本框清空就可" & @CRLF & _
			"以了。" & @CRLF & _
			"■如果你一天想执行3次或者更多任务，你可以直接修改注册表来实现，" & @CRLF & _
			"具体如何修改，有兴趣的话，和我联系^_^。" & @CRLF & @CRLF & _
			"总而言之，任务的配置灵活，完全支持配置任意次数，任意时间的任务。"
		MsgBox(8192, $APP_NAME, $helpMsg)
		
	;tab task manager
	Case $msg = $tabTaskManagerComboSet
		funSetTimerProfile()
	Case $msg = $tabTaskManagerSet
		funTimerSave()
		funTabMainInvokeDaemonFunc($MESSAGE_RELOAD_TIMER)
		
	;tab main
	Case $msg = $tabMainRefreshStatus
		; 刷新状态 按钮
		funTabMainRefreshStatus()
	Case $msg = $tabMainChecknow
		; 立即执行任务 按钮
		funTabMainInvokeDaemonFunc($MESSAGE_IMMEDIATE_CHECK)
	Case $msg = $tabMainDispTaskInfo
		; 任务执行查询 按钮
		funTabMainInvokeDaemonFunc($MESSAGE_SHOW_TASK_INFO)
	Case $msg = $tabMainReloadTimer
		; 更新后台任务 按钮
		funTabMainInvokeDaemonFunc($MESSAGE_RELOAD_TIMER)
	Case $msg = $tabMainDispTimer
		; 查询后台任务 按钮
		funTabMainInvokeDaemonFunc($MESSAGE_SHOW_CURRENT_TIMER)
	Case $msg = $tabMainCheckTest
		; 任务执行测试 按钮
		funTabMainInvokeDaemonFunc($MESSAGE_IMMEDIATE_CHECK_TEST)
	Case $msg = $tabMainTerminateDaemon
		; 杀掉后台程序 按钮
		funTabMainTerminateDaemon()
	Case $msg = $tabMainActiveDaemon
		; 启动后台程序 按钮
		funTabMainActiveDaemon()
	Case $msg = $tabMainViewLogFile
		; 查看运行日志 按钮
		funTabMainViewLogFile()
	Case $msg = $GUI_EVENT_CLOSE Or $msg = $btnClose
		ExitLoop
	EndSelect
	
    $msg = TrayGetMsg()
    Select
        Case $msg = 0
            ContinueLoop
        Case $msg = $trayItemAbout
            MsgBox(8256, $APP_NAME, "暂时未添加，谢谢")
        Case $msg = $trayItemExit
            ExitLoop
    EndSelect
WEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; button functions
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func funSaveOptions()
	$errText = "错误信息：" & @CRLF
	$errCount = 1
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;save jdk/jre path
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	$jdkPath = GUICtrlRead($tabOptionJdkPath)
	$jdkPath = StringStripWS($jdkPath, 1 + 2)
	$tmp = StringRight($jdkPath, 1)
	If $tmp == "\" Then $jdkPath = StringLeft($jdkPath, StringLen($jdkPath) - 1)
	$flag = FileExists($jdkPath & "\bin\java.exe")
	if $flag == 0 Then
		;MsgBox(8208, $APP_NAME, "严重错误：错误的JDK/JRE路径，程序将退出！")
		$errText = $errText & $errCount & "、严重错误：错误的JDK/JRE路径；" & @CRLF
		$errCount = $errCount + 1
	Else
		RegWrite($regBase, "jdkPath", "REG_SZ", $jdkPath)
	EndIf
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;save login info
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	$id = GUICtrlRead($tabOptionID)
	If StringLen($id) == 6 And StringIsAlNum($id) == 1 Then
		RegWrite($regBase, "id", "REG_SZ", GUICtrlRead($tabOptionID))
	Else
		;MsgBox(8208, $APP_NAME, "ID设置错误！")
		$errText = $errText & $errCount & "、ID设置错误，应该是6位数字；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$pwd = GUICtrlRead($tabOptionPWD)
	If $pwd == "" Then
		$errText = $errText & $errCount & "、密码设置错误，不能为空；" & @CRLF
		$errCount = $errCount + 1
	Else
		RegWrite($regBase, "pwd", "REG_SZ", GUICtrlRead($tabOptionPWD))
	EndIf
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; save misc options
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	$tmp = GUICtrlRead ($tabOptionCheckBoxRunStartup)
	; try to find the shortcut to our AutoCheckingDaemon.exe
	$lnkFileSearch = FileFindFirstFile(@StartupDir & "\*.lnk")
	$flag = False
	While 1
		$lnkFile = @StartupDir & "\" & FileFindNextFile($lnkFileSearch)
		If @error Then ExitLoop
		$lnkFileInfo = FileGetShortcut($lnkFile)
		If $lnkFileInfo[0] == (@ScriptDir & "\bin\AutoCheckingDaemon.exe") Then
			$flag = True
			ExitLoop
		EndIf
	WEnd
	; $flag == true if the shortcut found
	If $tmp == $GUI_CHECKED Then
		$tmp = "true"
		If Not $flag Then ; the shortcut doesn't exist, create it
			If FileCreateShortcut(@ScriptDir & "\bin\AutoCheckingDaemon.exe", _
				@StartupDir & "\AutoCheckingDaemon.lnk", _
				@ScriptDir & "\bin") == 0 Then
				$errText = $errText & $errCount & "创建快捷方式：" & @StartupDir & "\AutoCheckingDaemon.lnk" & _
										"出错，请重试。" & @CRLF
				$errCount = $errCount + 1
				$tmp = "error"
			EndIf
		EndIf
	Else
		$tmp = "false"
		If $flag Then ; the shortcut existed, remove it
			If FileDelete($lnkFile) == 0 Then
				$errText = $errText & $errCount & "删除快捷方式：" & $lnkFile & _
										" 出错，请重试或者手工删除。" & @CRLF
				$errCount = $errCount + 1
				$tmp = "error"
			EndIf
		EndIf
	EndIf
	If $tmp <> "error" Then ; do not save this info due to error occured
		RegWrite($regBase, "runOnStartup", "REG_SZ", $tmp)
	EndIf
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; save cell phone no
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	$tmp = GUICtrlRead ($tabOptionIsNotify)
	If $tmp == $GUI_CHECKED Then
		$tmp = GUICtrlRead ($tabOptionCellPhone)
		If StringLen($tmp) == 11 And StringIsDigit($tmp) Then
			RegWrite($regBase, "cellphoneNo", "REG_SZ", $tmp)
			RegWrite($regBase, "notify", "REG_SZ", "true")
		Else
			$errText = $errText & $errCount & "无效的手机号码" & @CRLF
			$errCount = $errCount + 1
		EndIf
		$tmp = GUICtrlRead ($tabOptionIMPath)
		If FileExists($tmp & "\IM.exe") Or FileExists($tmp & "IM.exe") Then
			If StringRight($tmp, 1) == "\" Then $tmp = StringLeft($tmp, StringLen($tmp) - 1)
			RegWrite($regBase, "IM", "REG_SZ", $tmp)
		Else
			$errText = $errText & $errCount & "IM路径错误。只填IM安装路径。" & @CRLF
			$errCount = $errCount + 1
		EndIf
		
	Else
		RegWrite($regBase, "notify", "REG_SZ", "false")
	EndIf
	
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; summary
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	If $errText <> ("错误信息：" & @CRLF) Then
		MsgBox(8208, $APP_NAME, $errText)
	Else
		Dim $iMsgBoxAnswer
		$iMsgBoxAnswer = MsgBox(8228,$APP_NAME,"设置保存成功！" & @CRLF & "需要重启后台来使设置生效，现在就重启吗？")
		Select
			Case $iMsgBoxAnswer = 6 ;Yes
				funTabMainInvokeDaemonFunc("^+!f")
			Case $iMsgBoxAnswer = 7 ;No
				MsgBox(8256,$APP_NAME,"由于后台未重启，目前仍然实用旧设置！")
		EndSelect
	EndIf
EndFunc

Func funTimerSave()
	$errText = "任务设置可能存在错误，下列任务不会被保存：" & @CRLF
	$errCount = 1
	
	RegDelete($regBase & "\1")
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextMon1))
	If $task <> "" Then
		RegWrite($regBase & "\1", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "、周一任务1；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextMon2))
	If $task <> "" Then
		RegWrite($regBase & "\1", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "、周一任务2；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	
	RegDelete($regBase & "\2")
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextTue1))
	If $task <> "" Then
		RegWrite($regBase & "\2", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "、周二任务1；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextTue2))
	If $task <> "" Then
		RegWrite($regBase & "\2", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "、周二任务2；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	
	RegDelete($regBase & "\3")
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextWed1))
	If $task <> "" Then
		RegWrite($regBase & "\3", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "、周三任务1；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextWed2))
	If $task <> "" Then
		RegWrite($regBase & "\3", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "、周三任务2；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	
	RegDelete($regBase & "\4")
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextThu1))
	If $task <> "" Then
		RegWrite($regBase & "\4", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "、周四任务1；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextThu2))
	If $task <> "" Then
		RegWrite($regBase & "\4", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "、周四任务2；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	
	RegDelete($regBase & "\5")
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextFri1))
	If $task <> "" Then
		RegWrite($regBase & "\5", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "、周五任务1；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextFri2))
	If $task <> "" Then
		RegWrite($regBase & "\5", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "、周五任务2；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	
	RegDelete($regBase & "\6")
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextSta1))
	If $task <> "" Then
		RegWrite($regBase & "\6", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "、周六任务1；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextSta2))
	If $task <> "" Then
		RegWrite($regBase & "\6", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "、周六任务2；" & @CRLF
		$errCount = $errCount + 1
	EndIf
	
	If $errText <> "任务设置可能存在错误，下列任务不会被保存：" & @CRLF Then
		MsgBox(8240, $APP_NAME, $errText)
	EndIf
EndFunc

Func funSetTimerProfile()
	$type = GUICtrlRead($tabTaskManagerCombo)
	;MsgBox(0, "debug", $type)
	Select
	Case $type = "规矩型"
		GUICtrlSetData($tabTaskManagerTextMon1, "08:00")
		GUICtrlSetData($tabTaskManagerTextMon2, "20:00")
		GUICtrlSetData($tabTaskManagerTextTue1, "08:00")
		GUICtrlSetData($tabTaskManagerTextTue2, "20:00")
		GUICtrlSetData($tabTaskManagerTextWed1, "08:00")
		GUICtrlSetData($tabTaskManagerTextWed2, "17:45")
		GUICtrlSetData($tabTaskManagerTextThu1, "08:00")
		GUICtrlSetData($tabTaskManagerTextThu2, "20:00")
		GUICtrlSetData($tabTaskManagerTextFri1, "08:00")
		GUICtrlSetData($tabTaskManagerTextFri2, "17:45")
		GUICtrlSetData($tabTaskManagerTextSta1, "12:00")
		GUICtrlSetData($tabTaskManagerTextSta2, "16:40")
	Case $type = "嚣张型"
		GUICtrlSetData($tabTaskManagerTextMon1, "08:00")
		GUICtrlSetData($tabTaskManagerTextMon2, "20:15")
		GUICtrlSetData($tabTaskManagerTextTue1, "08:00")
		GUICtrlSetData($tabTaskManagerTextTue2, "20:15")
		GUICtrlSetData($tabTaskManagerTextWed1, "08:00")
		GUICtrlSetData($tabTaskManagerTextWed2, "20:15")
		GUICtrlSetData($tabTaskManagerTextThu1, "08:00")
		GUICtrlSetData($tabTaskManagerTextThu2, "20:15")
		GUICtrlSetData($tabTaskManagerTextFri1, "08:00")
		GUICtrlSetData($tabTaskManagerTextFri2, "20:15")
		GUICtrlSetData($tabTaskManagerTextSta1, "09:00")
		GUICtrlSetData($tabTaskManagerTextSta2, "16:40")
	Case $type = "疯狂型"
		GUICtrlSetData($tabTaskManagerTextMon1, "08:00")
		GUICtrlSetData($tabTaskManagerTextMon2, "20:15")
		GUICtrlSetData($tabTaskManagerTextTue1, "08:00")
		GUICtrlSetData($tabTaskManagerTextTue2, "20:15")
		GUICtrlSetData($tabTaskManagerTextWed1, "08:00")
		GUICtrlSetData($tabTaskManagerTextWed2, "20:15")
		GUICtrlSetData($tabTaskManagerTextThu1, "08:00")
		GUICtrlSetData($tabTaskManagerTextThu2, "20:15")
		GUICtrlSetData($tabTaskManagerTextFri1, "08:00")
		GUICtrlSetData($tabTaskManagerTextFri2, "20:15")
		GUICtrlSetData($tabTaskManagerTextSta1, "09:00")
		GUICtrlSetData($tabTaskManagerTextSta2, "16:40")
	EndSelect
EndFunc

Func funTabMainActiveDaemon()
	If Not FileExists(@ScriptDir & "\bin\" & $DEAMON_NAME) Then
		MsgBox(8208, $APP_NAME,"严重错误！后台程序：【" & @ScriptDir & "\bin\" & $DEAMON_NAME & "】不存在，请检查！")
		Return
	EndIf
	Run(@ScriptDir & "\bin\" & $DEAMON_NAME)
	ProcessWait($DEAMON_NAME, 10)
	funTabMainRefreshStatus()
EndFunc

Func funTabMainInvokeDaemonFunc($cmd)
	If $daemonStatus == $DEAMON_STATUS_NOTRUNNING Then
		$n = MsgBox(8228, $APP_NAME, "后台程序未启动，现在就启动吗？")
		If $n == 6 Then    ;OK button pressed
			funTabMainActiveDaemon()
		EndIf
	EndIf
	If @error Then
		MsgBox(8208, $APP_NAME, "后台程序启动失败，这是一个严重错误。请检查！")
	Else
		RegWrite($regBase, $REG_MESSAGE_KEY, "REG_SZ", $cmd)
	EndIf
EndFunc

Func funTabMainTerminateDaemon()
	RegWrite($regBase, $REG_MESSAGE_KEY, "REG_SZ", $MESSAGE_TERMINATE)
	If Not ProcessWaitClose($DEAMON_NAME, 20) Then
		ProcessClose($DEAMON_NAME)
		ProcessWaitClose($DEAMON_NAME, 20)
	EndIf
	$daemonStatus = $DEAMON_STATUS_NOTRUNNING
	funTabMainRefreshStatus()
EndFunc

Func funTabMainRefreshStatus()
	If ProcessExists($DEAMON_NAME) Then
		$daemonStatus = $DEAMON_STATUS_NORMAL
	Else
		$daemonStatus = $DEAMON_STATUS_NOTRUNNING
	EndIf
	GUICtrlSetData ($tabMainLabelStatus, $daemonStatus)
	$totalTimeRan = Round(RegRead($regBase, "totalTimeRan")/1000, 2)
	$day = int($totalTimeRan/86400)
	$totalTimeRan = $totalTimeRan - $day * 86400
	$hour = int($totalTimeRan/3600)
	$totalTimeRan = $totalTimeRan - $hour * 3600
	$min = int($totalTimeRan/60)
	GUICtrlSetData ($tabMainLabelTimeRan, "总运行时间：" & $day & "天" & _
											$hour & "小时" & _
											$min & "分")
EndFunc

Func funTabMainViewLogFile()
	Run("notepad.exe " & @ScriptDir & "\log.txt")
EndFunc

Func funNotSupportedYet()
	MsgBox(8256, $APP_NAME, "暂时未添加，谢谢")
EndFunc

Func setLayout()
	GUICreate($APP_NAME, 400, 300)  ; will create a dialog box that when displayed is centered
	$btnClose = GUICtrlCreateButton("关    闭", 300, 265, 80, 25)
	$btnAbout = GUICtrlCreateButton("关    于", 215, 265, 80, 25)

	$tab = GUICtrlCreateTab (0, 0, 400,297)

	$tabMain = GUICtrlCreateTabitem ("基本功能")
	GUICtrlSetState(-1, $GUI_SHOW)	; will be display first
	GUICtrlCreateGroup ("基本", 5, 30, 390, 230)
	GUICtrlCreateGroup ("任务", 10, 45, 190, 210)
	$tabMainChecknow = GUICtrlCreateButton ("立即执行任务", 20, 75, 80, 25)
	GUICtrlSetTip($tabMainChecknow, "立即执行任务")
	$tabMainDispTaskInfo = GUICtrlCreateButton ("任务执行查询", 105, 75, 80, 25)
	GUICtrlSetTip($tabMainDispTaskInfo, "查询最近一次任务的执行时间和结果")
	$tabMainReloadTimer = GUICtrlCreateButton ("更新后台任务", 20, 110, 80, 25)
	GUICtrlSetTip($tabMainReloadTimer, "在GUI保存任务设置后，后台程序并不会更新，这个地方提供通知后台程序更新设置的功能")
	$tabMainDispTimer = GUICtrlCreateButton ("查询后台任务", 105, 110, 80, 25)
	GUICtrlSetTip($tabMainDispTimer, "查询后台正在实用的任务设置")
	$tabMainActiveDaemon = GUICtrlCreateButton ("启动后台程序", 20, 145, 80, 25)
	GUICtrlSetTip($tabMainActiveDaemon, "用来启动后台程序")
	$tabMainTerminateDaemon = GUICtrlCreateButton ("杀掉后台程序", 105, 145, 80, 25)
	GUICtrlSetTip($tabMainTerminateDaemon, "用来杀掉后台程序，如果需要重启后台，可以在这里杀掉后台在启动")
	$tabMainViewLogFile = GUICtrlCreateButton ("查看运行日志", 20, 180, 80, 25)
	GUICtrlSetTip($tabMainViewLogFile, "查看日志文件检查任务执行的情况")
	$tabMainCheckTest = GUICtrlCreateButton ("任务执行测试", 105, 180, 80, 25)
	GUICtrlSetTip($tabMainCheckTest, "测试任务执行流程中的绝大部分过程，可以发现一些移植过程中的错误，保证任务完成的准确率")
	GUICtrlCreateGroup ("后台程序信息", 203, 45, 187, 210)
	If ProcessExists($DEAMON_NAME) Then
		$daemonStatus = "正常运行！"
	Else
		$daemonStatus = "异常！未启动！"
	EndIf
	GUICtrlCreateLabel("运行状态  ：", 215, 70)
	$tabMainLabelStatus = GUICtrlCreateLabel($daemonStatus, 287, 70, 100)
	GUICtrlSetTip($tabMainLabelStatus, "后台的运行状态，可以帮助你快速判断后台是否正常运行")
	$totalTimeRan = Round(RegRead($regBase, "totalTimeRan")/1000, 2)
	$day = int($totalTimeRan/86400)
	$totalTimeRan = $totalTimeRan - $day * 86400
	$hour = int($totalTimeRan/3600)
	$totalTimeRan = $totalTimeRan - $hour * 3600
	$min = int($totalTimeRan/60)
	$tabMainLabelTimeRan = GUICtrlCreateLabel("总运行时间：" & $day & "天" & _
							$hour & "小时" & _
							$min & "分", 215, 95, 300)
	GUICtrlSetTip($tabMainLabelTimeRan, "后台总计运行的时间")
	$tabMainRefreshStatus = GUICtrlCreateButton ("刷新状态", 300, 220, 80, 25)
	GUICtrlSetTip($tabMainRefreshStatus, "手工刷新后台的状态")

	$tabTaskManager = GUICtrlCreateTabitem ("任务设置")
	GUICtrlCreateGroup ("设置", 5, 30, 390, 230)
	GUICtrlCreateLabel("选择一个预设类型：", 15, 50, 250, 20)
	$tabTaskManagerCombo = GUICtrlCreateCombo ("", 30, 70, 150, 220)
	GUICtrlSetData(-1, "规矩型|嚣张型|疯狂型", "规矩型") 
	$tabTaskManagerComboSet = GUICtrlCreateButton("设置", 185, 69, 50, 20)
	GUICtrlSetTip($tabTaskManagerComboSet, "把预设的类型填充到下列的文本框中，不保存到任务设置中")
	GUICtrlCreateLabel("详细任务设置，任务执行以下列配置的为准：", 15, 110, 250, 20)
	GUICtrlCreateLabel("周一：", 15, 135, 40, 20)
	GUICtrlCreateLabel("周二：", 75, 135, 40, 20)
	GUICtrlCreateLabel("周三：", 135, 135, 40, 20)
	GUICtrlCreateLabel("周四：", 195, 135, 40, 20)
	GUICtrlCreateLabel("周五：", 255, 135, 40, 20)
	GUICtrlCreateLabel("周六：", 315, 135, 40, 20)
	GUICtrlCreateLabel("上", 15, 163, 15, 20)
	GUICtrlCreateLabel("下", 15, 189, 15, 20)
	GUICtrlCreateLabel("上", 75, 163, 15, 20)
	GUICtrlCreateLabel("下", 75, 189, 15, 20)
	GUICtrlCreateLabel("上", 135, 163, 15, 20)
	GUICtrlCreateLabel("下", 135, 189, 15, 20)
	GUICtrlCreateLabel("上", 195, 163, 15, 20)
	GUICtrlCreateLabel("下", 195, 189, 15, 20)
	GUICtrlCreateLabel("上", 255, 163, 15, 20)
	GUICtrlCreateLabel("下", 255, 189, 15, 20)
	GUICtrlCreateLabel("上", 315, 163, 15, 20)
	GUICtrlCreateLabel("下", 315, 189, 15, 20)
	$tabTaskManagerTextMon1 = GUICtrlCreateInput ("08:00", 30, 160, 38, 18)
	$tabTaskManagerTextMon2 = GUICtrlCreateInput ("17:45", 30, 185, 38, 18)
	$tabTaskManagerTextTue1 = GUICtrlCreateInput ("08:00", 90, 160, 38, 18)
	$tabTaskManagerTextTue2 = GUICtrlCreateInput ("17:45", 90, 185, 38, 18)
	$tabTaskManagerTextWed1 = GUICtrlCreateInput ("08:00", 150, 160, 38, 18)
	$tabTaskManagerTextWed2 = GUICtrlCreateInput ("17:45", 150, 185, 38, 18)
	$tabTaskManagerTextThu1 = GUICtrlCreateInput ("08:00", 210, 160, 38, 18)
	$tabTaskManagerTextThu2 = GUICtrlCreateInput ("17:45", 210, 185, 38, 18)
	$tabTaskManagerTextFri1 = GUICtrlCreateInput ("08:00", 270, 160, 38, 18)
	$tabTaskManagerTextFri2 = GUICtrlCreateInput ("17:45", 270, 185, 38, 18)
	$tabTaskManagerTextSta1 = GUICtrlCreateInput ("08:00", 330, 160, 38, 18)
	$tabTaskManagerTextSta2 = GUICtrlCreateInput ("17:45", 330, 185, 38, 18)
	$tabTaskManagerSet = GUICtrlCreateButton("保存任务", 300, 227, 80, 25)
	GUICtrlSetTip($tabTaskManagerSet, "将任务保存到注册表中去，注意：仅保存任务，不通知后台，请手工更新后台任务时间")
	$tabTaskManagerHelp = GUICtrlCreateButton("帮    助", 215, 227, 80, 25)

	
	$tabOption=GUICtrlCreateTabitem ("选项设置")
	$errCode = checkConfig()
	If $errCode <> 0 Then ;error configuration or first time run the program, force to set the options
		GUICtrlSetState(-1, $GUI_SHOW)	; will be display first
		MsgBox(8240, $APP_NAME, "错误的参数设置，或者首次运行本程序，请进行一些简单的设置！")
	EndIf
	GUICtrlCreateGroup ("设置", 5, 30, 390, 230)
	GUICtrlCreateLabel ("JDK路径", 15, 60)
	$tabOptionJdkPath = GUICtrlCreateInput ("D:\Tools\j2sdk1.4.2_04", 60, 57, 285, 20)
	GUICtrlSetTip($tabOptionJdkPath, "JAVA HOME路径，设置错误的话，将直接导致所有任务失败")
	$tabOptionBrowseJdk = GUICtrlCreateButton ("...", 350, 56, 30, 20)
	GUICtrlSetTip($tabOptionBrowseJdk, "浏览...")
	GUICtrlCreateLabel ("6位ID：", 15, 90, 45, 20)
	$tabOptionID = GUICtrlCreateInput ("", 60, 88, 135, 20)
	GUICtrlSetTip($tabOptionID, "6位人事在线的ID号")
	GUICtrlCreateLabel ("密 码：", 215, 90, 45, 20)
	$tabOptionPWD = GUICtrlCreateInput ("", 260, 88, 120, 20, $ES_PASSWORD)
	GUICtrlSetTip($tabOptionPWD, "人事在线密码。注意密码错误的话，将会导致所有任务失败")
	$tabOptionCheckBoxRunStartup = GUICtrlCreateCheckbox("后台随系统启动运行", 215, 115)
	$tabOptionIsNotify = GUICtrlCreateCheckbox("手机短信通知任务结果", 15, 115)
	GUICtrlCreateLabel ("手机号", 34, 145)
	$tabOptionCellPhone = GUICtrlCreateInput ("", 75, 142, 120, 20)
	GUICtrlCreateLabel ("IM路径", 34, 175)
	$tabOptionIMPath = GUICtrlCreateInput ("", 75, 172, 120, 20)
	$tabOptionBrowseIM = GUICtrlCreateButton ("...", 200, 172, 30, 20)
	GUICtrlSetTip($tabOptionBrowseIM, "浏览...")
	
	$tabOptionSaveOptions = GUICtrlCreateButton("保存设置", 300, 227, 80, 25)
	GUICtrlSetTip($tabOptionSaveOptions, "保存设置")
	$tabOptionHelp = GUICtrlCreateButton("帮    助", 215, 227, 80, 25)

	GUICtrlCreateTabitem ("")	; end tabitem definition

	GUISetState ()
	
	setTrayMenuLayout()
EndFunc

Func setTrayMenuLayout()
	Opt("TrayMenuMode",1)
	$trayItemAbout = TrayCreateItem("关于")
	TrayCreateItem("")
	$trayItemExit = TrayCreateItem("退出")
	TraySetState()
EndFunc

Func initData()
	;init task setting
	For $i = 1 To 6 Step 1
		For $j = 1 To 2 Step 1
			$var = RegEnumVal($regBase & "\" & $i, $j)
			if @error == 0 Then
				GUICtrlSetData(getTextObjByWeek($i, $j), $var)
			Else
				GUICtrlSetData(getTextObjByWeek($i, $j), "--:--")
			EndIf
		Next
	Next
	
	;init jdk path
	$tmp = RegRead($regBase, "jdkPath")
	If @error == 1 Then
		RegWrite($regBase)
	EndIf
	If $tmp == "" Then
		$tmp = "c:\j2sdk"
	EndIf
	GUICtrlSetData($tabOptionJdkPath, $tmp)
	
	;init id and pwd
	$tmp = RegRead($regBase, "id")
	If @error == 1 Then
		RegWrite($regBase)
	EndIf
	GUICtrlSetData($tabOptionID, $tmp)
	$tmp = RegRead($regBase, "pwd")
	If @error == 1 Then
		RegWrite($regBase)
	EndIf
	GUICtrlSetData($tabOptionPWD, $tmp)

	; init cell phone no box
	GUICtrlSetData($tabOptionCellPhone, _
					RegRead($regBase, "cellphoneNo"))
	GUICtrlSetData($tabOptionIMPath, _
					RegRead($regBase, "IM"))
	
	;init misc options
	$tmp = StringLower(RegRead($regBase, "runOnStartup"))
	If $tmp <> "true" And $tmp <> "false" Then
		$tmp = "true"
	EndIf
	If $tmp == "true" Then
		GUICtrlSetState($tabOptionCheckBoxRunStartup, $GUI_CHECKED)
	EndIf
	$tmp = StringLower(RegRead($regBase, "notify"))
	If $tmp <> "true" And $tmp <> "false" Then
		$tmp = "true"
	EndIf
	If $tmp == "true" Then
		GUICtrlSetState($tabOptionIsNotify, $GUI_CHECKED)
	EndIf
	
EndFunc

Func checkTaskSetting($setting)
	;check whether the setting is valid
	;return "" if invalid setting
	$n = StringLen($setting)
	If $n <> 5 Then Return ""
	$tmp = StringLeft($setting, 2)
	If StringIsDigit($tmp) <> 1 Then Return ""
	$tmp = StringRight($setting, 2)
	If StringIsDigit($tmp) <> 1 Then Return ""
	$tmp = StringMid($setting, 3, 1)
	If $tmp <> ":" Then Return ""
	Return $setting
EndFunc

Func getTextObjByWeek($w, $flag)
	Switch $w
	Case 1
		If $flag == 1 Then Return $tabTaskManagerTextMon1
		Return $tabTaskManagerTextMon2
	Case 2
		If $flag == 1 Then Return $tabTaskManagerTextTue1
		Return $tabTaskManagerTextTue2
	Case 3
		If $flag == 1 Then Return $tabTaskManagerTextWed1
		Return $tabTaskManagerTextWed2
	Case 4
		If $flag == 1 Then Return $tabTaskManagerTextThu1
		Return $tabTaskManagerTextThu2
	Case 5
		If $flag == 1 Then Return $tabTaskManagerTextFri1
		Return $tabTaskManagerTextFri2
	Case 6
		If $flag == 1 Then Return $tabTaskManagerTextSta1
		Return $tabTaskManagerTextSta2
	EndSwitch
EndFunc

Func checkConfig()
	$str = RegRead($regBase, "jdkPath")
	If @error Then Return 10002
	$flag = FileExists($str & "\bin\java.exe")
	If $flag == 0 Then Return False
		
	$str = RegRead($regBase, "id")
	If @error Then Return 10003
	If $str == "" Then Return 10003
	$str = RegRead($regBase, "pwd")
	If @error Then Return 10004
	If $str == "" Then Return 10004
		
	Return 0
EndFunc

Func getErrorTextByErrorCode($code)
	Switch $code
	Case 10000
		$msg = "[AutoChecking] 刷卡成功"
	Case 10001
		$msg = "[AutoChecking] 刷卡失败"
	
	case 10002
		$msg = "JDK/JRE路径设置出错"
	case 10003
		$msg = "用户名出错"
	case 10004
		$msg = "密码为空"
	
	Case Else
		$msg = "[unkown function] 未知错误"
	EndSwitch
	
	Return $msg
EndFunc









