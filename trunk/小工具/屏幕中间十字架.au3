#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>

$child = GUICreate("My Draw")

GUICtrlCreateGraphic(20, 200, 80, 80)
    GUICtrlSetGraphic(-1, $GUI_GR_MOVE, 10, 10)
    GUICtrlSetGraphic(-1, $GUI_GR_COLOR, 0xff)
    GUICtrlSetGraphic(-1, $GUI_GR_LINE, 30, 40)
	
	GUISetState()
	
	While True
		Sleep(2000)
	WEnd