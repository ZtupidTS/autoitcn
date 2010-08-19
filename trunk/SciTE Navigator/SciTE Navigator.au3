#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#AutoIt3Wrapper_Icon = .\images\SciTE.ico
#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <GuiButton.au3>
#include <GuiComboBox.au3>
#include <Array.au3>
#include <File.au3>
#include "Common.au3"
#include "ListSearchResult.au3"
#NoTrayIcon

#Region global varibals
Global $gui_main
Global $cbb_func
Global $cbb_func_handle
Global $cbb_search
Global $cbb_search_handle
Global $btn_sort
Global $btn_searchList
Global $btn_searchNext
Global $btn_searchPre
Global $btn_back
Global $btn_forward
Global $btn_about
Global $btn_exit

Global $ctx_sort
Global $mi_dictAscending
Global $mi_dictDescending
Global $mi_original
Global $mi_originalReverse

;~ Global $g_counter = 0
Global $g_scitePid = WinGetProcess($g_hWndSciTE)
;~ Global $g_searchKeyword = ""
Global $g_updated = True
Global $g_sortType = IniRead($CONF, "main", "sort", 2)
Global $g_stkBack[1]
Global $g_stkForward[1]
Global $g_lastPos[3]

; $g_functions[n][0] : function name
; $g_functions[n][1] : line number
; $g_functions[n][2] : column number
Global $g_functions[3000][3] = [[0, 0, 0]]
Global $g_functionsBak
; $g_includes[n][0] : include name
; $g_includes[n][1] : line number
; $g_includes[n][2] : column number
Global $g_includes[200][3] = [[0, 0, 0]]
Global $g_includesBak
#EndRegion global varibals
;

$g_editingFile = _getCurFilePath()
_setLayout()
_createShortcut()
AdlibEnable("_check", $INTERVAL_BUSY)
While True
	Sleep(1000)
WEnd

Func _setLayout()
	$gui_main = GUICreate($APP_NAME, 446, 22, 345, 2, $WS_POPUP)
