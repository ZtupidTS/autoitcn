#include <Array.au3>
#include <GUIConstants.au3>
#include <GuiTreeView.au3>
#Include <GuiList.au3>
#Include <Constants.au3>
#Include <GuiStatusBar.au3>
#include <file.au3>
#include <A3LTreeView.au3>

;~ #AutoIt3Wrapper_run_debug_mode=Y


Opt("WinTitleMatchMode", 2)
Opt("TrayMenuMode",1)
;~ Opt("GUICloseOnESC", 0)

HotKeySet("{F3}", "searchDown")
HotKeySet("^{F3}", "searchUp")
HotKeySet("{F8}", "jump2Def")
HotKeySet("{F9}", "jumpBack")
HotKeySet("{F10}", "jumpForward")
HotKeySet("+!f", "search")
HotKeySet("!r", "updateTreeViewNow")
HotKeySet("!l", "listSelected")
HotKeySet("!1", "setTrans00")
HotKeySet("!2", "setTrans25")
HotKeySet("!3", "setTrans50")
HotKeySet("!4", "setTrans75")

HotKeySet("^1", "abc")


init()
AdlibEnable("adlibFunc", 100)
main()

Func main()
	Local $flag = False, $updateFlag = False
	Local $lastTitle, $msg, $text, $state, $treeItemMsg, $count = 0
	Local $newTreeView
	While 1
		$isEditingFileSwitched = False
		If $isEnableAutoRefresh Then
			$updateFlag = False
			If $lastTitle <> $editingFileInfo[0] And $editingFileInfo[0] <> "" Then
				$lastTitle = $editingFileInfo[0]
				$flag = False
				$isEditingFileSwitched = True
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
		EndIf
		
		$message = GUIGetMsg(1)
		$msg = $message[0]
		$treeItemMsg = handleTreeItemMessages($msg)
		handlePosChangedMessage()
		
		Select
		Case $msg = $MSG_NOMSG
			
		Case $msg = $ti_var
			
		Case $msg = $ti_includes
			If Not $isTreeIncludeFixed Then
				GUICtrlSetState($mi_sortIncludeNameAsc + $sortOrderInclude, $GUI_UNCHECKED)
				$sortOrderInclude = Mod($sortOrderInclude + 1, 4)
				GUICtrlSetState($mi_sortIncludeNameAsc + $sortOrderInclude, $GUI_CHECKED)
				$text = sort($sortOrderInclude, $UPDATE_OPTION_INCLUDE)
				updateTreeView($UPDATE_OPTION_INCLUDE, $text, True)
			EndIf
			Sleep(20)
			
		Case $msg = $ti_func
			If Not $isTreeFuncFixed Then
				GUICtrlSetState($mi_sortFuncNameAsc + $sortOrderFunc, $GUI_UNCHECKED)
				$sortOrderFunc = Mod($sortOrderFunc + 1, 4)
				GUICtrlSetState($mi_sortFuncNameAsc + $sortOrderFunc, $GUI_CHECKED)
				$text = sort($sortOrderFunc, $UPDATE_OPTION_FUNC)
				updateTreeView($UPDATE_OPTION_FUNC, $text, True)
			EndIf
			Sleep(20)
			
		Case $treeItemMsg <> -1
			$theMsg = $MSG_POSCHANGED_GOTO
			ReDim $MSG_EXTENDED[2]
			$MSG_EXTENDED[0] = getCaretPos()
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

