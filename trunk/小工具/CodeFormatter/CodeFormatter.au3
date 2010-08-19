#include <GUIConstants.au3>
#include <File.au3>

#AutoIt3Wrapper_Icon=".\dbpilot.ico"

setLayout()
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $btn_browse
			chooseFile()
		
		Case $rdo_fromFile
			GUICtrlSetState($txt_file, $GUI_ENABLE)
			GUICtrlSetState($btn_browse, $GUI_ENABLE)
			GUICtrlSetState($txt_text, $GUI_DISABLE)
			GUICtrlSetState($btn_browse, $GUI_FOCUS)
		Case $rdo_fromText
			GUICtrlSetState($txt_file, $GUI_DISABLE)
			GUICtrlSetState($btn_browse, $GUI_DISABLE)
			GUICtrlSetState($txt_text, $GUI_ENABLE)
			GUICtrlSetState($txt_text, $GUI_FOCUS)
			
		Case $btn_format
			If GUICtrlRead($rdo_fromFile) == $GUI_CHECKED Then
				Dim $aRecords
				If Not _FileReadToArray(GUICtrlRead($txt_file), $aRecords) Then
					MsgBox(4096, "文件不存在", "请确认待转换的文件路径正确！")
					ContinueLoop
				EndIf
				format($aRecords)
			Else
				format(getArray(GUICtrlRead($txt_text)))
			EndIf
			
		Case $btn_copy
			ClipPut(GUICtrlRead($txt_text))
			
		Case $GUI_EVENT_CLOSE
			Exit
		Case $btn_exit
			Exit

	EndSwitch
WEnd

Func setLayout()
	$aForm = GUICreate("Code Formatter", 570, 534, 193, 115)
	Global $txt_file = GUICtrlCreateInput("", 8, 32, 505, 21)
	GUICtrlSetState(-1, $GUI_DISABLE)
	Global $btn_browse = GUICtrlCreateButton("...", 528, 32, 35, 25, 0)
	GUICtrlSetState(-1, $GUI_DISABLE)
	Global $rdo_fromFile = GUICtrlCreateRadio("转换文件", 8, 8, 73, 17)
	Global $rdo_fromText = GUICtrlCreateRadio("转换文本", 8, 64, 73, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	Global $txt_text = GUICtrlCreateEdit("", 8, 88, 553, 385)
	GUICtrlSetState(-1, $GUI_FOCUS)
	Global $progressbar = GUICtrlCreateProgress (8,483,553,10)
	Global $btn_format = GUICtrlCreateButton("转换", 312, 503, 75, 25, 0)
	Global $btn_copy = GUICtrlCreateButton("拷贝", 400, 503, 75, 25, 0)
	Global $btn_exit = GUICtrlCreateButton("退出", 488, 503, 75, 25, 0)
	GUISetState(@SW_SHOW)
EndFunc

Func chooseFile()
	Local $initDir = GUICtrlRead($txt_file)
	If Not FileExists($initDir) Then $initDir = @DesktopDir
	Local $file = FileOpenDialog("选择文件", $initDir, "All (*.*)" , 1)
	If $file == "" Then Return
	GUICtrlSetData($txt_file, $file)
EndFunc

Func format($fileRecords)
	Local $line, $count
	Local $buff = ""
	Local $tabs = ""
	GUICtrlSetState($btn_format, $GUI_DISABLE)
	GUICtrlSetState($rdo_fromFile, $GUI_DISABLE)
	GUICtrlSetState($rdo_fromText, $GUI_DISABLE)
	GUICtrlSetData($progressbar, 0)
	For $x = 1 to $fileRecords[0]
		GUICtrlSetData($progressbar, Int(($x/$fileRecords[0]) * 100))
		$line = $fileRecords[$x]
		If @error = -1 Then ExitLoop
		$line = StringStripWS($line, 1 + 2)
		$count = analyzeLine($line)
		$tabsBak = $tabs
		If $count > 0 Then
			For $i = 1 To $count
				$tabs = $tabs & @TAB
			Next
			$buff = $buff & $tabsBak & $line & @CRLF
			ContinueLoop
		ElseIf $count < 0 Then
			$tabs = StringRight($tabs, StringLen($tabs) + $count)
			$buff = $buff & $tabs & $line & @CRLF
			ContinueLoop
		EndIf
		$buff = $buff & $tabsBak & $line & @CRLF
	Next
	GUICtrlSetData($txt_text, $buff)
	GUICtrlSetState($btn_format, $GUI_ENABLE)
	GUICtrlSetState($rdo_fromFile, $GUI_ENABLE)
	GUICtrlSetState($rdo_fromText, $GUI_ENABLE)
	GUICtrlSetState($txt_text, $GUI_ENABLE)
EndFunc

;判断一行数据是否包含 {, }, (, )等
;返回：
; {: 1
; }: -1
; (: 1
; ): -1
; other: 0
Func analyzeLine($line)
	If $line == "" Then Return 0
	Local $char
	Local $flag = False
	Local $flag1 = False ;双引号
	Local $flag2 = False ;单引号
	Local $count1 = 0 ;花括号
	Local $count2 = 0 ;圆括弧
	For $i = 1 To StringLen($line)
		$char = StringMid($line, $i, 1)
		If $char == '"' And Not $flag2 Then $flag1 = Not $flag1
		If $char == "'" And Not $flag1 Then $flag2 = Not $flag2
		If $flag1 Or $flag2 Then
			$flag = True
		Else
			$flag = False
		EndIf
;~ 		ConsoleWrite("$char: " & $char & @CRLF)
;~ 		ConsoleWrite("flag1: " & $flag1 & @CRLF)
;~ 		ConsoleWrite("flag2: " & $flag2 & @CRLF)
;~ 		ConsoleWrite("flag: " & $flag & @CRLF & "****************" & @CRLF)
		If $char == "{" And Not $flag Then $count1 = $count1 + 1
		If $char == "(" And Not $flag Then $count2 = $count2 + 1
		If $char == "}" And Not $flag Then $count1 = $count1 - 1
		If $char == ")" And Not $flag Then $count2 = $count2 - 1
	Next
	If ($count1 >= 0 And $count2 >= 0) Or ($count1 <= 0 And $count2 <= 0) Then
		Return $count1 + $count2
	ElseIf $count1 < 0 Then
		Return $count1
	ElseIf $count2 < 0 Then
		Return $count1
	EndIf
		
EndFunc

Func getArray($text)
	FileDelete(@TempDir & "\codeformattertmpfile.txt")
	FileWrite(@TempDir & "\codeformattertmpfile.txt", $text)
;~ 	ClipPut(@TempDir)
	Dim $aRecords
	If Not _FileReadToArray(@TempDir & "\codeformattertmpfile.txt", $aRecords) Then
		MsgBox(4096, "保存临时文件失败", "我也不知道为什么:(")
		Exit
	EndIf
	Return $aRecords
EndFunc
