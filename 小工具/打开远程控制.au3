#NoTrayIcon

Local $ret = RunWait('reg add  "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t REG_DWORD /d 0 /f', @ScriptDir, @SW_HIDE)
MsgBox(64, "��Զ�̿���", "ִ������������������� " & $ret)