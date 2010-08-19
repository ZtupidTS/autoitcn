#AutoIt3Wrapper_au3check_parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#AutoIt3Wrapper_Icon=".\ico\clearexplorer_app.ico"

#include <StaticConstants.au3>
#include <GuiButton.au3>
#include <GuiListBox.au3>
#include <IE.au3>
#include <Date.au3>
#include <Misc.au3>
#include "..\myudf\password.au3"
#include "SearchPrivate.au3"
#include "common.au3"

#NoTrayIcon

Opt("PixelCoordMode", 0)
Opt("MustDeclareVars", 1)

#Region global vriables
Global const $REG_BASE = "HKEY_LOCAL_MACHINE\SOFTWARE\Chenxu\CCHelper"
Global const $VERSION = "2.1.8"
Global const $DATE = "2009��05��26��"
Global $gui_help = ""
Global $errorText = ""
Global $ccPid = 0
Global $ccHome = getCCInstallPath()
Global $ccExePath = $ccHome & "\bin\clearexplorer.exe"
Global $mmExePath = $ccHome & "\bin\clearmrgman.exe"
Global $gui_main
Global $btn_merge
Global $btn_mergeDropDown
Global $ctxt_merge
Global $mi_mergeMulti
Global $mi_mergeSingle
Global $mi_mergeHelp
Global $mi_mergeConf
Global $btn_selection
Global $ctxt_selection
Global $mi_selection
Global $mi_selectionEx
Global $mi_selectionExploreFile
Global $mi_selectionFindPrivateFiles
Global $mi_favourite[1] = [0]
Global $mi_favouriteConf = -1
Global $isFavouriteInited = False
Global $btn_clibuilder
Global $ctxt_clibuilder
Global $mi_clibuilder[1] = [0]
Global $mi_clibuilderConf = -1
Global $isClibuilderInited = False
Global $btn_cq
Global $ctxt_cq
Global $mi_cqLaunch
Global $mi_cqNewChangemenForm
Global $mi_cqNewUnitTestForm
Global $mi_cqsubmitSolution
Global $mi_cqAddFiles2Solution
Global $mi_cqAudit
Global $mi_cqResearchResult
Global $mi_cqPwd
Global $mi_cqConf
Global $btn_help
Global $ctxt_help
Global $mi_helpCCService
Global $mi_helpTopmost
Global $mi_helpCCSwitcher
Global $mi_grabCC
Global $mi_helpAbout
Global $mi_helpHelp
Global $mi_helpExit
#EndRegion
;

If _Singleton("chenxu_cchelper", 1) == 0 Then
	WinActivate("ClearCase Helper", "Merge")
	Exit
EndIf

;~ install()
setLayout()
AdlibEnable("checkRestartFlag", 250)
_ReduceMemory()

Global $message
While 1
	$message = GUIGetMsg(1)
	Switch $message[0]
		Case $btn_merge
			disableAll()
			merge(False)
			enableAll()
		Case $btn_mergeDropDown
			ShowMenu($gui_main, $btn_merge, $ctxt_merge)
		Case $mi_mergeMulti
			disableAll()
			merge(True)
			enableAll()
		Case $mi_mergeSingle
			disableAll()
			merge(False)
			enableAll()
		Case $mi_mergeHelp
			mergeHelp()
		Case $mi_mergeConf
			openConfigFile("mergeConf.ini", "[main]")
		Case $btn_selection
			If Not $isFavouriteInited Then
				createFavouriteMenuItem()
				createClibuiderMenuItem()
			EndIf
			ShowMenu($gui_main, $btn_selection, $ctxt_selection)
		Case $mi_selection
			putPath2Clipboard(getSelection("cc_path"))
		Case $mi_selectionEx
			putPath2Clipboard(getSelection("ex_path"))
		Case $mi_selectionExploreFile
			getSelection("explore")
		Case $mi_selectionFindPrivateFiles
			disableAll()
			_SearchPrivate($ccHome)
			enableAll()
		Case $btn_cq
			ShowMenu($gui_main, $btn_cq, $ctxt_cq)
		Case $mi_cqLaunch
			disableAll()
			launchCQ()
			enableAll()
		Case $mi_cqNewChangemenForm
			disableAll()
			newChangementForm()
			enableAll()
		Case $mi_cqNewUnitTestForm
			disableAll()
			newUnitTestForm()
			enableAll()
		Case $mi_cqsubmitSolution
			disableAll()
			submitSolution()
			enableAll()
		Case $mi_cqAudit
			disableAll()
			auditOk()
			enableAll()
		Case $mi_cqResearchResult
			disableAll()
			researchResult()
			enableAll()
		Case $mi_cqAddFiles2Solution
			addFiles2Solution()
		Case $mi_cqPwd
			If FileExists(@ScriptDir & "\tools\��������.exe") Then
				Run(@ScriptDir & "\tools\��������.exe", @ScriptDir & "\tools")
			Else
				MsgBox(8208, "ClearCase Helper", "�������빤�߲����ڣ��޷�ִ�С�")
			EndIf
		Case $mi_cqConf
			openConfigFile("clearquest.ini", "main")
		Case $btn_help
			ShowMenu($gui_main, $btn_help, $ctxt_help)
		Case $mi_helpCCSwitcher
			If FileExists(@ScriptDir & "\tools\GclearSwitcher.exe") Then
				Run(@ScriptDir & "\tools\GclearSwitcher.exe", @ScriptDir & "\tools")
			Else
				MsgBox(8208, "ClearCase Helper", "GclearSwitcher.exe�����ڣ��޷�ִ�С�")
			EndIf
		Case $mi_helpTopmost
			If BitAND(GUICtrlRead($mi_helpTopmost), $GUI_CHECKED) == $GUI_CHECKED Then
				WinSetOnTop("ClearCase Helper", "��", 0)
				GUICtrlSetState($mi_helpTopmost, $GUI_UNCHECKED)
			Else
				WinSetOnTop("ClearCase Helper", "��", 1)
				GUICtrlSetState($mi_helpTopmost, $GUI_CHECKED)
			EndIf
		Case $mi_helpCCService
			If FileExists(@ScriptDir & "\tools\ClearCaseService.lnk") Then
				ShellExecute(@ScriptDir & "\tools\ClearCaseService", @ScriptDir & "\tools")
			Else
				MsgBox(8208, "ClearCase Helper", "ClearCaseService��ݷ�ʽ�����ڣ��޷�ִ�С�")
			EndIf
		Case $mi_grabCC
			Run (@ScriptDir & "\��CC.exe", @ScriptDir)
		Case $mi_helpAbout
			Run(@ScriptDir & '\tools\About.exe "' & $VERSION & '" "' & $DATE & '"', @ScriptDir)
		Case $mi_helpHelp
			setHelpLayout(@SW_SHOW)
		Case $mi_helpExit
			quit()
		Case $GUI_EVENT_CLOSE
			quit()
	EndSwitch
	handleMes($message[0])
WEnd

Func handleMes($msg)
	Local $path
	For $i = 1 To $mi_clibuilder[0]
		If $msg == $mi_clibuilder[$i] Then
			$path = IniRead(@ScriptDir & "\clibuilder.ini", $i, "path", "error")
			If Not FileExists($path) Then
				MsgBox(8208, "", "�����" & IniRead(@ScriptDir & "\clibuilder.ini", $i, "text", "error") & "����Ч��")
				Return
			EndIf
			disableAll()
			clibuilderOpen($path)
			enableAll()
			ExitLoop
		EndIf
	Next
	If $msg == $mi_clibuilderConf Then
		openConfigFile("clibuilder.ini")
	EndIf
	
	For $i = 1 To $mi_favourite[0]
		If $msg == $mi_favourite[$i] Then
			$path = IniRead(@ScriptDir & "\favourite.ini", $i, "path", "error")
			If Not FileExists($path) Then
				MsgBox(8208, "ClearCase Helper", "�����" & IniRead(@ScriptDir & "\favourite.ini", $i, "text", "error") & "����Ч��")
				Return
			EndIf
			disableAll()
			Run("c:\windows\explorer.exe " & $path, "c:\windows")
			enableAll()
			ExitLoop
		EndIf
	Next
	If $msg == $mi_favouriteConf Then
		openConfigFile("favourite.ini")
	EndIf
