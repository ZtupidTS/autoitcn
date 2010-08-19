#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <IE.au3>

_IEErrorHandlerRegister()

Dim $oForm, $idx, $mailId = 0

$oIE = _IECreateEmbedded()
GUICreate("Embedded Web control Test", 840, 630, 0, 0)
$GUIActiveX = GUICtrlCreateObj($oIE, 10, 40, 820, 570)
$btnGo = GUICtrlCreateButton("Go", 10, 5, 100, 30)
$btnCheck = GUICtrlCreateButton("Check", 110, 5, 100, 30)
$btnLogin = GUICtrlCreateButton("Login", 210, 5, 100, 30)
$btnLoginAll = GUICtrlCreateButton("Login All", 310, 5, 100, 30)
$btnLoginXici = GUICtrlCreateButton("Login xici", 410, 5, 100, 30)
GUISetState() ;Show GUI


; Waiting for user to close the window
While 1
	$msg = GUIGetMsg()
	Select
		Case $msg = $GUI_EVENT_CLOSE
			ExitLoop
		Case $msg = $btnGo
			_go()
		Case $msg = $btnCheck
			_check()
		Case $msg = $btnLogin
			_login()
		Case $msg = $btnLoginAll
			_loginAll()
		Case $msg = $btnLoginXici
			_loginXici()
	EndSelect
WEnd

GUIDelete()
Exit

Func _go()
	For $i = 94 To 100
		_IENavigate($oIE, "http://bjcgi.tom.com/cgi-bin/tom_reg.cgi?rf=060704")
		$oForm = _IEFormGetObjByName($oIE, "myform1")
		$oObject = _IEFormElementGetObjByName($oForm, 'uid')
		_IEFormElementSetValue($oObject, "oicqcx" & $i)

		$oObject = _IEFormElementGetObjByName($oForm, 'password')
		_IEFormElementSetValue($oObject, "5788312")

		$oObject = _IEFormElementGetObjByName($oForm, 'confirm_password')
		_IEFormElementSetValue($oObject, "5788312")

		$oObject = _IEFormElementGetObjByName($oForm, 'authcode')
		_IEFormElementSetValue($oObject, InputBox('输入验证码', '输入验证码', '', '', Default, Default, 200, 200))

		$oObject = _IEFormElementGetObjByName($oForm, 'answer')
		_IEFormElementSetValue($oObject, "这些是马甲")

		Sleep(500)
		_IEFormSubmit($oForm, 0)
		Sleep(1500)
		ConsoleWrite($i & @CRLF)
	Next
EndFunc   ;==>_go

Func _check()
	_IENavigate($oIE, "http://bjcgi.tom.com/cgi-bin/tom_reg.cgi?rf=060704")
	$oForm = _IEFormGetObjByName($oIE, "myform1")

	$oObject = _IEFormElementGetObjByName($oForm, 'password')
	_IEFormElementSetValue($oObject, "5788312")

	$oObject = _IEFormElementGetObjByName($oForm, 'confirm_password')
	_IEFormElementSetValue($oObject, "5788312")

	$oObject = _IEFormElementGetObjByName($oForm, 'answer')
	_IEFormElementSetValue($oObject, "这些是马甲")

	HotKeySet('{space}', '_checkDo')
	$idx = 86
EndFunc   ;==>_check

Func _checkDo()
	$oObject = _IEFormElementGetObjByName($oForm, 'uid')
	_IEFormElementSetValue($oObject, "oicqcx" & $idx)
	$idx += 1
EndFunc   ;==>_checkDo

Func _login()
	_IENavigate($oIE, "http://mail.tom.com/")
	$oForm = _IEFormGetObjByName($oIE, "loginfrm")

	$oObject = _IEFormElementGetObjByName($oForm, 'user')
	If $mailId == 0 Then
		$mailId = InputBox('', '输入登陆用户名后缀：oicqcx', $mailId + 1, '', Default, Default, 500, 150)
	Else
		$mailId = $mailId + 1
	EndIf
	_IEFormElementSetValue($oObject, 'oicqcx' & $mailId)

	$oObject = _IEFormElementGetObjByName($oForm, 'pass')
	_IEFormElementSetValue($oObject, "5788312")

	_IEFormSubmit($oForm, 0)
EndFunc   ;==>_login

Func _loginAll()
	For $i = 1 To 100
		_IENavigate($oIE, "http://mail.tom.com/")
		$oForm = _IEFormGetObjByName($oIE, "loginfrm")

		$oObject = _IEFormElementGetObjByName($oForm, 'user')
		_IEFormElementSetValue($oObject, 'oicqcx' & $i)

		$oObject = _IEFormElementGetObjByName($oForm, 'pass')
		_IEFormElementSetValue($oObject, "5788312")

		_IEFormSubmit($oForm, 0)
		_IELoadWait($oIE, 0, 5000)
	Next
EndFunc   ;==>_loginAll

Func _loginXici()
	$idArray = IniReadSectionNames('save_new.ini')

	For $i = 75 To $idArray[0]
		_IENavigate($oIE, "http://www.xici.net", 0)
		_IELoadWait($oIE, 200, 10000)

		$oForm = _IEFormGetObjByName($oIE, "userlogin")
		$oObject = _IEFormElementGetObjByName($oForm, 'UserName')
		_IEFormElementSetValue($oObject, IniRead('save_new.ini', $idArray[$i], 'name', ''))
		$oObject = _IEFormElementGetObjByName($oForm, 'Password')
		_IEFormElementSetValue($oObject, IniRead('save_new.ini', $idArray[$i], 'pwd', ''))

		; 由于无法实用commit来提交表格，所以只能通过这样的不稳定的方法来提交表格：直接用鼠标单击提交按钮
		ControlClick('Embedded Web control Test', '', 'Internet Explorer_Server1', 'left', 1, 78, 104)
		_IELoadWait($oIE, 200, 5000)
		$iMsgBoxAnswer = MsgBox(4, "西祠", "用户名、密码正确吗？当前id是 " & $i)
		Select
			Case $iMsgBoxAnswer = 6 ;Yes
				_IENavigate($oIE, 'http://www.xici.net/b1196246/board.asp', 0)
				_IELoadWait($oIE, 1000, 8000)
				MsgBox(0, '', '关闭以继续，当前id是 ' & $i & '，用户名是 ' & IniRead('save_new.ini', $idArray[$i], 'name', ''))
				_IENavigate($oIE, 'http://www.xici.net/user/logout.asp', 0)
				_IELoadWait($oIE, 200, 1000)
			Case $iMsgBoxAnswer = 7 ;No
				ConsoleWrite($i & @CRLF)
		EndSelect

	Next
EndFunc   ;==>_loginXici
