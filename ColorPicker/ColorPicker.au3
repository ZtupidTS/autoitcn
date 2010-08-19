#include <GUIconstants.au3>
#include <Misc.au3>
;~ #NoTrayIcon

Opt("WinTitleMatchMode", 4)
Opt("WinWaitDelay", 0)
;~ Opt("GUIonEventMode",1)

Global $SRCCOPY = 0x00CC0020
Global $leave = 0
Global $Paused=0
$MouseModifier = 1
$PressedTime = 1

Global $checksumCoorX1 = 0
Global $checksumCoorX2 = 0
Global $checksumCoorY1 = 0
Global $checksumCoorY2 = 0

HotKeySet("{PAUSE}", "TogglePause")
HotKeySet("{INS}", "_copyHEX")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; edited by chenxu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HotKeySet("!1", "setChecksumCoor1")
HotKeySet("!2", "setChecksumCoor2")
HotKeySet("!3", "getChecksum")
HotKeySet("^+j", "jump2Point")
HotKeySet("^+m", "enableMag")
HotKeySet("^+k", "moveCursorWithKeyBoard")
HotKeySet("!{space}", "getMouseClickText")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Tooltip("AU3MAG", @DesktopWidth + 1, @DesktopHeight + 1,"","",4)
$MyhWnd = WinGetHandle("classname=tooltips_class32")

Global $mainForm = GUICreate("Pixel Color", 180, 375,0, 0, -1, $WS_EX_TOPMOST)
GUISetOnEvent($GUI_EVENT_CLOSE,"_exit")

Global $grp_mouseCoords = GUICtrlCreateGroup(" Mouse coords - Screen ", 10, 10, 160, 50)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
GUICtrlCreateLabel("X:", 25, 33, 15, 15)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
$MousePosX=GUICtrlCreateInput("", 40, 30, 40, 20, $ES_READONLY)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
GUICtrlCreateLabel("Y:", 90, 33, 15, 15)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
$MousePosY=GUICtrlCreateInput("", 105, 30, 40, 20, $ES_READONLY)
GUICtrlSetResizing (-1, $GUI_DOCKALL)

GUICtrlCreateGroup(" Color codes ", 10, 70, 160, 110)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
GUICtrlCreateLabel("Decimal:", 25, 93, 50, 15)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
$PixelColor=GUICtrlCreateInput("", 80, 90, 70, 20, $ES_READONLY)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
GUICtrlCreateLabel("Hex:", 25, 123, 50, 15)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
$hexColor=GUICtrlCreateInput("", 80, 120, 70, 20, $ES_READONLY)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
GUICtrlCreateLabel("Color:", 25, 153, 50, 15)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
$MostrarColor=GUICtrlCreateLabel("", 80, 150, 70, 20,$ES_READONLY)
GUICtrlSetResizing (-1, $GUI_DOCKALL)

$btn_jumpTo=GUICtrlCreateButton("&Jump",10,190,50)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
$Ayuda=GUICtrlCreateButton("Help",65,190,50)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
$btn_fold=GUICtrlCreateButton("&Conf>>",120,190,50)
GUICtrlSetResizing (-1, $GUI_DOCKALL)

GUICtrlCreateGroup(" Special options ", 10, 220, 160, 145)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
GUIStartGroup()
$RB_Full = GUICtrlCreateRadio("Full Screen", 25, 240, 100, 20)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
GUICtrlSetState(-1, $GUI_CHECKED)
$RB_Window = GUICtrlCreateRadio("Active Window", 25, 260, 100, 20)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
GUIStartGroup()
$Mag= GUICtrlCreateCheckbox("Magnify", 25, 280, 100, 20)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
$Solid= GUICtrlCreateRadio("Solid crosshair", 35, 300, 100, 20)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
$Inver= GUICtrlCreateRadio("Inverted crosshair", 35, 320, 120, 20)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
GUICtrlSetState($Solid,$GUI_DISABLE+$GUI_UNCHECKED)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
GUICtrlSetState($Inver,$GUI_DISABLE+$GUI_UNCHECKED)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
GUICtrlSetState($RB_Window,$GUI_ENABLE)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
WinSetState($MyhWnd,"",@SW_HIDE)
$isMag = False
Global $KeyBMouse= GUICtrlCreateCheckbox("KeyBoard Mouse", 25, 340, 140, 20)
GUICtrlSetResizing (-1, $GUI_DOCKALL)
GUISetState()
data()