#region listening
Func listenMenuItemMsg($msg)
	Select
		Case $msg = $mi_sortFunc
			GUICtrlSetState($mi_sortFuncNameAsc + $sortOrderFunc, $GUI_UNCHECKED)
			$sortOrderFunc = Mod($sortOrderFunc + 1, 4)
			GUICtrlSetState($mi_sortFuncNameAsc + $sortOrderFunc, $GUI_CHECKED)
			$text = sort($sortOrderFunc, $UPDATE_OPTION_FUNC)
			updateTreeView($UPDATE_OPTION_FUNC, $text, True)
			Sleep(20)
			
		Case $msg = $mi_sortFuncNameAsc
			GUICtrlSetState($mi_sortFuncNameAsc + $sortOrderFunc, $GUI_UNCHECKED)
			GUICtrlSetState($mi_sortFuncNameAsc, $GUI_CHECKED)
			$sortOrderFunc = $SORT_ORDER_NAME_ASC
			$text = sort($sortOrderFunc, $UPDATE_OPTION_FUNC)
			updateTreeView($UPDATE_OPTION_FUNC, $text, True)
			Sleep(20)
			
		Case $msg = $mi_sortFuncNameDec
			GUICtrlSetState($mi_sortFuncNameAsc + $sortOrderFunc, $GUI_UNCHECKED)
			GUICtrlSetState($mi_sortFuncNameDec, $GUI_CHECKED)
			$sortOrderFunc = $SORT_ORDER_NAME_DEC
			$text = sort($sortOrderFunc, $UPDATE_OPTION_FUNC)
			updateTreeView($UPDATE_OPTION_FUNC, $text, True)
			Sleep(20)
			
		Case $msg = $mi_sortFuncLineAsc
			GUICtrlSetState($mi_sortFuncNameAsc + $sortOrderFunc, $GUI_UNCHECKED)
			GUICtrlSetState($mi_sortFuncLineAsc, $GUI_CHECKED)
			$sortOrderFunc = $SORT_ORDER_LINE_ASC
			$text = sort($sortOrderFunc, $UPDATE_OPTION_FUNC)
			updateTreeView($UPDATE_OPTION_FUNC, $text, True)
			Sleep(20)
			
		Case $msg = $mi_sortFuncLineDec
			GUICtrlSetState($mi_sortFuncNameAsc + $sortOrderFunc, $GUI_UNCHECKED)
			GUICtrlSetState($mi_sortFuncLineDec, $GUI_CHECKED)
			$sortOrderFunc = $SORT_ORDER_LINE_DEC
			$text = sort($sortOrderFunc, $UPDATE_OPTION_FUNC)
			updateTreeView($UPDATE_OPTION_FUNC, $text, True)
			Sleep(20)
			
		Case $msg = $mi_fixFunc
			Local $state
			If $isTreeFuncFixed Then
				$isTreeFuncFixed = False
				$state = $GUI_ENABLE
				GUICtrlSetState($mi_fixFunc, $GUI_UNCHECKED)
			Else
				$isTreeFuncFixed = True
				$state = $GUI_DISABLE
				GUICtrlSetState($mi_fixFunc, $GUI_CHECKED)
			EndIf
			GUICtrlSetState($mi_sortFunc, $state)
			GUICtrlSetState($mi_sortFuncNameAsc, $state)
			GUICtrlSetState($mi_sortFuncNameDec, $state)
			GUICtrlSetState($mi_sortFuncLineAsc, $state)
			GUICtrlSetState($mi_sortFuncLineDec, $state)
			
			
		Case $msg = $mi_sortInclude
			GUICtrlSetState($mi_sortIncludeNameAsc + $sortOrderInclude, $GUI_UNCHECKED)
			$sortOrderInclude = Mod($sortOrderInclude + 1, 4)
			GUICtrlSetState($mi_sortIncludeNameAsc + $sortOrderInclude, $GUI_CHECKED)
			$text = sort($sortOrderInclude, $UPDATE_OPTION_FUNC)
			updateTreeView($UPDATE_OPTION_FUNC, $text, True)
			Sleep(20)
			
		Case $msg = $mi_sortIncludeNameAsc
			GUICtrlSetState($mi_sortIncludeNameAsc + $sortOrderInclude, $GUI_UNCHECKED)
			GUICtrlSetState($mi_sortIncludeNameAsc, $GUI_CHECKED)
			$sortOrderInclude = $SORT_ORDER_NAME_ASC
			$text = sort($sortOrderInclude, $UPDATE_OPTION_INCLUDE)
			updateTreeView($UPDATE_OPTION_INCLUDE, $text, True)
			Sleep(20)
			
		Case $msg = $mi_sortIncludeNameDec
			GUICtrlSetState($mi_sortIncludeNameAsc + $sortOrderInclude, $GUI_UNCHECKED)
			GUICtrlSetState($mi_sortIncludeNameDec, $GUI_CHECKED)
			$sortOrderInclude = $SORT_ORDER_NAME_DEC
			$text = sort($sortOrderInclude, $UPDATE_OPTION_INCLUDE)
			updateTreeView($UPDATE_OPTION_INCLUDE, $text, True)
			Sleep(20)
			
		Case $msg = $mi_sortIncludeLineAsc
			GUICtrlSetState($mi_sortFuncNameAsc + $sortOrderInclude, $GUI_UNCHECKED)
			GUICtrlSetState($mi_sortIncludeLineAsc, $GUI_CHECKED)
			$sortOrderInclude = $SORT_ORDER_LINE_ASC
			$text = sort($sortOrderInclude, $UPDATE_OPTION_INCLUDE)
			updateTreeView($UPDATE_OPTION_INCLUDE, $text, True)
			Sleep(20)
			
		Case $msg = $mi_sortIncludeLineDec
			GUICtrlSetState($mi_sortIncludeNameAsc + $sortOrderInclude, $GUI_UNCHECKED)
			GUICtrlSetState($mi_sortIncludeLineDec, $GUI_CHECKED)
			$sortOrderInclude = $SORT_ORDER_LINE_DEC
			$text = sort($sortOrderInclude, $UPDATE_OPTION_INCLUDE)
			updateTreeView($UPDATE_OPTION_INCLUDE, $text, True)
			Sleep(20)
			
		Case $msg = $mi_fixInclude
			Local $state
			If $isTreeIncludeFixed Then
				$isTreeIncludeFixed = False
				$state = $GUI_ENABLE
				GUICtrlSetState($mi_fixInclude, $GUI_UNCHECKED)
			Else
				$isTreeIncludeFixed = True
				$state = $GUI_DISABLE
				GUICtrlSetState($mi_fixInclude, $GUI_CHECKED)
			EndIf
			GUICtrlSetState($mi_sortInclude, $state)
			GUICtrlSetState($mi_sortIncludeNameAsc, $state)
			GUICtrlSetState($mi_sortIncludeNameDec, $state)
			GUICtrlSetState($mi_sortIncludeLineAsc, $state)
			GUICtrlSetState($mi_sortIncludeLineDec, $state)
			
	EndSelect
	
EndFunc

Func listenTrayMenuMsg($msg)
	Select
	; tray messages
	Case $msg = $mi_properties
		MsgBox(8208, $APP_NAME, "Not supported yet")
		
	Case $msg = $mi_disableAutoRefresh
		If $isEnableAutoRefresh Then
			TrayItemSetText ( $mi_disableAutoRefresh, "&Enable Auto Refresh" )
			$isEnableAutoRefresh = False
		Else
			TrayItemSetText ( $mi_disableAutoRefresh, "&Disable Auto Refresh" )
			$isEnableAutoRefresh = True
		EndIf
		TraySetState()
		
	Case $msg = $mi_trayExit
;~ 		MsgBox(8208, $APP_NAME, "Code Navigator is shutting down...")
		Exit
			
	Case $msg = $mi_trans25
		setTrans(25)
		Sleep(20)
			
	Case $msg = $mi_trans50
		setTrans(50)
		Sleep(20)
			
	Case $msg = $mi_trans75
		setTrans(75)
		Sleep(20)
			
	Case $msg = $mi_trans00
		setTrans(0)
		Sleep(20)
	
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
			
		Case $msg = $btn_refresh
			updateTreeViewNow()
			Sleep(20)
			
		Case $msg = $btn_listResult
			listSelected()
			Sleep(20)
			
		Case $msg = $btn_searchResultJumpto
			Local $selected = GUICtrlRead($searchResult_list)
			Local $idx = _GUICtrlListGetAnchorIndex($searchResult_list) + 1
			Local $ln = $searchResultArray[$idx][1]
			$theMsg = $MSG_POSCHANGED_JUMP2DEF
			ReDim $MSG_EXTENDED[2]
			$MSG_EXTENDED[0] = getCaretPos()
			Local $tmpArr[2] = [$ln, 1]
			$MSG_EXTENDED[1] = $tmpArr
			goto($ln)
			Sleep(20)
			
		Case $msg = $btn_searchResultExit
			GUISetState(@SW_HIDE, $searchResult_GUI)
			Sleep(20)
			
		Case $msg = $btn_cancel
			GUISetState(@SW_HIDE, $find_gui)
			Sleep(20)
			
		Case $msg = $btn_jump2Def
			Local $text = ControlCommand ("SciTE", "Source", "[Instance:1; ID:350]", "GetSelected", "")
			Local $tmpArr
			If $text == 0 Then
				Return
			EndIf
			For $i = 1 To $functions[0][0]
				If StringLower(getFuncName($functions[$i][0])) == StringLower($text) Then
					$theMsg = $MSG_POSCHANGED_JUMP2DEF
					ReDim $MSG_EXTENDED[2]
					$MSG_EXTENDED[0] = getCaretPos()
					Local $tmpArr[2] = [$functions[$i][1], 6]
					$MSG_EXTENDED[1] = $tmpArr
					goto($functions[$i][1], 6)
					Return
				EndIf
			Next
			Sleep(20)
		
	EndSelect