EndFunc

Func setLayout()
	Local $lastPos[4]
	$lastPos[0] = 400
	$lastPos[1] = 300
	$lastPos[2] = 0
	$lastPos[3] = 30
	$gui_main = GUICreate("ClearCase Helper", 290, $lastPos[3], $lastPos[0] + $lastPos[2] + 1, $lastPos[1])
	GUICtrlCreateLabel("|", 2, 0, 15, $lastPos[3] - 1, $SS_LEFT)
	GUICtrlSetFont(-1, 17, 400, 0, "MS Sans Serif")
	GUICtrlSetState(-1, $GUI_DISABLE)
	
	$btn_merge = GUICtrlCreateButton("Merge", 10, 0, 50, $lastPos[3] - 1, BitOR($BS_LEFT, $BS_CENTER, $BS_FLAT))
	$btn_mergeDropDown = GUICtrlCreateButton("��", 60, 0, 14, $lastPos[3] - 1, BitOR($BS_LEFT, $BS_CENTER, $BS_FLAT))
	GUICtrlCreateLabel("|", 77, 0, 15, $lastPos[3] - 1, $SS_LEFT)
	GUICtrlSetFont(-1, 17, 400, 0, "MS Sans Serif")
	GUICtrlSetState(-1, $GUI_DISABLE)
	Local $dummy_merge = GUICtrlCreateDummy()
	$ctxt_merge = GUICtrlCreateContextMenu($dummy_merge)
	$mi_mergeMulti = GUICtrlCreateMenuItem("Merge����ļ���", $ctxt_merge)
	$mi_mergeSingle = GUICtrlCreateMenuItem("Merge�����ļ���", $ctxt_merge)
	GUICtrlCreateMenuItem("", $ctxt_merge)
	$mi_mergeHelp = GUICtrlCreateMenuItem("����...", $ctxt_merge)
	$mi_mergeConf = GUICtrlCreateMenuItem("����...", $ctxt_merge)
	
	$btn_selection = GUICtrlCreateButton("Selection", 85, 0, 65, $lastPos[3] - 1, BitOR($BS_LEFT, $BS_CENTER, $BS_FLAT))
	GUICtrlCreateLabel("|", 152, 0, 15, $lastPos[3] - 1, $SS_LEFT)
	GUICtrlSetFont(-1, 17, 400, 0, "MS Sans Serif")
	GUICtrlSetState(-1, $GUI_DISABLE)
	Local $dummy_selection   = GUICtrlCreateDummy()
	$ctxt_selection = GUICtrlCreateContextMenu($dummy_selection)
	$mi_selection = GUICtrlCreateMenuItem("����cc·��", $ctxt_selection)
	$mi_selectionEx = GUICtrlCreateMenuItem("����Ӳ��·��", $ctxt_selection)
	$mi_selectionExploreFile = GUICtrlCreateMenuItem("��������д�...", $ctxt_selection)
	GUICtrlCreateMenuItem("", $ctxt_selection)
	$mi_selectionFindPrivateFiles = GUICtrlCreateMenuItem("����˽���ļ�", $ctxt_selection)
	
	$btn_cq = GUICtrlCreateButton("ClearQuest", 160, 0, 70, $lastPos[3] - 1, BitOR($BS_LEFT, $BS_CENTER, $BS_FLAT))
	GUICtrlCreateLabel("|", 232, 0, 15, $lastPos[3] - 1, $SS_LEFT)
	GUICtrlSetFont(-1, 17, 400, 0, "MS Sans Serif")
	GUICtrlSetState(-1, $GUI_DISABLE)
	Local $dummy_cq = GUICtrlCreateDummy()
	$ctxt_cq = GUICtrlCreateContextMenu($dummy_cq)
	$mi_cqLaunch = GUICtrlCreateMenuItem("����CQ...", $ctxt_cq)
	$mi_cqNewChangemenForm = GUICtrlCreateMenuItem("�½������...", $ctxt_cq)
	$mi_cqNewUnitTestForm = GUICtrlCreateMenuItem("�½���Ԫ���Ե�...", $ctxt_cq)
	Local $cqNewChangemenFormFolder = GUICtrlCreateMenu("�ύ������", $ctxt_cq)
	$mi_cqsubmitSolution = GUICtrlCreateMenuItem("�ύ������", $cqNewChangemenFormFolder)
	$mi_cqAddFiles2Solution = GUICtrlCreateMenuItem("�����ѡ�ļ�", $cqNewChangemenFormFolder)
	GUICtrlCreateMenuItem("", $cqNewChangemenFormFolder)
	$mi_cqAudit = GUICtrlCreateMenuItem("���ͨ��", $cqNewChangemenFormFolder)
	$mi_cqResearchResult = GUICtrlCreateMenuItem("�����о����", $cqNewChangemenFormFolder)
	GUICtrlCreateMenuItem("", $ctxt_cq)
	$mi_cqPwd = GUICtrlCreateMenuItem("��������...", $ctxt_cq)
	$mi_cqConf = GUICtrlCreateMenuItem("����...", $ctxt_cq)
	
	$btn_help = GUICtrlCreateButton("Option", 240, 0, 50, $lastPos[3] - 1, BitOR($BS_LEFT, $BS_CENTER, $BS_FLAT))
	Local $dummy_help = GUICtrlCreateDummy()
	$ctxt_help = GUICtrlCreateContextMenu($dummy_help)
	$mi_helpTopmost = GUICtrlCreateMenuItem("�ö�����", $ctxt_help)
	$mi_helpCCSwitcher = GUICtrlCreateMenuItem("", $ctxt_help)
	$mi_helpCCSwitcher = GUICtrlCreateMenuItem("ClearCase�л�����", $ctxt_help)
	$mi_helpCCService = GUICtrlCreateMenuItem("ClearCase����", $ctxt_help)
	$mi_grabCC = GUICtrlCreateMenuItem("��CC", $ctxt_help)
	GUICtrlCreateMenuItem("", $ctxt_help)
	$mi_helpAbout = GUICtrlCreateMenuItem("����", $ctxt_help)
	$mi_helpHelp = GUICtrlCreateMenuItem("����", $ctxt_help)
	GUICtrlCreateMenuItem("", $ctxt_help)
	$mi_helpExit = GUICtrlCreateMenuItem("�˳�", $ctxt_help)
	GUISetState(@SW_SHOW, $gui_main)
	WinActivate("Rational ClearCase Explorer", "Menu bar")
EndFunc   ;==>setLayout

Func setHelpLayout($state = @SW_HIDE)
	Local Const $winHeigh = 600
	Local Const $winWidth = 800
	Local Const $browserHeigh = $winHeigh
	Local Const $browserWidth = $winWidth

	_IEErrorHandlerRegister ()
	Local $oIE = _IECreateEmbedded ()
	$gui_help = GUICreate("ClearCase Helper", $winWidth, $winHeigh, _
		(@DesktopWidth - $winWidth) / 2, (@DesktopHeight - $winHeigh) / 2, _
		$WS_CAPTION + $WS_SYSMENU + $WS_MINIMIZEBOX + $WS_VISIBLE + $WS_CLIPSIBLINGS)
	GUICtrlCreateObj($oIE, 0, 0, $browserWidth, $browserHeigh)
	_IENavigate ($oIE, @ScriptDir & "\help\help.html")

	GUISetState($state, $gui_help)
