#include <GUIConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Include <File.au3>
#Include <GuiListBox.au3>

;~ Global $parentGUI = WinGetHandle("无标题 - 记事本")
;~ _EditPictures_showDialog("IMS会话建议呼叫流程")

;~ $src = FileRead("E:\AutoItWork\缩略语管理器\data\aaa\aaa.html")
;~ _EditPictures_getImageListFromSrc($src)

Func _EditPictures_showDialog($brief, $src, $parentGUI, $mode)
	GUISetState(@SW_DISABLE, $parentGUI)
	Local $gui_editPic = GUICreate("选择待编辑的图片", 558, 315, Default, Default, _
		$WS_CAPTION, $WS_EX_MDICHILD, $parentGUI)
	GUICtrlCreateLabel("当前缩略语的所有图片", 5, 8)
	Local $ls_pic = GUICtrlCreateList("", 2, 24, 135, 250)
	Local $files
	If $mode == $EDIT_PICTURE_MODE_MAIN Then
		$files = _EditPictures_getImageList($brief)
	Else
		$files = _EditPictures_getImageListFromSrc($src)
	EndIf
	Local $pictures = _EditPictures_getImageListStr($files)
	GUICtrlSetData($ls_pic, $pictures)
	_GUICtrlListBox_SetCurSel($ls_pic, 0)
	Local $btn_ok = GUICtrlCreateButton("确定", 2, 280, 65, 25, 0)
	Local $btn_cancel = GUICtrlCreateButton("取消", 72, 280, 65, 25, 0)
	Local $pic_pic = GUICtrlCreatePic("", 140, 2, 413, 310, _
		BitOR($SS_NOTIFY,$WS_GROUP,$WS_CLIPSIBLINGS))
	Local $lbl_pre = 0, $file
	If $files[0][0] <> 0 Then
		$file = GUICtrlRead($ls_pic)
		For $i = 1 To $files[0][0]
			If $file <> $files[$i][0] Then ContinueLoop
			GUICtrlSetImage($pic_pic, $files[$i][1])
			ExitLoop
		Next
	Else
		$lbl_pre = GUICtrlCreateLabel("无预览", 330, 150)
		GUICtrlSetFont(-1, 11, 400)
	EndIf
	Local $hk[2][2] = [["{enter}", $btn_ok], ["{esc}", $btn_cancel]]
	GUISetAccelerators($hk, $gui_editPic)
	GUISetState(@SW_SHOW)
	
	Local $nMsg
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $ls_pic
				GUICtrlDelete($lbl_pre)
				$file = GUICtrlRead($ls_pic)
				For $i = 1 To $files[0][0]
					If $file <> $files[$i][0] Then ContinueLoop
					GUICtrlSetImage($pic_pic, $files[$i][1])
					ExitLoop
				Next
			Case $btn_ok
				If $files[0][0] <> 0 Then
					If WinExists(GUICtrlRead($ls_pic) & " - 画图", "颜色") Then
						WinActivate(GUICtrlRead($ls_pic) & " - 画图", "颜色")
					Else
						$file = GUICtrlRead($ls_pic)
						For $i = 1 To $files[0][0]
							If $file <> $files[$i][0] Then ContinueLoop
							Run ('mspaint "' & $files[$i][1] & '"')
							If @error Then
								MsgBox(8256,"选择待编辑的图片", _
									"无法打开Windows自带的画图工具，无法编辑图片。", Default, $gui_editPic)
							EndIf
							ExitLoop
						Next
					EndIf
				Else
					GUISetState(@SW_DISABLE, $gui_editPic)
					MsgBox(8256,"选择待编辑的图片", _
						"当前缩略语没有包含图片。", Default, $parentGUI)
				EndIf
				GUISetState(@SW_ENABLE, $parentGUI)
				GUIDelete($gui_editPic)
				Return
			Case $btn_cancel
				GUISetState(@SW_ENABLE, $parentGUI)
				GUIDelete($gui_editPic)
				Return
		EndSwitch
	WEnd
EndFunc

Func _EditPictures_getImageList($brief)
	Local $path = @ScriptDir & "\data\" & $brief
	Local $search = FileFindFirstFile($path & "\*.*")
	Local $files[1][2] = [[0, ""]]
	If $search == -1 Then Return $files

	Local $file, $tmp, $ext
	While 1
		$file = FileFindNextFile($search) 
		If @error Then ExitLoop
		_PathSplit($file, $tmp, $tmp, $tmp, $ext)
		$ext = StringLower($ext)
		If  $ext == ".jpg"  Or _
			$ext == ".jpeg" Or _
			$ext == ".jpe"  Or _
			$ext == ".jpif" Or _
			$ext == ".gif"  Or _
			$ext == ".tif"  Or _
			$ext == ".tiff" Or _
			$ext == ".png"  Or _
			$ext == ".ico"  Or _
			$ext == ".bmp"  Then
			$files[0][0] += 1
			ReDim $files[$files[0][0] + 1][2]
			$files[$files[0][0]][0] = $file
			$files[$files[0][0]][1] = $path & "\" & $file
		EndIf
	WEnd
	FileClose($search)
	Return $files
EndFunc

Func _EditPictures_getImageListFromSrc($src)
	Local $n = StringInStr($src, "<img"), $m1, $m2, $m3
	Local $fn, $ext, $path
	Local $files[1][2] = [[0, ""]]
	While $n <> 0
		$m1 = StringInStr($src, "src", Default, 1, $n)
		$m2 = StringInStr($src, ">", Default, 1, $n)
		If $m1 > $m2 Then
			$n = StringInStr($src, "<img", Default, 1, $n + 1)
			ContinueLoop
		EndIf
		$m1 += 3 ; 扣去 src 的长度3
		$m2 = StringInStr($src, " ", Default, 1, $m1)
		$m3 = StringInStr($src, ">", Default, 1, $m1)
		If $m2 > $m3 Then $m2 = $m3
		$path = StringMid($src, $m1, $m2 - $m1)
		$path = StringReplace($path, "=", "")
		$path = StringReplace($path, '"', "")
		$path = StringReplace($path, "file:///", "")
		$path = StringReplace($path, "%20", " ")
		$path = StringReplace($path, "/", "\")
		_PathSplit($path, $fn, $fn, $fn, $ext)
		$files[0][0] += 1
		ReDim $files[$files[0][0] + 1][2]
		$files[$files[0][0]][0] = $fn
		$files[$files[0][0]][1] = $path
		ConsoleWrite($path & @CRLF)
		$n = StringInStr($src, "<img", Default, 1, $n + 1)
	WEnd
;~ 	$str = StringLeft($str, StringLen($str) - 1)
;~ 	ConsoleWrite($str & @CRLF)
	Return $files
EndFunc

Func _EditPictures_getImageListStr($files)
	Local $ret = "", $i
	For $i = 1 To $files[0][0]
		$ret &= $files[$i][0] & "|"
	Next
	Return StringLeft($ret, StringLen($ret))
EndFunc
