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

Global $TYPE_DIR = '按目录搜索'
Global $TYPE_CONFIG = '按配置文件搜索'
Global $CONF_FILE = @ScriptDir & '\config.ini'
Global $HORIZONTAL_LINE = '-------------------------------------------------------------------------------------------------'
Global $HORIZONTAL_LINE2 = '================================================================================================='
Global $IN_USE = ' (使用中)'

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
Global $curScannerVersion = IniRead($CONF_FILE, 'main', 'current_scanner_version', '最新集成版本')

_createGUI()
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
		_consoleWrite('预编译程序生成临时文件失败，耗时 ' & _DateDiff('s', $start, _NowCalc()) & ' 秒' & @CRLF)
		_consoleWrite($HORIZONTAL_LINE2 & @CRLF & @CRLF & @CRLF & @CRLF)
		_enableAll()
		Return
	Else
		_consoleWrite(@CRLF & '预编译程序生成临时文件成功，耗时 ' & _DateDiff('s', $start, _NowCalc()) & ' 秒' & @CRLF)
		_consoleWrite($HORIZONTAL_LINE & @CRLF)
	EndIf

	Local $path = GUICtrlRead($ipOutput)
	If StringRight($path, 1) <> '\' Then $path = $path & '\'

	Local $success = True
	_consoleWrite('开始编译 mml_resource_zh.swf...' & @CRLF)
	If _makeResource($path, 'zh_CN') Then
		_consoleWrite('--> 编译 mml_resource_zh.swf 成功' & @CRLF)
	Else
		_consoleWrite('--> 编译 mml_resource_zh.swf 失败' & @CRLF)
		$success = False
	EndIf
	_consoleWrite('开始编译 mml_resource_en.swf...' & @CRLF)
	If _makeResource($path, 'en_US') Then
		_consoleWrite('--> 编译 mml_resource_en.swf 成功' & @CRLF)
	Else
		_consoleWrite('--> 编译 mml_resource_en.swf 失败' & @CRLF)
		$success = False
	EndIf
	_consoleWrite($HORIZONTAL_LINE & @CRLF)
	If $success Then
		_consoleWrite('编译人机命令资源成功，耗时 ' & _DateDiff('s', $start, _NowCalc()) & ' 秒' & @CRLF)
	Else
		_consoleWrite('编译人机命令资源失败，耗时 ' & _DateDiff('s', $start, _NowCalc()) & ' 秒' & @CRLF)
	EndIf
	_consoleWrite($HORIZONTAL_LINE2 & @CRLF & @CRLF & @CRLF & @CRLF)
	_enableAll()
EndFunc   ;==>_handleMakeClick

Func _makeResource($path, $locale)
	If Not _isAbsolute($path) Then
		;给的是一个相对路径，需要转化为绝对的
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
	MsgBox(64, "人机命令资源编译器", '即将开始下载下列3个工具' & @CRLF & _
			'Flex SDK，Java运行环境(JRE)，人机命令预编译程序(Scanner)' & @CRLF & @CRLF & _
			'整个过程需要10分钟左右，请耐心等待。' & @CRLF & _
			'这些工具都是从svn上下载的，因此无需外网权限，也不用担心流量^_^', Default, $form)
	_disableAll()
	If Not _getSDK() Then
		MsgBox(16, "人机命令资源编译器", '下载flex sdk发生错误，安装被中断，请确认网络连接正常。', Default, $form)
		GUICtrlSetState($btnSetup, $GUI_ENABLE)
		Return
	EndIf
	If Not _getJRE() Then
		MsgBox(16, "人机命令资源编译器", '下载Java运行环境（JRE）发生错误，安装被中断，请确认网络连接正常。', Default, $form)
		GUICtrlSetState($btnSetup, $GUI_ENABLE)
		Return
	EndIf

	Local $data = _getScannerVersionList()
	If $data == '' Then
		MsgBox(16, "人机命令资源编译器", '下载人机命令预编译程序的版本列表失败！请确认网络连接正常。', Default, $form)
		Return
	Else
		_GUICtrlComboBox_DeleteString($hScannerVersion, 0)
		GUICtrlSetData($cbScannerVersion, $data)
	EndIf

	If Not _getScanner() Then
		MsgBox(16, "人机命令资源编译器", '下载人机命令预编译程序发生错误，安装被中断，请确认网络连接正常。', Default, $form)
		GUICtrlSetState($btnSetup, $GUI_ENABLE)
		Return
	EndIf
	MsgBox(64, "人机命令资源编译器", '安装所需的工具成功，请重启本工具继续使用。', Default, $form)
	_consoleWrite('安装所需的工具成功，请重启本工具继续使用。' & @CRLF & $HORIZONTAL_LINE)
	GUICtrlSetState($btnHelp, $GUI_ENABLE)
