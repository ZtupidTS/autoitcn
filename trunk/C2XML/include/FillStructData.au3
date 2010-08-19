;~ #Include <GuiEdit.au3>

#include <WindowsConstants.au3>
#include <GuiListView.au3>
;~ #include <GuiListBox.au3>
#include <Array.au3>
#include "common.au3"
#include "ReadBasicArrayValues.au3"
;

Global $FSD_checkedInstances[1] = [0]

Func FillStructData($guiParent, $name, $inst, $isArray = False)
	Local $thisGui = GUICreate('填充数据 "' & $name & '"', 640, 455, 0, 0, Default, $WS_EX_MDICHILD, $guiParent)
	Local $curInst = StringReplace(_GUICtrlListView_getSelectedItemText($FSD_lv_instance), $STR_INSTANCE, "")
	$FSD_lv_instance = GUICtrlGetHandle(GUICtrlCreateListView("", 1, 0, 130, 225, _
			BitOR($LVS_REPORT, $LVS_SHOWSELALWAYS, $LVS_NOSORTHEADER, $LVS_SINGLESEL), $WS_EX_CLIENTEDGE))
	Local $extStyle = BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES)
	If $isArray Then $extStyle = BitOR($extStyle, $LVS_EX_CHECKBOXES)
	_GUICtrlListView_SetExtendedListViewStyle($FSD_lv_instance, $extStyle)
	_GUICtrlListView_AddColumn($FSD_lv_instance, "已配置的实例", 120)
	Local $hk[4][2]
	GUICtrlCreateGroup("操作", 1, 233, 130, 220)
	GUICtrlCreateLabel("选择已配置的实例列表中的实例来修改前一个结构的对应字段的值。" & @CRLF & _
			"双击结构成员可以编辑成员的值。" & @CRLF & _
			"你还可以：", 6, 248, 120, 80)
	$hk[0][0] = "^{a}"
	$hk[0][1] = GUICtrlCreateButton("添加实例(&A)", 7, 333, 118, 25)
	GUICtrlSetOnEvent(-1, "FSD_addInstace")
	GUICtrlSetTip(-1, "快捷键：Ctrl+A")
	$hk[1][0] = "^{d}"
	$hk[1][1] = GUICtrlCreateButton("删除实例(&D)", 7, 360, 118, 25)
	GUICtrlSetOnEvent(-1, "FSD_delInstace")
	GUICtrlSetTip(-1, "快捷键：Ctrl+D")
	$hk[2][0] = "^{s}"
	$hk[2][1] = GUICtrlCreateButton("保存修改(&S)", 7, 387, 118, 25)
	GUICtrlSetOnEvent(-1, "FSD_saveChangedDataMember")
	GUICtrlSetTip(-1, "快捷键：Ctrl+S")
	$hk[3][0] = "{enter}"
	$hk[3][1] = GUICtrlCreateButton("保存并关闭(Enter)", 7, 421, 118, 25)
	GUICtrlSetOnEvent(-1, "handleEventClose")
	GUICtrlSetTip(-1, "快捷键：Enter")
	GUISetAccelerators($hk, $thisGui)
	Local $memName = _GUICtrlListView_getSelectedItemText($FSD_lv, 1)
	$FSD_lv = GUICtrlGetHandle(GUICtrlCreateListView("", 133, 0, 506, 453, _
			BitOR($LVS_REPORT, $LVS_SHOWSELALWAYS, $LVS_EDITLABELS, $LVS_NOSORTHEADER, $LVS_SINGLESEL), $WS_EX_CLIENTEDGE))
	_GUICtrlListView_SetExtendedListViewStyle($FSD_lv, _
			BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES))
	_GUICtrlListView_AddColumn($FSD_lv, "值/实例", 60)
	_GUICtrlListView_AddColumn($FSD_lv, "成员", 170)
	_GUICtrlListView_AddColumn($FSD_lv, "类型", 170)
	_GUICtrlListView_AddColumn($FSD_lv, "数组", 40)
	_GUICtrlListView_AddColumn($FSD_lv, "状态", 40)
	_FSD_initInstanceList($objDoc, $name, $inst)
	If $isArray Then
		_FSD_initMembersArray($objDoc, _
				$FSD_parentStructNameStack[UBound($FSD_parentStructNameStack) - 1], $curInst, $memName)
	Else
		_FSD_initMembers($objDoc, $name, $inst)
	EndIf
