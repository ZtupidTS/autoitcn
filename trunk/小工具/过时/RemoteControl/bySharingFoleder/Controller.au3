#include <GUIConstants.au3>
#include "Common.au3"

Opt("MustDeclareVars", 1)

Global $CLIENT_WIDTH = 800
Global $CLIENT_HEIGH = 600
Global $controlleeId = ""
Global $controllerId = ""
Global $dirctory = ""
Global $APP_NAME = "远程控制"
Global $SOME_TEXT = "用来区分这个窗口是我的。"
Global $pic_screen
Global $gui

setLayout()
startControlling()
AdlibEnable("receiveData", 500)

Local $msg
While 1
	$msg = GUIGetMsg()
    If $msg = $GUI_EVENT_CLOSE Then ExitLoop
WEnd

Func setLayout()
	$controlleeId = RegRead($REG_BASE, "ControlleeID")
	$controlleeId = InputBox($APP_NAME,"输入当前的被控制ID：", $controlleeId, " ","200","120","-1","-1")
	If $controlleeId == "" Then
		MsgBox(8208, $APP_NAME, "必须输入一个被控制ID。")
		Exit
	EndIf
	RegWrite($REG_BASE, "ControlleeID", "REG_SZ", $controlleeId)
	$controllerId = RegRead($REG_BASE, "ControllerID")
	$controllerId = InputBox($APP_NAME,"输入当前的控制者ID：", $controllerId, " ","200","120","-1","-1")
	If $controllerId == "" Then
		MsgBox(8208, $APP_NAME, "必须输入一个控制者ID。")
		Exit
	EndIf
	RegWrite($REG_BASE, "ControllerID", "REG_SZ", $controllerId)
	$dirctory = StringReplace(@AppDataDir, "Application Data", "Local Settings\Application Data") & "\Microsoft\Messenger\"
	$dirctory = $dirctory & $controllerId & "\Sharing Folders\" & $controlleeId & "\"
	
	$gui = GUICreate($APP_NAME, $CLIENT_WIDTH, $CLIENT_HEIGH)
	GUICtrlCreateLabel($SOME_TEXT, 20, 20)
	$pic_screen = GUICtrlCreatePic(@ScriptDir & "\Wait4Data.jpg", 0, 0, $CLIENT_WIDTH, $CLIENT_HEIGH)
	GUISetState ()
EndFunc

Func receiveData()
	Local $stat =  WinGetState($APP_NAME, $SOME_TEXT)
	If BitAND($stat, 8) Then ; 程序窗口被激活，让被控制端传送数据过来。否则不传送数据
		FileDelete($dirctory & $FILENAME_PAUSE_CONTROL_TRIGGER)
		If Not FileExists($dirctory & $FILENAME_SNAPSHOT) Then Return
		FileMove($dirctory & $FILENAME_SNAPSHOT, @ScriptDir & "\" & $FILENAME_SNAPSHOT, 1)
		GUICtrlSetImage($pic_screen, @ScriptDir & "\" & $FILENAME_SNAPSHOT)
	Else
		FileWrite($dirctory & $FILENAME_PAUSE_CONTROL_TRIGGER, "paused.")
	EndIf
EndFunc

Func startControlling()
	If FileExists($dirctory & $FILENAME_START_CONTROL_TRIGGER) Then
		MsgBox(8208,$APP_NAME,"控制端可能发生异常，控制失败。")
		Exit
	EndIf
	FileWrite($dirctory & $FILENAME_START_CONTROL_TRIGGER, "start.")
EndFunc

Func OnAutoItExit()
	If FileExists($dirctory & $FILENAME_STOP_CONTROL_TRIGGER) Then
		MsgBox(8208,$APP_NAME,"控制端可能发生异常，停止控制失败。")
		Exit
	EndIf
	FileWrite($dirctory & $FILENAME_STOP_CONTROL_TRIGGER, "stop.")
EndFunc