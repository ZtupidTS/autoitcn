#Include <GuiTab.au3>
#NoTrayIcon

Run(@ComSpec & " /c " & 'sysdm.cpl', "", @SW_HIDE)
WinWait("ϵͳ����", "����", 60)
$hWnd = ControlGetHandle("ϵͳ����", "����", 12320)
_GUICtrlTab_SetCurFocus($hWnd, 6)
WinWait("ϵͳ����", "Զ��", 60)
ControlCommand("ϵͳ����", "Զ��", "[Text:�������̨���������Զ��Э������(&R)]", "Check", "")
ControlCommand("ϵͳ����", "Զ��", "[Text:�����û�Զ�����ӵ��˼����(&C)]", "Check", "")
Sleep(200)
ControlSend("ϵͳ����", "Զ��", "[Class:Button; ID:1; Text:ȷ��]", "{ENTER}")