;~ 	$gui_main = GUICreate($APP_NAME, 446, 22, 811, 2, $WS_POPUP)
;~ 	GUISetBkColor(0xff0000)
	DllCall("user32.dll", "int", "SetParent", "hwnd", $gui_main, "hwnd", $g_hWndSciTE)
	_createSeparator(0)
	$cbb_func = GUICtrlCreateCombo("", 8, 1, 150)
	GUICtrlSetTip(-1, "Type the function name and press ENTER to jump to it." & @CRLF & _
						"Press ESC to clear the text in the editor.")
	$cbb_func_handle = GUICtrlGetHandle(-1)
	_GUICtrlComboBox_SetDroppedWidth($cbb_func_handle, 350)
	$btn_sort = GUICtrlCreateButton("&S", 162, 1, 20, 20, $BS_ICON)
	GUICtrlSetTip(-1, "Sort the functions listed in the combobox.")
	GUICtrlSetOnEvent(-1, "_showMenuSort")
	_createSeparator(185)
	$cbb_search = GUICtrlCreateCombo("", 193, 1, 80)
	$cbb_search_handle = GUICtrlGetHandle(-1)
	_GUICtrlComboBox_SetDroppedWidth($cbb_search_handle, 350)
	GUICtrlSetTip(-1, "Type or select a keyword and press ENTER to search." & @CRLF & _
						"Press ESC to clear the text in the editor.")
	$btn_searchList = GUICtrlCreateButton("&L", 275, 1, 20, 20, $BS_ICON)
	_GUICtrlButton_SetImage($btn_searchList, @ScriptDir & "\images\search.ico")
	GUICtrlSetOnEvent(-1, "_showSearchList")
	GUICtrlSetTip(-1, "List search result.")
	$btn_searchPre = GUICtrlCreateButton("&P", 297, 1, 20, 20, $BS_ICON)
	_GUICtrlButton_SetImage($btn_searchPre, @ScriptDir & "\images\searchPrevious.ico")
	GUICtrlSetOnEvent(-1, "_searchPrevious")
	GUICtrlSetTip(-1, "Jump to the previous matched position.")
	$btn_searchNext = GUICtrlCreateButton("&N", 319, 1, 20, 20, $BS_ICON)
	_GUICtrlButton_SetImage($btn_searchNext, @ScriptDir & "\images\searchNext.ico")
	GUICtrlSetOnEvent(-1, "_searchNext")
	GUICtrlSetTip(-1, "Jump to the next matched position.")
	_createSeparator(342)
	$btn_back = GUICtrlCreateButton("<-", 350, 1, 20, 20, $BS_ICON)
	_GUICtrlButton_SetImage($btn_back, @ScriptDir & "\images\left.ico")
	GUICtrlSetOnEvent(-1, "_jumpBackClicked")
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Jump to the last search position. (Alt+Left)")
	$btn_forward = GUICtrlCreateButton("->", 372, 1, 20, 20, $BS_ICON)
	_GUICtrlButton_SetImage($btn_forward, @ScriptDir & "\images\right.ico")
	GUICtrlSetOnEvent(-1, "_jumpForwardClicked")
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Jump to the next search position. (Alt+Right)")
	_createSeparator(395)
	$btn_about = GUICtrlCreateButton("", 403, 1, 20, 20, $BS_ICON)
	GUICtrlSetTip(-1, "About this tool.")
	_GUICtrlButton_SetImage($btn_about, @ScriptDir & "\images\info.ico")
	GUICtrlSetOnEvent(-1, "_about")
	$btn_exit = GUICtrlCreateButton("&X", 425, 1, 20, 20, $BS_ICON)
	_GUICtrlButton_SetImage($btn_exit, "shell32.dll", 27)
	GUICtrlSetTip(-1, "Close.")
	GUICtrlSetOnEvent(-1, "_exit")
	
	_createContextMenu($g_sortType)
	_setHotkeys()
	GUIRegisterMsg($WM_COMMAND, "_comboBoxCommand")
	
	Local $dm_handleEnter = GUICtrlCreateDummy()
	GUICtrlSetOnEvent($dm_handleEnter, "_handleEnter")
	Local $dm_handleEsc = GUICtrlCreateDummy()
	GUICtrlSetOnEvent($dm_handleEsc, "_handleEsc")
	Local $hk[2][2] = [["{enter}", $dm_handleEnter], ["{esc}", $dm_handleEsc]]
	GUISetAccelerators($hk)
	
	GUISetState(@SW_SHOW, $gui_main)
	WinActivate($g_hWndSciTE)
	
;~ 	GUISetOnEvent($GUI_EVENT_MINIMIZE, "_checkTest", $g_hWndSciTE)
	_analyse($g_editingFile)
	_sortAndUpdateComboBox($g_sortType)
EndFunc   ;==>_setLayout

Func _setHotkeys()
	HotKeySet($HK_JUMP_BACK, "_jumpBack")
	HotKeySet($HK_JUMP_FORWARD, "_jumpForward")
	HotKeySet($HK_SEARCH_SELETECTED, "_searchSelected")
	HotKeySet($HK_LIST_SEARCH, "_showSearchList")
	
	HotKeySet($HK_TOGGLE_FOLD, "_toggleFold")
	HotKeySet($HK_TOGGLE_CURRENT_FOLD, "_toggleCurrentFold")
	HotKeySet($HK_CTRL_J, "_jump2FuncProd")
EndFunc   ;==>_setHotkeys

Func _showMenuSort()
	_showMenu($gui_main, $btn_sort, $ctx_sort)
EndFunc   ;==>_showMenuSort

