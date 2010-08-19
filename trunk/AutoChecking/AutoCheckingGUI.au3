#include <GUIConstants.au3>
#include "common.au3"
#NoTrayIcon
#AutoIt3Wrapper_icon = "..\ico\gui.ico"


Global $APP_NAME = "AC30 GUI Tool"
Global $DEAMON_NAME = "AutoCheckingDaemon.exe"
Global $DEAMON_STATUS_NORMAL = "�������У�"
Global $DEAMON_STATUS_NOTRUNNING = "�쳣��δ������"

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
		$jdkPath = FileSelectFolder("ѡ��JDK/JRE", "", 4)
		GUICtrlSetData($tabOptionJdkPath , $jdkPath)
	Case $msg = $tabOptionBrowseIM
		$imPath = FileSelectFolder("ѡ��IM·��", "", 4)
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
			"�������������ṩ��һ�����������á�����ֱ��á��ϡ��͡��¡������֣�" & @CRLF & _
			"����ʵ���ϣ����ϡ���������������ϰ�����񣬡��¡������������" & @CRLF & _
			"���°����������ȫ�����ڡ��ϡ��ı���������һ�������ʱ�䣬��" & @CRLF & _
			"�����п��ܿ�����һ�����ϡ����ı����г��֡�20:15��������һ��ʱ " & @CRLF & _
			"�䣬һ�㶼������֡�" & @CRLF & @CRLF & _
			"�������������Ԥ�����ͣ��������ֻ�ṩ�������������������" & @CRLF & _
			"���������İ�Ԥ�����񱣴棬��һ�����Ҫ��" & @CRLF & @CRLF & _
			"�����ĳһ���㲻��ִ���κ�����������������ʱ������԰��ı���" & @CRLF & _
			"��ձ��棬���ʱ����и���ʾ���ܴ���ľ��������������������" & @CRLF & _
			"��������û��Ӱ�졣" & @CRLF & _
			"�����������ĳ��ֻ����һ������Ҳ���ԣ�������һ���ı�����վͿ�" & @CRLF & _
			"���ˡ�" & @CRLF & _
			"�������һ����ִ��3�λ��߸������������ֱ���޸�ע�����ʵ�֣�" & @CRLF & _
			"��������޸ģ�����Ȥ�Ļ���������ϵ^_^��" & @CRLF & @CRLF & _
			"�ܶ���֮���������������ȫ֧�������������������ʱ�������"
		MsgBox(8192, $APP_NAME, $helpMsg)
		
	;tab task manager
	Case $msg = $tabTaskManagerComboSet
		funSetTimerProfile()
	Case $msg = $tabTaskManagerSet
		funTimerSave()
		funTabMainInvokeDaemonFunc($MESSAGE_RELOAD_TIMER)
		
	;tab main
	Case $msg = $tabMainRefreshStatus
		; ˢ��״̬ ��ť
		funTabMainRefreshStatus()
	Case $msg = $tabMainChecknow
		; ����ִ������ ��ť
		funTabMainInvokeDaemonFunc($MESSAGE_IMMEDIATE_CHECK)
	Case $msg = $tabMainDispTaskInfo
		; ����ִ�в�ѯ ��ť
		funTabMainInvokeDaemonFunc($MESSAGE_SHOW_TASK_INFO)
	Case $msg = $tabMainReloadTimer
		; ���º�̨���� ��ť
		funTabMainInvokeDaemonFunc($MESSAGE_RELOAD_TIMER)
	Case $msg = $tabMainDispTimer
		; ��ѯ��̨���� ��ť
		funTabMainInvokeDaemonFunc($MESSAGE_SHOW_CURRENT_TIMER)
	Case $msg = $tabMainCheckTest
		; ����ִ�в��� ��ť
		funTabMainInvokeDaemonFunc($MESSAGE_IMMEDIATE_CHECK_TEST)
	Case $msg = $tabMainTerminateDaemon
		; ɱ����̨���� ��ť
		funTabMainTerminateDaemon()
	Case $msg = $tabMainActiveDaemon
		; ������̨���� ��ť
		funTabMainActiveDaemon()
	Case $msg = $tabMainViewLogFile
		; �鿴������־ ��ť
		funTabMainViewLogFile()
	Case $msg = $GUI_EVENT_CLOSE Or $msg = $btnClose
		ExitLoop
	EndSelect
	
    $msg = TrayGetMsg()
    Select
        Case $msg = 0
            ContinueLoop
        Case $msg = $trayItemAbout
            MsgBox(8256, $APP_NAME, "��ʱδ��ӣ�лл")
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
	$errText = "������Ϣ��" & @CRLF
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
		;MsgBox(8208, $APP_NAME, "���ش��󣺴����JDK/JRE·���������˳���")
		$errText = $errText & $errCount & "�����ش��󣺴����JDK/JRE·����" & @CRLF
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
		;MsgBox(8208, $APP_NAME, "ID���ô���")
		$errText = $errText & $errCount & "��ID���ô���Ӧ����6λ���֣�" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$pwd = GUICtrlRead($tabOptionPWD)
	If $pwd == "" Then
		$errText = $errText & $errCount & "���������ô��󣬲���Ϊ�գ�" & @CRLF
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
				$errText = $errText & $errCount & "������ݷ�ʽ��" & @StartupDir & "\AutoCheckingDaemon.lnk" & _
										"���������ԡ�" & @CRLF
				$errCount = $errCount + 1
				$tmp = "error"
			EndIf
		EndIf
	Else
		$tmp = "false"
		If $flag Then ; the shortcut existed, remove it
			If FileDelete($lnkFile) == 0 Then
				$errText = $errText & $errCount & "ɾ����ݷ�ʽ��" & $lnkFile & _
										" ���������Ի����ֹ�ɾ����" & @CRLF
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
			$errText = $errText & $errCount & "��Ч���ֻ�����" & @CRLF
			$errCount = $errCount + 1
		EndIf
		$tmp = GUICtrlRead ($tabOptionIMPath)
		If FileExists($tmp & "\IM.exe") Or FileExists($tmp & "IM.exe") Then
			If StringRight($tmp, 1) == "\" Then $tmp = StringLeft($tmp, StringLen($tmp) - 1)
			RegWrite($regBase, "IM", "REG_SZ", $tmp)
		Else
			$errText = $errText & $errCount & "IM·������ֻ��IM��װ·����" & @CRLF
			$errCount = $errCount + 1
		EndIf
		
	Else
		RegWrite($regBase, "notify", "REG_SZ", "false")
	EndIf
	
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; summary
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	If $errText <> ("������Ϣ��" & @CRLF) Then
		MsgBox(8208, $APP_NAME, $errText)
	Else
		Dim $iMsgBoxAnswer
		$iMsgBoxAnswer = MsgBox(8228,$APP_NAME,"���ñ���ɹ���" & @CRLF & "��Ҫ������̨��ʹ������Ч�����ھ�������")
		Select
			Case $iMsgBoxAnswer = 6 ;Yes
				funTabMainInvokeDaemonFunc("^+!f")
			Case $iMsgBoxAnswer = 7 ;No
				MsgBox(8256,$APP_NAME,"���ں�̨δ������Ŀǰ��Ȼʵ�þ����ã�")
		EndSelect
	EndIf
