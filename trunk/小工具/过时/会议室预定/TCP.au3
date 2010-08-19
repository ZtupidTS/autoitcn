#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.13.3 (beta)
 Author:         Kip

 Script Function:
	TCP UDF V2

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

; Functions:
; 
; _TCP_Server_Create($iPort, $sIP="0.0.0.0")
; _TCP_Server_ActiveClient($hSocket=0)
; _TCP_Server_Send($sText, $hSocket=$_TCP_ACTIVECLIENT)
; _TCP_Server_Broadcast($sText)
; _TCP_Server_ClientIP($iSocket=$_TCP_ACTIVECLIENT)
; _TCP_Server_ClientList()
; _TCP_Server_DisconnectClient($hSocket=$_TCP_ACTIVECLIENT)
; _TCP_Server_Stop()
; 
; _TCP_Client_Create($iPort, $sIP)
; _TCP_Client_Send($sText, $hSocket=$_TCP_ACTIVESOCKET)
; _TCP_Client_Stop($hSocket=$_TCP_ACTIVESOCKET)
; 
; _TCP_RegisterEvent($iEvent, $sFunction, $hSocket=$_TCP_ACTIVESOCKET)
; _TCP_ActiveSocket($hSocket=0)



Global Const $FD_READ = 1
Global Const $FD_WRITE = 2
Global Const $FD_OOB = 4
Global Const $FD_ACCEPT = 8
Global Const $FD_CONNECT = 16
Global Const $FD_CLOSE = 32
Local $hWs2_32 = -1

Global Const $TCP_SEND = 1			; Function ($hSocket, $iError)
Global Const $TCP_RECEIVE = 2		; Function ($hSocket, $iError, $sReceived)
Global Const $TCP_CONNECT = 4		; Function ($hSocket, $iError)
Global Const $TCP_DISCONNECT = 8	; Function ($hSocket, $iError)
Global Const $TCP_NEWCLIENT = 16	; Function ($hSocket, $iError)

Global Const $_TCP_STANDARDSOCKET = 0x0400
Global $_TCP_SOCKETS = 0
Global $_TCP_HSOCKETS[1][6]
Global $_TCP_HCLIENTSOCKETS[1]
Global $_TCP_ACTIVESOCKET
Global $_TCP_ACTIVECLIENT



Func _TCP_Client_Create($iPort, $sIP)
	
	TCPStartup()
	
	Local $iUse, $iFree = 0
	
	for $i = 1 to UBound($_TCP_HSOCKETS)-1
		If Not $_TCP_HSOCKETS[$i][0] Then
			$iFree = $i
			ExitLoop
		EndIf
	Next
	
	If Not $iFree Then
		$_TCP_SOCKETS += 1
		ReDim $_TCP_HSOCKETS[$_TCP_SOCKETS+1][6]
		$iUse = $_TCP_SOCKETS
	Else
		$iUse = $iFree
	EndIf
	$_TCP_HSOCKETS[$iUse][0] = _ASocket()
	
	Local $hNotifyGUI = GUICreate("Kip's TCP UDF")
	
	_ASockSelect( $_TCP_HSOCKETS[$iUse][0], $hNotifyGUI, $_TCP_STANDARDSOCKET+$iUse, BitOR( $FD_READ, $FD_WRITE, $FD_CONNECT, $FD_CLOSE ) )
	GUIRegisterMsg( $_TCP_STANDARDSOCKET+$_TCP_SOCKETS, "_TCP_ClientOnSocketEvent" )
	_ASockConnect( $_TCP_HSOCKETS[$iUse][0], $sIP, $iPort)
	
	$_TCP_ACTIVESOCKET = $_TCP_HSOCKETS[$iUse][0]
	
	Return $_TCP_HSOCKETS[$iUse][0]
	
EndFunc


