#include <GUIConstants.au3>

#region variables

Global Const $APP_NAME = "Sudoku"
Global Const $POPUP_WIDTH = 105
Global Const $cellPosition[12][3] = [[8, 0, 0], [49, 0, 1], [90, 0, 2], [130, -1, -1], _
							[134, 1, 0], [175, 1, 1], [216, 1, 2], [256, -1, -1], _
							[260, 2, 0], [301, 2, 1], [341, 2, 2], [381, -1, -1]]
Global $sectors[3][3]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $cells[x][y][0]: ctrlId
; $cells[x][y][1]: label value
; $cells[x][y][2]: pencil hint array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Global $cells[3][3][3]
Global $popupCells[3][3]
Global $Form_main
Global $hdl_main
Global $Form_popup
Global $isPopupWinShown = False
Global $isPencilStroke = False

#endregion
createForm()
Local $clickedCell, $leftClickedCell, $rightClickedCell
Local $selectedPopupCellNum = 0, $nMsg
While 1
	$message = GUIGetMsg(1)
;~ 	$nMsg = GUIGetMsg()
	$nMsg = $message[0]
	$leftClickedCell = getLeftClickedCell($nMsg)
	If $leftClickedCell[0] <> 0 Then $clickedCell = $leftClickedCell
	If $isPopupWinShown Then
		$selectedPopupCellNum = searchPopupCells($nMsg)
		If $selectedPopupCellNum <> 0 Then
			WinMove($APP_NAME & " - Choose Number", "1", @DesktopWidth + 1, @DesktopHeight + 1)
			$isPopupWinShown = False
			GUISetState(@SW_RESTORE, $Form_main)
			fillSelectedNum($selectedPopupCellNum, $clickedCell, $isPencilStroke)
		EndIf
	EndIf
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			If $isPopupWinShown Then
				WinMove($APP_NAME & " - Choose Number", "1", @DesktopWidth + 1, @DesktopHeight + 1)
				$isPopupWinShown = False
				GUISetState(@SW_RESTORE, $Form_main)
			Else
				Exit
			EndIf
			
		Case $GUI_EVENT_SECONDARYDOWN ;handle right click
			$rightClickedCell = getRightClickedCell($message[3], $message[4])
			If $rightClickedCell[0] <> 0 Then $clickedCell = $rightClickedCell
	EndSwitch
WEnd

Func fillSelectedNum($num, $cell, $isPencilStroke = True)
	If $isPencilStroke Then
		Local $pencilArray = $cell[2]
		If Not IsArray($pencilArray) Then
			Local $pencilArray[3][3]
		EndIf
		If $num == 9 Then
			$pencilArray[2][2] = $num
		Else
			$pencilArray[Int($num/3)][Mod($num, 3)] = $num
		EndIf
		
		; todo: field the pencil stroke to the right position
		GUICtrlSetData($cell[0], $num)
		Return
	EndIf
	
	; not pencil stroke
	; todo: do some checking here
	GUICtrlSetData($cell[0], $num)
EndFunc

Func getLeftClickedCell($msg)
	Local $sector, $mousePos
	Local $cell[3] = [0, 0, 0]
	For $i = 0 to 2
		For $j = 0 to 2
			$sector = $sectors[$i][$j]
			For $ii = 0 to 2
				For $jj = 0 to 2
					If $msg == $sector[$ii][$jj][0] Then
						$mousePos = MouseGetPos()
						WinMove($APP_NAME & " - Choose Number", "1", _
								$mousePos[0] - Int($POPUP_WIDTH/2), _
								$mousePos[1] - Int($POPUP_WIDTH/2))
						$isPopupWinShown = True
						$isPencilStroke = False
;~ 						ConsoleWrite("$sector[$ii][$jj]=" & $sector[$ii][$jj] & @CRLF)
						$cell[0] = $sector[$ii][$jj][0]
						$cell[1] = $sector[$ii][$jj][1]
						$cell[2] = $sector[$ii][$jj][2]
						Return $cell
					EndIf
				Next
			Next
		Next
	Next
	Return $cell
EndFunc

