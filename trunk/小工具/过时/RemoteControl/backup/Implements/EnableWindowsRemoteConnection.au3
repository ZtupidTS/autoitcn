;~ Run((@ComSpec & " /c " & "sysdm.cpl")
;Sleep(10000)

Run(@ComSpec & " /c " & 'sysdm.cpl', "", @SW_HIDE)
;~ Run("c:\windows\system32\sysdm.cpl", "", @SW_HIDE)
WinWait("系统属性", "常规", 60)
ControlCommand("系统属性", "常规", "[CLASS:SysTabControl32; INSTANCE:1; ID:12320]", "TabRight", "")
WinWait("系统属性", "计算机名", 60)
ControlCommand("系统属性", "计算机名", "[CLASS:SysTabControl32; INSTANCE:1; ID:12320]", "TabRight", "")
WinWait("系统属性", "硬件", 60)
ControlCommand("系统属性", "硬件", "[CLASS:SysTabControl32; INSTANCE:1; ID:12320]", "TabRight", "")
WinWait("系统属性", "高级", 60)
ControlCommand("系统属性", "高级", "[CLASS:SysTabControl32; INSTANCE:1; ID:12320]", "TabRight", "")
WinWait("系统属性", "系统还原", 60)
ControlCommand("系统属性", "系统还原", "[CLASS:SysTabControl32; INSTANCE:1; ID:12320]", "TabRight", "")
WinWait("系统属性", "自动更新", 60)
ControlCommand("系统属性", "自动更新", "[CLASS:SysTabControl32; INSTANCE:1; ID:12320]", "TabRight", "")
WinWait("系统属性", "远程", 60)
ControlCommand("系统属性", "远程", "[CLASS:SysTabControl32; INSTANCE:1; ID:12320]", "TabRight", "")

WinWait("系统属性", "远程", 60)
ControlCommand("系统属性", "远程", "[Text:允许从这台计算机发送远程协助邀请(&R)]", "Check", "")
ControlCommand("系统属性", "远程", "[Text:允许用户远程连接到此计算机(&C)]", "Check", "")

Sleep(200)
ControlSend("系统属性", "远程", "[Class:Button; ID:1; Text:确定]", "{ENTER}")

