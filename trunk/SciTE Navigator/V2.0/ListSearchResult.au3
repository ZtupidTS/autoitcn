

#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <GUIListBox.au3>


Global Const $LS_APP_NAME = "Search Result"

Global $LS_gui_main
Global $LS_btn_goto
Global $LS_btn_clipboard
Global $LS_btn_refresh
Global $LS_btn_close
Global $LS_ls_resultHandle
Global $LS_cb_wholeWord
Global $LS_cb_matchCase
Global $LS_rb_all
Global $LS_rb_noCmt

Global $LS_g_curFile = ""
Global $LS_g_keyword

LS_setListLayout()

Func LS_popup($keyword)
	If $keyword <> "" Then
		$LS_g_keyword = $keyword
		_GUICtrlListBox_BeginUpdate($LS_ls_resultHandle)
		_GUICtrlListBox_ResetContent($LS_ls_resultHandle)
		Local $i
		For $i = 1 To $g_fileRecord[0]
;~ 			If Not StringInStr($g_fileRecord[$i], $keyword) Then ContinueLoop
			If Not _LS_isMatch($keyword, $g_fileRecord[$i]) Then ContinueLoop
			_GUICtrlListBox_AddString($LS_ls_resultHandle, $i & ' ' & $g_fileRecord[$i])
		Next
		_GUICtrlListBox_EndUpdate($LS_ls_resultHandle)
		_GUICtrlListBox_SetCurSel($LS_ls_resultHandle, 0)
		$LS_g_curFile = _getCurFilePath()
		If _GUICtrlListBox_GetCount($LS_ls_resultHandle) <= 0 Then
			GUICtrlSetState($LS_btn_goto, $GUI_DISABLE)
			GUICtrlSetState($LS_btn_clipboard, $GUI_DISABLE)
		Else
			GUICtrlSetState($LS_btn_goto, $GUI_ENABLE)
			GUICtrlSetState($LS_btn_clipboard, $GUI_ENABLE)
		EndIf
		WinSetTitle($LS_gui_main, "", _
			$LS_APP_NAME & ' - "' & $keyword & '"' & ' in file "' & _getFileName($LS_g_curFile) & '"')
		GUISetState(@SW_SHOW, $LS_gui_main)
	Else
		GUISetState(@SW_SHOW, $LS_gui_main)
	EndIf
EndFunc

Func _LS_isMatch($keyword, $line)
	If GUICtrlRead($LS_rb_noCmt) == $GUI_CHECKED Then
		If StringLeft(StringStripWS($line, 1), 1) == ';' Then Return False
	EndIf
	
	Local $casesense = 0
	If GUICtrlRead($LS_cb_matchCase) == $GUI_CHECKED Then $casesense = 1
	Local $pos = StringInStr($line, $keyword, $casesense)
	If $pos == 0 Then Return False
	
	If GUICtrlRead($LS_cb_wholeWord) == $GUI_CHECKED Then
		If $pos > 1 And _LS_isWordChar(StringMid($line, $pos-1, 1)) Then Return False
		$pos += StringLen($keyword)
		If _LS_isWordChar(StringMid($line, $pos, 1)) Then Return False
	EndIf
	
	Return True
EndFunc

Func _LS_isWordChar($char)
	Local $asc = Asc($char)
	If ($asc >= 65 And $asc <= 90) Or _
		($asc >= 97 And $asc <= 122) Or $asc == 95 Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func LS_setListLayout()
	Local $pos = WinGetPos($g_hWndSciTE)
	Local $x = $pos[2] - 530
	If $x < 0 Then $x = 0
	$LS_gui_main = GUICreate($LS_APP_NAME, 500, 230, $x, 24, $WS_SIZEBOX);, $WS_EX_MDICHILD, $g_hWndSciTE)
	DllCall("user32.dll", "int", "SetParent", "hwnd", $LS_gui_main, "hwnd", $g_hWndSciTE)
	$LS_ls_resultHandle = GUICtrlCreateList("", 109, 0, 390, 221, BitOR($WS_HSCROLL, $WS_VSCROLL, $WS_BORDER))
	$LS_ls_resultHandle = GUICtrlGetHandle($LS_ls_resultHandle)
	GUICtrlSetTip(-1, "Double click to jump to high lighted line.")
	GUICtrlSetResizing(-1, BitAND($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKTOP))
	
	$LS_cb_wholeWord = GUICtrlCreateCheckbox("Whole &Word", 5, 1)
	GUICtrlSetState(-1, IniRead($CONF, "search", "whole_word", 4))
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	$LS_cb_matchCase = GUICtrlCreateCheckbox("Match &Case", 5, 20)
	GUICtrlSetState(-1, IniRead($CONF, "search", "match_case", 4))
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlCreateGroup("Scope", 5, 38, 99, 51)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	$LS_rb_all = GUICtrlCreateRadio("Search &All", 10, 51)
	GUICtrlSetState(-1, IniRead($CONF, "search", "search_all", 1))
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	$LS_rb_noCmt = GUICtrlCreateRadio("&No Comment", 10, 67)
	GUICtrlSetState(-1, IniRead($CONF, "search", "no_comment", 1))
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	
	$LS_btn_goto = GUICtrlCreateButton("&Go to", 5, 94, 99, 25, 0)
	GUICtrlSetTip(-1, "Go to high lighted item (Ctrl+G)")
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetOnEvent(-1, "LS_searchListClicked")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	$LS_btn_clipboard = GUICtrlCreateButton("&Clipboard", 5, 123, 99, 25, 0)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetOnEvent(-1, "LS_clipboard")
	GUICtrlSetTip(-1, "Put the text of the high lighted item into clipboard. (Ctrl+C)")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	$LS_btn_refresh = GUICtrlCreateButton("&Refresh", 5, 152, 99, 25, 0)
	GUICtrlSetTip(-1, "Refresh the result when file in SciTE changed or search options changed. (Ctrl+R)")
	GUICtrlSetOnEvent(-1, "LS_updateSearchResult")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	$LS_btn_close = GUICtrlCreateButton("&Close", 5, 181, 99, 25, 0)
	GUICtrlSetTip(-1, "Close the search window. (ESC)")
	GUICtrlSetOnEvent(-1, "LS_close")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	Local $hk[3][2] = [["^g", $LS_btn_goto], ["^c", $LS_btn_clipboard], ["^r", $LS_btn_refresh]]
	GUISetAccelerators($hk, $LS_gui_main)
	GUISetOnEvent($GUI_EVENT_CLOSE, "LS_close")
	GUISetState(@SW_HIDE)
EndFunc

Func LS_updateSearchResult()
	LS_popup($LS_g_keyword)
EndFunc

Func LS_searchListClicked()
	Local $text = _GUICtrlListBox_GetText($LS_ls_resultHandle, _GUICtrlListBox_GetCurSel($LS_ls_resultHandle))
	If $text == 0 Then Return
	Local $ln = StringStripWS(StringLeft($text, StringInStr($text, ' ')), 3)
	_goto($ln, 0, $LS_g_curFile)
	Local $pos[3] = [$ln, 0, $LS_g_curFile]
	_addPos2BackStack($pos)
EndFunc

Func LS_clipboard()
	Local $text = _GUICtrlListBox_GetText($LS_ls_resultHandle, _GUICtrlListBox_GetCurSel($LS_ls_resultHandle))
	If $text == 0 Then Return
	ClipPut($text)
EndFunc

Func LS_close()
	GUISetState(@SW_HIDE, $LS_gui_main)
	WinActivate($g_hWndSciTE)
EndFunc
