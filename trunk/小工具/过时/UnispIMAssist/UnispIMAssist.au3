

init()
Run($upimcfgPath)
WinWaitActive($upimcfgTitle, "", 60)
ControlCommand($upimcfgTitle, "", "[Text:��̬������ʹ��Ƶ��(���ô�����)]", "Check", "")
ControlCommand($upimcfgTitle, "", "[Text:��̬������ʹ��Ƶ��(����������)]", "Check", "")
ControlSend($upimcfgTitle, "", "[Class:TButton; Instance:5]", "{ENTER}")
Global $pid = Run("notepad.exe")
WinWaitActive("�ޱ��� - ���±�")
Sleep(200)
Send("^{space}")
While 1
	Sleep(10)
WEnd

Func init()
	HotKeySet("{END}", "ex")
	
	Global $APP_NAME = "UnispIM Assist"
	Global $CONF_FILE = "conf.ini"
	
	Global $upimcfgTitle = IniRead($CONF_FILE, "unispInfo", "title", "�Ϲ⻪��ƴ�����뷨 - ����")
	Global $upimcfgPath = IniRead($CONF_FILE, "unispInfo", "imInstallPath", "C:\WINDOWS\system32\IME\Unispim") & "\" & _
							IniRead($CONF_FILE, "unispInfo", "upimcfgName", "upimcfg5.exe")
	If Not FileExists($upimcfgPath) Then
		MsgBox(0, $APP_NAME, "�Ϲ�����ó��򲻴��ڣ���鿴�����ļ���")
		Exit
	EndIf
EndFunc

Func ex()
	Run($upimcfgPath)
	WinWaitActive($upimcfgTitle, "", 60)
	ControlCommand($upimcfgTitle, "", "[Text:��̬������ʹ��Ƶ��(���ô�����)]", "Uncheck", "")
	ControlCommand($upimcfgTitle, "", "[Text:��̬������ʹ��Ƶ��(����������)]", "Uncheck", "")
	ControlSend($upimcfgTitle, "", "[Class:TButton; Instance:5]", "{ENTER}")
	ProcessClose($pid)
	Exit
EndFunc