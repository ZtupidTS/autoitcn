Opt("MustDeclareVars", 1)

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#NoTrayIcon
#AutoIt3Wrapper_Icon = maintain.ico

#Region ### START Koda GUI section ### Form=
Local $Form1 = GUICreate("mml.properties ������", 412, 130)
GUICtrlCreateLabel("�����߿��Ը��� comm-mmlfile-list.xml �������Զ���������� mml.properties �ļ������ݡ�" & _
		"������ comm-mmlfile-list.xml ��·������������ɡ���ť����������� mml.properties �ļ������ݣ�" & _
		"�����������ı��༭���󣬱����һ�� mml.propertes �ļ����ɡ�V1.3" & @CRLF & @CRLF & @CRLF & _
		"������ comm-mmlfile-list.xml ����·��", 8, 8, 399, 90)
Local $Input1 = GUICtrlCreateInput("c:\comm-mmlfile-list.xml", 8, 98, 280, 21)
Local $Button1 = GUICtrlCreateButton("��", 294, 97, 55, 25, 0)
Local $Button2 = GUICtrlCreateButton("����", 354, 97, 55, 25, 0)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	Local $nMsg = GUIGetMsg()
	Switch $nMsg
		Case $Button1
			Local $file = FileOpenDialog('ѡ���ļ�', '', 'XML files (*.xml)', 1, 'comm-mmlfile-list.xml', $Form1)
			If $file <> '' Then
				GUICtrlSetData($Input1, $file)
			EndIf
		Case $Button2
			_generate(GUICtrlRead($Input1))
		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch
WEnd

Func _generate($file)
	Local $xml = ObjCreate("Microsoft.XMLDOM")
	If Not IsObj($xml) Then
		MsgBox(16, 'mml.properties ������', "�޷�����xml����", Default, $Form1)
		Return
	EndIf

	If Not FileExists($file) Then
		MsgBox(64, 'mml.properties ������', '�ļ�������', Default, $Form1)
		Return
	EndIf

	$xml.Async = "false"
	$xml.Load($file)

	Local $items = $xml.SelectNodes('/filelist/ne/module')
	Local $result = ''
	Local $item, $type, $baseDir, $value
	For $item In $items
		$type = $item.GetAttribute("type")
		If $type == 'fake' Then ContinueLoop
		$baseDir = $item.GetAttribute("basedir")

		$value = _getUrl($item, 'cmdinfo')
		If $value <> '0' Then
			$result &= $type & '.cmdinfo = Embed("../../' & $baseDir & $value & '", mimeType="application/octet-stream")' & @CRLF
			$value = StringReplace($value, '.', '-i18n.')
			$result &= $type & '.cmdinfo.i18n = Embed("../../' & $baseDir & $value & '", mimeType="application/octet-stream")' & @CRLF
		EndIf

		$value = _getUrl($item, 'enuminfo')
		If $value <> '0' Then
			$result &= $type & '.enuminfo = Embed("../../' & $baseDir & $value & '", mimeType="application/octet-stream")' & @CRLF
			$value = StringReplace($value, '.', '-i18n.')
			$result &= $type & '.enuminfo.i18n = Embed("../../' & $baseDir & $value & '", mimeType="application/octet-stream")' & @CRLF
		EndIf

		$value = _getUrl($item, 'errorinfo')
		If $value <> '0' Then
			$result &= $type & '.errorinfo = Embed("../../' & $baseDir & $value & '", mimeType="application/octet-stream")' & @CRLF
			$value = StringReplace($value, '.', '-i18n.')
			$result &= $type & '.errorinfo.i18n = Embed("../../' & $baseDir & $value & '", mimeType="application/octet-stream")' & @CRLF
		EndIf

		$value = _getUrl($item, 'cmdtreeinfo')
		If $value <> '0' Then
			$result &= $type & '.cmdtreeinfo = Embed("../../' & $baseDir & $value & '", mimeType="application/octet-stream")' & @CRLF
			$value = StringReplace($value, 'cmd-tree', 'cmdtree-i18n')
			$result &= $type & '.cmdtreeinfo.i18n = Embed("../../' & $baseDir & $value & '", mimeType="application/octet-stream")' & @CRLF
		EndIf

		$result &= @CRLF
	Next

	$result &= '######################################### COMM����ű���Ӧ������Ķ� #########################################' & @CRLF & _
			'comm-i18n = Embed("comm-mml-api-i18n.xml", mimeType="application/octet-stream")' & @CRLF & @CRLF; & _
;~ 			'cn-comm-lmt.cmdinfo = Embed("../../../mml/clis/cn-comm-lmt/cn-comm-lmt-mml-cmdinfo.xml", mimeType="application/octet-stream")' & @CRLF & _
;~ 			'cn-comm-lmt.cmdinfo.i18n = Embed("../../../mml/clis/cn-comm-lmt/cn-comm-lmt-mml-cmdinfo-i18n.xml", mimeType="application/octet-stream")' & @CRLF & _
;~ 			'cn-comm-lmt.enuminfo = Embed("../../../mml/clis/cn-comm-lmt/cn-comm-lmt-mml-enum.xml", mimeType="application/octet-stream")' & @CRLF & _
;~ 			'cn-comm-lmt.enuminfo.i18n = Embed("../../../mml/clis/cn-comm-lmt/cn-comm-lmt-mml-enum-i18n.xml", mimeType="application/octet-stream")' & @CRLF & _
;~ 			'cn-comm-lmt.errorinfo = Embed("../../../mml/clis/cn-comm-lmt/cn-comm-lmt-mml-error-info.xml", mimeType="application/octet-stream")' & @CRLF & _
;~ 			'cn-comm-lmt.errorinfo.i18n = Embed("../../../mml/clis/cn-comm-lmt/cn-comm-lmt-mml-error-info-i18n.xml", mimeType="application/octet-stream")' & @CRLF & _
;~ 			'cn-comm-lmt.cmdtreeinfo = Embed("../../../mml/clis/cn-comm-lmt/cn-comm-lmt-mml-cmd-tree.xml", mimeType="application/octet-stream")' & @CRLF & _
;~ 			'cn-comm-lmt.cmdtreeinfo.i18n = Embed("../../../mml/clis/cn-comm-lmt/cn-comm-lmt-mml-cmdtree-i18n.xml", mimeType="application/octet-stream")'
	FileDelete(@ScriptDir & '\ResourceMakerResult.txt')
	FileWrite(@ScriptDir & '\ResourceMakerResult.txt', $result)
	Run('notepad.exe "' & @ScriptDir & '\ResourceMakerResult.txt"')
EndFunc   ;==>_generate

Func _getUrl($item, $nodeName)
	Local $subItems, $subItem
	$subItems = $item.SelectNodes($nodeName)
	For $subItem In $subItems
		Return $subItem.GetAttribute("url")
	Next
EndFunc   ;==>_getUrl