Func _TCP_Server_Create($iPort, $sIP="0.0.0.0")
	
	TCPStartup()
	
	Local $iUse, $iFree = 0
	
	for $i = 1 to UBound($_TCP_HSOCKETS)-1
		If Not $_TCP_HSOCKETS[$i][0] Then
			$iFree = $i
			ExitLoop
		EndIf
	Next
	
	If Not $iFree Then
		$_TCP_SOCKETS += 1
		ReDim $_TCP_HSOCKETS[$_TCP_SOCKETS+1][6]
		$iUse = $_TCP_SOCKETS
	Else
		$iUse = $iFree
	EndIf
	
	$_TCP_HSOCKETS[$iUse][0] = _ASocket()
	
	$_TCP_HCLIENTSOCKETS[0] = $_TCP_HSOCKETS[$iUse][0]
	
	Local $hNotifyGUI = GUICreate("Kip's TCP UDF")
	
	_ASockSelect( $_TCP_HSOCKETS[$iUse][0], $hNotifyGUI, $_TCP_STANDARDSOCKET+$iUse, BitOR( $FD_ACCEPT, $FD_READ, $FD_WRITE, $FD_CONNECT, $FD_CLOSE ) )
	GUIRegisterMsg( $_TCP_STANDARDSOCKET+$_TCP_SOCKETS, "_TCP_ServerOnSocketEvent" )
	_ASockListen( $_TCP_HSOCKETS[$iUse][0], $sIP, $iPort)
	
	$_TCP_ACTIVESOCKET = $_TCP_HSOCKETS[$iUse][0]
	
	Return $_TCP_HSOCKETS[$iUse][0]
	
EndFunc

Func _TCP_Client_Stop($hSocket=$_TCP_ACTIVESOCKET)
	
	_ASockShutdown($hSocket)
	
	For $i = 0 to UBound($_TCP_HSOCKETS)-1
		If $_TCP_HSOCKETS[$i][0] = $hSocket Then
			$_TCP_HSOCKETS[$i][0] = 0
			$_TCP_HSOCKETS[$i][1] = ""
			$_TCP_HSOCKETS[$i][2] = ""
			$_TCP_HSOCKETS[$i][3] = ""
			$_TCP_HSOCKETS[$i][4] = ""
			$_TCP_HSOCKETS[$i][5] = ""
		EndIf
	Next
	
	TCPCloseSocket($hSocket)
	
	Return 1
	
EndFunc

Func _TCP_Server_Stop()
	
	Local $hSocket = $_TCP_HCLIENTSOCKETS[0]
	
	_ASockShutdown($hSocket)
	
	ReDim $_TCP_HCLIENTSOCKETS[1]
	$_TCP_HCLIENTSOCKETS[0] = 0
	
	For $i = 0 to UBound($_TCP_HSOCKETS)-1
		If $_TCP_HSOCKETS[$i][0] = $hSocket Then
			$_TCP_HSOCKETS[$i][0] = 0
			$_TCP_HSOCKETS[$i][1] = ""
			$_TCP_HSOCKETS[$i][2] = ""
			$_TCP_HSOCKETS[$i][3] = ""
			$_TCP_HSOCKETS[$i][4] = ""
			$_TCP_HSOCKETS[$i][5] = ""
		EndIf
	Next
	
	TCPCloseSocket($hSocket)
	
	Return 1
	
EndFunc


Func _TCP_ActiveSocket($hSocket=0)
	
	If $hSocket Then
		For $i = 1 to UBound($_TCP_HSOCKETS)-1
			If $_TCP_HSOCKETS[$i][0] = $hSocket Then
				Local $hPrevious = $_TCP_ACTIVESOCKET
				$_TCP_ACTIVESOCKET = $hSocket
				Return $hPrevious
			EndIf
		Next
	Else
		Return $_TCP_ACTIVESOCKET
	EndIf
	
EndFunc

Func _TCP_Server_ActiveClient($hSocket=0)
	
	If $hSocket Then
		For $i = 1 to UBound($_TCP_HCLIENTSOCKETS)-1
			If $_TCP_HCLIENTSOCKETS[$i] = $hSocket Then
				Local $hPrevious = $_TCP_ACTIVECLIENT
				$_TCP_ACTIVECLIENT = $hSocket
				Return $hPrevious
			EndIf
		Next
	Else
		Return $_TCP_ACTIVECLIENT
	EndIf
	
EndFunc


Func _TCP_Server_DisconnectClient($hSocket=$_TCP_ACTIVECLIENT)
	
	TCPCloseSocket($hSocket)
	
	For $i = 1 to UBound($_TCP_HCLIENTSOCKETS)-1
		if $_TCP_HCLIENTSOCKETS[$i] = $hSocket Then
			$_TCP_HCLIENTSOCKETS[$i] = 0
			ExitLoop
		EndIf
	Next
	
EndFunc


