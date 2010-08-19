
Opt("TrayMenuMode",1)
Opt("MustDeclareVars",1)
FileChangeDir (@ScriptDir)

#Region global var
Global Const $TMP_HTML_FILE = @TempDir & "\preview_of_brief_manager.html"
Global Const $APP_TITLE = "缩略语管理器"
Global Const $SEARCH_DEFAULT_TEXT = "Google一把"
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
Global Const $UPDATED_DATE = "2008年9月26日"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 版本历史
; 
; 4、20080926 2.2.1 添加了3个比较大的功能：替换自动生成缩略语链接、编辑图片功能、
;    完成了“关于”功能，并且决定把版本变更的历史记录到源代码中。
;    同时优化了代码结果，优化了部分实现，修改了几个bug
; 3、20080912 2.0.2 修改了一些bug，优化了新建、修改的流程；优化了编辑器的功能
; 2、20080816 2.0.1 实现了同步功能，自动搜索自上次同步以来的修改过的缩略语条目，
;    并且自动打成zip包，方便携带到别的电脑上进行同步。
; 1、20080806 2.0   新建。在缩略语管理器1.0的基础上新建，实现html查看管理缩略语；
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#EndRegion
;

If _Singleton("brief_manager", 1) == 0 Then
	WinActivate($APP_TITLE, "缩略语(SPACE)：")
	Exit
EndIf

#Region gui set layout
Global $gui = GUICreate($APP_TITLE, $GUI_WIDTH, $GUI_HEIGH, Default, Default, _
	$WS_MAXIMIZEBOX + $WS_MINIMIZEBOX + $WS_SIZEBOX)
GUICtrlCreateLabel( "缩略语(SPACE)：", 5, 5)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
Global $txt_brief = GUICtrlCreateCombo("", 1, 20, 116, 21)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "待检索的缩略语。")
Global $ls_brief = GUICtrlCreateList("", 0, 43, 118, $GUI_HEIGH - 75)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
$hBrief = GUICtrlGetHandle($txt_brief)
GUICtrlCreateLabel("含义：", 120, 5)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
Global $btn_backward = GUICtrlCreateButton("退", 120, 44, 20, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "后退到前一个缩略语 (Alt+←)")
Global $btn_forward = GUICtrlCreateButton("进", 142, 44, 20, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "前进到下一个缩略语 (Alt+→)")
Global $btn_new = GUICtrlCreateButton("新建", 170, 44, 40, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "新建一个缩略语 (F2)")
Global $btn_mod = GUICtrlCreateButton("修改", 212, 44, 40, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "修改当前缩略语详细描述 (F3)")
Global $btn_del = GUICtrlCreateButton("删除", 254, 44, 40, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "删除当前缩略语 (F4)")
Global $btn_editPic = GUICtrlCreateButton("编辑图片", 296, 44, 60, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "修改当前缩略语所包含的图片")
Global $btn_setOnTop = GUICtrlCreateButton("置顶", 364, 44, 40, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "置顶/取消置顶窗口 Ctrl+T")
Global $txt_search = GUICtrlCreateInput($SEARCH_DEFAULT_TEXT, 413, 44, 116, 21)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "搜索一下Google")
Global $btn_search = GUICtrlCreateButton("搜索", 533, 44, 40, 20)
GUICtrlSetTip(-1, "搜索一下Google")
GUICtrlSetResizing(-1, $GUI_DOCKALL)
Global $txt_explain  = GUICtrlCreateInput("", 120, 20, 409, 21, $ES_READONLY)
GUICtrlSetTip(-1, "缩略语的含义。")
GUICtrlSetResizing(-1, $GUI_DOCKALL)
Global $btn_modExp = GUICtrlCreateButton("修改", 533, 20, 40, 20)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetTip(-1, "修改缩略语的含义。")
GUICtrlSetResizing(-1, $GUI_DOCKALL)
_IEErrorHandlerRegister ()
Global $obj_IE = _IECreateEmbedded ()
Global $obj_description  =  GUICtrlCreateObj($obj_IE, 120, 67, $GUI_WIDTH - 120, $GUI_HEIGH - 106)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
;创建任务栏菜单
Global $tm_about = TrayCreateItem("关于")
TrayCreateItem("")
Global $tm_quit = TrayCreateItem("退出")
;创建列表菜单
Global $cm_brief = GUICtrlCreateContextMenu($ls_brief)
Global $cm_add = GUICtrlCreateMenuItem("添加缩略语　F2", $cm_brief)
Global $cm_del = GUICtrlCreateMenuItem("删除缩略语　F4", $cm_brief)
GUICtrlCreateMenuItem("", $cm_brief)
Global $cm_mod = GUICtrlCreateMenuItem("修改详细描述　F3", $cm_brief)
Global $cm_modName = GUICtrlCreateMenuItem("修改名称", $cm_brief)
Global $cm_modExp = GUICtrlCreateMenuItem("修改含义", $cm_brief)
;创建主菜单
Global $m_edit = GUICtrlCreateMenu ("编辑(&E)")
Global $m_add = GUICtrlCreateMenuitem ("添加缩略语　F2", $m_edit)
Global $m_del = GUICtrlCreateMenuitem ("删除缩略语　F4", $m_edit)
GUICtrlCreateMenuitem ("", $m_edit)
Global $m_mod = GUICtrlCreateMenuitem ("修改缩略语描述　F3", $m_edit)
Global $m_modName = GUICtrlCreateMenuitem("修改缩略语名称", $m_edit)
Global $m_modExp = GUICtrlCreateMenuitem("修改缩略语含义", $m_edit)
GUICtrlCreateMenuitem("", $m_edit)
Global $m_quit = GUICtrlCreateMenuitem ("退出", $m_edit)
Global $m_tool = GUICtrlCreateMenu ("工具(&T)")
Global $m_ontop = GUICtrlCreateMenuitem ("置顶窗口(&T)　Ctrl+T", $m_tool)
GUICtrlCreateMenuitem ("", $m_tool)
Global $m_syc = GUICtrlCreateMenu ("同步(&S)", $m_tool)
Global $m_packChanged = GUICtrlCreateMenuitem ("打包有变化的条目(&C)", $m_syc)
Global $m_packAll = GUICtrlCreateMenuitem ("打包所有条目(&A)", $m_syc)
Global $m_merge = GUICtrlCreateMenuItem("合并缩略语文件(&M)...", $m_tool)
GUICtrlCreateMenuitem("", $m_tool)
Global $m_help = GUICtrlCreateMenuitem ("帮助(&H)", $m_tool)
TraySetToolTip ("管理、检索、再学习缩略语。")

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


