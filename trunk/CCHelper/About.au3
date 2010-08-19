#AutoIt3Wrapper_Icon=".\ico\clearexplorer_app.ico"

#include <GUIConstants.au3>
#include <INet.au3>
#NoTrayIcon

Local $ver = ""
Local $date = ""

If $cmdLine[0] == 1 Then
	$ver = $cmdLine[1]
ElseIf $cmdLine[0] >= 2 Then
	$ver = $cmdLine[1]
	$date = $cmdLine[2]
EndIf

#Region ### START Koda GUI section ### Form=
GUICreate("����CC����", 268, 172)
GUICtrlCreateLabel("�桡������" & $ver, 8, 8)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlCreateLabel("������£�" & $date, 8, 24, 200)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlCreateLabel("CC���֣���CC��CQ�����㣡", 8, 48, 260, 40)
GUICtrlCreateLabel("���ߣ�����145812", 8, 80)
$btn_email = GUICtrlCreateButton("�����ʼ�����", 8, 104, 251, 25, 0)
GUICtrlSetTip(-1, "���� chen.xu8@zte.com.cn")
$btn_close = GUICtrlCreateButton("�ر�(&C)", 8, 136, 251, 25, 0)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $btn_close
			Exit
		Case $btn_email
			_INetMail ( "chen.xu8@zte.com.cn", "About ClearCase/ClearQuest Helper", "" )
			If @error Then
				ClipPut("chen.xu8@zte.com.cn")
				MsgBox(8256, "����CC����", "�޷�ʹ��Ĭ�ϵ��ʼ��ͻ��ˣ������Ͼ���Notes�ˣ������ʼ��������ֱ�ӷ����ʼ��������ַ���� chen.xu8@zte.com.cn")
			EndIf
	EndSwitch
WEnd