Func data()
	Global $isMag = False
	Local $foldFlag = False, $isFullScreen = True
    While 1
        Sleep(50)
        If (_IsPressed(25) + _IsPressed(26) + _IsPressed(27) + _IsPressed(28)) = 0 Then
			_ResetSpeed()
        EndIf
        $msg=GUIGetMsg()
        Select
            Case $msg = $GUI_EVENT_CLOSE
                Exit
			Case $msg == $KeyBMouse And BitAND(GUICtrlRead($KeyBMouse), $GUI_CHECKED) = $GUI_CHECKED
				MouseKeyb()
			Case $msg == $KeyBMouse And BitAND(GUICtrlRead($KeyBMouse), $GUI_UNCHECKED) = $GUI_UNCHECKED
				MouseKeybNO()
			Case $msg == $RB_Full And BitAND(GUICtrlRead($RB_Full), $GUI_CHECKED) = $GUI_CHECKED
				GUICtrlSetData($grp_mouseCoords, " Mouse coords - Screen ")
				Opt("MouseCoordMode", 1)
				Opt("PixelCoordMode", 1)
				$isFullScreen = True
			Case $msg == $RB_Window And BitAND(GUICtrlRead($RB_Window), $GUI_CHECKED) = $GUI_CHECKED
				GUICtrlSetData($grp_mouseCoords, " Mouse coords - Win ")
				Opt("MouseCoordMode", 0)
				Opt("PixelCoordMode", 0)
				Opt("WinTitleMatchMode",1)
				$isFullScreen = False
			Case $msg == $Mag And BitAND(GUICtrlRead($Mag), $GUI_CHECKED) = $GUI_CHECKED
				GUICtrlSetState($RB_Window,$GUI_DISABLE)
				GUICtrlSetState($Solid,$GUI_ENABLE + $GUI_CHECKED)
				GUICtrlSetState($Inver,$GUI_ENABLE)
				GUICtrlSetState($RB_Full,$GUI_CHECKED)
				WinSetState($MyhWnd,"",@SW_SHOW)
				Opt("WinTitleMatchMode",4)
				$isMag = True
			Case $msg == $Mag And BitAND(GUICtrlRead($Mag), $GUI_UNCHECKED) = $GUI_UNCHECKED
				GUICtrlSetState($Solid,$GUI_DISABLE+$GUI_UNCHECKED)
				GUICtrlSetState($Inver,$GUI_DISABLE+$GUI_UNCHECKED)
				GUICtrlSetState($RB_Window,$GUI_ENABLE)
				WinSetState($MyhWnd,"",@SW_HIDE)
				$isMag = False
			Case $msg == $btn_jumpTo
				jump2Point()
			Case $msg == $Ayuda
				help()
			Case $msg == $btn_fold
				If $foldFlag Then
					GUICtrlSetData($btn_fold, "&Conf>>")
					WinMove ("Pixel Color", "Mouse coords", Default, Default, 186, 400)
					$foldFlag = False
				Else
					GUICtrlSetData($btn_fold, "&Conf<<")
					WinMove ("Pixel Color", "Mouse coords", Default, Default, 186, 245)
					$foldFlag = True
				EndIf
			
        EndSelect
        
        If $isMag Then
            MAG()
        EndIf

		$pos=MouseGetPos()
        If $isFullScreen Then
            $color=PixelGetColor($pos[0],$pos[1])
            GUICtrlSetData($MousePosX, $pos[0])
            GUICtrlSetData($MousePosY, $pos[1])
            GUICtrlSetData($PixelColor,$color)
            $HEX6=StringRight(Hex($color),6)
            GUICtrlSetData($hexColor,"0x"&$HEX6)
            GUICtrlSetBkColor($MostrarColor,"0x"&Hex($color))
        Else
            $win = WinGetPos("")
            If $pos[0] >= 0 And $pos[0] <= $win[2] and $pos[1] >= 0 And $pos[1] <= $win[3] Then
                $color=PixelGetColor($pos[0],$pos[1])
                GUICtrlSetData($MousePosX, $pos[0])
                GUICtrlSetData($MousePosY, $pos[1])
                GUICtrlSetData($PixelColor,$color)
                $HEX6=StringRight(Hex($color),6)
                GUICtrlSetData($hexColor,"0x"&$HEX6)
                GUICtrlSetBkColor($MostrarColor,"0x"&Hex($color))
            Else
                GUICtrlSetData($MousePosX, "----")
                GUICtrlSetData($MousePosY, "----")
                GUICtrlSetData($PixelColor,"")
                GUICtrlSetData($hexColor,"")
            EndIf
        EndIf
    WEnd
