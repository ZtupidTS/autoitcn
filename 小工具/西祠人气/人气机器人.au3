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
GUICreate("��������������", 840, 630, 0, 0)
$GUIActiveX = GUICtrlCreateObj($oIE, 2, 2, 836, 526)
$txtConsole = GUICtrlCreateEdit('', 2, 528, 836, 98, $ES_MULTILINE & $WS_HSCROLL)
$hEdit = GUICtrlGetHandle($txtConsole)
GUISetState() ;Show GUI

$oDate = _NowCalc()
_ConsoleWrite("�����˿�ʼ����")
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
	_ConsoleWrite("ȡ�����û����� " & IniRead('save_new.ini', $sections[$r], 'name', ''))
	_IEFormElementSetValue($oObject, IniRead('save_new.ini', $sections[$r], 'name', ''))
	$oObject = _IEFormElementGetObjByName($oForm, 'Password')
	_IEFormElementSetValue($oObject, "cx091026")

	; �����޷�ʵ��commit���ύ�������ֻ��ͨ�������Ĳ��ȶ��ķ������ύ���ֱ������굥���ύ��ť
	ControlClick('��������������', '', 'Internet Explorer_Server1', 'left', 1, 78, 104)
	_IELoadWait($oIE, 200, 25000)
	_ConsoleWrite("��½���������")

	$url = 'http://www.xici.net/b1196246/board.asp'
	_ConsoleWrite("��ʼ����������ַ " & $url)
	_IENavigate($oIE, $url, 0)
	_IELoadWait($oIE, 1000, 8000)
	_ConsoleWrite("��鵼�����")

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

Func _faTie();����
	_ConsoleWrite('============================================')
	_ConsoleWrite("���뷢������")

	$oForm = _IEFormGetObjByName($oIE, "DocLists")
	$oObject = _IEFormElementGetObjByName($oForm, 'doc_title')
	$r = Random(1, 1765, True)
	_IEFormElementSetValue($oObject, IniRead('Ц��.ini', 'line_' & $r, 'title', ''))
	$oObject = _IEFormElementGetObjByName($oForm, 'mce_editor_0_Source')
	_IEFormElementSetValue($oObject, IniRead('Ц��.ini', 'line_' & $r, 'line', ''))
	_ConsoleWrite("�����������ݡ��������")

	ControlSend('��������������', '', 'Internet Explorer_Server1', '^{end}')
	Sleep(200)
	ControlClick('��������������', '', 'Internet Explorer_Server1', 'left', 1, 295, 424)
	_ConsoleWrite("����������ť���")

	_IELoadWait($oIE, 200, 5000)
	_ConsoleWrite("�������������")
EndFunc   ;==>_faTie

Func _huiTie() ;����
	_ConsoleWrite('============================================')
	_ConsoleWrite("�����������")
	$oLinks = _IELinkGetCollection($oIE)
	Dim $oTips[1] = [0]
	For $oLink In $oLinks
		If Not StringInStr($oLink.href, 'http://www.xici.net/b1196246/d110') Then ContinueLoop

		$oTips[0] += 1
		ReDim $oTips[$oTips[0] + 1]
		$oTips[$oTips[0]] = $oLink.href
	Next

	$randMax = IniRead('����.ini', 'main', 'total', '10')
	$repeat = 5
	For $i = 1 To $repeat
		_ConsoleWrite('---------------- �������� ' & $i & ' ----------------')
		$url = $oTips[Random(1, $oTips[0], True)]
		_ConsoleWrite("������ " & $url)
		_navigate($url)
;~ 		_IELoadWait($oIE, 200, 10000)
		_ConsoleWrite("������ " & $url & " ��ɣ�")

		$oForm = _IEFormGetObjByName($oIE, "DocLists")
		$oObject = _IEFormElementGetObjByName($oForm, 'mce_editor_0_Source')
		$r = Random(1, $randMax, True)
		$replay = StringReplace(IniRead('����.ini', 'main', 'df_' & $r, '���������ǳ��ã�������'), '\n', @CRLF)
		_IEFormElementSetValue($oObject, $replay)
		_ConsoleWrite("��������[ " & $replay & " ]�������")

		For $j = 1 To 20
			_IEImgClick($oIE, 'http://www.xici.net/_controls/rte/themes/xici/images/plus.gif')
;~ 			_IEImgClick($oIE, '����༭��', 'alt')
			Sleep(10)
		Next
		_ConsoleWrite("���û������ݸ߶����")

		$delay = 23 - (_DateDiff('s', $oDate, _NowCalc()))
		If $delay < 0 Then $delay = 0
		_wait($delay)

		ControlSend('��������������', '', 'Internet Explorer_Server1', '^{end}')
		Sleep(200)
		ControlClick('��������������', '', 'Internet Explorer_Server1', 'left', 1, 295, 424)
		_ConsoleWrite("����������ť���")
		$oDate = _NowCalc()

		_IELoadWait($oIE, 200, 10000)
		_ConsoleWrite("�������")

	Next

	_ConsoleWrite($repeat & " �λ���ȫ�����")
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
	_ConsoleWrite('�ȴ� ' & $delay & ' ��... ', False)
	For $i = 1 To $delay
		_ConsoleWrite($delay - $i, False, False)
		Sleep(1000)
	Next
	_ConsoleWrite()
EndFunc   ;==>_wait

Func _navigate($url)
	_ConsoleWrite('����ǿ�Ƶ���... ', False)
	For $i = 1 To 20000000
		_IENavigate($oIE, $url, 0)
		For $j = 1 To 30
			_ConsoleWrite('��' & $i & '�Σ���ʱ' & (30 - $j), False, False)
			_IELoadWait($oIE, 200, 1000)
			If @error <> $_IEStatus_LoadWaitTimeout Then ExitLoop
		Next
		If @error <> $_IEStatus_LoadWaitTimeout Then ExitLoop
	Next
	_ConsoleWrite()
EndFunc   ;==>_navigate