EndFunc   ;==>_handleSetupClick

Func _handleInputClick()
	Local $text, $path = GUICtrlRead($ipInput)
	If Not _isAbsolute($path) Then
		$path = @ScriptDir & '\' & $path
	EndIf
	If GUICtrlRead($cbSearchFrom) == $TYPE_CONFIG Then
		$text = FileOpenDialog('命令行资源编译器', $path, '配置文件 (*.properties)', 1, '', $form)
		If $text == '' Then Return
		IniWrite($CONF_FILE, 'main', 'config_file', $text)
	Else
		$text = FileSelectFolder('命令行资源编译器', '', 4, $path, $form)
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
	Local $text = FileSelectFolder('命令行资源编译器', '', 4, $path, $form)
	If $text == '' Then Return

	IniWrite($CONF_FILE, 'main', 'output', $text)
	GUICtrlSetData($ipOutput, $text)
EndFunc   ;==>_handleOutputClick

Func _handleComboClick()
	If GUICtrlRead($cbSearchFrom) == $TYPE_CONFIG Then
		GUICtrlSetData($lblInput, '配置文件路径')
		GUICtrlSetData($ipInput, IniRead($CONF_FILE, 'main', 'config_file', ''))
	Else
		GUICtrlSetData($lblInput, '扫描目录路径')
		GUICtrlSetData($ipInput, IniRead($CONF_FILE, 'main', 'input', ''))
	EndIf
	IniWrite($CONF_FILE, 'main', 'search_from', GUICtrlRead($cbSearchFrom))
EndFunc   ;==>_handleComboClick

Func _handleScannerVersionClick()
	If $curScannerVersion & $IN_USE == GUICtrlRead($cbScannerVersion) Then Return

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
EndFunc   ;==>_handleScannerVersionClick