EndFunc

Func TogglePause()
    $Paused = NOT $Paused
    While $Paused
        sleep(10)
        $msg=GUIGetMsg()
        Select
            Case $msg=$GUI_EVENT_CLOSE
                Exit
        EndSelect
    WEnd
EndFunc

Func MAG()
  $MyHDC = DLLCall("user32.dll","int","GetDC","hwnd",$MyhWnd)
  If @error Then Return
  $DeskHDC = DLLCall("user32.dll","int","GetDC","hwnd",0)
  If Not @error Then
     $xy = MouseGetPos()
     If Not @error Then
        $l = $xy[0]-10
        $t = $xy[1]-10
        DLLCall("gdi32.dll","int","StretchBlt","int",$MyHDC[0],"int",0,"int",0,"int",100,"int",100,"int",$DeskHDC[0],"int",$l,"int",$t,"int",20,"int",20,"long",$SRCCOPY)
        If $xy[0]<(@DesktopWidth-120) then 
            $XArea= $xy[0] + 20
        Else
            $XArea= $xy[0] - 120
        EndIf
        If $xy[1]<(@DesktopHeight-120) then 
            $YArea= $xy[1] + 20
        Else
            $YArea= $xy[1] - 120    
        EndIf
        WinMove($myhwnd, "",$XArea,$YArea , 100, 100)
        If GUICtrlRead($Solid)=$GUI_CHECKED Then
            CrossHairsSOLID($MyHDC[0])
        ElseIf  GUICtrlRead($Inver)=$GUI_CHECKED Then
            CrossHairsINV($MyHDC[0])
        EndIf
     EndIf
     DLLCall("user32.dll","int","ReleaseDC","int",$DeskHDC[0],"hwnd",0)
  EndIf
  DLLCall("user32.dll","int","ReleaseDC","int",$MyHDC[0],"hwnd",$MyhWnd)
EndFunc

Func help()
    MsgBox(0,"Help","*Use magnifier for more presicion." & @CRLF & _
		"" & @CRLF & "*Use 'move cursor with keyboard' option for more presicion." & @CRLF & _
		"   -Keeping arrow key pressed increases speed." & @CRLF & _
		"   -Shift+'arrow' moves mouse cursor faster." & @CRLF & _
		"" & @CRLF & "*Use 'Jump to' to move mouse cursor to a specified pixel" & @CRLF & @CR & _
		"*Press PAUSE to freeze and unfreeze." & @CRLF & _
		"" & @CRLF &"*Press INS to copy HEX code to clipboard.")
EndFunc

Func jump2Point()
    Do
    $SaltarCord=InputBox("Jump to","Enter pixel coordinates you want to jump to."&@CRLF&"Example: 123,420",MouseGetPos(0)&","&MouseGetPos(1),"",150,150)
    $CoordsM=StringSplit($SaltarCord,",")
    Until @error OR ($CoordsM[1]<=@DesktopWidth AND $CoordsM[2]<=@DesktopHeight)
    if not @error Then
        BlockInput(1)
        MouseMove($CoordsM[1],$CoordsM[2])
        BlockInput(0)
    EndIf    
EndFunc

Func MouseKeyb()

HotKeySet("+{UP}", "_UpArrow")
HotKeySet("{UP}", "_UpArrow")
HotKeySet("+{DOWN}", "_DownArrow")
HotKeySet("{DOWN}", "_DownArrow")
HotKeySet("+{LEFT}", "_LeftArrow")
HotKeySet("{LEFT}", "_LeftArrow")
HotKeySet("+{RIGHT}", "_RightArrow")
HotKeySet("{RIGHT}", "_RightArrow")
EndFunc

