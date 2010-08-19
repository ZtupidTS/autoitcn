
#include <GuiEdit.au3>

Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 1)
Opt("WinTitleMatchMode", 2)

;~ Opt("GUIEventOptions", 1)

Global Const $MB_INFO_OK = 8256
Global Const $MB_CRITICAL_OK = 8208
Global Const $MB_ALERT_OK = 8240
Global Const $MB_QUESTION_YESNO = 8228
Global Const $MB_QUESTION_NOYES = 8484

Global Const $VERSION = "2.0.1"
Global Const $DATE = "2009/09/01"
Global Const $APP_NAME = "SciTE Navigator"
Global Const $SCITE_PATH = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\AutoIt", "InstallDir") & "\SciTE\SciTE.exe"
Global Const $CONF = @ScriptDir & "\conf.ini"
Global Const $INTERVAL_IDLE = 1000
Global Const $INTERVAL_BUSY = 500
Global Const $ST_ASCENDING = 0
Global Const $ST_DESCENDING = 1
Global Const $ST_ORIGINAL = 2
Global Const $ST_ORIGINAL_REVERSE = 3
Global Const $HK_JUMP_BACK = "!{left}"
Global Const $HK_JUMP_FORWARD = "!{right}"
Global Const $HK_SEARCH_SELETECTED = "{f3}"
Global Const $HK_LIST_SEARCH = "+!l"

Global Const $HK_TOGGLE_FOLD = "+!f"
Global Const $HK_TOGGLE_CURRENT_FOLD = "^+!f"
Global Const $HK_CTRL_J = "^j"

Global $g_editingFile = ""
Global $g_fileRecord[1]
Global $g_hWndSciTE = 0
Global $g_hWndEdit = 0

#Region init variables
$g_hWndSciTE = WinGetHandle("- SciTE", "Source")
If $g_hWndSciTE == "" Then
	If Not FileExists($SCITE_PATH) Then
		MsgBox($MB_CRITICAL_OK, $APP_NAME, "SciTE has not been installed or not successfully installed, " & @CRLF & _
				"reinstall SciTE or run SciTE manually and then run this application again.")
		Exit
	EndIf
	Run($SCITE_PATH)
	If WinWait("- SciTE", "Source", 60) == 0 Then
		MsgBox($MB_CRITICAL_OK, $APP_NAME, "SciTE can not be launched!")
		Exit
	EndIf
	$g_hWndSciTE = WinGetHandle("- SciTE", "Source")
EndIf
$g_hWndEdit = ControlGetHandle($g_hWndSciTE, "", 350)
#EndRegion
;


Func _isHotkeyValid($key, $func)
	If Not WinActive($g_hWndSciTE) Then
		HotKeySet($key)
		Send($key)
		HotKeySet($key, $func)
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>_isHotkeyValid

