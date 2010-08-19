
#include <GuiMenu.au3>


Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 1)
Opt("WinTitleMatchMode", 2)

;~ Opt("GUIEventOptions", 1)

Global Const $MB_INFO_OK = 8256
Global Const $MB_CRITICAL_OK = 8208
Global Const $MB_ALERT_OK = 8240
Global Const $MB_QUESTION_YESNO = 8228
Global Const $MB_QUESTION_NOYES = 8484

Global Const $VERSION = "3.0.1"
Global Const $DATE = "2009/04/24"
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

Func _getCurFilePath()
	Local $title = WinGetTitle($g_hWndSciTE)
	Return StringLeft($title, StringInStr($title, "SciTE", 1, -1) - 4)
EndFunc   ;==>_getCurFilePath

Func _createSeparator($x)
	GUICtrlCreateLabel("|", $x, 0, 15, 17, $SS_LEFT)
	GUICtrlSetFont(-1, 17, 400, 0, "MS Sans Serif")
	GUICtrlSetState(-1, $GUI_DISABLE)
EndFunc   ;==>_createSeparator

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

Func _goto($startIdx, $endIdx, $file = "")
	ConsoleWrite("$startIdx=" & $startIdx & ", $endIdx=" & $endIdx & ", file=" & $file &@CR)
	If $file <> "" Then
;~ 		WinMenuSelectItem($g_hWndSciTE, "", "&Buffers", _getMenuItemWholeText($file))
		Sleep(20)
	EndIf
	_GUICtrlEdit_SetSel($g_hWndEdit, $startIdx, $endIdx)
EndFunc

; failed, return ""
Func _getMenuItemWholeText($partialText)
	Local $hMenu = _GUICtrlMenu_GetMenu($g_hWndSciTE)
	Local $hBuffers = _GUICtrlMenu_GetItemSubMenu($hMenu, 7)
	Local $iItem = _GUICtrlMenu_FindItem($hBuffers, $partialText, True)
	Return _GUICtrlMenu_GetItemText($hBuffers, $iItem)
EndFunc

