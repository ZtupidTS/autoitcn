#include <GuiListBox.au3>
#include <Array.au3>
#include <Constants.au3>
#NoTrayIcon
#AutoIt3Wrapper_Icon=maintain.ico

Opt('MustDeclareVars', 1)

Global $CONF_FILE = @ScriptDir & '\config.ini'

Global $Form1 = GUICreate("��������Դ������", 621, 460)

GUICtrlCreateLabel("MML·��", 8, 12, 52, 17)
GUICtrlSetTip(-1, '�ṩ����˻�����ű�����Ŀ¼�����°���������Ŀ¼�е�������Ч�Ľű������Ա��ѵ�')
Global $txtMML = GUICtrlCreateInput(IniRead($CONF_FILE, 'main', 'mmlPath', @DesktopCommonDir), 64, 8, 513, 21)
GUICtrlSetTip(-1, '�ṩ����˻�����ű�����Ŀ¼�����°���������Ŀ¼�е�������Ч�Ľű������Ա��ѵ�')
Global $btnBrowseMML = GUICtrlCreateButton("...", 582, 7, 30, 23, 0)
GUICtrlSetTip(-1, '�ṩ����˻�����ű�����Ŀ¼�����°���������Ŀ¼�е�������Ч�Ľű������Ա��ѵ�')

GUICtrlCreateLabel("���·��", 8, 36)
GUICtrlSetTip(-1, 'ָ��һ��Ŀ¼���ڴ�����ɵ�mml_resource.swf�ļ�������԰�Ŀ���ļ���ָ������Ҫ���ɵ��ļ��У������Ͳ���ÿ�����ɺ��ٿ���һ����')
Global $txtOutput = GUICtrlCreateInput(IniRead($CONF_FILE, 'main', 'outputPath', @DesktopCommonDir), 64, 32, 513, 21)
GUICtrlSetTip(-1, 'ָ��һ��Ŀ¼���ڴ�����ɵ�mml_resource.swf�ļ�������԰�Ŀ���ļ���ָ������Ҫ���ɵ��ļ��У������Ͳ���ÿ�����ɺ��ٿ���һ����')
Global $btnBrowseOutput = GUICtrlCreateButton("...", 582, 31, 30, 23, 0)
GUICtrlSetTip(-1, 'ָ��һ��Ŀ¼���ڴ�����ɵ�mml_resource.swf�ļ�������԰�Ŀ���ļ���ָ������Ҫ���ɵ��ļ��У������Ͳ���ÿ�����ɺ��ٿ���һ����')

GUICtrlCreateLabel("SDK·��", 8, 60, 50, 17)
GUICtrlSetTip(-1, '����ļ�ͨ�����������SVN�ϵ����Ŀ¼���ң���������������ť���Ի�ø������Ϣ��' & @CRLF & _
		'<BaseDir>\client\tools\sdk\bin\mxmlc.exe')
Global $txtSDK = GUICtrlCreateInput(IniRead($CONF_FILE, 'main', 'sdkPath', @DesktopCommonDir & '\mxmlc.exe'), 64, 56, 513, 21)
GUICtrlSetTip(-1, '����ļ�ͨ�����������SVN�ϵ����Ŀ¼���ҵ�����������������ť���Ի�ø������Ϣ' & @CRLF & _
		'<BaseDir>\client\tools\sdk\bin\mxmlc.exe')
Global $btnBrowseSDK = GUICtrlCreateButton("...", 582, 55, 30, 23, 0)
GUICtrlSetTip(-1, '����ļ�ͨ�����������SVN�ϵ����Ŀ¼���ҵ�����������������ť���Ի�ø������Ϣ' & @CRLF & _
		'<BaseDir>\client\tools\sdk\bin\mxmlc.exe')

GUICtrlCreateLabel("comm-mml-api-i18n.xml·��", 8, 84)
GUICtrlSetTip(-1, '����ļ�ͨ�����������SVN�ϵ����Ŀ¼���ҵ�����������������ť���Ի�ø������Ϣ' & @CRLF & _
		'<BaseDir>\client\template\client\pub\mml\comm-mml-api-i18n.xml')
