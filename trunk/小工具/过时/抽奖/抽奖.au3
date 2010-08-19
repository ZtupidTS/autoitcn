#include <StaticConstants.au3>
#include <GUIConstants.au3>
#include <Sound.au3>

#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("抽奖", 800, 600)
GUICtrlCreatePic("bg.JPG", 0, 0, 800, 600)
GUICtrlCreateLabel("按下回车开始抽奖，再次按下回车停止。", 8, 8, 350)
GUICtrlSetFont(-1, 13, 800, 0, "宋体")
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetBkColor(-1, 0x0d9bf0)
$lable = GUICtrlCreateLabel("开始", 100, 240, 600, 160, $SS_CENTER)
GUICtrlSetFont(-1, 120, 800, 0, "宋体")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x0392f0)
$dummy = GUICtrlCreateDummy()
Dim $hk[1][2] = [["{enter}", $dummy]]
GUISetAccelerators($hk)
GUISetState(@SW_SHOW)
$sound = _SoundOpen("sound.wma", "Startup")
#EndRegion ### END Koda GUI section ###

Dim $rewards[11]
Dim $running = False
Dim $idx = 0
Dim $text
_readConf()

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $dummy
			_go()
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
	If $running Then
		$text = $rewards[$idx+1]
		GUICtrlSetData($lable, $text)
		$idx = Mod($idx + 1, $rewards[0])
	EndIf
	Sleep(100)
WEnd

Func _go()
	$running = Not $running
	If $running Then
		_SoundPlay($sound, 0)
	Else
		_SoundPause($sound)
	EndIf
EndFunc


Func _readConf()
	$rewards[0] = 0
	Local $item
	For $i = 1 To 10
		$item = IniRead("conf.ini", "main", "item" & $i, "_error_")
		If $item == "_error_" Then ExitLoop
		$rewards[0] += 1
		$rewards[$i] = $item
	Next
EndFunc