EndFunc
#endregion

Func init()
	Global Const $APP_NAME = "SciTE Navigator"
	Global $SORT_ORDER_NAME_ASC = 0
	Global $SORT_ORDER_NAME_DEC = 1
	Global $SORT_ORDER_LINE_ASC = 2
	Global $SORT_ORDER_LINE_DEC = 3
	
	Global $UPDATE_OPTION_VAR = 1
	Global $UPDATE_OPTION_FUNC = 2
	Global $UPDATE_OPTION_INCLUDE = 4
	Global $UPDATE_OPTION_ALL = $UPDATE_OPTION_VAR + $UPDATE_OPTION_FUNC + $UPDATE_OPTION_INCLUDE
	
	Global $editingFileInfo[2] = ["", ""]
	Global $isEditingFileSwitched = True
	
	Global $hashmapBuf[1][2]
	Global $hashmapSize = 0
	
	; necessary infomation of certain message
	Global $MSG_EXTENDED[1]
	; message types
	Global $MSG_UNKOWN = -1
	Global $MSG_STARTING_UP = -100
	Global $MSG_NOMSG = 0
	Global $MSG_UPDATETREE_UPDATED = 1
	Global $MSG_POSCHANGED_GOTO = 2
	Global $MSG_POSCHANGED_JUMP2DEF = 3
	Global $MSG_POSCHANGED_JUMP2SEARCH = 4
	Global $theMsg = $MSG_STARTING_UP
	Global $MAX_POS_BUF =  200
	Global $posChangedBufBack[$MAX_POS_BUF]
	Global $posChangedBufForward[$MAX_POS_BUF]
	Global $isJumpBackEnabled = False
	Global $isJumpForwardEnabled = False
	Global $lastPosArr4Distance[2] = [1, 1]
	Global $jumpDirection = "backward"
	
	Global $SciTE_PATH = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\Autoit", "InstallDir") & _
		"\SciTE\SciTE.exe"
	If Not FileExists($SciTE_PATH) then
		MsgBox(8208, $APP_NAME, "SciTE has not been installed, reinstall SciTE first...")
		Exit
	EndIf
	Global $SciTE = WinGetHandle("SciTE", "Source")
	If $SciTE == "" Then
		TrayTip($APP_NAME, "Lauching SciTE...", 10)
		Run($SciTE_PATH)
		If WinWait("SciTE", "Source", 60) == 0 Then
			MsgBox(8208, $APP_NAME, "SciTE can not be launched!")
			Exit
		EndIf
		$SciTE = WinGetHandle("SciTE", "Source")
	EndIf
	Local $size = WinGetClientSize ("SciTE", "Source")
	Global $mySize[2] = [200, $size[1] - 110]
	Global $main_GUI = GUICreate($APP_NAME, $mySize[0], $mySize[1], $size[0] - $mySize[0] - 25, 65, _
		BitOR($WS_SIZEBOX, $WS_SYSMENU,$WS_CAPTION,$WS_POPUP,$WS_POPUPWINDOW,$WS_BORDER,$WS_CLIPSIBLINGS, $WS_MINIMIZEBOX), _
		$WS_EX_MDICHILD, $SciTE)
