#include <Array.au3>
#include <GUIConstants.au3>
#include <GuiTreeView.au3>
#Include <GuiList.au3>

;~ #AutoIt3Wrapper_run_debug_mode=Y


Opt("WinTitleMatchMode", 2)
Opt("TrayMenuMode",1)
;~ Opt("GUICloseOnESC", 0)

HotKeySet("{F3}", "searchDown")
HotKeySet("^{F3}", "searchUp")
HotKeySet("{F8}", "jump2Def")
HotKeySet("{F9}", "jumpBack")
HotKeySet("{F10}", "jumpForward")
HotKeySet("^f", "search")



HotKeySet("^1", "abc")


init()
initAdlibs()
main()

Func main()
	Local $flag = False, $updateFlag = False
	Local $lastTitle, $msg, $text, $state, $treeItemMsg, $count = 0
	While 1
		$updateFlag = False
		If $lastTitle <> $editingFileInfo[0] Then
			$lastTitle = $editingFileInfo[0]
			$flag = False
			analyse($lastTitle)
			$text = sort($sortOrderFunc, $UPDATE_OPTION_FUNC)
			updateTreeView($UPDATE_OPTION_FUNC, $text)
			$text = sort($sortOrderInclude, $UPDATE_OPTION_INCLUDE)
			updateTreeView($UPDATE_OPTION_INCLUDE, $text)
			ContinueLoop
		EndIf
		If $flag And Not $editingFileInfo[1] Then
			$lastTitle = $editingFileInfo[0]
			$updateFlag = True
			analyse($lastTitle)
			$text = sort($sortOrderFunc, $UPDATE_OPTION_FUNC)
			updateTreeView($UPDATE_OPTION_FUNC, $text)
			$text = sort($sortOrderInclude, $UPDATE_OPTION_INCLUDE)
			updateTreeView($UPDATE_OPTION_INCLUDE, $text)
		EndIf
		$flag = $editingFileInfo[1]
		
		; if the tree is updated, discard the next 20 messages
		; hope to fix the bug
		If $theMsg == $MSG_UPDATETREE_UPDATED Then
			For $i = 1 To 200
				$message = GUIGetMsg(1)
				If $message[0] = $ti_func Then
					testMaxCount($i)
				EndIf
			Next
			$theMsg = $MSG_NOMSG
		EndIf
		
		
		$message = GUIGetMsg(1)
		$msg = $message[0]
		$treeItemMsg = handleTreeItemMessages($msg)
;~ 		searchJump2Line()
		handlePosChangedMessage()
		
;~ 		showMsg($msg, $ti_func, $ti_includes, $treeItemMsg )
		
		Select
		Case $msg = $MSG_NOMSG
			
		Case $msg = $ti_var
			
		Case $msg = $ti_includes
			$sortOrderInclude = Mod($sortOrderInclude + 1, 4)
			$text = sort($sortOrderInclude, $UPDATE_OPTION_INCLUDE)
			updateTreeView($UPDATE_OPTION_INCLUDE, $text)
			Sleep(20)
			
		Case $msg = $ti_func
			$sortOrderFunc = Mod($sortOrderFunc + 1, 4)
			$text = sort($sortOrderFunc, $UPDATE_OPTION_FUNC)
			updateTreeView($UPDATE_OPTION_FUNC, $text)
			Sleep(20)
			
		Case $treeItemMsg <> -1
			$theMsg = $MSG_POSCHANGED_GOTO
			ReDim $MSG_EXTENDED[2]
			$MSG_EXTENDED[0] = getPosFromStatusbar()
			Local $tmpArr[2] = [$treeItemMsg, 1]
			$MSG_EXTENDED[1] = $tmpArr
			goto($treeItemMsg)
			$treeItemMsg = -1
			Sleep(20)
			
		Case $msg = $GUI_EVENT_CLOSE			
			Select
				Case $message[1] == $main_GUI
					ExitLoop
					
				Case $message[1] == $searchResult_GUI
					GUISetState(@SW_HIDE, $searchResult_GUI)
					
				Case $message[1] == $find_gui
					GUISetState(@SW_HIDE, $find_gui)
					
			EndSelect
		EndSelect
		listenButtonMsg($msg)
		listenMenuItemMsg($msg)
		listenTrayMenuMsg(TrayGetMsg())
	WEnd
EndFunc

Func listenMenuItemMsg($msg)
	Select
		Case $msg = $mi_sortFunc
			
		Case $msg = $mi_sortFuncNameAsc
			
		Case $msg = $mi_sortFuncNameDec
			
		Case $msg = $mi_sortFuncLineAsc
			
		Case $msg = $mi_sortFuncLineDec
			
		Case $msg = $mi_fixFunc
			MsgBox(0, "", "fixed")
			
		Case $msg = $mi_sortInclude
			
		Case $msg = $mi_sortIncludeNameAsc
			
		Case $msg = $mi_sortIncludeNameDec
			
		Case $msg = $mi_sortIncludeLineAsc
			
		Case $msg = $mi_sortIncludeLineDec
			
		Case $msg = $mi_fixInclude
			
	EndSelect
	
EndFunc

Func listenTrayMenuMsg($msg)
	Select
	; tray messages
	Case $msg = $mi_properties
		
	Case $msg = $mi_trayExit
		MsgBox(0, "", "exit")
		Exit
	
	EndSelect
EndFunc

Func listenButtonMsg($msg)
	Select
		Case $msg = $btn_findNext
			searchFindNext()
			Sleep(20)
			
		Case $msg = $btn_jumpBack
			jumpBack()
			Sleep(20)
			
		Case $msg = $btn_jumpForward
			jumpForward()
			Sleep(20)
		
	EndSelect