EndFunc

Func funTimerSave()
	$errText = "�������ÿ��ܴ��ڴ����������񲻻ᱻ���棺" & @CRLF
	$errCount = 1
	
	RegDelete($regBase & "\1")
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextMon1))
	If $task <> "" Then
		RegWrite($regBase & "\1", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "����һ����1��" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextMon2))
	If $task <> "" Then
		RegWrite($regBase & "\1", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "����һ����2��" & @CRLF
		$errCount = $errCount + 1
	EndIf
	
	RegDelete($regBase & "\2")
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextTue1))
	If $task <> "" Then
		RegWrite($regBase & "\2", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "���ܶ�����1��" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextTue2))
	If $task <> "" Then
		RegWrite($regBase & "\2", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "���ܶ�����2��" & @CRLF
		$errCount = $errCount + 1
	EndIf
	
	RegDelete($regBase & "\3")
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextWed1))
	If $task <> "" Then
		RegWrite($regBase & "\3", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "����������1��" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextWed2))
	If $task <> "" Then
		RegWrite($regBase & "\3", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "����������2��" & @CRLF
		$errCount = $errCount + 1
	EndIf
	
	RegDelete($regBase & "\4")
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextThu1))
	If $task <> "" Then
		RegWrite($regBase & "\4", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "����������1��" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextThu2))
	If $task <> "" Then
		RegWrite($regBase & "\4", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "����������2��" & @CRLF
		$errCount = $errCount + 1
	EndIf
	
	RegDelete($regBase & "\5")
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextFri1))
	If $task <> "" Then
		RegWrite($regBase & "\5", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "����������1��" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextFri2))
	If $task <> "" Then
		RegWrite($regBase & "\5", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "����������2��" & @CRLF
		$errCount = $errCount + 1
	EndIf
	
	RegDelete($regBase & "\6")
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextSta1))
	If $task <> "" Then
		RegWrite($regBase & "\6", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "����������1��" & @CRLF
		$errCount = $errCount + 1
	EndIf
	$task = checkTaskSetting(GUICtrlRead($tabTaskManagerTextSta2))
	If $task <> "" Then
		RegWrite($regBase & "\6", $task, "REG_SZ", "on")
	Else
		$errText = $errText & $errCount & "����������2��" & @CRLF
		$errCount = $errCount + 1
	EndIf
	
	If $errText <> "�������ÿ��ܴ��ڴ����������񲻻ᱻ���棺" & @CRLF Then
		MsgBox(8240, $APP_NAME, $errText)
	EndIf
EndFunc

Func funSetTimerProfile()
	$type = GUICtrlRead($tabTaskManagerCombo)
	;MsgBox(0, "debug", $type)
	Select
	Case $type = "�����"
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
	Case $type = "������"
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
	Case $type = "�����"
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
		MsgBox(8208, $APP_NAME,"���ش��󣡺�̨���򣺡�" & @ScriptDir & "\bin\" & $DEAMON_NAME & "�������ڣ����飡")
		Return
	EndIf
	Run(@ScriptDir & "\bin\" & $DEAMON_NAME)
	ProcessWait($DEAMON_NAME, 10)
	funTabMainRefreshStatus()
EndFunc

Func funTabMainInvokeDaemonFunc($cmd)
	If $daemonStatus == $DEAMON_STATUS_NOTRUNNING Then
		$n = MsgBox(8228, $APP_NAME, "��̨����δ���������ھ�������")
		If $n == 6 Then    ;OK button pressed
			funTabMainActiveDaemon()
		EndIf
	EndIf
	If @error Then
		MsgBox(8208, $APP_NAME, "��̨��������ʧ�ܣ�����һ�����ش������飡")
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
	GUICtrlSetData ($tabMainLabelTimeRan, "������ʱ�䣺" & $day & "��" & _
											$hour & "Сʱ" & _
											$min & "��")
EndFunc

Func funTabMainViewLogFile()
	Run("notepad.exe " & @ScriptDir & "\log.txt")
EndFunc

Func funNotSupportedYet()
	MsgBox(8256, $APP_NAME, "��ʱδ��ӣ�лл")
EndFunc

Func setLayout()
	GUICreate($APP_NAME, 400, 300)  ; will create a dialog box that when displayed is centered
	$btnClose = GUICtrlCreateButton("��    ��", 300, 265, 80, 25)
	$btnAbout = GUICtrlCreateButton("��    ��", 215, 265, 80, 25)

	$tab = GUICtrlCreateTab (0, 0, 400,297)

	$tabMain = GUICtrlCreateTabitem ("��������")
	GUICtrlSetState(-1, $GUI_SHOW)	; will be display first
	GUICtrlCreateGroup ("����", 5, 30, 390, 230)
	GUICtrlCreateGroup ("����", 10, 45, 190, 210)
	$tabMainChecknow = GUICtrlCreateButton ("����ִ������", 20, 75, 80, 25)
	GUICtrlSetTip($tabMainChecknow, "����ִ������")
	$tabMainDispTaskInfo = GUICtrlCreateButton ("����ִ�в�ѯ", 105, 75, 80, 25)
	GUICtrlSetTip($tabMainDispTaskInfo, "��ѯ���һ�������ִ��ʱ��ͽ��")
	$tabMainReloadTimer = GUICtrlCreateButton ("���º�̨����", 20, 110, 80, 25)
	GUICtrlSetTip($tabMainReloadTimer, "��GUI�����������ú󣬺�̨���򲢲�����£�����ط��ṩ֪ͨ��̨����������õĹ���")
	$tabMainDispTimer = GUICtrlCreateButton ("��ѯ��̨����", 105, 110, 80, 25)
	GUICtrlSetTip($tabMainDispTimer, "��ѯ��̨����ʵ�õ���������")
	$tabMainActiveDaemon = GUICtrlCreateButton ("������̨����", 20, 145, 80, 25)
	GUICtrlSetTip($tabMainActiveDaemon, "����������̨����")
	$tabMainTerminateDaemon = GUICtrlCreateButton ("ɱ����̨����", 105, 145, 80, 25)
	GUICtrlSetTip($tabMainTerminateDaemon, "����ɱ����̨���������Ҫ������̨������������ɱ����̨������")
	$tabMainViewLogFile = GUICtrlCreateButton ("�鿴������־", 20, 180, 80, 25)
	GUICtrlSetTip($tabMainViewLogFile, "�鿴��־�ļ��������ִ�е����")
	$tabMainCheckTest = GUICtrlCreateButton ("����ִ�в���", 105, 180, 80, 25)
	GUICtrlSetTip($tabMainCheckTest, "��������ִ�������еľ��󲿷ֹ��̣����Է���һЩ��ֲ�����еĴ��󣬱�֤������ɵ�׼ȷ��")
	GUICtrlCreateGroup ("��̨������Ϣ", 203, 45, 187, 210)
	If ProcessExists($DEAMON_NAME) Then
		$daemonStatus = "�������У�"
	Else
		$daemonStatus = "�쳣��δ������"
	EndIf
	GUICtrlCreateLabel("����״̬  ��", 215, 70)
	$tabMainLabelStatus = GUICtrlCreateLabel($daemonStatus, 287, 70, 100)
	GUICtrlSetTip($tabMainLabelStatus, "��̨������״̬�����԰���������жϺ�̨�Ƿ���������")
	$totalTimeRan = Round(RegRead($regBase, "totalTimeRan")/1000, 2)
	$day = int($totalTimeRan/86400)
	$totalTimeRan = $totalTimeRan - $day * 86400
	$hour = int($totalTimeRan/3600)
	$totalTimeRan = $totalTimeRan - $hour * 3600
	$min = int($totalTimeRan/60)
	$tabMainLabelTimeRan = GUICtrlCreateLabel("������ʱ�䣺" & $day & "��" & _
							$hour & "Сʱ" & _
							$min & "��", 215, 95, 300)
	GUICtrlSetTip($tabMainLabelTimeRan, "��̨�ܼ����е�ʱ��")
	$tabMainRefreshStatus = GUICtrlCreateButton ("ˢ��״̬", 300, 220, 80, 25)
	GUICtrlSetTip($tabMainRefreshStatus, "�ֹ�ˢ�º�̨��״̬")

	$tabTaskManager = GUICtrlCreateTabitem ("��������")
	GUICtrlCreateGroup ("����", 5, 30, 390, 230)
	GUICtrlCreateLabel("ѡ��һ��Ԥ�����ͣ�", 15, 50, 250, 20)
	$tabTaskManagerCombo = GUICtrlCreateCombo ("", 30, 70, 150, 220)
	GUICtrlSetData(-1, "�����|������|�����", "�����") 
	$tabTaskManagerComboSet = GUICtrlCreateButton("����", 185, 69, 50, 20)
	GUICtrlSetTip($tabTaskManagerComboSet, "��Ԥ���������䵽���е��ı����У������浽����������")
	GUICtrlCreateLabel("��ϸ�������ã�����ִ�����������õ�Ϊ׼��", 15, 110, 250, 20)
	GUICtrlCreateLabel("��һ��", 15, 135, 40, 20)
	GUICtrlCreateLabel("�ܶ���", 75, 135, 40, 20)
	GUICtrlCreateLabel("������", 135, 135, 40, 20)
	GUICtrlCreateLabel("���ģ�", 195, 135, 40, 20)
	GUICtrlCreateLabel("���壺", 255, 135, 40, 20)
	GUICtrlCreateLabel("������", 315, 135, 40, 20)
	GUICtrlCreateLabel("��", 15, 163, 15, 20)
	GUICtrlCreateLabel("��", 15, 189, 15, 20)
	GUICtrlCreateLabel("��", 75, 163, 15, 20)
	GUICtrlCreateLabel("��", 75, 189, 15, 20)
	GUICtrlCreateLabel("��", 135, 163, 15, 20)
	GUICtrlCreateLabel("��", 135, 189, 15, 20)
	GUICtrlCreateLabel("��", 195, 163, 15, 20)
	GUICtrlCreateLabel("��", 195, 189, 15, 20)
	GUICtrlCreateLabel("��", 255, 163, 15, 20)
	GUICtrlCreateLabel("��", 255, 189, 15, 20)
	GUICtrlCreateLabel("��", 315, 163, 15, 20)
	GUICtrlCreateLabel("��", 315, 189, 15, 20)
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
	$tabTaskManagerSet = GUICtrlCreateButton("��������", 300, 227, 80, 25)
	GUICtrlSetTip($tabTaskManagerSet, "�����񱣴浽ע�����ȥ��ע�⣺���������񣬲�֪ͨ��̨�����ֹ����º�̨����ʱ��")
	$tabTaskManagerHelp = GUICtrlCreateButton("��    ��", 215, 227, 80, 25)

	
	$tabOption=GUICtrlCreateTabitem ("ѡ������")
	$errCode = checkConfig()
	If $errCode <> 0 Then ;error configuration or first time run the program, force to set the options
		GUICtrlSetState(-1, $GUI_SHOW)	; will be display first
		MsgBox(8240, $APP_NAME, "����Ĳ������ã������״����б����������һЩ�򵥵����ã�")
	EndIf
	GUICtrlCreateGroup ("����", 5, 30, 390, 230)
	GUICtrlCreateLabel ("JDK·��", 15, 60)
	$tabOptionJdkPath = GUICtrlCreateInput ("D:\Tools\j2sdk1.4.2_04", 60, 57, 285, 20)
	GUICtrlSetTip($tabOptionJdkPath, "JAVA HOME·�������ô���Ļ�����ֱ�ӵ�����������ʧ��")
	$tabOptionBrowseJdk = GUICtrlCreateButton ("...", 350, 56, 30, 20)
	GUICtrlSetTip($tabOptionBrowseJdk, "���...")
	GUICtrlCreateLabel ("6λID��", 15, 90, 45, 20)
	$tabOptionID = GUICtrlCreateInput ("", 60, 88, 135, 20)
	GUICtrlSetTip($tabOptionID, "6λ�������ߵ�ID��")
	GUICtrlCreateLabel ("�� �룺", 215, 90, 45, 20)
	$tabOptionPWD = GUICtrlCreateInput ("", 260, 88, 120, 20, $ES_PASSWORD)
	GUICtrlSetTip($tabOptionPWD, "�����������롣ע���������Ļ������ᵼ����������ʧ��")
	$tabOptionCheckBoxRunStartup = GUICtrlCreateCheckbox("��̨��ϵͳ��������", 215, 115)
	$tabOptionIsNotify = GUICtrlCreateCheckbox("�ֻ�����֪ͨ������", 15, 115)
	GUICtrlCreateLabel ("�ֻ���", 34, 145)
	$tabOptionCellPhone = GUICtrlCreateInput ("", 75, 142, 120, 20)
	GUICtrlCreateLabel ("IM·��", 34, 175)
	$tabOptionIMPath = GUICtrlCreateInput ("", 75, 172, 120, 20)
	$tabOptionBrowseIM = GUICtrlCreateButton ("...", 200, 172, 30, 20)
	GUICtrlSetTip($tabOptionBrowseIM, "���...")
	
	$tabOptionSaveOptions = GUICtrlCreateButton("��������", 300, 227, 80, 25)
	GUICtrlSetTip($tabOptionSaveOptions, "��������")
	$tabOptionHelp = GUICtrlCreateButton("��    ��", 215, 227, 80, 25)

	GUICtrlCreateTabitem ("")	; end tabitem definition

	GUISetState ()
	
	setTrayMenuLayout()
EndFunc

Func setTrayMenuLayout()
	Opt("TrayMenuMode",1)
	$trayItemAbout = TrayCreateItem("����")
	TrayCreateItem("")
	$trayItemExit = TrayCreateItem("�˳�")
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
		$msg = "[AutoChecking] ˢ���ɹ�"
	Case 10001
		$msg = "[AutoChecking] ˢ��ʧ��"
	
	case 10002
		$msg = "JDK/JRE·�����ó���"
	case 10003
		$msg = "�û�������"
	case 10004
		$msg = "����Ϊ��"
	
	Case Else
		$msg = "[unkown function] δ֪����"
	EndSwitch
	
	Return $msg
EndFunc









