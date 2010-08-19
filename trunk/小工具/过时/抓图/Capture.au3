
#include <ScreenCapture.au3>
$hGUI = ControlGetHandle("Flex Profiling", "", "[CLASS:SWT_Window0; INSTANCE:17]")
$confFile = @ScriptDir & "\conf.ini"
$left = IniRead($confFile, "coordinate", "left", "0")
$top = IniRead($confFile, "coordinate", "top", "0")
$right = IniRead($confFile, "coordinate", "right", "0")
$buttom = IniRead($confFile, "coordinate", "buttom", "0")

$n = 0
While True
	WinActivate("Flex Profiling", "")
	_ScreenCapture_CaptureWnd (@ScriptDir & "\images\img" & $n & ".jpg", $hGUI, $left, $top, $right, $buttom, False)
	$n += 100
	Sleep(100000)
WEnd