;~ 	Global $StatusBar = _GuiCtrlStatusBarCreate($main_GUI, -1, -1)
;~ 	_GuiCtrlStatusBarSetSimple($StatusBar)

	Global $btn_jumpBack = GUICtrlCreateButton("<-F9", 2, 5, 40, 20)
	GUICtrlSetState($btn_jumpBack, $GUI_DISABLE)
	GUICtrlSetResizing($btn_jumpBack, $GUI_DOCKALL)
	Global $btn_jumpForward = GUICtrlCreateButton("F10->", 48, 5, 40, 20)
	GUICtrlSetState($btn_jumpForward, $GUI_DISABLE)
	GUICtrlSetResizing($btn_jumpForward, $GUI_DOCKALL)
	Global $btn_refresh = GUICtrlCreateButton("&R", 94, 5, 20, 20)
	GUICtrlSetResizing($btn_refresh, $GUI_DOCKALL)
	Global $btn_listResult = GUICtrlCreateButton("&L", 120, 5, 20, 20)
	GUICtrlSetResizing($btn_listResult, $GUI_DOCKALL)
	Global $btn_jump2Def = GUICtrlCreateButton("&D", 146, 5, 20, 20)
	GUICtrlSetResizing($btn_jump2Def, $GUI_DOCKALL)
	Global $treeview = GUICtrlCreateTreeView(1, 30, $mySize[0] - 1, $mySize[1] - 30, _
		BitOr($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), _
		$WS_EX_CLIENTEDGE)
	Global $hdl_treeview = GUICtrlGetHandle($treeview)
	GUICtrlSetResizing($treeview, $GUI_DOCKBOTTOM + $GUI_DOCKTOP + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)

	Global $ti_var = GUICtrlCreateTreeViewItem("Variables (Click to Sort)", $treeview)
	Global $hdl_var = GUICtrlGetHandle($ti_var)
	Global $ti_func = GUICtrlCreateTreeViewItem("Functions (Click to Sort)", $treeview)
	Global $hdl_func = GUICtrlGetHandle($ti_func)
	Global $ti_includes = GUICtrlCreateTreeViewItem("Includes (Click to Sort)", $treeview)
	Global $hdl_includes = GUICtrlGetHandle($ti_includes)
	
	Global $searchResultSize[2] = [400, 200]
	Global $searchResult_GUI = GUICreate("Search Result - " & $APP_NAME, $searchResultSize[0], $searchResultSize[1], _
		$size[0] - $searchResultSize[0] - $mySize[0] - 25, 0, _
		BitOR($WS_SIZEBOX, $WS_SYSMENU,$WS_CAPTION,$WS_POPUP,$WS_POPUPWINDOW,$WS_BORDER,$WS_CLIPSIBLINGS), _
		$WS_EX_MDICHILD, $SciTE)
	Global $searchResult_list = GUICtrlCreateList("", 0, 25, $searchResultSize[0], $searchResultSize[1] - 25, _
		BitOR($WS_HSCROLL,$WS_VSCROLL,$WS_BORDER))
	GUICtrlSetResizing($searchResult_list, $GUI_DOCKBOTTOM + $GUI_DOCKTOP + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
	Global $btn_searchResultJumpto = GUICtrlCreateButton("&Jump To", 2, 2, 50, 20)
	GUICtrlSetResizing($btn_searchResultJumpto, $GUI_DOCKALL)
	Global $btn_searchResultExit = GUICtrlCreateButton("E&xit", 62, 2, 50, 20)
	GUICtrlSetResizing($btn_searchResultExit, $GUI_DOCKALL)

	Global $find_gui = GUICreate("Search and List - " & $APP_NAME, 380, 130, 193, 115, _
		BitOR($WS_SYSMENU,$WS_CAPTION,$WS_POPUP,$WS_POPUPWINDOW,$WS_BORDER,$WS_CLIPSIBLINGS), _
		$WS_EX_MDICHILD, $SciTE)
	GUICtrlCreateLabel("Fi&nd what:", 8, 16)
	Global $combo_findWhat = GUICtrlCreateCombo("", 72, 12, 189, 25)
	Global $cb_matchWholeWord = GUICtrlCreateCheckbox("Match &whole word only", 8, 48)
	Global $cb_matchCase = GUICtrlCreateCheckbox("Match &case", 8, 72)
	Global $cb_isList = GUICtrlCreateCheckbox("&List result in a window", 8, 96)
	GUICtrlSetState($cb_isList, $GUI_CHECKED)
	GUICtrlSetState($cb_isList, $GUI_DISABLE)
	$grp_direction = GUICtrlCreateGroup("Direction", 180, 48, 81, 65)
	Global $rdb_up = GUICtrlCreateRadio("&Up", 188, 68, 57, 17)
	Global $rdb_down = GUICtrlCreateRadio("&Down", 188, 88, 57, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $btn_findNext = GUICtrlCreateButton("&List Result", 276, 12, 97, 25, 0)
	Global $btn_cancel = GUICtrlCreateButton("&Cancel", 276, 56, 97, 25, 0)
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
	$functions[0][0] = 0
	Global $functionsToDel[2][3]
	Global $functionsToAdd[2][3]
	Global $includes[2][3]
	Global $includesToDel[2][3]
	Global $includesToAdd[2][3]
	
	createMenue()
	chechShortCut()
	
	GUISetState(@SW_HIDE, $searchResult_GUI)
	GUISetState(@SW_SHOW, $main_GUI)
EndFunc

Func adlibFunc()
	getCurFilePath()
	searchJump2Line()
	isSciTEExited()
;~ 	handlePosChangedMessage()
EndFunc

Func createMenue()
	$ContextMenu = GUICtrlCreateContextMenu($ti_func)
	Global $mi_sortFunc = GUICtrlCreateMenuitem("Sort", $ContextMenu)
	GUICtrlCreateMenuitem("", $ContextMenu)
	Global $isTreeFuncFixed = False
	Global $mi_sortFuncNameAsc = GUICtrlCreateMenuitem("Sort (a -> z)", $ContextMenu)
	Global $mi_sortFuncNameDec = GUICtrlCreateMenuitem("Sort (z -> a)", $ContextMenu)
	Global $mi_sortFuncLineAsc = GUICtrlCreateMenuitem("Sort (1 -> 9)", $ContextMenu)
	Global $mi_sortFuncLineDec = GUICtrlCreateMenuitem("Sort (9 -> 1)", $ContextMenu)
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
	If $isTreeFuncFixed Then
		GUICtrlSetState($mi_sortFunc, $GUI_DISABLE)
		GUICtrlSetState($mi_sortFuncNameAsc, $GUI_DISABLE)
		GUICtrlSetState($mi_sortFuncNameDec, $GUI_DISABLE)
		GUICtrlSetState($mi_sortFuncLineAsc, $GUI_DISABLE)
		GUICtrlSetState($mi_sortFuncLineDec, $GUI_DISABLE)
		GUICtrlSetState($mi_fixFunc, $GUI_CHECKED)
	EndIf
	
	$ContextMenu = GUICtrlCreateContextMenu($ti_includes)
	Global $mi_sortInclude = GUICtrlCreateMenuitem("Sort", $ContextMenu)
	GUICtrlCreateMenuitem("", $ContextMenu)
	Global $isTreeIncludeFixed = False
	Global $mi_sortIncludeNameAsc = GUICtrlCreateMenuitem("Sort by Name ASC", $ContextMenu)
	Global $mi_sortIncludeNameDec = GUICtrlCreateMenuitem("Sort by Name DEC", $ContextMenu)
	Global $mi_sortIncludeLineAsc = GUICtrlCreateMenuitem("Sort by Line ASC", $ContextMenu)
	Global $mi_sortIncludeLineDec = GUICtrlCreateMenuitem("Sort by Line DEC", $ContextMenu)
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
	If $isTreeIncludeFixed Then
		GUICtrlSetState($mi_sortInclude, $GUI_DISABLE)
		GUICtrlSetState($mi_sortIncludeNameAsc, $GUI_DISABLE)
		GUICtrlSetState($mi_sortIncludeNameDec, $GUI_DISABLE)
		GUICtrlSetState($mi_sortIncludeLineAsc, $GUI_DISABLE)
		GUICtrlSetState($mi_sortIncludeLineDec, $GUI_DISABLE)
		GUICtrlSetState($mi_fixInclude, $GUI_CHECKED)
	EndIf
	$ContextMenu = GUICtrlCreateContextMenu($ti_var)
	GUICtrlCreateMenuitem("Not Supported yet", $ContextMenu)
	
	Global $mi_properties = TrayCreateItem("&Properties...")
	TrayCreateItem("")
	Global $mi_trans00 = TrayCreateItem("&00% Trans (Alt + 1)", -1, -1, 1)
	Global $mi_trans25 = TrayCreateItem("&25% Trans (Alt + 2)", -1, -1, 1)
	Global $mi_trans50 = TrayCreateItem("&50% Trans (Alt + 3)", -1, -1, 1)
	Global $mi_trans75 = TrayCreateItem("&75% Trans (Alt + 4)", -1, -1, 1)
	TrayItemSetState($mi_trans50, $TRAY_CHECKED)
	TrayCreateItem("")
	Global $isEnableAutoRefresh = True
	Global $mi_disableAutoRefresh = TrayCreateItem("&Disable Auto Refresh")
	TrayCreateItem("")
	Global $mi_trayExit = TrayCreateItem("Exit")
	TraySetState()
EndFunc

Func updateTreeMap(ByRef $arrAll, $arrAdd)
	If $arrAdd[0][0] == 0 Then Return
	
	If $isEditingFileSwitched Then
		
	EndIf
	
	Local $idx
	For $i = 1 to $arrAdd[0][0]
		$idx = arraySearch($arrAll, $arrAdd[$i][0]) ; $idx: index of $tmpAdd
		$arrAll[ $idx ][2] = $arrAdd[$i][2]
	Next
EndFunc

Func updateTreeView($option, $parentText = " (Click to Sort)", $isSorting = False)
	$theMsg = $MSG_UPDATETREE_UPDATED
	;GUICtrlSetState($treeview, $GUI_HIDE)
	
	Local $idx
	Select
	Case BitAND($option, $UPDATE_OPTION_INCLUDE)
		If Not $isSorting Then
			For $i = 1 to $includesToDel[0][0]
				_TreeView_Delete($hdl_treeview, _
					_TreeView_FindNode($hdl_treeview, $includesToDel[$i][0]))
			Next
			For $i = 1 to $includesToAdd[0][0]
				$includesToAdd[$i][2] = GUICtrlCreateTreeViewItem( _
					$includesToAdd[$i][0], $ti_includes)
				$idx = arraySearch($includes, $includesToAdd[$i][0])
				$includes[$idx][2] = $includesToAdd[$i][2]
			Next
			$includesToAdd[0][0] = 0
		Else
			_GUICtrlTreeViewSetText($treeview, $ti_includes, "Functions (" & $parentText & ")")
			_TreeView_DeleteChildren($hdl_treeview, $hdl_includes)
			For $i = 1 to $includes[0][0]
				$includes[$i][2] = GUICtrlCreateTreeViewItem( _
					$includes[$i][0], $ti_includes)
			Next
		EndIf
		_GUICtrlTreeViewExpand($treeview, $isExpandedInclude, $ti_includes)
		Return
		
	Case BitAND($option, $UPDATE_OPTION_FUNC)
		If Not $isSorting Then
			For $i = 1 to $functionsToDel[0][0]
				_TreeView_Delete($hdl_treeview, _
					_TreeView_FindNode($hdl_treeview, $functionsToDel[$i][0]))
			Next
			For $i = 1 to $functionsToAdd[0][0]
				$functionsToAdd[$i][2] = GUICtrlCreateTreeViewItem( _
					$functionsToAdd[$i][0], $ti_func)
				$idx = arraySearch($functions, $functionsToAdd[$i][0])
				$functions[$idx][2] = $functionsToAdd[$i][2]
			Next
			$functionsToAdd[0][0] = 0
		Else
			_GUICtrlTreeViewSetText($treeview, $ti_func, "Functions (" & $parentText & ")")
			_TreeView_DeleteChildren($hdl_treeview, $hdl_func)
			For $i = 1 to $functions[0][0]
				$functions[$i][2] = GUICtrlCreateTreeViewItem( _
					$functions[$i][0], $ti_func)
			Next
		EndIf
		_GUICtrlTreeViewExpand($treeview, $isExpandedFunc, $ti_func)
		Return
	
	
	Case BitAND($option, $UPDATE_OPTION_VAR)
		
	EndSelect
	
;~ 	GuiCtrlSetState($ti_var, $GUI_FOCUS)

	;GUICtrlSetState($treeview, $GUI_SHOW)
EndFunc

Func updateTreeViewNow()
	If Not isHotkeyValid("!r", "updateTreeViewNow", true) Then Return

	analyse($editingFileInfo[0])
	updateTreeView($UPDATE_OPTION_FUNC, _
					sort($sortOrderFunc, $UPDATE_OPTION_FUNC))
	updateTreeView($UPDATE_OPTION_INCLUDE, _
					sort($sortOrderInclude, $UPDATE_OPTION_INCLUDE))
EndFunc

Func setTrans($trans = 0)
	WinSetTrans($main_GUI, "", Int( (100 - $trans) * 255 / 100))
EndFunc

Func setTrans00()
	If Not isHotkeyValid("!1", "setTrans00", true) Then Return
	
	setTrans(0)
EndFunc

Func setTrans25()
	If Not isHotkeyValid("!2", "setTrans25", true) Then Return
	
	setTrans(25)
EndFunc

Func setTrans50()
	If Not isHotkeyValid("!3", "setTrans50", true) Then Return
	
	setTrans(50)
EndFunc

Func setTrans75()
	If Not isHotkeyValid("!4", "setTrans75", true) Then Return
	
	setTrans(75)
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
			_ArraySort($functions, 0, 1, $functions[0][0], 3, 0)
			$text = "order: a -> z"
		EndIf
		If BitAND($option, $UPDATE_OPTION_INCLUDE) Then
			_ArraySort($includes, 0, 1, $includes[0][0], 3, 0)
			$text = "order: a -> z"
		EndIf
		
	Case $SORT_ORDER_NAME_DEC
		If BitAND($option, $UPDATE_OPTION_FUNC) Then
			_ArraySort($functions, 1, 1, $functions[0][0], 3, 0)
			$text = "order: z -> a"
		EndIf
		If BitAND($option, $UPDATE_OPTION_INCLUDE) Then
			_ArraySort($includes, 1, 1, $includes[0][0], 3, 0)
			$text = "order: z -> a"
		EndIf
		
	Case $SORT_ORDER_LINE_ASC
		If BitAND($option, $UPDATE_OPTION_FUNC) Then
			_ArraySort($functions, 0, 1, $functions[0][0], 3, 1)
			$text = "order: 1 -> 9"
		EndIf
		If BitAND($option, $UPDATE_OPTION_INCLUDE) Then
			_ArraySort($includes, 0, 1, $includes[0][0], 3, 1)
			$text = "order: 1 -> 9"
		EndIf
		
	Case $SORT_ORDER_LINE_DEC
		If BitAND($option, $UPDATE_OPTION_FUNC) Then
			_ArraySort($functions, 1, 1, $functions[0][0], 3, 1)
			$text = "order: 9 -> 1"
		EndIf
		If BitAND($option, $UPDATE_OPTION_INCLUDE) Then
			_ArraySort($includes, 1, 1, $includes[0][0], 3, 1)
			$text = "order: 9 -> 1"
		EndIf
	EndSwitch
	Return $text
EndFunc

Func goto($lineNum, $colNum = 1)
	RunWait($SciTE_PATH & " -goto:" & $lineNum & "," & $colNum)
EndFunc

;~ Func a()
;~ EndFunc

;~ Func b()
;~ EndFunc

Func analyse($f)
	$functionsToDel = $functions
	Local $functionsOrg = $functions
	$includesToDel = $includes
	Local $includesOrg = $includes
	Local $fileRecord
	_FileReadToArray ($f, $fileRecord )
	ReDim $functionsToAdd[ Int($fileRecord[0]/2) + 1 ][3]
	ReDim $includesToAdd[ Int($fileRecord[0]/2) + 1 ][3]
	$functionsToAdd[0][0] = 0
	$includesToAdd[0][0] = 0
	
	Local $line, $tmpName, $countFuncAdd = 0, $countIncludeAdd = 0, $idx
	For $i = 1 To $fileRecord[0]
		$line = StringStripWS($fileRecord[$i], 1 + 2 )
		
		If StringLower(StringLeft($line, 4)) == "func" Then
			$tmpName = StringStripWS( StringMid($line, 6), 1 + 2)
			$idx = arraySearch($functionsToDel, $tmpName) ; $idx: index of $tmpAdd
			If $idx <> -1 Then ; if found
				$functionsToDel[$idx][0] = ""
				$functions[$idx][1] = $i ; update the line num here
			Else ; new added item
				$countFuncAdd = $countFuncAdd + 1
				$functionsToAdd[0][0] = $countFuncAdd
				$functionsToAdd[ $functionsToAdd[0][0]][0] = $tmpName ; func name
				$functionsToAdd[ $functionsToAdd[0][0]][1] = $i ; line num
			EndIf
			ContinueLoop
		EndIf
		If StringLower(StringLeft($line, 8)) == "#include" Then
			$tmpName = StringStripWS( StringMid($line, 9), 1 + 2)
			$idx = arraySearch($includesToDel, $tmpName) ; $idx: index of $tmpAdd
			If $idx <> -1 Then ; if found
				$includesToDel[$idx][0] = ""
				$includes[$idx][1] = $i ; update the line num here
			Else ; new added item
				$countIncludeAdd = $countIncludeAdd + 1
				$includesToAdd[0][0] = $countIncludeAdd
				$includesToAdd[ $includesToAdd[0][0]][0] = $tmpName ; func name
				$includesToAdd[ $includesToAdd[0][0]][1] = $i ; line num
			EndIf
			ContinueLoop
		EndIf
	Next
	
	ReDim $functions[ $functions[0][0] + $countFuncAdd + 1][3]
	For $i = 1 to $functionsToAdd[0][0]
		$functions[ $functions[0][0] + $i ][0] = $functionsToAdd[$i][0]
		$functions[ $functions[0][0] + $i ][1] = $functionsToAdd[$i][1]
	Next
	$functions[0][0] = $functions[0][0] + $functionsToAdd[0][0]
	arrayTrimAllBlankElement($functionsToDel)
	For $i = 1 to $functionsToDel[0][0]
		$idx = arraySearch($functions, $functionsToDel[$i][0]) ; $idx: index of $tmpAdd
		If $idx <> -1 Then
			$functions[$idx][0] = ""
		EndIf
	Next
	arrayTrimAllBlankElement($functions)
	
	ReDim $includes[ $includes[0][0] + $countIncludeAdd + 1][3]
	For $i = 1 to $includesToAdd[0][0]
		$includes[ $includes[0][0] + $i ][0] = $includesToAdd[$i][0]
		$includes[ $includes[0][0] + $i ][1] = $includesToAdd[$i][1]
	Next
	$includes[0][0] = $includes[0][0] + $includesToAdd[0][0]
	arrayTrimAllBlankElement($includesToDel)
	For $i = 1 to $includesToDel[0][0]
		$idx = arraySearch($includes, $includesToDel[$i][0]) ; $idx: index of $tmpAdd
		If $idx <> -1 Then
			$includes[$idx][0] = ""
		EndIf
	Next
	arrayTrimAllBlankElement($includes)
EndFunc
 
Func arrayTrimAllBlankElement(ByRef $arr)
	Local $count = 0
	For $i = 1 To $arr[0][0]
		If $arr[$i][0] <> "" Then
			$count = $count + 1
			$arr[$count][0] = $arr[$i][0]
			$arr[$count][1] = $arr[$i][1]
			$arr[$count][2] = $arr[$i][2]
		EndIf
		
	Next
	
	If $count == 0 Then
		ReDim $arr[1][3]
		$arr[0][0] = 0
		Return
	EndIf
	ReDim $arr[$count + 1][3]
	$arr[0][0] = $count
EndFunc

; 
; $arr: 3 dimentions, as $functions or $includes
;
Func arraySearch($arr, $word)
	Local $tmp = StringLower($word)
	For $i = 1 To $arr[0][0]
		If StringLower($arr[$i][0]) == $tmp Then Return $i
	Next
	Return -1
EndFunc

;
; this function is an ablib function, run every 100milliseconds
; check is SciTE is closed very 50 * 100 milliseconds,
; just for saving resource
;
Func isSciTEExited()
	If $editingFileInfo[0] == "" Then
		If Not WinExists("SciTE", "Source") Then
			Exit
		EndIf
		
	EndIf
EndFunc

Func chechShortCut()
	Local $isInstalled = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\Autoit", _
									"isCodeNavigatorInstalled")
	If $isInstalled == "yes" Then
		Return
	EndIf
	If Not FileExists(@DesktopCommonDir & "\SciTE Code Naviator") Then
		FileCreateShortcut(@ScriptFullPath, _
							@DesktopCommonDir & "\SciTE Code Naviator", _
							@ScriptDir)
	EndIf
	If Not FileExists(@ProgramsCommonDir & "\AutoIt v3\SciTE Code Naviator") Then
		FileCreateShortcut(@ScriptFullPath, _
							@ProgramsCommonDir & "\AutoIt v3\SciTE Code Naviator", _
							@ScriptDir)
	EndIf
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\Autoit", _
			"isCodeNavigatorInstalled", "REG_SZ", "yes")
	
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
	$tmp = StringStripWS($line, 1 + 2)
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
	If StringLower(StringRight($file, 3)) <> "au3" Then
		$editingFileInfo[0] = ""
		Return
	EndIf
	$editingFileInfo[0] = $file
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
	If Not isHotkeyValid("^{F3}", "searchUp") Then Return
	
	searchPerform("Up")