Func MouseKeybNO()
HotKeySet("+{UP}")
HotKeySet("{UP}")
HotKeySet("+{DOWN}")
HotKeySet("{DOWN}")
HotKeySet("+{LEFT}")
HotKeySet("+{LEFT}")
HotKeySet("{LEFT}")
HotKeySet("+{RIGHT}")
HotKeySet("{RIGHT}")
EndFunc

Func nada()
EndFunc

Func _copyHEX()
	Local $text = GUICtrlRead($MousePosX) & ", " & GUICtrlRead($MousePosY) & "   " & Guictrlread($hexColor)
    ClipPut($text)
	TrayTip("Color Picker", $text, 30, 1)
EndFunc ;==>_ShowInfo

Func _UpArrow()
    Local $MousePos = MouseGetPos()
    If _IsPressed(10) Then
        $i = 10
    Else
        $i = 1
    EndIf
    
    If $MousePos[1] > 0 Then
        _BoostMouseSpeed()
        MouseMove($MousePos[0], $MousePos[1] - ($MouseModifier * $i), 1)
    EndIf
EndFunc ;==>_UpArrow

Func _DownArrow()
    If _IsPressed(10) Then
        $i = 10
    Else
        $i = 1
    EndIf

    Local $MousePos = MouseGetPos()
    If $MousePos[1] < @DesktopHeight Then
        _BoostMouseSpeed()
        MouseMove($MousePos[0], $MousePos[1] + ($MouseModifier * $i),1)
    EndIf
EndFunc ;==>_DownArrow

Func _LeftArrow()
    If _IsPressed(10) Then
        $i = 10
    Else
        $i = 1
    EndIf

    Local $MousePos = MouseGetPos()
    If $MousePos[0] > 0 Then
        _BoostMouseSpeed()
        MouseMove($MousePos[0] - ($MouseModifier * $i), $MousePos[1],1)
    EndIf
EndFunc ;==>_LeftArrow

Func _RightArrow()
    If _IsPressed(10) Then
        $i = 10
    Else
        $i = 1
    EndIf

    Local $MousePos = MouseGetPos()
    If $MousePos[0] < @DesktopWidth Then
        _BoostMouseSpeed()
        MouseMove($MousePos[0] + ($MouseModifier * $i), $MousePos[1],1)
    EndIf
EndFunc ;==>_RightArrow

Func _BoostMouseSpeed()
        If IsInt($PressedTime / 10) Then
            $MouseModifier = $MouseModifier + 1
            $PressedTime = $PressedTime + 1
        Else
            $PressedTime = $PressedTime + 1
        EndIf
EndFunc

Func _ResetSpeed()
    $MouseModifier = 1
    $PressedTime = 1
EndFunc ;==>_ResetSpeed

Func CrossHairsSOLID(ByRef $hdc)
    Local $hPen, $hPenOld
    $hPen = DllCall("gdi32.dll","hwnd","CreatePen","int",0,"int",5,"int",0x555555)
    $hPenOld = DllCall("gdi32.dll","hwnd","SelectObject","int",$hdc,"hwnd",$hPen[0])
    DLLCall("gdi32.dll","int","MoveToEx","int",$hdc,"int",52,"int",0,"ptr",0)
    DLLCall("gdi32.dll","int","LineTo","int",$hdc,"int",52,"int",46)
    DLLCall("gdi32.dll","int","MoveToEx","int",$hdc,"int",52,"int",58,"ptr",0)
    DLLCall("gdi32.dll","int","LineTo","int",$hdc,"int",52,"int",100)
    DLLCall("gdi32.dll","int","MoveToEx","int",$hdc,"int",0,"int",52,"ptr",0)
    DLLCall("gdi32.dll","int","LineTo","int",$hdc,"int",46,"int",52)
    DLLCall("gdi32.dll","int","MoveToEx","int",$hdc,"int",58,"int",52,"ptr",0)
    DLLCall("gdi32.dll","int","LineTo","int",$hdc,"int",100,"int",52)
    DllCall("gdi32.dll","hwnd","SelectObject","int",$hdc,"hwnd",$hPenOld[0])
    DllCall("gdi32.dll","int","DeleteObject","hwnd",$hPen[0])
