#include <GUIConstants.au3>
init()

While 1
	$msg = GUIGetMsg()
	Select
		Case $msg = $btnDial
			disableAll()
			$no = getNo()
			If $no == "" Then
				MsgBox(8256, $APP_NAME, "请选择一个联系人。")
				ContinueLoop
			EndIf
			dial($no)
			enableAll()

		Case $msg = $btnSMS
			$no = getNo()
			If $no == "" Then
				MsgBox(8256, $APP_NAME, "请选择一个联系人。")
				ContinueLoop
			EndIf
			sms($no)
			
		Case $msg = $btnQuickDial
			disableAll()
			quickDial()
			enableAll()
			
		Case $msg = $btnAdd
			addContact()
			
		Case $msg = $btnDel
			delContact()
			
		Case $msg = $btnRunIM
			disableAll()
			runIM()
			enableAll()
			
		Case $msg = $btnKillIM
			disableAll()
			killIM()
			enableAll()
			
		Case $msg = $btnRestartIM
			disableAll()
			restartIM()
			enableAll()
		
		Case $msg = $GUI_EVENT_CLOSE
			ExitLoop
		
	EndSelect
WEnd


Func dial($no)
	If not ProcessExists("IM.exe") Then
		MsgBox(8256, $APP_NAME, "IM未运行...")
		Return
	EndIf
	If Not WinExists("即时协同", "人事管理") Then
		Run($IM_PATH & "\IM.exe")
		If WinWaitActive("即时协同", "人事管理", 60) == 0 Then
			MsgBox(8256, $APP_NAME, "无法打开IM主界面。")
			Return
		EndIf
	Else
		WinActivate("即时协同", "人事管理")
	EndIf
	If Not WinExists("呼叫列表", "单方电话") Then
		$pos = MouseGetPos()
		MouseClick("left", 34, 70, 1, 0)
		MouseMove($pos[0], $pos[1], 0)
		If WinWaitActive("呼叫列表", "单方电话", 60) == 0 Then
			MsgBox(8256, $APP_NAME, "无法打开呼叫列表界面。")
			Return
		EndIf
	Else
		WinActivate("呼叫列表", "单方电话")
	EndIf
	ControlCommand ("呼叫列表", "单方电话", "[Instance:2; Class:ComboBox]","SelectString", "国内长途")
	Sleep(100)
	ControlSend("呼叫列表", "单方电话", "[Instance:1; Class:Edit]", $no)
	Sleep(100)
	ControlSend("呼叫列表", "单方电话", "", "{ENTER}")
EndFunc

Func sms($no)
	$msg = InputBox($APP_NAME,"请输入短信内容，最多60个字，多于60个字以后的内容会被截掉。",""," ","600","100","-1","-1")
	If $msg == "" Then
		MsgBox(8256, $APP_NAME, "请输入短消息内容。")
		Return
	EndIf
	If not ProcessExists("IM.exe") Then
		MsgBox(8256, $APP_NAME, "IM未运行...")
		Return
	EndIf
	If Not WinExists("短信中心", "短信中心") Then
		If BitAnd(WinGetState("即时协同", "人事管理"), 16) Then
			WinSetState("即时协同", "人事管理", @SW_RESTORE)
		EndIf
		WinMenuSelectItem("短信中心", "短信中心", "工具(&T)", "短信中心(&S)...")
		If WinWaitActive("短信中心", "短信中心", 60) == 0 Then
			MsgBox(8256, $APP_NAME, "无法打开短信中心界面。", 60)
			Return
		EndIf
	Else
		WinActivate("短信中心", "短信中心")
	EndIf
	ControlSetText("短信中心", "短信中心", "[Class:Edit; Instance:1; ID:1001]", $no)
	Sleep(200)
	ControlSetText("短信中心", "短信中心", "[Class:Edit; Instance:2; ID:1685]", $msg)
	Sleep(200)
	ControlClick("短信中心", "短信中心", "[Class:Button; Instance:2; ID:1687]")
	$ret = WinWait("IM", "短信发送成功。", 60)
	If $ret <> 0 Then
		TrayTip($APP_NAME, "短信发送成功", 1200)
	EndIf
	WinClose("IM", "确定")
	Sleep(200)
	WinClose("短信中心", "短信中心")
EndFunc