Func _createContextMenu($sortType)
	Local $dm_sort = GUICtrlCreateDummy()
	$ctx_sort = GUICtrlCreateContextMenu($dm_sort)
	$mi_dictAscending = GUICtrlCreateMenuItem("&Ascending", $ctx_sort)
	GUICtrlSetOnEvent(-1, "_sortAscending")
	$mi_dictDescending = GUICtrlCreateMenuItem("&Descending", $ctx_sort)
	GUICtrlSetOnEvent(-1, "_sortDescending")
	$mi_original = GUICtrlCreateMenuItem("&Original", $ctx_sort)
	GUICtrlSetOnEvent(-1, "_sortOriginal")
	$mi_originalReverse = GUICtrlCreateMenuItem("&Reverse Original", $ctx_sort)
	GUICtrlSetOnEvent(-1, "_sortOriginalReverse")
	Switch $sortType
		Case 0
			GUICtrlSetState($mi_dictAscending, $GUI_CHECKED)
			_GUICtrlButton_SetImage($btn_sort, @ScriptDir & "\images\sortAscending.ico")
		Case 1
			GUICtrlSetState($mi_dictDescending, $GUI_CHECKED)
			_GUICtrlButton_SetImage($btn_sort, @ScriptDir & "\images\sortDescending.ico")
		Case 2
			GUICtrlSetState($mi_original, $GUI_CHECKED)
			_GUICtrlButton_SetImage($btn_sort, @ScriptDir & "\images\original.ico")
		Case 3
			GUICtrlSetState($mi_originalReverse, $GUI_CHECKED)
			_GUICtrlButton_SetImage($btn_sort, @ScriptDir & "\images\original_reverse.ico")
	EndSwitch
EndFunc   ;==>_createContextMenu

Func _sortAscending()
	If BitAND(GUICtrlRead($mi_dictAscending), $GUI_CHECKED) == $GUI_CHECKED Then
		Return
	EndIf
	$g_sortType = $ST_ASCENDING
	_setMenuItemStat($mi_dictAscending, $GUI_CHECKED)
	_sortAndUpdateComboBox($ST_ASCENDING)
	_GUICtrlButton_SetImage($btn_sort, @ScriptDir & "\images\sortAscending.ico")
	WinActivate($g_hWndSciTE) ;The title starts with the editing file path
	IniWrite($CONF, "main", "sort", $g_sortType)
EndFunc   ;==>_sortAscending

Func _sortDescending()
	If BitAND(GUICtrlRead($mi_dictDescending), $GUI_CHECKED) == $GUI_CHECKED Then
		Return
	EndIf
	$g_sortType = $ST_DESCENDING
	_setMenuItemStat($mi_dictDescending, $GUI_CHECKED)
	_sortAndUpdateComboBox($ST_DESCENDING)
	_GUICtrlButton_SetImage($btn_sort, @ScriptDir & "\images\sortDescending.ico")
	WinActivate($g_hWndSciTE) ;The title starts with the editing file path
	IniWrite($CONF, "main", "sort", $g_sortType)
EndFunc   ;==>_sortDescending

Func _sortOriginal()
	If BitAND(GUICtrlRead($mi_original), $GUI_CHECKED) == $GUI_CHECKED Then
		Return
	EndIf
	$g_sortType = $ST_ORIGINAL
	_setMenuItemStat($mi_original, $GUI_CHECKED)
	_sortAndUpdateComboBox($ST_ORIGINAL)
	_GUICtrlButton_SetImage($btn_sort, @ScriptDir & "\images\original.ico")
	WinActivate($g_hWndSciTE) ;The title starts with the editing file path
	IniWrite($CONF, "main", "sort", $g_sortType)
EndFunc   ;==>_sortOriginal

Func _sortOriginalReverse()
	If BitAND(GUICtrlRead($mi_originalReverse), $GUI_CHECKED) == $GUI_CHECKED Then
		Return
	EndIf
	$g_sortType = $ST_ORIGINAL_REVERSE
	_setMenuItemStat($mi_originalReverse, $GUI_CHECKED)
	_sortAndUpdateComboBox($ST_ORIGINAL_REVERSE)
	_GUICtrlButton_SetImage($btn_sort, @ScriptDir & "\images\original_reverse.ico")
	WinActivate($g_hWndSciTE) ;The title starts with the editing file path
	IniWrite($CONF, "main", "sort", $g_sortType)
EndFunc   ;==>_sortOriginalReverse

