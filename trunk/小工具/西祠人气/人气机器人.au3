#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <IE.au3>
#include <GuiEdit.au3>
#include <ScrollBarConstants.au3>
#include <Date.au3>

_IEErrorHandlerRegister()

Dim $oForm, $consoleTxt = '', $idx = 1
Dim $sections = IniReadSectionNames('save_new.ini')

$oIE = _IECreateEmbedded()
GUICreate("西祠人气机器人", 840, 630, 0, 0)
$GUIActiveX = GUICtrlCreateObj($oIE, 2, 2, 836, 526)
$txtConsole = GUICtrlCreateEdit('', 2, 528, 836, 98, $ES_MULTILINE & $WS_HSCROLL)
$hEdit = GUICtrlGetHandle($txtConsole)
GUISetState() ;Show GUI

$oDate = _NowCalc()
_ConsoleWrite("机器人开始运行")
For $i = 1 To 2000
	_go()
Next

While 1
	$msg = GUIGetMsg()
	Select
		Case $msg = $GUI_EVENT_CLOSE
			ExitLoop
	EndSelect
WEnd

Func _go()
	_IENavigate($oIE, "http://www.xici.net", 0)
	_IELoadWait($oIE, 200, 10000)

	$oForm = _IEFormGetObjByName($oIE, "userlogin")
	$oObject = _IEFormElementGetObjByName($oForm, 'UserName')
	$r = Random(1, $sections[0], True)
	_ConsoleWrite("取到的用户名是 " & IniRead('save_new.ini', $sections[$r], 'name', ''))
	_IEFormElementSetValue($oObject, IniRead('save_new.ini', $sections[$r], 'name', ''))
	$oObject = _IEFormElementGetObjByName($oForm, 'Password')
	_IEFormElementSetValue($oObject, "cx091026")

	; 由于无法实用commit来提交表格，所以只能通过这样的不稳定的方法来提交表格：直接用鼠标单击提交按钮
	ControlClick('西祠人气机器人', '', 'Internet Explorer_Server1', 'left', 1, 78, 104)
	_IELoadWait($oIE, 200, 25000)
	_ConsoleWrite("登陆流程已完成")

	$url = 'http://www.xici.net/b1196246/board.asp'
	_ConsoleWrite("开始导航到版块地址 " & $url)
	_IENavigate($oIE, $url, 0)
	_IELoadWait($oIE, 1000, 8000)
	_ConsoleWrite("板块导航完毕")

;~ 	For $i = 1 To 10
;~ 		_faTie()
;~ 		Sleep(25000)
;~ 	Next

;~ 	_faTie()
;~ 	_wait(20)
	_huiTie()

	_IENavigate($oIE, 'http://www.xici.net/user/logout.asp', 0)
	_IELoadWait($oIE, 200, 10000)
EndFunc   ;==>_go

Func _faTie();发帖
	_ConsoleWrite('============================================')
	_ConsoleWrite("进入发帖流程")

	$oForm = _IEFormGetObjByName($oIE, "DocLists")
	$oObject = _IEFormElementGetObjByName($oForm, 'doc_title')
	$r = Random(1, 1765, True)
	_IEFormElementSetValue($oObject, IniRead('笑话.ini', 'line_' & $r, 'title', ''))
	$oObject = _IEFormElementGetObjByName($oForm, 'mce_editor_0_Source')
	_IEFormElementSetValue($oObject, IniRead('笑话.ini', 'line_' & $r, 'line', ''))
	_ConsoleWrite("设置帖子内容、标题完成")

	ControlSend('西祠人气机器人', '', 'Internet Explorer_Server1', '^{end}')
	Sleep(200)
	ControlClick('西祠人气机器人', '', 'Internet Explorer_Server1', 'left', 1, 295, 424)
	_ConsoleWrite("单击发帖按钮完成")

	_IELoadWait($oIE, 200, 5000)
	_ConsoleWrite("发帖流程已完成")
EndFunc   ;==>_faTie