EndFunc

Func init()
	Global Const $APP_NAME = "Code Navigator"
	Global $SORT_ORDER_NAME_ASC = 0
	Global $SORT_ORDER_NAME_DEC = 1
	Global $SORT_ORDER_LINE_ASC = 2
	Global $SORT_ORDER_LINE_DEC = 3
	
	Global $UPDATE_OPTION_VAR = 1
	Global $UPDATE_OPTION_FUNC = 2
	Global $UPDATE_OPTION_INCLUDE = 4
	Global $UPDATE_OPTION_ALL = $UPDATE_OPTION_VAR + $UPDATE_OPTION_FUNC + $UPDATE_OPTION_INCLUDE
	
	Global $editingFileInfo[2] = ["", ""]
	
	; necessary infomation of certain message
	Global $MSG_EXTENDED[1]
	; message types
	Global $MSG_UNKOWN = -1
	Global $MSG_NOMSG = 0
	Global $MSG_UPDATETREE_UPDATED = 1
	Global $MSG_POSCHANGED_GOTO = 2
	Global $MSG_POSCHANGED_JUMP2DEF = 3
	Global $MSG_POSCHANGED_JUMP2SEARCH = 4
	Global $theMsg = $MSG_UNKOWN
	Global $MAX_POS_BUF =  200
	Global $posChangedBufBack[$MAX_POS_BUF]
	Global $posChangedBufForward[$MAX_POS_BUF]
	Global $isJumpBackEnabled = False
	Global $isJumpForwardEnabled = False
	Global $lastPosArr4Distance[2] = [1, 1]
	Global $jumpDirection = "backward"
	
	Global $SciTE = WinGetHandle("SciTE", "Source")
	Global $SciTE_PATH = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\Autoit", "InstallDir") & _
		"\SciTE\SciTE.exe"
	If Not FileExists($SciTE_PATH) then
		MsgBox(8208, $APP_NAME, "SciTE has not been installed, reinstall SciTE first...")
		Exit
	EndIf
	Local $size = WinGetClientSize ("SciTE", "Source")
	Global $mySize[2] = [200, $size[1] - 110]
	Global $main_GUI = GUICreate($APP_NAME, $mySize[0], $mySize[1], $size[0] - $mySize[0] - 25, 65, _
		BitOR($WS_SIZEBOX, $WS_SYSMENU,$WS_CAPTION,$WS_POPUP,$WS_POPUPWINDOW,$WS_BORDER,$WS_CLIPSIBLINGS), _
		$WS_EX_MDICHILD, $SciTE)
	Global $treeview = GUICtrlCreateTreeView(1, 40, $mySize[0] - 1, $mySize[1] - 40, _
		BitOr($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), _
		$WS_EX_CLIENTEDGE)
	Global $btn_jumpBack = GUICtrlCreateButton("<-F9", 10, 10, 40, 20)
	GUICtrlSetState($btn_jumpBack, $GUI_DISABLE)
	Global $btn_jumpForward = GUICtrlCreateButton("F10->", 60, 10, 40, 20)
	GUICtrlSetState($btn_jumpForward, $GUI_DISABLE)
