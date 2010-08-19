;~ #AutoIt3Wrapper_au3check_parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Constants.au3>
#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <GuiStatusBar.au3>
#include <Array.au3>
#Include <File.au3>
#include "include\_XMLDomWrapper.au3"
#include "include\common.au3"
#include "include\FillStructData.au3"
#include "include\AddNewEvent.au3"

#AutoIt3Wrapper_Icon=Excel X.ico

;~ _replacePreCompiler("E:\AutoItWork\C2XML\preana.h")
;~ Exit

If Not FileExists(@ScriptDir & "\bin\C2XML.exe") Then
	MsgBox($MSG_BOX_CRITICAL_OK,$APP_NAME,"严重错误，文件" & @ScriptDir & "\bin\C2XML.exe不存在！")
	Exit
EndIf


#Region ### START Koda GUI section ### Form=
$gui = GUICreate($APP_NAME, 640, 455)
_ArrayAdd($guiStack, $gui)
GUICtrlCreateLabel("XML文件", 4, 9)
$txt_path = GUICtrlCreateInput("", 50, 5, 529, 21)
GUICtrlCreateButton("浏览(&B)", 583, 5, 50, 22, 0)
GUICtrlSetOnEvent(-1, "browseFile")

GUICtrlCreateButton("解析(&P)", 530, 35, 103, 25, 0)
GUICtrlCreateButton("添加事件(&A)", 530, 65, 103, 25, 0)
GUICtrlSetOnEvent(-1, "ANE_addNewEvent")
GUICtrlCreateButton("删除事件(&D)", 530, 95, 103, 25, 0)
GUICtrlSetOnEvent(-1, "delEvent")
GUICtrlCreateButton("退出(ESC)", 530, 405, 103, 25, 0)
GUICtrlSetOnEvent(-1, "mainGUIClose")
$lv_event = GUICtrlCreateListView("", 2, 35, 520, 400, _
		BitOR($LVS_REPORT, $LVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
$h_lv_event = GUICtrlGetHandle($lv_event)
_GUICtrlListView_SetExtendedListViewStyle($h_lv_event, _
		BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES))
_GUICtrlListView_AddColumn($h_lv_event, "事件号", 100)
_GUICtrlListView_AddColumn($h_lv_event, "接口", 300)
_GUICtrlListView_AddColumn($h_lv_event, "实例", 50)
_GUICtrlListView_AddColumn($h_lv_event, "状态", 50)
;~ _GUICtrlListView_AddItem($h_lv_event, "")

$statusbar = _GUICtrlStatusBar_Create($gui)
_GUICtrlStatusBar_SetText($statusbar, "单击“浏览”按钮打开一个头文件或者继续编辑一个xml文件。")

GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUISetOnEvent($GUI_EVENT_CLOSE, "mainGUIClose")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
;

While 1
	Sleep(200)
WEnd

Func delEvent()
	Local $i, $info[1][3] = [[0, 0, 0]]
	For $i = 0 To _GUICtrlListView_GetItemCount($h_lv_event)-1
		If Not _GUICtrlListView_GetItemSelected($h_lv_event, $i) Then ContinueLoop
		$info[0][0] += 1
		ReDim $info[$info[0][0]+1][3]
		$info[$info[0][0]][0] = _GUICtrlListView_GetItemText($h_lv_event, $i)
		$info[$info[0][0]][1] = _GUICtrlListView_GetItemText($h_lv_event, $i, 1)
		$info[$info[0][0]][2] = _GUICtrlListView_GetItemText($h_lv_event, $i, 2)
	Next
	If $info[0][0] == 0 Then Return
	Local $iMsgBoxAnswer = _
			MsgBox($MSG_BOX_QUESTION_NOYES, "删除事件", "即将删除" & $info[0][0] & "个事件，" & @CRLF & _
			"是否继续？", 0, $guiStack[UBound($guiStack) - 1])
	Select
		Case $iMsgBoxAnswer = 6 ;Yes
			; go on
		Case $iMsgBoxAnswer = 7 ;No
			Return
	EndSelect
	For $i = 1 To $info[0][0]
		_XMLDeleteNode("/simulator/events/event[@id='" & $info[$i][0] & _
			"' and @if='" & $info[$i][1] & "' and @instance='" & $info[$i][2] & "']")
		_GUICtrlListView_DeleteItem($h_lv_event, _GUICtrlListView_getSelectedItemIndex($h_lv_event))
	Next
EndFunc

Func _initListViewItems()
	Local $xmlPath = FileGetShortName(GUICtrlRead($txt_path))
	If Not FileExists($xmlPath) Then
		MsgBox($MSG_BOX_ALERT_OK,$APP_NAME,"选择的xml文件不存在。", 0, $gui)
		Return
	EndIf
	_XMLFileOpen($xmlPath)
	Local $xml = $objDoc
	_getAllBasicTypes($xml)
	Local $items = $xml.SelectNodes("/simulator/events/event")
	If $items.Length <= 0 Then Return
	_GUICtrlListView_BeginUpdate($h_lv_event)
	_GUICtrlListView_DeleteAllItems($h_lv_event)
	Local $item, $if, $inst, $i = 0
	For $item In $items
		_GUICtrlListView_AddItem($h_lv_event, $item.GetAttribute("id"))
		$if = $item.GetAttribute("if")
		_GUICtrlListView_AddSubItem($h_lv_event, $i, $if, 1)
		$inst = $item.GetAttribute("instance")
		If $inst == "" Then $inst = 0
		_GUICtrlListView_AddSubItem($h_lv_event, $i, $inst, 2)
		If _checkInterfaceStatus($xml, $if, $inst) Then
			_GUICtrlListView_AddSubItem($h_lv_event, $i, "√", 3)
		Else
			_GUICtrlListView_AddSubItem($h_lv_event, $i, "×", 3)
		EndIf
		$i += 1
	Next
	_GUICtrlListView_EndUpdate($h_lv_event)
EndFunc

Func _analyseHeadFile()
	_GUICtrlStatusBar_SetText($statusbar, "正在解析头文件，请稍等...")
	Local $headPath = FileGetShortName(GUICtrlRead($txt_path))
	If Not FileExists($headPath) Then
		MsgBox($MSG_BOX_ALERT_OK,$APP_NAME,"选择的头文件不存在。", 0, $gui)
		_GUICtrlStatusBar_SetText($statusbar, "单击“浏览”按钮打开一个头文件或者继续编辑一个xml文件。")
		Return
	EndIf
;~ 	_replacePreCompiler($headPath)

	Local $path = FileOpenDialog ("选择输出的xml文件", @ScriptDir, "xml files (*.xml)|All (*.*)", 9, "Simulator.xml", $gui)
	If @error Then
		_GUICtrlStatusBar_SetText($statusbar, "单击“浏览”按钮打开一个头文件或者继续编辑一个xml文件。")
		Return
	EndIf
	If FileExists($path) Then
		Local $iMsgBoxAnswer = _
				MsgBox($MSG_BOX_QUESTION_NOYES, $APP_NAME, "输出xml的目标文件已经存在，是否覆盖？", _
							0, $gui)
		Select
			Case $iMsgBoxAnswer = 6 ;Yes
				FileDelete($path)
			Case $iMsgBoxAnswer = 7 ;No
				_GUICtrlStatusBar_SetText($statusbar, "单击“浏览”按钮打开一个头文件或者继续编辑一个xml文件。")
				Return
		EndSelect
	EndIf
;~ 	$path = FileGetShortName($path)
	RunWait("bin\c2xml.exe '" & $headPath & "' -o '" & @ScriptDir & "\tmp.xml'", "bin", @SW_HIDE)
;~ 	MsgBox(0, "", "bin\c2xml.exe '" & $headPath & "' -o '" & @ScriptDir & "\tmp.xml'")
	_XMLFileOpen(@ScriptDir & "\tmp.xml")
	Local $hasErr = _XMLGetValue('/translation_unit')
	If IsArray($hasErr) And $hasErr[0] > 0 And $hasErr[1] == "parse error" Then
		MsgBox($MSG_BOX_ALERT_OK,$APP_NAME,"头文件存在编译错误，解析xml失败。", 0, $gui)
		Return
	EndIf
	_GUICtrlStatusBar_SetText($statusbar, "正在生成基础xml，请稍等...")
	_genSimultorXml(_getBasicTypes(), _getStructs(), $path)
	FileDelete(@ScriptDir & "\tmp.xml")
	_GUICtrlStatusBar_SetText($statusbar, "头文件解析结束，请单击“添加事件”来增加一个事件和对应的接口。")
EndFunc

Func _genSimultorXml($basicTypes, $structs, $xml)
	If Not IsArray($basicTypes) Or Not IsArray($structs) Then Return False
	_createBasicSimulatorXml($xml)
	_XMLFileOpen($xml)
	
	Local $gui_progress = GUICreate("正在生成基础xml文件...", 635, 65, 0, 100, _
			$WS_POPUP + $WS_CAPTION, $WS_EX_MDICHILD, $gui)
	Local $progress = GUICtrlCreateProgress(4, 8, 627, 16, BitOR($PBS_SMOOTH, $WS_BORDER))
	Local $lbl_stat = GUICtrlCreateLabel("状态：", 8, 32, 627)
	Local $lbl_detail = GUICtrlCreateLabel("", 8, 48, 627)
	GUISetState(@SW_SHOW, $gui_progress)
	GUISetState(@SW_DISABLE, $gui)
	Local $i, $j, $total = $structs[0][0] + $basicTypes[0][0], $p = 0
	Local $members
	For $i = 1 To $structs[0][0]
		$members = $structs[$i][1]
		$total += $members[0][0]
	Next
	
	For $i = 1 To $basicTypes[0][0]
		_XMLCreateChildNode("/simulator/types", "type")
		_XMLSetAttrib("/simulator/types/type", "name", $basicTypes[$i][0], $i-1)
		_XMLSetAttrib("/simulator/types/type", "len", $basicTypes[$i][1], $i-1)
		GUICtrlSetData($progress, Int(($p / $total) * 100))
		GUICtrlSetData($lbl_stat, "状态：" & $p & " / " & $total)
		GUICtrlSetData($lbl_detail, $basicTypes[$i][0] & " -> " & $basicTypes[$i][1])
		$p += 1
	Next
	
	For $i = 1 To $structs[0][0]
		$members = $structs[$i][1]
		_XMLCreateChildNode("/simulator/structs_def", "struct")
		_XMLSetAttrib("/simulator/structs_def/struct", "name", $structs[$i][0], $i-1)
		GUICtrlSetData($progress, Int(($p / $total) * 100))
		GUICtrlSetData($lbl_stat, "状态：" & $p & " / " & $total)
		GUICtrlSetData($lbl_detail, $structs[$i][0])
		$p += 1
		For $j = 1 To $members[0][0]
			_XMLCreateChildNode("/simulator/structs_def/struct[@name='" & $structs[$i][0] & "']", "member")
			_XMLSetAttrib("/simulator/structs_def/struct[@name='" & $structs[$i][0] & "']/member", "name", $members[$j][1], $j-1)
			_XMLSetAttrib("/simulator/structs_def/struct[@name='" & $structs[$i][0] & "']/member", "type", $members[$j][0], $j-1)
			GUICtrlSetData($progress, Int(($p / $total) * 100))
			GUICtrlSetData($lbl_stat, "状态：" & $p & " / " & $total)
			GUICtrlSetData($lbl_detail, $structs[$i][0] & "." & $members[$j][1])
			$p += 1
			If $members[$j][2] == 0 Then ContinueLoop
			_XMLSetAttrib("/simulator/structs_def/struct[@name='" & $structs[$i][0] & "']/member", "array_len", $members[$j][2], $j-1)
		Next
	Next
	GUISetState(@SW_ENABLE, $gui)
	GUIDelete($gui_progress)
EndFunc

Func _getBasicTypes()
	Local $max = _XMLGetChildNodes("/translation_unit")
	If Not IsArray($max) Then Return
	Local $types[1][2] = [[0, 0]], $i, $basicType, $udType
	For $i = 1 To $max[0]
		If Not _XMLNodeExists("/translation_unit/declaration[" & $i & _
							"]/type_specifier_atomic") Then ContinueLoop
		$basicType = _XMLGetAttrib("/translation_unit/declaration[" & $i & "]" & _
							"/type_specifier_atomic[last()]", "token")
		If $basicType == -1 Then ContinueLoop
		$udType = _XMLGetAttrib("/translation_unit/declaration[" & $i & "]" & _
							"/init_declarator/declarator/direct_declarator_id", "token")
		If $udType == -1 Then ContinueLoop
		Switch $basicType
			Case "char"
				$basicType = 1
			Case "short"
				$basicType = 2
			Case "long"
				$basicType = 4
			Case Else
				ContinueLoop
		EndSwitch
		$types[0][0] += 1
		ReDim $types[$types[0][0]+1][2]
		$types[$types[0][0]][0] = $udType
		$types[$types[0][0]][1] = $basicType
	Next
	Return $types
EndFunc

Func _getStructs()
	Local $sc = 1, $mc = 1, $max = _XMLGetChildNodes("/translation_unit")
	Local $members[1][3], $structs[1][2]
	Local $memType, $memName, $memArrLen, $structName
	If Not IsArray($max) Then Return
	$structs[0][0] = 0
	For $sc = 1 To $max[0]
		If Not _XMLNodeExists("/translation_unit/declaration[" & $sc & _
			"]/type_specifier_struct_union") Then ContinueLoop
		If _XMLGetAttrib("/translation_unit/declaration[" & $sc & _
			"]/type_specifier_struct_union/struct_union", "token") <> "struct" Then ContinueLoop
		ReDim $members[1][3]
		$members[0][0] = 0
		$mc = 1
		While 1
			$memType = _XMLGetAttrib("/translation_unit/declaration[" & $sc & _
									"]/type_specifier_struct_union/struct_declaration[" & $mc & _
									"]/type_specifier_atomic", "token")
			If $memType == -1 Then ExitLoop
			If _XMLNodeExists("/translation_unit/declaration[" & $sc & _
							"]/type_specifier_struct_union/struct_declaration[" & $mc & _
							"]/struct_declarator/declarator/direct_declarator_array") Then
				$memName = _XMLGetAttrib("/translation_unit/declaration[" & $sc & _
										"]/type_specifier_struct_union/struct_declaration[" & $mc & _
										"]/struct_declarator/declarator/direct_declarator_array/direct_declarator_id", "token")
				If $memName == -1 Then ExitLoop
				$memArrLen = _XMLGetAttrib("/translation_unit/declaration[" & $sc & _
										"]/type_specifier_struct_union/struct_declaration[" & $mc & _
										"]/struct_declarator/declarator/direct_declarator_array/expression_id", "token")
				If $memArrLen == -1 Then ExitLoop
			Else
				$memName = _XMLGetAttrib("/translation_unit/declaration[" & $sc & _
										"]/type_specifier_struct_union/struct_declaration[" & $mc & _
										"]/struct_declarator/declarator/direct_declarator_id", "token")
				If $memName == -1 Then ExitLoop
				$memArrLen = 0
			EndIf
			$members[0][0] += 1
			ReDim $members[$members[0][0]+1][3]
			$members[$members[0][0]][0] = $memType
			$members[$members[0][0]][1] = $memName
			$members[$members[0][0]][2] = $memArrLen
			$mc += 1
		WEnd
;~ 	_ArrayDisplay($members)
		$structName = _XMLGetAttrib("/translation_unit/declaration[" & $sc & _
									"]/init_declarator/declarator/direct_declarator_id", 'token')
		If $structName == -1 Then ContinueLoop
		$structs[0][0] += 1
		ReDim $structs[$structs[0][0]+1][2]
		$structs[$structs[0][0]][0] = $structName
		$structs[$structs[0][0]][1] = $members
	Next
;~ 	_ArrayDisplay($structs)
	Return $structs
EndFunc

Func _createBasicSimulatorXml($xml)
	FileDelete($xml)
	Local $txt = _
		'<?xml version="1.0" encoding="GB2312"?>' & @CRLF & _
		'<simulator>' & @CRLF & _
		'	<events/>' & @CRLF & _
		'	<types/>' & @CRLF & _
		'	<structs/>' & @CRLF & _
		'	<structs_def/>' & @CRLF & _
		'</simulator>' & @CRLF
	FileWrite($xml, $txt)
EndFunc

Func _replacePreCompiler($headPath)
	If Not FileCopy($headPath, $headPath & ".tmp~", 1) Then
		MsgBox($MSG_BOX_ALERT_OK,$APP_NAME,"无法覆盖文件 " & $headPath & ".tmp~", 0, $gui)
		Return
	EndIf
	Local $preCompiler = _findAllPreComplier($headPath)
	Local $i
	For $i = 1 To $preCompiler[0][0]
		_ReplaceStringInFile($headPath & ".tmp~", $preCompiler[$i][0], $preCompiler[$i][1], 1)
	Next
EndFunc

Func _findAllPreComplier($file)
	Local $fc[1]
	_FileReadToArray($file, $fc)
	Local $i, $preCompiler[1][2] = [[0, 0]], $compiler
	For $i = 1 To $fc[0]
		$fc[$i] = StringStripWS($fc[$i], 3)
		If StringLeft($fc[$i], 7) <> "#define" Then ContinueLoop
		$fc[$i] = StringStripWS(StringRight($fc[$i], StringLen($fc[$i])-7), 3)
		$fc[$i] = StringReplace($fc[$i], @TAB, " ")
		$compiler = StringSplit($fc[$i], " ")
		If Not IsArray($compiler) And $compiler[0] < 2 Then ContinueLoop
		$preCompiler[0][0] += 1
		ReDim $preCompiler[$preCompiler[0][0]+1][2]
		$preCompiler[$preCompiler[0][0]][0] = $compiler[1]
		If StringLower(StringLeft($compiler[$compiler[0]], 2)) == "0x" Then _
			$compiler[$compiler[0]] = Dec(StringRight($compiler[$compiler[0]], StringLen($compiler[$compiler[0]])))
		$preCompiler[$preCompiler[0][0]][1] = $compiler[$compiler[0]]
	Next
	Return $preCompiler
EndFunc

Func _getAllBasicTypes($xml)
	Local $items = $xml.SelectNodes("/simulator/types/type")
	ReDim $basicTypes[1][2]
	$basicTypes[0][0] = 0
	If $items.Length <= 0 Then Return
	Local $item
	For $item In $items
		$basicTypes[0][0] += 1
		ReDim $basicTypes[$basicTypes[0][0]+1][2]
		$basicTypes[$basicTypes[0][0]][0] = $item.GetAttribute("name")
		$basicTypes[$basicTypes[0][0]][1] = $item.GetAttribute("len")
	Next
EndFunc

Func browseFile()
	Local $path = FileOpenDialog ("选择头文件或xml文件", @ScriptDir, "Head files (*.h)|xml files (*.xml)|All (*.*)", 9, "", $gui)
	If @error Then Return
	GUICtrlSetData($txt_path, $path)
	If StringLower(StringRight($path, 4)) == ".xml" Then
		_initListViewItems()
	Else
		_analyseHeadFile()
	EndIf
EndFunc

Func listviewClicked()
	Local $name = _GUICtrlListView_getSelectedItemText($h_lv_event, 1)
	If $name == 0 Then Return
	Local $inst = _GUICtrlListView_getSelectedItemText($h_lv_event, 2)
	_GUICtrlListView_SetItemSelected($h_lv_event, _GUICtrlListView_getSelectedItemIndex($h_lv_event))
	FillStructData($gui, $name, $inst)
EndFunc

Func mainGUIClose()
	Exit
EndFunc
