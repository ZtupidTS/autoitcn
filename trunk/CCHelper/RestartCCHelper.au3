
#NoTrayIcon
#AutoIt3Wrapper_Icon=".\ico\clearexplorer.ico"

Opt("PixelCoordMode", 0)
Opt("MustDeclareVars", 1)

Global $REG_BASE = "HKEY_LOCAL_MACHINE\SOFTWARE\Chenxu\CCHelper"
RegWrite($REG_BASE, "restartCCHelperFlag", "REG_SZ", "true")
If Not ProcessWaitClose("CCHelper.exe", 60) Then
	Exit
EndIf
RegWrite($REG_BASE, "restartCCHelperFlag", "REG_SZ", "false")
Run (@ScriptDir & "\CCHelper.exe", @ScriptDir)
