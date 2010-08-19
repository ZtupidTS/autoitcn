#include <GUIConstants.au3>

$gui=GUICreate("test transparentpic", 200, 100)
$pic=GUICreate("", 68, 71, 10, 10,$WS_POPUP,BitOr($WS_EX_LAYERED,$WS_EX_MDICHILD),$gui)
GUICtrlCreatePic(@Systemdir & "\oobe\images\merlin.gif",0,0, 0,0)

GUISetState(@SW_SHOW,$pic)
GUISetState(@SW_SHOW,$gui)

HotKeySet("{ESC}", "main")
HotKeySet("{LEFT}", "left")
HotKeySet("{RIGHT}", "right")
HotKeySet("{DOWN}", "down")
HotKeySet("{UP}", "up")
$picPos = WinGetPos($pic)
$guiPos = WinGetPos($gui)

do
    $msg = GUIGetMsg()
until $msg = $GUI_EVENT_CLOSE
Exit

Func main()
    $guiPos = WinGetPos($gui)
    WinMove($gui,"",$guiPos[0]+10,$guiPos[1]+10)
EndFunc

Func left ()
    $picPos = WinGetPos($pic)
    WinMove($pic,"",$picPos[0]-10,$picPos[1])
EndFunc

Func right()
    $picPos = WinGetPos($pic)
    WinMove($pic,"",$picPos[0]+10,$picPos[1])
EndFunc

Func down()
    $picPos = WinGetPos($pic)
    WinMove($pic,"",$picPos[0],$picPos[1]+10)
EndFunc

Func up()
    $picPos = WinGetPos($pic)
    WinMove($pic,"",$picPos[0],$picPos[1]-10)
EndFunc