Func _huiTie() ;回帖
	_ConsoleWrite('============================================')
	_ConsoleWrite("进入回帖流程")
	$oLinks = _IELinkGetCollection($oIE)
	Dim $oTips[1] = [0]
	For $oLink In $oLinks
		If Not StringInStr($oLink.href, 'http://www.xici.net/b1196246/d110') Then ContinueLoop

		$oTips[0] += 1
		ReDim $oTips[$oTips[0] + 1]
		$oTips[$oTips[0]] = $oLink.href
	Next

	$randMax = IniRead('回帖.ini', 'main', 'total', '10')
	$repeat = 5
	For $i = 1 To $repeat
		_ConsoleWrite('---------------- 回帖次数 ' & $i & ' ----------------')
		$url = $oTips[Random(1, $oTips[0], True)]
		_ConsoleWrite("导航到 " & $url)
		_navigate($url)
;~ 		_IELoadWait($oIE, 200, 10000)
		_ConsoleWrite("导航到 " & $url & " 完成！")

		$oForm = _IEFormGetObjByName($oIE, "DocLists")
		$oObject = _IEFormElementGetObjByName($oForm, 'mce_editor_0_Source')
		$r = Random(1, $randMax, True)
		$replay = StringReplace(IniRead('回帖.ini', 'main', 'df_' & $r, '顶起来，非常好！！！！'), '\n', @CRLF)
		_IEFormElementSetValue($oObject, $replay)
		_ConsoleWrite("回帖内容[ " & $replay & " ]设置完成")

		For $j = 1 To 20
			_IEImgClick($oIE, 'http://www.xici.net/_controls/rte/themes/xici/images/plus.gif')
;~ 			_IEImgClick($oIE, '增大编辑区', 'alt')
			Sleep(10)
		Next
		_ConsoleWrite("设置回帖内容高度完成")

		$delay = 23 - (_DateDiff('s', $oDate, _NowCalc()))
		If $delay < 0 Then $delay = 0
		_wait($delay)

		ControlSend('西祠人气机器人', '', 'Internet Explorer_Server1', '^{end}')
		Sleep(200)
		ControlClick('西祠人气机器人', '', 'Internet Explorer_Server1', 'left', 1, 295, 424)
		_ConsoleWrite("单击回帖按钮完成")
		$oDate = _NowCalc()

		_IELoadWait($oIE, 200, 10000)
		_ConsoleWrite("回帖完成")

	Next

	_ConsoleWrite($repeat & " 次回帖全部完成")
EndFunc   ;==>_huiTie

Func _ConsoleWrite($txt = '____empty____', $newLine = True, $append = True)
	If $txt == '____empty____' Then
		$consoleTxt &= @CRLF
	Else
		If $append Then
			$consoleTxt &= $idx & '. ' & _DateDiff('s', "1970/01/01 00:00:00", _NowCalc()) & ' ' & $txt
			If $newLine Then
				$consoleTxt &= @CRLF
				$idx += 1
			EndIf
			GUICtrlSetData($txtConsole, $consoleTxt)
		Else
			GUICtrlSetData($txtConsole, $consoleTxt & $txt)
		EndIf
	EndIf

	$iLen = _GUICtrlEdit_GetTextLen($hEdit)
	_GUICtrlEdit_SetSel($hEdit, $iLen, $iLen)
	_GUICtrlEdit_Scroll($hEdit, $SB_SCROLLCARET)
EndFunc   ;==>_ConsoleWrite

Func _wait($delay)
	_ConsoleWrite('等待 ' & $delay & ' 秒... ', False)
	For $i = 1 To $delay
		_ConsoleWrite($delay - $i, False, False)
		Sleep(1000)
	Next
	_ConsoleWrite()
EndFunc   ;==>_wait

Func _navigate($url)
	_ConsoleWrite('进入强制导航... ', False)
	For $i = 1 To 20000000
		_IENavigate($oIE, $url, 0)
		For $j = 1 To 30
			_ConsoleWrite('第' & $i & '次，超时' & (30 - $j), False, False)
			_IELoadWait($oIE, 200, 1000)
			If @error <> $_IEStatus_LoadWaitTimeout Then ExitLoop
		Next
		If @error <> $_IEStatus_LoadWaitTimeout Then ExitLoop
	Next
	_ConsoleWrite()
EndFunc   ;==>_navigate