#Include <Constants.au3>
#NoTrayIcon

Opt("TrayMenuMode",1)	; Default tray menu items (Script Paused/Exit) will not be shown.

$exititem		= TrayCreateItem("Exit")

TraySetState()

$start = 0
$id = 0
While 1
	$msg = TrayGetMsg()
	If $msg = $exititem Then ExitLoop
	$diff = TimerDiff($start)
	If $diff > 1000 Then
		$id = $id + 1
		TrayTip("", $id, 20)
		TraySetIcon("Shell32.dll",$id)
		$start = TimerInit()
	EndIF
WEnd

Exit