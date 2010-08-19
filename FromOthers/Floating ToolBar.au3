#include <GUIConstants.au3>
;Opt("MustDeclareVars", 1)

; ver 1.0.0
; $h_ToolBar = XSkinToolBarCreate($Xh_Gui, $tool_left, $tool_top, $tool_width, $tool_bkcolor = "")
; XSkinToolBarButton($iNumber, $iDLL = "shell32.dll")
; XSkinToolBarSeparator()

Global $TBcnt = -1
; ************************ YOUR CODE GOES BELOW HERE *****************************

$h_ToolBar = XSkinToolBarCreate("Float-ToolBar", 200, 200, 324)

$TButton1 = XSkinToolBarButton( "", @WindowsDir & "\notepad.exe")

; #1 - Using Icons from a dll ( shell32.dll is default)
XSkinToolBarButton(21)
XSkinToolBarButton(17)
XSkinToolBarButton(44)
XSkinToolBarSeparator()
GUICtrlSetTip( -1, "Drag Me")

; #2 - Using Icons from an exe file

XSkinToolBarButton(22)
XSkinToolBarButton("", @ProgramFilesDir & "\Internet Explorer\iexplore.exe")
XSkinToolBarButton( "", @WindowsDir & "\explorer.exe")
XSkinToolBarButton( "", @SystemDir & "\calc.exe")
XSkinToolBarSeparator()
GUICtrlSetTip( -1, "Drag Me")

; #3 - Using Icons from an ico file
XSkinToolBarButton("", @ScriptDir & "\Skins\Default-ToolBar\Admin Tools.ico")
XSkinToolBarButton("", @ScriptDir & "\Skins\Default-ToolBar\Control Panel.ico")
XSkinToolBarButton("", @ScriptDir & "\Skins\Default-ToolBar\E-Mail.ico")

; Exit Button
XSkinToolBarSeparator()
GUICtrlSetTip( -1, "Drag Me")
$TButtonLast = XSkinToolBarButton(27)


GUISetState(@SW_SHOW, $h_ToolBar)

WinSetOnTop($h_ToolBar, "", 1)

While 1
    $msg = GUIGetMsg()
    
    if $msg = $TButton1 Then Run('notepad.exe')
        
    if $msg = $TButtonLast Then Exit
WEnd


; ************************ YOUR CODE ENDS HERE *****************************

Func XSkinToolBarCreate($XTitle, $tool_left, $tool_top, $tool_width, $tool_bkcolor = "")
    Local $Xh_ToolBar
    $Xh_ToolBar = GUICreate($XTitle, $tool_width, 24, $tool_left, $tool_top, $WS_POPUP, $WS_CLIPCHILDREN);-1, $WS_EX_STATICEDGE);, $Xh_Gui)
    If $tool_bkcolor <> "" Then GUISetBkColor($tool_bkcolor, $Xh_ToolBar)
    Return $Xh_ToolBar
EndFunc   ;==>XSkinToolBarCreate

Func XSkinToolBarButton($iNumber, $iDLL = "shell32.dll")
    Local $Xhadd, $TBBleft
    $TBcnt = $TBcnt + 1
    $TBBleft = $TBcnt * 24
    $Xhadd = GUICtrlCreateButton("", $TBBleft, 1, 24, 24, $BS_ICON)
    GUICtrlSetImage($Xhadd, $iDLL, $iNumber, 0)
    Return $Xhadd
EndFunc   ;==>XSkinToolBarButton

Func XSkinToolBarSeparator()
    Local $TBBleft
    $TBcnt = $TBcnt + .5
    $TBBleft = $TBcnt * 24
    GUICtrlCreateLabel("", $TBBleft + 17, 2, 2, 22, $SS_ETCHEDVERT, $GUI_WS_EX_PARENTDRAG)
EndFunc   ;==>XSkinToolBarSeparator