EndFunc

Func merge($isMulti = False)
	If Not FileExists ($mmExePath) Then
		MsgBox(8256, "ClearCase Helper", "����ʧ�ܣ�" & @CRLF & "������Ϣ��" & @CRLF & _
			"��ȷ��cc�Ѿ���ȷ��װ������·��������ȷ������" & $mmExePath & "����ȷ��λ���ϡ�")
		openConfigFile("mergeConf.ini", "[main]")
		Return
	EndIf
	Local $mergePath = getMultiCCPath($isMulti)
	If Not IsArray($mergePath) Then
		MsgBox(8256, "ClearCase Helper", "����ʧ�ܣ�" & @CRLF & "������Ϣ��" & @CRLF & $errorText)
		Return
	EndIf
	Local $iMsgBoxAnswer = MsgBox(8227,"ClearCase Helper","��Merge֮ǰ�Ƿ�updateһ��Ŀ���ļ���")
	Select
		Case $iMsgBoxAnswer = 6 ;Yes
			_updateSelectedFiles($mergePath)
		Case $iMsgBoxAnswer = 7 ;No
			
		Case $iMsgBoxAnswer = 2 ;Cancel
			Return
	EndSelect
	If $mergePath[0] == 0 Then
		$errorText = "û��ѡ���κ��ļ������ļ��У�"
		MsgBox(8256, "ClearCase Helper", "����ʧ�ܣ�" & @CRLF & "������Ϣ��" & @CRLF & $errorText)
		Return
	EndIf
	
	; �Ѿ���һ��Merge Manager���������У��������ڽ���merge������
	Local $confirm = -1
	If WinExists("files2merge.mrgman - Merge Manager", "Running") Or _
		WinExists("files2merge.mrgman - Merge Manager", "Searching") Then
		$confirm = MsgBox(292,"ClearCase Helper", _
			"�Ѿ���һ��Merge Manager���������У��������ڽ���merge������" & @CRLF & _
			"�Ƿ�ȷ����ֹ��Merge Manager�ĵ�ǰ����")
	EndIf
	If $confirm == 7 Then ;��ȡ����������
		Return
	EndIf
	
	Local $pid
	;�Ѿ���һ��Merge Manager�ڴ� files2merge.mrgman �ˣ�Ҫ�ص��������
	If WinExists("files2merge.mrgman - Merge Manager", "Ready") Then
		WinClose("files2merge.mrgman - Merge Manager", "Ready")
		If WinWait("Merge Manager", "���Ķ����浽", 3) == 0 Then
			$pid = WinGetProcess("files2merge.mrgman - Merge Manager")
			ProcessClose($pid)
		EndIf
		ControlClick("Merge Manager", "���Ķ����浽", 6)
		If WinWaitClose("files2merge.mrgman - Merge Manager", "", 10) == 0 Then
			$pid = WinGetProcess("files2merge.mrgman - Merge Manager")
			ProcessClose($pid)
		EndIf
	EndIf
	
	Local $viewTag = $mergePath[ $mergePath[0] + 1 ]
	Local $integ = IniRead(@ScriptDir & "\mergeConf.ini", $viewTag, "toBranch", "error")
	Local $bugifx = IniRead(@ScriptDir & "\mergeConf.ini", $viewTag, "fromBranch", "error")
	If $integ == "error" Or $bugifx == "error" Then
		MsgBox(8256, "ClearCase Helper", "����ʧ�ܣ�" & @CRLF & "������Ϣ��" & @CRLF & _
			"�޷���ȡ����ȷ�ķ�֧�����ļ���" & @ScriptDir & "\mergeConf.ini" & @CRLF & _
			"����ȷ������ļ����ڲ�����������")
		openConfigFile("mergeConf.ini", "[main]")
		Return
	EndIf
	If Not generateMergeFile($integ, $bugifx, $mergePath) Then
		MsgBox(8256, "ClearCase Helper", "����files2merge.mrgman�ļ�ʧ�ܣ�")
		Return
	EndIf
	
	; ����һ��Merge Manager���򿪸ո��������˵� files2merge.mrgman �ļ�
	Run ($mmExePath & " " & @ScriptDir & "\files2merge.mrgman", $ccHome & "\bin")
	If WinWait ("files2merge.mrgman - Merge Manager", "Ready", 30) == 0 Then
		MsgBox(8256, "ClearCase Helper", "����ʧ�ܣ�" & @CRLF & "������Ϣ��" & @CRLF & _
			$mmExePath & "�޷�������")
		openConfigFile("mergeConf.ini", "[main]")
		Return
	EndIf
	WinMenuSelectItem("files2merge.mrgman - Merge Manager", "Ready", "&Merge", "&Refresh Element List")
	MsgBox(8256, "ClearCase Helper", "Merge Manager�Ѿ�����������������Ҫmerge���ļ�������Merge Manager�м������Ĳ�����")
	WinActivate("files2merge.mrgman - Merge Manager")
	
EndFunc

Func generateMergeFile($integ, $bugifx, $mergePath)
	If Not IsArray($mergePath) Then Return False
	If $mergePath[0] == 0 Then
		Return False
	EndIf
	Local $mgrFile = FileOpen(@ScriptDir & "\files2merge.mrgman", 18)
	If $mgrFile == -1 Then
		MsgBox(8256, "ClearCase Helper", "����files2merge.mrgman�ļ�ʧ�ܣ�" & @CRLF & _
					"������Ϣ���޷���files2merge.mrgman�ļ���")
		Return False
	EndIf
	Local $bin = Binary("0xffff02000D00") & Binary("CFindCriteria") & Binary("0x01000000")
	$bin = $bin & Binary("0x" & Hex(StringLen($integ), 2)) & Binary($integ) & Binary("0x00")
	$bin = $bin & Binary("0x" & Hex(StringLen($bugifx), 2)) & Binary($bugifx) & Binary("0x00")
	$bin = $bin & Binary("0x00") & Binary("0x00") & Binary("0x00") & Binary("0x01")
	$bin = $bin & Binary("0x" & Hex($mergePath[0], 2)) & Binary("0x00")
	For $i = 1 To $mergePath[0]
		$bin = $bin & Binary("0x" & Hex(StringLen($mergePath[$i]), 2)) & Binary($mergePath[$i])
	Next
	$bin = $bin & Binary("0x00") & Binary("0x00")
	FileWrite($mgrFile, $bin)
	FileClose($mgrFile)
	Return True
EndFunc

Func _updateSelectedFiles($mergePath)
	Local $i, $cmd = '"' & $ccHome & '\bin\cleartool.exe" update -print -log "' & @ScriptDir & '\UpdateLog.updt" '
	Local $viewTag = $mergePath[ $mergePath[0] + 1 ]
	Local $integ = IniRead(@ScriptDir & "\mergeConf.ini", $viewTag, "toBranch", "error")
	For $i = 1 To $mergePath[0]
		$cmd &= '"' & $integ & $mergePath[$i] & '" '
	Next
	SplashTextOn("����update","����ִ��update��������ȴ�...","300","100","-1","-1",50,"����","12","700")
	RunWait($cmd, $ccHome & "\bin", @SW_HIDE)
	SplashOff ()
	Sleep(200)
	Run('"' & $ccHome & '\bin\clearviewupdate.exe" "' & @ScriptDir & '\UpdateLog.updt"', $ccHome & "\bin", @SW_MINIMIZE)
EndFunc