Func _sortAndUpdateComboBox($sortType)
	$g_functions = $g_functionsBak
	$g_includes = $g_includesBak
	Switch $sortType
		Case $ST_ASCENDING
			_ArraySort($g_functions, $ST_ASCENDING, 1, $g_functions[0][0])
			_ArraySort($g_includes, $ST_ASCENDING, 1, $g_includes[0][0])
		Case $ST_DESCENDING
			_ArraySort($g_functions, $ST_DESCENDING, 1, $g_functions[0][0])
			_ArraySort($g_includes, $ST_DESCENDING, 1, $g_includes[0][0])
		Case $ST_ORIGINAL
			; do nothing
		Case $ST_ORIGINAL_REVERSE
			_reverseArray($g_functions)
			_reverseArray($g_includes)
	EndSwitch
	
	_GUICtrlComboBox_BeginUpdate($cbb_func_handle)
	_GUICtrlComboBox_ResetContent($cbb_func_handle)
	For $i = 1 To $g_functions[0][0]
		_GUICtrlComboBox_AddString($cbb_func_handle, $g_functions[$i][0])
	Next
	_GUICtrlComboBox_AddString($cbb_func_handle, "------ < include > ------- < include > -------")
	For $i = 1 To $g_includes[0][0]
		_GUICtrlComboBox_AddString($cbb_func_handle, $g_includes[$i][0])
	Next
	_GUICtrlComboBox_EndUpdate($cbb_func_handle)
EndFunc   ;==>_sortAndUpdateComboBox

Func _setMenuItemStat($mi, $stat)
	Local $stat2
	If $stat == $GUI_CHECKED Then
		$stat2 = $GUI_UNCHECKED
	Else
		$stat2 = $GUI_CHECKED
	EndIf
	GUICtrlSetState($mi_dictAscending, $stat2)
	GUICtrlSetState($mi_dictDescending, $stat2)
	GUICtrlSetState($mi_original, $stat2)
	GUICtrlSetState($mi_originalReverse, $stat2)
	GUICtrlSetState($mi, $stat)
EndFunc   ;==>_setMenuItemStat

Func _handleEsc()
	Local $ctrlNN = ControlGetFocus($gui_main)
	If $ctrlNN == "Edit1" Then
		_GUICtrlComboBox_SetEditText($cbb_func_handle, "")
	ElseIf $ctrlNN == "Edit2" Then
		_GUICtrlComboBox_SetEditText($cbb_search_handle, "")
	EndIf
EndFunc

Func _handleEnter()
	Local $ctrlNN = ControlGetFocus($gui_main)
	If $ctrlNN == "Edit1" Then
		_typeGotoFunc()
	ElseIf $ctrlNN == "Edit2" Then
		_showSearchList()
	EndIf
EndFunc   ;==>_handleEnter

Func _typeGotoFunc()
	Local $selText = _GUICtrlComboBox_GetEditText($cbb_func_handle)
	If $selText == "" Then Return
	Local $pos[3]
	For $i = 1 To $g_functions[0][0]
		If Not StringInStr($g_functions[$i][0], $selText) Then ContinueLoop
		_addCurPos2BackStack()
		_goto($g_functions[$i][1])
		$pos[0] = $g_functions[$i][1]
		$pos[1] = $g_functions[$i][2]
		$pos[2] = $g_editingFile
		_addPos2BackStack($pos)
		Return
	Next
	For $i = 1 To $g_includes[0][0]
		If Not StringInStr($g_includes[$i][0], $selText) Then ContinueLoop
		_addCurPos2BackStack()
		_goto($g_includes[$i][1])
		$pos[0] = $g_includes[$i][1]
		$pos[1] = $g_includes[$i][2]
		$pos[2] = $g_editingFile
		_addPos2BackStack($pos)
		Return
	Next
EndFunc   ;==>_typeGotoFunc

