#NoTrayIcon

Local $ret = RunWait('reg add  "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t REG_DWORD /d 0 /f', @ScriptDir, @SW_HIDE)
MsgBox(64, "打开远程控制", "执行命令结束，返回码是 " & $ret)