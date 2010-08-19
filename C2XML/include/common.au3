
#include-once
#NoTrayIcon

Global Const $APP_NAME = "C2XML"
Global Const $MSG_BOX_INFO_OK = 8256
Global Const $MSG_BOX_CRITICAL_OK = 8208
Global Const $MSG_BOX_ALERT_OK = 8240
Global Const $MSG_BOX_QUESTION_YESNO = 8228
Global Const $MSG_BOX_QUESTION_NOYES = 8484
;MsgBox features: Title=Yes, Text=Yes, Buttons=Yes, No, and Cancel, Icon=Question, Modality=Task Modal
Global Const $MSG_BOX_QUESTION_YESNOCANCEL = 8227

Global Const $STR_INSTANCE = "Instance "

Global $basicTypes[1][2] = [[0, 0]]
Global $guiStack[1]
Global $FSD_lvStack[2] = [0, 0]
Global $FSD_lvInstStack[2] = [0, 0]
Global $FSD_parentStructNameStack[1]
Global $FSD_memDataStack[1]
; _XMLDomWrapper.au3中定义的全局变量，指向一个xml的dom对象
Global $objDoc

Global $gui
Global $txt_path
Global $statusbar

Global $lv_event
Global $h_lv_event
Global $FSD_lv
Global $FSD_lv_instance
Global $FSD_memData[2] = [0, -1]

;~ Global $FSD_editCtrl


Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 1)

Func handleEventClose()
	FSD_saveChangedData()
	
	_ArrayPop($FSD_lvStack)
	$FSD_lv = $FSD_lvStack[UBound($FSD_lvStack) - 1]
	_ArrayPop($FSD_lvInstStack)
	$FSD_lv_instance = $FSD_lvInstStack[UBound($FSD_lvInstStack) - 1]
	_ArrayPop($FSD_parentStructNameStack)
	_ArrayPop($FSD_memDataStack)
	$FSD_memData = $FSD_memDataStack[UBound($FSD_memDataStack)-1]
	
	Local $topGui = _ArrayPop($guiStack)
	GUISetState(@SW_ENABLE, $guiStack[UBound($guiStack) - 1])
	GUIDelete($topGui)
	
	_refreshMainInterfaceStat()
EndFunc   ;==>handleEventClose

Func _isBasicType($type)
	Local $i
	For $i = 1 To $basicTypes[0][0]
		If $basicTypes[$i][0] == $type Then Return True
	Next
	Return False
EndFunc   ;==>_isBasicType

Func _GUICtrlListView_getSelectedItemText($hWnd, $iSubItem = 0)
	Local $i, $it
	For $i = 0 To _GUICtrlListView_GetItemCount($hWnd) - 1
		If Not _GUICtrlListView_GetItemSelected($hWnd, $i) Then ContinueLoop
		$it = _GUICtrlListView_GetItemText($hWnd, $i, $iSubItem)
		Return $it
	Next
	Return _GUICtrlListView_GetItemText($hWnd, (_GUICtrlListView_GetItemCount($hWnd)-1), $iSubItem)
EndFunc   ;==>_GUICtrlListView_getSelectedItemText

Func _GUICtrlListView_getSelectedItemIndex($hWnd)
	Local $i
	For $i = 0 To _GUICtrlListView_GetItemCount($hWnd) - 1
		If Not _GUICtrlListView_GetItemSelected($hWnd, $i) Then ContinueLoop
		Return $i
	Next
	Return _GUICtrlListView_GetItemCount($hWnd) - 1
EndFunc   ;==>_GUICtrlListView_getSelectedItemIndex

Func _checkInterfaceStatus($xml, $if, $inst)
;~ 	ConsoleWrite("checking " & $if & "(" & $inst & ")" &@CRLF)
	If Not _XMLNodeExists("/simulator/structs/struct[@name='" & $if & "']") Then Return False
	
	Local $xpath = "/simulator/structs/struct[@name='" & $if & "' and @instance='" & $inst & "']/member"
	Local $subInst, $items
	$items = $xml.SelectNodes($xpath)
	If $items.Length <= 0 Then Return False
	
	Local $type, $instItems, $instItem, $memName
	For $item In $items
		$type = $item.GetAttribute("type")
		If _isBasicType($type) Then ContinueLoop
		
		; 判断是否是结构数组
		$memName = $item.GetAttribute("name")
		$instItems = $xml.SelectNodes($xpath & "[@name='" & $memName & "']/value")
		If $instItems.Length <= 0 Then
			$subInst = $item.GetAttribute("instance")
			If $subInst == "" Then Return False
			If $subInst == -1 Then ContinueLoop
			If Not _checkInterfaceStatus($xml, $type, $subInst) Then Return False
		Else
			For $instItem In $instItems
				$subInst = $instItem.GetAttribute("instance")
				If $subInst == "" Then Return False
				If $subInst == 65535 Then ContinueLoop
				If Not _checkInterfaceStatus($xml, $type, $subInst) Then Return False
			Next
		EndIf
	Next
	Return True
EndFunc

Func _refreshMainInterfaceStat()
	If $guiStack[UBound($guiStack) - 1] <> $gui Then Return
	Local $i, $if, $inst
	For $i = 0 To _GUICtrlListView_GetItemCount($h_lv_event)-1
		$if = _GUICtrlListView_GetItemText($h_lv_event, $i, 1)
		$inst = _GUICtrlListView_GetItemText($h_lv_event, $i, 2)
		If _checkInterfaceStatus($objDoc, $if, $inst) Then
			_GUICtrlListView_AddSubItem($h_lv_event, $i, "√", 3)
		Else
			_GUICtrlListView_AddSubItem($h_lv_event, $i, "×", 3)
		EndIf
	Next
