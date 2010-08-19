#include <GUIConstants.au3>

#Region ### START Koda GUI section ### Form=D:\Tools\AutoIt3\koda_1.7.0.0\Forms\sudoku_popup.kxf
$Form2 = GUICreate("Form1", 105, 105, 100, 100, $WS_POPUP)
$Label11 = GUICtrlCreateLabel("1", 2, 2, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
$Label12 = GUICtrlCreateLabel("2", 36, 2, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
$Label13 = GUICtrlCreateLabel("3", 70, 2, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
$Label21 = GUICtrlCreateLabel("4", 2, 36, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
$Label22 = GUICtrlCreateLabel("5", 36, 36, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
$Label23 = GUICtrlCreateLabel("6", 70, 36, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
$Label31 = GUICtrlCreateLabel("7", 2, 70, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
$Label32 = GUICtrlCreateLabel("8", 36, 70, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
$Label33 = GUICtrlCreateLabel("9", 70, 70, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


GUICtrlSetPos ($Form2, 0, 0)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch
WEnd
