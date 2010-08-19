#AutoIt3Wrapper_au3check_parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#include <Constants.au3>
#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#Include <GuiListView.au3>
#Include <GuiTab.au3>
#Include <File.au3>
#Include <Date.au3>
#include "common.au3"

Global Const $LOG_PATH = @ScriptDir & "\cleartool.log"

Global $_SearchPrivate_gui_clts
Global $_SearchPrivate_txt_path
Global $_SearchPrivate_ls_private
Global $_SearchPrivate_ls_co
Global $_SearchPrivate_path

;~ _SearchPrivate("E:\Program Files\Rational\ClearCase")

Func _SearchPrivate($ccHome, $path = "")
	Local Const $GUI_WIDTH = 800
	Local Const $GUI_HEIGH = 600
	$_SearchPrivate_gui_clts = GUICreate("�������", $GUI_WIDTH, $GUI_HEIGH, Default, Default, _
		$WS_POPUP + $WS_SYSMENU + $WS_CAPTION + $WS_MINIMIZEBOX)
	GUICtrlCreateLabel("ɨ��Ŀ¼", 5, 5)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	If $path == "" Then
		$path = WinGetTitle("Rational ClearCase Explorer", "Menu bar")
		$path = StringMid($path, StringInStr($path, "(") + 1)
		$path = StringMid($path, 1, StringLen($path) - 1)
	EndIf
	If StringRight($path, 1) == "\" Then $path = StringLeft($path, StringLen($path) - 1)
	$_SearchPrivate_txt_path = GUICtrlCreateInput($path, 60, 1, 678);, Default, $ES_READONLY)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	$_SearchPrivate_path = $path
	Local $btn_reSearch = GUICtrlCreateButton("��������", 742, 1, Default, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "ʹ���ı����е�·����������")
	Local $hTab = GUICtrlGetHandle(GUICtrlCreateTab(0, 25, $GUI_WIDTH, $GUI_HEIGH - 25))
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 9)
	Local $exStyles = BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES)
	Local $hImage = _GUIImageList_Create(16, 16, 5, 3, 3)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 3)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 75)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 131)
	GUIRegisterMsg($WM_NOTIFY, "_SearchPrivate_WM_NOTIFY")
	
	#Region private
    Local $tab_private = GUICtrlCreateTabItem("˽���ļ� (*)")
	Local $btn_privateSelect = GUICtrlCreateButton("ѡ��", 4, 48, 40, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	Local $dummy_privateSelect = GUICtrlCreateDummy()
	Local $ctxt_privateSelect = GUICtrlCreateContextMenu($dummy_privateSelect)
	Local $mi_privateSelectAll = GUICtrlCreateMenuItem("ѡ��ȫ��(&A) Ctrl+A", $ctxt_privateSelect)
	Local $mi_privateSelectInvert = GUICtrlCreateMenuItem("����ѡ��(&I) Ctrl+I", $ctxt_privateSelect)
	GUICtrlCreateMenuItem("", $ctxt_privateSelect)
	Local $mi_privateCopy = GUICtrlCreateMenuItem("��������(&C) Ctrl+C", $ctxt_privateSelect)
	Local $btn_privateSave = GUICtrlCreateButton("����·��", 46, 48, 60, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "�����ļ�/�ļ���·�����ı��ļ�")
	Local $dummy_privateSave = GUICtrlCreateDummy()
	Local $ctxt_privateSave = GUICtrlCreateContextMenu($dummy_privateSave)
	Local $mi_privateSaveSelected = GUICtrlCreateMenuItem("������ѡ", $ctxt_privateSave)
	Local $mi_privateSaveAll = GUICtrlCreateMenuItem("����ȫ��", $ctxt_privateSave)
	Local $btn_privateAdd2SrcCtrl = GUICtrlCreateButton("�ܿ�", 108, 48, 40, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "��ѡ����ļ���ӵ���ǰ��֧��")
	Local $btn_privateDel = GUICtrlCreateButton("ɾ��", 150, 48, 40, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "ɾ��ѡ����ļ�/�ļ���")
	Local $ls_private = GUICtrlCreateListView("", 4, 70, $GUI_WIDTH - 8, $GUI_HEIGH - 75, _
		BitOR($LVS_REPORT, $LVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	$_SearchPrivate_ls_private = GUICtrlGetHandle($ls_private)
	_GUICtrlListView_SetExtendedListViewStyle($_SearchPrivate_ls_private, $exStyles)
	_GUICtrlListView_SetImageList($_SearchPrivate_ls_private, $hImage, 1)
	_GUICtrlListView_AddColumn($_SearchPrivate_ls_private, "˽���ļ�", $GUI_WIDTH - 50)
	Local $ctxt_privateLs = GUICtrlCreateContextMenu($ls_private)
	Local $cm_privateSelectAll = GUICtrlCreateMenuItem("ѡ��ȫ��(&A) Ctrl+A", $ctxt_privateLs)
	Local $cm_privateSelectInvert = GUICtrlCreateMenuItem("����ѡ��(&I) Ctrl+I", $ctxt_privateLs)
	GUICtrlCreateMenuItem("", $ctxt_privateLs)
	Local $cm_privateCopy = GUICtrlCreateMenuItem("��������(&C) Ctrl+C", $ctxt_privateLs)
	Local $lbl_privatePlsWait = GUICtrlCreateLabel("�������������Ժ�...", 10, 91)
	#EndRegion
	;
	
	#Region checkout
    Local $tab_co = GUICtrlCreateTabItem("��������ļ� (*)")
	Local $btn_coSelect = GUICtrlCreateButton("ѡ��", 4, 48, 40, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	Local $dummy_coSelect = GUICtrlCreateDummy()
	Local $ctxt_coSelect = GUICtrlCreateContextMenu($dummy_coSelect)
	Local $mi_coSelectAll = GUICtrlCreateMenuItem("ѡ��ȫ��(&A) Ctrl+A", $ctxt_coSelect)
	Local $mi_coSelectInvert = GUICtrlCreateMenuItem("����ѡ��(&I) Ctrl+I", $ctxt_coSelect)
	GUICtrlCreateMenuItem("", $ctxt_coSelect)
	Local $mi_coCopy = GUICtrlCreateMenuItem("��������(&C) Ctrl+C", $ctxt_coSelect)
	Local $btn_coSave = GUICtrlCreateButton("����·��", 46, 48, 60, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "�����ļ�/�ļ���·�����ı��ļ�")
	Local $btn_coCheckin = GUICtrlCreateButton("����", 108, 48, 40, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "����ѡ����ļ�")
	Local $btn_coUncheckin = GUICtrlCreateButton("ȡ�����", 150, 48, 60, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "Undo Check Out ѡ����ļ�����.keep��Ϊ��׺���浱ǰ�޸�")
	Local $btn_coDiff = GUICtrlCreateButton("�Ա�", 212, 48, 40, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "��ǰһ���汾�Ա�")
	Local $btn_coVTree = GUICtrlCreateButton("�汾��", 254, 48, 40, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "��ǰ�ļ��İ汾��")
	Local $btn_coHistory = GUICtrlCreateButton("��ʷ", 296, 48, 40, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "��ǰ�ļ��İ汾��ʷ")
	Local $btn_coProperty = GUICtrlCreateButton("����", 338, 48, 40, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "��ǰ�ļ�������")
	Local $dummy_coSave = GUICtrlCreateDummy()
	Local $ctxt_coSave = GUICtrlCreateContextMenu($dummy_coSave)
	Local $mi_coSaveSelected = GUICtrlCreateMenuItem("������ѡ", $ctxt_coSave)
	Local $mi_coSaveAll = GUICtrlCreateMenuItem("����ȫ��", $ctxt_coSave)
	Local $ls_co = GUICtrlCreateListView("", 4, 70, $GUI_WIDTH - 8, $GUI_HEIGH - 75, _
		BitOR($LVS_REPORT, $LVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	$_SearchPrivate_ls_co = GUICtrlGetHandle($ls_co)
	_GUICtrlListView_SetExtendedListViewStyle($_SearchPrivate_ls_co, $exStyles)
	_GUICtrlListView_SetImageList($_SearchPrivate_ls_co, $hImage, 1)
	_GUICtrlListView_AddColumn($_SearchPrivate_ls_co, "��������ļ�", $GUI_WIDTH - 50)
	Local $ctxt_coLs = GUICtrlCreateContextMenu($ls_co)
	Local $cm_coSelectAll = GUICtrlCreateMenuItem("ѡ��ȫ��(&A) Ctrl+A", $ctxt_coLs)
	Local $cm_coSelectInvert = GUICtrlCreateMenuItem("����ѡ��(&I) Ctrl+I", $ctxt_coLs)
	GUICtrlCreateMenuItem("", $ctxt_coLs)
	Local $cm_coSelectCopy = GUICtrlCreateMenuItem("��������(&C) Ctrl+C", $ctxt_coLs)
	Local $lbl_coPlsWait = GUICtrlCreateLabel("�������������Ժ�...", 10, 91)
	#EndRegion
	;
	GUICtrlCreateTabItem("")
	
	Local $dummy_Copy = GUICtrlCreateDummy()
	Local $dummy_selectAll = GUICtrlCreateDummy()
	Local $dummy_selectInvert = GUICtrlCreateDummy()
	Local $hk[3][2] = _
		[["^c", $dummy_Copy], _
		["^i", $dummy_selectInvert], _
		["^a", $dummy_selectAll]]
	GUISetAccelerators($hk)
	GUISetState(@SW_SHOW)
	Local $fileSet = _SearchPrivate_search($ccHome, $path)
;~ 	Local $fileSet = _getTestFileSet()
	GUICtrlSetData($tab_co, "��������ļ� (" & $fileSet[0][0] & ")")
	GUICtrlSetData($tab_private, "˽���ļ� (" & $fileSet[0][1] & ")")
	GUICtrlDelete($lbl_privatePlsWait)
	GUICtrlDelete($lbl_coPlsWait)
	_SearchPrivate_createListViewItems($fileSet)

	Local $nMsg
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $btn_privateSelect
				ShowMenu($_SearchPrivate_gui_clts, $btn_privateSelect, $ctxt_privateSelect)
			Case $mi_privateSelectAll, $cm_privateSelectAll
				_SearchPrivate_selectAll($_SearchPrivate_ls_private)
			Case $mi_privateSelectInvert, $cm_privateSelectInvert
				_SearchPrivate_selectInvert($_SearchPrivate_ls_private)
			Case $mi_privateCopy, $cm_privateCopy
				_SearchPrivate_copySelected($_SearchPrivate_ls_private)
			Case $btn_privateSave
				ShowMenu($_SearchPrivate_gui_clts, $btn_privateSave, $ctxt_privateSave)
			Case $mi_privateSaveSelected
				_SearchPrivate_save($_SearchPrivate_ls_private, "selected")
			Case $mi_privateSaveAll
				_SearchPrivate_save($_SearchPrivate_ls_private, "all")
			Case $btn_privateAdd2SrcCtrl
				_SearchPrivate_add2SrcCtrl()
			Case $btn_privateDel
				_SearchPrivate_deleteSelected()
				
			Case $btn_coSelect
				ShowMenu($_SearchPrivate_gui_clts, $btn_coSelect, $ctxt_coSelect)
			Case $mi_coSelectAll, $cm_coSelectAll
				_SearchPrivate_selectAll($_SearchPrivate_ls_co)
			Case $mi_coSelectInvert, $cm_coSelectInvert
				_SearchPrivate_selectInvert($_SearchPrivate_ls_co)
			Case $mi_coCopy, $cm_coSelectCopy
				_SearchPrivate_copySelected($_SearchPrivate_ls_co)
			Case $btn_coSave
				ShowMenu($_SearchPrivate_gui_clts, $btn_coSave, $ctxt_coSave)
			Case $mi_coSaveSelected
				_SearchPrivate_save($_SearchPrivate_ls_co, "selected")
			Case $mi_coSaveAll
				_SearchPrivate_save($_SearchPrivate_ls_co, "all")
			Case $btn_coCheckin
				_SearchPrivate_checkIn($ccHome)
			Case $btn_coUncheckin
				_SearchPrivate_unCheckout($ccHome)
			Case $btn_coDiff
				_SearchPrivate_diff($ccHome)
			Case $btn_coVTree
				_SearchPrivate_vtree($ccHome)
			Case $btn_coHistory
				_SearchPrivate_history($ccHome)
			Case $btn_coProperty
				_SearchPrivate_property($ccHome)
				
			Case $btn_reSearch
				$_SearchPrivate_path = GUICtrlRead($_SearchPrivate_txt_path)
				If StringRight($_SearchPrivate_path, 1) == "\" Then
					$_SearchPrivate_path = StringLeft($_SearchPrivate_path, StringLen($_SearchPrivate_path) - 1)
				EndIf
				$fileSet = _SearchPrivate_search($ccHome, $_SearchPrivate_path)
				GUICtrlSetData($tab_co, "��������ļ� (" & $fileSet[0][0] & ")")
				GUICtrlSetData($tab_private, "˽���ļ� (" & $fileSet[0][1] & ")")
				_SearchPrivate_createListViewItems($fileSet)
			Case $dummy_selectAll
				_SearchPrivate_selectAll("", $hTab)
			Case $dummy_selectInvert
				_SearchPrivate_selectInvert("", $hTab)
			Case $dummy_Copy
				_SearchPrivate_copySelected("", $hTab)
			Case $GUI_EVENT_CLOSE
				GUIDelete($_SearchPrivate_gui_clts)
				Return

		EndSwitch
	WEnd

EndFunc

Func _SearchPrivate_selectAll($ls = "", $hTab = "")
	If $ls == "" Then
		If _GUICtrlTab_GetCurFocus($hTab) == 0 Then
			$ls =$_SearchPrivate_ls_private
		Else
			$ls =$_SearchPrivate_ls_co
		EndIf
	EndIf
	Local $i
	For $i = 0 To _GUICtrlListView_GetItemCount($ls) - 1
		_GUICtrlListView_SetItemSelected($ls, $i)
	Next
EndFunc

Func _SearchPrivate_selectInvert($ls = "", $hTab = "")
	If $ls == "" Then
		If _GUICtrlTab_GetCurFocus($hTab) == 0 Then
			$ls =$_SearchPrivate_ls_private
		Else
			$ls =$_SearchPrivate_ls_co
		EndIf
	EndIf
	Local $i
	For $i = 0 To _GUICtrlListView_GetItemCount($ls) - 1
		_GUICtrlListView_SetItemSelected($ls, $i, Not _GUICtrlListView_GetItemSelected($ls, $i))
	Next
EndFunc

Func _SearchPrivate_copySelected($ls = "", $hTab = "")
	If $ls == "" Then
		If _GUICtrlTab_GetCurFocus($hTab) == 0 Then
			$ls =$_SearchPrivate_ls_private
		Else
			$ls =$_SearchPrivate_ls_co
		EndIf
	EndIf
	Local $i, $it, $str = ""
	For $i = 0 To _GUICtrlListView_GetItemCount($ls) - 1
		If Not _GUICtrlListView_GetItemSelected($ls, $i) Then ContinueLoop
		$it = _GUICtrlListView_GetItemText($ls, $i)
		$it = $_SearchPrivate_path & "\" & StringRight($it, StringLen($it) - 2)
		$str &= $it & @CRLF
	Next
	ClipPut($str)
EndFunc

Func _SearchPrivate_add2SrcCtrl()
	Local $i, $it
	For $i = 0 To _GUICtrlListView_GetItemCount($_SearchPrivate_ls_private) - 1
		If Not _GUICtrlListView_GetItemSelected($_SearchPrivate_ls_private, $i) Then ContinueLoop
		$it = _GUICtrlListView_GetItemText($_SearchPrivate_ls_private, $i)
		$it = $_SearchPrivate_path & "\" & StringRight($it, StringLen($it) - 2)
		MsgBox(8256,"ClearCase Helper", _
			"��Ǹ����������δ���ơ�" & @CRLF & _
			"�ش𱾶Ի����Ϊ��򿪸��ļ�����Ŀ¼��" & @CRLF & _
			"�������������ɱ�������",0, $_SearchPrivate_gui_clts)
		ShellExecute(_SearchPrivate_getFileInfo($it))
		Return
	Next
EndFunc

Func _SearchPrivate_deleteSelected()
	Local $i, $it = ""
	Local $n = _GUICtrlListView_GetItemCount($_SearchPrivate_ls_private) - 1
	GUISetState(@SW_DISABLE, $_SearchPrivate_gui_clts)
	ProgressOn("ɾ���ļ�/�ļ���", "���ڽ���ѡ�ļ��������վ...", "")
	For $i = 0 To $n
		If Not _GUICtrlListView_GetItemSelected($_SearchPrivate_ls_private, $i) Then ContinueLoop
		$it = _GUICtrlListView_GetItemText($_SearchPrivate_ls_private, $i)
		$it = $_SearchPrivate_path & "\" & StringRight($it, StringLen($it) - 2)
		_GUICtrlListView_SetItemImage($_SearchPrivate_ls_private, $i, 2)
		FileRecycle($it)
		ProgressSet(Int($i/($n + 1) * 100), _SearchPrivate_getFileInfo($it, "name"))
	Next
	ProgressSet(100, "���")
	Sleep(500)
	ProgressOff ()
	GUISetState(@SW_ENABLE, $_SearchPrivate_gui_clts)
EndFunc

Func _SearchPrivate_save($ls, $what)
	Local $i, $str = "", $it
	For $i = 0 To _GUICtrlListView_GetItemCount($ls) - 1
		If ($what == "selected" And _GUICtrlListView_GetItemSelected($ls, $i)) Or _
			$what == "all" Then
			$it = _GUICtrlListView_GetItemText($ls, $i)
			$it = $_SearchPrivate_path & "\" & StringRight($it, StringLen($it) - 2)
			$str &= $it & @CRLF
		EndIf
	Next
	Local $path = FileSaveDialog("����·�����ı��ļ�", @MyDocumentsDir, "All (*.*)", 18, Default, $_SearchPrivate_gui_clts)
	If FileExists($path) Then
		If Not FileDelete($path) Then
			;MsgBox features: Title=Yes, Text=Yes, Buttons=OK, Icon=Info, Modality=Task Modal
			MsgBox(8256,"����·�����ı��ļ�","����ʧ�ܣ��޷�����Ŀ���ļ� " & $path)
			Return
		EndIf
	EndIf
	FileWrite($path, $str)
EndFunc

Func _SearchPrivate_checkIn($ccHome)
	Local $i, $it, $aArray[1] = [0]
	For $i = 0 To _GUICtrlListView_GetItemCount($_SearchPrivate_ls_co) - 1
		If Not _GUICtrlListView_GetItemSelected($_SearchPrivate_ls_co, $i) Then ContinueLoop
		$it = _GUICtrlListView_GetItemText($_SearchPrivate_ls_co, $i)
		$it = $_SearchPrivate_path & "\" & StringRight($it, StringLen($it) - 2)
		$aArray[0] += 1
		ReDim $aArray[$aArray[0] + 1]
		$aArray[$aArray[0]] = $it
	Next
	If $aArray[0] == 0 Then Return
	Local $defaultComment = "Checked in by " & @UserName & " at " & _NowCalc() & " with ClearCase Helper."
	Local $pos = WinGetPos($_SearchPrivate_gui_clts)
	Local $comment = InputBox("����","����һ��ע����Ϣ�����255���ַ���" & @CRLF & @CRLF & _
		"ע�����ι�ѡ�������ļ���ʹ�ô�ע�͡�", _
		$defaultComment,"","250","150",($pos[2] - 250)/2 + $pos[0], ($pos[3] - 150)/3 + $pos[1], _
		Default, $_SearchPrivate_gui_clts)
	Select
		Case @Error = 0 ;OK - The string returned is valid
			If $comment == "" Then $comment = $defaultComment
		Case @Error = 1 ;The Cancel button was pushed
			Return
		Case @Error = 3 ;The InputBox failed to open
			Return
	EndSelect
	Local $cmd = '"' & $ccHome & '\bin\cleartool.exe" checkin -comment "' & $comment & '" '
	For $i = 1 To $aArray[0]
		$cmd &= '"' & $aArray[$i] & '" '
	Next
	Local $line = "", $result = ""
	WinSetState($_SearchPrivate_gui_clts, "", @SW_DISABLE)
	$pos = WinGetPos($_SearchPrivate_gui_clts)
	Local $gui_res = GUICreate("���", 600, 480, ($pos[2] - 600)/2, ($pos[3] - 480)/3, _
		$WS_CAPTION + $WS_SYSMENU, $WS_EX_MDICHILD, $_SearchPrivate_gui_clts)
	GUICtrlCreateLabel("�����Ǽ���ɹ��Ľ�������顣", 5, 2)
	Local $txt_resSuccess = GUICtrlCreateEdit("����ִ�м������...", 0, 20, 599, 220, _
		BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_READONLY,$WS_HSCROLL,$WS_VSCROLL))
	GUICtrlCreateLabel("�����Ǽ���ʧ�ܵĽ�������顣", 5, 245)
	Local $txt_resFailed = GUICtrlCreateEdit("����ִ�м������...", 0, 260, 599, 220, _
		BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_READONLY,$WS_HSCROLL,$WS_VSCROLL))
	GUISetState(@SW_SHOW, $gui_res)
	Local $ctci = Run($cmd, $ccHome & "\bin", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	_FileWriteLog($LOG_PATH, $cmd, 0)
	While 1
		$line = StdoutRead($ctci)
		If @error Then ExitLoop
		If $line == "" Then ContinueLoop
		$result &= StringReplace($line, "cleartool:", "")
		GUICtrlSetData($txt_resSuccess, $result)
		Sleep(300)
	Wend
	If $result == "" Then
		GUICtrlSetData($txt_resSuccess, "�������")
	Else
		_FileWriteLog($LOG_PATH, StringStripWS($result, 3), 0)
	EndIf
	$result = ""
	While 1
		$line = StderrRead($ctci)
		If @error Then ExitLoop
		If $line == "" Then ContinueLoop
		$result &= StringReplace($line, "cleartool:", "")
		GUICtrlSetData($txt_resFailed, $result)
		Sleep(300)
	Wend
	If $result == "" Then
		GUICtrlSetData($txt_resFailed, "�������")
	Else
		_FileWriteLog($LOG_PATH, StringStripWS($result, 3), 0)
	EndIf

	While 1
		If GUIGetMsg() == $GUI_EVENT_CLOSE Then
			WinSetState($_SearchPrivate_gui_clts, "", @SW_ENABLE)
			GUIDelete($gui_res)
			Return
		EndIf
	WEnd
EndFunc

Func _SearchPrivate_unCheckout($ccHome)
	Local $i, $it, $aArray[1] = [0]
	For $i = 0 To _GUICtrlListView_GetItemCount($_SearchPrivate_ls_co) - 1
		If Not _GUICtrlListView_GetItemSelected($_SearchPrivate_ls_co, $i) Then ContinueLoop
		$it = _GUICtrlListView_GetItemText($_SearchPrivate_ls_co, $i)
		$it = $_SearchPrivate_path & "\" & StringRight($it, StringLen($it) - 2)
		$aArray[0] += 1
		ReDim $aArray[$aArray[0] + 1]
		$aArray[$aArray[0]] = $it
	Next
	If $aArray[0] == 0 Then Return
	Local $cmd = '"' & $ccHome & '\bin\cleartool.exe" uncheckout -keep '
	For $i = 1 To $aArray[0]
		$cmd &= '"' & $aArray[$i] & '" '
	Next
	Local $line = "", $result = ""
	WinSetState($_SearchPrivate_gui_clts, "", @SW_DISABLE)
	Local $pos = WinGetPos($_SearchPrivate_gui_clts)
	Local $gui_res = GUICreate("���", 600, 480, ($pos[2] - 600)/2, ($pos[3] - 480)/3, _
		$WS_CAPTION + $WS_SYSMENU, $WS_EX_MDICHILD, $_SearchPrivate_gui_clts)
	GUICtrlCreateLabel("������uncheck out�ɹ��Ľ�������顣", 5, 2)
	Local $txt_resSuccess = GUICtrlCreateEdit("����ִ��uncheck out����...", 0, 20, 599, 220, _
		BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_READONLY,$WS_HSCROLL,$WS_VSCROLL))
	GUICtrlCreateLabel("������uncheck outʧ�ܵĽ�������顣", 5, 245)
	Local $txt_resFailed = GUICtrlCreateEdit("����ִ��uncheck out����...", 0, 260, 599, 220, _
		BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_READONLY,$WS_HSCROLL,$WS_VSCROLL))
	GUISetState(@SW_SHOW)
	Local $ctci = Run($cmd, $ccHome & "\bin", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	_FileWriteLog($LOG_PATH, $cmd, 0)
	While 1
		$line = StdoutRead($ctci)
		If @error Then ExitLoop
		If $line == "" Then ContinueLoop
		$result &= StringReplace($line, "cleartool:", "")
		GUICtrlSetData($txt_resSuccess, $result)
		Sleep(300)
	Wend
	If $result == "" Then 
		GUICtrlSetData($txt_resSuccess, "�������")
	Else
		_FileWriteLog($LOG_PATH, StringStripWS($result, 3), 0)
	EndIf
	$result = ""
	While 1
		$line = StderrRead($ctci)
		If @error Then ExitLoop
		If $line == "" Then ContinueLoop
		$result &= StringReplace($line, "cleartool:", "")
		GUICtrlSetData($txt_resFailed, $result)
		Sleep(300)
	Wend
	If $result == "" Then
		GUICtrlSetData($txt_resFailed, "�������")
	Else
		_FileWriteLog($LOG_PATH, StringStripWS($result, 3), 0)
	EndIf

	While 1
		If GUIGetMsg() == $GUI_EVENT_CLOSE Then
			WinSetState($_SearchPrivate_gui_clts, "", @SW_ENABLE)
			GUIDelete($gui_res)
			Return
		EndIf
	WEnd
EndFunc

Func _SearchPrivate_diff($ccHome)
	Local $i, $it, $cmd = '"' & $ccHome & '\bin\cleartool.exe" diff -graphical  -predecessor "'
	For $i = 0 To _GUICtrlListView_GetItemCount($_SearchPrivate_ls_co) - 1
		If Not _GUICtrlListView_GetItemSelected($_SearchPrivate_ls_co, $i) Then ContinueLoop
		$it = _GUICtrlListView_GetItemText($_SearchPrivate_ls_co, $i)
		$it = $_SearchPrivate_path & "\" & StringRight($it, StringLen($it) - 2)
		$cmd &= $it & '"'
		Run($cmd, $ccHome & "\bin", @SW_HIDE)
		_FileWriteLog($LOG_PATH, $cmd, 0)
		Return
	Next
EndFunc

Func _SearchPrivate_vtree($ccHome)
	Local $i, $it, $cmd = '"' & $ccHome & '\bin\cleartool.exe" lsvtree -graphical -all "'
	For $i = 0 To _GUICtrlListView_GetItemCount($_SearchPrivate_ls_co) - 1
		If Not _GUICtrlListView_GetItemSelected($_SearchPrivate_ls_co, $i) Then ContinueLoop
		$it = _GUICtrlListView_GetItemText($_SearchPrivate_ls_co, $i)
		$it = $_SearchPrivate_path & "\" & StringRight($it, StringLen($it) - 2)
		$cmd &= $it & '"'
		Run($cmd, $ccHome & "\bin", @SW_HIDE)
		_FileWriteLog($LOG_PATH, $cmd, 0)
		Return
	Next
EndFunc

Func _SearchPrivate_history($ccHome)
	Local $i, $it, $cmd = '"' & $ccHome & '\bin\cleartool.exe" lshistory -graphical "'
	For $i = 0 To _GUICtrlListView_GetItemCount($_SearchPrivate_ls_co) - 1
		If Not _GUICtrlListView_GetItemSelected($_SearchPrivate_ls_co, $i) Then ContinueLoop
		$it = _GUICtrlListView_GetItemText($_SearchPrivate_ls_co, $i)
		$it = $_SearchPrivate_path & "\" & StringRight($it, StringLen($it) - 2)
		$cmd &= $it & '"'
		Run($cmd, $ccHome & "\bin", @SW_HIDE)
		_FileWriteLog($LOG_PATH, $cmd, 0)
		Return
	Next
EndFunc

Func _SearchPrivate_property($ccHome)
	Local $i, $it, $cmd = '"' & $ccHome & '\bin\cleartool.exe" des -graphical "'
	For $i = 0 To _GUICtrlListView_GetItemCount($_SearchPrivate_ls_co) - 1
		If Not _GUICtrlListView_GetItemSelected($_SearchPrivate_ls_co, $i) Then ContinueLoop
		$it = _GUICtrlListView_GetItemText($_SearchPrivate_ls_co, $i)
		$it = $_SearchPrivate_path & "\" & StringRight($it, StringLen($it) - 2)
		If WinExists($it, $it) Then
			WinActivate($it, $it)
			Return
		EndIf
		$cmd &= $it & '"'
		Run($cmd, $ccHome & "\bin", @SW_HIDE)
		_FileWriteLog($LOG_PATH, $cmd, 0)
		Return
	Next
EndFunc

Func _SearchPrivate_createListViewItems($fileSet)
	_GUICtrlListView_DeleteAllItems($_SearchPrivate_ls_private)
	_GUICtrlListView_DeleteAllItems($_SearchPrivate_ls_co)
	Local $i, $attrib
	For $i = 1 To $fileSet[0][0]
		$attrib = FileGetAttrib($_SearchPrivate_path & "\" & StringRight($fileSet[$i][0], StringLen($fileSet[$i][0]) - 2))
		If StringInStr($attrib, "D") Then
			_GUICtrlListView_AddItem($_SearchPrivate_ls_co, $fileSet[$i][0], 0)
		Else
			_GUICtrlListView_AddItem($_SearchPrivate_ls_co, $fileSet[$i][0], 1)
		EndIf
	Next
	For $i = 1 To $fileSet[0][1]
		$attrib = FileGetAttrib($_SearchPrivate_path & "\" & StringRight($fileSet[$i][1], StringLen($fileSet[$i][1]) - 2))
		If StringInStr($attrib, "D") Then
			_GUICtrlListView_AddItem($_SearchPrivate_ls_private, $fileSet[$i][1], 0)
		Else
			_GUICtrlListView_AddItem($_SearchPrivate_ls_private, $fileSet[$i][1], 1)
		EndIf
	Next
	
EndFunc

;
; $fileSet[n][0]: checkout
; $fileSet[n][1]: private
;
Func _SearchPrivate_search($ccHome, $path)
	Local $aArray[1][2]
	If Not FileExists($ccHome & "\bin\cleartool.exe") Then
		MsgBox(8240, "ClearCase Helper", _
			$ccHome & "\bin\cleartool.exe �����ڣ���ȷ��ClearCase��װ��ȷ��", _
			Default, $_SearchPrivate_gui_clts)
		$aArray[0][0] = 0
		$aArray[0][1] = 0
		Return $aArray
	EndIf
	If Not FileExists($path) Then
		MsgBox(8240, "ClearCase Helper", "�޷���ȡ��ǰѡ���·����δ֪����", _
			Default, $_SearchPrivate_gui_clts)
		$aArray[0][0] = 0
		$aArray[0][1] = 0
		Return $aArray
	EndIf
	
	Local $cmd = '"' & $ccHome & '\bin\cleartool.exe" ls -r -view_only ' & $path
	Local $ctls = Run($cmd, $ccHome & "\bin", @SW_HIDE, $STDOUT_CHILD)
	_FileWriteLog($LOG_PATH, $cmd, 0)
	Local $line, $privateFiles = "", $n = 0, $sleep = 300
	ProgressOn("ClearCase Helper", "��������...", "0 %", Default, Default, 16)
	While 1
		$line = StdoutRead($ctls)
		If @error Then ExitLoop
		$privateFiles &= $line
		Sleep($sleep)
		If $n == 49 Then
			$sleep = 600
		EndIf
		ProgressSet($n, $n & " %")
		If $n == 99 Then
			;MsgBox features: Title=Yes, Text=Yes, Buttons=Yes and No, Icon=Question, Modality=Task Modal
			Local $iMsgBoxAnswer = MsgBox(8228,"ClearCase Helper", _
				"������Ҫ��ʱ���Ԥ�ڵ�Ҫ�࣬Ҳ�����ǳ���ʲô���⡣" & @CRLF & "Ҫ�����ȴ���", 15)
			Switch $iMsgBoxAnswer
				Case 6, -1 ;Yes;Timeout
					ProgressSet($n, $n & " %", "�������ѵ�ʱ���Ԥ�Ƶĳ�...")
				Case $iMsgBoxAnswer = 7 ;No
					ProcessClose($ctls)
					ProgressOff()
					$aArray[0][0] = 0
					$aArray[0][1] = 0
					Return $aArray
			EndSwitch
		EndIf
		$n += 1
		$n = Mod($n, 100)
	Wend
	ProgressSet(100, "100 %")
	Sleep(200)
	ProgressOff()
	$aArray = StringSplit($privateFiles, @CRLF, 1) ; Try Windows @CRLF first
	If @error Then $aArray = StringSplit($privateFiles, @LF) ; Unix @LF is next most common
	If @error Then $aArray = StringSplit($privateFiles, @CR) ; Finally try Mac @CR
	If $aArray[0] > 1 Then
		$aArray[0] = $aArray[0] - 1
	Else
		Local $fileSet[1][2]
		$fileSet[0][0] = 0
		$fileSet[0][1] = 0
		Return $fileSet
	EndIf
	Local $i, $fileSet[$aArray[0] + 1][2]
	$n = 0
	$fileSet[0][0] = 0
	$fileSet[0][1] = 0
	For $i = 1 To $aArray[0]
		If StringInStr($aArray[$i], "Rule: CHECKEDOUT") Then
			$n = StringInStr($aArray[$i], "@@") - 1
			If $n == 0 Then $n = StringInStr($aArray[$i], "Rule: CHECKEDOUT")
			$fileSet[0][0] += 1
			$fileSet[$fileSet[0][0]][0] = StringReplace(StringLeft($aArray[$i], $n), $path, ".")
		Else
			$fileSet[0][1] += 1
			$fileSet[$fileSet[0][1]][1] = StringReplace($aArray[$i], $path, ".")
		EndIf
	Next
	Return $fileSet
EndFunc

Func _SearchPrivate_WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    #forceref $hWnd, $iMsg, $iwParam
    Local $hWndFrom, $iCode, $tNMHDR, $it, $hWndList, $i

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iCode = DllStructGetData($tNMHDR, "Code")
	If $hWndFrom == $_SearchPrivate_ls_private Then
		$hWndList = $_SearchPrivate_ls_private
	ElseIf $hWndFrom == $_SearchPrivate_ls_co Then
		$hWndList = $_SearchPrivate_ls_co
	Else
		Return
	EndIf
	Switch $iCode
		Case $LVN_COLUMNCLICK
			
		Case $NM_CLICK
			
		Case $NM_DBLCLK
			For $i = 0 To _GUICtrlListView_GetItemCount($hWndList) - 1
				If Not _GUICtrlListView_GetItemFocused($hWndList, $i) Then ContinueLoop
				$it = _GUICtrlListView_GetItemText($hWndList, $i)
				$it = $_SearchPrivate_path & "\" & StringRight($it, StringLen($it) - 2)
				If Not FileExists($it) Then Return
				ShellExecute($it, "", _SearchPrivate_getFileInfo($it, "path"), "open")
			Next
	EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

;;;;;;;;;;;;;;;;;;;;;;
; $what = "path"
; $what = "name"
; $what = "ext"
;;;;;;;;;;;;;;;;;;;;;;
Func _SearchPrivate_getFileInfo($fullPath, $what = "path")
	Local $szDrive, $szDir, $szFName, $szExt
	_PathSplit($fullPath, $szDrive, $szDir, $szFName, $szExt)
	Switch $what
		Case "path"
			Return $szDrive & $szDir
		Case "name"
			Return $szFName & $szExt
		Case "ext"
			Return $szExt
	EndSwitch
EndFunc















;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   to be deleted
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func _getTestFileSet()
	Local $fileSet[5][2]
	$fileSet[0][0] = 4
	$fileSet[0][1] = 4
	
	$fileSet[1][0] = ".\test.html"
	$fileSet[2][0] = ".\���� images"
	$fileSet[3][0] = ".\���� jre"
	$fileSet[4][0] = ".\1111111111.html"
	
	$fileSet[1][1] = ".\test.html"
	$fileSet[2][1] = ".\1.txt"
	$fileSet[3][1] = ".\���� jre"
	$fileSet[4][1] = ".\1111111111.html"

	
	Return $fileSet
EndFunc