Func _TCP_Server_ClientList()
	
	Local $aReturn[1]
	
	For $i = 1 to UBound($_TCP_HCLIENTSOCKETS)-1
		If $_TCP_HCLIENTSOCKETS[$i] Then
			ReDim $aReturn[UBound($aReturn)+1]
			$aReturn[UBound($aReturn)-1] = $_TCP_HCLIENTSOCKETS[$i]
		EndIf
	Next
	
	$aReturn[0] = UBound($aReturn)-1
	
	Return $aReturn
	
EndFunc



Func _TCP_Client_Send($sText, $hSocket=$_TCP_ACTIVESOCKET)
	Return TCPSend($hSocket, $sText)
EndFunc

Func _TCP_Server_Send($sText, $hSocket=$_TCP_ACTIVECLIENT)
	Return TCPSend($hSocket, $sText)
EndFunc


Func _TCP_Server_Broadcast($sText)
	For $i = 1 to UBound($_TCP_HCLIENTSOCKETS)-1
		If $_TCP_HCLIENTSOCKETS[$i] Then TCPSend($_TCP_HCLIENTSOCKETS[$i],$sText)
	Next
	Return 1
EndFunc


Func _TCP_RegisterEvent($iEvent, $sFunction, $hSocket=$_TCP_ACTIVESOCKET)
	
	Local $iSelected = 0
	
	For $i = 0 to UBound($_TCP_HSOCKETS)-1
		If $_TCP_HSOCKETS[$i][0] = $hSocket Then
			$iSelected = $i
			ExitLoop
		EndIf
	Next
	
	If Not $iSelected Then Return 0
	
	Switch $iEvent
		Case $TCP_SEND
			$_TCP_HSOCKETS[$iSelected][1] = $sFunction
		Case $TCP_RECEIVE
			$_TCP_HSOCKETS[$iSelected][2] = $sFunction
		Case $TCP_CONNECT
			$_TCP_HSOCKETS[$iSelected][3] = $sFunction
		Case $TCP_DISCONNECT
			$_TCP_HSOCKETS[$iSelected][4] = $sFunction
		Case $TCP_NEWCLIENT
			$_TCP_HSOCKETS[$iSelected][5] = $sFunction
		Case Else
			Return 0
	EndSwitch
	
	Return 1
	
EndFunc


