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
GUICreate("关于CC助手", 268, 172)
GUICtrlCreateLabel("版　　本：" & $ver, 8, 8)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlCreateLabel("最近更新：" & $date, 8, 24, 200)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlCreateLabel("CC助手，让CC和CQ更方便！", 8, 48, 260, 40)
GUICtrlCreateLabel("作者：陈旭145812", 8, 80)
$btn_email = GUICtrlCreateButton("发个邮件给我", 8, 104, 251, 25, 0)
GUICtrlSetTip(-1, "邮箱 chen.xu8@zte.com.cn")
$btn_close = GUICtrlCreateButton("关闭(&C)", 8, 136, 251, 25, 0)
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
				MsgBox(8256, "关于CC助手", "无法使用默认的邮件客户端（基本上就是Notes了）发送邮件，你可以直接发送邮件到这个地址给我 chen.xu8@zte.com.cn")
			EndIf
	EndSwitch
WEnd