;~ 	GUISetOnEvent($GUI_EVENT_CLOSE, "handleEventClose")
	GUISetState(@SW_DISABLE, $guiParent)
	GUISetState(@SW_SHOW, $thisGui)
	_ArrayAdd($FSD_parentStructNameStack, $name)
	_ArrayAdd($FSD_lvStack, $FSD_lv)
	_ArrayAdd($FSD_lvInstStack, $FSD_lv_instance)
	_ArrayAdd($guiStack, $thisGui)
	_ArrayAdd($FSD_memDataStack, $FSD_memData)
EndFunc   ;==>FillStructData

Func FSD_instListviewClicked()
	Local $selText = _GUICtrlListView_getSelectedItemText($FSD_lv_instance)
	Local $inst = StringReplace($selText, $STR_INSTANCE, "")
	_GUICtrlListView_SetItemSelected($FSD_lv_instance, _GUICtrlListView_FindText($FSD_lv_instance, $selText, 0, False))
	If $FSD_memData[$FSD_memData[0]+1] == $inst Then Return
	Local $i, $value
	For $i = 1 To $FSD_memData[0]
		$value = _GUICtrlListView_GetItemText($FSD_lv, $i - 1)
		If $value == $FSD_memData[$i] Then ContinueLoop
		Local $iMsgBoxAnswer = _
				MsgBox($MSG_BOX_QUESTION_YESNOCANCEL, "确认", "这个动作会导致已经修改的数据丢失，" & @CRLF & _
				"是否保存修改？", 0, $guiStack[UBound($guiStack) - 1])
		Select
			Case $iMsgBoxAnswer = 6 ;Yes
				FSD_saveChangedDataMember()
				ExitLoop
			Case $iMsgBoxAnswer = 7 ;No
				ExitLoop
			Case $iMsgBoxAnswer = 2 ;Cancel
				_GUICtrlListView_SetItemSelected($FSD_lv_instance, $FSD_memData[$FSD_memData[0] + 1])
				Return
		EndSelect
	Next
	_FSD_initMembers($objDoc, $FSD_parentStructNameStack[UBound($FSD_parentStructNameStack) - 1], $inst)
EndFunc   ;==>FSD_instListviewClicked

Func FSD_memListviewClicked()
	Local $isArray = _GUICtrlListView_getSelectedItemText($FSD_lv, 3)
	Local $type = _GUICtrlListView_getSelectedItemText($FSD_lv, 2)
	If $type == 0 Or $type == "" Then Return
	If $isArray == "是" Then
		If _isBasicType($type) Then
			ReadBasicArrayValues( _
					$guiStack[UBound($guiStack) - 1], _
					$FSD_parentStructNameStack[UBound($FSD_parentStructNameStack) - 1], _
					StringReplace(_GUICtrlListView_getSelectedItemText($FSD_lv_instance), $STR_INSTANCE, ""), _
					_GUICtrlListView_getSelectedItemText($FSD_lv, 1))
		Else
			FillStructData($guiStack[UBound($guiStack) - 1], $type, _GUICtrlListView_getSelectedItemText($FSD_lv, 0), True)
		EndIf
	Else
		If _isBasicType($type) Then
			
		Else
			FillStructData($guiStack[UBound($guiStack) - 1], $type, _GUICtrlListView_getSelectedItemText($FSD_lv, 0))
		EndIf
	EndIf
	
EndFunc   ;==>FSD_memListviewClicked

