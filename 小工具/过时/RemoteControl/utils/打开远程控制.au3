#Include <GuiTab.au3>
#NoTrayIcon

Run(@ComSpec & " /c " & 'sysdm.cpl', "", @SW_HIDE)
WinWait("系统属性", "常规", 60)
$hWnd = ControlGetHandle("系统属性", "常规", 12320)
_GUICtrlTab_SetCurFocus($hWnd, 6)
WinWait("系统属性", "远程", 60)
ControlCommand("系统属性", "远程", "[Text:允许从这台计算机发送远程协助邀请(&R)]", "Check", "")
ControlCommand("系统属性", "远程", "[Text:允许用户远程连接到此计算机(&C)]", "Check", "")
Sleep(200)
ControlSend("系统属性", "远程", "[Class:Button; ID:1; Text:确定]", "{ENTER}")
