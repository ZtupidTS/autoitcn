
Opt("TrayMenuMode",1)
Opt("MustDeclareVars",1)
FileChangeDir (@ScriptDir)

#Region global var
Global Const $TMP_HTML_FILE = @TempDir & "\preview_of_brief_manager.html"
Global Const $APP_TITLE = "�����������"
Global Const $SEARCH_DEFAULT_TEXT = "Googleһ��"
Global Const $GUI_WIDTH = 800
Global Const $GUI_HEIGH = 604
Global Const $MAX_LIST_DISP = 800
Global Const $LISTEN_INTERVAL = 300
Global Const $DIALOG_MODE_ADD = "ADD"
Global Const $DIALOG_MODE_MOD = "MOD"
Global Const $EDIT_PICTURE_MODE_MAIN = "$EDIT_PICTURE_MODE_MAIN"
Global Const $EDIT_PICTURE_MODE_EDITOR = "$EDIT_PICTURE_MODE_EDITOR"
Global Const $COMMON_HTML = _
	"<head>" & @CRLF & _
	"	<title>%s</title>" & @CRLF & _
	"</head>" & @CRLF & _
	"<body>" & @CRLF & _
	"%s" & @CRLF & _
	"</body>" & @CRLF & _
	"</html>"

Global $dataFile
Global $data[1]
Global $lastListenedBrief = ""
Global $lastListenedUrl = ""
Global $nMsg
Global $listenPageURLCount = 0
Global $listBuff[1]
Global $hBrief
Global $DATA_INI = @ScriptDir & "\data.ini"

Global Const $VERSION = "2.2.1"
Global Const $UPDATED_DATE = "2008��9��26��"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �汾��ʷ
; 
; 4��20080926 2.2.1 �����3���Ƚϴ�Ĺ��ܣ��滻�Զ��������������ӡ��༭ͼƬ���ܡ�
;    ����ˡ����ڡ����ܣ����Ҿ����Ѱ汾�������ʷ��¼��Դ�����С�
;    ͬʱ�Ż��˴��������Ż��˲���ʵ�֣��޸��˼���bug
; 3��20080912 2.0.2 �޸���һЩbug���Ż����½����޸ĵ����̣��Ż��˱༭���Ĺ���
; 2��20080816 2.0.1 ʵ����ͬ�����ܣ��Զ��������ϴ�ͬ���������޸Ĺ�����������Ŀ��
;    �����Զ����zip��������Я������ĵ����Ͻ���ͬ����
; 1��20080806 2.0   �½����������������1.0�Ļ������½���ʵ��html�鿴���������
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#EndRegion
;

If _Singleton("brief_manager", 1) == 0 Then
	WinActivate($APP_TITLE, "������(SPACE)��")
	Exit
EndIf

#Region gui set layout
Global $gui = GUICreate($APP_TITLE, $GUI_WIDTH, $GUI_HEIGH, Default, Default, _
	$WS_MAXIMIZEBOX + $WS_MINIMIZEBOX + $WS_SIZEBOX)