Func FSD_addInstace()
	Local $struct = $FSD_parentStructNameStack[UBound($FSD_parentStructNameStack) - 1]
	Local $xpath = "/simulator/structs_def/struct[@name='" & $struct & "']/member"
	Local $items = $objDoc.SelectNodes($xpath), $item, $thisGui = $guiStack[UBound($guiStack) - 1]
	If $items.Length <= 0 Then
		MsgBox($MSG_BOX_ALERT_OK, "添加实例", _
				"目标结构信息不存在。发生这个错误一般是由于本xml文件被手工编辑过，" & @CRLF & _
				"误删了struct_def中的内容。请手工添加这部分信息或者使用本工具分析" & @CRLF & _
				"对应的h文件得到一个正确的xml。", Default, $thisGui)
		Return
	EndIf
	;InputBox features: Title=Yes, Prompt=Yes, Default Text=No, Mandatory, Width=250, Height=120
	Local $sInputBoxAnswer
	$sInputBoxAnswer = InputBox("添加实例", "请输入一个正整数作为实例号。", _
			"0", " M4", "250", "120", "-1", "-1", Default, $thisGui)
	If @error == 0 Then
		$sInputBoxAnswer = Number($sInputBoxAnswer)
		$xpath = "/simulator/structs/struct[@name='" & $struct & "' and @instance='" & $sInputBoxAnswer & "']"
		If _XMLNodeExists($xpath) Then
			MsgBox($MSG_BOX_ALERT_OK, "添加实例", "待新增的实例号" & $sInputBoxAnswer & _
					"已经存在，" & @CRLF & "请输入一个未被占用的实例号。", Default, $thisGui)
			Return
		EndIf
	Else
		Return
	EndIf
	
	Local $structs = _XMLGetChildNodes("/simulator/structs")
	Local $idx
	If IsArray($structs) Then
		$idx = $structs[0]
	Else
		$idx = 0
	EndIf
	_XMLCreateChildNode("/simulator/structs", "struct")
	_XMLSetAttrib("/simulator/structs/struct", "name", $struct, $idx)
	_XMLSetAttrib("/simulator/structs/struct", "instance", $sInputBoxAnswer, $idx)
	
	Local $gui_progress = GUICreate("正在添加一个实例", 242, 55, 0, 0, _
			$WS_POPUP + $WS_CAPTION, $WS_EX_MDICHILD, $thisGui)
	Local $progress = GUICtrlCreateProgress(4, 8, 234, 16, BitOR($PBS_SMOOTH, $WS_BORDER))
	Local $lbl_stat = GUICtrlCreateLabel("状态：             ", 8, 32)
;~ 	Local $thisGui = $guiStack[UBound($guiStack) - 1]
	GUISetState(@SW_SHOW, $gui_progress)
	GUISetState(@SW_DISABLE, $thisGui)
	
	$xpath = "/simulator/structs/struct[@name='" & $struct & "' and @instance='" & $sInputBoxAnswer & "']"
	Local $i = 0, $j = 0, $arrLen, $memName, $type, $attr = "", $total = $items.Length, $n = 1
	For $item In $items
		_XMLCreateChildNode($xpath, "member")
		$memName = $item.GetAttribute("name")
		_XMLSetAttrib($xpath & "/member", "name", $memName, $i)
		$type = $item.GetAttribute("type")
		_XMLSetAttrib($xpath & "/member", "type", $type, $i)
		
		GUICtrlSetData($progress, Int(($n / $total) * 100))
		GUICtrlSetData($lbl_stat, "状态：" & $n & " / " & $total)
		$n += 1
		
		$arrLen = $item.GetAttribute("array_len")
		If _isBasicType($type) Then
			$attr = "value"
		Else
			$attr = "instance"
		EndIf
		If $arrLen == "" Then $arrLen = 0
		If $arrLen > 0 Then
			$total += $arrLen
			For $j = 0 To $arrLen - 1
				_XMLCreateChildNode($xpath & "/member[@name='" & $memName & "']", "value")
				_XMLSetAttrib($xpath & "/member[@name='" & $memName & "']/value", $attr, "0", $j)
				GUICtrlSetData($progress, Int(($n / $total) * 100))
				GUICtrlSetData($lbl_stat, "状态：" & $n & " / " & $total)
				$n += 1
			Next
		Else
			_XMLSetAttrib($xpath & "/member", $attr, "0", $i)
		EndIf
		$i += 1
	Next
	_GUICtrlListView_AddItem($FSD_lv_instance, $STR_INSTANCE & $sInputBoxAnswer)
	Local $parentLvMem = $FSD_lvStack[UBound($FSD_lvStack) - 2]
	$idx = _GUICtrlListView_getSelectedItemIndex($parentLvMem)
	Local $isArray = _GUICtrlListView_GetItemText($parentLvMem, $idx, 3)
	If _GUICtrlListView_GetItemCount($FSD_lv_instance) == 1 Then
		_GUICtrlListView_SetItemSelected($FSD_lv_instance, 0)
		_FSD_initMembers($objDoc, $struct, $sInputBoxAnswer)
		If $isArray == "是" Then _GUICtrlListView_SetItemChecked($FSD_lv_instance, 0)
	EndIf
	GUISetState(@SW_ENABLE, $thisGui)
	GUIDelete($gui_progress)
