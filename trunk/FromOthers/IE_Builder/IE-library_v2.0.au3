#include <GUIConstants.au3>
#Include <Constants.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#Include <GuiListBox.au3>
#include <GuiEdit.au3>
#include <IE.au3>
#include <Array.au3>
#include <Date.au3>
#Include <File.au3>
#include <String.au3>
#include <Misc.au3>
#Include <GuiButton.au3>

Opt("TrayIconDebug", True)

Dim $Radio[10], $Input[10], $Combo[10]
Dim $wloc = @ScriptDir & "\web.ini"
Dim $AutoItBetaLocation, $Dwait
Dim $ver = "2.0.0", $prg = 0, $Status = ""

; Set a COM Error handler -- only one can be active at a time (see helpfile)
_IEErrorHandlerRegister ()

#region Verify Requirements
$AutoItBetaLocation = IniRead(@ScriptDir & "\IE-library.ini", "exe", "dir", "")
If $AutoItBetaLocation = "" Then
	$AutoItBetaLocation = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\AutoIt", "betaInstallDir")
	If $AutoItBetaLocation = "" Then
		$AutoItBetaLocation = FileSelectFolder("Select Folder where the Beta AutoIt is installed", "c:\", 4, @ProgramFilesDir & "\AutoIt3\beta")
		If $AutoItBetaLocation = "" Then
			$iMsgBoxAnswer = MsgBox(262209, "IE.au3 Error #1", "Autoit3 Beta is required   " & @CRLF & _
					"Download from www.Autoit3.com ?  ")
			If $iMsgBoxAnswer = 1 Then
				$web_loc = "http://www.autoitscript.com/forum/index.php?showtopic=19717#"
				Run(@ComSpec & " /c Start " & $web_loc, "", @SW_HIDE)
				MsgBox(262208, "Web Site", "The AutoIt3 Beta Link is at the top of this page...       " & _
						@CRLF & @CRLF & "Please Download and Install   ", 10)
				$Dwait = 1
			EndIf
		EndIf
	EndIf
	IniWrite(@ScriptDir & "\IE-library.ini", "exe", "dir", $AutoItBetaLocation)
EndIf
If Not FileExists($AutoItBetaLocation & "\Include\IE.au3") Then
	$iMsgBoxAnswer = MsgBox(262209, "IE.au3 Error #2", "IE.au3 Library is required   " & @CRLF & "Download from www.Autoit3.com ?  ")
	If $iMsgBoxAnswer = 1 Then
		$web_loc = "http://www.autoitscript.com/forum/index.php?showtopic=25629&st=0&p=180446&#entry180446"
		Run(@ComSpec & " /c Start " & $web_loc, "", @SW_HIDE)
		MsgBox(262208, "Web Site", "The IE.au3 Library is at the top of this page...       " & _
				@CRLF & @CRLF & "Save as " & $AutoItBetaLocation & "\Include\IE.au3   ", 10)
		$Dwait = 1
	EndIf
EndIf


If Not FileExists(@ScriptDir & "\web.ini") Then Set_web()

$Program_2 = $AutoItBetaLocation & "\Autoit3.exe"
#endregion
#region Parent GUI
$GUI = GUICreate(" IE-Builder  " & $ver, @DesktopWidth - 5, @DesktopHeight - 30, 0, 0);, $WS_OVERLAPPEDWINDOW + $WS_VISIBLE + $WS_OVERLAPPEDWINDOW + $WS_MAXIMIZE) ;, $WS_EX_TOPMOST )

$VLabel = GUICtrlCreateLabel("IE-Builder View", 10, 140, 140, 43, $SS_CENTER)
GUICtrlSetFont(-1, 16, 700, 4, "MS Sans Serif")
$VAbout = GUICtrlCreateButton("", 15, 60, 40, 30, $BS_ICON)
$VImg = GUICtrlCreateButton("", 105, 60, 40, 30, $BS_ICON)
$VFavr = GUICtrlCreateButton("", 60, 60, 40, 30, $BS_ICON)
$VBack = GUICtrlCreateButton("Back", 15, 20, 40, 30, $BS_BITMAP)
$VForward = GUICtrlCreateButton("Forward", 60, 20, 40, 30, $BS_BITMAP)
$VRefresh = GUICtrlCreateButton("Refresh", 105, 20, 40, 30, $BS_BITMAP)
$VGo = GUICtrlCreateButton("GO", 800, 20, 50, 30, $BS_BITMAP)
$VMnmz = GUICtrlCreateButton("Min", 855, 20, 50, 30, $BS_ICON)
$VExit = GUICtrlCreateButton("Exit", 910, 20, 50, 30, $BS_ICON)

$Combo_5 = GUICtrlCreateCombo("http://www.Autoit3.com", 160, 25, 625, 25)
Set_combo()
ControlSetText(" IE-Builder  ", "", $Combo_5, "http://www.Autoit3.com")
$Progress_6 = GUICtrlCreateProgress(30, 620, 100, 15)
GUICtrlCreateLabel("Ver " & $ver, 60, 640, 100, 15)

GUICtrlCreateLabel("", 160, @DesktopHeight - 100, 650, 35, $SS_SUNKEN + $SS_CENTER)
GUICtrlSetFont(-1, 16, 700, 4, "MS Sans Serif")
GUICtrlSetData(-1, " Internet Explorer Automation UDF Library and IE-Builder for AutoIt3 ")

; set button pics
GUICtrlSetImage($VFavr, "shell32.dll", 208)
GUICtrlSetImage($VImg, "shell32.dll", 220)
GUICtrlSetImage($VBack, "images\back.bmp")
GUICtrlSetImage($VForward, "images\forward.bmp")
GUICtrlSetImage($VRefresh, "images\refresh.bmp")
GUICtrlSetImage($VGo, "images\go.bmp")
GUICtrlSetImage($VMnmz, "shell32.dll", 217)
GUICtrlSetImage($VExit, "shell32.dll", 215)
GUICtrlSetImage($VAbout, "shell32.dll", 210)