Func mergeHelp()
	disableAll()
	MsgBox(64, "ClearCase Helper", _
		"�� Merge��ť��" & @CRLF & " mergeһ���ļ��л��߶���ļ�����cc��ѡ����Ҫmerge���ļ��л���ѡ������ļ���" & @CRLF & _
		" Ȼ�󵥻������ť��������ɶ�ѡ���ļ�/�ļ��е�merge������" & @CRLF & @CRLF & _
		"�� Merge����ļ��в˵���" & @CRLF & _
		" ������ܺ�Merge��ť���ƣ�ֻ��֧��ͬʱѡ�����ļ�/�ļ��С�ѡ������˵���" & @CRLF & _
		" ���и��Ի���������밴�նԻ����ϵ���ʾ������" & @CRLF & @CRLF & _
		"�� Merge�����ļ��в˵���" & @CRLF & _
		" ��Merge��ť����һ����")
	enableAll()
EndFunc

Func openConfigFile($file, $text = "")
	If WinExists($file & " - " & "���±�", $text) Then
		WinActivate($file & " - " & "���±�", $text)
	Else
		Run("notepad " & @ScriptDir & "\" & $file)
	EndIf
EndFunc

Func checkRestartFlag()
	If StringLower(RegRead($REG_BASE, "restartCCHelperFlag")) == "true" Then
		RegWrite($REG_BASE, "restartCCHelperFlag", "REG_SZ", "false")
		Exit
	EndIf
EndFunc

;
; $isMulti ��ʾ�û�ѡ���� $mi_mergeMulti �˵��
; ��������ֻmergeһ���ļ������ļ���
;
; ���ص�����ṹ��
; $paths[0]: ѡ����ļ�·������
; $paths[1]: ��1��ѡ���ļ�·��
; $paths[2]: ��2��ѡ���ļ�·��
; ...
; $paths[n]: ��n��ѡ���ļ�·��
; $paths[n+1]: ������view tag������
;
Func getMultiCCPath($isMulti = True)
	Local $count = 0, $paths[105]
	$paths[0] = $count
	
	If Not $isMulti Then
		$paths = getSelection("cc_path")
		For $i = 1 To $paths[0]
			$paths[$i] = "\" & $paths[$i]
		Next
		Return $paths
	EndIf
	
	Local $pos = WinGetPos("Rational ClearCase Explorer", "Menu bar"), $x
	Local $splashText = _
		" 1��ѡ����ҪMerge��Ŀ¼��" & @CRLF & _
		" 2�����¡��ո񡿼�ȷ�ϣ�" & @CRLF & _
		" 3���ظ�1��2��ֱ��ѡ�������е�Ŀ¼�����¡�ENTER��������" & @CRLF & _
		" 4�������ȡ���������񣬰��¡�ESC����" & @CRLF & @CRLF & _
		" �Ѿ�ѡ���Ŀ¼��" & @CRLF
	$x = $pos[2] - 620
	If $x < 0 Then $x = 200
	SplashTextOn("ѡ����ҪMerge��Ŀ¼ - ClearCase Helper",$splashText,"600","200", $x,"24",20,"����","9","400")
	
	Local $n = 0
	Local $splashTextAll = ""
	Local $viewTag = "unkown"
	While 1
		If _IsPressed("1b") Then ; ESC: task is cancelled
			$errorText = "�û�ȡ���˱�������"
			SplashOff()
			Return ""
		EndIf
		If _IsPressed("0D") Then ; ENTER: process forward
			SplashOff()
			$paths[0] = $n
			$paths[ $n + 1 ] = $viewTag
			Return $paths
		EndIf
		If _IsPressed("20") Then ; SPACE: select
			Local $tmpArr = getSelection("cc_path")
			If $viewTag <> $tmpArr[ $tmpArr[0] + 1 ] And $viewTag <> "unkown" Then
				MsgBox(8256, "ClearCase Helper", "һ��mergeֻ��ѡ��ͬһ����֧�µ��ļ���" & @CRLF & _
						"����ѡ����ļ����������ԡ�")
				ContinueLoop
			Else
				$viewTag = $tmpArr[ $tmpArr[0] + 1 ]
			EndIf
			For $i = 1 To $tmpArr[0]
				If StringInStr($splashTextAll, $tmpArr[$i]) <> 0 Then
					; �Ѿ������ˣ�����Ҫ���
					ContinueLoop
				EndIf
				$n = $n + 1
				If $n >= 100 Then
					; �����������ͷ�100�������˾Ͳ���������
					$paths[0] = $n - 1
					MsgBox(8256, "ClearCase Helper", "�����������ͷ�100����merge�ļ������ļ��У�" & @CRLF & _
							"�������Ѿ�ѡ����ļ������ļ��н���merge...")
					Return $paths
				EndIf
				$paths[$n] = "\" & $tmpArr[$i]
				$splashTextAll = $splashTextAll & $tmpArr[$i] & @CRLF
				If StringLen($tmpArr[$i]) >= 93 Then
					$splashText = $splashText & "   ..." & StringRight($tmpArr[$i], 90) & @CRLF
				Else
					$splashText = $splashText & "   " & $tmpArr[$i] & @CRLF
				EndIf
				ControlSetText("ѡ����ҪMerge��Ŀ¼ - ClearCase Helper", "", "Static1", $splashText)
			Next
			Do
				Sleep(20)
			Until Not _IsPressed("20")
		Else
			Sleep(20)
		EndIf
		Sleep(20)
	WEnd
EndFunc

Func disableAll()
	GUICtrlSetState($btn_merge, $GUI_DISABLE)
	GUICtrlSetState($btn_mergeDropDown, $GUI_DISABLE)
	GUICtrlSetState($btn_selection, $GUI_DISABLE)
	GUICtrlSetState($btn_clibuilder, $GUI_DISABLE)
	GUICtrlSetState($btn_cq, $GUI_DISABLE)
	GUICtrlSetState($btn_help, $GUI_DISABLE)
EndFunc

Func enableAll()
	GUICtrlSetState($btn_merge, $GUI_ENABLE)
	GUICtrlSetState($btn_mergeDropDown, $GUI_ENABLE)
	GUICtrlSetState($btn_selection, $GUI_ENABLE)
	GUICtrlSetState($btn_clibuilder, $GUI_ENABLE)
	GUICtrlSetState($btn_cq, $GUI_ENABLE)
	GUICtrlSetState($btn_help, $GUI_ENABLE)
EndFunc

Func getCCInstallPath()
	Local $ccInstallPath = IniRead(@ScriptDir & "\mergeConf.ini", "main", "ccInstallPath", "c:\Program Files\Rational\ClearCase")
	If StringRight($ccInstallPath, 1) == "\" Then $ccInstallPath = StringLeft($ccInstallPath, StringLen($ccInstallPath))
	If Not FileExists($ccInstallPath & "\bin\clearexplorer.exe") Or Not FileExists($ccInstallPath & "\bin\clearmrgman.exe") Then
		$ccInstallPath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Atria\ClearCase\2.0", "ProductHome")
		IniWrite(@ScriptDir & "\mergeConf.ini", "main", "ccInstallPath", $ccInstallPath)
	EndIf
	
	Return $ccInstallPath
EndFunc

Func install()
	If StringLower(RegRead($REG_BASE, "installPath")) == StringLower(@ScriptFullPath) And _
		StringLower(RegRead($REG_BASE, "isInstalled")) <> "false" Then
		Return
	EndIf
	FileCreateShortcut(@ScriptFullPath, @DesktopCommonDir & "\Rational ClearCase")
	FileCreateShortcut(@ScriptFullPath, "C:\Documents and Settings\" & @UserName & _
		"\Application Data\Microsoft\Internet Explorer\Quick Launch\Rational ClearCase")
	FileCreateShortcut(@ScriptFullPath, @ProgramsCommonDir & "\Rational ClearCase\ClearCase Explorer")
	
	RegWrite($REG_BASE, "isInstalled", "REG_SZ", "true")
	RegWrite($REG_BASE, "installPath", "REG_SZ", @ScriptFullPath)
EndFunc

Func quit()
	If $gui_help == "" Then
		Exit
	Else
		GUIDelete($gui_help)
		$gui_help = ""
	EndIf
EndFunc

; cc_path: ����cc·�������а�
; ex_path: ����ʵ��·�������а�
; explore: ��windows������д򿪵�ǰĿ¼
; 
; ���ص�����ṹ��
; $selection[0]: ѡ����ļ�·������
; $selection[1]: ��1��ѡ���ļ�·��
; $selection[2]: ��2��ѡ���ļ�·��
; ...
; $selection[n]: ��n��ѡ���ļ�·��
; $selection[n+1]: ������view tag�����ƣ�����Ϊ ""
; 
Func getSelection($type = "cc_path")
	Local $hWnd = ControlGetHandle("Rational ClearCase Explorer", "Menu bar", 2)
	Local $count = _GUICtrlListView_GetItemCount($hWnd)
	Local $selection[3], $ccPath, $explorerTitle, $title, $viewTag = "", $pos = 0
	If $type == "ex_path" Or $type == "explore" Then
		$title = WinGetTitle("Rational ClearCase Explorer", "Menu bar")
		$title = StringMid($title, StringInStr($title, "(") + 1)
		$title = StringMid($title, 1, StringLen($title) - 1) & "\"
		If $type == "explore" Then
			$explorerTitle = StringMid($title, StringInStr($title, "\", 0, -2) + 1)
			If WinExists($explorerTitle, $title) Then
				WinActivate($explorerTitle, $title)
			Else
				Run("explorer " & $title)
			EndIf
			$selection[0] = 1
			$selection[1] = ""
			Return $selection
		EndIf
	ElseIf $type == "cc_path" Then
		$ccPath = getCCPath()
		$pos = StringInStr($ccPath[$ccPath[0] + 1], '\')
		If $pos == 0 Then
			$viewTag = $ccPath[$ccPath[0] + 1]
		Else
			$viewTag = StringLeft($ccPath[$ccPath[0] + 1], $pos - 1)
		EndIf
		$title = StringMid($ccPath[$ccPath[0] + 1], StringInStr($ccPath[$ccPath[0] + 1], "\") + 1) & "\"
	EndIf
	Local $n = 0
	For $i = 0 To $count - 1
		If Not _GUICtrlListView_GetItemSelected($hWnd, $i) Then ContinueLoop
		$n = $n + 1
		ReDim $selection[$n + 2]
		$selection[$n] = $title & _GUICtrlListView_GetItemText($hWnd, $i)
	Next
	$selection[0] = $n
	If $n == 0 Then
		; û��ѡ���ļ�����·������
		$selection[0] = 1
		$selection[1] = StringLeft($title, StringLen($title) - 1)
		$selection[2] = $viewTag
		$n = 1
	EndIf
	$selection[$n + 1] = $viewTag
	Return $selection
EndFunc

Func putPath2Clipboard($paths)
	If Not IsArray($paths) Then
		MsgBox(8240, "ClearCase Helper", "��ѡ��CC������е��ļ������ԡ�")
		Return
	EndIf
	Local $str = ""
	For $i = 1 To $paths[0]
		$str = $str & $paths[$i] & @CRLF
	Next
	ClipPut($str)
	MsgBox(8256, "ClearCase Helper", $paths[0] & "����Ŀ�Ѿ���ӵ����а��С�", 5)
EndFunc

Func createClibuiderMenuItem()
	GUICtrlCreateMenuItem("", $ctxt_selection)
	Local $mi_clibuilderFolder = GUICtrlCreateMenu("CliBuilder����", $ctxt_selection)
	Local $cliPath = IniRead(@ScriptDir & "\clibuilder.ini", "main", "clipath", "error")
	If Not FileExists($cliPath) Then
;~ 		MsgBox(8208, "ClearCase Helper", "CliBuilder·����Ч������clibuilder.ini��main section�����á�")
;~ 		openConfigFile("clibuilder.ini")
;~ 		$isFavouriteInited = True
		Return
	EndIf
	Local $sec = IniReadSectionNames(@ScriptDir & "\clibuilder.ini")
	If Not IsArray($sec) Then
		$mi_clibuilderConf = GUICtrlCreateMenuItem("����...", $ctxt_selection)
		If Not FileExists(@ScriptDir & "\clibuilder.ini") Then
			FileWriteLine(@ScriptDir & "\clibuilder.ini", "")
		EndIf
		$isFavouriteInited = True
		Return
	EndIf
	ReDim $mi_clibuilder[$sec[0]]
	Local $n = 0
	For $i = 1 To $sec[0] - 1
		If StringLower($sec[$i]) == "seperator" Then
			GUICtrlCreateMenuItem("", $mi_clibuilderFolder)
			ContinueLoop
		EndIf
		$n = $n + 1
		$mi_clibuilder[$n] = GUICtrlCreateMenuItem(IniRead(@ScriptDir & "\clibuilder.ini", $sec[$i], "text", "error"), _
			$mi_clibuilderFolder)
	Next
	$mi_clibuilder[0] = $n
	ReDim $mi_clibuilder[$n + 1]
	GUICtrlCreateMenuItem("", $mi_clibuilderFolder)
	$mi_clibuilderConf = GUICtrlCreateMenuItem("����...", $mi_clibuilderFolder)
	$isFavouriteInited = True
EndFunc

Func clibuilderOpen($path)
	If StringRight($path, 1) <> "\" Then
		$path = $path & "\"
	EndIf
;~ 	If WinExists("�˻������ V3.0.1 - [" & $path) Then
;~ 		WinActivate("�˻������ V3.0.1 - [" & $path)
;~ 		Return
;~ 	EndIf
	If Not WinExists("�˻������ V", "") Then
		Local $cliPath = IniRead(@ScriptDir & "\clibuilder.ini", "main", "clipath", "error")
		If StringRight($cliPath, 1) <> "\" Then $cliPath = $cliPath & "\"
		Run($cliPath & "CliBuilder.exe", $cliPath)
		WinWait("�˻������ V", "")
	EndIf
	WinActivate("�˻������ V", "")
	Sleep(300)
	ControlClick("�˻������", "", "[instance:1; Class:TToolBar]", "left", 1, 8, 8)
	If WinWait("����ɸѡ", "ȷ��(&O)", 20) == 0 Then
		MsgBox(8208, "ClearCase Helper", "������ɸѡ���ڴ���")
		Return
	EndIf
	ControlSetText("����ɸѡ", "ȷ��(&O)", 1001, $path)
	ControlCommand("����ɸѡ", "ȷ��(&O)", "[Text:��������]", "Check", "")
	ControlCommand("����ɸѡ", "ȷ��(&O)", "[Text:����Ϊȱʡ����]", "Check", "")
	ControlClick("����ɸѡ", "ȷ��(&O)", "[Text:ȷ��(&O)]")
EndFunc

Func createFavouriteMenuItem()
	GUICtrlCreateMenuItem("", $ctxt_selection)
	Local $mi_favouriteFolder = GUICtrlCreateMenu("�����ļ���", $ctxt_selection)
	Local $sec = IniReadSectionNames(@ScriptDir & "\favourite.ini")
	If Not IsArray($sec) Then
		$mi_favouriteConf = GUICtrlCreateMenuItem("����...", $mi_favouriteFolder)
		If Not FileExists(@ScriptDir & "\favourite.ini") Then
			FileWriteLine(@ScriptDir & "\favourite.ini", "")
		EndIf
		$isFavouriteInited = True
		Return
	EndIf
;~ 	Local $path
	ReDim $mi_favourite[$sec[0] + 1]
	Local $n = 0
	For $i = 1 To $sec[0]
		If StringLower($sec[$i]) == "separator" Then
			GUICtrlCreateMenuItem("", $mi_favouriteFolder)
			ContinueLoop
		EndIf
		$n = $n + 1
		$mi_favourite[$n] = GUICtrlCreateMenuItem(IniRead(@ScriptDir & "\favourite.ini", $sec[$i], "text", "error"), _
			$mi_favouriteFolder)
	Next
	$mi_favourite[0] = $n
	ReDim $mi_favourite[$n + 1]
	GUICtrlCreateMenuItem("", $mi_favouriteFolder)
	$mi_favouriteConf = GUICtrlCreateMenuItem("����...", $mi_favouriteFolder)
	$isFavouriteInited = True
EndFunc

Func submitSolution()
	If Not WinExists("Rational ClearQuest", "Standard") Then
		MsgBox(8208, "ClearCase Helper", "CQδ����...")
		Return
	EndIf
	Local $isEnabled = StringLower(IniRead(@ScriptDir & "\clearquest.ini", "main", "enableCustomedSolutions", "false"))
	Local $text
	If $isEnabled == "false" Then
		$text = getDefaultSolution()
		If $text == "" Then Return
	Else
		Local $solutions = IniReadSection(@ScriptDir & "\clearquest.ini", "solution")
		If @error Or $solutions[0][0] == 0 Then
			$text = getDefaultSolution()
			If $text == "" Then Return
		EndIf
		$text = getCustomedSolution($solutions)
	EndIf
	ControlSetText("Rational ClearQuest", "Standard", 12, $text)
	WinActivate("Rational ClearQuest", "Standard")
	Sleep(200)
	$isEnabled = StringLower(IniRead(@ScriptDir & "\clearquest.ini", "main", "enableCustomedDescription", "false"))
	Local $discription
	If $isEnabled == "false" Then
		$discription = getDefaultDescription()
	Else
		Local $descriptions = IniReadSection(@ScriptDir & "\clearquest.ini", "discription")
		If @error Or $descriptions[0][0] == 0 Then
			$discription = getDefaultSolution()
			If $discription == "" Then Return
		EndIf
		$discription = getCustomedSolution($descriptions)
	EndIf
	Local $hWnd = ControlGetHandle("Rational ClearQuest", "Standard", 12320)
	_GuiCtrlTab_SetCurFocus($hWnd, 5)
	ControlSetText("Rational ClearQuest", "Standard", 10, $discription & @CRLF)
	ControlSetText("Rational ClearQuest", "Standard", 18, "1")
	ControlCommand("Rational ClearQuest", "Standard", 14, "SelectString", '��')
	ControlCommand("Rational ClearQuest", "Standard", 16, "SelectString", '���ɲ���')
EndFunc

Func auditOk()
	If Not WinExists("Rational ClearQuest", "Standard") Then
		MsgBox(8208, "ClearCase Helper", "CQδ����...")
		Return
	EndIf
	If WinMenuSelectItem("Rational ClearQuest", "Standard", "&Actions", "&2 ���ͨ��") == 0 Then
		WinActivate("Rational ClearQuest", "Standard")
		Sleep(200)
		Send("!a")
		Sleep(50)
		Send("2")
	EndIf
	
	Local $hWnd = ControlGetHandle("Rational ClearQuest", "Standard", 12320)
	_GuiCtrlTab_SetCurFocus($hWnd, 7)
	Sleep(50)
	Local $var = ""
	; ������
	$var = IniRead(@ScriptDir & "\clearquest.ini", "audit", "opinion", "ok")
	ControlCommand("Rational ClearQuest", "Standard", 10, "EditPaste", $var)
	; ��˹�����
	$var = IniRead(@ScriptDir & "\clearquest.ini", "audit", "workload", "")
	ControlSetText("Rational ClearQuest", "Standard", 33, $var)
	; �������׶�
	$var = IniRead(@ScriptDir & "\clearquest.ini", "audit", "phase", "")
	ControlCommand("Rational ClearQuest", "Standard", "[CLASS:ComboBox; INSTANCE:3]", "SelectString", $var)
	; ����ԭ��1������
	$var = IniRead(@ScriptDir & "\clearquest.ini", "audit", "errorClass1", "")
	ControlFocus("Rational ClearQuest", "Standard", "[CLASS:ComboBox; INSTANCE:5]")
	ControlCommand("Rational ClearQuest", "Standard", "[CLASS:ComboBox; INSTANCE:5]", "SelectString", $var)
	; ����ԭ��2������
	$var = IniRead(@ScriptDir & "\clearquest.ini", "audit", "errorClass2", "")
	ControlFocus("Rational ClearQuest", "Standard", "[CLASS:ComboBox; INSTANCE:4]")
	ControlCommand("Rational ClearQuest", "Standard", "[CLASS:ComboBox; INSTANCE:4]", "SelectString", $var)
	; �Ƿ��迪����֤
	$var = IniRead(@ScriptDir & "\clearquest.ini", "audit", "needDevlopValidate", "��")
	ControlCommand("Rational ClearQuest", "Standard", "[CLASS:ComboBox; INSTANCE:6]", "SelectString", $var)
	If $var <> "��" Then Return
	_GuiCtrlTab_SetCurFocus($hWnd, 3)
	Sleep(50)
	; ������֤�ˣ������Ƿ��迪����֤��Ϊ���ǡ���ʱ�����Ч
	$var = IniRead(@ScriptDir & "\clearquest.ini", "audit", "validator", "")
	ControlCommand("Rational ClearQuest", "Standard", "[CLASS:ComboBox; INSTANCE:3]", "SelectString", $var)
	_GuiCtrlTab_SetCurFocus($hWnd, 7)
EndFunc

Func researchResult()
	If Not WinExists("Rational ClearQuest", "Standard") Then
		MsgBox(8208, "ClearCase Helper", "CQδ����...")
		Return
	EndIf
	If WinMenuSelectItem("Rational ClearQuest", "Standard", "&Actions", "&2 �����о����") == 0 Then
		WinActivate("Rational ClearQuest", "Standard")
		Sleep(200)
		Send("!a")
		Sleep(50)
		Send("2")
	EndIf
	Local $hWnd = ControlGetHandle("Rational ClearQuest", "Standard", 12320)
	_GuiCtrlTab_SetCurFocus($hWnd, 3)
	Sleep(50)
	Local $txt = _
		"�� �� �ˣ�" & ControlGetText("Rational ClearQuest", "Standard", 10) & @CRLF & _
		"����׶Σ�����ʵ��" & @CRLF & _
		"������Χ����" & @CRLF & _
		"�����汾����" & @CRLF & _
		"�������ۣ����" & @CRLF & _
		"���鷽������ԭ�����" & @CRLF & _
		"ԭ�������"
	ControlSetText("Rational ClearQuest", "Standard", 12, $txt)
	ControlFocus("Rational ClearQuest", "Standard", 12)
	Sleep(10)
	ControlSend("Rational ClearQuest", "Standard", 12, "^{end}")
EndFunc

Func getDefaultSolution()
	Local $paths = getSelection("ex_path")
	Local $modFiles = "", $add2Solution
	If IsArray($paths) And $paths[0] >= 1 Then
		Local $attrib = FileGetAttrib($paths[1])
		If $attrib <> "" And Not StringInStr($attrib, "D") Then
			$add2Solution = MsgBox(8227,"ClearCase Helper","Ҫ����ѡ����ļ������޸��ļ���ӵ������������")
			If $add2Solution == 6 Then
				$paths = getSelection("cc_path")
				For $i = 1 To $paths[0]
					$modFiles = $modFiles & $paths[$i] & @CRLF
				Next
			ElseIf $add2Solution == 2 Then
				Return ""
			EndIf
		EndIf
	EndIf
	Local $str = ""
	For $i = 1 To $paths[0]
		$str = $str & $paths[$i] & @CRLF
	Next
	WinActivate("Rational ClearQuest", "Standard")
	Sleep(200)
	Local $hWnd = ControlGetHandle("Rational ClearQuest", "Standard", 12320)
	_GUICtrlTab_SetCurFocus($hWnd, 0)
	Local $subject = ControlGetText("Rational ClearQuest", "Standard", 23)
	Local $version = ControlGetText("Rational ClearQuest", "Standard", 43)
	_GUICtrlTab_SetCurFocus($hWnd, 4)
	Local $disposer = ControlGetText("Rational ClearQuest", "Standard", 10)
	_GUICtrlTab_SetCurFocus($hWnd, 5)
	If WinMenuSelectItem("Rational ClearQuest", "Standard", "&Actions", "&3 �ύ������") == 0 Then
		WinActivate("Rational ClearQuest", "Standard")
		Sleep(200)
		Send("!a")
		Sleep(50)
		Send("3")
	EndIf
	Local $time = TimerInit()
	Do
		Sleep(100)
		If ControlCommand("Rational ClearQuest", "Standard", 12, "IsEnabled", "") == 1 Then
			ExitLoop
		EndIf
	Until TimerDiff($time) > 10000
;~ 	Sleep(10000)
	Local $text =   "��������" & $subject & @CRLF
	$text = $text & "�� �� �ˣ�" & $disposer & "��" & _Now() & "��" & @CRLF
	$text = $text & "���϶��ԣ� <����>" & @CRLF
	$text = $text & "������Χ��" & @CRLF
	$text = $text & "�� �� �ˣ�" & $disposer & @CRLF
	$text = $text & "�����汾��" & $version & @CRLF
	$text = $text & "�����������ԭ�����" & @CRLF
	$text = $text & "���Է�Χ��" & @CRLF
	$text = $text & "�޸��ļ���" & @CRLF & $modFiles
	Return $text
EndFunc
	
Func getCustomedSolution($solutions)
	Local $text = ""
	For $i = 1 To $solutions[0][0]
		$text = $text & $solutions[$i][1] & @CRLF
	Next
	Return StringStripWS($text, 2)
EndFunc

Func getDefaultDescription()
	Local $hWnd = ControlGetHandle("Rational ClearQuest", "Standard", 12320)
	_GUICtrlTab_SetCurFocus($hWnd, 1)
	Return ControlGetText("Rational ClearQuest", "Standard", 10)
EndFunc

Func getCustomedDescription($descriptions)
	Local $text = ""
	For $i = 1 To $descriptions[0][0]
		$text = $text & $descriptions[$i][1] & @CRLF
	Next
	Return StringStripWS($text, 2)
EndFunc

Func addFiles2Solution()
	Local $hWnd = ControlGetHandle("Rational ClearQuest", "Standard", 12320)
	_GUICtrlTab_SetCurFocus($hWnd, 5)
	Local $modFiles = StringStripWS(ControlGetText("Rational ClearQuest", "Standard", 12), 3) & @CRLF
	Local $paths = getSelection("cc_path")
	For $i = 1 To $paths[0]
		If StringInStr($modFiles, $paths[$i] & @CRLF) Then ContinueLoop
		If StringInStr($paths[$i], ".contrib", 0, -1) Then ContinueLoop
		If StringInStr($paths[$i], ".bak", 0, -1) Then ContinueLoop
		If StringInStr($paths[$i], ".keep", 0, -1) Then ContinueLoop
		$modFiles = $modFiles & $paths[$i] & @CRLF
	Next
	ControlSetText("Rational ClearQuest", "Standard", 12, $modFiles)
	ControlFocus("Rational ClearQuest", "Standard", 12)
	ControlSend("Rational ClearQuest", "Standard", 12, "^{end}")
	ControlSend("Rational ClearQuest", "Standard", 12, "{enter}")
EndFunc

Func newChangementForm()
	If Not WinExists("Rational ClearQuest", "Standard") Then
		MsgBox(8208, "ClearCase Helper", "CQδ����...")
		Return
	EndIf
	WinActivate("Rational ClearQuest", "Standard")
	Sleep(200)
	ControlClick("Rational ClearQuest", "Standard", 33211)
	If WinWait("�ύ �����", "�����Ϣ", 30) == 0 Then
		MsgBox(8208, "ClearCase Helper", "�޷��½��������")
		Return
	EndIf
	Local $var = ""
	; ��Ŀ
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "project", "")
	ControlCommand("�ύ �����", "�����Ϣ", "[Instance:7; ID:34]", "SelectString", $var)
	; ��������
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "mainChangementType", "")
	ControlCommand("�ύ �����", "�����Ϣ", "[Instance:9; ID:38]", "SelectString", $var)
	; ����Ŀ
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "subProject", "")
	ControlFocus("�ύ �����", "�����Ϣ", "[Instance:10; ID:41]")
	ControlCommand("�ύ �����", "�����Ϣ", "[Instance:10; ID:41]", "SelectString", $var)
	; �������
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "changementType", "")
	ControlFocus("�ύ �����", "�����Ϣ", "[Instance:3; ID:25]")
	ControlCommand("�ύ �����", "�����Ϣ", "[Instance:3; ID:25]", "SelectString", $var)
	; ���ֻ
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "dicoveryActivity", "")
	ControlCommand("�ύ �����", "�����Ϣ", "[Instance:8; ID:36]", "SelectString", $var)
	; ����ȼ�
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "level", "")
	ControlFocus("�ύ �����", "�����Ϣ", "[Instance:4; ID:27]")
	ControlCommand("�ύ �����", "�����Ϣ", "[Instance:4; ID:27]", "SelectString", $var)
	; ���ְ汾 Ĭ��ѡ�����°汾
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "discoveredVersion", "")
	ControlFocus("�ύ �����", "�����Ϣ", "[Instance:11; ID:43]")
	Local $text = 0
	For $i = 20 To 0 Step -1
		ControlCommand("�ύ �����", "�����Ϣ", "[Instance:11; ID:43]", "SetCurrentSelection", $i)
		$text = StringStripWS( _
			ControlCommand("�ύ �����", "�����Ϣ", "[Instance:11; ID:43]", "GetCurrentSelection", ""), 3)
		If $text <> "0" And $text <> "" Then
			If $var == "" Then ExitLoop
			If $var == $text Then ExitLoop
		EndIf
	Next
	; �汾�����׶�
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "versionPhase", "")
	ControlCommand("�ύ �����", "�����Ϣ", "[Instance:12; ID:45]", "SelectString", $var)
	; ���ֵص�
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "dicoveryPosition", "")
	ControlCommand("�ύ �����", "�����Ϣ", "[Instance:5; ID:29]", "SelectString", $var)
	; ������
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "whoDiscovered", "")
	ControlCommand("�ύ �����", "�����Ϣ", "[Instance:2; ID:19]", "SelectString", $var)
	; �����˲���
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "dicovererDept", "")
	ControlCommand("�ύ �����", "�����Ϣ", "[Instance:6; ID:31]", "SelectString", $var)
	; �����˵绰
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "phone", "")
	ControlSetText("�ύ �����", "�����Ϣ", 21, $var)
	
	Local $hWnd = ControlGetHandle("�ύ �����", "�����Ϣ", 12320)
	_GUICtrlTab_SetCurFocus($hWnd, 1)
	If WinWait("�ύ �����", "�������", 10) Then
		$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "discrpition", "")
		ControlSetText("�ύ �����", "�������", "[Instance:1; ID:10]", $var)
		$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "recurFault", "")
		ControlSetText("�ύ �����", "�������", "[Instance:2; ID:12]", $var)
		Sleep(200)
	Else
		MsgBox(8208, "ClearCase Helper", "�޷��򿪡���������������ֹ����޷���ɡ�")
	EndIf
	Sleep(200)

	_GUICtrlTab_SetCurFocus($hWnd, 0)
	; �������
	$var = IniRead(@ScriptDir & "\clearquest.ini", "main", "subject", "")
	ControlSetText("�ύ �����", "�����Ϣ", "[Instance:6; ID:23]", $var)
	ControlFocus("�ύ �����", "�����Ϣ", "[Instance:6; ID:23]")
	ControlSend("�ύ �����", "�����Ϣ", "[Instance:6; ID:23]", "{end}")
