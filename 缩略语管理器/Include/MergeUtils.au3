#include-once

Global Const $MERGE_RESULT_USEORG = 1
Global Const $MERGE_RESULT_USENEW = 2
Global Const $MERGE_FROM_LOCAL = 0
Global Const $MERGE_FROM_REMOTE = 1

Func merge($mergeFrom = $MERGE_FROM_LOCAL)
	Local $file
	If $mergeFrom == $MERGE_FROM_LOCAL Then
		$file = FileOpenDialog("ѡ����Ƚϵ��������ļ�", @ScriptDir & "\", "�������ļ� (data.ini)", 1, Default, $gui)
		Local $ret = @error
		If $ret Then Return
		If StringLower($file) == StringLower(@ScriptDir & "\data.ini") Then
			MsgBox(8256,"�ϲ�������", "�ļ���" & $file & "����ʹ�ã���ѡ��һ����֮�Աȵ��ļ���", Default, $gui)
			Return
		EndIf
	ElseIf $mergeFrom == $MERGE_FROM_REMOTE Then
		$file = @ScriptDir & "\tmp\data.ini"
	Else
		MsgBox(8256,"�ϲ�������", "δѡ����Աȵ��ļ���", Default, $gui)
		Return
	EndIf
	$file = StringLeft($file, StringLen($file) - 9)
	If $mergeFrom == $MERGE_FROM_LOCAL Then
		Local $isMerge = MsgBox(8225,"�ϲ�������", _
								"�Ƿ���кϲ���������ϲ���·����" & @CRLF & $file, Default, $gui)
		If $isMerge == 2 Then Return
	EndIf
;~ 	FileCopy(@ScriptDir & "\data.ini", @ScriptDir & "\data.ini.bak", 1)
	
	Local $pos = WinGetPos($gui)
	If Not IsArray($pos) Then Exit
	Local $gui_process = GUICreate("����", 400, 35, _
		($pos[2] - 400)/2, ($pos[3] - 35)/3, Default, $WS_EX_MDICHILD, $gui)
	Local $progressBar = GUICtrlCreateProgress(10, 10, 382, 16, $PBS_SMOOTH )
	GUICtrlSetData(-1, 0)
	GUISetState(@SW_SHOW, $gui_process)
	GUISetState(@SW_DISABLE, $gui)
	TrayItemSetState ($tm_about, $TRAY_DISABLE)
	TrayItemSetState ($tm_quit, $TRAY_DISABLE)
	
	Local $i, $j, $isConflicted, $modCount = 0, $addCount = 0
	Local $explain1, $explain2, $ret, $sec = IniReadSectionNames($file & "\data.ini")
	For $i = 1 To $sec[0]
		GUICtrlSetData($progressBar, 100*($i/$sec[0]))
		$isConflicted = False
		For $j = 1 To $data[0]
			If $sec[$i] <> $data[$j] Then ContinueLoop
			$explain1 = IniRead(@ScriptDir & "\data.ini", $sec[$i], "brief", "unkown")
			$explain2 = IniRead($file & "\data.ini", $sec[$i], "brief", "unkown")
			$isConflicted = True
			If $explain1 == $explain2 And _compareHtmlFiles($file, $sec[$i]) Then
				ContinueLoop
			EndIf
			$ret = _mergeDialog($sec[$i], $explain1, $explain2, _
					@ScriptDir & "\data\" & $sec[$i] & "\" & $sec[$i] & ".html", _
					$file & "\data\" & $sec[$i] & "\" & $sec[$i] & ".html")
			If $ret == $MERGE_RESULT_USEORG Then ContinueLoop
			IniDelete(@ScriptDir & "\data.ini", $sec[$i])
			IniWrite(@ScriptDir & "\data.ini", $sec[$i], "brief", IniRead($file & "\data.ini", $sec[$i], "brief", "unkown"))
;~ 			IniWrite(@ScriptDir & "\data.ini", $sec[$i], "desc", $sec[$i] & ".html")
			DirRemove(@ScriptDir & "\data\" & $sec[$i], 1)
			DirCopy($file & "\data\" & $sec[$i], @ScriptDir & "\data\" & $sec[$i])
			$modCount = $modCount + 1
		Next
		If $isConflicted Then ContinueLoop ; �г�ͻ������Ѿ��ڵڶ���forѭ���д����ˣ����ﲻ��Ҫ�ٴ���
		IniWrite(@ScriptDir & "\data.ini", $sec[$i], "brief", IniRead($file & "\data.ini", $sec[$i], "brief", "unkown"))
;~ 		IniWrite(@ScriptDir & "\data.ini", $sec[$i], "desc", $sec[$i] & ".html")
		DirRemove(@ScriptDir & "\data\" & $sec[$i], 1)
		DirCopy($file & "\data\" & $sec[$i], @ScriptDir & "\data\" & $sec[$i])
		$addCount = $addCount + 1
	Next
	$data = IniReadSectionNames(@ScriptDir & "\data.ini")
	If @error Then
		Global $data[2]
		$data[0] = 0
	EndIf
	GUICtrlSetData($ls_brief, "")
	Local $str = "", $n = $data[0]
	If $n > $MAX_LIST_DISP Then $n = $MAX_LIST_DISP
	For $i = 1 To $n
		$str = $str & $data[$i] & "|"
	Next
	$str = StringLeft($str, StringLen($str) - 1)
	GUICtrlSetData($ls_brief, $str)
	_GUICtrlListBox_SetCurSel ($ls_brief, 0)
	setData(_GUICtrlListBox_GetText ($ls_brief, 0))
	TrayTip("�ϲ�������", "�ϲ���ɡ��޸���Ŀ��" & $modCount & "��������Ŀ��" & $addCount, 10)
	GUISetState(@SW_HIDE, $gui_process)
	GUISetState(@SW_ENABLE, $gui)
	GUISetState(@SW_RESTORE, $gui)
	TrayItemSetState ($tm_about, $TRAY_ENABLE)
	TrayItemSetState ($tm_quit, $TRAY_ENABLE)
EndFunc

; ����Ҫ�ϲ��򷵻� True
Func _compareHtmlFiles($path, $brief)
	Local $search = FileFindFirstFile($path & "\data\" & $brief & "\*.*")
	If $search = -1 Then
		Return False
	EndIf
	Local $file, $html = FileRead($path & "\data\" & $brief & "\" & $brief & ".html")
	Local $htmlOrg = FileRead(@ScriptDir & "\data\" & $brief & "\" & $brief & ".html")
	If $html <> $htmlOrg Then Return False
	While 1
		$file = FileFindNextFile($search) 
		If @error Then ExitLoop
		If StringLower($file) == StringLower($brief & ".html") Then ContinueLoop
		If Not StringInStr($html, $file) Then ContinueLoop ;δ���õ��ļ�������
		; ����ͼƬ���������������ļ�����С��һ������Ϊ��Ҫ�ϲ���
		If FileGetSize($path & "\data\" & $brief & "\" & $file) <> _
			FileGetSize(@ScriptDir & "\data\" & $brief & "\" & $file) Then Return False
	WEnd
	FileClose($search)
	Return True
EndFunc

Func _mergeDialog($brief, $explain1, $explain2, $html1, $html2)
	#Region ### START Koda GUI section ### Form=
	Local $gui_merge = GUICreate("Form1", 875, 680, 0, 0)
	GUISwitch($gui_merge)
	GUICtrlCreateLabel("������(ԭ)", 8, 312)
	GUICtrlCreateLabel("������(ԭ)", 8, 336)
	GUICtrlCreateLabel("������(��)", 808, 312)
	GUICtrlCreateLabel("������(��)", 808, 336)
	Local $obj_IEMergeDlg = _IECreateEmbedded ()
	Local $obj_viewMerge = GUICtrlCreateObj($obj_IEMergeDlg, 8, 8, 859, 295)
	Local $txt_briefOrg = GUICtrlCreateInput($brief, 72, 312, 201, 21, _
		BitOR($ES_AUTOHSCROLL,$ES_READONLY))
	Local $txt_explainOrg = GUICtrlCreateInput($explain1, 72, 336, 361, 21, _
		BitOR($ES_AUTOHSCROLL,$ES_READONLY))
	Local $htmlCxt1 = FileRead($html1)
	Local $txt_descOrg = GUICtrlCreateEdit($htmlCxt1, 8, 360, 425, 313, _
		BitOR($ES_AUTOVSCROLL,$ES_READONLY,$ES_WANTRETURN,$WS_VSCROLL))
	Local $txt_briefNew = GUICtrlCreateInput($brief, 600, 312, 201, 21, _
		BitOR($ES_AUTOHSCROLL,$ES_READONLY))
	Local $txt_explainNew = GUICtrlCreateInput($explain2, 440, 336, 361, 21, _
		BitOR($ES_AUTOHSCROLL,$ES_READONLY))
	Local $htmlCxt2 = FileRead($html2)
	Local $txt_descNew = GUICtrlCreateEdit($htmlCxt2, 440, 360, 425, 313, _
		BitOR($ES_AUTOVSCROLL,$ES_READONLY,$ES_WANTRETURN,$WS_VSCROLL))
	Local $btn_viewNew = GUICtrlCreateButton("Ԥ���¼�¼", 440, 312, 75, 21, 0)
	Local $btn_viewOrg = GUICtrlCreateButton("Ԥ��ԭ��¼", 359, 312, 74, 21, 0)
	Local $btn_useOrg = GUICtrlCreateButton("ʹ��ԭ��¼", 280, 312, 74, 21, 0)
	Local $btn_useNew = GUICtrlCreateButton("ʹ���¼�¼", 520, 312, 75, 21, 0)
	If $explain1 <> $explain2 Then
		GUICtrlSetFont($txt_explainOrg, 9, 800)
		GUICtrlSetFont($txt_explainNew, 9, 800)
	EndIf
	If $htmlCxt1 <> $htmlCxt2 Then
		GUICtrlSetFont($txt_descOrg, 9, 800)
		GUICtrlSetFont($txt_descNew, 9, 800)
	EndIf
	FileDelete($TMP_HTML_FILE)
	FileWrite($TMP_HTML_FILE, _genHelpHtml())
	_IENavigate ($obj_IEMergeDlg, $TMP_HTML_FILE)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $btn_viewNew
				_IENavigate ($obj_IEMergeDlg, $html2)
			Case $btn_viewOrg
				_IENavigate ($obj_IEMergeDlg, $html1)
			Case $btn_useNew
				GUIDelete($gui_merge)
				GUISwitch($gui)
				Return $MERGE_RESULT_USENEW
			Case $btn_useOrg
				GUIDelete($gui_merge)
				GUISwitch($gui)
				Return $MERGE_RESULT_USEORG
		EndSwitch
	WEnd
EndFunc

Func _genHelpHtml()
	Return "<html><body><font size=2>" & _
			"1�������·����ı����е���������Ǵ��壬���ʾ��������" & _
			"<b><font size=5 face='Courier New' color=#FF0000>��</font></b>" & _
			"���죬��Ҫ�ر�ע��ġ�<br>" & _
			"2�������<font size=4 face='Courier New' color=#0000FF>Ԥ��ԭ��¼</font>����" & _
			"��<font size=4 face='Courier New' color=#0000FF>Ԥ���¼�¼</font>��" & _
			"��������������г���ԭ��¼���¼�¼��htmlЧ����<br>" & _
			"3����ϸ�ԱȺ󣬵�����<font size=4 face='Courier New' color=#0000FF>ʹ��ԭ��¼</font>����" & _
			"��<font size=4 face='Courier New' color=#0000FF>ʹ���¼�¼</font>��" & _
			"������ʹ��ԭ��¼�����¼�¼�����һ����ͻ�Ľ����" & _
			"</font></body></html>"
EndFunc
