EndFunc   ;==>FSD_addInstace

Func FSD_delInstace()
	If _GUICtrlListView_GetItemCount($FSD_lv_instance) == 1 Then
		MsgBox($MSG_BOX_INFO_OK, "删除实例", "最后一个实例不允许被删除。", Default, $guiStack[UBound($guiStack) - 1])
		Return
	EndIf
	Local $inst = StringReplace(_GUICtrlListView_getSelectedItemText($FSD_lv_instance), $STR_INSTANCE, "")
	If $inst == "" Then
		MsgBox($MSG_BOX_INFO_OK, "删除实例", "请选择一个实例再试。", Default, $guiStack[UBound($guiStack) - 1])
		Return
	EndIf
	Local $struct = $FSD_parentStructNameStack[UBound($FSD_parentStructNameStack) - 1]
	Local $iMsgBoxAnswer = _
			MsgBox($MSG_BOX_QUESTION_YESNO, "确认", "即将删除" & @CRLF & _
			$struct & "的" & $inst & "号实例" & @CRLF & _
			"是否继续？", 0, $guiStack[UBound($guiStack) - 1])
	Select
		Case $iMsgBoxAnswer = 6 ;Yes
			; go on
		Case $iMsgBoxAnswer = 7 ;No
			Return
	EndSelect
	Local $xpath = "/simulator/structs/struct[@name='" & $struct & "' and @instance='" & $inst & "']"
	_XMLDeleteNode($xpath)
	_GUICtrlListView_DeleteItem($FSD_lv_instance, _GUICtrlListView_getSelectedItemIndex($FSD_lv_instance))
			
	Local $parentLvMem = $FSD_lvStack[UBound($FSD_lvStack) - 2]
	Local $idx = _GUICtrlListView_getSelectedItemIndex($parentLvMem)
	Local $isArray = _GUICtrlListView_GetItemText($parentLvMem, $idx, 3)
	Local $i
	If $isArray == "是" Then
		For $i = 0 To _GUICtrlListView_GetItemCount($FSD_lv_instance)-1
			If Not _GUICtrlListView_GetItemChecked($FSD_lv_instance, $i) Then ContinueLoop
			_GUICtrlListView_SetItemSelected($FSD_lv_instance, $i)
			_FSD_initMembers($objDoc, $struct, _
					StringReplace(_GUICtrlListView_GetItemText($FSD_lv_instance, $i), $STR_INSTANCE, ""))
			Return
		Next
		_GUICtrlListView_SetItemSelected($FSD_lv_instance, 0)
		_GUICtrlListView_SetItemChecked($FSD_lv_instance, 0)
		_FSD_initMembers($objDoc, $struct, _
				StringReplace(_GUICtrlListView_GetItemText($FSD_lv_instance, 0), $STR_INSTANCE, ""))
	Else
		_GUICtrlListView_SetItemSelected($FSD_lv_instance, 0)
		_FSD_initMembers($objDoc, $struct, _
				StringReplace(_GUICtrlListView_GetItemText($FSD_lv_instance, 0), $STR_INSTANCE, ""))
	EndIf
EndFunc   ;==>FSD_delInstace