; View buttons
GUICtrlCreateGroup("IE-Builder Center", 20, 200, 120, 390)
$VBuilder = GUICtrlCreateButton("IE-Builder", 40, 230, 80, 20)
$VInternet = GUICtrlCreateButton("Internet", 40, 270, 80, 20)
$VSource = GUICtrlCreateButton("Source Code", 40, 310, 80, 20)
$VHtml = GUICtrlCreateButton("Html Elements", 40, 350, 80, 20)
$VAnchor = GUICtrlCreateButton("Anchor Tags", 40, 390, 80, 20)
$VImage = GUICtrlCreateButton("Image Tags", 40, 430, 80, 20)
$VForm = GUICtrlCreateButton("Form Elements", 40, 470, 80, 20)
$VSyntax = GUICtrlCreateButton("IE.au3 Syntax", 40, 510, 80, 20)
$VExample = GUICtrlCreateButton("Examples", 40, 550, 80, 20)
GUISetState()
#endregion
#region Internet Objects
;creates internet objects
$B_oIE1 = ObjCreate("Shell.Explorer.2")
$B_oIE2 = ObjCreate("Shell.Explorer.2")
$B_oIE3 = ObjCreate("Shell.Explorer.2")
$B_oIE4 = ObjCreate("Shell.Explorer.2")
$B_oIE5 = ObjCreate("Shell.Explorer.2")

;creates the child gui that the internet objects will be held in
;$INETGUI = GUICreate("Internet GUI", @DesktopWidth - 200, @DesktopHeight - 200, 160, 80, $WS_CHILD + $WS_BORDER, "", $GUI)
$INETGUI = GUICreate("Internet GUI", @DesktopWidth - 200, @DesktopHeight - 200, 160, 100, $WS_BORDER, "", $GUI)
$INETGUI1 = GUICtrlCreateObj($B_oIE1, -1, -1, @DesktopWidth - 200, @DesktopHeight - 200)
GUICtrlSetState(-1, $GUI_HIDE)
$INETGUI2 = GUICtrlCreateObj($B_oIE2, -1, -1, @DesktopWidth - 200, @DesktopHeight - 200)
GUICtrlSetState(-1, $GUI_HIDE)
$INETGUI3 = GUICtrlCreateObj($B_oIE3, -1, -1, @DesktopWidth - 200, @DesktopHeight - 200)
GUICtrlSetState(-1, $GUI_HIDE)
$INETGUI4 = GUICtrlCreateObj($B_oIE4, -1, -1, @DesktopWidth - 200, @DesktopHeight - 200)
GUICtrlSetState(-1, $GUI_HIDE)
$INETGUI5 = GUICtrlCreateObj($B_oIE5, -1, -1, @DesktopWidth - 200, @DesktopHeight - 200)
GUICtrlSetState(-1, $GUI_HIDE)
GUISetState(@SW_HIDE)

; Navigate the IE Objects
$B_oIE1.navigate ("about:Html Elements - Get Source First")
$B_oIE2.navigate ("about:Anchor Tags - Get Source First")
$B_oIE3.navigate ("about:Image Tags -  Get Source First")
$B_oIE4.navigate ("about:Form Elements - Get Source First")
$B_oIE5.navigate ("about:Web Site - Navigate to Desired Web Page First")
#endregion
#region Child GUIs
;creates the child gui for HTML Source
$HTMLGUI = GUICreate("Html GUI", @DesktopWidth - 200, @DesktopHeight - 200, 160, 80, $WS_CHILD + $WS_BORDER, "", $GUI)
$HTMLLabel = GUICtrlCreateLabel((GUICtrlRead($Combo_5)), 15, 17, 300, 20)

$HTMLInput = GUICtrlCreateInput("Search word/phrase", 520, 15, 120, 20)
$HTMLButton1 = GUICtrlCreateButton("Search Source", 650, 15, 100, 20)
$HTMLButton2 = GUICtrlCreateButton("Display Source", 350, 15, 100, 20)
$HTMLEdit = GUICtrlCreateEdit("Reads current web page" & @CRLF & "Updates the following views..." & _
		@CRLF & @CRLF & "Html Elements" & @CRLF & "Anchor Tags" & @CRLF & "Image Tags" & _
		@CRLF & "Form Elements", 0, 50, @DesktopWidth - 200, @DesktopHeight - 250)
GUISetState(@SW_HIDE)

;creates the child gui for examples
$EXAMPLEGUI = GUICreate("Examples GUI", @DesktopWidth - 200, @DesktopHeight - 200, 160, 80, $WS_CHILD + $WS_BORDER, "", $GUI)
$EExamples = FileRead(@ScriptDir & "\Examples.txt", FileGetSize(@ScriptDir & "\Examples.txt"))
GUICtrlCreateEdit($EExamples, -1, -1, @DesktopWidth - 200, @DesktopHeight - 200)
GUISetState(@SW_HIDE)

;creates the child gui for syntax files
$SYNTAXGUI = GUICreate("Syntax GUI", @DesktopWidth - 200, @DesktopHeight - 200, 160, 80, $WS_CHILD + $WS_BORDER, "", $GUI)
$ESnytax = FileRead(@ProgramFilesDir & "\Autoit3\Include\IE.au3", FileGetSize(@ProgramFilesDir & "\Autoit3\Include\IE.au3"))
GUICtrlCreateEdit($ESnytax, -1, -1, @DesktopWidth - 200, @DesktopHeight - 200)
GUISetState(@SW_HIDE)
#endregion
#region IE Builder GUI
;creates the IE-Builder gui.
$BUILDERGUI = GUICreate("", @DesktopWidth - 200, @DesktopHeight - 200, 160, 80, $WS_CHILD + $WS_BORDER, "", $GUI)

