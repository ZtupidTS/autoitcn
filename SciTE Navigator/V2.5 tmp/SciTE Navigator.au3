#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#AutoIt3Wrapper_Icon = .\images\SciTE.ico

#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <GuiButton.au3>
#include <GuiComboBox.au3>
#include <GuiEdit.au3>
#include <Array.au3>
#include <File.au3>
#include "Common.au3"

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

Global $g_scitePid = WinGetProcess($g_hWndSciTE)
Global $g_updated = True
Global $g_sortType = IniRead($CONF, "main", "sort", 2)
Global $g_stkBack[1]
Global $g_stkForward[1]
; $g_lastPos[n][0] : start index
; $g_lastPos[n][1] : end index
; $g_lastPos[n][2] : file name
Global $g_lastPos[3]

; $g_functions[n][0] : function name
; $g_functions[n][1] : start index
; $g_functions[n][2] : end index
Global $g_functions[3000][3] = [[0, 0, 0]]
Global $g_functionsBak
; $g_includes[n][0] : include name
; $g_includes[n][1] : start index
; $g_includes[n][2] : end index
Global $g_includes[200][3] = [[0, 0, 0]]
Global $g_includesBak
#EndRegion global varibals


$g_editingFile = _getCurFilePath()
_setLayout()
While True
	Sleep(1000)
WEnd



Func _setLayout()
;~ 	$gui_main = GUICreate($APP_NAME, 446, 22, 345, 2, $WS_POPUP)
	$gui_main = GUICreate($APP_NAME, 446, 22, 791, 2, $WS_POPUP)
	GUISetBkColor(0xff0000)
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
;~ 	GUICtrlSetOnEvent(-1, "_showSearchList")
	GUICtrlSetTip(-1, "List search result.")
	$btn_searchPre = GUICtrlCreateButton("&P", 297, 1, 20, 20, $BS_ICON)
	_GUICtrlButton_SetImage($btn_searchPre, @ScriptDir & "\images\searchPrevious.ico")
;~ 	GUICtrlSetOnEvent(-1, "_searchPrevious")
	GUICtrlSetTip(-1, "Jump to the previous matched position.")
	$btn_searchNext = GUICtrlCreateButton("&N", 319, 1, 20, 20, $BS_ICON)
	_GUICtrlButton_SetImage($btn_searchNext, @ScriptDir & "\images\searchNext.ico")
;~ 	GUICtrlSetOnEvent(-1, "_searchNext")
	GUICtrlSetTip(-1, "Jump to the next matched position.")
	_createSeparator(342)
	$btn_back = GUICtrlCreateButton("<-", 350, 1, 20, 20, $BS_ICON)
	_GUICtrlButton_SetImage($btn_back, @ScriptDir & "\images\left.ico")
;~ 	GUICtrlSetOnEvent(-1, "_jumpBackClicked")
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Jump to the last search position. (Alt+Left)")
	$btn_forward = GUICtrlCreateButton("->", 372, 1, 20, 20, $BS_ICON)
	_GUICtrlButton_SetImage($btn_forward, @ScriptDir & "\images\right.ico")
;~ 	GUICtrlSetOnEvent(-1, "_jumpForwardClicked")
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Jump to the next search position. (Alt+Right)")
	_createSeparator(395)
	$btn_about = GUICtrlCreateButton("", 403, 1, 20, 20, $BS_ICON)
	GUICtrlSetTip(-1, "About this tool.")
	_GUICtrlButton_SetImage($btn_about, @ScriptDir & "\images\info.ico")
;~ 	GUICtrlSetOnEvent(-1, "_about")
	$btn_exit = GUICtrlCreateButton("&X", 425, 1, 20, 20, $BS_ICON)
	_GUICtrlButton_SetImage($btn_exit, "shell32.dll", 27)
	GUICtrlSetTip(-1, "Close.")
;~ 	GUICtrlSetOnEvent(-1, "_exit")
	
	_createContextMenu($g_sortType)
	_setHotkeys()
	GUIRegisterMsg($WM_COMMAND, "_comboBoxCommand")
	
	Local $dm_handleEnter = GUICtrlCreateDummy()
;~ 	GUICtrlSetOnEvent($dm_handleEnter, "_handleEnter")
	Local $dm_handleEsc = GUICtrlCreateDummy()
;~ 	GUICtrlSetOnEvent($dm_handleEsc, "_handleEsc")
	Local $hk[2][2] = [["{enter}", $dm_handleEnter], ["{esc}", $dm_handleEsc]]
	GUISetAccelerators($hk)
	
	GUISetState(@SW_SHOW, $gui_main)
	WinActivate($g_hWndSciTE)
	
	_analyse($g_editingFile)
	_sortAndUpdateComboBox($g_sortType)
EndFunc   ;==>_setLayout

Func _showMenuSort()
	_showMenu($gui_main, $btn_sort, $ctx_sort)
EndFunc   ;==>_showMenuSort