EndFunc

Func newUnitTestForm()
	If Not WinExists("Rational ClearQuest", "Standard") Then
		MsgBox(8208, "ClearCase Helper", "CQδ����...")
		Return
	EndIf
	WinActivate("Rational ClearQuest", "Standard")
	Sleep(200)
	If Not WinExists("�ύ ��Ԫ���Ե�", "�ύҳ��") Then
		If Not WinExists("Choose Record Type. . .", "Please choose a record type from the following list:") Then
			WinMenuSelectItem("Rational ClearQuest", "Standard", "&Actions", "&New...")
		EndIf
		Local $hWnd = ControlGetHandle("Choose Record Type. . .", "Please choose a record type from the following list:", 5136)
		If $hWnd == "" Then
			MsgBox(8208, "ClearCase Helper", "�޷����ñ�������ͣ��Ҳ������ھ��")
			Return
		EndIf
		Local $id = _GUICtrlListBox_FindString($hWnd, "��Ԫ���Ե�")
		If $id == -1 Then
			MsgBox(8208, "ClearCase Helper", "�޷����ñ�������ͣ��Ҳ�������Ԫ���Ե�����id")
			Return
		EndIf
		_GUICtrlListBox_SetCurSel($hWnd, $id)
		Sleep(10)
		ControlSend("Choose Record Type. . .", "Please choose a record type from the following list:", 1, "{enter}")
		If Not WinWait("�ύ ��Ԫ���Ե�", "�ύҳ��", 10) Then
			MsgBox(8208, "ClearCase Helper", "�޷����ñ�������ͣ��޷��򿪡��ύ ��Ԫ���Ե����Ի���")
			Return
		EndIf
	EndIf
	
	Local $var = ""
	; �������
	$var = IniRead(@ScriptDir & "\clearquest.ini", "unit", "subject", "")
	ControlSetText("�ύ ��Ԫ���Ե�", "�ύҳ��", "[CLASS:Edit; INSTANCE:3]", $var)
	; ��Ŀ
	$var = IniRead(@ScriptDir & "\clearquest.ini", "unit", "project", "")
	ControlCommand("�ύ ��Ԫ���Ե�", "�ύҳ��", "[CLASS:ComboBox; INSTANCE:1]", "SelectString", $var)
	; ������
	$var = IniRead(@ScriptDir & "\clearquest.ini", "unit", "whoDiscovered", "")
	ControlCommand("�ύ ��Ԫ���Ե�", "�ύҳ��", "[CLASS:ComboBox; INSTANCE:3]", "SelectString", $var)
	; ����Ŀ
	$var = IniRead(@ScriptDir & "\clearquest.ini", "unit", "subProject", "")
	ControlFocus("�ύ ��Ԫ���Ե�", "�ύҳ��", "[CLASS:ComboBox; INSTANCE:2]")
	ControlCommand("�ύ ��Ԫ���Ե�", "�ύҳ��", "[CLASS:ComboBox; INSTANCE:2]", "SelectString", $var)
	; �����˲���
	$var = IniRead(@ScriptDir & "\clearquest.ini", "unit", "dicovererDept", "")
	ControlCommand("�ύ ��Ԫ���Ե�", "�ύҳ��", "[CLASS:ComboBox; INSTANCE:4]", "SelectString", $var)
	; �������ַ���
	$var = IniRead(@ScriptDir & "\clearquest.ini", "unit", "recurFault", "")
	ControlSetText("�ύ ��Ԫ���Ե�", "�ύҳ��", "[CLASS:Edit; INSTANCE:8]", $var)
	; �����ϸ����
	$var = IniRead(@ScriptDir & "\clearquest.ini", "unit", "discrpition", "")
	ControlSetText("�ύ ��Ԫ���Ե�", "�ύҳ��", "[CLASS:Edit; INSTANCE:9]", $var)
	; ������
	$var = IniRead(@ScriptDir & "\clearquest.ini", "unit", "dealer", "")
	ControlCommand("�ύ ��Ԫ���Ե�", "�ύҳ��", "[CLASS:ComboBox; INSTANCE:5]", "SelectString", $var)
	; �����˲���
	$var = IniRead(@ScriptDir & "\clearquest.ini", "unit", "department", "")
	ControlCommand("�ύ ��Ԫ���Ե�", "�ύҳ��", "[CLASS:ComboBox; INSTANCE:6]", "SelectString", $var)