Func _analyse($file)
	If Not FileExists($file) Then Return
	_FileReadToArray($file, $g_fileRecord)
	$g_functions[0][0] = 0
	$g_includes[0][0] = 0
	Local $i, $line, $idx
	For $i = 1 To $g_fileRecord[0]
		$line = StringStripWS($g_fileRecord[$i], 2)
		$idx = _lookforFirstVisiblePos($line)
		If $idx == -1 Then ContinueLoop
		If StringLower(StringMid($line, $idx, 4)) == "func" And _
				Not _isCharVisible(StringMid($line, $idx + 4, 1)) Then
			$idx = _lookforFirstVisiblePos($line, $idx + 5)
			$g_functions[0][0] += 1
			$g_functions[$g_functions[0][0]][0] = ""
			$g_functions[$g_functions[0][0]][1] = $i
			$g_functions[$g_functions[0][0]][2] = $idx
			Local $lastChar
			Do
				$lastChar = StringRight($line, 1)
				If $lastChar == '_' Then
					$g_functions[$g_functions[0][0]][0] = $g_functions[$g_functions[0][0]][0] & _
							StringMid($line, $idx, StringLen($line) - $idx)
				Else
					$g_functions[$g_functions[0][0]][0] = $g_functions[$g_functions[0][0]][0] & _
							StringMid($line, $idx, StringLen($line) - $idx + 1)
				EndIf
				$i += 1
				$line = StringStripWS($g_fileRecord[$i], 2)
				$idx = _lookforFirstVisiblePos($line)
			Until $lastChar <> '_'
		ElseIf StringLower(StringMid($line, $idx, 8)) == "#include" And _
				Not _isCharVisible(StringMid($line, $idx + 8, 1)) Then
			$idx = _lookforFirstVisiblePos($line, $idx + 9)
			$g_includes[0][0] += 1
			$g_includes[$g_includes[0][0]][0] = StringMid($line, $idx, StringLen($line))
			$g_includes[$g_includes[0][0]][1] = $i
			$g_includes[$g_includes[0][0]][2] = $idx
		EndIf
	Next
	$g_functionsBak = $g_functions
	$g_includesBak = $g_includes
EndFunc   ;==>_analyse

Func _check()
;~ 	If Mod($g_counter, 2) Then
	_checkFileHasChanged()
	_checkEditorStatus()
;~ 	EndIf
;~ 	_checkTest()
;~ 	$g_counter += 1
EndFunc   ;==>_check

; saved or change tab
Func _checkFileHasChanged()
	Local $file = _getCurFilePath()
	If $g_editingFile == $file Then
		Local $title = WinGetTitle($g_hWndSciTE)
		If StringInStr($title, "*") <> 0 Then
			$g_updated = False
			Return
		EndIf
		If Not $g_updated Then
			$g_updated = True
			_analyse($file)
			_sortAndUpdateComboBox($g_sortType)
		EndIf
	Else
		$g_editingFile = $file
		_analyse($file)
		_sortAndUpdateComboBox($g_sortType)
	EndIf
EndFunc   ;==>_checkFileHasChanged

Func _checkEditorStatus()
	If ProcessExists($g_scitePid) Then Return
	_exit()
EndFunc   ;==>_checkEditorStatus

Func _checkTest()
	MsgBox(0, '', "minimized" & @CRLF)
#CS 	Local $stat = WinGetState($g_hWndSciTE)
   	If BitAND($stat, 8) == 8 Then
   ;~ 		AdlibDisable()
   ;~ 		AdlibEnable("_check", $INTERVAL_BUSY)
   		ConsoleWrite("active" &  @CRLF)
   	Else
   ;~ 		AdlibDisable()
   ;~ 		AdlibEnable("_check", $INTERVAL_IDLE)
   		ConsoleWrite("diactive" & @CRLF)
   	EndIf
#CE
EndFunc