$Group1 = GUICtrlCreateGroup("Core Functions", 8, 10, 441, 49)
$Combo[1] = GUICtrlCreateCombo("", 56, 26, 161, 21)
GUICtrlSetData(-1, "_IECreate|_IECreateEmbedded|_IENavigate|_IEAttach|_IELoadWait|_IELoadWaitTimeout")
$Input[1] = GUICtrlCreateInput("Choose a Function 1", 264, 26, 161, 21, -1, $WS_EX_CLIENTEDGE)

$Group2 = GUICtrlCreateGroup("Frame Functions", 8, 66, 441, 49)
$Combo[2] = GUICtrlCreateCombo("", 56, 82, 161, 21)
GUICtrlSetData(-1, "_IEIsFrameSet|_IEFrameGetCollection|_IEFrameGetObjByName")
$Input[2] = GUICtrlCreateInput("Choose a Function 2", 264, 82, 161, 21, -1, $WS_EX_CLIENTEDGE)

$Group3 = GUICtrlCreateGroup("Link Functions", 8, 122, 441, 49)
$Combo[3] = GUICtrlCreateCombo("", 56, 138, 161, 21)
GUICtrlSetData(-1, "_IELinkClickByText|_IELinkClickByIndex|_IELinkGetCollection")
$Input[3] = GUICtrlCreateInput("Choose a Function 3", 264, 138, 161, 21, -1, $WS_EX_CLIENTEDGE)

$Group4 = GUICtrlCreateGroup("Image Function", 8, 178, 441, 49)
$Combo[4] = GUICtrlCreateCombo("", 56, 194, 161, 21)
GUICtrlSetData(-1, "_IEImgClick|_IEImgGetCollection")
$Input[4] = GUICtrlCreateInput("Choose a Function 4", 264, 194, 161, 21, -1, $WS_EX_CLIENTEDGE)

$Group5 = GUICtrlCreateGroup("Form Functions", 8, 234, 441, 49)
$Combo[5] = GUICtrlCreateCombo("", 56, 250, 161, 21)
GUICtrlSetData(-1, "_IEFormGetCollection|_IEFormGetObjByName|_IEFormElementGetCollection|_IEFormElementGetObjByName|" & _
		"_IEFormElementGetValue|_IEFormElementSetValue|_IEFormElementOptionSelect|_IEFormElementCheckboxSelect|_IEFormElementRadioSelect|" & _
		"_IEFormImageClick|_IEFormSubmit|_IEFormReset")
$Input[5] = GUICtrlCreateInput("Choose a Function 5", 264, 250, 161, 21, -1, $WS_EX_CLIENTEDGE)

$Group6 = GUICtrlCreateGroup("Table Functions", 8, 290, 441, 49)
$Combo[6] = GUICtrlCreateCombo("", 56, 306, 161, 21)
GUICtrlSetData(-1, "_IETableGetCollection|_IETableWriteToArray")
$Input[6] = GUICtrlCreateInput("Choose a Function 6", 264, 306, 161, 21, -1, $WS_EX_CLIENTEDGE)

$Group7 = GUICtrlCreateGroup("Read/Write Functions", 8, 346, 441, 49)
$Combo[7] = GUICtrlCreateCombo("", 56, 362, 161, 21)
GUICtrlSetData(-1, "_IEBodyReadHTML|_IEBodyReadText|_IEBodyWriteHTML|_IEDocReadHTML|_IEDocWriteHTML|_IEHeadInsertEventScript")
$Input[7] = GUICtrlCreateInput("Choose a Function 7", 264, 362, 161, 21, -1, $WS_EX_CLIENTEDGE)

$Group8 = GUICtrlCreateGroup("Utility Functions", 8, 402, 441, 49)
$Combo[8] = GUICtrlCreateCombo("", 56, 418, 161, 21)
GUICtrlSetData(-1, "_IEDocGetObj|_IETagNameGetCollection|_IETagNameAllGetCollection|_IEGetObjByName|_IEAction|" & _
		"_IEPropertyGet|_IEPropertySet|_IEErrorNotify|_IEErrorHandlerRegister|_IEErrorHandlerDeRegister|_IEQuit")
$Input[8] = GUICtrlCreateInput("Choose a Function 8", 264, 418, 161, 21, -1, $WS_EX_CLIENTEDGE)

$Group9 = GUICtrlCreateGroup("General Functions", 8, 458, 441, 49)
$Combo[9] = GUICtrlCreateCombo("", 56, 474, 161, 21)
GUICtrlSetData(-1, "_IE_Introduction|_IE_Example|_IE_VersionInfo")
$Input[9] = GUICtrlCreateInput("Choose a Function 9", 264, 474, 161, 21, -1, $WS_EX_CLIENTEDGE)

$Edit1 = GUICtrlCreateEdit("", 474, 32, 329, 515);, -1, $WS_EX_CLIENTEDGE)
GUICtrlSetData($Edit1, "#include <IE.au3>" & @CRLF & @CRLF & '#Region --- IE-Builder generated code Start ---' & @CRLF & _
						'$sUrl = "www.autoit3.com"' & @CRLF & "$oIE = _IECreate($sUrl, 1)" & @CRLF, 1)
GUICtrlCreateLabel("IE-Builder Form - Line by Line", 480, 8, 294, 24, $SS_CENTER)
GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")