Func init()
	Opt("MouseCoordMode", 0)
	
	Global $APP_NAME = "Dial Assist"
	Global $INI_FILE = "callee.ini"
	Global $IM_PATH = IniRead($INI_FILE, "loginInfo", "imPath", "c:\Program Files\ZTE IM")
	If Not FileExists($IM_PATH & "\IM.exe") Then
		MsgBox(8256, $APP_NAME, "IM路径配置错误，请直接修改callee.ini的imPath的值")
		IniWrite($INI_FILE, "loginInfo", "imPath", "c:\Program Files\ZTE IM")
		Return
	EndIf
	Global $id = IniRead($INI_FILE, "loginInfo", "id", -1)
	Global $pwd = IniRead($INI_FILE, "loginInfo", "pwd", "alongstring")
	If $id == -1 Or $pwd == "alongstring" Then
		MsgBox(8256, $APP_NAME, "登录信息有误，请直接修改callee.ini的id和pwd的值")
		IniWrite($INI_FILE, "loginInfo", "id", -1)
		IniWrite($INI_FILE, "loginInfo", "pwd", "alongstring")
		Return
	EndIf
	
	GUICreate($APP_NAME, 310, 360)
	GUICtrlCreateGroup("拨号选项", 5, 5, 300, 290)
	Global $callLs = GuiCtrlCreateList("", 10, 20, 200, 270)
	getCallee()
	Global $btnDial = GUICtrlCreateButton("拨号(&D)", 215, 20, 80, 25)
	Global $btnSMS = GUICtrlCreateButton("短信(&S)", 215, 55, 80, 25)
	GUICtrlCreateLabel("用户名：", 215, 105)
	Global $txtName = GUICtrlCreateInput("", 215, 120, 80, 20)
	GUICtrlCreateLabel("号码：", 215, 145)
	Global $txtNo = GUICtrlCreateInput("", 215, 160, 80, 20)
	Global $btnQuickDial = GUICtrlCreateButton("快速拨号(&Q)", 215, 190, 80, 25)
	Global $btnAdd = GUICtrlCreateButton("增联系人(&A)", 215, 225, 80, 25)
	Global $btnDel = GUICtrlCreateButton("删联系人(&R)", 215, 260, 80, 25)
	
	GUICtrlCreateGroup("IM选项", 5, 300, 300, 55)
	Global $btnRunIM = GUICtrlCreateButton("启动IM", 20, 320, 80, 25)
	Global $btnKillIM = GUICtrlCreateButton("杀掉IM", 115, 320, 80, 25)
	Global $btnRestartIM = GUICtrlCreateButton("重启IM", 210, 320, 80, 25)
	GUISetState ()
EndFunc

Func enableAll()
	GUICtrlSetState($btnDial, $GUI_ENABLE)
	GUICtrlSetState($btnSMS, $GUI_ENABLE)
	GUICtrlSetState($txtName, $GUI_ENABLE)
	GUICtrlSetState($txtNo, $GUI_ENABLE)
	GUICtrlSetState($btnQuickDial, $GUI_ENABLE)
	GUICtrlSetState($btnAdd, $GUI_ENABLE)
	GUICtrlSetState($btnDel, $GUI_ENABLE)
	
	GUICtrlSetState($btnRunIM, $GUI_ENABLE)
	GUICtrlSetState($btnKillIM, $GUI_ENABLE)
	GUICtrlSetState($btnRestartIM, $GUI_ENABLE)
EndFunc

Func disableAll()
	GUICtrlSetState($btnDial, $GUI_DISABLE)
	GUICtrlSetState($btnSMS, $GUI_DISABLE)
	GUICtrlSetState($txtName, $GUI_DISABLE)
	GUICtrlSetState($txtNo, $GUI_DISABLE)
	GUICtrlSetState($btnQuickDial, $GUI_DISABLE)
	GUICtrlSetState($btnAdd, $GUI_DISABLE)
	GUICtrlSetState($btnDel, $GUI_DISABLE)
	
	GUICtrlSetState($btnRunIM, $GUI_DISABLE)
	GUICtrlSetState($btnKillIM, $GUI_DISABLE)
	GUICtrlSetState($btnRestartIM, $GUI_DISABLE)
EndFunc

Func getCallee()
	$callees = IniRead($INI_FILE, "calleeInfo", "callees", 0)
	
	For $i = 1 To $callees
		$calleeName = IniRead($INI_FILE, "calleeInfo", "calleeName" & $i, "unkown")
		$calleeNo = IniRead($INI_FILE, "calleeInfo", "calleeNo" & $i, "")
		GUICtrlSetData($callLs, $calleeName & " - " & $calleeNo)
	Next
EndFunc

Func getNo()
	$txt = GUICtrlRead($callLs)
	$n = StringInStr($txt, "-", 0, -1)
	Return StringStripWS(StringMid($txt, $n + 1), 1 + 2)
EndFunc

Func addContact()
	$name = GUICtrlRead($txtName)
	$no = GUICtrlRead($txtNo)
	
	If $no == "" Then
		MsgBox(8256, $APP_NAME, "至少输入一个号码。")
		Return
	EndIf
	If $name == "" Then $name = "unkown"
	$count = IniRead($INI_FILE, "calleeInfo", "callees", "0")