Func _comboBoxCommand($hWnd, $iMsg, $iwParam, $ilParam)
	#forceref $hWnd, $iMsg
	Local $hWndFrom, $iCode
	$hWndFrom = $ilParam
	$iCode = BitShift($iwParam, 16)
	If $hWndFrom == $cbb_func_handle Then
		Switch $iCode
			Case $CBN_EDITCHANGE
				_GUICtrlComboBox_AutoComplete($cbb_func_handle)
				
			Case $CBN_SELENDOK
				Local $sel = _GUICtrlComboBox_GetCurSel($cbb_func_handle)
				If $sel == $g_functions[0][0] Then Return
				_addCurPos2BackStack()
				If $sel < $g_functions[0][0] Then
					_goto($g_functions[$sel + 1][1])
					Local $pos[3] = [$g_functions[$sel + 1][1], 0, $g_editingFile]
				Else
					_goto($g_includes[$sel - $g_functions[0][0]][1])
					Local $pos[3] = [$g_includes[$sel - $g_functions[0][0]][1], 0, $g_editingFile]
				EndIf
				_addPos2BackStack($pos)
				
			Case $CBN_SETFOCUS
				_GUICtrlComboBox_SetEditText($cbb_func_handle, "")
		EndSwitch
		
	ElseIf $hWndFrom == $cbb_search_handle Then
		Switch $iCode
			Case $CBN_SETFOCUS
				_GUICtrlComboBox_SetEditText($cbb_search_handle, "")
		EndSwitch
	
	ElseIf $hWndFrom == $LS_ls_resultHandle Then
		Switch $iCode
			Case $LBN_DBLCLK
				LS_searchListClicked()
		EndSwitch
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc   ;==>_comboBoxCommand

Func _jumpBackClicked()
	If BitAND(GUICtrlGetState($btn_back), $GUI_DISABLE) == $GUI_DISABLE Then Return
	Local $pos = _ArrayPop($g_stkBack)
	If Not IsArray($pos) Then Return
;~ 	GUICtrlSetState($btn_back, $GUI_DISABLE)
	; The title starts with the editing file path
	If $pos[0] == ControlCommand($g_hWndSciTE, "", 350, "GetCurrentLine", "") Then
		ConsoleWrite("fadfa"&@CRLF)
		_ArrayAdd($g_stkForward, $pos)
		GUICtrlSetState($btn_forward, $GUI_ENABLE)
		If UBound($g_stkBack) <= 1 Then
			WinActivate($g_hWndSciTE)
			Return
		EndIf
		$pos = _ArrayPop($g_stkBack)
;~ 		If Not IsArray($pos) Then Return
	EndIf
	_goto($pos[0], $pos[1], $pos[2])
	_ArrayAdd($g_stkForward, $pos)
	GUICtrlSetState($btn_forward, $GUI_ENABLE)
	If UBound($g_stkBack) <= 1 Then
		GUICtrlSetState($btn_back, $GUI_DISABLE)
	Else
		GUICtrlSetState($btn_back, $GUI_ENABLE)
	EndIf
EndFunc   ;==>_jumpBackClicked

Func _jumpBack()
	If Not _isHotkeyValid($HK_JUMP_BACK, "_jumpBack") Then Return
	_jumpBackClicked()
EndFunc   ;==>_jumpBack

Func _jumpForwardClicked()
	If BitAND(GUICtrlGetState($btn_forward), $GUI_DISABLE) == $GUI_DISABLE Then
		Return
	EndIf
	Local $pos = _ArrayPop($g_stkForward)
	If Not IsArray($pos) Then Return
;~ 	GUICtrlSetState($btn_forward, $GUI_DISABLE)
	If $pos[0] == ControlCommand($g_hWndSciTE, "", 350, "GetCurrentLine", "") Then
		_ArrayAdd($g_stkBack, $pos)
		GUICtrlSetState($btn_back, $GUI_ENABLE)
		If UBound($g_stkForward) <= 1 Then
			WinActivate($g_hWndSciTE)
			Return
		EndIf
		$pos = _ArrayPop($g_stkForward)
;~ 		If Not IsArray($pos) Then Return
	EndIf
	_goto($pos[0], $pos[1], $pos[2])
;~ 	GUISetState(@SW_RESTORE, $gui_main)
;~ 	WinActivate($g_hWndSciTE)
	_ArrayAdd($g_stkBack, $pos)
	GUICtrlSetState($btn_back, $GUI_ENABLE)
	If UBound($g_stkForward) <= 1 Then
		GUICtrlSetState($btn_forward, $GUI_DISABLE)
	Else
		GUICtrlSetState($btn_forward, $GUI_ENABLE)
	EndIf
EndFunc   ;==>_jumpForwardClicked

Func _jumpForward()
	If Not _isHotkeyValid($HK_JUMP_FORWARD, "_jumpForward") Then Return
	_jumpForwardClicked()