Func getRightClickedCell($col, $row)
	If $isPopupWinShown Then Return 0 ; the num choose window is poped up, ignore the righclick
	Local $sectorX = -1, $sectorY = -1, $cellX = -1, $cellY = -1
	Local $cell[3] = [0, 0, 0]
	For $i = 11 To 1 Step -1
		If $row < $cellPosition[$i][0] Then
			$sectorX = $cellPosition[$i - 1][1]
			$cellX = $cellPosition[$i - 1][2]
		EndIf
		If $col < $cellPosition[$i][0] Then
			$sectorY = $cellPosition[$i - 1][1]
			$cellY = $cellPosition[$i - 1][2]
		EndIf
	Next
	If $sectorX == -1 Or _
		$cellX == -1 Or _
		$sectorY == -1 Or _
		$cellY == -1 Or _
		$col < $cellPosition[0][0] Or _
		$row < $cellPosition[0][0] Then Return $cell ; user click outside of the cell area
	
	Local $sectorTmp = $sectors[$sectorX][$sectorY]
	$mousePos = MouseGetPos()
	WinMove($APP_NAME & " - Choose Number", "1", _
			$mousePos[0] - Int($POPUP_WIDTH/2), _
			$mousePos[1] - Int($POPUP_WIDTH/2))
	$isPopupWinShown = True
	$isPencilStroke = True
	$cell[0] = $sectorTmp[$cellX][$cellY][0]
	$cell[1] = $sectorTmp[$cellX][$cellY][1]
	$cell[2] = $sectorTmp[$cellX][$cellY][2]
	Return $cell
EndFunc

Func searchPopupCells($msg)
	For $i = 0 to 2
		For $j = 0 to 2
			If $popupCells[$i][$j] == $msg Then
;~ 				ConsoleWrite(GUICtrlRead($popupCells[$i][$j]) & @CRLF)
				Return GUICtrlRead($popupCells[$i][$j])
			EndIf
		Next
	Next
	Return 0
EndFunc