EndFunc

Func searchDown()
	If Not isHotkeyValid("{F3}", "searchDown") Then Return
	
	searchPerform("Down")
EndFunc

Func searchPerform($dir = "down")
	Local $text = ControlCommand ("SciTE", "Source", "[Instance:1; ID:350]", "GetSelected", "")

	If $searchIsMatchCase Then
		Local $ret = ($text == $searchKeyWord)
	Else
		Local $ret = (StringLower($text) == StringLower($searchKeyWord))
	EndIf
	
	If $text == 0 Or $ret Then
		If StringLower($dir) == "down" Then
			Local $menuText = "Find &Next"
		Else
			Local $menuText = "Find Previou&s"
		EndIf
		WinMenuSelectItem("SciTE", "Source", "&Search", $menuText)
		Return
	EndIf
	
	; $text <> "" and $text <> $searchKeyWord
	$searchKeyWord = $text
	RunWait($SciTE_PATH & " -find:" & $text)
	If StringLower($dir) == "up" Then
		WinMenuSelectItem("SciTE", "Source", "&Search", "Find Previou&s")
		WinMenuSelectItem("SciTE", "Source", "&Search", "Find Previou&s")
	EndIf
EndFunc

Func search()
	If Not isHotkeyValid("+!f", "search") Then Return
	
	GUISetState(@SW_SHOW, $find_gui)
