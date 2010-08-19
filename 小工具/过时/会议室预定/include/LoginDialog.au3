#include <GuiEdit.au3>
#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include "common.au3"

Global $Login_gui
Global $Login_txt_name
Global $Login_txt_pwd
Global $LOgin_cb_savePwd
Global $Login_btn_ok
Global $Login_btn_cancel

Login_login(WinGetHandle("", ""))

Func Login_login($guiParent)
	$Login_gui = GUICreate("��¼", 212, 135, 0, 0, Default, $WS_EX_MDICHILD, $guiParent)
	GUICtrlCreateLabel("�û���", 8, 8, 40, 17)
	$Login_txt_name = GUICtrlCreateInput(IniRead($INI_FILE, "main", "name", ""), 48, 8, 153, 21)
	GUICtrlCreateLabel("����", 8, 32, 28, 17)
	$Login_txt_pwd = GUICtrlCreateInput(IniRead($INI_FILE, "main", "pwd", ""), 48, 32, 153, 21, $ES_PASSWORD)
	$Login_cb_savePwd = GUICtrlCreateCheckbox("��ס�û���������", 8, 58)
	If StringLower(IniRead($INI_FILE, "main", "save", "true")) == "true" Then _
		GUICtrlSetState($Login_cb_savePwd, $GUI_CHECKED)
	$Login_btn_ok = GUICtrlCreateButton("ȷ��", 80, 102, 59, 25, 0)
	$Login_btn_cancel = GUICtrlCreateButton("ȡ��", 144, 102, 59, 25, 0)
	GUISetState(@SW_SHOW)
EndFunc

While 1
	Sleep(200)
WEnd

Func Login_ok()
	
EndFunc