Func _getFileName($path)
	Local $idx = StringInStr($path, "\", 0, -1)
	If $idx == 0 Then Return ""
	Return StringMid($path, $idx+1, StringLen($path))
EndFunc

Func _getSelectedText()
	Local $bak = ClipGet()
	ClipPut("")
	WinMenuSelectItem($g_hWndSciTE, "", "&Edit", "&Copy")
	Sleep(10)
	Local $text = ClipGet()
	ClipPut($bak)
	Return $text
EndFunc

Func _add2Combobox($hCombo, $str)
	Local $aList = StringSplit(_GUICtrlComboBox_GetList($hCombo), "|")
	_GUICtrlComboBox_InsertString($hCombo, StringStripWS($str, 3), 0)
	Local $i
	For $i = 1 To $aList[0]
		If StringLower($aList[$i]) <> StringStripWS(StringLower($str), 3) Then ContinueLoop
		_GUICtrlComboBox_DeleteString($hCombo, $i)
		ExitLoop
	Next
EndFunc   ;==>_add2Combobox

Func _goto($lineNum, $colNum = 0, $file = "")
	If $file <> "" Then
		RunWait($SCITE_PATH & ' "' & $file & '" -goto:' & $lineNum & ',' & $colNum)
	Else
		RunWait($SCITE_PATH & ' -goto:' & $lineNum & ',' & $colNum)
	EndIf
;~ 	ControlSend($g_hWndEdit, "", 0, "^{home}")
;~ 	_GUICtrlEdit_LineScroll($g_hWndEdit, 0, $lineNum - 1)
;~ 	WinActivate($g_hWndSciTE)
EndFunc   ;==>_goto

Func _getCurFilePath()
	Local $title = WinGetTitle($g_hWndSciTE)
	Return StringLeft($title, StringInStr($title, "SciTE", 1, -1) - 4)
EndFunc   ;==>_getCurFilePath

Func _createSeparator($x)
	GUICtrlCreateLabel("|", $x, 0, 15, 17, $SS_LEFT)
	GUICtrlSetFont(-1, 17, 400, 0, "MS Sans Serif")
	GUICtrlSetState(-1, $GUI_DISABLE)
EndFunc   ;==>_createSeparator

Func _reverseArray(ByRef $arr)
	Local $len = Int($arr[0][0] / 2)
	Local $i, $t
	For $i = 1 To $len
		$t = $arr[$i][0]
		$arr[$i][0] = $arr[$arr[0][0] - $i + 1][0]
		$arr[$arr[0][0] - $i + 1][0] = $t
		
		$t = $arr[$i][1]
		$arr[$i][1] = $arr[$arr[0][0] - $i + 1][1]
		$arr[$arr[0][0] - $i + 1][1] = $t
		
		$t = $arr[$i][2]
		$arr[$i][2] = $arr[$arr[0][0] - $i + 1][2]
		$arr[$arr[0][0] - $i + 1][2] = $t
	Next
EndFunc   ;==>_reverseArray

;~ Func _search($kw, $fromIdx = 0, )
;~ EndFunc

Func _showMenu($hWnd, $CtrlID, $nContextID)
	Local $hMenu = GUICtrlGetHandle($nContextID)
	Local $arPos = ControlGetPos($hWnd, "", $CtrlID)

	Local $x = $arPos[0]
	Local $y = $arPos[1] + $arPos[3]

	_clientToScreen($hWnd, $x, $y)
	_trackPopupMenu($hWnd, $hMenu, $x, $y)
EndFunc   ;==>_showMenu

Func _clientToScreen($hWnd, ByRef $x, ByRef $y)
	Local $stPoint = DllStructCreate("int;int")

	DllStructSetData($stPoint, 1, $x)
	DllStructSetData($stPoint, 2, $y)

	DllCall("user32.dll", "int", "ClientToScreen", "hwnd", $hWnd, "ptr", DllStructGetPtr($stPoint))

	$x = DllStructGetData($stPoint, 1)
	$y = DllStructGetData($stPoint, 2)
	; release Struct not really needed as it is a local
	$stPoint = 0
EndFunc   ;==>_clientToScreen

Func _trackPopupMenu($hWnd, $hMenu, $x, $y)
	DllCall("user32.dll", "int", "TrackPopupMenuEx", "hwnd", $hMenu, "int", 0, "int", $x, "int", $y, "hwnd", $hWnd, "ptr", 0)
EndFunc   ;==>_trackPopupMenu

Func _lookforFirstVisiblePos($str, $fromIdx = 1)
	Local $i, $char
	For $i = $fromIdx To StringLen($str)
		$char = StringMid($str, $i, 1)
		If $char == ' ' Or $char == @TAB Or $char == @CR Or $char == @LF Then ContinueLoop
		Return $i
	Next
	Return -1
EndFunc   ;==>_lookforFirstVisiblePos

Func _isCharVisible($char)
	If $char == ' ' Or $char == @TAB Or $char == @CR Or $char == @LF Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>_isCharVisible


;~ Func onAutoitExit()
;~ EndFunc