;~ 	GUICtrlSetResizing($treeview, $GUI_DOCKTOP)

	Global $ti_var = GUICtrlCreateTreeViewItem("Variables (Click to Sort)", $treeview)
	Global $ti_includes = GUICtrlCreateTreeViewItem("Includes (Click to Sort)", $treeview)
	Global $ti_func = GUICtrlCreateTreeViewItem("Functions (Click to Sort)", $treeview)
	Global $ti_tmpFunc[1]
	Global $ti_tmpIncludes[1]
	Global $ti_tmpVar[1]
	
	Global $searchResultSize[2] = [400, 200]
	Global $searchResult_GUI = GUICreate("Search Result - " & $APP_NAME, $searchResultSize[0], $searchResultSize[1], _
		$size[0] - $searchResultSize[0] - $mySize[0] - 25, 0, _
		BitOR($WS_SIZEBOX, $WS_SYSMENU,$WS_CAPTION,$WS_POPUP,$WS_POPUPWINDOW,$WS_BORDER,$WS_CLIPSIBLINGS), _
		$WS_EX_MDICHILD, $SciTE)
	Global $searchResult_list = GUICtrlCreateList("", 0, 35, $searchResultSize[0], $searchResultSize[1] - 25, _
		BitOR($LBS_NOTIFY, $WS_VSCROLL, $WS_BORDER))
	GUICtrlSetResizing($searchResult_list, $GUI_DOCKTOP)
	Global $searchResult_jumpto = GUICtrlCreateButton("&Jump To", 10, 5, 80, 25)
	GUICtrlSetResizing($searchResult_jumpto, $GUI_DOCKALL)
	Global $searchResult_exit = GUICtrlCreateButton("E&xit", 100, 5, 80, 25)
	GUICtrlSetResizing($searchResult_exit, $GUI_DOCKALL)

	Global $find_gui = GUICreate("Find - " & $APP_NAME, 380, 130, 193, 115, _
		BitOR($WS_SYSMENU,$WS_CAPTION,$WS_POPUP,$WS_POPUPWINDOW,$WS_BORDER,$WS_CLIPSIBLINGS), _
		$WS_EX_MDICHILD, $SciTE)
	GUICtrlCreateLabel("Fi&nd what:", 8, 16)
	Global $combo_findWhat = GUICtrlCreateCombo("", 72, 12, 189, 25)
	Global $cb_matchWholeWord = GUICtrlCreateCheckbox("Match &whole word only", 8, 48)
	Global $cb_matchCase = GUICtrlCreateCheckbox("Match &case", 8, 72)
	Global $cb_isList = GUICtrlCreateCheckbox("&List result in a window", 8, 96)
	GUICtrlSetState($cb_isList, $GUI_CHECKED)
	$grp_direction = GUICtrlCreateGroup("Direction", 180, 48, 81, 65)
	Global $rdb_up = GUICtrlCreateRadio("&Up", 188, 68, 57, 17)
	Global $rdb_down = GUICtrlCreateRadio("&Down", 188, 88, 57, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $btn_findNext = GUICtrlCreateButton("&Find Next", 276, 12, 97, 25, 0)
	Global $btn_cancel = GUICtrlCreateButton("Cancel", 276, 56, 97, 25, 0)
	GUICtrlSetState($rdb_down, $GUI_CHECKED)
	
	Global $sortOrderInclude = $SORT_ORDER_LINE_ASC
	Global $sortOrderFunc = $SORT_ORDER_LINE_ASC
	Global $sortOrderVar = $SORT_ORDER_LINE_ASC
	
	Global $isExpandedInclude = True
	Global $isExpandedFunc = True
	
	Global $searchKeyWord = ""
	Global $searchIsMatchWholeWord = False
	Global $searchIsMatchCase = False
	Global $searchIsListen = False
	Global $searchIsStart = False
	Global $searchResultArray[1][1]
	Global $searchListLastSelected

	; $functions[0][0] contains the max length of this array, 
	; $functions[1][0]: function name
	; $functions[1][1]: line number
	; $functions[1][2]: tree_view_item
	Global $functions[2][3]
	$functions[0][0] = 1
	$functions[1][2] = ""
	Global $includes[2][3]
	$includes[0][0] = 1
	$includes[1][2] = ""
	Global $var[2][3]
	$var[0][0] = 1
	$var[1][2] = ""
	Global $varIsMultiLineFlag = False
	
	createMenue()
	
	GUISetState(@SW_HIDE, $searchResult_GUI)
	GUISetState(@SW_SHOW, $main_GUI)
EndFunc

Func initAdlibs()
	AdlibEnable("getCurFilePath", 100)
	AdlibEnable("searchJump2Line", 150)
EndFunc

Func createMenue()
	$ContextMenu = GUICtrlCreateContextMenu($ti_func)
	Global $mi_sortFunc = GUICtrlCreateMenuitem("Sort", $ContextMenu)
	GUICtrlCreateMenuitem("", $ContextMenu)
	Global $mi_sortFuncNameAsc = GUICtrlCreateMenuitem("Sort by Name ASC", $ContextMenu)
	Global $mi_sortFuncNameDec = GUICtrlCreateMenuitem("Sort by Name DEC", $ContextMenu)
	Global $mi_sortFuncLineAsc = GUICtrlCreateMenuitem("Sort by Line ASC", $ContextMenu)
	Global $mi_sortFuncLineDec = GUICtrlCreateMenuitem("Sort by Line ASC", $ContextMenu)
	Switch $sortOrderFunc
		Case $SORT_ORDER_NAME_ASC
			GUICtrlSetState($mi_sortFuncNameAsc, $GUI_CHECKED)
		Case $SORT_ORDER_NAME_DEC
			GUICtrlSetState($mi_sortFuncNameDec, $GUI_CHECKED)
		Case $SORT_ORDER_LINE_ASC
			GUICtrlSetState($mi_sortFuncLineAsc, $GUI_CHECKED)
		Case $SORT_ORDER_LINE_DEC
			GUICtrlSetState($mi_sortFuncLineDec, $GUI_CHECKED)
	EndSwitch
	GUICtrlCreateMenuitem("", $ContextMenu)
	Global $mi_fixFunc = GUICtrlCreateMenuitem("Fix the tree", $ContextMenu)
	
	$ContextMenu = GUICtrlCreateContextMenu($ti_includes)
	Global $mi_sortInclude = GUICtrlCreateMenuitem("Sort", $ContextMenu)
	GUICtrlCreateMenuitem("", $ContextMenu)
	Global $mi_sortIncludeNameAsc = GUICtrlCreateMenuitem("Sort by Name ASC", $ContextMenu)
	Global $mi_sortIncludeNameDec = GUICtrlCreateMenuitem("Sort by Name DEC", $ContextMenu)
	Global $mi_sortIncludeLineAsc = GUICtrlCreateMenuitem("Sort by Line ASC", $ContextMenu)
	Global $mi_sortIncludeLineDec = GUICtrlCreateMenuitem("Sort by Line ASC", $ContextMenu)
	Switch $sortOrderInclude
		Case $SORT_ORDER_NAME_ASC
			GUICtrlSetState($mi_sortIncludeNameAsc, $GUI_CHECKED)
		Case $SORT_ORDER_NAME_DEC
			GUICtrlSetState($mi_sortIncludeNameDec, $GUI_CHECKED)
		Case $SORT_ORDER_LINE_ASC
			GUICtrlSetState($mi_sortIncludeLineAsc, $GUI_CHECKED)
		Case $SORT_ORDER_LINE_DEC
			GUICtrlSetState($mi_sortIncludeLineDec, $GUI_CHECKED)
	EndSwitch
	GUICtrlCreateMenuitem("", $ContextMenu)
	Global $mi_fixInclude = GUICtrlCreateMenuitem("Fix the tree", $ContextMenu)
	
	Global $mi_properties = TrayCreateItem("Properties...")
	TrayCreateItem("")
	Global $mi_trayExit = TrayCreateItem("Exit")
	TraySetState()
EndFunc

Func updateTreeView($option, $parentText = " (Click to Sort)")
	$theMsg = $MSG_UPDATETREE_UPDATED
;~ 	GUICtrlSetState($treeview, $GUI_HIDE)
	
	Select
	Case BitAND($option, $UPDATE_OPTION_FUNC)
		For $i = 1 to $ti_tmpFunc[0]
			If $ti_tmpFunc[$i] <> "" Then
				_GUICtrlTreeViewDeleteItem($main_GUI, $treeview, $ti_tmpFunc[$i])
			EndIf
		Next
		
		_GUICtrlTreeViewSetText($treeview, $ti_func, "Functions (" & $parentText & ")")
		ReDim $ti_tmpFunc[$functions[0][0] + 1]
		$ti_tmpFunc[0] = $functions[0][0]
		For $i = 1 to $functions[0][0]
			$functions[$i][2] = GUICtrlCreateTreeViewItem( _
				$functions[$i][0] & " (" & $functions[$i][1] & ")", $ti_func)
			$ti_tmpFunc[$i] = $functions[$i][2]
		Next
;~ 		MsgBox(0, "",  _GUICtrlTreeViewGetState($treeview, $ti_func))
;~ 		If $isExpandedFunc == True Then
;~ 			_GUICtrlTreeViewExpand($treeview, True, $ti_func)
;~ 		ElseIf $isExpandedFunc == False
;~ 			_GUICtrlTreeViewExpand($treeview, False, $ti_func)
;~ 		EndIf
;~ 		If BitAND( _GUICtrlTreeViewGetState($treeview, $ti_func), $TVIS_EXPANDED) Then
;~ 			$isExpandedFunc = True
;~ 		Else
;~ 			$isExpandedFunc = False
;~ 		EndIf
		_GUICtrlTreeViewExpand($treeview, $isExpandedFunc, $ti_func)
		ContinueCase
	
	Case BitAND($option, $UPDATE_OPTION_INCLUDE)
		For $i = 1 to $ti_tmpIncludes[0]
			If $ti_tmpIncludes[$i] <> "" Then
				_GUICtrlTreeViewDeleteItem($main_GUI, $treeview, $ti_tmpIncludes[$i])
			EndIf
		Next
		
		_GUICtrlTreeViewSetText($treeview, $ti_includes, "Includes (" & $parentText & ")")
		ReDim $ti_tmpIncludes[$includes[0][0] + 1]
		$ti_tmpIncludes[0] = $includes[0][0]
		For $i = 1 to $includes[0][0]
			$includes[$i][2] = GUICtrlCreateTreeViewItem( _
				$includes[$i][0] & " (" & $includes[$i][1] & ")", $ti_includes)
			$ti_tmpIncludes[$i] = $includes[$i][2]
		Next
;~ 		If BitAND( _GUICtrlTreeViewGetState($treeview, $ti_includes), $TVIS_EXPANDED) Then
;~ 			$isExpandedInclude = True
;~ 		Else
;~ 			$isExpandedInclude = False
;~ 		EndIf
		_GUICtrlTreeViewExpand($treeview, $isExpandedInclude, $ti_includes)
		ContinueCase
	
	Case BitAND($option, $UPDATE_OPTION_VAR)
		
	EndSelect
	
;~ 	GUICtrlSetState($treeview, $GUI_SHOW)
EndFunc

Func handleTreeItemMessages($msg)
	If $msg == 0 Then
		Return -1
	EndIf
	For $i = 1 To $functions[0][0]
		If $functions[$i][2] == $msg Then
			Return $functions[$i][1]
		EndIf
	Next
	For $i = 1 To $includes[0][0]
		If $includes[$i][2] == $msg Then
			Return $includes[$i][1]
		EndIf
	Next
	Return -1
EndFunc

Func sort($order, $option)
	Local $text
	Switch $order
	Case $SORT_ORDER_NAME_ASC
		If BitAND($option, $UPDATE_OPTION_FUNC) Then
			_ArraySort($functions, 0, 1, $functions[0][0], 2, 0)
			$text = "order: a -> z"
		EndIf
		If BitAND($option, $UPDATE_OPTION_INCLUDE) Then
			_ArraySort($includes, 0, 1, $includes[0][0], 2, 0)
			$text = "order: a -> z"
		EndIf
		
	Case $SORT_ORDER_NAME_DEC
		If BitAND($option, $UPDATE_OPTION_FUNC) Then
			_ArraySort($functions, 1, 1, $functions[0][0], 2, 0)
			$text = "order: z -> a"
		EndIf
		If BitAND($option, $UPDATE_OPTION_INCLUDE) Then
			_ArraySort($includes, 1, 1, $includes[0][0], 2, 0)
			$text = "order: z -> a"
		EndIf
		
	Case $SORT_ORDER_LINE_ASC
		If BitAND($option, $UPDATE_OPTION_FUNC) Then
			_ArraySort($functions, 0, 1, $functions[0][0], 2, 1)
			$text = "order: 1 -> 9"
		EndIf
		If BitAND($option, $UPDATE_OPTION_INCLUDE) Then
			_ArraySort($includes, 0, 1, $includes[0][0], 2, 1)
			$text = "order: 1 -> 9"
		EndIf
		
	Case $SORT_ORDER_LINE_DEC
		If BitAND($option, $UPDATE_OPTION_FUNC) Then
			_ArraySort($functions, 1, 1, $functions[0][0], 2, 1)
			$text = "order: 9 -> 1"
		EndIf
		If BitAND($option, $UPDATE_OPTION_INCLUDE) Then
			_ArraySort($includes, 1, 1, $includes[0][0], 2, 1)
			$text = "order: 9 -> 1"
		EndIf
	EndSwitch
	Return $text
EndFunc

Func goto($lineNum, $colNum = 1)
	RunWait($SciTE_PATH & " -goto:" & $lineNum & "," & $colNum)
;~ 	Run(@ComSpec & " /c " &  $SciTE_PATH   & " -goto:" & $lineNum & "," & $colNum, @SW_MAXIMIZE )
;~ 	RunWait(@ComSpec & " /c " & '"' & $SciTE_PATH & '"' & " -goto:" & $lineNum & "," & $colNum)

EndFunc

Func analyse($f)
	Local $file = FileOpen($f, 0)
	If $file = -1 Then
		TrayTip($APP_NAME, "Unable to open file[" & $f & "]", 60)
		return ""
	EndIf
	$functions[0][0] = 0
	$includes[0][0] = 0
	
	Local $line, $tmp, $count = 0, $lineNum = 0
	While 1
		$line = FileReadLine($file)
		If @error = -1 Then ExitLoop
		$line = StringStripWS($line, 1 + 2 )
		$lineNum = $lineNum + 1
		
;~ 		$tmp = StringLower(StringLeft(
		
		$tmp = StringLower(StringLeft($line, 4))
		If $tmp == "func" Then
			$count = $functions[0][0] + 1
			$functions[0][0] = $count
			ReDim $functions[$count + 1][3]
			$functions[$count][0] = getFuncName($line)
			$functions[$count][1] = $lineNum
			ContinueLoop
		EndIf
		
		$tmp = StringLower(StringLeft($line, 8))
		If $tmp == "#include" Then
			$count = $includes[0][0] + 1
			$includes[0][0] = $count
			ReDim $includes[$count + 1][3]
			$includes[$count][0] = getIncludeName($line)
			$includes[$count][1] = $lineNum
			ContinueLoop
		EndIf
		
	Wend
EndFunc

; =======================================================================
;  the function name can be determined by 2 chars, the '(' and the '_'
;  but the '_' can be part of function name, the first '_' after a WS 
;  is we looking for
;
; =======================================================================
Func getFuncName($line)
	Local $n, $m, $m1, $tmp
	; $line no longer contains leading WS here
	$tmp = StringStripWS( StringMid($line, 5), 1 + 2)
	$n = StringInStr($tmp, "(")
	; look for the first WS in $tmp
	$m = StringInStr($tmp, " ")
	$m1 = StringInStr($tmp, "	")
	If $m <> 0 And $m1 <> 0 Then
		If $m1 < $m Then $m = $m1
	Else
		If $m1 > $m Then $m = $m1
	EndIf
	If $n <> 0 And $m <> 0 Then
		If $n < $m Then Return StringLeft($tmp, $n - 1)
		Return StringLeft($tmp, $m - 1)
	ElseIf $n == 0 And $m <> 0 Then
		Return StringLeft($tmp, $m - 1)
	ElseIf $m == 0 and $n <> 0 Then
		Return StringLeft($tmp, $n - 1)
	Else ; $n == 0 And $m == 0 
		Return ""
	EndIf
EndFunc

Func getIncludeName($line)
	Return StringStripWS( StringMid($line, 9), 1 + 2)
EndFunc

Func getCurFilePath()
	Local $title = WinGetTitle("SciTE", "Source"), $tmp
	If StringInStr($title, "*") <> 0 then
		$editingFileInfo[1] = True
		$tmp = " * SciTE"
	Else
		$editingFileInfo[1] = False
		$tmp = " - SciTE"
	EndIf
	Local $file = StringLeft($title, StringInStr($title, $tmp) - 1)
	$editingFileInfo[0] = $file
EndFunc

Func testSort()
;~ 	init()
;~ 	analyseFunc("E:\AutoItWork\CodeNavigator\testingcode.au3")
;~ 	_ArraySort($functions, 1, 1, $functions[0][0], 2, 1)
;~ 	_ArrayDisplay($functions)
EndFunc

; ===========================================================================
;
;
;
;
;
;
; ===========================================================================
Func searchUp()
	If Not WinActive("SciTE", "Source") Then
		HotKeySet("^{F3}")
		Send("^{F3}")
		HotKeySet("^{F3}", "searchUp")
		Return
	EndIf
	
	searchPerform("Up")
EndFunc

Func searchDown()
	If Not WinActive("SciTE", "Source") Then
		HotKeySet("{F3}")
		Send("{F3}")
		HotKeySet("{F3}", "searchDown")
		Return
	EndIf
	
	searchPerform("Down")
EndFunc

Func searchPerform($dir = "Down")
	$clipBak = ClipGet()
	If @error Then
		$clipBak = ""
	EndIf
	ClipPut("")
	WinMenuSelectItem("SciTE", "Source", "&Edit", "&Copy")
	Sleep(20)
	Local $text = ClipGet()
	ClipPut($clipBak)

	If $searchIsMatchCase Then
		Local $ret = ($text == $searchKeyWord)
	Else
		Local $ret = (StringLower($text) == StringLower($searchKeyWord))
	EndIf
	
	If $text == "" Or $ret Then
		HotKeySet("{F3}")
		Send("{F3}")
		HotKeySet("{F3}", "search" & $dir)
		Return
	EndIf
	
	; $text <> "" and $text <> $searchKeyWord
	$searchKeyWord = $text
	WinMenuSelectItem("SciTE", "Source", "&Search", "&Find...")
	WinWait("Find", "Fi&nd what:")
	If $dir == "Down" Then
		ControlCommand("Find", "Fi&nd what:", "[Instance:9; ID:235]", "Check", "")
	ElseIf $dir == "Up" Then
		ControlCommand("Find", "Fi&nd what:", "[Instance:8; ID:234]", "Check", "")
	EndIf
	$searchIsMatchCase = ControlCommand("Find", "Fi&nd what:", "[Instance:2; ID:233]", "IsChecked", "")
	Sleep(10)
	ControlSend("Find", "Fi&nd what:", "[Instance:10; ID:1]", "{enter}")
EndFunc

Func search()
	If Not WinActive("SciTE", "Source") Then
		HotKeySet("^f")
		Send("^f")
		HotKeySet("^f", "search")
		Return
	EndIf
	
	GUISetState(@SW_SHOW, $find_gui)
EndFunc

Func searchFindNext()
	$searchKeyWord = GUICtrlRead($combo_findWhat)
	If $searchKeyWord == "" then Return
	GUISetState(@SW_HIDE, $find_gui)
	$searchIsMatchWholeWord = GUICtrlRead($cb_matchWholeWord)
	$searchIsMatchCase = GUICtrlRead($cb_matchCase)
	Local $searchDown = GUICtrlRead($rdb_down)
	Local $isMatchWholeWord
	Local $isMatchCase
	
	WinMenuSelectItem("SciTE", "Source", "&Search", "&Find...")
	WinWait("Find", "Fi&nd what:")
	ControlSetText("Find", "Fi&nd what:", "[Instance:1; ID:1001]", $searchKeyWord, 1)
	If $searchIsMatchWholeWord == $GUI_CHECKED Then
		$isMatchWholeWord = True
		ControlCommand("Find", "Fi&nd what:", "[Instance:1; ID:232]", "Check", "")
	Else
		$isMatchWholeWord = False
		ControlCommand("Find", "Fi&nd what:", "[Instance:1; ID:232]", "UnCheck", "")
	EndIf
	If $searchIsMatchCase == $GUI_CHECKED Then
		$isMatchCase = True
		ControlCommand("Find", "Fi&nd what:", "[Instance:2; ID:233]", "Check", "")
	Else
		$isMatchCase = False
		ControlCommand("Find", "Fi&nd what:", "[Instance:2; ID:233]", "UnCheck", "")
	EndIf
	If $searchDown == $GUI_CHECKED Then ; search down
		ControlCommand("Find", "Fi&nd what:", "[Instance:9; ID:235]", "Check", "")
	Else ; search up
		ControlCommand("Find", "Fi&nd what:", "[Instance:8; ID:234]", "Check", "")
	EndIf
	Sleep(50)
	ControlSend("Find", "Fi&nd what:", "[Instance:10; ID:1]", "{enter}")
	
	Local $isList = GUICtrlRead($cb_isList)
	If $isList == $GUI_CHECKED Then
		searchListResult($isMatchWholeWord, $isMatchCase)
	EndIf
EndFunc

Func searchListResult($isMatchWholeWord, $isMatchCase)
	Local $ret = getCurFilePath()
	Local $filePath = $ret[0]
	If $filePath == "" Then Return
	$file = FileOpen($filePath, 0)
	If $file = -1 Then
		TrayTip($APP_NAME, "Unable to open file[" & $filePath & "]", 60)
		return ""
	EndIf
	Local $line, $lineNum = 0, $count = 1
	GUICtrlSetData($searchResult_list, "")
	While 1
		$line = FileReadLine($file)
		If @error = -1 Then ExitLoop
		$lineNum = $lineNum + 1
		$line = searchCheckLine($line, $searchKeyWord, $isMatchWholeWord, $isMatchCase)
		If $line <> "" Then
			ReDim $searchResultArray[$count + 1][2]
			$searchResultArray[$count][0] = $line
			$searchResultArray[$count][1] = $lineNum
			$count = $count + 1
			
			GUICtrlSetData($searchResult_list, $line & " (" & $lineNum & ")")
		EndIf
	Wend
	$searchResultArray[0][0] = $count - 1
	GUISetState(@SW_SHOW, $searchResult_GUI)
EndFunc

Func searchCheckLine($line, $kw, $isMatchWholeWord, $isMatchCase)
	Local $myKw = StringStripWS($kw, 1 + 2)
	Local $kwLen = StringLen($myKw)
	Local $n = StringInStr($line, $myKw, $isMatchCase)
	If $n == 0 Then Return ""
	If Not $isMatchWholeWord Then
		Return $line
	EndIf
	
	Local $occ = 1
	Do
		If isWS(StringMid($line, $n - 1, 1)) And _
			isWS(StringMid($line, $n + $kwLen , 1)) Then
			Return $line
		EndIf
		$occ = $occ + 1
		$n = StringInStr($line, $myKw, $isMatchCase, $occ)
	Until $n == 0
	Return ""
EndFunc

Func isWS($c)
	If  $c == " " Or _
		$c == "	" Or _
		$c == "`" Or _
		$c == "~" Or _
		$c == "!" Or _
		$c == "@" Or _
		$c == "#" Or _
		$c == "%" Or _
		$c == "^" Or _
		$c == "&" Or _
		$c == "*" Or _
		$c == "(" Or _
		$c == ")" Or _
		$c == "-" Or _
		$c == "+" Or _
		$c == "=" Or _
		$c == "[" Or _
		$c == "]" Or _
		$c == "{" Or _
		$c == "}" Or _
		$c == ";" Or _
		$c == ":" Or _
		$c == "'" Or _
		$c == '"' Or _
		$c == "," Or _
		$c == "." Or _
		$c == "/" Or _
		$c == "<" Or _
		$c == ">" Or _
		$c == "?" Then
		Return True
	EndIf
	Return False
EndFunc

Func searchJump2Line()
	Local $selected = GUICtrlRead($searchResult_list)
	If $selected == "" Or $selected == $searchListLastSelected Then
		Return
	EndIf
	$searchListLastSelected = $selected
	Local $idx = _GUICtrlListGetAnchorIndex($searchResult_list) + 1
	Local $ln = $searchResultArray[$idx][1]
	
	$theMsg = $MSG_POSCHANGED_JUMP2DEF
	ReDim $MSG_EXTENDED[2]
	$MSG_EXTENDED[0] = getPosFromStatusbar()
	Local $tmpArr[2] = [$ln, 1]
	$MSG_EXTENDED[1] = $tmpArr
	
	goto($ln)
EndFunc

Func jump2Def()
	If Not WinActive("SciTE", "Source") Then
		HotKeySet("{F8}")
		Send("{F8}")
		HotKeySet("{F8}", "jump2Def")
		Return
	EndIf
	Local $clipBak = ClipGet()
	If @error then $clipBak = ""
	ClipPut("")
	Sleep(30)
	WinMenuSelectItem("SciTE", "Source", "&Edit", "&Copy")
	Sleep(30)
	Local $text = ClipGet()
	ClipPut($clipBak)
	If $text == "" Then
		HotKeySet("{F8}")
		Send("{F8}")
		HotKeySet("{F8}", "jump2Def")
		Return
	EndIf
	For $i = 1 To $functions[0][0]
		If StringLower($text) == StringLower($functions[$i][0]) Then
			$theMsg = $MSG_POSCHANGED_JUMP2DEF
			ReDim $MSG_EXTENDED[2]
			$MSG_EXTENDED[0] = getPosFromStatusbar()
			Local $tmpArr[2] = [$functions[$i][1], 6]
			$MSG_EXTENDED[1] = $tmpArr
			goto($functions[$i][1], 6)
			Return
		EndIf
	Next
	HotKeySet("{F8}")
	Send("{F8}")
	HotKeySet("{F8}", "jump2Def")
	Return
EndFunc


; ===========================================================================
;
;
;
;
;
;
; ===========================================================================

Func handlePosChangedMessage()
	Switch $theMsg
		Case $MSG_POSCHANGED_GOTO, _
			$MSG_POSCHANGED_JUMP2DEF, _
			$MSG_POSCHANGED_JUMP2SEARCH
			
			push($posChangedBufBack, $MSG_EXTENDED[0])
			push($posChangedBufBack, $MSG_EXTENDED[1])
			$theMsg = $MSG_NOMSG
			
		Case Else
		
	EndSwitch
EndFunc

Func jumpBack()
	If Not WinActive("SciTE", "Source") And _
		Not WinActivate($APP_NAME, "<-") Then
		HotKeySet("{F9}")
		Send("{F9}")
		HotKeySet("{F9}", "jumpBack")
		Return
	EndIf
	
	If Not $isJumpBackEnabled Then
		Return
	EndIf
;~ 	If $jumpDirection == "forward" Then
;~ 		_ArrayPop($posChangedBufBack)
;~ 	EndIf
;~ 	$jumpDirection = "backward"
	Local $pos = _ArrayPop($posChangedBufBack)
	If $pos = "" Then
		disableJumpBack()
		Return
	EndIf
	_ArrayPush($posChangedBufForward, $pos)
	enableJumpForward()
	Local $arr = resolvePos($pos)
	goto($arr[0], $arr[1])
EndFunc

Func jumpForward()
	If Not WinActive("SciTE", "Source") And _
		Not WinActivate($APP_NAME, "<-") Then
		HotKeySet("{F10}")
		Send("{F10}")
		HotKeySet("{F10}", "jumpForward")
		Return
	EndIf
	
	If Not $isJumpForwardEnabled Then
		Return
	EndIf
	If $jumpDirection == "backward" Then
		_ArrayPop($posChangedBufForward)
	EndIf
;~ 	$jumpDirection = "forward"
;~ 	If $pos = "" Then
;~ 		disableJumpForward()
;~ 		Return
;~ 	EndIf
	Local $pos = _ArrayPop($posChangedBufForward)
	_ArrayPush($posChangedBufBack, $pos)
	enableJumpBack()
	Local $arr = resolvePos($pos)
	goto($arr[0], $arr[1])
EndFunc

Func enableAll()
	GUICtrlSetState($btn_jumpBack, $GUI_ENABLE)
	GUICtrlSetState($btn_jumpForward, $GUI_ENABLE)
EndFunc

Func disableAll()
	GUICtrlSetState($btn_jumpBack, $GUI_DISABLE)
	GUICtrlSetState($btn_jumpForward, $GUI_DISABLE)
EndFunc

Func enableJumpBack()
	$isJumpBackEnabled = True
	GUICtrlSetState($btn_jumpBack, $GUI_ENABLE)
EndFunc

Func disableJumpBack()
	$isJumpBackEnabled = False
	GUICtrlSetState($btn_jumpBack, $GUI_DISABLE)
EndFunc

Func enableJumpForward()
	$isJumpForwardEnabled = True
	GUICtrlSetState($btn_jumpForward, $GUI_ENABLE)
EndFunc

Func disableJumpForward()
	$isJumpForwardEnabled = False
	GUICtrlSetState($btn_jumpForward, $GUI_DISABLE)
	$posChangedBufForward = _ArrayTrim($posChangedBufForward, $MAX_POS_BUF)
EndFunc

Func getPosFromStatusbar()
	Local $pos[2]
	If Not resetStatusBar() Then
		; can not open the status bar, some position can not be recorded
		$pos[0] = -1
		$pos[1] = -1
		Return $pos
	EndIf
	Local $text = ControlGetText ("SciTE", "Source", "[Instance:1; ID:353]")
	Local $n = StringInStr($text, " ")
	Local $m = StringInStr($text, " ", 1, 2)
	$pos[0] = StringMid($text, 4, $n - 4)
	$pos[1] = StringMid($text, $n + 4, $m - $n - 4)
	Return $pos
EndFunc

Func resetStatusBar()
	If Not ControlCommand("SciTE", "Source", "[Instance:1; ID:353]", "IsVisible", "") Then
		WinMenuSelectItem("SciTE", "Source", "&View", "&Status Bar")
		Do
			Sleep(10)
		Until ControlCommand("SciTE", "Source", "[Instance:1; ID:353]", "IsVisible", "")
	EndIf
	
	Local $text = ControlGetText ("SciTE", "Source", "[Instance:1; ID:353]")
	If StringLeft($text, 3) == "li=" Then
		Return True
	EndIf
	Local $count = 0
	Do
		$count = $count + 1
		ControlClick("SciTE", "Source", "[Instance:1; ID:353]")
		$text = ControlGetText ("SciTE", "Source", "[Instance:1; ID:353]")
	Until StringLeft($text, 3) == "li=" Or $count >= 100
	If $count >= 100 Then
		MsgBox(8208, $APP_NAME, "Unable to open your SciTE's status bar, the Navigator may not work properly!")
		Return False
	EndIf
	Return True
EndFunc

Func push(ByRef $arr, $data)
	Const $MAX_DISTANCE = 8
	
;~ 		TrayTip("", getDistance($lastPosArr4Distance[0], $lastPosArr4Distance[1], $data[0], $data[1]), 20)
	If getDistance($lastPosArr4Distance[0], $lastPosArr4Distance[1], $data[0], $data[1]) < $MAX_DISTANCE Then
		$lastPosArr4Distance = $data
		Return
	EndIf
	$lastPosArr4Distance = $data
	enableJumpBack()
	disableJumpForward()
	_ArrayPush($arr, $data[0] & " " & $data[1])
	
;~ 	_ArrayDisplay($arr)
EndFunc

; calculate the distance between 2 position
Func getDistance($row1, $col1, $row2, $col2)
	Return Sqrt( ($row1 - $row2) * ($row1 - $row2) + ($col1 - $col2) * ($col1 - $col2) )
EndFunc

Func resolvePos($posText)
	Local $n = StringInStr($posText, " ")
	Local $arr[2] = [StringLeft($posText, $n - 1), StringMid($posText, $n + 1)]
	Return $arr
EndFunc




; ===========================================================================
;
;
;
;
;
;
; ===========================================================================


Func showMsg($msg, $ti_func, $ti_includes, $treeItemMsg)
	If $msg == 0 Then Return
	
	ConsoleWrite("$msg=" & $msg & @CRLF)
	ConsoleWrite("$ti_func=" & $ti_func & @CRLF)
	ConsoleWrite("$ti_includes=" & $ti_includes & @CRLF)
	ConsoleWrite("$treeItemMsg=" & $treeItemMsg & @CRLF)
	ConsoleWrite(@CRLF)
	ConsoleWrite(@CRLF)
	
EndFunc


Func abc()
	If Not WinActive("SciTE", "Source") Then
		Return
	EndIf
	consolewrite("$main_GUI=" & $main_GUI & @crlf)
	consolewrite("$treeview=" & $treeview & @crlf)
	consolewrite("$ti_var=" & $ti_var & @crlf)
	consolewrite("$ti_includes=" & $ti_includes & @crlf)
	consolewrite("$ti_func=" & $ti_func & @crlf)
	consolewrite("$searchResult_GUI=" & $searchResult_GUI & @crlf)
	consolewrite("$searchResult_list=" & $searchResult_list & @crlf)
	consolewrite("$searchResult_jumpto=" & $searchResult_jumpto & @crlf)
	consolewrite("$searchResult_exit=" & $searchResult_exit & @crlf)
	consolewrite("$find_gui=" & $find_gui & @crlf)
	consolewrite("$combo_findWhat=" & $combo_findWhat & @crlf)
	consolewrite("$cb_matchWholeWord=" & $cb_matchWholeWord & @crlf)
	consolewrite("$cb_matchCase=" & $cb_matchCase & @crlf)
	consolewrite("$cb_isList=" & $cb_isList & @crlf)
	consolewrite("$rdb_up=" & $rdb_up & @crlf)
	consolewrite("$rdb_down=" & $rdb_down & @crlf)
	consolewrite("$btn_findNext=" & $btn_findNext & @crlf)
	consolewrite("$btn_cancel=" & $btn_cancel & @crlf)
	
	For $i = 1 to $ti_tmpFunc[0]
		ConsoleWrite("$ti_tmpFunc[" & $i & "]=" & $ti_tmpFunc[$i] & @CRLF)
	Next
	For $i = 1 to $ti_tmpIncludes[0]
		ConsoleWrite("$ti_tmpIncludes[" & $i & "]=" & $ti_tmpIncludes[$i] & @CRLF)
	Next
	For $i = 1 to $ti_tmpVar[0]
		ConsoleWrite("$ti_tmpVar[" & $i & "]=" & $ti_tmpVar[$i] & @CRLF)
	Next
	For $i = 1 to $functions[0][0]
		ConsoleWrite("$functions[" & $i & "][2]=" & $functions[$i][2] & @CRLF)
	Next
	For $i = 1 to $includes[0][0]
		ConsoleWrite("$includes[" & $i & "][2]=" & $includes[$i][2] & @CRLF)
	Next
	For $i = 1 to $var[0][0]
		ConsoleWrite("$var[" & $i & "][2]=" & $var[$i][2] & @CRLF)
	Next
EndFunc


Func testMaxCount($num)
	$count = IniRead(@ScriptDir & "\test.ini", "test", "count", 0)
	$count = $count + 1
	IniWrite(@ScriptDir & "\test.ini", "test", "count", $count)
	IniWrite(@ScriptDir & "\test.ini", "test", "num" & $count, $num)
EndFunc

Func ffff()
EndFunc