EndFunc

Func CrossHairsINV(ByRef $hdc)
    Local CONST $NOTSRCCOPY = 0x330008
    DLLCall("gdi32.dll","int","BitBlt","int",$hdc,"int",50,"int",0,"int",5,"int",49,"int",$hdc,"int",50,"int",0,"int",$NOTSRCCOPY)
    DLLCall("gdi32.dll","int","BitBlt","int",$hdc,"int",50,"int",56,"int",5,"int",49,"int",$hdc,"int",50,"int",56,"int",$NOTSRCCOPY)
    DLLCall("gdi32.dll","int","BitBlt","int",$hdc,"int",0,"int",50,"int",49,"int",5,"int",$hdc,"int",0,"int",50,"int",$NOTSRCCOPY)
    DLLCall("gdi32.dll","int","BitBlt","int",$hdc,"int",56,"int",50,"int",44,"int",5,"int",$hdc,"int",56,"int",50,"int",$NOTSRCCOPY)
EndFunc

Func _exit()
    Exit
EndFunc



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func setChecksumCoor1()
	$checksumCoorX1 = GUICtrlRead($MousePosX)
	$checksumCoorY1 = GUICtrlRead($MousePosY)
	TrayTip("Check sum", "Point 1: " & $checksumCoorX1 & ", " & $checksumCoorY1, 60)
EndFunc

Func setChecksumCoor2()
	$checksumCoorX2 = GUICtrlRead($MousePosX)
	$checksumCoorY2 = GUICtrlRead($MousePosY)
	TrayTip("Check sum", "Point 2: " & $checksumCoorX2 & ", " & $checksumCoorY2, 60)
EndFunc

Func getChecksum()
	Local $sum = PixelChecksum($checksumCoorX1, $checksumCoorY1, $checksumCoorX2, $checksumCoorY2)
	Local $line = "PixelChecksum(" & $checksumCoorX1 & ", " & $checksumCoorY1 & ", " & $checksumCoorX2 & ", " & $checksumCoorY2 & ") == " & $sum
	ClipPut($line)
	TrayTip("Check sum", $line, 60)
EndFunc

Func getMouseClickText()
	Local $text = "MouseMove(" & GUICtrlRead($MousePosX) & ", " & GUICtrlRead($MousePosY) & ", 0)" & @CRLF & _
		"MouseClick('left', " & GUICtrlRead($MousePosX) & ", " & GUICtrlRead($MousePosY) & ", 1, " & "0)"
	ClipPut( $text )
	TrayTip("Get Mouse Command Line", $text, 60)
EndFunc

Func moveCursorWithKeyBoard()
	If BitAND( GUICtrlRead($KeyBMouse), $GUI_CHECKED) == $GUI_CHECKED Then
		GUICtrlSetState($KeyBMouse, $GUI_UNCHECKED)
		MouseKeybNO()
	Else
		GUICtrlSetState($KeyBMouse, $GUI_CHECKED)
		MouseKeyb()
	EndIf
EndFunc

Func enableMag()
	If BitAND( GUICtrlRead($Mag), $GUI_CHECKED) == $GUI_CHECKED Then
		GUICtrlSetState($Mag, $GUI_UNCHECKED)
		GUICtrlSetState($Solid,$GUI_DISABLE+$GUI_UNCHECKED)
		GUICtrlSetState($Inver,$GUI_DISABLE+$GUI_UNCHECKED)
		GUICtrlSetState($RB_Window,$GUI_ENABLE)
		WinSetState($MyhWnd,"",@SW_HIDE)
		$isMag = False
	Else
		GUICtrlSetState($Mag, $GUI_CHECKED)
		GUICtrlSetState($RB_Window,$GUI_DISABLE)
		GUICtrlSetState($Solid,$GUI_ENABLE + $GUI_CHECKED)
		GUICtrlSetState($Inver,$GUI_ENABLE)
		GUICtrlSetState($RB_Full,$GUI_CHECKED)
		WinSetState($MyhWnd,"",@SW_SHOW)
		Opt("WinTitleMatchMode",4)
		$isMag = True
	EndIf
EndFunc