EndFunc

Func searchFindNext($kw = "")
	If $kw == "" Then
		$searchKeyWord = GUICtrlRead($combo_findWhat)
		If $searchKeyWord == "" then Return
		GUISetState(@SW_HIDE, $find_gui)
	Else
		$searchKeyWord = $kw
	EndIf
	$searchIsMatchWholeWord = GUICtrlRead($cb_matchWholeWord)
	$searchIsMatchCase = GUICtrlRead($cb_matchCase)
	Local $searchDown = GUICtrlRead($rdb_down)
	Local $isMatchWholeWord
	Local $isMatchCase
	Local $isList = GUICtrlRead($cb_isList)
	If $isList == $GUI_CHECKED Then
		searchListResult($isMatchWholeWord, $isMatchCase)
	EndIf
EndFunc

Func listSelected()
	If Not isHotkeyValid("!l", "listSelected", True) Then Return
	
	Local $text = ControlCommand ("SciTE", "Source", "[Instance:1; ID:350]", "GetSelected", "")
	If $text == 0 Then
		GUISetState(@SW_SHOW, $find_gui)
	Else
		searchFindNext($text)
	EndIf
EndFunc

Func searchListResult($isMatchWholeWord, $isMatchCase)
	Local $filePath = $editingFileInfo[0]
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
	$MSG_EXTENDED[0] = getCaretPos()
	Local $tmpArr[2] = [$ln, 1]
	$MSG_EXTENDED[1] = $tmpArr
	
	goto($ln)
