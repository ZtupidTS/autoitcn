#NoTrayIcon
#AutoIt3Wrapper_Icon=maintain.ico

#include <GuiEdit.au3>
#include <ScrollBarConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiComboBox.au3>
#include <WindowsConstants.au3>
#include <Constants.au3>

#include <Date.au3>
#include <File.au3>
#include <Array.au3>

Opt('MustDeclareVars', 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Global Const $THIS_VERSION = 'v2.2.0'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Global Const $TYPE_DIR = '��Ŀ¼����'
Global Const $TYPE_CONFIG = '�������ļ�����'
Global Const $CONF_FILE = @ScriptDir & '\config.ini'
Global Const $HORIZONTAL_LINE = '-------------------------------------------------------------------------------------------------'
Global Const $HORIZONTAL_LINE2 = '================================================================================================='
Global Const $IN_USE = ' (ʹ����)'
Global Const $COMM_USER = 'wangliang138840'
Global Const $COMM_USER_PWD = 'wangliang'

Global $form = -1
Global $cbScannerVersion = -1
Global $hScannerVersion
Global $cbSearchFrom = -1
Global $lblInput = -1
Global $ipInput = -1
Global $btnInput = -1
Global $ipOutput = -1
Global $btnOutput = -1
Global $btnSetup = -1
Global $btnMake = -1
Global $btnHelp = -1
Global $txtConsole = -1
Global $hConsole = -1

Global $logFilePath = @ScriptDir & '\log\' & _DateDiff('s', "1970/01/01 00:00:00", _NowCalc()) & '.log'
Global $curScannerVersion = IniRead($CONF_FILE, 'main', 'current_scanner_version', '���¼��ɰ汾')

_setupEnviaronmant()
_createGUI()
_checkLatestVersion()
_removeExtraFiles()

While True
	Local $nMsg = GUIGetMsg()
	Switch $nMsg
		Case $btnSetup
			_handleSetupClick()
		Case $btnMake
			_handleMakeClick()
		Case $btnInput
			_handleInputClick()
		Case $btnOutput
			_handleOutputClick()
		Case $cbSearchFrom
			_handleComboClick()
		Case $cbScannerVersion
			_handleScannerVersionClick()
		Case $btnHelp
			_handleHelp()
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd

Func _handleMakeClick()
	Local $start = _NowCalc()
	_disableAll()
	_saveConfig()
	$logFilePath = @ScriptDir & '\log\' & _DateDiff('s', "1970/01/01 00:00:00", _NowCalc()) & '.log'

	Local $jvmOpt = IniRead($CONF_FILE, 'main', 'jvm_opt', '')
	Local $by
	If GUICtrlRead($cbSearchFrom) == $TYPE_CONFIG Then
		$by = 'by_config'
	Else
		$by = 'by_dir'
	EndIf
	Local $cmd = '"' & @ScriptDir & '\bin\jre\bin\java.exe" ' & _
			'-cp bin\scanner\lib\jdom.jar;bin\scanner\lib\jxl.jar;bin\scanner\bin ' & _
			$jvmOpt & ' com.zte.mml.common.managers.Main "' & _
			$by & '" "' & GUICtrlRead($ipInput) & '" "' & GUICtrlRead($ipOutput) & '"'
	_consoleWrite($cmd & @CRLF & @CRLF)

	Local $process = Run($cmd, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	Local $line
	While 1
		Sleep(50)
		$line = StdoutRead($process)
		If @error Then ExitLoop

		If $line == '' Then ContinueLoop
		$line = StringReplace($line, @LF, @CRLF)
		_consoleWrite($line)
	WEnd

	$line = ''
	Local $hasError = False
	While 1
		Sleep(50)
		$line = StderrRead($process)
		If @error Then ExitLoop

		If $line == '' Then ContinueLoop
		$line = StringReplace($line, @LF, @CRLF)
		_consoleWrite($line)
		$hasError = True
	WEnd
	If $hasError Then
		_consoleWrite('Ԥ�������������ʱ�ļ�ʧ�ܣ���ʱ ' & _DateDiff('s', $start, _NowCalc()) & ' ��' & @CRLF)
		_consoleWrite($HORIZONTAL_LINE2 & @CRLF & @CRLF & @CRLF & @CRLF)
		_enableAll()
		Return
	Else
		_consoleWrite(@CRLF & 'Ԥ�������������ʱ�ļ��ɹ�����ʱ ' & _DateDiff('s', $start, _NowCalc()) & ' ��' & @CRLF)
		_consoleWrite($HORIZONTAL_LINE & @CRLF)
	EndIf

	Local $path = GUICtrlRead($ipOutput)
	If StringRight($path, 1) <> '\' Then $path = $path & '\'

	Local $success = True
	_consoleWrite('��ʼ���� mml_resource_zh.swf...' & @CRLF)
	If _makeResource($path, 'zh_CN') Then
		_consoleWrite('--> ���� mml_resource_zh.swf �ɹ�' & @CRLF)
	Else
		_consoleWrite('--> ���� mml_resource_zh.swf ʧ��' & @CRLF)
		$success = False
	EndIf
	_consoleWrite('��ʼ���� mml_resource_en.swf...' & @CRLF)
	If _makeResource($path, 'en_US') Then
		_consoleWrite('--> ���� mml_resource_en.swf �ɹ�' & @CRLF)
	Else
		_consoleWrite('--> ���� mml_resource_en.swf ʧ��' & @CRLF)
		$success = False
	EndIf
	_consoleWrite($HORIZONTAL_LINE & @CRLF)
	If $success Then
		_consoleWrite('�����˻�������Դ�ɹ�����ʱ ' & _DateDiff('s', $start, _NowCalc()) & ' ��' & @CRLF)
	Else
		_consoleWrite('�����˻�������Դʧ�ܣ���ʱ ' & _DateDiff('s', $start, _NowCalc()) & ' ��' & @CRLF)
	EndIf
	_consoleWrite($HORIZONTAL_LINE2 & @CRLF & @CRLF & @CRLF & @CRLF)
	_enableAll()
EndFunc   ;==>_handleMakeClick

Func _makeResource($path, $locale)
	If Not _isAbsolute($path) Then
		;������һ�����·������Ҫת��Ϊ���Ե�
		$path = @ScriptDir & '\' & $path
	EndIf

	Local $process, $cmd
	If $locale == 'zh_CN' Then
		$cmd = '"' & @ScriptDir & '\bin\flex_sdk\bin\mxmlc.exe' & _
				'"  -locale=zh_CN -source-path="' & StringLeft($path, StringLen($path) - 1) & _
				'" -include-resource-bundles=mml_zh,collections,containers,controls,core,effects,skins,styles -output "' & _
				$path & 'mml_resource_zh.swf"'
		FileDelete($path & 'mml_resource_zh.swf')
	Else
		$cmd = '"' & @ScriptDir & '\bin\flex_sdk\bin\mxmlc.exe' & _
				'"  -locale=en_US -source-path="' & StringLeft($path, StringLen($path) - 1) & _
				'" -include-resource-bundles=mml_en,collections,containers,controls,core,effects,skins,styles -output "' & _
				$path & 'mml_resource_en.swf"'
		FileDelete($path & 'mml_resource_en.swf')
	EndIf
	_consoleWrite($cmd & @CRLF)
	$process = Run($cmd, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

	Local $line = ''
	While 1
		Sleep(50)
		$line = StdoutRead($process)
		If @error Then ExitLoop

		If $line == '' Then ContinueLoop
		_consoleWrite($line)
	WEnd

	$line = ''
	While 1
		Sleep(50)
		$line &= StderrRead($process)
		If @error Then ExitLoop
	WEnd
	_consoleWrite($line)

	If $locale == 'zh_CN' Then
		Return FileExists($path & 'mml_resource_zh.swf')
	Else
		Return FileExists($path & 'mml_resource_en.swf')
	EndIf
EndFunc   ;==>_makeResource

Func _handleSetupClick()
	MsgBox(64, "�˻�������Դ������", '������ʼ��������3������' & @CRLF & _
			'Flex SDK��Java���л���(JRE)���˻�����Ԥ�������(Scanner)' & @CRLF & @CRLF & _
			'����������Ҫ10�������ң������ĵȴ���' & @CRLF & _
			'��Щ���߶��Ǵ�svn�����صģ������������Ȩ�ޣ�Ҳ���õ�������^_^', Default, $form)
	_disableAll()
	If Not _getSDK() Then
		MsgBox(16, "�˻�������Դ������", '����flex sdk�������󣬰�װ���жϣ���ȷ����������������', Default, $form)
		GUICtrlSetState($btnSetup, $GUI_ENABLE)
		Return
	EndIf
	If Not _getJRE() Then
		MsgBox(16, "�˻�������Դ������", '����Java���л�����JRE���������󣬰�װ���жϣ���ȷ����������������', Default, $form)
		GUICtrlSetState($btnSetup, $GUI_ENABLE)
		Return
	EndIf

	Local $data = _getScannerVersionList()
	If $data == '' Then
		MsgBox(16, "�˻�������Դ������", '�����˻�����Ԥ�������İ汾�б�ʧ�ܣ���ȷ����������������', Default, $form)
		Return
	Else
		_GUICtrlComboBox_DeleteString($hScannerVersion, 0)
		GUICtrlSetData($cbScannerVersion, $data)
	EndIf

	If Not _getScanner() Then
		MsgBox(16, "�˻�������Դ������", '�����˻�����Ԥ������������󣬰�װ���жϣ���ȷ����������������', Default, $form)
		GUICtrlSetState($btnSetup, $GUI_ENABLE)
		Return
	EndIf
	MsgBox(64, "�˻�������Դ������", '��װ����Ĺ��߳ɹ��������������߼���ʹ�á�', Default, $form)
	_consoleWrite('��װ����Ĺ��߳ɹ��������������߼���ʹ�á�' & @CRLF & $HORIZONTAL_LINE)
	GUICtrlSetState($btnHelp, $GUI_ENABLE)
EndFunc   ;==>_handleSetupClick

Func _handleInputClick()
	Local $text, $path = GUICtrlRead($ipInput)
	If Not _isAbsolute($path) Then
		$path = @ScriptDir & '\' & $path
	EndIf
	If GUICtrlRead($cbSearchFrom) == $TYPE_CONFIG Then
		$text = FileOpenDialog('��������Դ������', $path, '�����ļ� (*.properties)', 1, '', $form)
		If $text == '' Then Return
		IniWrite($CONF_FILE, 'main', 'config_file', $text)
	Else
		$text = FileSelectFolder('��������Դ������', '', 4, $path, $form)
		If $text == '' Then Return
		IniWrite($CONF_FILE, 'main', 'input', $text)
	EndIf

	GUICtrlSetData($ipInput, $text)
EndFunc   ;==>_handleInputClick

Func _handleOutputClick()
	Local $path = GUICtrlRead($ipOutput)
	If Not _isAbsolute($path) Then
		$path = @ScriptDir & '\' & $path
	EndIf
	Local $text = FileSelectFolder('��������Դ������', '', 4, $path, $form)
	If $text == '' Then Return

	IniWrite($CONF_FILE, 'main', 'output', $text)
	GUICtrlSetData($ipOutput, $text)
EndFunc   ;==>_handleOutputClick

Func _handleComboClick()
	If GUICtrlRead($cbSearchFrom) == $TYPE_CONFIG Then
		GUICtrlSetData($lblInput, '�����ļ�·��')
		GUICtrlSetData($ipInput, IniRead($CONF_FILE, 'main', 'config_file', ''))
	Else
		GUICtrlSetData($lblInput, 'ɨ��Ŀ¼·��')
		GUICtrlSetData($ipInput, IniRead($CONF_FILE, 'main', 'input', ''))
	EndIf
	IniWrite($CONF_FILE, 'main', 'search_from', GUICtrlRead($cbSearchFrom))
EndFunc   ;==>_handleComboClick

Func _handleScannerVersionClick()
	If $curScannerVersion & $IN_USE == GUICtrlRead($cbScannerVersion) Then Return

	_disableAll()

	$curScannerVersion = GUICtrlRead($cbScannerVersion)
	Local $arr = _GUICtrlComboBox_GetListArray($hScannerVersion)
	Local $result = '', $index = 0
	For $i = 1 To $arr[0]
		If StringRight($arr[$i], StringLen($IN_USE)) == $IN_USE Then $arr[$i] = StringLeft($arr[$i], StringLen($arr[$i]) - StringLen($IN_USE))
		If $arr[$i] == $curScannerVersion Then
			$arr[$i] = $arr[$i] & $IN_USE
			$index = $i - 1
		EndIf
		$result &= '|' & $arr[$i]
	Next

	GUICtrlSetData($cbScannerVersion, $result)
	_GUICtrlComboBox_SetCurSel($hScannerVersion, $index)
	IniWrite($CONF_FILE, 'main', 'current_scanner_version', $curScannerVersion)

	IniWrite($CONF_FILE, 'main', 'scanner_installed', _downloadScanner($curScannerVersion))

	_enableAll()
EndFunc   ;==>_handleScannerVersionClick

Func _handleHelp()
	MsgBox(64, '�˻�������Դ������', _getHelp(), Default, $form)
EndFunc   ;==>_handleHelp

Func _saveConfig()
	IniWrite($CONF_FILE, 'main', 'search_from', GUICtrlRead($cbSearchFrom))
	If GUICtrlRead($cbSearchFrom) == $TYPE_CONFIG Then
		IniWrite($CONF_FILE, 'main', 'config_file', GUICtrlRead($ipInput))
	Else
		IniWrite($CONF_FILE, 'main', 'input', GUICtrlRead($ipInput))
	EndIf
	IniWrite($CONF_FILE, 'main', 'output', GUICtrlRead($ipOutput))
EndFunc   ;==>_saveConfig

Func _createGUI()
	$form = GUICreate("��������Դ������V2 - " & $THIS_VERSION, 626, 461)

	GUICtrlCreateLabel("ɨ�跶Χ", 8, 13, 52, 17)
	$cbSearchFrom = GUICtrlCreateCombo("", 88, 9, 110, 25, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, $TYPE_DIR & '|' & $TYPE_CONFIG, IniRead($CONF_FILE, 'main', 'search_from', $TYPE_CONFIG))

	GUICtrlCreateLabel("����Ԥ������򵽴˰汾", 215, 13)
	$cbScannerVersion = GUICtrlCreateCombo('', 352, 9, 225, 25, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, $curScannerVersion & $IN_USE, $curScannerVersion & $IN_USE)
	$hScannerVersion = GUICtrlGetHandle($cbScannerVersion)

	If IniRead($CONF_FILE, 'main', 'search_from', $TYPE_CONFIG) == $TYPE_CONFIG Then
		$lblInput = GUICtrlCreateLabel("�����ļ�·��", 8, 35)
		$ipInput = GUICtrlCreateInput(IniRead($CONF_FILE, 'main', 'config_file', ''), 88, 32, 489, 21)
	Else
		$lblInput = GUICtrlCreateLabel("ɨ��Ŀ¼·��", 8, 35)
		$ipInput = GUICtrlCreateInput(IniRead($CONF_FILE, 'main', 'input', ''), 88, 32, 489, 21)
	EndIf
	$btnInput = GUICtrlCreateButton("...", 584, 30, 35, 23, 0)

	GUICtrlCreateLabel("���·��", 8, 59, 52, 17)
	$ipOutput = GUICtrlCreateInput(IniRead($CONF_FILE, 'main', 'output', ''), 88, 56, 489, 21)
	GUICtrlSetTip(-1, '��ȷ��Ŀ¼��ʽ��ȷ����������Ŀ¼�����ڣ����߻��Զ�����')
	$btnOutput = GUICtrlCreateButton("...", 584, 55, 35, 23, 0)

	If _checkFlexSDK() And _checkJRE() And _checkJavaTool() Then
		$btnMake = GUICtrlCreateButton("����SWF��Դ", 7, 83, 107, 25, 0)
	Else
		$btnSetup = GUICtrlCreateButton("��װ", 7, 83, 55, 25, 0)
		GUICtrlCreateLabel('���뵥���˰�ť��װһЩ��Ҫ�Ĺ���', 65, 89)
		GUICtrlSetColor(-1, 0xff0000)
		GUICtrlCreateDummy()
		_disableAll()
		GUICtrlSetState($btnSetup, $GUI_ENABLE)
		GUICtrlSetState($btnHelp, $GUI_ENABLE)
	EndIf

	$txtConsole = GUICtrlCreateEdit('��ע�⣬�����޸��� �˻��������ζ��塢ö�ٶ��塢����������ģ�����Ҫ���±����˻�������Դ��' & @CRLF & _
			'������ֱ������˻�������Դδ��Ч���뽫IE����ʱ�ļ�ɾ��������' & @CRLF & $HORIZONTAL_LINE2 & @CRLF, _
			6, 111, 613, 344, $ES_MULTILINE & $WS_HSCROLL)
	$hConsole = GUICtrlGetHandle(-1)
	; ������ؼ��������������enableall��disableall��ʱ�򣬳����쳣
	$btnHelp = GUICtrlCreateButton("����", 564, 83, 55, 25, 0)

	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
	GUISetState(@SW_SHOW)
EndFunc   ;==>_createGUI

Func _enableAll()
	GUICtrlSetState($cbSearchFrom, $GUI_ENABLE)
	GUICtrlSetState($cbScannerVersion, $GUI_ENABLE)
	GUICtrlSetState($ipInput, $GUI_ENABLE)
	GUICtrlSetState($btnInput, $GUI_ENABLE)
	GUICtrlSetState($ipOutput, $GUI_ENABLE)
	GUICtrlSetState($btnOutput, $GUI_ENABLE)
	GUICtrlSetState($btnMake, $GUI_ENABLE)
	GUICtrlSetState($btnHelp, $GUI_ENABLE)
	GUICtrlSetState($btnSetup, $GUI_ENABLE)
EndFunc   ;==>_enableAll

Func _disableAll()
	GUICtrlSetState($cbSearchFrom, $GUI_DISABLE)
	GUICtrlSetState($cbScannerVersion, $GUI_DISABLE)
	GUICtrlSetState($ipInput, $GUI_DISABLE)
	GUICtrlSetState($btnInput, $GUI_DISABLE)
	GUICtrlSetState($ipOutput, $GUI_DISABLE)
	GUICtrlSetState($btnOutput, $GUI_DISABLE)
	GUICtrlSetState($btnMake, $GUI_DISABLE)
	GUICtrlSetState($btnHelp, $GUI_DISABLE)
	GUICtrlSetState($btnSetup, $GUI_DISABLE)
EndFunc   ;==>_disableAll

Func _getSDK()
	If IniRead($CONF_FILE, 'main', 'sdk_installed', '0') == 'True' Then Return True

	_consoleWrite('�������� flex sdk�����صĶ����Ƚ϶࣬�����ĵȴ�' & @CRLF)
	Local $ret = _downloadSVNFiles('http://10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/client/tools/sdk', 'bin\flex_sdk')
	If $ret Then
		_consoleWrite('����Flex SDK �ɹ�' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
	Else
		_consoleWrite('����Flex SDK ʧ��' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
	EndIf

	IniWrite($CONF_FILE, 'main', 'sdk_installed', $ret)

	Return $ret
EndFunc   ;==>_getSDK

Func _getJRE()
	If IniRead($CONF_FILE, 'main', 'jre_installed', '0') == 'True' Then Return True

	_consoleWrite('��������Java���л���(JRE)�����صĶ����Ƚ϶࣬�����ĵȴ�' & @CRLF)
	Local $ret = _downloadSVNFiles('http://10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/build/jre', 'bin\jre')
	If $ret Then
		_consoleWrite('����Java���л���(JRE) �ɹ�' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
	Else
		_consoleWrite('����Java���л���(JRE) ʧ��' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
	EndIf

	IniWrite($CONF_FILE, 'main', 'jre_installed', $ret)
	Return $ret
EndFunc   ;==>_getJRE

Func _getScanner()
	If IniRead($CONF_FILE, 'main', 'scanner_installed', '0') == 'True' Then Return True

	$curScannerVersion = '���¼��ɰ汾'
	IniWrite($CONF_FILE, 'main', 'current_scanner_version', $curScannerVersion)
	Local $ret = _downloadScanner($curScannerVersion)

	IniWrite($CONF_FILE, 'main', 'scanner_installed', $ret)

	Return $ret
EndFunc   ;==>_getScanner

Func _downloadScanner($versionTag)
	_consoleWrite('���������˻�����Ԥ����java����(Scanner)�����µ��汾��' & $versionTag & @CRLF)
	_writeLog('���������˻�����Ԥ����java����(Scanner)��$versionTag=' & $versionTag)

	DirRemove(@ScriptDir & '\bin\scanner\bin', 1)

	Local $ret
	If $versionTag == '���¼��ɰ汾' Then
		$ret = _downloadSVNFiles('http://10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/client/build/scanner/bin', 'bin\scanner\bin')
	ElseIf $versionTag == '���¿����汾' Then
		$ret = _downloadSVNFiles('http://10.44.20.16/svn/COMM/branches/Br_COMMV2.0_dev/client/build/scanner/bin', 'bin\scanner\bin')
	Else
		$ret = _downloadSVNFiles('http://10.44.20.16/svn/COMM/tags/' & $versionTag & _
				'/client/build/scanner/bin', 'bin\scanner\bin')
	EndIf

	If $ret Then
		_consoleWrite('�����˻�����Ԥ����java����(Scanner) �ɹ�' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
		_writeLog('�����˻�����Ԥ����java����(Scanner) �ɹ�')
	Else
		_consoleWrite('�����˻�����Ԥ����java����(Scanner) ʧ��' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
		_writeLog('�����˻�����Ԥ����java����(Scanner) ʧ��')
	EndIf
	Return $ret
EndFunc   ;==>_downloadScanner

;~ Func _setupFailed()
;~ 	Local $text = ''
;~ 	If Not _checkFlexSDK() Then
;~ 		$text &= '�� flex sdk�����ڣ��뵽�����ַȥ��flex sdk����������' & @CRLF & _
;~ 				'�� http://10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/client/tools/sdk' & @CRLF & _
;~ 				'�� �����������Ŀ¼�£�' & @CRLF & _
;~ 				'�� ' & @ScriptDir & '\bin\flex_sdk' & @CRLF & @CRLF
;~ 	EndIf
;~ 	If Not _checkJRE() Then
;~ 		$text &= '�� Java���л��������ڣ��뵽�����ַȥ�ϰ�������������' & @CRLF & _
;~ 				'�� http://10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/build/jre' & @CRLF & _
;~ 				'�� �����������Ŀ¼�£�' & @CRLF & _
;~ 				'�� ' & @ScriptDir & '\bin\jre' & @CRLF & @CRLF
;~ 	EndIf
;~ 	If Not _checkJavaTool() Then
;~ 		$text &= '�� �˻�����Ԥ����java���򲻴��ڣ��뵽�����ַȥ�ϰ�������������' & @CRLF & _
;~ 				'�� http://10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/client/build/scanner' & @CRLF & _
;~ 				'�� �����������Ŀ¼�£�' & @CRLF & _
;~ 				'�� ' & @ScriptDir & '\bin\scanner' & @CRLF & @CRLF
;~ 	EndIf
;~ 	If $text <> '' Then
;~ 		$text = '�������������쳣���⵼�±����ߵİ�װ�޷��Զ���ɣ���ȷ��������������������' & @CRLF & _
;~ 				'���߰��������ָʾ�ֹ���ɰ�װ����' & @CRLF & @CRLF & $text & _
;~ 				'��ܰ���ѣ������ʹ��Ctrl+C�����Ի����ϵ������ı�����������' & @CRLF & _
;~ 				'����һ���������ļ���ʱ�򣬾Ͳ���Ҫһ�����ַ�����'
;~ 		MsgBox(64, "�˻�������Դ������", $text, Default, $form)
;~ 		Exit
;~ 	EndIf
;~ 	MsgBox(64, "�˻�������Դ������", '������һЩ������������Ҳ��֪������Ի�����ô�ᵯ�����ģ���ͳ���10045812��ϵ', Default, $form)
;~ EndFunc   ;==>_setupFailed

Func _checkFlexSDK()
	Return IniRead($CONF_FILE, 'main', 'sdk_installed', 'False') == 'True'
EndFunc   ;==>_checkFlexSDK

Func _checkJRE()
	Return IniRead($CONF_FILE, 'main', 'jre_installed', 'False') == 'True'
EndFunc   ;==>_checkJRE

Func _checkJavaTool()
	Return IniRead($CONF_FILE, 'main', 'scanner_installed', 'False') == 'True'
EndFunc   ;==>_checkJavaTool

Func _downloadSVNFiles($url, $folder)
	If FileExists($folder) Then
		DirRemove($folder, True)
	EndIf

	Local $cmd = '"' & @ScriptDir & '\bin\svn.exe" co "' & $url & '" "' & $folder & _
			'" --username ' & $COMM_USER & ' --password ' & $COMM_USER_PWD
	Local $process = Run($cmd, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	Local $line
	While 1
		Sleep(50)
		$line = StdoutRead($process)
		If @error Then ExitLoop

		If $line == '' Then ContinueLoop
		$line = StringReplace($line, @LF, @CRLF)
		_consoleWrite($line)
	WEnd

	$line = ''
	Local $hasError = False
	While 1
		Sleep(50)
		$line = StderrRead($process)
		If @error Then ExitLoop

		If $line == '' Then ContinueLoop
		$line = StringReplace($line, @LF, @CRLF)
		_consoleWrite($line)
		$hasError = True
	WEnd
	Return Not $hasError
EndFunc   ;==>_downloadSVNFiles

Func _downloadFile($url, $saveto, $retry = 3)
	For $i = 1 To $retry
		InetGet($url, $saveto)
		If Not @error Then Return True
	Next
	Return False
EndFunc   ;==>_downloadFile

Func _getScannerVersionList()
	_consoleWrite('���������˻�����Ԥ�������İ汾�б���ȴ�...' & @CRLF)
	If Not _downloadFile('http://' & $COMM_USER & ':' & $COMM_USER_PWD & '@10.44.20.16/svn/COMM/tags', @ScriptDir & '\map.xml') Then
		FileDelete(@ScriptDir & '\map.xml')
		_consoleWrite('�����˻�����Ԥ�������İ汾�б�ʧ�ܣ�' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
		_writeLog("�����˻�����Ԥ�������İ汾�б�ʧ�ܣ�InetGet set @error 0")
		Return ''
	EndIf

	Local $xml = ObjCreate("Microsoft.XMLDOM")
	If Not IsObj($xml) Then
		FileDelete(@ScriptDir & '\map.xml')
		_consoleWrite('�����˻�����Ԥ�������İ汾�б�ʧ�ܣ�' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
		_writeLog("�����˻�����Ԥ�������İ汾�б�ʧ�ܣ�����xmlʧ��")
		Return ''
	EndIf
	$xml.Async = "false"
	$xml.Load(@ScriptDir & '\map.xml')

	Local $items = $xml.SelectNodes('/svn/index/dir')
	Local $tag, $item, $version, $arr[1][2] = [[0, 0]]
	For $item In $items
		$tag = $item.GetAttribute("name")
		$version = StringRight($tag, 6)

		;��Ϊֻ�е�I4����Ԥ�������I4�İ汾�ž���100519
		If $version < 100519 Then ContinueLoop

		$arr[0][0] += 1
		ReDim $arr[$arr[0][0] + 1][2]
		$arr[$arr[0][0]][0] = $version
		$arr[$arr[0][0]][1] = $tag
	Next
	_ArraySort($arr, 0, 1)

	Local $i, $result = '', $count = 0
	For $i = 1 To $arr[0][0]
		If Not _downloadFile('http://' & $COMM_USER & ':' & $COMM_USER_PWD & '@10.44.20.16/svn/COMM/tags/' & _
				$arr[$i][1] & '/client/build/scanner/bin', @ScriptDir & '\map.xml') Then
			ContinueLoop
		EndIf
		If $count >= 15 Then
			ExitLoop
		EndIf

		If $arr[$i][1] == $curScannerVersion Then $arr[$i][1] = $arr[$i][1] & $IN_USE
		$result &= $arr[$i][1] & '|'
		$count += 1
	Next

	FileDelete(@ScriptDir & '\map.xml')
	If $result == '' Then
		_consoleWrite('�����˻�����Ԥ�������İ汾�б�ʧ�ܣ�' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
		_writeLog("�����˻�����Ԥ�������İ汾�б�ʧ�ܣ����ص�xml�У�û�а汾��Ϣ")
		Return ''
	Else
		_consoleWrite('�����˻�����Ԥ�������İ汾�б�ɹ���' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
		_writeLog("�����˻�����Ԥ�������İ汾�б�ɹ���")
		If $curScannerVersion == '���¼��ɰ汾' Then
			Return '���¼��ɰ汾' & $IN_USE & '|���¿����汾|' & StringLeft($result, StringLen($result) - 1)
		ElseIf $curScannerVersion == '���¿����汾' Then
			Return '���¼��ɰ汾|���¿����汾' & $IN_USE & '|' & StringLeft($result, StringLen($result) - 1)
		Else
			Return '���¼��ɰ汾|���¿����汾|' & StringLeft($result, StringLen($result) - 1)
		EndIf
	EndIf
EndFunc   ;==>_getScannerVersionList

Func WM_COMMAND($hWnd, $iMsg, $iwParam, $ilParam)
	If _GUICtrlComboBox_GetCount($hScannerVersion) > 1 Then Return $GUI_RUNDEFMSG

	Local $hWndFrom, $iIDFrom, $iCode
	$hWndFrom = $ilParam
	$iIDFrom = BitAND($iwParam, 0xFFFF) ; Low Word
	$iCode = BitShift($iwParam, 16) ; Hi Word

	If $hWndFrom <> $hScannerVersion Then Return $GUI_RUNDEFMSG
;~ 	ConsoleWrite('$iCode=' & $iCode & @CRLF)
	If $iCode == $CBN_DROPDOWN Then
		_GUICtrlComboBox_DeleteString($hScannerVersion, 0)
		GUICtrlSetData($cbScannerVersion, _getScannerVersionList())
		If _GUICtrlComboBox_GetCurSel($hScannerVersion) == -1 Then
			Local $arr = _GUICtrlComboBox_GetListArray($hScannerVersion)
			For $i = 1 To $arr[0]
				If $arr[$i] <> $curScannerVersion & $IN_USE Then ContinueLoop
				_GUICtrlComboBox_SetCurSel($hScannerVersion, $i - 1)
				ExitLoop
			Next
		EndIf
	EndIf

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND

Func _checkLatestVersion()
	If IniRead($CONF_FILE, 'main', 'is_check_latest_version', 'True') <> 'True' Then Return

	_consoleWrite('���ڼ���°汾�����Ե�...' & @CRLF)
	_disableAll()
	If FileExists(@ScriptDir & '\version.ini') Then FileDelete(@ScriptDir & '\version.ini')
	Local $ret = _downloadFile('http://' & $COMM_USER & ':' & $COMM_USER_PWD & _
			'@10.44.20.37/svn/NM_PLAT_DOC/trunk/C�������ĵ�/0����ҵ�񿪷�һ��/01�ۺϿ�/С����/�˻�������Դ������V2.ini', _
			@ScriptDir & '\version.ini', 1)
	If Not $ret Then
		_consoleWrite('�޷�������°汾����ȷ�����������Ƿ��������������Ӱ�챾���߼���ʹ�á�' & @CRLF & $HORIZONTAL_LINE2 & @CRLF)
		_enableAll()
		Return
	EndIf

	Local $latestVersion = IniRead(@ScriptDir & '\version.ini', 'version', 'latest_version', $THIS_VERSION)
	If _compareVersion($latestVersion, $THIS_VERSION) <= 0 Then
		_consoleWrite('��ǰʹ�õİ汾�Ѿ������°汾��' & @CRLF & $HORIZONTAL_LINE2 & @CRLF)
		_enableAll()
		Return
	EndIf

	Local $info = IniReadSection(@ScriptDir & '\version.ini', 'version')
	Local $releaseNote = '', $version
	If IsArray($info) Then
		$releaseNote = @CRLF & @CRLF & '���¼�¼��' & @CRLF & @CRLF
		For $i = 1 To $info[0][0]
			If StringLeft($info[$i][0], 13) <> 'release_note_' Then ContinueLoop

			$version = StringMid($info[$i][0], 14)
			If _compareVersion($version, $THIS_VERSION) <= 0 Then ContinueLoop

			$releaseNote &= '�� �汾 ' & $version & @CRLF & $info[$i][1] & @CRLF & @CRLF
		Next
		$releaseNote = StringReplace($releaseNote, '\n', @CRLF)
		$releaseNote = StringReplace($releaseNote, '\t', @TAB)
	EndIf

	Local $text = '�����°汾���˻�������Դ������V2�����汾���� ' & $latestVersion & '��ǰ�汾�� ' & $THIS_VERSION & _
			'���Ƿ��������°汾��' & @CRLF & _
			'���ѣ�1. ������Դ�ǹ�˾����SVN����������Ȩ�ޣ�Ҳ�������������' & @CRLF & _
			'������2. ���ϰ汾��ͬʱʹ�ã�����Ӱ��Ŷ' & $releaseNote
	$text = StringStripWS($text, 3)
	_consoleWrite($text & @CRLF & $HORIZONTAL_LINE2 & @CRLF)
	Local $iMsgBoxAnswer = MsgBox(36, '�˻�������Դ������V2', $text, Default, $form)
	If $iMsgBoxAnswer == 6 Then ;Yes
		Local $path = FileSaveDialog('�˻�������Դ������V2', '', '�����ļ� (*.*)', 18, '�˻�������Դ������V2.rar', $form)
		If $path == '' Then
			_enableAll()
			Return
		EndIf

		_consoleWrite('��ʼ�����°汾�����浽 ' & $path & @CRLF)
		$ret = _downloadFile('http://' & $COMM_USER & ':' & $COMM_USER_PWD & _
				'@10.44.20.37/svn/NM_PLAT_DOC/trunk/C�������ĵ�/0����ҵ�񿪷�һ��/01�ۺϿ�/С����/�˻�������Դ������V2.rar', $path)
		If $ret Then
			_consoleWrite("��ϲ���°汾���سɹ�����ѹ������ѹ����ĳ��Ŀ¼�¼���ʹ���°汾�ˡ�" & @CRLF & _
					"С��ʾ�����ϰ汾��ͬʱʹ�ã�����Ӱ��Ŷ^_^" & @CRLF)
			MsgBox(64, "�˻�������Դ������V2", "��ϲ���°汾���سɹ�����ѹ������ѹ����ĳ��Ŀ¼�¼���ʹ���°汾�ˡ�" & @CRLF & _
					"С��ʾ�����ϰ汾��ͬʱʹ�ã�����Ӱ��Ŷ^_^", Default, $form)
		Else
			_consoleWrite("��Ǹ���޷������°汾ѹ������" & @CRLF & "��ȷ��������������������һ�Ρ�" & @CRLF)
			MsgBox(48, "�˻�������Դ������V2", "��Ǹ���޷������°汾ѹ������" & @CRLF & "��ȷ��������������������һ�Ρ�", Default, $form)
		EndIf
		_consoleWrite($HORIZONTAL_LINE & @CRLF)
	EndIf
	_enableAll()
EndFunc   ;==>_checkLatestVersion

Func _compareVersion($ver1, $ver2)
	If StringUpper(StringLeft($ver1, 1)) == 'V' Then $ver1 = StringMid($ver1, 2)
	If StringUpper(StringLeft($ver2, 1)) == 'V' Then $ver2 = StringMid($ver2, 2)

	Local $arr = StringSplit($ver1, '.')
	Local $verNum1
	If $arr[0] >= 3 Then
		$verNum1 = $arr[1] * 1000000 + $arr[2] * 1000 + $arr[3]
	Else
		$verNum1 = 0
	EndIf

	$arr = StringSplit($ver2, '.')
	Local $verNum2
	If $arr[0] >= 3 Then
		$verNum2 = $arr[1] * 1000000 + $arr[2] * 1000 + $arr[3]
	Else
		$verNum2 = 0
	EndIf

	If $verNum1 > $verNum2 Then Return 1
	If $verNum1 < $verNum2 Then Return -1
	If $verNum1 == $verNum2 Then Return 0
EndFunc   ;==>_compareVersion

Func _setupEnviaronmant()
	Local $javaHome = EnvGet('JAVA_HOME')
	If $javaHome == '' Then
		_writeLog('������������ JAVA_HOME=' & @ScriptDir & '\bin\jre')
		EnvSet('JAVA_HOME', @ScriptDir & '\bin\jre')
	EndIf

	If Not FileExists(@ScriptDir & '\log') Then DirCreate(@ScriptDir & '\log')
EndFunc   ;==>_setupEnviaronmant

Func _consoleWrite($txt)
	GUICtrlSetData($txtConsole, _GUICtrlEdit_GetText($hConsole) & $txt)
	; ��һ����10λ�����������ļ�
	_writeLog($txt, $logFilePath)
	_GUICtrlEdit_Scroll($hConsole, $SB_SCROLLCARET)
EndFunc   ;==>_consoleWrite

Func _removeExtraFiles()
	Local $fileList = _FileListToArray(@ScriptDir & '\log', '*.log', 1)
	If @error Then
		Return
	EndIf
	_ArraySort($fileList, 1, 1, $fileList[0])

	Local $count = 0, $i, $num
	For $i = 1 To $fileList[0]
		$num = StringLeft($fileList[$i], 10)
		;�����ļ�������10λ���������ģ�����޷�ת�������֣�����Ϊ�ļ�����Ч
		If Number($num) == 0 Then ContinueLoop

		$count += 1
		If $count < 10 Then ContinueLoop

		FileDelete(@ScriptDir & '\log\' & $fileList[$i])
		_writeLog('removing file: ' & @ScriptDir & '\log\' & $fileList[$i])
	Next
EndFunc   ;==>_removeExtraFiles

Func _writeLog($message, $file = '__default__')
	Local $now = _NowCalc()
	If $file == '__default__' Then
		$message = _NowCalc() & '    ' & $message & @CRLF
		$file = @ScriptDir & '\log\global.log'
	EndIf

	FileWrite($file, $message)
EndFunc   ;==>_writeLog

Func _isAbsolute($path)
	Return StringMid(StringStripWS($path, 3), 2, 1) == ':'
EndFunc   ;==>_isAbsolute

Func _getCompiledDate()
	Local $attr = FileGetTime(@ScriptFullPath, 0)
	Return $attr[0] & '��' & $attr[1] & '��' & $attr[2] & '��' & $attr[3] & '��'
EndFunc   ;==>_getCompiledDate

Func _getHelp()
	Local $text = '������£�' & _getCompiledDate() & @CRLF & _
			'���߰汾��' & $THIS_VERSION & @CRLF & _
			'�������ߣ�����10045812' & @CRLF & @CRLF & FileRead(@ScriptDir & '\ʹ�ð���.txt')
	Return $text
EndFunc   ;==>_getHelp