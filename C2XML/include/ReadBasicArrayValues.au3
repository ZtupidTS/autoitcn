#include <GUIConstants.au3>
#include <ProgressConstants.au3>

Global $RBAV_gui
Global $RBAV_txt_value
Global $RBAV_rdo_string
Global $RBAV_rdo_value
Global $RBAV_lbl

Global $RBAV_guiParent
Global $RBAV_arrLen
Global $RBAV_curChecked
Global $RBAV_xpath

Func ReadBasicArrayValues($guiParent, $structName, $structInst, $memName)
	$RBAV_guiParent = $guiParent
	$RBAV_gui = GUICreate("��������������ֵ", 250, 154, 0, 0, Default, $WS_EX_MDICHILD, $guiParent)
	$RBAV_txt_value = GUICtrlCreateInput("", 8, 8, 233, 21)
	_RBAV_setTextData($objDoc, $structName, $structInst, $memName)
	GUICtrlCreateLabel("�ò���������", 8, 43)
	$RBAV_rdo_string = GUICtrlCreateRadio("�ַ���(&S)", 88, 40)
	GUICtrlSetOnEvent(-1, "RBAV_rdoString")
	GUICtrlSetState(-1, $GUI_CHECKED)
	$RBAV_curChecked = $RBAV_rdo_string
	$RBAV_rdo_value = GUICtrlCreateRadio("��ֵ(&V)", 168, 40)
	GUICtrlSetOnEvent(-1, "RBAV_rdoValue")
	$RBAV_arrLen = _RBAV_getArrayLength($objDoc, $structName, $structInst, $memName)
	$RBAV_lbl = GUICtrlCreateLabel("����һ���ַ��������е��ַ����������ַ��������Ȳ�����" & _
		$RBAV_arrLen, 8, 64, 232, 41)
	Local $hk[2][2]
	$hk[0][0] = "{enter}"
	$hk[0][1] = GUICtrlCreateButton("ȷ��", 88, 120, 75, 25, 0)
	GUICtrlSetOnEvent(-1, "RBAV_okClicked")
	$hk[1][0] = "{esc}"
	$hk[1][1] = GUICtrlCreateButton("ȡ��", 168, 120, 75, 25, 0)
	GUICtrlSetOnEvent(-1, "RBAV_cancelClicked")
	GUISetAccelerators($hk, $RBAV_gui)
	GUISetState(@SW_DISABLE, $RBAV_guiParent)
	GUISetState(@SW_SHOW, $RBAV_gui)
	$RBAV_xpath = "/simulator/structs/struct[@name='" & $structName & "' and @instance='" & _
		$structInst & "']/member[@name='" & $memName & "']"
EndFunc

Func RBAV_okClicked()
	Local $valNodeCount = _XMLDeleteNode($RBAV_xpath & "/value")
	Local $delimiter = ""
	Local $i
	If $RBAV_curChecked == $RBAV_rdo_value Then
		$delimiter = ","
	EndIf
	Local $values = StringSplit(GUICtrlRead($RBAV_txt_value), $delimiter)
	If $RBAV_curChecked == $RBAV_rdo_string Then
		For $i = 1 To $values[0]
			$values[$i] = Asc($values[$i])
		Next
	EndIf
	ReDim $values[$valNodeCount+1]
	For $i = $values[0]+1 To $valNodeCount
		$values[$i] = 0
	Next
	
	Local $gui_progress = GUICreate("������������Ա", 242, 55, 0, 0, _
		$WS_POPUP + $WS_CAPTION, $WS_EX_MDICHILD, $RBAV_gui)
	Local $progress = GUICtrlCreateProgress(4, 8, 234, 16, BitOR($PBS_SMOOTH,$WS_BORDER))
	Local $lbl_stat = GUICtrlCreateLabel("״̬��             ", 8, 32)
	GUISetState(@SW_SHOW, $gui_progress)
	GUISetState(@SW_DISABLE, $RBAV_gui)
	$values[0] = $valNodeCount
	For $i = 1 To $valNodeCount
		_XMLCreateChildNode($RBAV_xpath, "value")
		$values[$i] = StringStripWS($values[$i], 3)
		_XMLSetAttrib($RBAV_xpath & "/value", "value", $values[$i], $i-1)
		GUICtrlSetData($progress, Int(($i/$valNodeCount)*100))
		GUICtrlSetData($lbl_stat, "״̬��" & $i & " / " & $valNodeCount)
	Next
	GUISetState(@SW_ENABLE, $RBAV_gui)
	GUIDelete($gui_progress)
	RBAV_cancelClicked()