EndFunc

Func jump2Def()
	If Not isHotkeyValid("{F8}", "jump2Def") Then Return
	
;~ 	Local $clipBak = ClipGet()
;~ 	If @error then $clipBak = ""
;~ 	ClipPut("")
;~ 	Sleep(30)
;~ 	WinMenuSelectItem("SciTE", "Source", "&Edit", "&Copy")
;~ 	Sleep(30)
;~ 	Local $text = ClipGet()
;~ 	ClipPut($clipBak)
	Local $text = ControlCommand ("SciTE", "Source", "[Instance:1; ID:350]", "GetSelected", "")
	If $text == 0 Then
		HotKeySet("{F8}")
		Send("{F8}")
		HotKeySet("{F8}", "jump2Def")
		Return
	EndIf
	For $i = 1 To $functions[0][0]
		If StringLower(getFuncName($functions[$i][0])) == StringLower($text) Then
			$theMsg = $MSG_POSCHANGED_JUMP2DEF
			ReDim $MSG_EXTENDED[2]
			$MSG_EXTENDED[0] = getCaretPos()
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
	If Not isHotkeyValid("{F9}", "jumpBack", true) Then Return
	
	If Not $isJumpBackEnabled Then
		Return
	EndIf
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
	If Not isHotkeyValid("{F10}", "jumpForward", true) Then Return
	
	If Not $isJumpForwardEnabled Then
		Return
	EndIf
	Local $pos = _ArrayPop($posChangedBufForward)
	If $pos = "" Then
		disableJumpForward()
		Return
	EndIf
	_ArrayPush($posChangedBufBack, $pos)
	enableJumpBack()
	Local $arr = resolvePos($pos)
	goto($arr[0], $arr[1])
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

Func getCaretPos()
	Local $pos[2]
	$pos[0] = ControlCommand ("SciTE", "Source", "[Instance:1; ID:350]", "GetCurrentLine", "")
	$pos[1] = ControlCommand ("SciTE", "Source", "[Instance:1; ID:350]", "GetCurrentCol", "")
	
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

Func isHotkeyValid($key, $funName, $isEnableOn2Win = False)
	If $isEnableOn2Win Then
		If Not WinActive("SciTE", "Source") And _
			Not WinActivate($APP_NAME, "<-") Then
			HotKeySet($key)
			Send($key)
			HotKeySet($key, $funName)
			Return False
		Else
			Return True
		EndIf
	EndIf
	
	If Not WinActive("SciTE", "Source") Then
		HotKeySet($key)
		Send($key)
		HotKeySet($key, $funName)
		Return False
	Else
		Return True
	EndIf
	Return False
EndFunc


; ===========================================================================
;
;  hashmap utilites
;
; ===========================================================================
Func hashMapPut($key, $value)
	Local $isKeyExisted = False, $idx
	For $idx = 0 to $hashmapSize - 1
		If $hashmapBuf[$idx][0] == $key Then
			$isKeyExisted = True
			ExitLoop
		EndIf
	Next
	If $isKeyExisted Then
		$hashmapBuf[$idx][1] = $value
		Return $hashmapSize
	Else
		ReDim $hashmapBuf[ $hashmapSize + 1 ][2]
		$hashmapBuf[$hashmapSize][0] = $key
		$hashmapBuf[$hashmapSize][1] = $value
		$hashmapSize = $hashmapSize + 1
		Return $hashmapSize
	EndIf