; create radios
$Radio[1] = GUICtrlCreateRadio("", 16, 26, 17, 25)
$Radio[2] = GUICtrlCreateRadio("", 16, 82, 17, 25)
$Radio[3] = GUICtrlCreateRadio("", 16, 138, 17, 25)
$Radio[4] = GUICtrlCreateRadio("", 16, 194, 17, 25)
$Radio[5] = GUICtrlCreateRadio("", 16, 250, 17, 25)
$Radio[6] = GUICtrlCreateRadio("", 16, 306, 17, 25)
$Radio[7] = GUICtrlCreateRadio("", 16, 362, 17, 25)
$Radio[8] = GUICtrlCreateRadio("", 16, 418, 17, 25)
$Radio[9] = GUICtrlCreateRadio("", 16, 474, 17, 25)
;create buttons
$Button1 = GUICtrlCreateButton("Submit to Form", 16, 520, 129, 33)
$Button2 = GUICtrlCreateButton("Test Run Form", 160, 520, 137, 33)
$Button3 = GUICtrlCreateButton("Copy to ClipBoard", 312, 520, 137, 33)

If $Dwait = 1 Then
	GUISetState(@SW_MINIMIZE, $GUI)
Else
	GUISetState(@SW_SHOW, $GUI)
	GUISetState(@SW_SHOW, $BUILDERGUI)
	$Status = "builder"
EndIf