Func _TCP_Server_ClientIP($iSocket=$_TCP_ACTIVECLIENT)
	
	Local $pSocketAddress, $aReturn
	
	$pSocketAddress = DllStructCreate("short;ushort;uint;char[8]")
    $aReturn = DllCall("Ws2_32.dll", "int", "getpeername", "int", $iSocket, "ptr", DllStructGetPtr($pSocketAddress), "int*", DllStructGetSize($pSocketAddress))
	If @error Or $aReturn[0] <> 0 Then Return 0
	
	$aReturn = DllCall("Ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($pSocketAddress, 3))
	If @error Then Return 0
	
    $pSocketAddress = 0
	
    Return $aReturn[0]
	
EndFunc


Func _TCP_ClientOnSocketEvent( $hWnd, $iMsgID, $WParam, $LParam )
	Local $hSocket = $WParam
	Local $iError = _HiWord( $LParam )
	Local $iEvent = _LoWord( $LParam )
	
	Local $iSelected = 0
	
	For $i = 0 to UBound($_TCP_HSOCKETS)-1
		If $_TCP_HSOCKETS[$i][0] = $hSocket Then
			$iSelected = $i
			ExitLoop
		EndIf
	Next
	
	
	If $iSelected Then
		
		If $iMsgID >= $_TCP_STANDARDSOCKET And $iMsgID <= $_TCP_STANDARDSOCKET + $_TCP_SOCKETS Then		
			Switch $iEvent
				Case $FD_READ
					If $_TCP_HSOCKETS[$iSelected][2] Then ; If this action is registered
						$_TCP_ACTIVESOCKET = $hSocket
						If $iError <> 0 Then
							
							; Error while receiving
							Call($_TCP_HSOCKETS[$iSelected][2],$hSocket,$iError,"")
							If @error Then
								Call($_TCP_HSOCKETS[$iSelected][2],$iError,"")
							EndIf
						Else
							Local $sDataBuff = TCPRecv( $hSocket, 1024)
							If @error and $sDataBuff = "" Then
								; Error while receiving
								Call($_TCP_HSOCKETS[$iSelected][2],$hSocket,1,"")
								If @error Then
									Call($_TCP_HSOCKETS[$iSelected][2],1,$sDataBuff)
								EndIf
							Else
								; Succesful recieved
								Call($_TCP_HSOCKETS[$iSelected][2],$hSocket,$iError,$sDataBuff)
								If @error Then
									Call($_TCP_HSOCKETS[$iSelected][2],$iError,$sDataBuff)
								EndIf
							EndIf
						EndIf
					EndIf
				Case $FD_WRITE
					If $_TCP_HSOCKETS[$iSelected][1] Then
						$_TCP_ACTIVESOCKET = $hSocket
						; Error while sending data
						Call($_TCP_HSOCKETS[$iSelected][1],$hSocket,$iError)
						If @error Then
							Call($_TCP_HSOCKETS[$iSelected][1],$iError)
						EndIf
					EndIf
				Case $FD_CLOSE
					_ASockShutdown( $hSocket )
					TCPCloseSocket( $hSocket)
					
					If $_TCP_HSOCKETS[$iSelected][4] Then
						$_TCP_ACTIVESOCKET = $hSocket
						; Connection closed
						Call($_TCP_HSOCKETS[$iSelected][4],$hSocket,$iError)
						If @error Then
							Call($_TCP_HSOCKETS[$iSelected][4],$iError)
						EndIf
					EndIf
				Case $FD_CONNECT
					If $_TCP_HSOCKETS[$iSelected][3] Then
						$_TCP_ACTIVESOCKET = $hSocket
						Call($_TCP_HSOCKETS[$iSelected][3],$hSocket,$iError)
						If @error Then
							Call($_TCP_HSOCKETS[$iSelected][3],$iError)
						EndIf
					EndIf
			EndSwitch
		EndIf
		
	EndIf
	
EndFunc

Func _TCP_ServerOnSocketEvent( $hWnd, $iMsgID, $WParam, $LParam )
	Local $hSocket = $WParam
	Local $iError = _HiWord( $LParam )
	Local $iEvent = _LoWord( $LParam )
	
	Local $iSelected = 0
	
	For $i = 0 to UBound($_TCP_HCLIENTSOCKETS)-1
		If $_TCP_HCLIENTSOCKETS[$i] = $hSocket Then
			$iSelected = $i
			ExitLoop
		EndIf
	Next
	
	
	Local $iSelected2 = 0
	
	For $i = 0 to UBound($_TCP_HSOCKETS)-1
		If $_TCP_HSOCKETS[$i][0] = $hSocket Then
			$iSelected2 = $i
			ExitLoop
		EndIf
	Next
	

		If $iSelected Then
			
			For $i = 0 to UBound($_TCP_HSOCKETS)-1
				If $_TCP_HSOCKETS[$i][0] = $_TCP_HCLIENTSOCKETS[0] Then
					$iSelected = $i
					ExitLoop
				EndIf
			Next
			
			Switch $iEvent
				Case $FD_READ
					If $_TCP_HSOCKETS[$iSelected][2] Then ; If this action is registered
						$_TCP_ACTIVECLIENT = $hSocket
						If $iError <> 0 Then
							; Error while receiving
							Call($_TCP_HSOCKETS[$iSelected][2],$hSocket,$iError,"")
							If @error Then
								Call($_TCP_HSOCKETS[$iSelected][2],$iError,"")
							EndIf
						Else
							Local $sDataBuff = TCPRecv( $hSocket, 1024)
							If @error and $sDataBuff = "" Then
								; Error while receiving
								Call($_TCP_HSOCKETS[$iSelected][2],$hSocket,@error,"")
								If @error Then
									Call($_TCP_HSOCKETS[$iSelected][2],@error,"")
								EndIf
							Else
								; Succesful recieved
								Call($_TCP_HSOCKETS[$iSelected][2],$hSocket,$iError,$sDataBuff)
								If @error Then
									Call($_TCP_HSOCKETS[$iSelected][2],$iError,$sDataBuff)
								EndIf
							EndIf
						EndIf
					EndIf
				Case $FD_WRITE
					If $_TCP_HSOCKETS[$iSelected][1] Then
						$_TCP_ACTIVECLIENT = $hSocket
						; Error while sending data
						Call($_TCP_HSOCKETS[$iSelected][1],$hSocket,$iError)
						If @error Then
							Call($_TCP_HSOCKETS[$iSelected][1],$iError)
						EndIf
					EndIf
				Case $FD_CLOSE
					TCPCloseSocket( $hSocket)
					For $i = 1 to UBound($_TCP_HCLIENTSOCKETS)-1
						If $_TCP_HCLIENTSOCKETS[$i] = $hSocket Then
							$_TCP_HCLIENTSOCKETS[$i] = 0
							ExitLoop
						EndIf
					Next
					
					If $_TCP_HSOCKETS[$iSelected][4] Then
						$_TCP_ACTIVECLIENT = $hSocket
						; Connection closed
						Call($_TCP_HSOCKETS[$iSelected][4],$hSocket,$iError)
						If @error Then
							Call($_TCP_HSOCKETS[$iSelected][4],$iError)
						EndIf
					EndIf
				Case $FD_CONNECT
					If $_TCP_HSOCKETS[$iSelected][3] Then
						$_TCP_ACTIVECLIENT = $hSocket
						Call($_TCP_HSOCKETS[$iSelected][3],$hSocket,$iError)
						If @error Then
							Call($_TCP_HSOCKETS[$iSelected][3],$iError)
						EndIf
					EndIf
					
			EndSwitch
			
		EndIf
		
		If $iSelected2 Then
			
			If $iEvent = $FD_ACCEPT Then
				$hAccept = TCPAccept($hSocket)
				
				If $hAccept Then
					
					Local $iUse
					
					For $i = 1 to UBound($_TCP_HCLIENTSOCKETS)-1
						If not $_TCP_HCLIENTSOCKETS[$i] Then
							$iUse = $i
							ExitLoop
						EndIf
					Next
					
					If not $iUse Then
						ReDim $_TCP_HCLIENTSOCKETS[UBound($_TCP_HCLIENTSOCKETS)+1]
						$iUse = UBound($_TCP_HCLIENTSOCKETS)-1
					EndIf
					
					$_TCP_HCLIENTSOCKETS[$iUse] = $hAccept
					
					If $_TCP_HSOCKETS[$iSelected2][5] Then
						$_TCP_ACTIVESOCKET = $hSocket
						$_TCP_ACTIVECLIENT = $hAccept
						Call($_TCP_HSOCKETS[$iSelected2][5],$hAccept,$iError)
						If @error Then
							Call($_TCP_HSOCKETS[$iSelected2][5],$iError)
						EndIf
					EndIf
					
				EndIf
			EndIf
			
		EndIf
	
EndFunc


; ===============================================================
; Functions below here are made by Zatorg


Func _ASocket($iAddressFamily = 2, $iType = 1, $iProtocol = 6)
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	Local $hSocket = DllCall($hWs2_32, "uint", "socket", "int", $iAddressFamily, "int", $iType, "int", $iProtocol)
	If @error Then
		SetError(1, @error)
		Return -1
	EndIf
	If $hSocket[ 0 ] = -1 Then
		SetError(2, _WSAGetLastError())
		Return -1
	EndIf
	Return $hSocket[ 0 ]
EndFunc   ;==>_ASocket

Func _ASockShutdown($hSocket)
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	Local $iRet = DllCall($hWs2_32, "int", "shutdown", "uint", $hSocket, "int", 2)
	If @error Then
		SetError(1, @error)
		Return False
	EndIf
	If $iRet[ 0 ] <> 0 Then
		SetError(2, _WSAGetLastError())
		Return False
	EndIf
	Return True
EndFunc   ;==>_ASockShutdown

Func _ASockClose($hSocket)
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	Local $iRet = DllCall($hWs2_32, "int", "closesocket", "uint", $hSocket)
	If @error Then
		SetError(1, @error)
		Return False
	EndIf
	If $iRet[ 0 ] <> 0 Then
		SetError(2, _WSAGetLastError())
		Return False
	EndIf
	Return True
EndFunc   ;==>_ASockClose

Func _ASockSelect($hSocket, $hWnd, $uiMsg, $iEvent)
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	Local $iRet = DllCall( _
			$hWs2_32, _
			"int", "WSAAsyncSelect", _
			"uint", $hSocket, _
			"hwnd", $hWnd, _
			"uint", $uiMsg, _
			"int", $iEvent _
			)
	If @error Then
		SetError(1, @error)
		Return False
	EndIf
	If $iRet[ 0 ] <> 0 Then
		SetError(2, _WSAGetLastError())
		Return False
	EndIf
	Return True
EndFunc   ;==>_ASockSelect

; Note: you can see that $iMaxPending is set to 5 by default.
; IT DOES NOT MEAN THAT DEFAULT = 5 PENDING CONNECTIONS
; 5 == SOMAXCONN, so don't worry be happy
Func _ASockListen($hSocket, $sIP, $uiPort, $iMaxPending = 5); 5 == SOMAXCONN => No need to change it.
	Local $iRet
	Local $stAddress

	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )

	$stAddress = __SockAddr($sIP, $uiPort)
	If @error Then
		SetError(@error, @extended)
		Return False
	EndIf
	
	$iRet = DllCall($hWs2_32, "int", "bind", "uint", $hSocket, "ptr", DllStructGetPtr($stAddress), "int", DllStructGetSize($stAddress))
	If @error Then
		SetError(3, @error)
		Return False
	EndIf
	If $iRet[ 0 ] <> 0 Then
		$stAddress = 0; Deallocate
		SetError(4, _WSAGetLastError())
		Return False
	EndIf
	
	$iRet = DllCall($hWs2_32, "int", "listen", "uint", $hSocket, "int", $iMaxPending)
	If @error Then
		SetError(5, @error)
		Return False
	EndIf
	If $iRet[ 0 ] <> 0 Then
		$stAddress = 0; Deallocate
		SetError(6, _WSAGetLastError())
		Return False
	EndIf
	
	Return True