EndFunc

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
	Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $tInfo
	
	If Not IsHWnd($h_lv_event) Then $hWndListView = GUICtrlGetHandle($h_lv_event)

	$tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	If $hWndFrom == $h_lv_event Then
		$hWndListView = $h_lv_event
	ElseIf $hWndFrom == $FSD_lv Then
		$hWndListView = $FSD_lv
	ElseIf $hWndFrom == $FSD_lv_instance Then
		$hWndListView = $FSD_lv_instance
	Else
		Return
	EndIf
	$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	If $hWndFrom <> $hWndListView Then Return
	Switch $iCode
	Case $LVN_COLUMNCLICK ; A column was clicked
		; No return value
	Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
		Switch $hWndListView
			Case $h_lv_event
;~ 				listviewClicked()
			Case $FSD_lv
				FSD_memListviewClicked()
			Case $FSD_lv_instance
				FSD_instListviewClicked()
		EndSwitch
;~ 	Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the right mouse button
;~ 		ControlClick($guiStack[UBound($guiStack) - 1], "", $dummy, "right")
;~ 		_DebugPrint("test")
		; No return value
	Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
		Switch $hWndListView
			Case $h_lv_event
				If _GUICtrlListView_GetItemCount($h_lv_event) <> 0 Then listviewClicked()
			Case $FSD_lv
				_GUICtrlListView_EditLabel($FSD_lv, _GUICtrlListView_getSelectedItemIndex($FSD_lv))
;~ 			Case $FSD_lv_instance
;~ 				FSD_instListviewClicked()
		EndSwitch
		
		; No return value
	Case $LVN_ENDLABELEDIT, $LVN_ENDLABELEDITW ; The end of label editing for an item
		Local $tBuffer = DllStructCreate("char Text[" & DllStructGetData($tInfo, "TextMax") & "]", DllStructGetData($tInfo, "Text"))
		If StringLen(DllStructGetData($tBuffer, "Text")) Then Return True
		
	 Case $LVN_BEGINLABELEDIT ; Start of label editing for an item
		 $tInfo = DllStructCreate($tagNMLVDISPINFO, $ilParam)
		 ConsoleWrite("$LVN_BEGINLABELEDIT" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
				 "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
				 "-->Code:" & @TAB & $iCode & @LF & _
				 "-->Mask:" & @TAB & DllStructGetData($tInfo, "Mask") & @LF & _
				 "-->Item:" & @TAB & DllStructGetData($tInfo, "Item") & @LF & _
				 "-->SubItem:" & @TAB & DllStructGetData($tInfo, "SubItem") & @LF & _
				 "-->State:" & @TAB & DllStructGetData($tInfo, "State") & @LF & _
				 "-->StateMask:" & @TAB & DllStructGetData($tInfo, "StateMask") & @LF & _
				 "-->Image:" & @TAB & DllStructGetData($tInfo, "Image") & @LF & _
				 "-->Param:" & @TAB & DllStructGetData($tInfo, "Param") & @LF & _
				 "-->Indent:" & @TAB & DllStructGetData($tInfo, "Indent") & @LF & _
				 "-->GroupID:" & @TAB & DllStructGetData($tInfo, "GroupID") & @LF & _
				 "-->Columns:" & @TAB & DllStructGetData($tInfo, "Columns") & @LF & _
				 "-->pColumns:" & @TAB & DllStructGetData($tInfo, "pColumns") & @LF)
		
	 Case $LVN_ENDLABELEDIT ; The end of label editing for an item
		 $tInfo = DllStructCreate($tagNMLVDISPINFO, $ilParam)
		 $tBuffer = DllStructCreate("char Text[" & DllStructGetData($tInfo, "TextMax") & "]", DllStructGetData($tInfo, "Text"))
		 ConsoleWrite("$LVN_ENDLABELEDIT" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
				 "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
				 "-->Code:" & @TAB & $iCode & @LF & _
				 "-->Mask:" & @TAB & DllStructGetData($tInfo, "Mask") & @LF & _
				 "-->Item:" & @TAB & DllStructGetData($tInfo, "Item") & @LF & _
				 "-->SubItem:" & @TAB & DllStructGetData($tInfo, "SubItem") & @LF & _
				 "-->State:" & @TAB & DllStructGetData($tInfo, "State") & @LF & _
				 "-->StateMask:" & @TAB & DllStructGetData($tInfo, "StateMask") & @LF & _
				 "-->Text:" & @TAB & DllStructGetData($tBuffer, "Text") & @LF & _
				 "-->TextMax:" & @TAB & DllStructGetData($tInfo, "TextMax") & @LF & _
				 "-->Image:" & @TAB & DllStructGetData($tInfo, "Image") & @LF & _
				 "-->Param:" & @TAB & DllStructGetData($tInfo, "Param") & @LF & _
				 "-->Indent:" & @TAB & DllStructGetData($tInfo, "Indent") & @LF & _
				 "-->GroupID:" & @TAB & DllStructGetData($tInfo, "GroupID") & @LF & _
				 "-->Columns:" & @TAB & DllStructGetData($tInfo, "Columns") & @LF & _
				 "-->pColumns:" & @TAB & DllStructGetData($tInfo, "pColumns") & @CRLF)
	EndSwitch
EndFunc   ;==>WM_NOTIFY