EndFunc

; if the value does not exist, "" is returned
Func hashMapGet($key)
	For $idx = 0 to hashMapSize() - 1
		If $hashmapBuf[$idx][0] == $key Then
			Return $hashmapBuf[$idx][1]
		EndIf
	Next
	Return ""
EndFunc

Func hashMapSize()
	Return $hashmapSize
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
	For $i = 1 to $functions[0][0]
		ConsoleWrite("all: " & $functions[$i][1] & "	" & _
			$functions[$i][2] & "	" & _
			$functions[$i][0] & @CRLF)
	Next
;~ 	ConsoleWrite("**************************************************************" & @CRLF)
;~ 	For $i = 0 to UBound($functionsToDel,1) - 1
;~ 		ConsoleWrite("del: " & $functionsToDel[$i][1] & "	" & _
;~ 			$functionsToDel[$i][2] & "	" & _
;~ 			$functionsToDel[$i][0] & @CRLF)
;~ 	Next
;~ 	ConsoleWrite("**************************************************************" & @CRLF)
;~ 	For $i = 1 to $functionsToAdd[0][0]
;~ 		ConsoleWrite("add: " & $functionsToAdd[$i][1] & "	" & _
;~ 			$functionsToAdd[$i][2] & "	" & _
;~ 			$functionsToAdd[$i][0] & @CRLF)
;~ 	Next
;~ 	ConsoleWrite("**************************************************************" & @CRLF)



;~ 	For $i = 1 to $functionsToDel[0][0]
;~ 		ConsoleWrite("$functionsToDel[" & $i & "][2]=" & $functionsToDel[$i][0] & @CRLF)
;~ 	Next
;~ 	ConsoleWrite("**************************************************************" & @CRLF)
;~ 	For $i = 1 to $functionsToAdd[0][0]
;~ 		ConsoleWrite("$functionsToAdd[" & $i & "][2]=" & $functionsToAdd[$i][0] & @CRLF)
;~ 	Next
;~ 	ConsoleWrite("**************************************************************" & @CRLF)
;~ 	ConsoleWrite("**************************************************************" & @CRLF)
	ConsoleWrite("**************************************************************" & @CRLF)
	ConsoleWrite("**************************************************************" & @CRLF)
;~ 	If Not WinActive("SciTE", "Source") Then
;~ 		Return
;~ 	EndIf
;~ 	consolewrite("$main_GUI=" & $main_GUI & @crlf)
;~ 	consolewrite("$treeview=" & $treeview & @crlf)
;~ 	consolewrite("$ti_var=" & $ti_var & @crlf)
;~ 	consolewrite("$ti_includes=" & $ti_includes & @crlf)
;~ 	consolewrite("$ti_func=" & $ti_func & @crlf)
;~ 	consolewrite("$searchResult_GUI=" & $searchResult_GUI & @crlf)
;~ 	consolewrite("$searchResult_list=" & $searchResult_list & @crlf)
;~ 	consolewrite("$btn_searchResultJumpto=" & $btn_searchResultJumpto & @crlf)
;~ 	consolewrite("$btn_searchResultExit=" & $btn_searchResultExit & @crlf)
;~ 	consolewrite("$find_gui=" & $find_gui & @crlf)
;~ 	consolewrite("$combo_findWhat=" & $combo_findWhat & @crlf)
;~ 	consolewrite("$cb_matchWholeWord=" & $cb_matchWholeWord & @crlf)
;~ 	consolewrite("$cb_matchCase=" & $cb_matchCase & @crlf)
;~ 	consolewrite("$cb_isList=" & $cb_isList & @crlf)
;~ 	consolewrite("$rdb_up=" & $rdb_up & @crlf)
;~ 	consolewrite("$rdb_down=" & $rdb_down & @crlf)
;~ 	consolewrite("$btn_findNext=" & $btn_findNext & @crlf)
;~ 	consolewrite("$btn_cancel=" & $btn_cancel & @crlf)
;~ 	
;~ 	For $i = 1 to $ti_tmpFunc[0]
;~ 		ConsoleWrite("$ti_tmpFunc[" & $i & "]=" & $ti_tmpFunc[$i] & @CRLF)
;~ 	Next
;~ 	For $i = 1 to $ti_tmpIncludes[0]
;~ 		ConsoleWrite("$ti_tmpIncludes[" & $i & "]=" & $ti_tmpIncludes[$i] & @CRLF)
;~ 	Next
;~ 	For $i = 1 to $ti_tmpVar[0]
;~ 		ConsoleWrite("$ti_tmpVar[" & $i & "]=" & $ti_tmpVar[$i] & @CRLF)
;~ 	Next
;~ 	For $i = 1 to $includes[0][0]
;~ 		ConsoleWrite("$includes[" & $i & "][2]=" & $includes[$i][2] & @CRLF)
;~ 	Next
;~ 	For $i = 1 to $var[0][0]
;~ 		ConsoleWrite("$var[" & $i & "][2]=" & $var[$i][2] & @CRLF)
;~ 	Next
EndFunc


Func testMaxCount($num)
	$count = IniRead(@ScriptDir & "\test.ini", "test", "count", 0)
	$count = $count + 1
	IniWrite(@ScriptDir & "\test.ini", "test", "count", $count)
	IniWrite(@ScriptDir & "\test.ini", "test", "num" & $count, $num)
EndFunc

Func isExist($id)
	For $i = 1 To $functions[0][0]
		If $functions[$i][2] == $id Then
			Return True
		EndIf
	Next
	Return False
EndFunc



;~ Func a($a, $b, $c)
;~ 	
;~ EndFunc

;~ Func b()
;~ 	
;~ EndFunc

;~ Func c()
;~ 	
;~ EndFunc

;~ Func d()
;~ 	
;~ EndFunc

;~ Func e()
;~ 	
;~ EndFunc

;~ Func f()
;~ 	
;~ EndFunc

;~ Func g()
;~ 	
;~ EndFunc

;~ Func h()
;~ 	
;~ EndFunc

;~ Func i()
;~ 	
;~ EndFunc