Func FSD_saveChangedData()
	Local $parentGUI = $guiStack[UBound($guiStack) - 2]
	Local $parentLvMem = $FSD_lvStack[UBound($FSD_lvStack) - 2]
	Local $idx = _GUICtrlListView_getSelectedItemIndex($parentLvMem)
	Local $memName = _GUICtrlListView_GetItemText($parentLvMem, $idx, 1)
	Local $struct = $FSD_parentStructNameStack[UBound($FSD_parentStructNameStack) - 2]
	Local $isArray = _GUICtrlListView_GetItemText($parentLvMem, $idx, 3)
	Local $parentLvInst = $FSD_lvInstStack[UBound($FSD_lvInstStack) - 2]
	Local $parentInst = StringReplace(_GUICtrlListView_getSelectedItemText($parentLvInst), $STR_INSTANCE, "")
	Local $instArr[2], $inst, $xpath, $i, $value, $event
	Local $valNodeCount, $thisGui = $guiStack[UBound($guiStack) - 1]
	
	If $isArray == "是" Then
		If _FSD_checkHasStructArrayStatusChanged() Then
			$instArr = _FSD_getCheckedInstanceArr()
			If $instArr[0] > 0 Then
				$xpath = "/simulator/structs/struct[@name='" & $struct & "' and @instance='" & _
						$parentInst & "']/member[@name='" & $memName & "']"
				$valNodeCount = _XMLDeleteNode($xpath & "/value")
				If $instArr[0] > $valNodeCount Then MsgBox($MSG_BOX_ALERT_OK, "警告", _
						"选择的实例个数多于字段" & @CRLF & $struct & "(" & $parentInst & ")." & $memName & @CRLF & _
						"能容纳的最多实例个数，实例号比较大的实例将被忽略。", 0, $thisGui)
				ReDim $instArr[$valNodeCount + 1] ; 多退少补
				For $i = $instArr[0] + 1 To $valNodeCount
					$instArr[$i] = 65535
				Next
				Local $gui_progress = GUICreate("正在添加数组成员", 242, 55, 0, 0, _
						$WS_POPUP + $WS_CAPTION, $WS_EX_MDICHILD, $thisGui)
				Local $progress = GUICtrlCreateProgress(4, 8, 234, 16, BitOR($PBS_SMOOTH, $WS_BORDER))
				Local $lbl_stat = GUICtrlCreateLabel("状态：             ", 8, 32)
				GUISetState(@SW_SHOW, $gui_progress)
				GUISetState(@SW_DISABLE, $thisGui)
				For $i = 1 To $valNodeCount
					_XMLCreateChildNode($xpath, "value")
					_XMLSetAttrib($xpath & "/value", "instance", $instArr[$i], $i - 1)
					GUICtrlSetData($progress, Int(($i / $valNodeCount) * 100))
					GUICtrlSetData($lbl_stat, "状态：" & $i & " / " & $valNodeCount)
				Next
				GUISetState(@SW_ENABLE, $thisGui)
				GUIDelete($gui_progress)
			Else
				MsgBox($MSG_BOX_ALERT_OK, "警告", "结构数组的值，必须至少拥有一个合法的实例，" & @CRLF & _
					"刚刚的修改不会被保存。", Default, $thisGui)
			EndIf
		EndIf
	Else
		If $parentGUI == $gui Then
			$event = _GUICtrlListView_getSelectedItemText($h_lv_event)
			$struct = _GUICtrlListView_getSelectedItemText($h_lv_event, 1)
			$xpath = "/simulator/events/event[@id='" & $event & "' and @if='" & $struct & "']"
			$inst = StringReplace(_GUICtrlListView_getSelectedItemText($FSD_lv_instance), $STR_INSTANCE, "")
			$idx = _GUICtrlListView_getSelectedItemIndex($h_lv_event)
			If $inst == "" Then
				$inst = -1
				_GUICtrlListView_SetItemText($h_lv_event, $idx, "×", 3)
				_GUICtrlListView_SetItemText($parentLvMem, _
						_GUICtrlListView_getSelectedItemIndex($parentLvMem), "×", 4)
			EndIf
			_XMLSetAttrib($xpath, "instance", $inst)
			_GUICtrlListView_SetItemText($h_lv_event, $idx, $inst, 2)
		Else
			$inst = StringReplace(_GUICtrlListView_getSelectedItemText($FSD_lv_instance), $STR_INSTANCE, "")
			$xpath = "/simulator/structs/struct[@name='" & $struct & "' and @instance='" & _
					$parentInst & "']/member[@name='" & $memName & "']"
			_XMLSetAttrib($xpath, "instance", $inst)
			If $inst == "" Then $inst = -1
			_GUICtrlListView_SetItemText($parentLvMem, $idx, $inst)
		EndIf
	EndIf
	
	_GUICtrlListView_AddSubItem($parentLvMem, $idx, _FSD_checkMemberStatus($objDoc, $struct, $parentInst, $memName), 4)
	
	ReDim $FSD_checkedInstances[1]
	$FSD_checkedInstances[0] = 0
	For $i = 0 To _GUICtrlListView_GetItemCount($parentLvInst) - 1
		If _GUICtrlListView_GetItemChecked($parentLvInst, $i) Then
			$FSD_checkedInstances[0] += 1
			ReDim $FSD_checkedInstances[$FSD_checkedInstances[0] + 1]
			$FSD_checkedInstances[$FSD_checkedInstances[0]] = $i
		EndIf
	Next
	
	If IsArray($FSD_memData) Then
		For $i = 1 To $FSD_memData[0]
			$value = _GUICtrlListView_GetItemText($FSD_lv, $i - 1)
			If $value == $FSD_memData[$i] Then ContinueLoop
			Local $iMsgBoxAnswer = _
					MsgBox($MSG_BOX_QUESTION_YESNO, "确认", "结构成员数据已经修改，是否保存？", 0, $guiStack[UBound($guiStack) - 1])
			Select
				Case $iMsgBoxAnswer = 6 ;Yes
					FSD_saveChangedDataMember()
				Case $iMsgBoxAnswer = 7 ;No
					; go on
			EndSelect
			ExitLoop
		Next
	EndIf