$B_oIE5.navigate ((GUICtrlRead($Combo_5)))
Set_progress()
#endregion
#region Main Loop
While 1
	$msg = GUIGetMsg()
	Switch $msg
		; Main window controls
		Case $GUI_EVENT_CLOSE, $VExit
			ExitLoop
		Case $VMnmz
			GUISetState(@SW_MINIMIZE, $GUI)
		Case $HTMLButton1
			Search_HTML()
			Set_progress()
		Case $HTMLButton2
			Set_HTML()
			Set_progress()
		Case $VFavr
			check_web()
			Set_progress()
		Case $VBuilder
			If $Status <> "builder" Then
				GUISetState(@SW_HIDE, $HTMLGUI)
				GUISetState(@SW_HIDE, $EXAMPLEGUI)
				GUISetState(@SW_HIDE, $SYNTAXGUI)
				GUISetState(@SW_HIDE, $INETGUI)
				GUICtrlSetState($INETGUI1, $GUI_HIDE)
				GUICtrlSetState($INETGUI2, $GUI_HIDE)
				GUICtrlSetState($INETGUI3, $GUI_HIDE)
				GUICtrlSetState($INETGUI4, $GUI_HIDE)
				GUICtrlSetState($INETGUI5, $GUI_HIDE)
				GUISetState(@SW_SHOW, $BUILDERGUI)
				GUICtrlSetData($VLabel, "IE-Builder View")
				Set_progress()
				$Status = "builder"
			EndIf
		Case $VInternet, $VImg
			If $Status <> "internet" Then
				GUISetState(@SW_HIDE, $HTMLGUI)
				GUISetState(@SW_HIDE, $EXAMPLEGUI)
				GUISetState(@SW_HIDE, $SYNTAXGUI)
				GUISetState(@SW_HIDE, $BUILDERGUI)
				GUICtrlSetState($INETGUI1, $GUI_HIDE)
				GUICtrlSetState($INETGUI2, $GUI_HIDE)
				GUICtrlSetState($INETGUI3, $GUI_HIDE)
				GUICtrlSetState($INETGUI4, $GUI_HIDE)
				GUISetState(@SW_SHOW, $INETGUI)
				GUICtrlSetState($INETGUI5, $GUI_SHOW)
				GUICtrlSetState($INETGUI5, $GUI_FOCUS)
				GUICtrlSetData($VLabel, "Internet View")
				Set_progress()
				$Status = "internet"
			EndIf
		Case $VHtml
			If $Status <> "html" Then
				GUISetState(@SW_HIDE, $HTMLGUI)
				GUISetState(@SW_HIDE, $EXAMPLEGUI)
				GUISetState(@SW_HIDE, $SYNTAXGUI)
				GUISetState(@SW_HIDE, $BUILDERGUI)
				GUICtrlSetState($INETGUI2, $GUI_HIDE)
				GUICtrlSetState($INETGUI3, $GUI_HIDE)
				GUICtrlSetState($INETGUI4, $GUI_HIDE)
				GUICtrlSetState($INETGUI5, $GUI_HIDE)
				GUISetState(@SW_SHOW, $INETGUI)
				GUICtrlSetState($INETGUI1, $GUI_SHOW)
				GUICtrlSetData($VLabel, "Elements View")
				Set_progress()
				$Status = "html"
			EndIf
		Case $VAnchor
			If $Status <> "anchor" Then
				GUISetState(@SW_HIDE, $HTMLGUI)
				GUISetState(@SW_HIDE, $EXAMPLEGUI)
				GUISetState(@SW_HIDE, $SYNTAXGUI)
				GUISetState(@SW_HIDE, $BUILDERGUI)
				GUICtrlSetState($INETGUI1, $GUI_HIDE)
				GUICtrlSetState($INETGUI3, $GUI_HIDE)
				GUICtrlSetState($INETGUI4, $GUI_HIDE)
				GUICtrlSetState($INETGUI5, $GUI_HIDE)
				GUISetState(@SW_SHOW, $INETGUI)
				GUICtrlSetState($INETGUI2, $GUI_SHOW)
				GUICtrlSetData($VLabel, "Anchors View")
				Set_progress()
				$Status = "anchor"
			EndIf
		Case $VImage
			If $Status <> "image" Then
				GUISetState(@SW_HIDE, $HTMLGUI)
				GUISetState(@SW_HIDE, $EXAMPLEGUI)
				GUISetState(@SW_HIDE, $SYNTAXGUI)
				GUISetState(@SW_HIDE, $BUILDERGUI)
				GUISetState(@SW_HIDE, $INETGUI)
				GUICtrlSetState($INETGUI1, $GUI_HIDE)
				GUICtrlSetState($INETGUI2, $GUI_HIDE)
				GUICtrlSetState($INETGUI4, $GUI_HIDE)
				GUICtrlSetState($INETGUI5, $GUI_HIDE)
				GUISetState(@SW_SHOW, $INETGUI)
				GUICtrlSetState($INETGUI3, $GUI_SHOW)
				GUICtrlSetData($VLabel, "Images View")
				Set_progress()
				$Status = "image"
			EndIf
		Case $VForm
			If $Status <> "form" Then
				GUISetState(@SW_HIDE, $HTMLGUI)
				GUISetState(@SW_HIDE, $EXAMPLEGUI)
				GUISetState(@SW_HIDE, $SYNTAXGUI)
				GUISetState(@SW_HIDE, $BUILDERGUI)
				GUISetState(@SW_HIDE, $INETGUI)
				GUICtrlSetState($INETGUI1, $GUI_HIDE)
				GUICtrlSetState($INETGUI2, $GUI_HIDE)
				GUICtrlSetState($INETGUI3, $GUI_HIDE)
				GUICtrlSetState($INETGUI5, $GUI_HIDE)
				GUISetState(@SW_SHOW, $INETGUI)
				GUICtrlSetState($INETGUI4, $GUI_SHOW)
				GUICtrlSetData($VLabel, "Forms View")
				Set_progress()
				$Status = "form"
			EndIf
		Case $VSource
			If $Status <> "source" Then
				GUISetState(@SW_HIDE, $EXAMPLEGUI)
				GUISetState(@SW_HIDE, $SYNTAXGUI)
				GUISetState(@SW_HIDE, $INETGUI)
				GUISetState(@SW_HIDE, $BUILDERGUI)
				GUICtrlSetState($INETGUI1, $GUI_HIDE)
				GUICtrlSetState($INETGUI2, $GUI_HIDE)
				GUICtrlSetState($INETGUI3, $GUI_HIDE)
				GUICtrlSetState($INETGUI4, $GUI_HIDE)
				GUICtrlSetState($INETGUI5, $GUI_HIDE)
				GUISetState(@SW_SHOW, $HTMLGUI)
				GUICtrlSetData($VLabel, "Source View")
				Set_progress()
				$Status = "source"
			EndIf
		Case $VExample
			If $Status <> "example" Then
				GUISetState(@SW_HIDE, $HTMLGUI)
				GUISetState(@SW_HIDE, $BUILDERGUI)
				GUISetState(@SW_HIDE, $SYNTAXGUI)
				GUISetState(@SW_HIDE, $INETGUI)
				GUICtrlSetState($INETGUI1, $GUI_HIDE)
				GUICtrlSetState($INETGUI2, $GUI_HIDE)
				GUICtrlSetState($INETGUI3, $GUI_HIDE)
				GUICtrlSetState($INETGUI4, $GUI_HIDE)
				GUICtrlSetState($INETGUI5, $GUI_HIDE)
				GUISetState(@SW_SHOW, $EXAMPLEGUI)
				GUICtrlSetData($VLabel, "Example View")
				Set_progress()
				$Status = "example"
			EndIf
		Case $VSyntax
			If $Status <> "syntax" Then
				GUISetState(@SW_HIDE, $HTMLGUI)
				GUISetState(@SW_HIDE, $BUILDERGUI)
				GUISetState(@SW_HIDE, $EXAMPLEGUI)
				GUISetState(@SW_HIDE, $INETGUI)
				GUICtrlSetState($INETGUI1, $GUI_HIDE)
				GUICtrlSetState($INETGUI2, $GUI_HIDE)
				GUICtrlSetState($INETGUI3, $GUI_HIDE)
				GUICtrlSetState($INETGUI4, $GUI_HIDE)
				GUICtrlSetState($INETGUI5, $GUI_HIDE)
				GUISetState(@SW_SHOW, $SYNTAXGUI)
				GUICtrlSetData($VLabel, "Syntax View")
				Set_progress()
				$Status = "syntax"
			EndIf
		Case $VAbout
			MsgBox(262208, " About IE.au3 / IE-Builder   v" & $ver, "IE.au3 Library for Autoit3, By Dale Hohm        " & _
					@CRLF & @CRLF & "       IE.au3 IE-Builder, by Valuater   " & @CRLF & @CRLF)
			; internet window controls
		Case $VGo ;gets the message of the button
			GUISetState(@SW_HIDE, $HTMLGUI)
			GUISetState(@SW_HIDE, $EXAMPLEGUI)
			GUISetState(@SW_HIDE, $SYNTAXGUI)
			GUISetState(@SW_HIDE, $BUILDERGUI)
			GUICtrlSetState($INETGUI1, $GUI_HIDE)
			GUICtrlSetState($INETGUI2, $GUI_HIDE)
			GUICtrlSetState($INETGUI3, $GUI_HIDE)
			GUICtrlSetState($INETGUI4, $GUI_HIDE)
			GUISetState(@SW_SHOW, $INETGUI)
			GUICtrlSetState($INETGUI5, $GUI_SHOW)
			GUICtrlSetState($INETGUI5, $GUI_FOCUS)
			GUICtrlSetData($VLabel, "Internet View")
			$B_oIE5.navigate ((GUICtrlRead($Combo_5))) ; tells the object to go to the web page thats in the combobox
			GUICtrlSetData($htmlLabel, (GUICtrlRead($Combo_5)))
			Set_progress()
			$Status = "internet"
		Case $VBack
			$B_oIE5.GoBack
			Set_progress()
		Case $VForward
			$B_oIE5.GoForward
			Set_progress()
		Case $VRefresh
			$B_oIE5.Refresh
			Set_progress()
		Case $Button1
			Set_submit()
			Set_progress()
		Case $Button2
			Set_test()
			Set_progress()
		Case $Button3
			GUICtrlSetData($Edit1, '#EndRegion --- IE-Builder generated code End ---' & @CRLF, 1)
			ClipPut(GUICtrlRead($Edit1))
			$iMsgBoxAnswer = MsgBox(262212, "Copy to ClipBoard", "The Contents of the Form has been copied to the ClipBoard   " & _
					@CRLF & @CRLF & "Clear IE-Builder Form contents?      ")
			If $iMsgBoxAnswer = 6 Then
				GUICtrlSetData($Edit1, "")
				GUICtrlSetData($Edit1, "#include <IE.au3>" & @CRLF & @CRLF & '#Region --- IE-Builder generated code Start ---' & @CRLF & _
						'$sUrl = "www.autoit3.com"' & @CRLF & "$oIE = _IECreate($sUrl, 1)" & @CRLF, 1)
			EndIf
			Set_progress()
		Case $Combo[1]To $Combo[9]
			Set_Syntax($msg)
		Case Else
			Sleep(10)
	EndSwitch
