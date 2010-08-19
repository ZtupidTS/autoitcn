#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>

Global $ANE_gui
Global $ANE_cbbEvent
Global $ANE_cbbIf
Global $ANE_txtInst


;~ ANE_addNewEvent(WinGetHandle(""))
;~ While 1
;~ 	Sleep(200)
;~ WEnd

Func ANE_addNewEvent()
	If Not IsObj($objDoc) Then
		_GUICtrlStatusBar_SetText($statusbar, "请打开一个头文件或者xml文件以继续。")
		Return
	EndIf
	$ANE_gui = GUICreate("添加事件号", 275, 123, 0, 0, Default, $WS_EX_MDICHILD, $gui)
	GUICtrlCreateLabel("事件号", 8, 8, 40, 17)
	$ANE_cbbEvent = GUICtrlCreateCombo("", 56, 8, 209, 21)
	_ANE_initEvent()
	GUICtrlCreateLabel("接口", 8, 32, 28, 17)
	$ANE_cbbIf = GUICtrlCreateCombo("", 56, 32, 209, 25)
	_ANE_initIf()
	GUICtrlCreateLabel("实例", 8, 56, 28, 17)
	$ANE_txtInst = GUICtrlCreateInput("0", 56, 56, 209, 25)
	Local $hk[2][2]
	$hk[0][0] = "{enter}"
	$hk[0][1] = GUICtrlCreateButton("确定", 112, 88, 75, 25, 0)
	GUICtrlSetOnEvent(-1, "ANE_ok")
	$hk[1][0] = "{esc}"
	$hk[1][1] = GUICtrlCreateButton("取消", 192, 88, 75, 25, 0)
	GUICtrlSetOnEvent(-1, "ANE_cancel")
	GUISetAccelerators($hk, $ANE_gui)
	GUISetState(@SW_SHOW, $ANE_gui)
	GUISetState(@SW_DISABLE, $gui)
EndFunc

Func ANE_ok()
	Local $event = GUICtrlRead($ANE_cbbEvent)
	If $event == "" Then
		MsgBox($MSG_BOX_ALERT_OK, "添加事件号", "必须输入一个事件号。", 0, $ANE_gui)
		Return
	EndIf
	Local $if = GUICtrlRead($ANE_cbbIf)
	If $if == "" Then
		MsgBox($MSG_BOX_ALERT_OK, "添加事件号", "必须选择一个接口。", 0, $ANE_gui)
		Return
	EndIf
	Local $inst = GUICtrlRead($ANE_txtInst)
	If $inst == "" Then
		MsgBox($MSG_BOX_ALERT_OK, "添加事件号", "必须输入一个实例号。", 0, $ANE_gui)
		Return
	EndIf
	If _ANE_checkEventExists($event, $if, $inst) Then
		MsgBox($MSG_BOX_ALERT_OK, "添加事件号", "对应的配置项已经存在，请重新输入。", 0, $ANE_gui)
		Return
	EndIf
	Local $nodes = _XMLGetChildNodes("/simulator/events")
	Local $idx = 0
	If IsArray($nodes) Then $idx = $nodes[0]
	_XMLCreateChildNode("/simulator/events", "event")
	_XMLSetAttrib("/simulator/events/event", "id", $event, $idx)
	_XMLSetAttrib("/simulator/events/event", "if", $if, $idx)
	_XMLSetAttrib("/simulator/events/event", "instance", $inst, $idx)
	$idx = _GUICtrlListView_GetItemCount($h_lv_event)
	_GUICtrlListView_AddItem($h_lv_event, $event)
	_GUICtrlListView_AddSubItem($h_lv_event, $idx, $if, 1)
	_GUICtrlListView_AddSubItem($h_lv_event, $idx, $inst, 2)
	If _checkInterfaceStatus($objDoc, $if, $inst) Then
		_GUICtrlListView_AddSubItem($h_lv_event, $idx, "√", 3)
	Else
		_GUICtrlListView_AddSubItem($h_lv_event, $idx, "×", 3)
	EndIf
	_GUICtrlStatusBar_SetText($statusbar, "添加接口成功。双击该接口条目进行进一步编辑或者单击“添加事件”按钮继续。")
	ANE_cancel()
EndFunc

Func ANE_cancel()
	GUISetState(@SW_ENABLE, $gui)
	GUIDelete($ANE_gui)
EndFunc

Func _ANE_initIf()
	Local $xpath = "/simulator/structs_def/struct"
	Local $items, $item, $str = "", $def = ""
	$items = $objDoc.SelectNodes($xpath)
	For $item In $items
		$str &= $item.GetAttribute("name") & "|"
		If $def == "" Then $def = $item.GetAttribute("name")
	Next
	GUICtrlSetData($ANE_cbbIf, StringLeft($str, StringLen($str)-1), $def)
EndFunc

Func _ANE_initEvent()
	Local $xpath = "/simulator/events/event"
	Local $items, $item, $def = "", $str = "", $i, $event
	Local $events[1] = [0]
	$items = $objDoc.SelectNodes($xpath)
	For $item In $items
		$event = $item.GetAttribute("id")
;~ 		ConsoleWrite($event & @CRLF)
		For $i = 1 To $events[0]
			If StringLower($events[$i]) == StringLower($event) Then ExitLoop
		Next
		If $i <= $events[0] Then ContinueLoop
		$events[0] += 1
		ReDim $events[$events[0]+1]
		$events[$events[0]] = $event
		$str &= $event & "|"
		If $def == "" Then $def = $event
	Next
	GUICtrlSetData($ANE_cbbEvent, StringLeft($str, StringLen($str)-1), $def)
;~ 	_ArrayDisplay($events)
EndFunc

Func _ANE_checkEventExists($event, $if, $inst)
	Local $xpath = "/simulator/events/event[@id='" & $event & "' and @if='" & $if & "' and @instance='" & $inst & "']"
	Return _XMLNodeExists($xpath)
EndFunc







