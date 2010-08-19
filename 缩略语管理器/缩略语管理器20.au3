#Include <Constants.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#Include <GuiListBox.au3>
#include <GuiEdit.au3>
#Include <GuiComboBox.au3>
#include <IE.au3>
#include <Date.au3>
#Include <File.au3>
#include <Misc.au3>
#include ".\Include\Common.au3"
#include ".\Include\MergeUtils.au3"
#include ".\Include\EditPictures.au3"
#include ".\Include\ReplaceBrief.au3"
#include ".\ZipPlugin\_ZipPlugin.au3"

#AutoIt3Wrapper_Icon=ico.ico

initData()
GUICtrlSetState($txt_brief, $GUI_FOCUS)
AdlibEnable("listen", $LISTEN_INTERVAL)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $ls_brief
			setData()
		Case $txt_brief
			handleComboBox()
		Case $m_add, $cm_add, $btn_new
			popupDialog($DIALOG_MODE_ADD)
		Case $m_mod, $cm_mod, $btn_mod
			popupDialog($DIALOG_MODE_MOD)
		Case $cm_modName, $m_modName
			modifyName()
		Case $cm_modExp, $m_modExp, $btn_modExp
			modifyExp()
		Case $m_del, $cm_del, $btn_del
			delete()
		Case $m_merge
			merge()
		Case $btn_backward
			backward()
		Case $btn_forward
			forward()
		Case $btn_search
			searchGoogle()
		Case $m_ontop, $btn_setOnTop
			setOnTop()
		Case $btn_editPic
			_EditPictures_showDialog(_getBriefFromUrl(), "", $gui, $EDIT_PICTURE_MODE_MAIN)
		Case $m_packChanged
			_packItems()
		Case $m_packAll
			_packItems(True)
		Case $dm_brief
			handleSpace()
		Case $dm_esc
			handleESC()
		Case $dm_enter
			handleEnter()
		Case $dm_down
			handleDown()
		Case $dm_up
			handleUp()
		Case $GUI_EVENT_RESIZED
			resizeControls()
		Case $GUI_EVENT_RESTORE
			resizeControls()
		Case $GUI_EVENT_MAXIMIZE
			resizeControls()
		Case $GUI_EVENT_CLOSE, $m_quit
			Exit
			
	EndSwitch
	$nMsg = TrayGetMsg()
	Switch $nMsg
		Case $tm_about
			_about()
		Case $tm_quit
			Exit
	EndSwitch
WEnd