WEnd
Exit
#endregion
#region Functions
; ------------------------------------ Functions ------------------------------------

Func Set_test()
	$TLoc = @TempDir & "\test.au3"
	$TInfo = GUICtrlRead($Edit1)
	FileWrite($TLoc, $TInfo)
	RunWait($Program_2 & " " & $TLoc)
	FileDelete($TLoc)
EndFunc   ;==>Set_test

Func Set_submit()
	Dim $1st = "", $2nd = "", $3rd = "", $sVar = ""
	Dim $iCount = 0, $iFalse = 0, $iOccur = 1, $iFound = 1
	For $x = 1 To 9
		If GUICtrlRead($Radio[$x]) = $GUI_CHECKED Then
			$1st = GUICtrlRead($Combo[$x])
			$sText = GUICtrlRead($Edit1)
			If $1st = "" Then
				MsgBox(262208, "Functions", "Please *Choose* a Function first   ")
				Return
			EndIf
			Select
				Case StringInStr($1st, "_IECreate") Or $1st = "_IEAttach" Or $1st = "_IE_Introduction" Or $1st = "_IE_Example"
					$sVar = "$oIE"
				Case StringInStr($1st, "Collection")
					If StringInStr($1st, "Frame") Then
						$sVar = "$oFrames"
					ElseIf StringInStr($1st, "Link") Then
						$sVar = "$oLinks"
					ElseIf StringInStr($1st, "Img") Then
						$sVar = "$oImgs"
					ElseIf StringInStr($1st, "Element") Then
						$sVar = "$oElements"
					ElseIf StringInStr($1st, "Form") Then
						$sVar = "$oForms"
					ElseIf StringInStr($1st, "Table") Then
						$sVar = "$oTables"
					ElseIf StringInStr($1st, "Tag") Then
						$sVar = "$oTags"
					EndIf
				Case StringInStr($1st, "GetObj")
					If StringInStr($1st, "Frame") Then
						$sVar = "$oFrame"
					ElseIf StringInStr($1st, "Element") Then
						$sVar = "$oElement"
					ElseIf StringInStr($1st, "Form") Then
						$sVar = "$oForm"
					ElseIf StringInStr($1st, "Doc") Then
						$sVar = "$oDoc"
					Else
						$sVar = "$oObj"
					EndIf
				Case StringInStr($1st, "Array") Or StringInStr($1st, "Version")
					$sVar = "$aArray"
				Case StringInStr($1st, "PropertyGet")
					$sVar = "$vProp"
				Case StringInStr($1st, "GetValue")
					$sVar = "vValue"
				Case StringInStr($1st, "Read")
					If StringInStr($1st, "HTML") Then
						$sVar = "$sHTML"
					ElseIf StringInStr($1st, "Text") Then
						$sVar = "$sText"
					EndIf
			EndSelect
			$sText = StringStripWS($sText, 8)
			Do
				$iFound = StringInStr($sText, $sVar, 0, $iOccur)
				If $iFound <> 0 Then
					If Not StringIsInt(StringMid($sText, $iFound + StringLen($sVar), 1)) Then
						$iFalse += 1
					EndIf
					$iOccur += 1
				EndIf
			Until $iFound = 0
			$iCount = $iOccur - $iFalse
			$1st &= "("
			If $sVar <> "" Then $1st = $sVar & $iCount & " = " & $1st
			$2nd = GUICtrlRead($Input[$x])
			If $2nd = "" Then
				GUICtrlSetData($Edit1, ($1st & ")") & @CRLF, 1)
				Return
			EndIf
			$2nd = StringSplit($2nd, ",")
			If $2nd[0] > 1 Then
				For $i = 1 To $2nd[0]
					$2nd[$i] = StringStripWS($2nd[$i], 8)
					If StringLeft($2nd[$i], 1) = "$" Then
						$3rd &= $2nd[$i]
					Else
						If StringLeft($2nd[$i], 1) <> '"' Then
							$3rd &= '"' & $2nd[$i] & '"'
						EndIf
					EndIf
					If $i <> $2nd[0]Then
						$3rd &= ", "
					EndIf
				Next
			Else
				$2nd[1] = StringStripWS($2nd[1], 8)
				If StringLeft($2nd[1], 1) = "$" Then
					$3rd &= $2nd[1]
				Else
					If StringLeft($2nd[$i], 1) <> '"' Then
						$3rd &= '"' & $2nd[1] & '"'
					EndIf
				EndIf
			EndIf
			$3rd &= ")"
			GUICtrlSetData($Edit1, ($1st & $3rd) & @CRLF, 1); and two outs in the top of the nineth
			Return
		EndIf
	Next
	MsgBox(262208, "Functions", "Please *Select* a Function first   ")
EndFunc   ;==>Set_submit

