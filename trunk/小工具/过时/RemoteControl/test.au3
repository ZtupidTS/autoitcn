#include <GUIConstants.au3>
Opt("TrayIconDebug", 1)

Global $WIDHT = 1024
Global $HEIGH = 768
Global $COUNT = 16
Global $CELL_WIDTH = 1024/$COUNT
Global $CELL_HEIGH = 768/$COUNT

Global $pics[$COUNT][$COUNT]

GUICreate("My GUI picture", $WIDHT, $HEIGH, -1, -1)  ; will create a dialog box that when displayed is centered
$label = GUICtrlCreateLabel("µÈ´ýÊý¾Ý...", 10, 10)
GUISetState()
For $i = 0 To $COUNT - 1
	For $j = 0 To $COUNT - 1
		$pics[$i][$j] = GUICtrlCreatePic("", $i * $CELL_WIDTH, $j * $CELL_HEIGH, $CELL_WIDTH, $CELL_HEIGH)
	Next
Next
Do
	Sleep(200)
Until FileExists("Z:\RCFTP\data\FirstFrame.jpg")
GUICtrlDelete($label)
;~ $pic = GUICtrlCreatePic("Z:\RCFTP\data\FirstFrame.jpg", 0, 0, $WIDHT, $HEIGH)
FileDelete("Z:\RCFTP\data\FirstFrame.jpg")

AdlibEnable("check", 1000)
While 1
    $msg = GUIGetMsg()
;~     If $msg = $GUI_EVENT_CLOSE Then ExitLoop
WEnd


Func check()
	If Not FileExists("Z:\RCFTP\data\data.zip") Then Return
	FileDelete("Z:\RCFTP\data\data.zip")
	$search = FileFindFirstFile("Z:\RCFTP\data\tmp\*.jpg")  

	If $search = -1 Then
		Return
	EndIf
	While 1
		$file = FileFindNextFile($search) 
		If @error Then ExitLoop
		$xy = getXY($file)
		GUICtrlSetImage($pics[$xy[1]][$xy[0]], "Z:\RCFTP\data\tmp\" & $file)
		FileDelete("Z:\RCFTP\data\tmp\" & $file)
	WEnd
	FileClose($search)
EndFunc

Func getXY($file)
	Dim $xy[2]
	$arr = StringSplit($file, "_")
	$xy[0] = $arr[1]
	$xy[1] = StringLeft($arr[2], StringLen($arr[2]) - 4)
	Return $xy
EndFunc