Func popupDialog($mode)
	GUICtrlSetState($txt_brief, $GUI_FOCUS)
	TrayTip("", "", 1)
	TrayItemSetState($tm_about, $TRAY_DISABLE)
	TrayItemSetState($tm_quit, $TRAY_DISABLE)
	GUISetState(@SW_DISABLE, $gui)
	Local $brief = popupEditor($mode)
	TrayItemSetState($tm_about, $TRAY_ENABLE)
	TrayItemSetState($tm_quit, $TRAY_ENABLE)
	If $brief == "" Then Return
	If $mode == $DIALOG_MODE_ADD Then
		$data = IniReadSectionNames($DATA_INI)
		If @error Then
			ReDim $data[2]
			$data[0] = 0
		EndIf
		TrayTip($APP_TITLE, "当前词汇总量：" & $data[0] & @CRLF & "当前的等级是：" & getLevel($data[0]), 30)
		AdlibDisable()
		$lastListenedBrief = ""
		GUICtrlSetData($ls_brief, "")
		Local $str = "", $n = $data[0]
		If $n > $MAX_LIST_DISP Then $n = $MAX_LIST_DISP
		For $i = 1 To $n
			$str = $str & $data[$i] & "|"
		Next
		$str = StringLeft($str, StringLen($str) - 1)
		GUICtrlSetData($ls_brief, $str)
		_GUICtrlComboBox_SetEditText($hBrief, "")
		$lastListenedBrief = ""
		_IENavigate ($obj_IE, @ScriptDir & "\data\" & $brief & "\" & $brief & ".html")
		GUICtrlSetData($txt_explain, IniRead($DATA_INI, $brief, "brief", ""))
		_GUICtrlListBox_SetCurSel ($ls_brief, _GUICtrlListBox_FindString($ls_brief, $brief, True))
		AdlibEnable("listen", $LISTEN_INTERVAL)
	ElseIf $mode == $DIALOG_MODE_MOD Then
		_IEAction($obj_IE, "refresh")
	EndIf
	
EndFunc

Func modifyName()
	If _GUICtrlListBox_GetCurSel($ls_brief) == -1 Then
		MsgBox(8256,$APP_TITLE, "请选择一个缩略语再试。", Default, $gui)
		Return
	EndIf
	GUISetState(@SW_DISABLE, $gui)
	Local $sInputBoxAnswer = InputBox($APP_TITLE,"输入一个新的名字：", _
		GUICtrlRead($ls_brief), "", 200, 120, -1, -1, Default, $gui)
	Local $ret = @error
	GUISetState(@SW_ENABLE, $gui)
	GUISetState(@SW_RESTORE, $gui)
	Local $brief = GUICtrlRead($ls_brief)
	Select
		Case $ret = 0 ;OK - The string returned is valid
			If StringRegExp($sInputBoxAnswer, "[?:""'*/\|<>!#$%&]") Then
				MsgBox(8256,$APP_TITLE,"新缩略语名字包含非法字符。" & @CRLF & _
					"不允许包含如下字符：?:""'*/\|<>!#$%&&", Default, $gui)
				Return
			EndIf
			If IniRenameSection($DATA_INI, $brief, $sInputBoxAnswer) == 0 Then
				;MsgBox features: Title=Yes, Text=Yes, Buttons=OK, Icon=Info, Modality=Task Modal
				MsgBox(8256,$APP_TITLE,"目标缩略语已经存在，修改失败。", Default, $gui)
				Return
			EndIf
			IniWrite($DATA_INI, $sInputBoxAnswer, "changed", "true")
			$data = IniReadSectionNames($DATA_INI)
			AdlibDisable()
			$lastListenedBrief = ""
			GUICtrlSetData($ls_brief, "")
			Local $str = "", $n = $data[0]
			If $n > $MAX_LIST_DISP Then $n = $MAX_LIST_DISP
			For $i = 1 To $n
				$str = $str & $data[$i] & "|"
			Next
			$str = StringLeft($str, StringLen($str) - 1)
			GUICtrlSetData($ls_brief, $str)
			_GUICtrlListBox_SetCurSel ($ls_brief, _GUICtrlListBox_FindString($ls_brief, $sInputBoxAnswer, True))
			DirMove(@ScriptDir & "\data\" & $brief, @ScriptDir & "\data\" & $sInputBoxAnswer)
			FileMove(@ScriptDir & "\data\" & $sInputBoxAnswer & "\" & $brief & ".html", _
				@ScriptDir & "\data\" & $sInputBoxAnswer & "\" & $sInputBoxAnswer & ".html")
			AdlibEnable("listen", $LISTEN_INTERVAL)
		Case $ret = 1 ;The Cancel button was pushed
			Return
		Case $ret = 3 ;The InputBox failed to open
			Return
	EndSelect
	AdlibEnable("listen", $LISTEN_INTERVAL)
EndFunc

Func modifyExp()
	If _GUICtrlListBox_GetCurSel($ls_brief) == -1 Then
		MsgBox(8256,$APP_TITLE, "请选择一个缩略语再试。", Default, $gui)
		Return
	EndIf
	Local $sInputBoxAnswer = InputBox($APP_TITLE,"输入一个新的含义：", _
		GUICtrlRead($txt_explain), "", 200, 120, -1, -1, Default, $gui)
	Local $ret = @error
	Local $brief = GUICtrlRead($ls_brief)
	Select
		Case $ret = 0 ;OK - The string returned is valid
			IniWrite($DATA_INI, $brief, "brief", $sInputBoxAnswer)
			GUICtrlSetData($txt_explain, $sInputBoxAnswer)
			IniWrite($DATA_INI, $brief, "changed", "true")
		Case $ret = 1 ;The Cancel button was pushed
			Return
		Case $ret = 3 ;The InputBox failed to open
			Return
	EndSelect
EndFunc

Func delete()
	If BitAND (GUICtrlRead($m_ontop), $GUI_CHECKED) == $GUI_CHECKED Then setOnTop()
	If _GUICtrlListBox_GetCurSel($ls_brief) == -1 Then
		MsgBox(8256,$APP_TITLE, "请选择一个缩略语再试。", Default, $gui)
		Return
	EndIf
	Local $brief = GUICtrlRead($ls_brief)
	Local $iMsgBoxAnswer = MsgBox(8228,$APP_TITLE,"是否删除缩略语：" & $brief & "？" & @CRLF & _
				"包括所有引用到的文件都会一并删除。", Default, $gui)
	If $iMsgBoxAnswer == 7 Then Return
	
	IniDelete($DATA_INI, $brief)
	DirRemove(@ScriptDir & "\data\" & $brief, 1)
	$data = IniReadSectionNames($DATA_INI)
	If @error Then
		Global $data[2]
		$data[0] = 0
	EndIf
	TrayTip($APP_TITLE, "当前词汇总量：" & $data[0] & @CRLF & "当前的等级是：" & getLevel($data[0]), 30)
	_GUICtrlComboBox_SetEditText($hBrief, "")
	GUICtrlSetData($ls_brief, "")
	Local $str = "", $n = $data[0]
	If $n > $MAX_LIST_DISP Then $n = $MAX_LIST_DISP
	For $i = 1 To $n
		$str = $str & $data[$i] & "|"
	Next
	$str = StringLeft($str, StringLen($str) - 1)
	GUICtrlSetData($ls_brief, $str)
	_GUICtrlListBox_SetCurSel ($ls_brief, 0)
	setData(GUICtrlRead($ls_brief))
EndFunc

Func backward()
	If _IEAction($obj_IE, "back") == 0 Then Return
	_IELoadWait($obj_IE)
	Local $brief = _getBriefFromUrl()
	Local $i
	For $i = 1 To $data[0]
		If StringLower($data[$i]) <> StringLower($brief) Then ContinueLoop
		GUICtrlSetData($txt_explain, IniRead($DATA_INI, $brief, "brief", ""))
		_GUICtrlListBox_SetCurSel ($ls_brief, _GUICtrlListBox_FindString($ls_brief, $brief, True))
		Return
	Next
	GUICtrlSetData($txt_explain, "")
	_GUICtrlListBox_SetCurSel ($ls_brief, -1)
EndFunc

Func forward()
	If _IEAction($obj_IE, "forward") == 0 Then Return
	_IELoadWait($obj_IE)
;~ 	Local $url = _IEPropertyGet($obj_IE, "locationurl")
	Local $brief = _getBriefFromUrl()
	Local $i
	For $i = 1 To $data[0]
		If StringLower($data[$i]) <> StringLower($brief) Then ContinueLoop
		GUICtrlSetData($txt_explain, IniRead($DATA_INI, $brief, "brief", ""))
		_GUICtrlListBox_SetCurSel ($ls_brief, _GUICtrlListBox_FindString($ls_brief, $brief, True))
		Return
	Next
	GUICtrlSetData($txt_explain, "")
	_GUICtrlListBox_SetCurSel ($ls_brief, -1)
EndFunc

Func listen()
	listenPageLink()
	Local $brief = _GUICtrlComboBox_GetEditText($hBrief)
	If $lastListenedBrief == $brief Then Return
	Local $str = ""
	Local $i = 0, $n = $data[0]
	If $n > $MAX_LIST_DISP Then $n = $MAX_LIST_DISP
	If $brief == "" Then
		GUICtrlSetData($ls_brief, "")
		For $i = 1 To $n
			$str = $str & $data[$i] & "|"
		Next
		$str = StringLeft($str, StringLen($str) - 1)
		GUICtrlSetData($ls_brief, $str)
		$lastListenedBrief = $brief
		_GUICtrlListBox_SetCurSel ($ls_brief, 0)
		Return
	EndIf
	If Not StringInStr($brief, $lastListenedBrief, 2) Then
		GUICtrlSetData($ls_brief, "")
		For $i = 1 To $data[0]
			If Not StringInStr($data[$i], $brief, 2) Then ContinueLoop
			$str = $str & $data[$i] & "|"
		Next
		$str = StringLeft($str, StringLen($str) - 1)
		$listBuff = StringSplit($str, "|")
		GUICtrlSetData($ls_brief, $str)
		$lastListenedBrief = $brief
		_GUICtrlListBox_SetCurSel ($ls_brief, 0)
	Else
		GUICtrlSetData($ls_brief, "")
		For $i = 1 To $listBuff[0]
			If Not StringInStr($listBuff[$i], $brief, 2) Then ContinueLoop
			$str = $str & $listBuff[$i] & "|"
		Next
		$str = StringLeft($str, StringLen($str) - 1)
		$listBuff = StringSplit($str, "|")
		GUICtrlSetData($ls_brief, $str)
		$lastListenedBrief = $brief
		_GUICtrlListBox_SetCurSel ($ls_brief, 0)
	EndIf
EndFunc

Func listenPageLink()
	Local $url = $obj_IE.locationURL()
	If $lastListenedUrl == $url Then Return
	$lastListenedUrl = $url
	Local $brief = _getBriefFromUrl($url)
	Local $i, $ret, $str = "", $path
	AdlibDisable()
	If _containsImages($brief) Then
		GUICtrlSetState($btn_editPic, $GUI_ENABLE)
	Else
		GUICtrlSetState($btn_editPic, $GUI_DISABLE)
	EndIf
	For $i = 1 To $data[0]
		If StringLower($data[$i]) <> StringLower($brief) Then ContinueLoop
		$path = StringReplace(@ScriptDir & "\data\" & $brief & "\" & $brief & ".html", "\", "/")
		$path = StringReplace($path, " ", "%20")
		If Not StringInStr($url, $path, 0) Then ContinueLoop
		GUICtrlSetState($btn_mod, $GUI_ENABLE)
		GUICtrlSetState($cm_mod, $GUI_ENABLE)
		GUICtrlSetState($m_mod, $GUI_ENABLE)
		GUICtrlSetState($btn_del, $GUI_ENABLE)
		GUICtrlSetState($cm_del, $GUI_ENABLE)
		GUICtrlSetState($m_del, $GUI_ENABLE)
		GUICtrlSetState($btn_modExp, $GUI_ENABLE)
		GUICtrlSetState($cm_modExp, $GUI_ENABLE)
		GUICtrlSetState($m_modExp, $GUI_ENABLE)
		GUICtrlSetState($m_modName, $GUI_ENABLE)
		GUICtrlSetState($cm_modName, $GUI_ENABLE)
		GUICtrlSetData($txt_explain, IniRead($DATA_INI, $brief, "brief", ""))
		$ret = _GUICtrlListBox_SetCurSel ($ls_brief, _GUICtrlListBox_FindString($ls_brief, $brief, True))
		If $ret == -1 Then
			For $i = 1 To $data[0]
				$str = $str & $data[$i] & "|"
			Next
			$str = StringLeft($str, StringLen($str) - 1)
			GUICtrlSetData($ls_brief, $str)
			_GUICtrlListBox_SetCurSel ($ls_brief, _GUICtrlListBox_FindString($ls_brief, $brief, True))
		EndIf
		AdlibEnable("listen", $LISTEN_INTERVAL)
		Return
	Next
	GUICtrlSetState($btn_mod, $GUI_DISABLE)
	GUICtrlSetState($cm_mod, $GUI_DISABLE)
	GUICtrlSetState($m_mod, $GUI_DISABLE)
	GUICtrlSetState($btn_del, $GUI_DISABLE)
	GUICtrlSetState($cm_del, $GUI_DISABLE)
	GUICtrlSetState($m_del, $GUI_DISABLE)
	GUICtrlSetState($btn_modExp, $GUI_DISABLE)
	GUICtrlSetState($cm_modExp, $GUI_DISABLE)
	GUICtrlSetState($m_modExp, $GUI_DISABLE)
	GUICtrlSetState($m_modName, $GUI_DISABLE)
	GUICtrlSetState($cm_modName, $GUI_DISABLE)
	_GUICtrlListBox_SetCurSel ($ls_brief, -1)
	GUICtrlSetData($txt_explain, "")
	AdlibEnable("listen", $LISTEN_INTERVAL)
EndFunc

Func handleSpace()
	If ControlGetFocus ($gui) == "Edit2" Then
		ControlCommand($gui, "", $txt_search, "EditPaste", " ")
	Else
		GUICtrlSetState($txt_brief, $GUI_FOCUS)
	EndIf
EndFunc

Func handleESC()
	AdlibDisable()
	If GUICtrlRead($txt_brief) == "" Then
		GUICtrlSetState($txt_brief, $GUI_FOCUS)
		AdlibEnable("listen", $LISTEN_INTERVAL)
		Return
	EndIf
	_GUICtrlComboBox_SetEditText($hBrief, "")
	GUICtrlSetState($txt_brief, $GUI_FOCUS)
;~ 	Local $url = _IEPropertyGet($obj_IE, "locationurl")
	Local $brief = _getBriefFromUrl()
	$lastListenedBrief = ""
	GUICtrlSetData($ls_brief, "")
	Local $str = "", $n = $data[0]
	If $n > $MAX_LIST_DISP Then $n = $MAX_LIST_DISP
	For $i = 1 To $n
		$str = $str & $data[$i] & "|"
	Next
	$str = StringLeft($str, StringLen($str) - 1)
	GUICtrlSetData($ls_brief, $str)
	If $brief <> "" Then
		_GUICtrlListBox_SetCurSel ($ls_brief, _GUICtrlListBox_FindString($ls_brief, $brief, True))
	Else
		GUICtrlSetData($txt_explain, "")
	EndIf
	AdlibEnable("listen", $LISTEN_INTERVAL)
EndFunc

Func handleEnter()
	Local $id = ControlGetFocus($gui)
	If $id == "Edit1" Or $id == "ListBox1" Then
;~ 		MsgBox(0, "", "")
		setData(GUICtrlRead ($ls_brief))
		If StringInStr(_GUICtrlComboBox_GetList($hBrief), GUICtrlRead ($txt_brief)) Then Return
		_GUICtrlComboBox_AddString($hBrief, GUICtrlRead($txt_brief))
	ElseIf $id == "Edit2" Then
		searchGoogle()
	EndIf
EndFunc

Func handleDown()
;~ 	AdlibDisable()
	Local $n = _GUICtrlListBox_GetCurSel($ls_brief)
	If $n == _GUICtrlListBox_GetCount($ls_brief) Then Return
	_GUICtrlListBox_SetCurSel($ls_brief, $n + 1)
;~ 	AdlibEnable("listen", $LISTEN_INTERVAL)
EndFunc

Func handleUp()
;~ 	AdlibDisable()
	Local $n = _GUICtrlListBox_GetCurSel($ls_brief)
	If $n == 0 Then Return
	_GUICtrlListBox_SetCurSel($ls_brief, $n - 1)
;~ 	AdlibEnable("listen", $LISTEN_INTERVAL)
EndFunc

Func searchGoogle()
	Local $search = GUICtrlRead($txt_search)
	If $search == "" Or $search == $SEARCH_DEFAULT_TEXT Then
		TrayTip($APP_TITLE, "输入一个待搜索的关键字再试。", 5)
		Return
	EndIf
	GUICtrlSetState($btn_editPic, $GUI_DISABLE)
	GUICtrlSetState($btn_mod, $GUI_DISABLE)
	GUICtrlSetState($cm_mod, $GUI_DISABLE)
	GUICtrlSetState($m_mod, $GUI_DISABLE)
	GUICtrlSetState($btn_del, $GUI_DISABLE)
	GUICtrlSetState($cm_del, $GUI_DISABLE)
	GUICtrlSetState($m_del, $GUI_DISABLE)
	GUICtrlSetState($btn_modExp, $GUI_DISABLE)
	GUICtrlSetState($cm_modExp, $GUI_DISABLE)
	GUICtrlSetState($m_modExp, $GUI_DISABLE)
	GUICtrlSetState($m_modName, $GUI_DISABLE)
	GUICtrlSetState($cm_modName, $GUI_DISABLE)
	TrayTip($APP_TITLE, "正在Google上搜索""" & $search & """，请稍等。", 30)
	_IENavigate($obj_IE, "http://www.google.cn/search?maxResults=50?complete=1&hl=zh-CN&newwindow=0&q=" & $search & "&meta=&aq=f&oq=")
	_IELoadWait($obj_IE)
	_GUICtrlListBox_SetCurSel($ls_brief, -1)
	GUICtrlSetData($txt_explain, "")
	TrayTip("", "", 1)
EndFunc

Func setOnTop()
	If BitAND (GUICtrlRead($m_ontop), $GUI_CHECKED) == $GUI_CHECKED Then
		WinSetOnTop($gui, "", 0)
		GUICtrlSetState($m_ontop, $GUI_UNCHECKED)
	Else
		WinSetOnTop($gui, "", 1)
		GUICtrlSetState($m_ontop, $GUI_CHECKED)
	EndIf
EndFunc

Func _about()
	MsgBox(8192,"关于","关于 缩略语管理器2.0" & @CRLF & @CRLF & _
		"版    本：" & $VERSION & @CRLF & _
		"更新日期：" & $UPDATED_DATE & @CRLF & _
		"作    者：陈旭" & @CRLF & _
		"与我联系：oicqcx@hotmail.com (msn/email)", Default, $gui)
EndFunc

Func _packItems($isAll = False)
	Local $handle
	If (($handle = PluginOpen(@ScriptDir & "\zipplugin\Au3Zip.dll")) == 0) Then Return False
	If FileExists(@ScriptDir & "\_TempZip_") Then
		Local $iMsgBoxAnswer = MsgBox(8227, $APP_TITLE, _
			"用于压缩临时存放的目录" & @CRLF & _
			@ScriptDir & "\_TempZip_" & @CRLF & _
			"已经存在。是否删除该目录？" & @CRLF & @CRLF & _
			"是：删除这个目录已经目录中的所有文件和子文件夹。" & @CRLF & _
			"否：自动以.bak重命名该文件夹。" & @CRLF & _
			"取消：返回，手工清除该目录。", Default, $gui)
		If $iMsgBoxAnswer == 6 Then
			DirRemove(@ScriptDir & "\_TempZip_", 1)
			DirCreate(@ScriptDir & "\_TempZip_")
		ElseIf $iMsgBoxAnswer == 7 Then
			DirMove(@ScriptDir & "\_TempZip_", @ScriptDir & "\_TempZip_.bak")
		Else
			Return
		EndIf
	EndIf
	Local $i, $tmpFile = @ScriptDir & "\_TempZip_\data.ini"
	Local $changed = False
	ProgressOn("正在打包", "扫描文件...", "0 %")
	For $i = 1 To $data[0]
		If StringLower(IniRead($DATA_INI, $data[$i], "changed", "error")) == "true" Or _
			$isAll Then
			DirCopy(@ScriptDir & "\data\" & $data[$i], @ScriptDir & "\_TempZip_\data\" & $data[$i], 1)
			IniWrite($tmpFile, $data[$i], "brief", _
				IniRead($DATA_INI, $data[$i], "brief", "error"))
			If Not $isAll Then IniWrite($DATA_INI, $data[$i], "changed", "false")
			$changed = True
		EndIf
		ProgressSet(Int(($i/$data[0])*90))
	Next
	If Not $changed Then
		ProgressOff()
		MsgBox(8256, $APP_TITLE, "没有改变的文件。", Default, $gui)
		DirRemove(@ScriptDir & "\_TempZip_", 1)
		Return False
	EndIf
	If FileExists(@ScriptDir & "\data.zip") Then
		ProgressOff()
		Local $iMsgBoxAnswer = MsgBox(8227, $APP_TITLE, _
			"文件data.zip存在，这个可能是之前压缩过的，是否备份data.zip？" & @CRLF & _
			"是：自动以 .bak+当前时间 来重命名该文件。" & @CRLF & _
			"否：删除这个文件。" & @CRLF & _
			"取消：返回，手工清除文件。", Default, $gui)
		If $iMsgBoxAnswer == 6 Then
			FileMove(@ScriptDir & "\data.zip", @ScriptDir & "\data.zip.bak" & _
				_DateDiff( 's',"1970/01/01 00:00:00",_NowCalc()))
		ElseIf $iMsgBoxAnswer == 7 Then
			FileDelete(@ScriptDir & "\data.zip")
		Else
			DirRemove(@ScriptDir & "\_TempZip_", 1)
			Return
		EndIf
		ProgressOn("正在打包", "正在压缩...", "90 %")
		ProgressSet(90)
	EndIf
	ProgressSet(90, "90 %", "正在压缩...")
	Local $zip = _ZipCreate("data.zip")
	_ZipAdd($zip, $tmpFile, "data.ini")
	_ZipAddDir($zip, @ScriptDir & "\_TempZip_\data", 1)
	_ZipClose($zip)
	DirRemove(@ScriptDir & "\_TempZip_", 1)
	ProgressSet(100, "100 %", "完成。")
	Sleep(800)
	ProgressOff()
	TrayTip($APP_TITLE, "打包完成！文件在" & @ScriptDir & "\data.zip", 30)
	Return True
EndFunc

Func initData()
	$dataFile = FileOpen($DATA_INI, 1) ; 锁住这个文件，不让其它程序修改。
	$data = IniReadSectionNames($DATA_INI)
	If @error Then
		Global $data[2]
		$data[0] = 0
	EndIf
	TrayTip($APP_TITLE, "当前词汇总量：" & $data[0] & @CRLF & "当前的等级是：" & getLevel($data[0]), 30)
	GUICtrlSetData($ls_brief, "")
	Local $str = "", $n = $data[0]
	If $n > $MAX_LIST_DISP Then $n = $MAX_LIST_DISP
	For $i = 1 To $n
		$str = $str & $data[$i] & "|"
	Next
	$str = StringLeft($str, StringLen($str) - 1)
	GUICtrlSetData($ls_brief, $str)
	_GUICtrlListBox_SetCurSel ($ls_brief, 0)
	setData(GUICtrlRead ($ls_brief))
EndFunc

Func setData($brief = "")
	AdlibDisable()
	If $brief == "" Then $brief = GUICtrlRead($ls_brief)
	If $brief == _getBriefFromUrl() Then
		AdlibEnable("listen", $LISTEN_INTERVAL)
		Return
	EndIf
	GUICtrlSetData($txt_explain, IniRead($DATA_INI, $brief, "brief", ""))
	Local $file = @ScriptDir & "\data\" & $brief & "\" & $brief & ".html"
	If Not FileExists($file) Then
		FileDelete($TMP_HTML_FILE)
		FileWrite($TMP_HTML_FILE, "")
		$file = $TMP_HTML_FILE
	EndIf
	_IENavigate ($obj_IE, $file)
	If GUICtrlRead($ls_brief) == "" Or _
		StringInStr(_GUICtrlComboBox_GetList($hBrief), GUICtrlRead ($ls_brief)) Then
		AdlibEnable("listen", $LISTEN_INTERVAL)
		Return
	EndIf
	_GUICtrlComboBox_AddString($hBrief, GUICtrlRead($ls_brief))
	AdlibEnable("listen", $LISTEN_INTERVAL)
EndFunc

Func handleComboBox()
	$lastListenedBrief = _GUICtrlComboBox_GetEditText($hBrief)
	Local $brief = GUICtrlRead($txt_brief), $i, $str = ""
	If _GUICtrlListBox_SetCurSel ($ls_brief, _GUICtrlListBox_FindString($ls_brief, $brief)) == -1 Then
		GUICtrlSetData($ls_brief, "")
		For $i = 1 To $data[0]
			If Not StringInStr($data[$i], $brief) Then ContinueLoop
			$str &= $brief & "|"
		Next
		$str = StringLeft($str, StringLen($str) - 1)
		GUICtrlSetData($ls_brief, $str)
		_GUICtrlListBox_SetCurSel ($ls_brief, _GUICtrlListBox_FindString($ls_brief, $brief))
	EndIf
	setData($brief)
EndFunc

Func resizeControls()
	Local $pos = WinGetPos($gui)
	If Not IsArray($pos) Then Return
	GUICtrlSetPos($ls_brief, 0, 43, Default, (($pos[3] - 85)/12) * 12)
	GUICtrlSetPos($obj_description, 120, 67, $pos[2] - 127, $pos[3] - 112)
EndFunc

Func resetBriefList()
	Local $str = "", $n = $data[0]
	If $n > $MAX_LIST_DISP Then $n = $MAX_LIST_DISP
	For $i = 1 To $n
		$str = $str & $data[$i] & "|"
	Next
	$str = StringLeft($str, StringLen($str) - 1)
	GUICtrlSetData($ls_brief, "")
	GUICtrlSetData($ls_brief, $str)
EndFunc

Func popupEditor($mode)
	Local $brief
	If $mode == $DIALOG_MODE_ADD Then
		$brief = createBrief()
		If $brief == "" Then
			GUISetState(@SW_ENABLE, $gui)
			GUISwitch($gui)
			Return ""
		EndIf
	Else
		$brief = _getBriefFromUrl()
		If $brief == "" Then
			MsgBox(8256, $APP_TITLE, "请选择一个缩略语再试。", Default, $gui)
			GUISetState(@SW_ENABLE, $gui)
			GUISwitch($gui)
			Return ""
		EndIf
	EndIf
	
	Local Const $EDITOR_TITLE = "编辑缩略语"
	Local $pos = WinGetPos($gui)
	Local $gui_editor = GUICreate($EDITOR_TITLE, 880, 660, _
		(@DesktopWidth - 880)/2 - $pos[0] - 5,(@DesktopHeight - 660)/3 - $pos[1] - 20, _
		Default, $WS_EX_MDICHILD, $gui)
	GUISwitch($gui_editor)
	Local $btn_save = GUICtrlCreateButton("保存(Ctrl+S)", 2, 2, 90, 20, 0)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	Local $btn_createBriefLinks = GUICtrlCreateButton("替换缩略语", 95, 2, 90, 20, 0)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	Local $btn_editPic1 = GUICtrlCreateButton("编辑图片", 188, 2, 90, 20, 0)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	Local $btn_cancel = GUICtrlCreateButton("关闭", 291, 2, 50, 20, 0)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	Local $obj_IEEditor = _IECreateEmbedded ()
	Local $obj_editor = GUICtrlCreateObj($obj_IEEditor, 0, 25, 880, 635)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	Local $hotKeys[1][2] = [["^s", $btn_save]]
	GUISetAccelerators($hotKeys, $gui_editor)
	GUISetState(@SW_SHOW, $gui_editor)
	_IENavigate($obj_IEEditor, createIndexPage($brief))
	_IELoadWait($obj_IEEditor, 1)
	Local $oForm = _IEFormGetObjByName ($obj_IEEditor, "edit_area")
	Local $oBtnSave = _IEFormElementGetObjByName($oForm, "save_button")
	Local $oInput = _IEFormElementGetObjByName ($oForm, "source_code")
	Local $pos, $ret1, $ret2, $src, $lastSrc
	_IEAction($oBtnSave, "click")
	$src = _IEFormElementGetValue($oInput)
	$lastSrc = $src
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $btn_save
				_IEAction($oBtnSave, "click")
				$src = _IEFormElementGetValue($oInput)
				If $lastSrc == $src Then ContinueLoop
				$lastSrc = $src
			Case $btn_cancel, $GUI_EVENT_CLOSE
				_IEAction($oBtnSave, "click")
				$src = _IEFormElementGetValue($oInput)
				If $src <> $lastSrc And _
					MsgBox(8484,$APP_TITLE, "是否退出？未保存的修改将丢失。", Default, $gui_editor) == 6 Then
					convertAndSave($lastSrc, $brief)
					GUISetState(@SW_ENABLE, $gui)
					GUIDelete($gui_editor)
					Return $brief
				ElseIf $src == $lastSrc Then
					convertAndSave($lastSrc, $brief)
					GUISetState(@SW_ENABLE, $gui)
					GUIDelete($gui_editor)
					Return $brief
				EndIf
			Case $btn_createBriefLinks
				_IEAction($oBtnSave, "click")
				$src = _IEFormElementGetValue($oInput)
				If $src <> $lastSrc And _
					MsgBox(8228,$APP_TITLE, "执行本操作之前必须保存已做的修改。" & @CRLF & _
						"是否保存并继续？", Default, $gui_editor) == 7 Then
					ContinueLoop
				EndIf
				$lastSrc = $src
				_IENavigate($obj_IEEditor, createIndexPage(_ReplaceBrief_createLink($src, $gui_editor)))
				_IELoadWait($obj_IEEditor, 1)
				$oForm = _IEFormGetObjByName ($obj_IEEditor, "edit_area")
				$oBtnSave = _IEFormElementGetObjByName ($oForm, "save_button")
				$oInput = _IEFormElementGetObjByName ($oForm, "source_code")
			Case $btn_editPic1
				_IEAction($oBtnSave, "click")
				$src = _IEFormElementGetValue($oInput)
				_EditPictures_showDialog($brief, $src, $gui_editor, $EDIT_PICTURE_MODE_EDITOR)
		EndSwitch
	WEnd
EndFunc

Func createBrief()
	Local $pos = WinGetPos($gui)
	Local $gui_le = GUICreate("新建缩略语", 427, 157, ($pos[2] - 427)/2, ($pos[3] - 157)/3, Default, $WS_EX_MDICHILD, $gui)
	GUISwitch($gui_le)
	GUICtrlCreateLabel( _
		"请输入一个缩略语及其含义，缩略语不允许使用如下字符：?:""'*/\|<>!#$%&&", 8, 8)
	GUICtrlCreateLabel("缩略语", 8, 40, 40, 17)
	GUICtrlCreateLabel("含　义", 8, 72, 40, 17)
	Local $txt_dlgBrief = GUICtrlCreateInput("新建缩略语*", 56, 40, 361, 21)
	GUICtrlSetState(-1, $GUI_FOCUS)
	Local $txt_dlgExplain = GUICtrlCreateInput("", 56, 72, 361, 21)
	GUICtrlCreateLabel("单击确定后请继续编辑当前缩略语的详细描述→", 8, 125)
	GUICtrlSetColor(-1, 0xff0000)
	Local $btn_dlgOK = GUICtrlCreateButton("确定", 264, 120, 75, 25, 0)
	GUICtrlSetTip(-1, "请继续编辑当前缩略语的详细描述")
	Local $btn_dlgCancel = GUICtrlCreateButton("取消", 344, 120, 75, 25, 0)
	GUICtrlSetTip(-1, "取消新建缩略语")
	Local $hotKeys[1][2] = [["{enter}", $btn_dlgOK]]
	GUISetAccelerators($hotKeys, $gui_le)
	GUISetState(@SW_SHOW)
	Local $brief, $i, $iMsgBoxAnswer, $explain_le
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $btn_dlgOK
				$brief = GUICtrlRead($txt_dlgBrief)
				If $brief == "" Or StringRegExp($brief, "[?:""'*/\|<>!#$%&]") Then
					;MsgBox features: Title=Yes, Text=Yes, Buttons=OK, Icon=Info, Modality=Task Modal
					MsgBox(8256,"新建缩略语","缩略语栏为空或者有非法字符，请输入一个合法的缩略语。", Default, $gui_le)
					GUICtrlSetState($txt_dlgBrief, $GUI_FOCUS)
					ContinueLoop
				EndIf
				$explain_le = GUICtrlRead($txt_dlgExplain)
				If $explain_le == "" Then
					;MsgBox features: Title=Yes, Text=Yes, Buttons=OK, Icon=Info, Modality=Task Modal
					MsgBox(8256,"新建缩略语","缩略语含义为空，请输入一个合法缩略语解释。", Default, $gui_le)
					GUICtrlSetState($txt_dlgExplain, $GUI_FOCUS)
					ContinueLoop
				EndIf
				If $iMsgBoxAnswer == 7 Then ; 删除原来的缩略语，并且新建一个
					IniDelete($DATA_INI, $brief)
					IniWrite($DATA_INI, $brief, "brief", $explain_le)
					DirRemove(@ScriptDir & "\data\" & $brief & "\", 1)
					DirCreate(@ScriptDir & "\data\" & $brief & "\")
					FileWrite(@ScriptDir & "\data\" & $brief & "\" & $brief & ".html", "")
					IniWrite($DATA_INI, $brief, "changed", "true")
;~ 					GUISetState(@SW_ENABLE, $gui)
					GUIDelete($gui_le)
					Return $brief
				EndIf
				IniWrite($DATA_INI, $brief, "brief", $explain_le)
				DirCreate(@ScriptDir & "\data\" & $brief & "\")
				FileWrite(@ScriptDir & "\data\" & $brief & "\" & $brief & ".html", "")
				IniWrite($DATA_INI, $brief, "changed", "true")
;~ 				GUISetState(@SW_ENABLE, $gui)
				GUIDelete($gui_le)
				Return $brief
			Case $txt_dlgBrief
				$brief = GUICtrlRead($txt_dlgBrief)
				For $i = 1 To $data[0]
					If StringLower($data[$i]) <> StringLower($brief) Then ContinueLoop
					;MsgBox features: Title=Yes, Text=Yes, Buttons=Yes, No, and Cancel, Icon=Question, Modality=Task Modal
					$iMsgBoxAnswer = MsgBox(8227,"新建缩略语","输入的缩略语已经存在，是否要编辑它？" & @CRLF & @CRLF & _
								"是：打开这个缩略语并且进行编辑；" & @CRLF & _
								"否：删除原来的缩略语，并新建一个同名缩略语条目；", Default, $gui_le)
					Select
						Case $iMsgBoxAnswer = 6 ;Yes
;~ 							GUISetState(@SW_ENABLE, $gui)
							GUIDelete($gui_le)
							Return $brief
						Case $iMsgBoxAnswer = 7 ;No
							If GUICtrlRead($txt_dlgExplain) == "" Then
								GUICtrlSetData($txt_dlgExplain, GUICtrlRead($txt_dlgBrief))
							EndIf
							GUICtrlSetState($txt_dlgExplain, $GUI_FOCUS)
							GUICtrlSetState($txt_dlgBrief, $GUI_DISABLE)
						Case $iMsgBoxAnswer = 2 ;Cancel
							GUISetState(@SW_ENABLE, $gui)
							GUIDelete($gui_le)
							Return ""
					EndSelect
				Next
				If GUICtrlRead($txt_dlgExplain) == "" Then
					GUICtrlSetData($txt_dlgExplain, GUICtrlRead($txt_dlgBrief))
				EndIf
				GUICtrlSetState($txt_dlgExplain, $GUI_FOCUS)
			Case $GUI_EVENT_CLOSE, $btn_dlgCancel
				GUISetState(@SW_ENABLE, $gui)
				GUIDelete($gui_le)
				Return ""
		EndSwitch
	WEnd
EndFunc

Func convertAndSave($src, $brief)
	Local $html = $src
	IniWrite($DATA_INI, $brief, "changed", "true")
	$html = StringReplace($html, "file:///", "")
	Local $n = StringInStr($html, '<img'), $m, $file, $desFile
	Local $imgSet[1] = [0]
	While $n <> 0
		$n = StringInStr($html, 'src=', 0, 1, $n)
		If $n == 0 Then
			$n = StringInStr($html, '<img', 0, 1, $n + 1)
		EndIf
		$n = $n + 5
		$m = StringInStr($html, '"', 0, 1, $n)
		$file = StringMid($html, $n, $m - $n)
		$imgSet[0] += 1
		ReDim $imgSet[$imgSet[0] + 1]
		$imgSet[$imgSet[0]] = $file
		$n = StringInStr($html, '<img', 0, 1, $n)
	WEnd
	Local $i
	For $i = 1 To $imgSet[0]
		$file = StringReplace($imgSet[$i], "%20", " ")
		If Not FileExists($file) Then ContinueLoop
		$desFile = _createUniqueFileName($file)
		$html = StringReplace($html, $imgSet[$i], ".\" & $desFile)
		FileCopy($file, @ScriptDir & "\data\" & $brief & "\" & $desFile, 1)
	Next
	$html = StringFormat($COMMON_HTML, $brief, $html)
	FileDelete(@ScriptDir & "\data\" & $brief & "\" & $brief & ".html")
	Sleep(20)
	FileWrite(@ScriptDir & "\data\" & $brief & "\" & $brief & ".html", $html)
	_searchUnreferredFiles($html, $brief)
EndFunc

Func createIndexPage($brief)
	FileDelete(@ScriptDir & "\Editor\editor.html")
	Sleep(10)
	Local $file = FileOpen(@ScriptDir & "\Editor\editor.html", 17)
	Local $html = _
		'<!doctype html public "-//w3c//dtd html 4.0 transitional//en">' & @CRLF & _
		'<html>' & @CRLF & _
		'<head>' & @CRLF & _
		'<meta http-equiv="content-type" content="text/html; charset=utf-8">' & @CRLF & _
		'<title>Editor</title>' & @CRLF & _
		'</head>' & @CRLF & _
		'<body>' & @CRLF & _
		'<form name="edit_area" method="post" onsubmit="javascript:KindSubmit();">' & @CRLF & _
		'<input type="hidden" name="source_code" value="">' & @CRLF & _
		'<input type="hidden" name="save_button" value="Save" onclick="javascript:KindSubmit();">' & @CRLF & _
		'<input type="hidden" name="content" value=' & @CRLF
	FileWrite($file, $html)
	FileWrite($file, StringToBinary(getBody($brief) & @CRLF, 4))
	$html = _
		'>' & @CRLF & _
		'<script type="text/javascript" src="./KindEditor.js"></script>' & @CRLF & _
		'<script type="text/javascript">' & @CRLF & _
		'var editor = new KindEditor("editor");' & @CRLF & _
		'editor.hiddenName = "content";' & @CRLF & _
		'editor.skinPath = "./skins/fck/";' & @CRLF & _
		'editor.iconPath = "./icons/";' & @CRLF & _
		'editor.cssPath = "./common.css";' & @CRLF & _
		'editor.editorWidth = "840px";' & @CRLF & _
		'editor.editorHeight = "530px";' & @CRLF & _
		'editor.show();' & @CRLF & _
		'function KindSubmit() {' & @CRLF & _
		'	editor.data();' & @CRLF & _
		'}' & @CRLF & _
		'</script>' & @CRLF & _
		'</form>' & @CRLF & _
		'</body>' & @CRLF & _
		'</html>' & @CRLF
	FileWrite($file, $html)
	FileClose($file)
	Return @ScriptDir & "\Editor\editor.html"
EndFunc

Func getBody($brief)
	Local $html = FileRead(@ScriptDir & "\data\" & $brief & "\" & $brief & ".html")
	If @error Then $html = $brief
	$html = StringReplace($html, "'", "&#39;")
	Local $n = StringInStr($html, "<body")
	If $n <> 0 Then
		$n = StringInStr($html, ">", 0, 1, $n + 5) + 1
	EndIf
	If $n == 0 Then $n = 1
	Local $m = StringInStr($html, "</body")
	If $m == 0 Then $m = StringLen($html)
	$html = StringStripWS(StringMid($html, $n, $m - $n), 3)
	$html = _replaceImagePath($html, $brief)
	$html = StringReplace($html, "<", "&lt;")
	$html = StringReplace($html, ">", "&gt;")
	Return "'" & $html & "'"
EndFunc

Func _replaceImagePath($html, $brief)
	Local $n = StringInStr($html, '<img'), $m, $file, $desFile
	While $n <> 0
		$n = StringInStr($html, 'src="', 0, 1, $n)
		If $n == 0 Then
			$n = StringInStr($html, '<img', 0, 1, $n + 1)
		EndIf
		$n = $n + 5
		$m = StringInStr($html, '"', 0, 1, $n)
		$file = StringMid($html, $n + 2, $m - $n)
		$html = StringReplace($html, ".\" & $file, _
			StringReplace(@ScriptDir & "\data\" & $brief & "\" & $file, "\", "/"), 1)
		$n = StringInStr($html, '<img', 0, 1, $n)
	WEnd
	Return $html
EndFunc

Func _searchUnreferredFiles($html, $brief)
	Local $search = FileFindFirstFile(@ScriptDir & "\data\" & $brief & "\*.*")
	If $search = -1 Then
		Return
	EndIf
	Local $file
	While 1
		$file = FileFindNextFile($search) 
		If @error Then ExitLoop
		If StringLower($file) == StringLower($brief & ".html") Then ContinueLoop
		If Not StringInStr($html, $file) Then
			FileDelete(@ScriptDir & "\data\" & $brief & "\" & $file)
		EndIf
	WEnd
	FileClose($search)
EndFunc

Func _createUniqueFileName($file)
	Local $tmp, $ext
	_PathSplit($file, $tmp, $tmp, $tmp, $ext)
	Return _DateDiff( 's',"1970/01/01 00:00:00",_NowCalc()) & "_" & Random(0, 200000, 1) & $ext
EndFunc

Func _getBriefFromUrl($url = "")
	If $url == "" Then $url = _IEPropertyGet($obj_IE, "locationurl")
	Local $tmp, $fn, $i
	_PathSplit($url, $tmp, $tmp, $fn, $tmp)
	For $i = 1 To $data[0]
		$fn = StringReplace($fn, "%20", " ")
		If $data[$i] == $fn Then Return StringReplace($fn, "%20", " ")
	Next
	Return ""
EndFunc

Func getLevel($n = 0)
	Switch $n
		Case 0 To 10
			Return "婴儿 (0 ~ 10)"
	Case 11 To 30
			Return "幼儿小班 (11 ~ 30)"
	Case 31 To 60
			Return "幼儿中班 (31 ~ 60)"
	Case 61 To 100
			Return "幼儿大班 (61 ~ 100)"
	Case 101 To 150
			Return "学前班 (101 ~ 150)"
	Case 151 To 210
			Return "小学生 (151 ~ 210)"
	Case 211 To 280
			Return "初中生 (211 ~ 280)"
	Case 281 To 360
			Return "高中生 (281 ~ 360)"
	Case 361 To 450
			Return "大学生 (361 ~ 450)"
	Case 451 To 550
			Return "硕士生 (451 ~ 550)"
	Case 551 To 650
			Return "博士生 (551 ~ 650)"
	Case 651 To 750
			Return "博士后 (651 ~ 750)"
	Case 751 To 950
			Return "教授 (751 ~ 950)"
	Case 951 To 1150
			Return "博士生导师 (951 ~ 1150)"
	Case 1151 To 1350
			Return "院士 (1151 ~ 1350)"
	Case 1351 To 1550
			Return "双料院士 (1351 ~ 1550)"
	Case 1551 To 1750
			Return "幼儿爱因斯坦 (1551 ~ 1750)"
	Case 1751 To 1950
			Return "青年爱因斯坦 (1751 ~ 1950)"
	Case 1951 To 2150
			Return "中年爱因斯坦 (1951 ~ 2150)"
	Case 2151 To 2350
			Return "老年爱因斯坦 (2151 ~ 2350)"
	Case 2351 To 3550
			Return "学习机器 (2351 ~ 3550)"
	Case 3551 To 5500
			Return "继续学习吧，已经不需要用这样的方式激发你的学习热情了..."
	Case Else
			Return "未知"
	EndSwitch
EndFunc

Func _containsImages($brief)
	Local $path = @ScriptDir & "\data\" & $brief
	Local $search = FileFindFirstFile($path & "\*.*")
	If $search == -1 Then Return False
	Local $file, $tmp, $ext
	While 1
		$file = FileFindNextFile($search) 
		If @error Then ExitLoop
		_PathSplit($file, $tmp, $tmp, $tmp, $ext)
		$ext = StringLower($ext)
		If  $ext == ".jpg"  Or _
			$ext == ".jpeg" Or _
			$ext == ".jpe"  Or _
			$ext == ".jpif" Or _
			$ext == ".gif"  Or _
			$ext == ".tif"  Or _
			$ext == ".tiff" Or _
			$ext == ".png"  Or _
			$ext == ".ico"  Or _
			$ext == ".bmp"  Then
			Return True
		EndIf
	WEnd
	FileClose($search)
	Return False
EndFunc






