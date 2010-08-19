#include <A3LScreenCap.au3>
#include "Common.au3"

Opt("MustDeclareVars", 1)
Opt("RunErrorsFatal", 0)

Global $controllers[1] = [0]
Global $direcotries[1] = [0]
Global $controlleeId = ""
Global $currentControllerId = ""
Global $currentControllerDir = ""
Global $LAST_CHECK_SUM = 0

init()
AdlibEnable("wait", 5000)

While 1
	Sleep(100000)
WEnd

Func init()
	Local $count = RegRead($REG_BASE, "RegisteredCount")
	If $count == "" Then
		MsgBox(8208, "远程控制", "无注册控制ID，请注册至少一个控制ID。")
		Exit
	EndIf
	
	$controlleeId = RegRead($REG_BASE, "ControlleeID")
	$controlleeId = InputBox("远程控制","输入当前的被控制ID：", $controlleeId, " ","200","120","-1","-1")
	If $controlleeId == "" Then
		MsgBox(8208, "远程控制", "必须输入一个被控制ID。")
		Exit
	EndIf
	RegWrite($REG_BASE, "ControlleeID", "REG_SZ", $controlleeId)
	
	ReDim $controllers[$count + 1]
	ReDim $direcotries[$count + 1]
	$controllers[0] = $count
	$direcotries[0] = $count
	Local $dir = StringReplace(@AppDataDir, "Application Data", "Local Settings\Application Data") & "\Microsoft\Messenger\"
	Local $i = 0
	For $i = 1 To $count
		$controllers[$i] = RegRead($REG_BASE, "RegisteredControllerID" & $i)
		$direcotries[$i] = $dir & $controlleeId & "\Sharing Folders\" & $controllers[$i] & "\"
	Next
	_ScreenCap_SetJPGQuality(50)
EndFunc

Func wait()
	For $i = 1 To $direcotries[0]
		If FileExists($direcotries[$i] & $FILENAME_START_CONTROL_TRIGGER) Then
			$currentControllerId = $controllers[$i]
			$currentControllerDir = $direcotries[$i]
			FileDelete($currentControllerDir & $FILENAME_START_CONTROL_TRIGGER)
			FileDelete($currentControllerDir & $FILENAME_STOP_CONTROL_TRIGGER)
			FileDelete($currentControllerDir & $FILENAME_PAUSE_CONTROL_TRIGGER)
			FileDelete($currentControllerDir & $FILENAME_SNAPSHOT)
			AdlibDisable()
			TraySetIcon("Shell32.dll", 94)
			AdlibEnable("snapshot", 500)
			Return
		EndIf
	Next
EndFunc

Func snapshot()
	If FileExists($currentControllerDir & $FILENAME_STOP_CONTROL_TRIGGER) Then
		FileDelete($currentControllerDir & $FILENAME_START_CONTROL_TRIGGER)
		FileDelete($currentControllerDir & $FILENAME_STOP_CONTROL_TRIGGER)
		FileDelete($currentControllerDir & $FILENAME_PAUSE_CONTROL_TRIGGER)
		FileDelete($currentControllerDir & $FILENAME_SNAPSHOT)
		AdlibDisable()
		TraySetIcon()
		AdlibEnable("wait", 5000)
		Return
	EndIf
	If FileExists($currentControllerDir & $FILENAME_SNAPSHOT) Or _
		FileExists($currentControllerDir & $FILENAME_PAUSE_CONTROL_TRIGGER) Then
		Return
	EndIf
	Local $sum = PixelChecksum(0, 0, @DesktopWidth, @DesktopHeight)
	If $sum == $LAST_CHECK_SUM Then Return
	$LAST_CHECK_SUM = $sum
	_ScreenCap_Capture($currentControllerDir & $FILENAME_SNAPSHOT)
EndFunc
