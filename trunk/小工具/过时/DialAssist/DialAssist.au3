#include <GUIConstants.au3>
init()

While 1
	$msg = GUIGetMsg()
	Select
		Case $msg = $btnDial
			disableAll()
			$no = getNo()
			If $no == "" Then
				MsgBox(8256, $APP_NAME, "��ѡ��һ����ϵ�ˡ�")
				ContinueLoop
			EndIf
			dial($no)
			enableAll()

		Case $msg = $btnSMS
			$no = getNo()
			If $no == "" Then
				MsgBox(8256, $APP_NAME, "��ѡ��һ����ϵ�ˡ�")
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
		MsgBox(8256, $APP_NAME, "IMδ����...")
		Return
	EndIf
	If Not WinExists("��ʱЭͬ", "���¹���") Then
		Run($IM_PATH & "\IM.exe")
		If WinWaitActive("��ʱЭͬ", "���¹���", 60) == 0 Then
			MsgBox(8256, $APP_NAME, "�޷���IM�����档")
			Return
		EndIf
	Else
		WinActivate("��ʱЭͬ", "���¹���")
	EndIf
	If Not WinExists("�����б�", "�����绰") Then
		$pos = MouseGetPos()
		MouseClick("left", 34, 70, 1, 0)
		MouseMove($pos[0], $pos[1], 0)
		If WinWaitActive("�����б�", "�����绰", 60) == 0 Then
			MsgBox(8256, $APP_NAME, "�޷��򿪺����б���档")
			Return
		EndIf
	Else
		WinActivate("�����б�", "�����绰")
	EndIf
	ControlCommand ("�����б�", "�����绰", "[Instance:2; Class:ComboBox]","SelectString", "���ڳ�;")
	Sleep(100)
	ControlSend("�����б�", "�����绰", "[Instance:1; Class:Edit]", $no)
	Sleep(100)
	ControlSend("�����б�", "�����绰", "", "{ENTER}")
EndFunc

Func sms($no)
	$msg = InputBox($APP_NAME,"������������ݣ����60���֣�����60�����Ժ�����ݻᱻ�ص���",""," ","600","100","-1","-1")
	If $msg == "" Then
		MsgBox(8256, $APP_NAME, "���������Ϣ���ݡ�")
		Return
	EndIf
	If not ProcessExists("IM.exe") Then
		MsgBox(8256, $APP_NAME, "IMδ����...")
		Return
	EndIf
	If Not WinExists("��������", "��������") Then
		If BitAnd(WinGetState("��ʱЭͬ", "���¹���"), 16) Then
			WinSetState("��ʱЭͬ", "���¹���", @SW_RESTORE)
		EndIf
		WinMenuSelectItem("��������", "��������", "����(&T)", "��������(&S)...")
		If WinWaitActive("��������", "��������", 60) == 0 Then
			MsgBox(8256, $APP_NAME, "�޷��򿪶������Ľ��档", 60)
			Return
		EndIf
	Else
		WinActivate("��������", "��������")
	EndIf
	ControlSetText("��������", "��������", "[Class:Edit; Instance:1; ID:1001]", $no)
	Sleep(200)
	ControlSetText("��������", "��������", "[Class:Edit; Instance:2; ID:1685]", $msg)
	Sleep(200)
	ControlClick("��������", "��������", "[Class:Button; Instance:2; ID:1687]")
	$ret = WinWait("IM", "���ŷ��ͳɹ���", 60)
	If $ret <> 0 Then
		TrayTip($APP_NAME, "���ŷ��ͳɹ�", 1200)
	EndIf
	WinClose("IM", "ȷ��")
	Sleep(200)
	WinClose("��������", "��������")
EndFunc

