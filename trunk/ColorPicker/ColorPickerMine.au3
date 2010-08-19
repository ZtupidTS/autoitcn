#include <GuiConstants.au3>

;~ Sets the way colors are defined, either RGB or BGR. 
;~ RGB is the default but in previous versions of AutoIt (pre 3.0.102) BGR was the default:
;~ 0 = Colors are defined as RGB (0xRRGGBB) (default)
;~ 1 = Colors are defined as BGR (0xBBGGRR) (the mode used in older versions of AutoIt)

Global $APP_NAME = "Color Picker V1.0 by chenxu"
Global $CONF_FILE = "ColorPicker.ini"
HotKeySet("+!s", "save")

IniRead($CONF_FILE, "main", "posX", -1)
IniRead($CONF_FILE, "main", "posY", -1)
GuiCreate($APP_NAME, 230, 115, IniRead($CONF_FILE, "main", "posX", -1), IniRead($CONF_FILE, "main", "posY", -1), _
		$WS_CAPTION + $WS_SYSMENU + $WS_MINIMIZEBOX + $WS_VISIBLE + $WS_CLIPSIBLINGS)

GuiCtrlCreateLabel("Screen Position", 10, 10, 100, 20)
$Label_scnPos = GuiCtrlCreateLabel("", 10, 30, 100, 20)
GuiCtrlCreateLabel("Window Position", 10, 50, 100, 20)
$Label_winPos = GuiCtrlCreateLabel("", 10, 70, 100, 20)
$Radio_RGB = GuiCtrlCreateRadio("&RGB", 110, 10, 40, 20)
GUICtrlSetState($Radio_RGB, IniRead($CONF_FILE, "main", "rgb", $GUI_CHECKED))
$Radio_BGR = GuiCtrlCreateRadio("&BGR", 160, 10, 40, 20)
GUICtrlSetState($Radio_BGR, IniRead($CONF_FILE, "main", "bgr", $GUI_CHECKED))
$Checkbox_top = GuiCtrlCreateCheckbox("&Always On Top", 110, 30, 100, 20)
GUICtrlSetState($Checkbox_top, IniRead($CONF_FILE, "main", "top", $GUI_CHECKED))
$Checkbox_scn = GuiCtrlCreateCheckbox("s&cn", 110, 55, 35, 20)
GUICtrlSetState($Checkbox_scn, IniRead($CONF_FILE, "main", "scn", $GUI_CHECKED))
$Checkbox_win = GuiCtrlCreateCheckbox("&win", 150, 55, 35, 20)
GUICtrlSetState($Checkbox_win, IniRead($CONF_FILE, "main", "win", $GUI_CHECKED))
$Checkbox_clr = GuiCtrlCreateCheckbox("c&lr", 190, 55, 35, 20)
GUICtrlSetState($Checkbox_clr, IniRead($CONF_FILE, "main", "clr", $GUI_CHECKED))
$Button_save = GuiCtrlCreateButton("&Save Info", 110, 80, 95, 25)
GUICtrlSetTip($Button_save, "Press Shift+Alt+S to make it faster.")
GuiCtrlCreateLabel("Color:", 10, 90, 40, 10)
$Label_color = GuiCtrlCreateLabel("", 50, 90, 50, 20)

GuiSetState()
While 1
	Sleep(50)
	$msg = GuiGetMsg()
	getMousePos("scn")
	getMousePos("win")
	getColor()
	isOnTop()
	Select
		Case $msg = $GUI_EVENT_CLOSE
		saveConf()
		ExitLoop
	Case $msg = $Button_save
		save()
	Case Else
		;;;
	EndSelect
WEnd
Exit

Func getMousePos($relateTo)
	If $relateTo == "win" Then
		Opt("MouseCoordMode", 0)
		$hdl = $Label_winPos
	Elseif $relateTo == "scn" Then
		Opt("MouseCoordMode", 1)
		$hdl = $Label_scnPos
	EndIf
	$pos = MouseGetPos()
	GUICtrlSetData($hdl, $pos[0] & ", " & $pos[1])
EndFunc

Func getColor()
	$type = 0
	If GUICtrlRead($Radio_RGB) == $GUI_CHECKED Then
		$type = 0
	ElseIf GUICtrlRead($Radio_BGR) == $GUI_CHECKED Then
		$type = 1
	EndIf
	Opt("ColorMode", $type)
	Opt("MouseCoordMode", 1)
	$pos = MouseGetPos()
	GUICtrlSetData($Label_color,  PixelGetColor($pos[0], $pos[1]))
EndFunc

Func isOnTop()
	If GUICtrlRead($Checkbox_top) == $GUI_CHECKED Then
		WinSetOnTop($APP_NAME, "Screen Position", 1)
	Else
		WinSetOnTop($APP_NAME, "Screen Position", 0)
	EndIf
EndFunc

Func save()
	$info = ""
	If GUICtrlRead($Checkbox_scn) == $GUI_CHECKED Then
		$info = $info & "Screen Position: " & GUICtrlRead($Label_scnPos) & @CRLF
	EndIf
	If GUICtrlRead($Checkbox_win) == $GUI_CHECKED Then
		$info = $info & "Window Position: " & GUICtrlRead($Label_winPos) & @CRLF
	EndIf
	If GUICtrlRead($Checkbox_clr) == $GUI_CHECKED Then
		$info = $info & "Color: " & GUICtrlRead($Label_color) & @CRLF
	EndIf
	ClipPut($info)
	TrayTip($APP_NAME, "Info Saved to clipboard!" & @CRLF & $info, 20, 1)
EndFunc

Func saveConf()
	$winPos = WinGetPos($APP_NAME, "Screen Position")
	IniWrite($CONF_FILE, "main", "posX", $winPos[0])
	IniWrite($CONF_FILE, "main", "posY", $winPos[1])
	IniWrite($CONF_FILE, "main", "scn", GUICtrlRead($Checkbox_scn))
	IniWrite($CONF_FILE, "main", "win", GUICtrlRead($Checkbox_win))
	IniWrite($CONF_FILE, "main", "clr", GUICtrlRead($Checkbox_clr))
	IniWrite($CONF_FILE, "main", "top", GUICtrlRead($Checkbox_top))
	IniWrite($CONF_FILE, "main", "rgb", GUICtrlRead($Radio_RGB))
	IniWrite($CONF_FILE, "main", "bgr", GUICtrlRead($Radio_BGR))
EndFunc