EndFunc

Func launchCQ()
	If WinExists("Rational ClearQuest", "&User Name") Then
		WinActivate("Rational ClearQuest", "&User Name")
		Return
	EndIf
	Local $path = IniRead(@ScriptDir & "\clearquest.ini", "main", "path", "error")
	If StringRight($path, 1) <> "\" Then
		$path = $path & "\"
	EndIf
	If Not FileExists($path & "clearquest.exe") Then
		MsgBox(8208, "ClearCase Helper", "��Ч��ClearQuest·�������������á�")
		openConfigFile("clearquest.ini", "main")
		Return
	EndIf
	If Not ProcessExists("clearquest.exe") Then
		Run($path & "clearquest.exe", $path)
;~ 		If WinWait("Rational ClearQuest Schema Repository", "&Next >>", 60) == 0 Then
;~ 			MsgBox(8208, "ClearCase Helper", "�޷�����CQ��")
;~ 			Return
;~ 		EndIf
		Local $i
		For $i = 1 To 100
			Sleep(200)
			If WinExists("Rational ClearQuest Schema Repository", "&Next >>") Then ExitLoop
			If WinExists("Rational ClearQuest Login", "&User Name") Then ExitLoop
		Next
		Sleep(200)
	EndIf
	If WinExists("Rational ClearQuest Schema Repository", "&Next >>") Then
		launchCQStep1()
		launchCQStep2()
	ElseIf WinExists("Rational ClearQuest Login", "&User Name") Then
		launchCQStep2()
	EndIf