;~ 	If $count == 0 Then
;~ 		MsgBox(8256, $APP_NAME, "配置文件可能出错，请检查。")
;~ 		Return
;~ 	EndIf
	$count = $count + 1
	IniWrite($INI_FILE, "calleeInfo", "callees", $count)
	IniWrite($INI_FILE, "calleeInfo", "calleeName" & $count, $name)
	IniWrite($INI_FILE, "calleeInfo", "calleeNo" & $count, $no)
	
	GUICtrlSetData($callLs, $name & " - " & $no)
EndFunc

Func delContact()
	$txt = GUICtrlRead($callLs)
	If $txt == "" Then
		MsgBox(8256, $APP_NAME, "请选择一个联系人。")
		Return
	EndIf
	$n = StringInStr($txt, "-", 0, -1)
	$no = StringStripWS(StringMid($txt, $n + 1), 1 + 2)
	$name = StringStripWS(StringLeft($txt, $n - 1), 1 + 2)
	
	$count = IniRead($INI_FILE, "calleeInfo", "callees", 0)
	If $count == 0 Then
		MsgBox(8256, $APP_NAME, "配置文件可能出错，请检查。")
		Return
	EndIf
	$flag = False
	For $i = 1 To $count
		$calleeName = IniRead($INI_FILE, "calleeInfo", "calleeName" & $i, "unkown")
		$calleeNo = IniRead($INI_FILE, "calleeInfo", "calleeNo" & $i, "")
		If $flag Then
			IniWrite($INI_FILE, "calleeInfo", "calleeName" & ($i - 1), $calleeName)
			IniWrite($INI_FILE, "calleeInfo", "calleeNo" & ($i - 1), $calleeNo)
		EndIf
		If $calleeName == $name And $calleeNo == $no Then
			$flag = True
		EndIf
	Next
	IniDelete($INI_FILE, "calleeInfo", "calleeName" & $count)
	IniDelete($INI_FILE, "calleeInfo", "calleeNo" & $count)
	$count = $count - 1
	IniWrite($INI_FILE, "calleeInfo", "callees", $count)
	
	For $i = 1 To $count + 1
		GUICtrlSetData($callLs, "")
	Next
	getCallee()
EndFunc

Func quickDial()
	$no = GUICtrlRead($txtNo)
	If $no == "" Then
		MsgBox(8256, $APP_NAME, "请输入一个号码。")
		Return
	EndIf
	dial($no)
EndFunc

Func runIM($flag = True)
	If ProcessExists("IM.exe") And $flag Then
		MsgBox(8256, $APP_NAME, "IM已运行...")
		Return
	EndIf
	Run($IM_PATH & "\IM.exe")
	WinWait("即时协同", "中文(&S)", 60)
	ControlSend("即时协同", "中文(&S)", "[Class:Button; Instance:1; ID:1081]", "{ENTER}")
	WinWait("登录", "用户名：", 60)
;~ 	ControlSetText("登录", "用户名：", "[Class:Edit; Instance:1; ID:1001]", "{DEL 6}")
	ControlSetText("登录", "用户名：", "[Class:Edit; Instance:1; ID:1001]", $id)
	ControlSetText("登录", "口  令：", "[Class:Edit; Instance:2; ID:1015]", $pwd)
	ControlSend("登录", "确定", "[Class:Button; Instance:5; ID:1]", "{ENTER}")
	WinWait("即时协同", "人事管理", 60)
	If $flag Then
		MsgBox(8256, $APP_NAME, "IM启动完毕！", 5)
	EndIf
EndFunc

Func killIM($flag = True)
	If Not ProcessExists("IM.exe") And $flag Then
		MsgBox(8256, $APP_NAME, "IM未运行...")
		Return
	EndIf
	If Not WinExists("即时协同", "人事管理") Then
		Run($IM_PATH & "\IM.exe")
		If WinWaitActive("即时协同", "人事管理", 60) == 0 Then
			MsgBox(8256, $APP_NAME, "无法打开IM主界面。")
			Return
		EndIf
	Else
		WinActivate("即时协同", "人事管理")
	EndIf
	Sleep(200)
	WinMenuSelectItem("即时协同", "人事管理", "文件(&F)", "退出(&X)")
	WinWait("系统提示", "确定退出即时协同？", 60)
	Sleep(400)
	ControlSend("系统提示", "确定退出即时协同？", "[Text:是(&Y)]", "{ENTER}")
	ProcessWaitClose("IM.exe", 60)
	If $flag Then
		MsgBox(8256, $APP_NAME, "IM已经退出！", 5)
	EndIf
EndFunc

Func restartIM()
	killIM(False)
	runIM()
EndFunc




