#Include <GuiTreeView.au3>
#include-once

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 返回路径数组，结构如下：
; array[0]: 路径成员个数 n
; array[1] ~ array[n]: 路径成员（不包含view名字）
; array[n + 1]: 路径的文本（包含view的名字）
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func getCCPath()
	Local $hWnd = ControlGetHandle("Rational ClearCase Explorer", "Standard Toolbar", 126)
	Local $hNode = _GUICtrlTreeView_GetSelection ($hWnd)
	Local $string = _GUICtrlTreeView_GetText ($hWnd, $hNode)
	Local $parentNode, $nodeText, $rootText = _GUICtrlTreeView_GetText($hWnd, 0)
	While 1
		$parentNode = _GUICtrlTreeView_GetParentHandle ($hWnd, $hNode)
		$nodeText = _GUICtrlTreeView_GetText ($hWnd, $parentNode)
		If $nodeText == $rootText Then
			$string = $nodeText & "\" & $string
			ExitLoop
		EndIf
		$string = $nodeText & "\" & $string
		$hNode = $parentNode
	WEnd

	Local $bugfixViewName = StringLeft($string, StringInStr($string, "\") - 1)
	$string = StringMid($string, StringInStr($string, "\") + 1)
	Local $array = StringSplit($string, "\")
	ReDim $array[$array[0] + 2]
	If $bugfixViewName == "" Then
		$array[$array[0] + 1] = $string
	Else
		$array[$array[0] + 1] = $bugfixViewName & "\" & $string
	EndIf
	Return $array
EndFunc   ;==>getCCPath

Func _ReduceMemory()
	Local $dll_mem = DllOpen(@SystemDir & "\psapi.dll")
	Local $ai_Return = DllCall($dll_mem, 'int', 'EmptyWorkingSet', 'long', -1)
	If @error Then Return SetError(@error,@error, 1)
	Return $ai_Return[0]
EndFunc   ;==>_ReduceMemory

Func ShowMenu($hWnd, $CtrlID, $nContextID)
	Local $hMenu = GUICtrlGetHandle($nContextID)
	Local $arPos = ControlGetPos($hWnd, "", $CtrlID)

	Local $x = $arPos[0]
	Local $y = $arPos[1] + $arPos[3]

	ClientToScreen($hWnd, $x, $y)
	TrackPopupMenu($hWnd, $hMenu, $x, $y)
EndFunc

Func ClientToScreen($hWnd, ByRef $x, ByRef $y)
    Local $stPoint = DllStructCreate("int;int")
    
    DllStructSetData($stPoint, 1, $x)
    DllStructSetData($stPoint, 2, $y)

    DllCall("user32.dll", "int", "ClientToScreen", "hwnd", $hWnd, "ptr", DllStructGetPtr($stPoint))
    
    $x = DllStructGetData($stPoint, 1)
    $y = DllStructGetData($stPoint, 2)
    ; release Struct not really needed as it is a local 
    $stPoint = 0
EndFunc

Func TrackPopupMenu($hWnd, $hMenu, $x, $y)
    DllCall("user32.dll", "int", "TrackPopupMenuEx", "hwnd", $hMenu, "int", 0, "int", $x, "int", $y, "hwnd", $hWnd, "ptr", 0)
EndFunc

