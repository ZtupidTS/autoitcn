
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <GUIConstants.au3>
#include <Array.au3>
#include "include\common.au3"

Global Const $CELL_LEFT = 103
Global Const $CELL_TOP = 32
Global Const $CELL_WIDTH = 80
Global Const $CELL_HIGH = 20
Global Const $CELL_STYLE = $SS_CENTER + $SS_CENTERIMAGE + $WS_BORDER
Global Const $CELL_STYLE_SEL = $CELL_STYLE + $SS_SUNKEN

Global Const $CLR_SELECTED = 0xFFCCFD
Global Const $CLR_DPT1_CONF1 = 0xFFCC99

Global $selCells[1][2] = [[0, 0]]
Global $lbl_sel

Global $Form1 = GUICreate($APP_NAME, 800, 600)
_createBkCells()
Global $btn_occupy = GUICtrlCreateButton("占用(&Z)", 670, 32, 90, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $btn_release = GUICtrlCreateButton("释放(&S)", 670, 60, 90, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $btn_unsel = GUICtrlCreateButton("取消选择(ESC)", 670, 87, 90, 25)
GUICtrlSetOnEvent(-1, "handleESC")
GUICtrlSetState(-1, $GUI_DISABLE)
GUISetOnEvent($GUI_EVENT_CLOSE, "quit")

Global $hk[1][2] = [["{esc}", $btn_unsel]]
GUISetAccelerators($hk)
GUISetState(@SW_SHOW)

While 1
	Sleep(2000)
WEnd

Func _createBkCells()
	Local $left = $CELL_LEFT, $top = 32
	#Region 日前，时间
	GUICtrlCreateLabel("时间§日期", 8, $top-1, 95, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("上", -1, $top, 16, ($CELL_HIGH - 1)*8 + 1, $CELL_STYLE)
	GUICtrlCreateLabel("08:30-09:00", 23, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("09:00-09:30", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("09:30-10:00", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("10:00-10:30", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("10:30-11:00", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("11:00-11:30", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("11:30-12:00", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("12:00-12:30", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	
	$top += $CELL_HIGH
	GUICtrlCreateLabel("中", 8, $top, 16, ($CELL_HIGH - 1)*2 + 1, $CELL_STYLE)
	
	GUICtrlCreateLabel("13:00-13:30", 23, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("13:30-14:00", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	
	$top += $CELL_HIGH
	GUICtrlCreateLabel("下", 8, $top, 16, ($CELL_HIGH - 1)*7 + 1, $CELL_STYLE)
	GUICtrlCreateLabel("14:00-14:30", 23, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("14:30-15:00", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("15:00-15:30", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("15:30-16:00", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("16:00-16:30", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("16:30-17:00", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("17:00-17:30", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	
	$top += $CELL_HIGH
	GUICtrlCreateLabel("晚", 8, $top, 16, $CELL_HIGH, $CELL_STYLE)
	GUICtrlCreateLabel("18:30-20:00", 23, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	#EndRegion
	
	#Region 周一
	$top = $CELL_TOP
	GUICtrlCreateLabel("周一", $left, $top-1, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("一部配置一室", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	GUICtrlSetBkColor(-1, $CLR_DPT1_CONF1)
	GUICtrlSetOnEvent(-1, "cellClicked_1_2")
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("一部配置一室", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	GUICtrlSetBkColor(-1, $CLR_DPT1_CONF1)
	GUICtrlSetOnEvent(-1, "cellClicked_1_3")
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("一部配置一室", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	GUICtrlSetBkColor(-1, $CLR_DPT1_CONF1)
	GUICtrlSetOnEvent(-1, "cellClicked_1_4")
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	#EndRegion
	
	#Region 周二
	$left += $CELL_WIDTH - 1
	$top = $CELL_TOP
	GUICtrlCreateLabel("周二", $left, $top-1, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("一部配置一室", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	GUICtrlSetBkColor(-1, $CLR_DPT1_CONF1)
	GUICtrlSetOnEvent(-1, "cellClicked_2_14")
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("一部配置一室", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	GUICtrlSetBkColor(-1, $CLR_DPT1_CONF1)
	GUICtrlSetOnEvent(-1, "cellClicked_2_15")
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("一部配置一室", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	GUICtrlSetBkColor(-1, $CLR_DPT1_CONF1)
	GUICtrlSetOnEvent(-1, "cellClicked_2_16")
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("一部配置一室", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	GUICtrlSetBkColor(-1, $CLR_DPT1_CONF1)
	GUICtrlSetOnEvent(-1, "cellClicked_2_17")
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	#EndRegion
	
	#Region 周三
	$left += $CELL_WIDTH - 1
	$top = $CELL_TOP
	GUICtrlCreateLabel("周三", $left, $top-1, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	#EndRegion
	
	#Region 周四
	$left += $CELL_WIDTH - 1
	$top = $CELL_TOP
	GUICtrlCreateLabel("周四", $left, $top-1, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("一部配置一室", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	GUICtrlSetBkColor(-1, $CLR_DPT1_CONF1)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("一部配置一室", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	GUICtrlSetBkColor(-1, $CLR_DPT1_CONF1)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("一部配置一室", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	GUICtrlSetBkColor(-1, $CLR_DPT1_CONF1)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("一部配置一室", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	GUICtrlSetBkColor(-1, $CLR_DPT1_CONF1)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	#EndRegion
	
	#Region 周五
	$left += $CELL_WIDTH - 1
	$top = $CELL_TOP
	GUICtrlCreateLabel("周五", $left, $top-1, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	#EndRegion
	
	#Region 周六
	$left += $CELL_WIDTH - 1
	$top = $CELL_TOP
	GUICtrlCreateLabel("周六", $left, $top-1, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	#EndRegion
	
	#Region 周日
	$left += $CELL_WIDTH - 1
	$top = $CELL_TOP
	GUICtrlCreateLabel("周日", $left, $top-1, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH - 1
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	$top += $CELL_HIGH
	GUICtrlCreateLabel("", -1, $top, $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE)
	#EndRegion
EndFunc

; $x 周几
; $y 第几个cell
Func _countPosition($x, $y)
	Local $pos[2]
	$pos[0] = ($x - 1) * ($CELL_WIDTH - 1) + $CELL_LEFT
	$pos[1] = $y * ($CELL_HIGH - 1) + $CELL_TOP
;~ 	If $y >= 1 And $y <= 8 Then $pos[1] += 1
	If $y >= 9 And $y <= 10 Then $pos[1] += 1
	If $y >= 11 And $y <= 17 Then $pos[1] += 2
	Return $pos
EndFunc

Func _cellClicked($x, $y)
	GUICtrlSetState($btn_occupy, $GUI_ENABLE)
	GUICtrlSetState($btn_release, $GUI_ENABLE)
	GUICtrlSetState($btn_unsel, $GUI_ENABLE)
	Local $i, $pos, $needRemove = False
	Local $label = "选定", $cm
	For $i = 1 To $selCells[0][0]
		If $selCells[$i][0] == $x And $selCells[$i][1] == $y Then Return
		If $selCells[$i][0] <> $x Then $needRemove = True
	Next
	If $selCells[0][0] >= 1 Then
		If $selCells[1][1] > $y + 1 Or $selCells[$selCells[0][0]][1] < $y - 1 Then
			$needRemove = True
		ElseIf $y >= $selCells[1][1] And $y <= $selCells[$selCells[0][0]][1] Then
			Return
		EndIf
	Else
		$selCells[0][0] = 1
		ReDim $selCells[2][2]
		$selCells[1][0] = $x
		$selCells[1][1] = $y
		$pos = _countPosition($x, $y)
		$lbl_sel = GUICtrlCreateLabel($label, $pos[0], $pos[1], $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE_SEL)
		GUICtrlSetBkColor($lbl_sel, $CLR_SELECTED)
		$cm = GUICtrlCreateContextMenu($lbl_sel)
		Return
	EndIf
	
	GUICtrlDelete($lbl_sel)
	If $needRemove Then
		$selCells[0][0] = 1
		ReDim $selCells[2][2]
		$selCells[1][0] = $x
		$selCells[1][1] = $y
		$pos = _countPosition($x, $y)
		$lbl_sel = GUICtrlCreateLabel($label, $pos[0], $pos[1], $CELL_WIDTH, $CELL_HIGH, $CELL_STYLE_SEL)
	Else
		If $selCells[1][1] == $y + 1 Then
			$pos = _countPosition($x, $y)
		Else
			$pos = _countPosition($selCells[1][0], $selCells[1][1])
		EndIf
		$selCells[0][0] += 1
		ReDim $selCells[$selCells[0][0]+1][2]
		$selCells[$selCells[0][0]][0] = $x
		$selCells[$selCells[0][0]][1] = $y
		_ArraySort($selCells, 0, 1, $selCells[0][0], 1)
		$lbl_sel = GUICtrlCreateLabel($label, $pos[0], $pos[1], $CELL_WIDTH, _calcHigh(), $CELL_STYLE_SEL)
	EndIf
	GUICtrlSetBkColor($lbl_sel, $CLR_SELECTED)
EndFunc

Func _calcHigh()
	Local $h = $CELL_HIGH * ($selCells[$selCells[0][0]][1] - $selCells[1][1] + 1)
	Return $h
EndFunc

Func cellClicked_1_2()
	_cellClicked(1, 2)
EndFunc

Func cellClicked_1_3()
	_cellClicked(1, 3)
EndFunc

Func cellClicked_1_4()
	_cellClicked(1, 4)
EndFunc

Func cellClicked_2_14()
	_cellClicked(2, 14)
EndFunc

Func cellClicked_2_15()
	_cellClicked(2, 15)
EndFunc

Func cellClicked_2_16()
	_cellClicked(2, 16)
EndFunc

Func cellClicked_2_17()
	_cellClicked(2, 17)
EndFunc

Func quit()
	Exit
EndFunc

Func handleESC()
	If $selCells[0][0] <> 0 Then
		GUICtrlDelete($lbl_sel)
		ReDim $selCells[1][2]
		$selCells[0][0] = 0
		GUICtrlSetState($btn_occupy, $GUI_DISABLE)
		GUICtrlSetState($btn_release, $GUI_DISABLE)
		GUICtrlSetState($btn_unsel, $GUI_DISABLE)
	EndIf
EndFunc