EndFunc   ;==>_jumpForward

Func _searchSelected()
	If Not _isHotkeyValid($HK_SEARCH_SELETECTED, "_searchSelected") Then Return
	
	_addCurPos2BackStack()
;~ 	Local $text = _getSelectedText()
;~ 	If $text == '' Then
;~ 		WinMenuSelectItem($g_hWndSciTE, "", "&Search", "Find &Next")
;~ 		Return
;~ 	EndIf
;~ 	If $g_searchKeyword == $text Then
;~ 		WinMenuSelectItem($g_hWndSciTE, "", "&Search", "Find &Next")
;~ 	Else
;~ 		RunWait($SCITE_PATH & " -find:" & $text)
;~ 		$g_searchKeyword = $text
;~ 		_add2Combobox($cbb_search_handle, $text)
;~ 	EndIf
	Local $ln = ControlCommand($g_hWndSciTE, "", 350, "GetCurrentLine", "")
	Local $pos[3] = [$ln, 0, $g_editingFile]
	_addPos2BackStack($pos)
EndFunc   ;==>_searchSelected

Func _showSearchList()
	Local $kw = GUICtrlRead($cbb_search)
	If $kw == "" Then $kw = _getSelectedText()
	
	LS_popup($kw)
	If $kw <> "" Then
		_add2Combobox($cbb_search_handle, $kw)
	EndIf
	_GUICtrlComboBox_SetEditText($cbb_search_handle, "")
EndFunc   ;==>_showSearchList

Func _searchNext()
;~ 	WinActivate($g_hWndSciTE)
	Local $text = GUICtrlRead($cbb_search)
	If $text == "" Then $text = _getSelectedText()
	If $text == "" Then Return

	_addCurPos2BackStack()
;~ 	If $g_searchKeyword == $text Then
;~ 		WinMenuSelectItem($g_hWndSciTE, "", "&Search", "Find &Next")
;~ 	Else
;~ 		RunWait($SCITE_PATH & " -find:" & $text)
;~ 		$g_searchKeyword = $text
;~ 	EndIf
	Local $ln = ControlCommand($g_editingFile, "Source", 350, "GetCurrentLine", "")
	Local $pos[3] = [$ln, 0, $g_editingFile]
	_addPos2BackStack($pos)
EndFunc   ;==>_searchNext

Func _searchPrevious()
;~ 	WinActivate($g_hWndSciTE)
	Local $text = GUICtrlRead($cbb_search)
	If $text == "" Then $text = _getSelectedText()
	If $text == "" Then Return

;~ 	If $g_searchKeyword == $text Then
;~ 		WinMenuSelectItem($g_hWndSciTE, "", "&Search", "Find Previou&s")
;~ 	Else
;~ 		RunWait($SCITE_PATH & " -find:" & $text)
;~ 		$g_searchKeyword = $text
;~ 		WinMenuSelectItem($g_hWndSciTE, "", "&Search", "Find Previou&s")
;~ 		WinMenuSelectItem($g_hWndSciTE, "", "&Search", "Find Previou&s")
;~ 	EndIf
EndFunc   ;==>_searchPrevious

Func _addPos2BackStack($pos)
	If Not IsArray($pos) Then Return
	$g_lastPos = $pos
	_ArrayAdd($g_stkBack, $pos)
	Global $g_stkForward[1]
	GUICtrlSetState($btn_back, $GUI_ENABLE)
	GUICtrlSetState($btn_forward, $GUI_DISABLE)
EndFunc   ;==>_addPos2BackStack

Func _addCurPos2BackStack()
	Local $ln = ControlCommand($g_hWndSciTE, "", 350, "GetCurrentLine", "")
	If $g_lastPos[0] == $ln Then Return
	; need to add current position to back stack
	Local $pos[3] = [$ln, 0, $g_editingFile]
;~ 	_addPos2BackStack($pos)
EndFunc