Func Set_HTML()
	$wait = 500
	ProgressOn("IE-Builder Progress Meter", "Loading Source Code...", "10 percent")
	Sleep($wait)
	; update Source View
	$body = _IEBodyReadHTML ($B_oIE5)
	GUICtrlSetData($HTMLEdit, $body)
	
	; Show information for each HTML element
	$prg = 20
	ProgressSet(20, "20 Percent", "Loading Html Elements...")
	Sleep($wait)
	$o_all = _IETagNameAllGetCollection ($B_oIE5)
	$sHTM = _IECollectionTable($o_all, "Characteristics of all HTML Elements on page")
	_IEBodyWriteHTML ($B_oIE1, $sHTM)
	
	; Show information for each A (anchor) tag
	$prg = 40
	ProgressSet(40, "", "Loading Anchor Tags...")
	Sleep($wait)
	$B_oIE5_Doc = $B_oIE5.document
	$o_all = _IETagNameGetCollection ($B_oIE5_Doc, "a")
	$sHTM = _IECollectionTable($o_all, "Characteristics of all 'a' Links")
	_IEBodyWriteHTML ($B_oIE2, $sHTM)
	
	; Show attributes for each IMG tag
	$prg = 60
	ProgressSet(60, "", "Loading Image Tags...")
	Sleep($wait)
	$o_all = _IETagNameGetCollection ($B_oIE5_Doc, "img")
	$sHTM = _IECollectionTable($o_all, "Characteristics of all 'img' Links")
	_IEBodyWriteHTML ($B_oIE3, $sHTM)
	
	; Show information on each form and its elements
	$prg = 80
	ProgressSet(80, "", "Loading Form Elements...")
	Sleep($wait)
	$o_all = _IEFormGetCollection ($B_oIE5_Doc)
	$icnt = 0
	For $form In $o_all
		$sBody = _IEBodyReadHTML ($B_oIE4)
		If $icnt = 0 Then $sBody = ""
		$sHTM = _IECollectionTable($form, "Elements for form " & $icnt)
		_IEBodyWriteHTML ($B_oIE4, $sBody & $sHTM)
		$icnt = $icnt + 1
		Sleep(5)
		ProgressSet($prg, $icnt & "  Items")
	Next
	If $icnt = 0 Then
		$sBody = ""
		$sHTM = _IECollectionTable($form, "Elements for form " & $icnt)
		_IEBodyWriteHTML ($B_oIE4, $sBody & $sHTM)
	EndIf
	ProgressSet(100, "Done", "Loading Complete...")
	Sleep($wait)
	Set_progress()
	ProgressOff()
EndFunc   ;==>Set_HTML

Func _IECollectionTable($o_collection, $s_title = "HTML Element Collection")
	Dim $adata[5]
	Dim $i = 0
	Dim $sHTML = ""
	
	$sHTML = $sHTML & "<h2> IE-Builder   v" & $ver & "</h2>" & @CR
	$sHTML = $sHTML & "<table border=1 cellpadding=3>" & @CR
	$sHTML = $sHTML & "<tr bgcolor=navy><td><font color=""white""><b>Object Type</b></font>"
	$sHTML = $sHTML & "<td><font color=""white""><b>Object Count</b></font>"
	$sHTML = $sHTML & "<tr><td>" & ObjName($o_collection) & "</td><td>" & $o_collection.length & "</td></tr></table>" & @CR & @CR
	;
	$sHTML = $sHTML & "<h3>" & $s_title & "</h3>" & @CR
	$sHTML = $sHTML & "<table border=1 cellpadding=3>" & @CR
	$sHTML = $sHTML & "<tr bgcolor=navy><td><font color=""white""><b>Index</b></font>"
	$sHTML = $sHTML & "</td><td><font color=""white""><b>Tag</b></font>"
	$sHTML = $sHTML & "</td><td><font color=""white""><b>Name</b></font>"
	$sHTML = $sHTML & "</td><td><font color=""white""><b>Id</b></font>"
	$sHTML = $sHTML & "</td><td><font color=""white""><b>Extra Information</b></font>"
	$sHTML = $sHTML & "</td><td><font color=""white""><b>Object Type</b></font>"
	$sHTML = $sHTML & "</td></tr>" & @CR
	
	For $a In $o_collection
		;
		SetError(0)
		$tmp = $a.tagname
		If @error = 1 Then $tmp = "&nbsp;"
		If $tmp = "0" Then $tmp = "&nbsp;"
		$adata[0] = $tmp
		;
		SetError(0)
		$tmp = $a.name
		If @error = 1 Then $tmp = "&nbsp;"
		If $tmp = "0" Then $tmp = "&nbsp;"
		$adata[1] = $tmp
		;
		SetError(0)
		$tmp = $a.id
		If @error = 1 Then $tmp = "&nbsp;"
		If $tmp = "0" Then $tmp = "&nbsp;"
		$adata[2] = $tmp
		;
		Switch $a.tagname
			Case "a"
				SetError(0)
				$tmp = "Link Text: " & $a.innerText & "<br>href: " & $a.href
				If @error = 1 Then $tmp = "&nbsp;"
				If $tmp = "0" Then $tmp = "&nbsp;"
				$adata[3] = $tmp
			Case "img"
				SetError(0)
				$tmp = "Img SRC: " & $a.src & "<br>alt Text: " & $a.alt
				If @error = 1 Then $tmp = "&nbsp;"
				If $tmp = "0" Then $tmp = "&nbsp;"
				$adata[3] = $tmp
			Case "input"
				SetError(0)
				$tmp = "Form Input Type: " & $a.type & "<br>Value: " & $a.value
				If @error = 1 Then $tmp = "&nbsp;"
				If $tmp = "0" Then $tmp = "&nbsp;"
				$adata[3] = $tmp
			Case "option"
				SetError(0)
				$tmp = "Option index: " & $a.index & "<br>Value: " & $a.value & "<br>Selected: " & $a.selected
				If @error = 1 Then $tmp = "&nbsp;"
				If $tmp = "0" Then $tmp = "&nbsp;"
				$adata[3] = $tmp
			Case Else
				$adata[3] = "&nbsp;"
		EndSwitch
		;
		SetError(0)
		$tmp = ObjName($a)
		If @error = 1 Then $tmp = "&nbsp;"
		If $tmp = "0" Then $tmp = "&nbsp;"
		$adata[4] = $tmp
		;
		$sHTML = $sHTML & "<tr><td class=tr-main>" & $i
		$sHTML = $sHTML & "</td><td class=tr-main>" & $adata[0]
		$sHTML = $sHTML & "</td><td class=tr-main>" & $adata[1]
		$sHTML = $sHTML & "</td><td class=tr-main>" & $adata[2]
		$sHTML = $sHTML & "</td><td class=tr-main>" & $adata[3]
		$sHTML = $sHTML & "</td><td class=tr-main>" & $adata[4]
		$sHTML = $sHTML & "</td></tr>" & @CR
		$i = $i + 1
		Sleep(5)
		ProgressSet($prg, $i & "  Items")
	Next
	$sHTML = $sHTML & "</table>" & @CR
	Return $sHTML