Func _handleHelp()
	MsgBox(64, '人机命令资源编译器', _getHelp(), Default, $form)
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
	$form = GUICreate("命令行资源编译器V2", 626, 461, 193, 115)

	GUICtrlCreateLabel("扫描范围", 8, 13, 52, 17)
	$cbSearchFrom = GUICtrlCreateCombo("", 88, 9, 110, 25, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, $TYPE_DIR & '|' & $TYPE_CONFIG, IniRead($CONF_FILE, 'main', 'search_from', $TYPE_CONFIG))

	GUICtrlCreateLabel("更新预编译程序到此版本", 215, 13)
	$cbScannerVersion = GUICtrlCreateCombo('', 352, 9, 225, 25, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, $curScannerVersion & $IN_USE, $curScannerVersion & $IN_USE)
	$hScannerVersion = GUICtrlGetHandle($cbScannerVersion)

	If IniRead($CONF_FILE, 'main', 'search_from', $TYPE_CONFIG) == $TYPE_CONFIG Then
		$lblInput = GUICtrlCreateLabel("配置文件路径", 8, 35)
		$ipInput = GUICtrlCreateInput(IniRead($CONF_FILE, 'main', 'config_file', ''), 88, 32, 489, 21)
	Else
		$lblInput = GUICtrlCreateLabel("扫描目录路径", 8, 35)
		$ipInput = GUICtrlCreateInput(IniRead($CONF_FILE, 'main', 'input', ''), 88, 32, 489, 21)
	EndIf
	$btnInput = GUICtrlCreateButton("...", 584, 30, 35, 23, 0)

	GUICtrlCreateLabel("输出路径", 8, 59, 52, 17)
	$ipOutput = GUICtrlCreateInput(IniRead($CONF_FILE, 'main', 'output', ''), 88, 56, 489, 21)
	GUICtrlSetTip(-1, '请确认目录格式正确，如果输入的目录不存在，工具会自动创建')
	$btnOutput = GUICtrlCreateButton("...", 584, 55, 35, 23, 0)

	If _checkFlexSDK() And _checkJRE() And _checkJavaTool() Then
		$btnMake = GUICtrlCreateButton("生成SWF资源", 7, 83, 107, 25, 0)
	Else
		$btnSetup = GUICtrlCreateButton("安装", 7, 83, 55, 25, 0)
		GUICtrlCreateLabel('←请单击此按钮安装一些必要的工具', 65, 89)
		GUICtrlSetColor(-1, 0xff0000)
		GUICtrlCreateDummy()
		_disableAll()
		GUICtrlSetState($btnSetup, $GUI_ENABLE)
		GUICtrlSetState($btnHelp, $GUI_ENABLE)
	EndIf

	$txtConsole = GUICtrlCreateEdit('请注意，凡是修改了 人机命令出入参定义、枚举定义、命令树定义的，都需要重新编译人机命令资源。' & @CRLF & _
			'如果发现编译后的人机命令资源未生效，请将IE的临时文件删除后再试' & @CRLF & $HORIZONTAL_LINE2 & @CRLF, _
			6, 111, 613, 344, $ES_MULTILINE & $WS_HSCROLL)
	$hConsole = GUICtrlGetHandle(-1)
	; 将这个控件放在最后，以免在enableall和disableall的时候，出现异常
	$btnHelp = GUICtrlCreateButton("帮助", 564, 83, 55, 25, 0)

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

	_consoleWrite('正在下载 flex sdk，下载的东西比较多，请耐心等待' & @CRLF)
	Local $ret = _downloadSVNFiles('http://chenxucc:oicqcx1@10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/client/tools/sdk', @ScriptDir & '\bin\flex_sdk')
	If $ret Then
		_consoleWrite('下载Flex SDK 成功' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
	Else
		_consoleWrite('下载Flex SDK 失败' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
	EndIf

	IniWrite($CONF_FILE, 'main', 'sdk_installed', $ret)

	Return $ret
EndFunc   ;==>_getSDK

Func _getJRE()
	If IniRead($CONF_FILE, 'main', 'jre_installed', '0') == 'True' Then Return True

	_consoleWrite('正在下载Java运行环境(JRE)，下载的东西比较多，请耐心等待' & @CRLF)
	Local $ret = _downloadSVNFiles('http://chenxucc:oicqcx1@10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/build/jre', @ScriptDir & '\bin\jre')
	If $ret Then
		_consoleWrite('下载Java运行环境(JRE) 成功' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
	Else
		_consoleWrite('下载Java运行环境(JRE) 失败' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
	EndIf

	IniWrite($CONF_FILE, 'main', 'jre_installed', $ret)
	Return $ret
EndFunc   ;==>_getJRE

Func _getScanner()
	If IniRead($CONF_FILE, 'main', 'scanner_installed', '0') == 'True' Then Return True

	$curScannerVersion = '最新集成版本'
	IniWrite($CONF_FILE, 'main', 'current_scanner_version', $curScannerVersion)
	Local $ret = _downloadScanner($curScannerVersion)

	IniWrite($CONF_FILE, 'main', 'scanner_installed', $ret)

	Return $ret
EndFunc   ;==>_getScanner

Func _downloadScanner($versionTag)
	_consoleWrite('正在下载人机命令预编译java程序(Scanner)，更新到版本：' & $versionTag & @CRLF)
	_writeLog('正在下载人机命令预编译java程序(Scanner)，$versionTag=' & $versionTag)

	DirRemove(@ScriptDir & '\bin\scanner\bin', 1)

	Local $ret
	If $versionTag == '最新集成版本' Then
		$ret = _downloadSVNFiles('http://chenxucc:oicqcx1@10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/client/build/scanner/bin', _
				@ScriptDir & '\bin\scanner\bin')
	ElseIf $versionTag == '最新开发版本' Then
		$ret = _downloadSVNFiles('http://chenxucc:oicqcx1@10.44.20.16/svn/COMM/branches/Br_COMMV2.0_dev/client/build/scanner/bin', _
				@ScriptDir & '\bin\scanner\bin')
	Else
		$ret = _downloadSVNFiles('http://chenxucc:oicqcx1@10.44.20.16/svn/COMM/tags/' & $versionTag & _
				'/client/build/scanner/bin', @ScriptDir & '\bin\scanner\bin')
	EndIf

	If $ret Then
		_consoleWrite('下载人机命令预编译java程序(Scanner) 成功' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
		_writeLog('下载人机命令预编译java程序(Scanner) 成功')
	Else
		_consoleWrite('下载人机命令预编译java程序(Scanner) 失败' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
		_writeLog('下载人机命令预编译java程序(Scanner) 失败')
	EndIf
	Return $ret
EndFunc   ;==>_downloadScanner

;~ Func _setupFailed()
;~ 	Local $text = ''
;~ 	If Not _checkFlexSDK() Then
;~ 		$text &= '★ flex sdk不存在，请到这个网址去把flex sdk下载下来：' & @CRLF & _
;~ 				'　 http://10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/client/tools/sdk' & @CRLF & _
;~ 				'　 并拷贝到这个目录下：' & @CRLF & _
;~ 				'　 ' & @ScriptDir & '\bin\flex_sdk' & @CRLF & @CRLF
;~ 	EndIf
;~ 	If Not _checkJRE() Then
;~ 		$text &= '★ Java运行环境不存在，请到这个网址去上把它下载下来：' & @CRLF & _
;~ 				'　 http://10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/build/jre' & @CRLF & _
;~ 				'　 并拷贝到这个目录下：' & @CRLF & _
;~ 				'　 ' & @ScriptDir & '\bin\jre' & @CRLF & @CRLF
;~ 	EndIf
;~ 	If Not _checkJavaTool() Then
;~ 		$text &= '★ 人机命令预编译java程序不存在，请到这个网址去上把它下载下来：' & @CRLF & _
;~ 				'　 http://10.44.20.16/svn/COMM/branches/Br_COMMV2.0_integ/client/build/scanner' & @CRLF & _
;~ 				'　 并拷贝到这个目录下：' & @CRLF & _
;~ 				'　 ' & @ScriptDir & '\bin\scanner' & @CRLF & @CRLF
;~ 	EndIf
;~ 	If $text <> '' Then
;~ 		$text = '由于网络连接异常，这导致本工具的安装无法自动完成，请确认网络连接正常后再试' & @CRLF & _
;~ 				'或者按照下面的指示手工完成安装过程' & @CRLF & @CRLF & $text & _
;~ 				'温馨提醒：你可以使用Ctrl+C将本对话框上的所有文本复制下来，' & @CRLF & _
;~ 				'这样一来在下载文件的时候，就不需要一个个字符敲了'
;~ 		MsgBox(64, "人机命令资源编译器", $text, Default, $form)
;~ 		Exit
;~ 	EndIf
;~ 	MsgBox(64, "人机命令资源编译器", '出现了一些意外的情况，我也不知道这个对话框怎么会弹出来的，请和陈旭10045812联系', Default, $form)
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
	If StringRight($folder, 1) == '\' Then $folder = StringLeft($folder, StringLen($folder))
	DirCreate($folder)

	InetGet($url, $folder & '\map.xml')
	If @error Then
		Return False
	EndIf

	Local $xml = ObjCreate("Microsoft.XMLDOM")
	If Not IsObj($xml) Then
		FileDelete($folder & '\map.xml')
		Return False
	EndIf
	$xml.Async = "false"
	$xml.Load($folder & '\map.xml')

	Local $items = $xml.SelectNodes('/svn/index/dir')
	Local $tag
	For $item In $items
		$tag = $item.GetAttribute("name")
		_consoleWrite('downloading folder ' & $folder & '\' & $tag & @CRLF)
		DirCreate($folder & '/' & $tag)
		If Not _downloadSVNFiles($url & '/' & $tag, $folder & '\' & $tag) Then
			_consoleWrite('download folder failed ' & $folder & '\' & $tag & @CRLF)
			FileDelete($folder & '\map.xml')
			Return False
		EndIf
	Next

	$items = $xml.SelectNodes('/svn/index/file')
	For $item In $items
		$tag = $item.GetAttribute("name")
		_consoleWrite('downloading file ' & $folder & '\' & $tag & @CRLF)
		InetGet($url & '/' & $tag, $folder & '\' & $tag)
		If @error Then
			_consoleWrite('download file failed ' & $folder & '\' & $tag & @CRLF)
			FileDelete($folder & '\map.xml')
			Return False
		EndIf
	Next

	FileDelete($folder & '\map.xml')
	Return True
EndFunc   ;==>_downloadSVNFiles

Func _getScannerVersionList()
	_consoleWrite('正在下载人机命令预编译程序的版本列表，请等待...' & @CRLF)
	InetGet('http://chenxucc:oicqcx1@10.44.20.16/svn/COMM/tags', @ScriptDir & '\map.xml')
	If @error Then
		FileDelete(@ScriptDir & '\map.xml')
		_consoleWrite('下载人机命令预编译程序的版本列表失败！' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
		_writeLog("下载人机命令预编译程序的版本列表失败！InetGet set @error 0")
		Return ''
	EndIf

	Local $xml = ObjCreate("Microsoft.XMLDOM")
	If Not IsObj($xml) Then
		FileDelete(@ScriptDir & '\map.xml')
		_consoleWrite('下载人机命令预编译程序的版本列表失败！' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
		_writeLog("下载人机命令预编译程序的版本列表失败！创建xml失败")
		Return ''
	EndIf
	$xml.Async = "false"
	$xml.Load(@ScriptDir & '\map.xml')

	Local $items = $xml.SelectNodes('/svn/index/dir')
	Local $tag, $item, $version, $arr[1][2] = [[0, 0]]
	For $item In $items
		$tag = $item.GetAttribute("name")
		$version = StringRight($tag, 6)

		;因为只有到I4才有预编译程序，I4的版本号就是100519
		If $version < 100519 Then ContinueLoop

		$arr[0][0] += 1
		ReDim $arr[$arr[0][0] + 1][2]
		$arr[$arr[0][0]][0] = $version
		$arr[$arr[0][0]][1] = $tag
	Next
	_ArraySort($arr, 0, 1)

	Local $i, $result = '', $count = 0
	For $i = 1 To $arr[0][0]
		InetGet('http://chenxucc:oicqcx1@10.44.20.16/svn/COMM/tags/' & $arr[$i][1] & '/client/build/scanner/bin', @ScriptDir & '\map.xml')
		If @error Then
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
		_consoleWrite('下载人机命令预编译程序的版本列表失败！' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
		_writeLog("下载人机命令预编译程序的版本列表失败！下载的xml中，没有版本信息")
		Return ''
	Else
		_consoleWrite('下载人机命令预编译程序的版本列表成功！' & @CRLF & $HORIZONTAL_LINE & @CRLF & @CRLF)
		_writeLog("下载人机命令预编译程序的版本列表成功！")
		If $curScannerVersion == '最新集成版本' Then
			Return '最新集成版本' & $IN_USE & '|最新开发版本|' & StringLeft($result, StringLen($result) - 1)
		ElseIf $curScannerVersion == '最新开发版本' Then
			Return '最新集成版本|最新开发版本' & $IN_USE & '|' & StringLeft($result, StringLen($result) - 1)
		Else
			Return '最新集成版本|最新开发版本|' & StringLeft($result, StringLen($result) - 1)
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

Func _consoleWrite($txt)
	GUICtrlSetData($txtConsole, _GUICtrlEdit_GetText($hConsole) & $txt)
	; 用一个以10位数字命名的文件
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
		;所有文件都是用10位数字命名的，如果无法转换成数字，则认为文件名无效
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
	Return $attr[0] & '年' & $attr[1] & '月' & $attr[2] & '日' & $attr[3] & '点'
EndFunc   ;==>_getCompiledDate

Func _getHelp()
	Local $text = '最近更新：' & _getCompiledDate() & @CRLF & _
			'工具版本：V2.1.1' & @CRLF & _
			'工具作者：陈旭10045812' & @CRLF & @CRLF & FileRead(@ScriptDir & '\使用帮助.txt')
	Return $text
EndFunc   ;==>_getHelp