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
		_GUICtrlStatusBar_SetText($statusbar, "���һ��ͷ�ļ�����xml�ļ��Լ�����")
		Return
	EndIf
	$ANE_gui = GUICreate("����¼���", 275, 123, 0, 0, Default, $WS_EX_MDICHILD, $gui)
	GUICtrlCreateLabel("�¼���", 8, 8, 40, 17)
	$ANE_cbbEvent = GUICtrlCreateCombo("", 56, 8, 209, 21)
	_ANE_initEvent()
	GUICtrlCreateLabel("�ӿ�", 8, 32, 28, 17)
	$ANE_cbbIf = GUICtrlCreateCombo("", 56, 32, 209, 25)
	_ANE_initIf()
	GUICtrlCreateLabel("ʵ��", 8, 56, 28, 17)
	$ANE_txtInst = GUICtrlCreateInput("0", 56, 56, 209, 25)
	Local $hk[2][2]
	$hk[0][0] = "{enter}"
	$hk[0][1] = GUICtrlCreateButton("ȷ��", 112, 88, 75, 25, 0)
	GUICtrlSetOnEvent(-1, "ANE_ok")
	$hk[1][0] = "{esc}"
	$hk[1][1] = GUICtrlCreateButton("ȡ��", 192, 88, 75, 25, 0)
	GUICtrlSetOnEvent(-1, "ANE_cancel")
	GUISetAccelerators($hk, $ANE_gui)
	GUISetState(@SW_SHOW, $ANE_gui)
	GUISetState(@SW_DISABLE, $gui)
EndFunc

Func ANE_ok()
	Local $event = GUICtrlRead($ANE_cbbEvent)
	If $event == "" Then
		MsgBox($MSG_BOX_ALERT_OK, "����¼���", "��������һ���¼��š�", 0, $ANE_gui)
		Return
	EndIf
	Local $if = GUICtrlRead($ANE_cbbIf)
	If $if == "" Then
		MsgBox($MSG_BOX_ALERT_OK, "����¼���", "����ѡ��һ���ӿڡ�", 0, $ANE_gui)
		Return
	EndIf
	Local $inst = GUICtrlRead($ANE_txtInst)
	If $inst == "" Then
		MsgBox($MSG_BOX_ALERT_OK, "����¼���", "��������һ��ʵ���š�", 0, $ANE_gui)
		Return
	EndIf
	If _ANE_checkEventExists($event, $if, $inst) Then
		MsgBox($MSG_BOX_ALERT_OK, "����¼���", "��Ӧ���������Ѿ����ڣ����������롣", 0, $ANE_gui)
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
		_GUICtrlListView_AddSubItem($h_lv_event, $idx, "��", 3)
	Else
		_GUICtrlListView_AddSubItem($h_lv_event, $idx, "��", 3)
	EndIf
	_GUICtrlStatusBar_SetText($statusbar, "��ӽӿڳɹ���˫���ýӿ���Ŀ���н�һ���༭���ߵ���������¼�����ť������")
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