EndFunc   ;==>FSD_saveChangedData

Func FSD_saveChangedDataMember()
	Local $parentLvMem = $FSD_lvStack[UBound($FSD_lvStack) - 2]
	Local $idx = _GUICtrlListView_getSelectedItemIndex($parentLvMem)
	Local $curStruct
	If $parentLvMem == 0 Then ; 父亲是主窗口，用别的办法得到 $curStruct
		$idx = _GUICtrlListView_getSelectedItemIndex($h_lv_event)
		$curStruct = _GUICtrlListView_GetItemText($h_lv_event, $idx, 1)
	Else
		$curStruct = _GUICtrlListView_GetItemText($parentLvMem, $idx, 2)
	EndIf
	Local $curInst = $FSD_memData[$FSD_memData[0] + 1]
	
	Local $xpath = "/simulator/structs/struct[@name='" & $curStruct & "' and @instance='" & $curInst & "']/member[@name='"
	Local $memName, $memValue
	ReDim $FSD_memData[_GUICtrlListView_GetItemCount($FSD_lv)+2]
	$FSD_memData[0]=_GUICtrlListView_GetItemCount($FSD_lv)
	For $i = 0 To _GUICtrlListView_GetItemCount($FSD_lv)-1
		If _GUICtrlListView_GetItemText($FSD_lv, $i, 3) == "是" Then ContinueLoop
		$memName = _GUICtrlListView_GetItemText($FSD_lv, $i, 1)
		$memValue = _GUICtrlListView_GetItemText($FSD_lv, $i)
		$FSD_memData[$i + 1] = $memValue
		_XMLSetAttrib($xpath & $memName & "']", "value", $memValue)
	Next
	$FSD_memData[$FSD_memData[0]+1] = $curStruct
EndFunc   ;==>FSD_saveChangedDataMember