EndFunc

Func launchCQStep1()
	Sleep(200)
	Local $var = IniRead(@ScriptDir & "\clearquest.ini", "main", "schema", "δ���á�")
	Local $id = ControlCommand ("Rational ClearQuest Schema Repository", "&Next >>", "[Instance:1; ID:2205]", "FindString", $var)
	If $id == "0" Then
		MsgBox(8208, "ClearCase Helper", "��Ч��Schema Repository: " & $var)
		Return
	EndIf
	Sleep(200)
	ControlListView ("Rational ClearQuest Schema Repository", "&Next >>", "[Instance:1; ID:2205]", "Select", $id)
	Sleep(200)
	ControlSend("Rational ClearQuest Schema Repository", "&Next >>", "[Instance:1; ID:1]", "{enter}")
	If WinWait("Rational ClearQuest Login", "&User Name", 60) == 0 Then
		MsgBox(8208, "ClearCase Helper", "�޷���¼CQ��2����")
		Return
	EndIf
EndFunc

Func launchCQStep2()
	Local $var = IniRead(@ScriptDir & "\clearquest.ini", "main", "username", "δ���á�")
	ControlSetText("Rational ClearQuest Login", "&User Name", "[Instance:1; ID:2208]", $var)
	$var = _decode(IniRead(@ScriptDir & "\clearquest.ini", "main", "pwd", "nopwd"))
	ControlSetText("Rational ClearQuest Login", "&User Name", "[Instance:2; ID:2209]", $var)
	ControlCommand("Rational ClearQuest Login", "&User Name", 2202, "SetCurrentSelection", 0)
	ControlSend("Rational ClearQuest Login", "&User Name", "[Instance:1; ID:1]", "{enter}")
EndFunc