EndFunc

Func RBAV_cancelClicked()
	GUISetState(@SW_ENABLE, $RBAV_guiParent)
	GUIDelete($RBAV_gui)
EndFunc

Func RBAV_rdoString()
	If $RBAV_curChecked == $RBAV_rdo_string Then Return
	Local $iMsgBoxAnswer = MsgBox($MSG_BOX_QUESTION_YESNO,"��������ת��","�����������������õĲ��ɼ�ASCֵ��ʧ��" & @CRLF & "�Ƿ������")
	Select
		Case $iMsgBoxAnswer = 6 ;Yes
			; go on
		Case $iMsgBoxAnswer = 7 ;No
			GUICtrlSetState($RBAV_rdo_value, $GUI_CHECKED)
			Return
	EndSelect
	$RBAV_curChecked = $RBAV_rdo_string
	GUICtrlSetData($RBAV_lbl, "����һ���ַ��������е��ַ����������ַ��������Ȳ�����" & $RBAV_arrLen & _
		"�����㲿�ֽ�����0�Զ���䡣")
	Local $string = StringSplit(GUICtrlRead($RBAV_txt_value), ",")
	If Not IsArray($string) Or $string[0] == 0 Then
		GUICtrlSetData($RBAV_txt_value, "")
		Return
	EndIf
	Local $i, $str = ""
	For $i = 1 To $string[0]
		If $string[$i] < 31 Or $string[$i] > 126 Then ContinueLoop
		$str &= Chr($string[$i])
	Next
	GUICtrlSetData($RBAV_txt_value, $str)
EndFunc

Func RBAV_rdoValue()
	If $RBAV_curChecked == $RBAV_rdo_value Then Return
	$RBAV_curChecked = $RBAV_rdo_value
	GUICtrlSetData($RBAV_lbl, "����һЩ���֣���Ӣ�Ķ���( ,)���������Ȳ�����" & $RBAV_arrLen & _
		"�����㲿�ֽ�����0�Զ���䡣")
	Local $string = StringSplit(GUICtrlRead($RBAV_txt_value), "")
	If Not IsArray($string) Or $string[0] == 0 Then
		GUICtrlSetData($RBAV_txt_value, "")
		Return
	EndIf
	Local $i, $str = ""
	For $i = 1 To $string[0]
		$str &= Asc($string[$i]) & ", "
	Next
	GUICtrlSetData($RBAV_txt_value, StringLeft($str, StringLen($str)-2))
EndFunc

Func _RBAV_getArrayLength($xml, $structName, $structInst, $memName)
	Local $xpath = "/simulator/structs/struct[@name='" & _
		$structName & "' and @instance='" & $structInst & "']/member[@name='" & $memName & "']/value"
	Local $items = $xml.SelectNodes($xpath)
	Return $items.Length
EndFunc

Func _RBAV_setTextData($xml, $structName, $structInst, $memName)
	Local $xpath = "/simulator/structs/struct[@name='" & _
		$structName & "' and @instance='" & $structInst & "']/member[@name='" & $memName & "']/value"
	Local $items = $xml.SelectNodes($xpath), $item, $str = "", $value
	For $item In $items
		$value = $item.GetAttribute("value")
		If $value < 32 Or $value > 126 Then ContinueLoop
		$str &=  Chr($value)
	Next
	GUICtrlSetData($RBAV_txt_value, $str)
EndFunc