Func _FSD_initMembers($xml, $name, $inst)
	If Not IsArray($FSD_memData) Then
		Dim $FSD_memData[2]
	Else
		ReDim $FSD_memData[2]
	EndIf
	$FSD_memData[0] = 0
	$FSD_memData[1] = -1
	Local $xpath = "/simulator/structs/struct[@name='" & $name & "' and @instance='" & $inst & "']/member"
	Local $items = $xml.SelectNodes($xpath)
	If $items.Length <= 0 Then Return
	_GUICtrlListView_DeleteAllItems($FSD_lv)
	Local $i = 0, $item, $valItems, $type, $subName, $value
	For $item In $items
		$type = $item.GetAttribute("type")
		$subName = $item.GetAttribute("name")
		If _isBasicType($type) Then
			$value = $item.GetAttribute("value")
			_GUICtrlListView_AddItem($FSD_lv, $value)
			_GUICtrlListView_AddSubItem($FSD_lv, $i, "√", 4)
		Else
			$value = $item.GetAttribute("instance")
			If $value == "" Then $value = 0
			_GUICtrlListView_AddItem($FSD_lv, $value)
			_GUICtrlListView_AddSubItem($FSD_lv, $i, _FSD_checkMemberStatus($xml, $name, $inst, $subName), 4)
		EndIf
		$FSD_memData[0] += 1
		ReDim $FSD_memData[$FSD_memData[0] + 1]
		$FSD_memData[$FSD_memData[0]] = $value
		_GUICtrlListView_AddSubItem($FSD_lv, $i, $subName, 1)
		_GUICtrlListView_AddSubItem($FSD_lv, $i, $type, 2)
		$valItems = $xml.SelectNodes($xpath & "[@name='" & $subName & "']/value")
		If $valItems.Length > 0 Then ; 是一个数组
			_GUICtrlListView_SetItemText($FSD_lv, $i, "{...}")
			_GUICtrlListView_AddSubItem($FSD_lv, $i, "是", 3)
			$FSD_memData[$FSD_memData[0]] = "{...}"
		Else
			_GUICtrlListView_AddSubItem($FSD_lv, $i, "否", 3)
		EndIf
		$i += 1
	Next
	; 最后一个元素放前一个实例值
	ReDim $FSD_memData[$FSD_memData[0] + 2]
	$FSD_memData[$FSD_memData[0] + 1] = $inst
	
;~ 	_FSD_printArray($FSD_memData, "$FSD_memData")
	
EndFunc   ;==>_FSD_initMembers

Func _FSD_initMembersArray($xml, $structName, $curInst, $memName)
	Local $xpath = "/simulator/structs/struct[@name='" & _
			$structName & "' and @instance='" & $curInst & "']/member[@name='" & $memName & "']"
	Local $items = $xml.SelectNodes($xpath & "/value"), $item, $inst, $curSelIdx
	Local $firstInst = -1
	ReDim $FSD_checkedInstances[1]
	$FSD_checkedInstances[0] = 0
	For $item In $items
		$inst = $item.GetAttribute("instance")
		If $inst == 65535 Then ContinueLoop
		$curSelIdx = _GUICtrlListView_FindText($FSD_lv_instance, $STR_INSTANCE & $inst, 0, False)
		_GUICtrlListView_SetItemChecked($FSD_lv_instance, $curSelIdx)
		If $firstInst == -1 Then
			$firstInst = $inst
			_GUICtrlListView_SetItemSelected($FSD_lv_instance, $curSelIdx)
		EndIf
		$FSD_checkedInstances[0] += 1
		ReDim $FSD_checkedInstances[$FSD_checkedInstances[0] + 1]
		$FSD_checkedInstances[$FSD_checkedInstances[0]] = $curSelIdx
	Next
;~ 	_FSD_printArray($FSD_checkedInstances, "$FSD_checkedInstances")
	Local $name = _XMLGetAttrib($xpath, "type")
	_FSD_initMembers($xml, $name, $firstInst)
EndFunc   ;==>_FSD_initMembersArray

Func _FSD_initInstanceList($xml, $name, $selectedInst)
	Local $xpath = "/simulator/structs/struct[@name='" & $name & "']"
	Local $items = $xml.SelectNodes($xpath), $item
	Local $instArr[$items.Length+1], $i = 1
	$instArr[0] = $items.Length
	For $item In $items
		$instArr[$i] = $item.GetAttribute("instance")
		$i += 1
	Next
	_ArraySort($instArr, 0, 1, $items.Length)
	