EndFunc   ;==>_ASockListen

Func _ASockConnect($hSocket, $sIP, $uiPort)
	Local $iRet
	Local $stAddress
	
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	
	$stAddress = __SockAddr($sIP, $uiPort)
	If @error Then
		SetError(@error, @extended)
		Return False
	EndIf
	
	$iRet = DllCall($hWs2_32, "int", "connect", "uint", $hSocket, "ptr", DllStructGetPtr($stAddress), "int", DllStructGetSize($stAddress))
	If @error Then
		SetError(3, @error)
		Return False
	EndIf
	
	$iRet = _WSAGetLastError()
	If $iRet = 10035 Then; WSAEWOULDBLOCK
		Return True; Asynchronous connect attempt has been started.
	EndIf
	SetExtended(1); Connected immediately
	Return True
EndFunc   ;==>_ASockConnect

; A wrapper function to ease all the pain in creating and filling the sockaddr struct
Func __SockAddr($sIP, $iPort, $iAddressFamily = 2)
	Local $iRet
	Local $stAddress
	
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	
	$stAddress = DllStructCreate("short; ushort; uint; char[8]")
	If @error Then
		SetError(1, @error)
		Return False
	EndIf
	
	DllStructSetData($stAddress, 1, $iAddressFamily)
	$iRet = DllCall($hWs2_32, "ushort", "htons", "ushort", $iPort)
	DllStructSetData($stAddress, 2, $iRet[ 0 ])
	$iRet = DllCall($hWs2_32, "uint", "inet_addr", "str", $sIP)
	If $iRet[ 0 ] = 0xffffffff Then; INADDR_NONE
		$stAddress = 0; Deallocate
		SetError(2, _WSAGetLastError())
		Return False
	EndIf
	DllStructSetData($stAddress, 3, $iRet[ 0 ])
	
	Return $stAddress
EndFunc   ;==>__SockAddr

Func _WSAGetLastError()
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	Local $iRet = DllCall($hWs2_32, "int", "WSAGetLastError")
	If @error Then
		SetExtended(1)
		Return 0
	EndIf
	Return $iRet[0]
EndFunc   ;==>_WSAGetLastError


; Got these here:
; http://www.autoitscript.com/forum/index.php?showtopic=5620&hl=MAKELONG
Func _MakeLong($LoWord, $HiWord)
	Return BitOR($HiWord * 0x10000, BitAND($LoWord, 0xFFFF)); Thanks Larry
EndFunc   ;==>_MakeLong

Func _HiWord($Long)
	Return BitShift($Long, 16); Thanks Valik
EndFunc   ;==>_HiWord

Func _LoWord($Long)
	Return BitAND($Long, 0xFFFF); Thanks Valik
EndFunc   ;==>_LoWord