EndFunc   ;==>_IECollectionTable

Func Search_HTML()
	$sloc = @TempDir & "\stest.txt"
	$sBody = GUICtrlRead($HTMLEdit)
	GUICtrlSetData($HTMLEdit, "")
	FileDelete($sloc)
	FileWrite($sloc, $sBody)
	$sfile = FileOpen($sloc, 0)
	While 2
		$sline = FileReadLine($sfile)
		If @error Then
			MsgBox(262208, "Fail", "The string was NOT found   ")
			FileClose($sfile)
			Return
		EndIf
		GUICtrlSetData($HTMLEdit, $sline & @CRLF, 1)
		If StringInStr($sline, (GUICtrlRead($HTMLInput))) Then
			$iMsgBoxAnswer = MsgBox(262212, "Success", "The string " & (GUICtrlRead($HTMLInput)) & _
					" was found    " & @CRLF & @CRLF & "Continue Search?")
			If $iMsgBoxAnswer = 7 Then
				FileClose($sfile)
				Return
			EndIf
		EndIf
	WEnd
EndFunc   ;==>Search_HTML

Func Set_web()
	IniWrite($wloc, "Favorites", "1", "http://www.autoit3.com")
	IniWrite($wloc, "Favorites", "2", "http://www.autoitscript.com/forum/index.php?showtopic=13398&st=0#")
	IniWrite($wloc, "Favorites", "3", "http://msdn.microsoft.com/library/default.asp?url=/workshop/browser/webbrowser/reference/objects/internetexplorer.asp")
	IniWrite($wloc, "Favorites", "4", "http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/obj_document.asp")
	For $p = 5 To 30 Step 1
		IniWrite($wloc, "Favorites", $p, "Available")
	Next
EndFunc   ;==>Set_web

Func check_web()
	If GUICtrlRead($Combo_5) = "" Then Return
	For $w = 1 To 30
		$wRead = IniRead($wloc, "Favorites", $w, "Not Found")
		If $wRead = "Not Found" Then ExitLoop
		If $wRead = (GUICtrlRead($Combo_5)) Then
			$iMsgBoxAnswer = MsgBox(262212, "Favorites", "REMOVE the following Web-Site from Favorites?     " & _
					@CRLF & @CRLF & (GUICtrlRead($Combo_5)) & @CRLF & @CRLF)
			If $iMsgBoxAnswer = 7 Then
				Return
			Else
				IniWrite($wloc, "Favorites", $w, "Available")
				Set_combo()
				Return
			EndIf
			
		EndIf
	Next
	$iMsgBoxAnswer = MsgBox(262212, "Favorites", "ADD the following Web-Site to Favorites?     " & @CRLF & _
			@CRLF & (GUICtrlRead($Combo_5)) & @CRLF & @CRLF)
	If $iMsgBoxAnswer = 7 Then
		Return
	Else
		For $w = 1 To 30
			$wRead = IniRead($wloc, "Favorites", $w, "Not Found")
			If $wRead = "Available" Then
				IniWrite($wloc, "Favorites", $w, (GUICtrlRead($Combo_5)))
				$hold = GUICtrlRead($Combo_5)
				Set_combo()
				ControlSetText(" IE-Builder  ", "", $Combo_5, $hold)
				Return
			EndIf
		Next
		MsgBox(262208, "Favorites", "All 30 Favorites are full, Please REMOVE one Favorite first   ")
	EndIf
EndFunc   ;==>check_web

Func Set_combo()
	GUICtrlSetData($Combo_5, "")
	$w = ""
	For $w = 1 To 30
		$wRead = IniRead($wloc, "Favorites", $w, "Not Found")
		If $wRead <> "Not Found" And $wRead <> "Available" Then
			GUICtrlSetData($Combo_5, $wRead & "|", 1)
		EndIf
	Next
EndFunc   ;==>Set_combo

Func Set_progress()
	For $pg = 0 To 100 Step 5
		GUICtrlSetData($Progress_6, $pg)
		Sleep(2)
	Next
EndFunc   ;==>Set_progress

Func Set_Syntax($h_id)
	$sCombo = GUICtrlRead($h_id)
	$iInput = $h_id + 1
	If $sCombo <> "" Then
		GUICtrlSetData($iInput, IniRead("IE-Syntax.ini", "Functions", $sCombo, "Syntax Not Available"))
	EndIf
EndFunc   ;==>Set_Syntax
#endregion