;~ 	Local $firstInst = -1
	For $i = 1 To $instArr[0]
;~ 		If $instArr[$i] == "" Then $inst = 65535
		_GUICtrlListView_AddItem($FSD_lv_instance, $STR_INSTANCE & $instArr[$i])
	Next
;~ 	For $item In $items
;~ 		$inst = $item.GetAttribute("instance")
;~ 		If $inst == "" Then $inst = 65535
;~ 		_GUICtrlListView_AddItem($FSD_lv_instance, $STR_INSTANCE & $inst)
;~ 	Next
	Local $curSelIdx = _GUICtrlListView_FindText($FSD_lv_instance, $STR_INSTANCE & $selectedInst, 0, False)
	_GUICtrlListView_SetItemSelected($FSD_lv_instance, $curSelIdx)
;~ 	_GUICtrlListView_SortItems($FSD_lv_instance, 1)
EndFunc   ;==>_FSD_initInstanceList

Func _FSD_getCheckedInstanceArr()
	Local $arr[1] = [0]
	Local $i
	For $i = 0 To _GUICtrlListView_GetItemCount($FSD_lv_instance) - 1
		If Not _GUICtrlListView_GetItemChecked($FSD_lv_instance, $i) Then ContinueLoop
		$arr[0] += 1
		ReDim $arr[$arr[0] + 1]
		$arr[$arr[0]] = StringReplace(_GUICtrlListView_GetItemText($FSD_lv_instance, $i), $STR_INSTANCE, "")
	Next
	Return $arr
EndFunc   ;==>_FSD_getCheckedInstanceArr

Func _FSD_checkHasStructArrayStatusChanged()
;~ 	_FSD_printArray($FSD_checkedInstances, "$FSD_checkedInstances")
	Local $i, $j, $flag
	For $i = 1 To $FSD_checkedInstances[0]
		If Not _GUICtrlListView_GetItemChecked($FSD_lv_instance, $FSD_checkedInstances[$i]) Then Return True
	Next
	For $i = 0 To _GUICtrlListView_GetItemCount($FSD_lv_instance) - 1
		If Not _GUICtrlListView_GetItemChecked($FSD_lv_instance, $i) Then ContinueLoop
		$flag = True
		For $j = 1 To $FSD_checkedInstances[0]
			If $i == $FSD_checkedInstances[$j] Then $flag = False
		Next
		If $flag Then Return True
	Next
	Return False
EndFunc   ;==>_FSD_checkHasStructArrayStatusChanged

Func _FSD_checkMemberStatus($xml, $struct, $inst, $memName)
	Local $xpath = "/simulator/structs/struct[@name='" & $struct & "' and @instance='" & $inst & _
		"']/member[@name='" & $memName & "']"
	If _isBasicType(_XMLGetAttrib($xpath, "type")) Then Return "√"
	
	Local $items, $item, $memInst
	Local $memType = _XMLGetAttrib($xpath, "type")
	If _XMLNodeExists($xpath & "/value") Then ; 是一个数组
		$items = $xml.SelectNodes($xpath & "/value")
		For $item In $items
			$memInst = $item.GetAttribute("instance")
			If $memInst == 65535 Then ContinueLoop
			If Not _checkInterfaceStatus($xml, $memType, $memInst) Then Return "×"
		Next
		Return "√"
	Else
		$memInst = _XMLGetAttrib($xpath, "instance")
		If _checkInterfaceStatus($xml, $memType, $memInst) Then
			Return "√"
		Else
			Return "×"
		EndIf
	EndIf
	Return "未知"
EndFunc


Func _FSD_printArray($arr, $msg = "unkown")
	Local $i
	ConsoleWrite("+========== " & $msg & " =============" &@CRLF)
	ConsoleWrite("total: " & UBound($arr) & @CRLF)
	For $i = 0 To UBound($arr)-1
		ConsoleWrite("+num: " & $i & ", data: " & $arr[$i] & @CRLF)
		
	Next
	ConsoleWrite("+=================================" &@CRLF)
EndFunc