Func init()
	Opt("MouseCoordMode", 0)
	
	Global $APP_NAME = "Dial Assist"
	Global $INI_FILE = "callee.ini"
	Global $IM_PATH = IniRead($INI_FILE, "loginInfo", "imPath", "c:\Program Files\ZTE IM")
	If Not FileExists($IM_PATH & "\IM.exe") Then
		MsgBox(8256, $APP_NAME, "IM·�����ô�����ֱ���޸�callee.ini��imPath��ֵ")
		IniWrite($INI_FILE, "loginInfo", "imPath", "c:\Program Files\ZTE IM")
		Return
	EndIf
	Global $id = IniRead($INI_FILE, "loginInfo", "id", -1)
	Global $pwd = IniRead($INI_FILE, "loginInfo", "pwd", "alongstring")
	If $id == -1 Or $pwd == "alongstring" Then
		MsgBox(8256, $APP_NAME, "��¼��Ϣ������ֱ���޸�callee.ini��id��pwd��ֵ")
		IniWrite($INI_FILE, "loginInfo", "id", -1)
		IniWrite($INI_FILE, "loginInfo", "pwd", "alongstring")
		Return
	EndIf
	
	GUICreate($APP_NAME, 310, 360)
	GUICtrlCreateGroup("����ѡ��", 5, 5, 300, 290)
	Global $callLs = GuiCtrlCreateList("", 10, 20, 200, 270)
	getCallee()
	Global $btnDial = GUICtrlCreateButton("����(&D)", 215, 20, 80, 25)
	Global $btnSMS = GUICtrlCreateButton("����(&S)", 215, 55, 80, 25)
	GUICtrlCreateLabel("�û�����", 215, 105)
	Global $txtName = GUICtrlCreateInput("", 215, 120, 80, 20)
	GUICtrlCreateLabel("���룺", 215, 145)
	Global $txtNo = GUICtrlCreateInput("", 215, 160, 80, 20)
	Global $btnQuickDial = GUICtrlCreateButton("���ٲ���(&Q)", 215, 190, 80, 25)
	Global $btnAdd = GUICtrlCreateButton("����ϵ��(&A)", 215, 225, 80, 25)
	Global $btnDel = GUICtrlCreateButton("ɾ��ϵ��(&R)", 215, 260, 80, 25)
	
	GUICtrlCreateGroup("IMѡ��", 5, 300, 300, 55)
	Global $btnRunIM = GUICtrlCreateButton("����IM", 20, 320, 80, 25)
	Global $btnKillIM = GUICtrlCreateButton("ɱ��IM", 115, 320, 80, 25)
	Global $btnRestartIM = GUICtrlCreateButton("����IM", 210, 320, 80, 25)
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
		MsgBox(8256, $APP_NAME, "��������һ�����롣")
		Return
	EndIf
	If $name == "" Then $name = "unkown"
	$count = IniRead($INI_FILE, "calleeInfo", "callees", "0")
;~ 	If $count == 0 Then
;~ 		MsgBox(8256, $APP_NAME, "�����ļ����ܳ������顣")
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
		MsgBox(8256, $APP_NAME, "��ѡ��һ����ϵ�ˡ�")
		Return
	EndIf
	$n = StringInStr($txt, "-", 0, -1)
	$no = StringStripWS(StringMid($txt, $n + 1), 1 + 2)
	$name = StringStripWS(StringLeft($txt, $n - 1), 1 + 2)
	
	$count = IniRead($INI_FILE, "calleeInfo", "callees", 0)
	If $count == 0 Then
		MsgBox(8256, $APP_NAME, "�����ļ����ܳ������顣")
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
		MsgBox(8256, $APP_NAME, "������һ�����롣")
		Return
	EndIf
	dial($no)
EndFunc

Func runIM($flag = True)
	If ProcessExists("IM.exe") And $flag Then
		MsgBox(8256, $APP_NAME, "IM������...")
		Return
	EndIf
	Run($IM_PATH & "\IM.exe")
	WinWait("��ʱЭͬ", "����(&S)", 60)
	ControlSend("��ʱЭͬ", "����(&S)", "[Class:Button; Instance:1; ID:1081]", "{ENTER}")
	WinWait("��¼", "�û�����", 60)
;~ 	ControlSetText("��¼", "�û�����", "[Class:Edit; Instance:1; ID:1001]", "{DEL 6}")
	ControlSetText("��¼", "�û�����", "[Class:Edit; Instance:1; ID:1001]", $id)
	ControlSetText("��¼", "��  �", "[Class:Edit; Instance:2; ID:1015]", $pwd)
	ControlSend("��¼", "ȷ��", "[Class:Button; Instance:5; ID:1]", "{ENTER}")
	WinWait("��ʱЭͬ", "���¹���", 60)
	If $flag Then
		MsgBox(8256, $APP_NAME, "IM������ϣ�", 5)
	EndIf
EndFunc

Func killIM($flag = True)
	If Not ProcessExists("IM.exe") And $flag Then
		MsgBox(8256, $APP_NAME, "IMδ����...")
		Return
	EndIf
	If Not WinExists("��ʱЭͬ", "���¹���") Then
		Run($IM_PATH & "\IM.exe")
		If WinWaitActive("��ʱЭͬ", "���¹���", 60) == 0 Then
			MsgBox(8256, $APP_NAME, "�޷���IM�����档")
			Return
		EndIf
	Else
		WinActivate("��ʱЭͬ", "���¹���")
	EndIf
	Sleep(200)
	WinMenuSelectItem("��ʱЭͬ", "���¹���", "�ļ�(&F)", "�˳�(&X)")
	WinWait("ϵͳ��ʾ", "ȷ���˳���ʱЭͬ��", 60)
	Sleep(400)
	ControlSend("ϵͳ��ʾ", "ȷ���˳���ʱЭͬ��", "[Text:��(&Y)]", "{ENTER}")
	ProcessWaitClose("IM.exe", 60)
	If $flag Then
		MsgBox(8256, $APP_NAME, "IM�Ѿ��˳���", 5)
	EndIf
EndFunc

Func restartIM()
	killIM(False)
	runIM()
EndFunc