Global $txtI18n = GUICtrlCreateInput(IniRead($CONF_FILE, 'main', 'i18nPath', @DesktopCommonDir & '\comm-mml-api-i18n.xml'), 165, 80, 412, 21)
GUICtrlSetTip(-1, '����ļ�ͨ�����������SVN�ϵ����Ŀ¼���ҵ�����������������ť���Ի�ø������Ϣ' & @CRLF & _
		'<BaseDir>\client\template\client\pub\mml\comm-mml-api-i18n.xml')
Global $btnBrowseI18n = GUICtrlCreateButton("...", 582, 79, 30, 23, 0)
GUICtrlSetTip(-1, '����ļ�ͨ�����������SVN�ϵ����Ŀ¼���ҵ�����������������ť���Ի�ø������Ϣ' & @CRLF & _
		'<BaseDir>\client\template\client\pub\mml\comm-mml-api-i18n.xml')

Global $btnSearch = GUICtrlCreateButton("ɨ��ű�", 8, 106, 75, 25, 0)
Global $btnGenerate = GUICtrlCreateButton("����SWF��Դ", 88, 106, 85, 25, 0)
Global $btnMakeProperties = GUICtrlCreateButton("����mml.properties", 178, 106, 125, 25, 0)
Global $btnDelete = GUICtrlCreateButton("ɾ��ѡ����", 308, 106, 85, 25, 0)
Global $btnHelp = GUICtrlCreateButton("����", 497, 106, 55, 25, 0)
Global $btnExit = GUICtrlCreateButton("�˳�", 557, 106, 55, 25, 0)
Global $list = GUICtrlCreateList('', 8, 134, 605, 321)
GUISetState(@SW_SHOW)

