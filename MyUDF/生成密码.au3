#include <GUIConstants.au3>
#include "Password.au3"
#NoTrayIcon

#AutoIt3Wrapper_icon = D:\My Documents\My Pictures\图标大全\PowerPoint X.ico
#AutoIt3Wrapper_Res_SaveSource = false

$gui = GUICreate("密码生成", 321, 187, 193, 115)
GUICtrlCreateLabel("原始密码字符串，长度小于64，不允许中文。", 24, 16)
$txt_src = GUICtrlCreateInput("", 24, 40, 273, 21)
GUICtrlCreateLabel("生成的密码字符串：", 24, 80, 112, 17)
$txt_pwd = GUICtrlCreateInput("", 24, 104, 273, 21)
$btn_change = GUICtrlCreateButton("转换/拷贝", 136, 144, 75, 25, 0)
$btn_exit = GUICtrlCreateButton("退出", 224, 144, 75, 25, 0)
GUICtrlCreateLabel("^!H", 24, 144)
$btn_chgback = GUICtrlCreateButton("逆转/拷贝", 24, 144, 75, 25, 0)
GUICtrlSetState(-1, $GUI_HIDE)
$dm_show = GUICtrlCreateDummy()
Dim $hotkey[1][2] = [["^!h", $dm_show]]
GUISetAccelerators($hotkey, $gui)
GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $btn_change
			Local $src = GUICtrlRead($txt_src)
			If StringLen($src) > $_MAX_MASKED_PASSWORD_LENGTH/2 Then
				MsgBox(8208, "错误", "原始密码字符串，长度应该小于64。")
				ContinueLoop
			EndIf
			Local $pwd = _code($src)
			GUICtrlSetData($txt_pwd, $pwd)
			ClipPut($pwd)
		Case $btn_chgback
			Local $src = GUICtrlRead($txt_pwd)
			If StringLen($src) <> $_MAX_MASKED_PASSWORD_LENGTH + 12 Then
				MsgBox(8208, "错误", "待解码的密码错误，长度应该等于" & $_MAX_MASKED_PASSWORD_LENGTH + 12)
				ContinueLoop
			EndIf
			Local $pwd = _decode($src)
			GUICtrlSetData($txt_src, $pwd)
			ClipPut($pwd)
		Case $dm_show
			show()
		Case $btn_exit
			Exit
		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch
WEnd

Func show()
	Local $sInputBoxAnswer = InputBox("第二次认证","请提供二次认证密码：","","*","200","120")
	Select
		Case @Error = 0 ;OK - The string returned is valid
			If $sInputBoxAnswer <> "5788312" Then Return
		Case @Error = 1 ;The Cancel button was pushed
			Return
		Case @Error = 3 ;The InputBox failed to open
			Return
	EndSelect
	GUICtrlSetState($btn_chgback, $GUI_SHOW)
EndFunc