GUICtrlCreateLabel( "������(SPACE)��", 5, 5)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
Global $txt_brief = GUICtrlCreateCombo("", 1, 20, 116, 21)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "�������������")
Global $ls_brief = GUICtrlCreateList("", 0, 43, 118, $GUI_HEIGH - 75)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
$hBrief = GUICtrlGetHandle($txt_brief)
GUICtrlCreateLabel("���壺", 120, 5)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
Global $btn_backward = GUICtrlCreateButton("��", 120, 44, 20, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "���˵�ǰһ�������� (Alt+��)")
Global $btn_forward = GUICtrlCreateButton("��", 142, 44, 20, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "ǰ������һ�������� (Alt+��)")
Global $btn_new = GUICtrlCreateButton("�½�", 170, 44, 40, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "�½�һ�������� (F2)")
Global $btn_mod = GUICtrlCreateButton("�޸�", 212, 44, 40, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "�޸ĵ�ǰ��������ϸ���� (F3)")
Global $btn_del = GUICtrlCreateButton("ɾ��", 254, 44, 40, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "ɾ����ǰ������ (F4)")
Global $btn_editPic = GUICtrlCreateButton("�༭ͼƬ", 296, 44, 60, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "�޸ĵ�ǰ��������������ͼƬ")
Global $btn_setOnTop = GUICtrlCreateButton("�ö�", 364, 44, 40, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "�ö�/ȡ���ö����� Ctrl+T")
Global $txt_search = GUICtrlCreateInput($SEARCH_DEFAULT_TEXT, 413, 44, 116, 21)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "����һ��Google")
Global $btn_search = GUICtrlCreateButton("����", 533, 44, 40, 20)
GUICtrlSetTip(-1, "����һ��Google")
GUICtrlSetResizing(-1, $GUI_DOCKALL)
Global $txt_explain  = GUICtrlCreateInput("", 120, 20, 409, 21, $ES_READONLY)
GUICtrlSetTip(-1, "������ĺ��塣")
GUICtrlSetResizing(-1, $GUI_DOCKALL)
Global $btn_modExp = GUICtrlCreateButton("�޸�", 533, 20, 40, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "�޸�������ĺ��塣")
GUICtrlSetResizing(-1, $GUI_DOCKALL)
_IEErrorHandlerRegister ()
Global $obj_IE = _IECreateEmbedded ()
Global $obj_description  =  GUICtrlCreateObj($obj_IE, 120, 67, $GUI_WIDTH - 120, $GUI_HEIGH - 106)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
;�����������˵�
Global $tm_about = TrayCreateItem("����")
TrayCreateItem("")
Global $tm_quit = TrayCreateItem("�˳�")
;�����б�˵�
Global $cm_brief = GUICtrlCreateContextMenu($ls_brief)
Global $cm_add = GUICtrlCreateMenuItem("��������F2", $cm_brief)
Global $cm_del = GUICtrlCreateMenuItem("ɾ�������F4", $cm_brief)
GUICtrlCreateMenuItem("", $cm_brief)
Global $cm_mod = GUICtrlCreateMenuItem("�޸���ϸ������F3", $cm_brief)
Global $cm_modName = GUICtrlCreateMenuItem("�޸�����", $cm_brief)
Global $cm_modExp = GUICtrlCreateMenuItem("�޸ĺ���", $cm_brief)
;�������˵�
Global $m_edit = GUICtrlCreateMenu ("�༭(&E)")
Global $m_add = GUICtrlCreateMenuitem ("��������F2", $m_edit)
Global $m_del = GUICtrlCreateMenuitem ("ɾ�������F4", $m_edit)
GUICtrlCreateMenuitem ("", $m_edit)
Global $m_mod = GUICtrlCreateMenuitem ("�޸�������������F3", $m_edit)
Global $m_modName = GUICtrlCreateMenuitem("�޸�����������", $m_edit)
Global $m_modExp = GUICtrlCreateMenuitem("�޸������ﺬ��", $m_edit)
GUICtrlCreateMenuitem("", $m_edit)
Global $m_quit = GUICtrlCreateMenuitem ("�˳�", $m_edit)
Global $m_tool = GUICtrlCreateMenu ("����(&T)")
Global $m_ontop = GUICtrlCreateMenuitem ("�ö�����(&T)��Ctrl+T", $m_tool)
GUICtrlCreateMenuitem ("", $m_tool)
Global $m_syc = GUICtrlCreateMenu ("ͬ��(&S)", $m_tool)
Global $m_packChanged = GUICtrlCreateMenuitem ("����б仯����Ŀ(&C)", $m_syc)
Global $m_packAll = GUICtrlCreateMenuitem ("���������Ŀ(&A)", $m_syc)
Global $m_merge = GUICtrlCreateMenuItem("�ϲ��������ļ�(&M)...", $m_tool)
GUICtrlCreateMenuitem("", $m_tool)
Global $m_help = GUICtrlCreateMenuitem ("����(&H)", $m_tool)
TraySetToolTip ("������������ѧϰ�����")

Global $dm_brief = GUICtrlCreateDummy()
Global $dm_esc = GUICtrlCreateDummy()
Global $dm_enter = GUICtrlCreateDummy()
Global $dm_down = GUICtrlCreateDummy()
Global $dm_up = GUICtrlCreateDummy()
Global $hotKeys[11][2] = _
	[["{space}", $dm_brief    ], _
	["{esc}",    $dm_esc      ], _
	["{enter}",  $dm_enter    ], _
	["{F2}",     $m_add       ], _
	["{F3}",     $m_mod       ], _
	["{F4}",     $m_del       ], _
	["!{left}",  $btn_backward], _
	["!{right}", $btn_forward ], _
	["{down}",   $dm_down     ], _
	["{up}",     $dm_up       ], _
	["^t",       $m_ontop]]
GUISetAccelerators($hotKeys, $gui)
GUISetState(@SW_SHOW)
#EndRegion
;