Local $path
While 1
	Local $nMsg = GUIGetMsg()
	Switch $nMsg
		Case $btnSearch
			_updateList()

		Case $btnGenerate
			_makeResource()

		Case $btnBrowseMML
			$path = FileSelectFolder('���˻�����ű�����Ŀ¼', '', 4, GUICtrlRead($txtMML), $Form1)
			If $path == '' Then ContinueLoop
			If Not FileExists($path) Then
				MsgBox(16, '��������Դ������', '��Ч���˻�����ű�Ŀ¼��', Default, $Form1)
				ContinueLoop
			EndIf
			IniWrite($CONF_FILE, 'main', 'mmlPath', $path)
			GUICtrlSetData($txtMML, $path)

		Case $btnBrowseOutput
			$path = FileSelectFolder('ѡ���˻�������Դ���Ŀ¼', '', 4, GUICtrlRead($txtOutput), $Form1)
			If $path == '' Then ContinueLoop
			If Not FileExists($path) Then
				MsgBox(16, '��������Դ������', '��Ч���˻�������Դ���Ŀ¼��', Default, $Form1)
				ContinueLoop
			EndIf
			IniWrite($CONF_FILE, 'main', 'outputPath', $path)
			GUICtrlSetData($txtOutput, $path)

		Case $btnBrowseSDK
			$path = FileOpenDialog('��SDK������', GUICtrlRead($txtSDK), 'Flex ������� (mxmlc.exe)', 1, 'mxmlc.exe', $Form1)
			If $path == '' Then ContinueLoop
			If Not FileExists($path) Then
				MsgBox(16, '��������Դ������', 'mxmlc.exe�ļ������ڣ�', Default, $Form1)
				ContinueLoop
			EndIf
			IniWrite($CONF_FILE, 'main', 'sdkPath', $path)
			GUICtrlSetData($txtSDK, $path)

		Case $btnBrowseI18n
			$path = FileOpenDialog('��comm-mml-api-i18n.xml', GUICtrlRead($txtI18n), _
					'comm-mml-api-i18n.xml (comm-mml-api-i18n.xml)', 1, 'comm-mml-api-i18n.xml', $Form1)
			If $path == '' Then ContinueLoop
			If Not FileExists($path) Then
				MsgBox(16, '��������Դ������', 'comm-mml-api-i18n.xml�ļ������ڣ�', Default, $Form1)
				ContinueLoop
			EndIf
			IniWrite($CONF_FILE, 'main', 'i18nPath', $path)
			GUICtrlSetData($txtI18n, $path)

		Case $btnDelete
			_deleteSelected()

		Case $btnMakeProperties
			If FileExists(@ScriptDir & '\Tools\' & 'mml.properties ������.exe') Then
				Run('"' & @ScriptDir & '\Tools\' & 'mml.properties ������.exe"')
			Else
				MsgBox(16, '��������Դ������', '��Ǹ���Ҳ�������ļ� mml.properties ������.exe', Default, $Form1)
			EndIf

		Case $btnHelp
			MsgBox(64, '������������Դ������', '�汾��V1.3' & @CRLF & '���ߣ�����145812' & @CRLF & @CRLF & _
					'SDK ���Դ�svn������ط���ã���Ҫ��������SDKĿ¼��' & @CRLF & _
					'http://10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/client/tools/sdk' & @CRLF & @CRLF & _
					'comm-mml-api-i18n.xml ���Դ�svn������ط����' & @CRLF & _
					'http://10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/client/template/client/pub/mml/comm-mml-api-i18n.xml', _
					Default, $Form1)

		Case $btnExit
			Exit
		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch
WEnd

Func _updateList()
	Local $dir = GUICtrlRead($txtMML)
	If Not FileExists($dir) Then
		MsgBox(16, '��������Դ������', '��Ч���˻�����ű�Ŀ¼��', Default, $Form1)
		Return
	EndIf
	_GUICtrlListBox_ResetContent($list)
	If StringRight($dir, 1) == '\' Then
		$dir = StringLeft($dir, StringLen($dir) - 1)
	EndIf

	_disableAll()

	Local $fileSet[1]
	_search($fileSet, $dir)

	Local $i, $file
	$dir = $dir & '\'
	For $i = 1 To $fileSet[0]
		$file = StringReplace($fileSet[$i], $dir, '', Default, 0)
		If _getSuffix($file) == '' Then ContinueLoop

		_GUICtrlListBox_AddString($list, StringReplace($fileSet[$i], $dir, '', Default, 0))
	Next

	_saveArguments()
	_enableAll()
EndFunc   ;==>_updateList

Func _makeResource()
	If Not _checkArguments() Then Return
	_disableAll()

	Local $count = _GUICtrlListBox_GetCount($list) - 1
	Local $i, $file, $suffix, $dir = GUICtrlRead($txtMML), $properties = ''
	If StringRight($dir, 1) == '\' Then $dir = StringLeft($dir, StringLen($dir) - 1)
	For $i = 0 To $count
		$file = _GUICtrlListBox_GetText($list, $i)
		$suffix = _getSuffix($file)
		$properties &= _getPropertyName($file) & ' = Embed("' & $dir & '\' & $file & '", mimeType="application/octet-stream")' & @CRLF
	Next
	$properties &= 'comm-i18n = Embed("' & GUICtrlRead($txtI18n) & '", mimeType="application/octet-stream")'
	$properties = StringReplace($properties, '\', '/')
	If FileExists(@ScriptDir & '\mml.properties') Then FileDelete(@ScriptDir & '\mml.properties')
	FileWrite(@ScriptDir & '\mml.properties', $properties)

	Local $outputDir = GUICtrlRead($txtOutput)
	If StringRight($outputDir, 1) == '\' Then $outputDir = StringLeft($outputDir, StringLen($outputDir) - 1)
	;��ʼ����sdk������Դ
	Local $process = Run('"' & GUICtrlRead($txtSDK) & '"  -locale=zh_CN -source-path=. -include-resource-bundles=mml,collections,containers,controls,core,effects,skins,styles -output "' & _
			$outputDir & '\mml_resource.swf"', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

	Local $stdOut = ''
	While 1
		$stdOut &= StdoutRead($process)
		If @error Then ExitLoop
	WEnd
	Local $errOut = ''
	While 1
		$errOut &= StderrRead($process)
		If @error Then ExitLoop
	WEnd

	If $errOut <> '' Then
		MsgBox(16, "��Դ���������", $errOut, Default, $Form1)
	Else
		MsgBox(64, "��Դ����ɹ�", '���ɵ��ļ�������' & @CRLF & $outputDir & '\mml_resource.swf', Default, $Form1)
	EndIf

	_enableAll()
EndFunc   ;==>_makeResource

Func _search(ByRef $fileSet, $dir)
	Local $sch = FileFindFirstFile($dir & "\*.*")
	If $sch = -1 Then
		Return
	EndIf

	Local $file
	While 1
		$file = FileFindNextFile($sch)
		If @error Then ExitLoop

		$file = StringLower($file)
		If StringInStr(FileGetAttrib($dir & "\" & $file), "D") Then
			_search($fileSet, $dir & "\" & $file)
		ElseIf StringRight($file, 4) == '.xml' Then
			_ArrayAdd($fileSet, $dir & "\" & $file)
		EndIf
	WEnd
	; Close the search handle
	FileClose($sch)
	$fileSet[0] = UBound($fileSet) - 1
EndFunc   ;==>_search

Func _deleteSelected()
	Local $i, $count = _GUICtrlListBox_GetCount($list) - 1
	For $i = 0 To $count
		If Not _GUICtrlListBox_GetSel($list, $i) Then ContinueLoop
		_GUICtrlListBox_DeleteString($list, $i)
		ExitLoop
	Next
EndFunc

Func _getSuffix($file)
	Local $suffix = StringRight($file, 20)
	If $suffix == '-error-info-i18n.xml' Then Return $suffix

	$suffix = StringRight($suffix, 17)
	If $suffix == '-cmdtree-i18n.xml' Then Return $suffix
	If $suffix == '-cmdinfo-i18n.xml' Then Return $suffix

	$suffix = StringRight($file, 15)
	If $suffix == '-error-info.xml' Then Return $suffix

	$suffix = StringRight($file, 14)
	If $suffix == '-enum-i18n.xml' Then Return $suffix

	$suffix = StringRight($file, 13)
	If $suffix == '-cmd-tree.xml' Then Return $suffix

	$suffix = StringRight($file, 12)
	If $suffix == '-cmdinfo.xml' Then Return $suffix

	$suffix = StringRight($file, 9)
	If $suffix == '-enum.xml' Then Return $suffix

	Return ''
EndFunc   ;==>_getSuffix

Func _getPropertyName($file)
	Local $suffix = _getSuffix($file)
	Local $idx = StringInStr($file, '\', Default, -1)
	Local $property
	If $idx == -1 Then
		$property = 'unkown'
	Else
		$property = StringLeft($file, $idx - 1)
	EndIf
	
	Switch $suffix
		Case '-cmdinfo.xml'
			Return $property & '.cmdinfo'
		Case '-cmdinfo-i18n.xml'
			Return $property & '.cmdinfo.i18n'
		Case '-enum.xml'
			Return $property & '.enuminfo'
		Case '-enum-i18n.xml'
			Return $property & '.enuminfo.i18n'
		Case '-error-info.xml'
			Return $property & '.errorinfo'
		Case '-error-info-i18n.xml'
			Return $property & '.errorinfo.i18n'
		Case '-cmd-tree.xml'
			Return $property & '.cmdtreeinfo'
		Case '-cmdtree-i18n.xml'
			Return $property & '.cmdtreeinfo.i18n'
	EndSwitch
	Return 'unkown'
EndFunc   ;==>_getPropertyName

Func _checkArguments()
	Local $file = GUICtrlRead($txtSDK)
	If Not FileExists($file) Or StringLower(StringRight($file, 9)) <> 'mxmlc.exe' Then
		MsgBox(16, '��������Դ������', 'mxmlc.exe�ļ������ڣ�', Default, $Form1)
		Return False
	EndIf

	If Not FileExists(GUICtrlRead($txtOutput)) Then
		MsgBox(16, '��������Դ������', '��Ч���˻�������Դ���Ŀ¼��', Default, $Form1)
		Return False
	EndIf

	If Not FileExists(GUICtrlRead($txtMML)) Then
		MsgBox(16, '��������Դ������', '��Ч���˻�����ű�Ŀ¼��', Default, $Form1)
		Return False
	EndIf

	$file = GUICtrlRead($txtI18n)
	If Not FileExists($file) Or StringLower(StringRight($file, 21)) <> 'comm-mml-api-i18n.xml' Then
		MsgBox(16, '��������Դ������', 'comm-mml-api-i18n.xml�ļ������ڣ�', Default, $Form1)
		Return False
	EndIf

	If _GUICtrlListBox_GetCount($list) == 0 Then
		_updateList()
		If _GUICtrlListBox_GetCount($list) == 0 Then
			MsgBox(16, '��������Դ������', '�б���û���κ��ļ�������ִ�С�ɨ�衱������', Default, $Form1)
			Return False
		EndIf
	EndIf

	Return True
EndFunc   ;==>_checkArguments

Func _enableAll()
	GUICtrlSetState($txtMML, $GUI_ENABLE)
	GUICtrlSetState($txtOutput, $GUI_ENABLE)
	GUICtrlSetState($txtSDK, $GUI_ENABLE)
	GUICtrlSetState($txtI18n, $GUI_ENABLE)
	GUICtrlSetState($btnBrowseMML, $GUI_ENABLE)
	GUICtrlSetState($btnBrowseOutput, $GUI_ENABLE)
	GUICtrlSetState($btnBrowseSDK, $GUI_ENABLE)
	GUICtrlSetState($btnBrowseI18n, $GUI_ENABLE)
	GUICtrlSetState($btnSearch, $GUI_ENABLE)
	GUICtrlSetState($btnGenerate, $GUI_ENABLE)
	GUICtrlSetState($btnMakeProperties, $GUI_ENABLE)
	GUICtrlSetState($btnDelete, $GUI_ENABLE)
	GUICtrlSetState($btnHelp, $GUI_ENABLE)
	GUICtrlSetState($btnExit, $GUI_ENABLE)
EndFunc   ;==>_enableAll

Func _disableAll()
	GUICtrlSetState($txtMML, $GUI_DISABLE)
	GUICtrlSetState($txtOutput, $GUI_DISABLE)
	GUICtrlSetState($txtSDK, $GUI_DISABLE)
	GUICtrlSetState($txtI18n, $GUI_DISABLE)
	GUICtrlSetState($btnBrowseMML, $GUI_DISABLE)
	GUICtrlSetState($btnBrowseOutput, $GUI_DISABLE)
	GUICtrlSetState($btnBrowseSDK, $GUI_DISABLE)
	GUICtrlSetState($btnBrowseI18n, $GUI_DISABLE)
	GUICtrlSetState($btnSearch, $GUI_DISABLE)
	GUICtrlSetState($btnGenerate, $GUI_DISABLE)
	GUICtrlSetState($btnMakeProperties, $GUI_DISABLE)
	GUICtrlSetState($btnDelete, $GUI_DISABLE)
	GUICtrlSetState($btnHelp, $GUI_DISABLE)
	GUICtrlSetState($btnExit, $GUI_DISABLE)
EndFunc   ;==>_disableAll

Func _saveArguments()
	IniWrite($CONF_FILE, 'main', 'mmlPath', GUICtrlRead($txtMML))
	IniWrite($CONF_FILE, 'main', 'sdkPath', GUICtrlRead($txtSDK))
	IniWrite($CONF_FILE, 'main', 'i18nPath', GUICtrlRead($txtI18n))
EndFunc   ;==>_saveArguments