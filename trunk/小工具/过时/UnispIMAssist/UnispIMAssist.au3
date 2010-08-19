

init()
Run($upimcfgPath)
WinWaitActive($upimcfgTitle, "", 60)
ControlCommand($upimcfgTitle, "", "[Text:动态调整词使用频率(常用词优先)]", "Check", "")
ControlCommand($upimcfgTitle, "", "[Text:动态调整字使用频率(常用字优先)]", "Check", "")
ControlSend($upimcfgTitle, "", "[Class:TButton; Instance:5]", "{ENTER}")
Global $pid = Run("notepad.exe")
WinWaitActive("无标题 - 记事本")
Sleep(200)
Send("^{space}")
While 1
	Sleep(10)
WEnd

Func init()
	HotKeySet("{END}", "ex")
	
	Global $APP_NAME = "UnispIM Assist"
	Global $CONF_FILE = "conf.ini"
	
	Global $upimcfgTitle = IniRead($CONF_FILE, "unispInfo", "title", "紫光华宇拼音输入法 - 设置")
	Global $upimcfgPath = IniRead($CONF_FILE, "unispInfo", "imInstallPath", "C:\WINDOWS\system32\IME\Unispim") & "\" & _
							IniRead($CONF_FILE, "unispInfo", "upimcfgName", "upimcfg5.exe")
	If Not FileExists($upimcfgPath) Then
		MsgBox(0, $APP_NAME, "紫光的配置程序不存在，请查看配置文件！")
		Exit
	EndIf
EndFunc

Func ex()
	Run($upimcfgPath)
	WinWaitActive($upimcfgTitle, "", 60)
	ControlCommand($upimcfgTitle, "", "[Text:动态调整词使用频率(常用词优先)]", "Uncheck", "")
	ControlCommand($upimcfgTitle, "", "[Text:动态调整字使用频率(常用字优先)]", "Uncheck", "")
	ControlSend($upimcfgTitle, "", "[Class:TButton; Instance:5]", "{ENTER}")
	ProcessClose($pid)
	Exit
EndFunc