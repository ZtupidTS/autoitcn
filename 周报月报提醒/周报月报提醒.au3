#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <Date.au3>
#NoTrayIcon

#AutoIt3Wrapper_Icon = Clock.ico

Opt("MustDeclareVars", 1)

Global $shown = False
Global $interval = 60000*60

AdlibEnable("notify", $interval)
notify()
While True
	Sleep(60000000)
WEnd

Func notify()
	Local $hintWeek = ""
	Local $hintMonth = ""
	If @WDAY <> 2 Then
		Return
	EndIf
	$hintWeek = "发送周报"
	popup($hintWeek, $hintMonth)
EndFunc

Func popup($hintWeek, $hintMonth)
	If $shown Then Return
	$shown = True
	AdlibDisable()
	GUICreate("周报月报提醒", 145, 142, Default, Default, Default, $WS_EX_TOPMOST)
	GUICtrlCreateLabel("提醒：", 8, 8, 40, 17)
	Local $btn_later = GUICtrlCreateButton("过15分钟后再提醒", 8, 80, 131, 25, 0)
	Local $btn_clear = GUICtrlCreateButton("消除", 8, 112, 131, 25, 0)
	Local $lbl_week = GUICtrlCreateLabel($hintWeek, 8, 32, 52, 17)
	GUICtrlSetColor(-1, 0xff0000)
	Local $lbl_month = GUICtrlCreateLabel($hintMonth, 8, 56, 52, 17)
	GUICtrlSetColor(-1, 0x0000ff)
	GUISetState(@SW_SHOW)

	Local $restSec
	While 1
		Local $nMsg = GUIGetMsg()
		Switch $nMsg
			Case $btn_clear, $GUI_EVENT_CLOSE
				GUIDelete()
				$restSec = 86400 - (_DateDiff( 's',"1970/01/01 00:00:00",_NowCalc()) - _DateDiff( 's',"1970/01/01 00:00:00",_NowCalcDate()))
				Sleep($restSec*1000)
				ExitLoop
			Case $btn_later
				GUISetState(@SW_HIDE)
				Sleep(15*60000)
				GUISetState(@SW_SHOW)
		EndSwitch
	WEnd
	$shown = False
	AdlibEnable("notify", $interval)
EndFunc