Func _createContextMenu($sortType)
	Local $dm_sort = GUICtrlCreateDummy()
	$ctx_sort = GUICtrlCreateContextMenu($dm_sort)
	$mi_dictAscending = GUICtrlCreateMenuItem("&Ascending", $ctx_sort)
;~ 	GUICtrlSetOnEvent(-1, "_sortAscending")
	$mi_dictDescending = GUICtrlCreateMenuItem("&Descending", $ctx_sort)
;~ 	GUICtrlSetOnEvent(-1, "_sortDescending")
	$mi_original = GUICtrlCreateMenuItem("&Original", $ctx_sort)
;~ 	GUICtrlSetOnEvent(-1, "_sortOriginal")
	$mi_originalReverse = GUICtrlCreateMenuItem("&Reverse Original", $ctx_sort)
;~ 	GUICtrlSetOnEvent(-1, "_sortOriginalReverse")
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

Func _setHotkeys()
;~ 	HotKeySet($HK_JUMP_BACK, "_jumpBack")
;~ 	HotKeySet($HK_JUMP_FORWARD, "_jumpForward")
;~ 	HotKeySet($HK_SEARCH_SELETECTED, "_searchSelected")
;~ 	HotKeySet($HK_LIST_SEARCH, "_showSearchList")
	
;~ 	HotKeySet($HK_TOGGLE_FOLD, "_toggleFold")
;~ 	HotKeySet($HK_TOGGLE_CURRENT_FOLD, "_toggleCurrentFold")
;~ 	HotKeySet($HK_CTRL_J, "_jump2FuncProd")
EndFunc   ;==>_setHotkeys

Func _analyse($file)
	If Not FileExists($file) Then Return
	Local $fileRecord[1]
	_FileReadToArray($file, $fileRecord)
	$g_functions[0][0] = 0
	$g_includes[0][0] = 0
	Local $i, $line, $idx
	For $i = 1 To $fileRecord[0]
		$line = StringStripWS($fileRecord[$i], 2)
		$idx = _lookforFirstVisiblePos($line)
		If $idx == -1 Then ContinueLoop
		If StringLower(StringMid($line, $idx, 4)) == "func" And _
				Not _isCharVisible(StringMid($line, $idx + 4, 1)) Then
			$idx = _lookforFirstVisiblePos($line, $idx + 5)
			$g_functions[0][0] += 1
			$g_functions[$g_functions[0][0]][0] = ""
			$g_functions[$g_functions[0][0]][1] = 0
;~ 			ConsoleWrite($i & " line idx: " & _GUICtrlEdit_LineIndex($g_hWndEdit, $i) & ", $idx=" & $idx & @CRLF)
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
				$line = StringStripWS($fileRecord[$i], 2)
				$idx = _lookforFirstVisiblePos($line)
			Until $lastChar <> '_'
			$g_functions[$g_functions[0][0]][2] = 0
		ElseIf StringLower(StringMid($line, $idx, 8)) == "#include" And _
				Not _isCharVisible(StringMid($line, $idx + 8, 1)) Then
			$idx = _lookforFirstVisiblePos($line, $idx + 9)
			$g_includes[0][0] += 1
			$g_includes[$g_includes[0][0]][0] = StringMid($line, $idx, StringLen($line))
			$g_includes[$g_includes[0][0]][1] = _GUICtrlEdit_LineIndex($g_hWndEdit, $i) + $idx
			$g_includes[$g_includes[0][0]][2] = $g_includes[$g_includes[0][0]][1] + 3
		EndIf
	Next
	$g_functionsBak = $g_functions
	$g_includesBak = $g_includes
EndFunc   ;==>_analyse

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

Func _comboBoxCommand($hWnd, $iMsg, $iwParam, $ilParam)
	#forceref $hWnd, $iMsg
	Local $hWndFrom, $iCode, $sIdx, $eIdx
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
					$sIdx = $g_functions[$sel + 1][1]
					$eIdx = $g_functions[$sel + 1][2]
					Local $pos[3] = [$sIdx, $eIdx, $g_editingFile]
				Else
					$sIdx = $g_includes[$sel - $g_functions[0][0]][1]
					$eIdx = $g_includes[$sel - $g_functions[0][0]][2]
					Local $pos[3] = [$sIdx, $eIdx, $g_editingFile]
				EndIf
				_goto($sIdx, $eIdx, $g_editingFile)
				_addPos2BackStack($pos)
				
		;~Case $CBN_SETFOCUS
		;~ _GUICtrlComboBox_SetEditSel($cbb_func_handle, 0, -1)
		EndSwitch
;~ 	ElseIf $hWndFrom == $LS_ls_resultHandle Then
;~ 		Switch $iCode
;~ 			Case $LBN_DBLCLK
;~ 				LS_searchListClicked()
;~ 		EndSwitch
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc   ;==>_comboBoxCommand

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
	_addPos2BackStack($pos)
;~ 	ConsoleWrite("added" & @CRLF)
EndFunc