Func createForm()
	$Form_main = GUICreate($APP_NAME, 392, 477, 193, 115)
	$cells[0][0][0] = GUICtrlCreateLabel("", 8, 8, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][1][0] = GUICtrlCreateLabel("", 49, 8, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][2][0] = GUICtrlCreateLabel("", 90, 8, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][0][0] = GUICtrlCreateLabel("", 8, 49, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][1][0] = GUICtrlCreateLabel("", 49, 49, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][2][0] = GUICtrlCreateLabel("", 90, 49, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][0][0] = GUICtrlCreateLabel("", 8, 90, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][1][0] = GUICtrlCreateLabel("", 49, 90, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][2][0] = GUICtrlCreateLabel("", 90, 90, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$sectors[0][0] = $cells

	$cells[0][0][0] = GUICtrlCreateLabel("", 134, 8, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][1][0] = GUICtrlCreateLabel("", 175, 8, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][2][0] = GUICtrlCreateLabel("", 216, 8, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][0][0] = GUICtrlCreateLabel("", 134, 49, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][1][0] = GUICtrlCreateLabel("", 175, 49, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][2][0] = GUICtrlCreateLabel("", 216, 49, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][0][0] = GUICtrlCreateLabel("", 134, 90, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][1][0] = GUICtrlCreateLabel("", 175, 90, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][2][0] = GUICtrlCreateLabel("", 216, 90, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$sectors[0][1] = $cells

	$cells[0][0][0] = GUICtrlCreateLabel("", 260, 8, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][1][0] = GUICtrlCreateLabel("", 301, 8, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][2][0] = GUICtrlCreateLabel("", 342, 8, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][0][0] = GUICtrlCreateLabel("", 260, 49, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][1][0] = GUICtrlCreateLabel("", 301, 49, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][2][0] = GUICtrlCreateLabel("", 342, 49, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][0][0] = GUICtrlCreateLabel("", 260, 90, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][1][0] = GUICtrlCreateLabel("", 301, 90, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][2][0] = GUICtrlCreateLabel("", 342, 90, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$sectors[0][2] = $cells

	$cells[0][0][0] = GUICtrlCreateLabel("", 8, 134, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][1][0] = GUICtrlCreateLabel("", 49, 134, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][2][0] = GUICtrlCreateLabel("", 90, 134, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][0][0] = GUICtrlCreateLabel("", 8, 175, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][1][0] = GUICtrlCreateLabel("", 49, 175, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][2][0] = GUICtrlCreateLabel("", 90, 175, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][0][0] = GUICtrlCreateLabel("", 8, 216, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][1][0] = GUICtrlCreateLabel("", 49, 216, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][2][0] = GUICtrlCreateLabel("", 90, 216, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$sectors[1][0] = $cells

	$cells[0][0][0] = GUICtrlCreateLabel("", 134, 134, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][1][0] = GUICtrlCreateLabel("", 175, 134, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][2][0] = GUICtrlCreateLabel("", 216, 134, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][0][0] = GUICtrlCreateLabel("", 134, 175, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][1][0] = GUICtrlCreateLabel("", 175, 175, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][2][0] = GUICtrlCreateLabel("", 216, 175, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][0][0] = GUICtrlCreateLabel("", 134, 216, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][1][0] = GUICtrlCreateLabel("", 175, 216, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][2][0] = GUICtrlCreateLabel("", 216, 216, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$sectors[1][1] = $cells

	$cells[0][0][0] = GUICtrlCreateLabel("", 260, 134, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][1][0] = GUICtrlCreateLabel("", 301, 134, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][2][0] = GUICtrlCreateLabel("", 342, 134, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][0][0] = GUICtrlCreateLabel("", 260, 175, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][1][0] = GUICtrlCreateLabel("", 301, 175, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][2][0] = GUICtrlCreateLabel("", 342, 175, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][0][0] = GUICtrlCreateLabel("", 260, 216, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][1][0] = GUICtrlCreateLabel("", 301, 216, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][2][0] = GUICtrlCreateLabel("", 342, 216, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$sectors[1][2] = $cells

	$cells[0][0][0] = GUICtrlCreateLabel("", 8, 260, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][1][0] = GUICtrlCreateLabel("", 49, 260, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][2][0] = GUICtrlCreateLabel("", 90, 260, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][0][0] = GUICtrlCreateLabel("", 8, 301, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][1][0] = GUICtrlCreateLabel("", 49, 301, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][2][0] = GUICtrlCreateLabel("", 90, 301, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][0][0] = GUICtrlCreateLabel("", 8, 342, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][1][0] = GUICtrlCreateLabel("", 49, 342, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][2][0] = GUICtrlCreateLabel("", 90, 342, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$sectors[2][0] = $cells

	$cells[0][0][0] = GUICtrlCreateLabel("", 134, 260, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][1][0] = GUICtrlCreateLabel("", 175, 260, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][2][0] = GUICtrlCreateLabel("", 216, 260, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][0][0] = GUICtrlCreateLabel("", 134, 301, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][1][0] = GUICtrlCreateLabel("", 175, 301, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][2][0] = GUICtrlCreateLabel("", 216, 301, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][0][0] = GUICtrlCreateLabel("", 134, 342, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][1][0] = GUICtrlCreateLabel("", 175, 342, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][2][0] = GUICtrlCreateLabel("", 216, 342, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$sectors[2][1] = $cells

	$cells[0][0][0] = GUICtrlCreateLabel("", 260, 260, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][1][0] = GUICtrlCreateLabel("", 301, 260, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[0][2][0] = GUICtrlCreateLabel("", 342, 260, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][0][0] = GUICtrlCreateLabel("", 260, 301, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][1][0] = GUICtrlCreateLabel("", 301, 301, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[1][2][0] = GUICtrlCreateLabel("", 342, 301, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][0][0] = GUICtrlCreateLabel("", 260, 342, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][1][0] = GUICtrlCreateLabel("", 301, 342, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$cells[2][2][0] = GUICtrlCreateLabel("", 342, 342, 40, 40, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$sectors[2][2] = $cells

	GUISetState(@SW_SHOW, $Form_main)
	$hdl_main = WinGetHandle($APP_NAME)
	createPopup()
EndFunc

Func createPopup()
	#Region ### START Koda GUI section ### Form=D:\Tools\AutoIt3\koda_1.7.0.0\Forms\sudoku_popup.kxf
	$Form_popup = GUICreate($APP_NAME & " - Choose Number", $POPUP_WIDTH, $POPUP_WIDTH, _
					@DesktopWidth + 1, @DesktopHeight + 1, $WS_POPUP, $WS_EX_MDICHILD, $hdl_main)
	GUISwitch($Form_popup)
	$popupCells[0][0] = GUICtrlCreateLabel("1", 2, 2, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
	$popupCells[0][1] = GUICtrlCreateLabel("2", 36, 2, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
	$popupCells[0][2] = GUICtrlCreateLabel("3", 70, 2, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
	$popupCells[1][0] = GUICtrlCreateLabel("4", 2, 36, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
	$popupCells[1][1] = GUICtrlCreateLabel("5", 36, 36, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
	$popupCells[1][2] = GUICtrlCreateLabel("6", 70, 36, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
	$popupCells[2][0] = GUICtrlCreateLabel("7", 2, 70, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
	$popupCells[2][1] = GUICtrlCreateLabel("8", 36, 70, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
	$popupCells[2][2] = GUICtrlCreateLabel("9", 70, 70, 33, 33, BitOR($SS_CENTER,$WS_BORDER))
	GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
	GUISetState(@SW_SHOW, $Form_popup)
	WinSetTrans($APP_NAME & " - Choose Number", "1", 170) 
	GUISetState(@SW_RESTORE, $Form_main)
	#EndRegion ### END Koda GUI section ###
EndFunc







