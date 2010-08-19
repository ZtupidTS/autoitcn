#AutoIt3Wrapper_Icon=.\images\info2.ico

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
GUICreate("About SciTE Navigator", 268, 172)
GUICtrlCreateLabel("Version: " & $ver, 8, 8)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlCreateLabel("Last Update: " & $date, 8, 24)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlCreateLabel("This is a tool to make SciTE easier to navigate for AutoIt.", 8, 48, 260, 40)
GUICtrlCreateLabel("By chenxu from P.R.C.", 8, 80)
$btn_email = GUICtrlCreateButton("Please feel free to send me an &email.", 8, 104, 251, 25, 0)
GUICtrlSetTip(-1, "email: oicqcx@hotmail.com")
$btn_close = GUICtrlCreateButton("&Close", 8, 136, 251, 25, 0)
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
			_INetMail ( "oicqcx@hotmail.com", "Hi, chenxu, about the SciTE Navigator", "" )
			If @error Then
				ClipPut("oicqcx@hotmail.com")
				MsgBox(8256, "About SciTE Navigator", "Failed to send email with default mail client," & @CRLF & _
							"please send me an email manually. The address is oicqcx@hotmail.com and has been saved to your clipboard.")
			EndIf
	EndSwitch
WEnd