Func _createShortcut()
	If Not @Compiled Then Return
	If StringLower(IniRead($CONF, "main", "installed", "false")) == "true" Then
		Return
	EndIf
	FileDelete(@DesktopCommonDir & "\SciTe.lnk")
	FileDelete(@DesktopDir & "\SciTe.lnk")
	FileDelete(@ProgramsCommonDir & "\AutoIt v3\SciTE\SciTe.lnk")
	FileDelete(@ProgramsDir & "\AutoIt v3\SciTE\SciTe.lnk")
	FileDelete(@ProgramsCommonDir & "\AutoIt v3\SciTe.lnk")
	FileDelete(@ProgramsDir & "\AutoIt v3\SciTe.lnk")
	
	FileCreateShortcut(@ScriptFullPath, _
			@DesktopCommonDir & "\SciTe.lnk", _
			@ScriptDir)
	FileCreateShortcut(@ScriptFullPath, _
			@ProgramsCommonDir & "\AutoIt v3\SciTE\SciTe.lnk", _
			@ScriptDir)
	FileCreateShortcut(@ScriptFullPath, _
			@ProgramsCommonDir & "\AutoIt v3\SciTe.lnk", _
			@ScriptDir)
	IniWrite($CONF, "main", "installed", "true")
	
	MsgBox($MB_INFO_OK, $APP_NAME, "Some shortcuts has been added/replaced, " & @CRLF & _
				"remove them if you don't want this tool anymore." & @CRLF & @CRLF & _
				"They are:" & @CRLF & _
				@DesktopCommonDir & "\SciTe.lnk" & @CRLF & _
				@ProgramsCommonDir & "\AutoIt v3\SciTe.lnk" & @CRLF & _
				@ProgramsCommonDir & "\AutoIt v3\SciTE\SciTe.lnk", Default, $gui_main)
EndFunc   ;==>_createShortcut

Func _about()
	If Not FileExists(@ScriptDir & "\About.exe") Then Return
	Run(@ScriptDir & '\About.exe "' & $VERSION & '" "' & $DATE & '"', @ScriptDir)
EndFunc

Func _exit()
	IniWrite($CONF, "search", "whole_word", GUICtrlRead($LS_cb_wholeWord))
	IniWrite($CONF, "search", "match_case", GUICtrlRead($LS_cb_matchCase))
	IniWrite($CONF, "search", "search_all", GUICtrlRead($LS_rb_all))
	IniWrite($CONF, "search", "no_comment", GUICtrlRead($LS_rb_noCmt))
	Exit
EndFunc   ;==>_exit

#Region hotkeys for SciTE
Func _jump2FuncProd()
;~ 	If Not _isHotkeyValid($HK_CTRL_J, "_jump2FuncProd") Then
;~ 		Return
;~ 	EndIf
;~ 	Local $ln = ControlCommand($g_hWndSciTE, "", 350, "GetCurrentLine", "")
;~ 	Local $pos[3] = [$ln, 0, $g_editingFile]
;~ 	_addPos2BackStack($pos)
;~ 	WinMenuSelectItem($g_hWndSciTE, "", "&Tools", "Jump to Function Prod")
	If WinActive($g_hWndSciTE) Then
		Local $ln = ControlCommand($g_hWndSciTE, "", 350, "GetCurrentLine", "")
		Local $pos[3] = [$ln, 0, $g_editingFile]
		_addPos2BackStack($pos)
	EndIf
	HotKeySet($HK_CTRL_J)
	Send($HK_CTRL_J)
	HotKeySet($HK_CTRL_J, "_jump2FuncProd")
EndFunc   ;==>_jump2FuncProd

Func _toggleFold()
	If Not _isHotkeyValid($HK_TOGGLE_FOLD, "_toggleFold") Then
		Return
	EndIf
	WinMenuSelectItem($g_hWndSciTE, "", "&View", "Toggle &all folds")
EndFunc   ;==>_toggleFold

Func _toggleCurrentFold()
	If Not _isHotkeyValid($HK_TOGGLE_CURRENT_FOLD, "_toggleCurrentFold") Then
		Return
	EndIf
	WinMenuSelectItem($g_hWndSciTE, "", "&View", "Toggle &current fold")
EndFunc   ;==>_toggleCurrentFold
#EndRegion hotkeys for SciTE