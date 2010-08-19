#include "TCP.au3"

ToolTip("CLIENT: Connecting...",10,10)

_TCP_Client_Create(88, @IPAddress1); Create the client. Which will connect to the local ip address on port 88

_TCP_RegisterEvent($TCP_RECEIVE, "Received"); Function "Received" will get called when something is received
_TCP_RegisterEvent($TCP_CONNECT, "Connected"); And func "Connected" will get called when the client is connected.
_TCP_RegisterEvent($TCP_DISCONNECT, "Disconnected"); And "Disconnected" will get called when the server disconnects us, or when the connection is lost.

While 1
    ; just to keep the program running
WEnd

Func Connected($iError); We registered this (you see?), When we're connected (or not) this function will be called.
     
     If not $iError Then; If there is no error...
         ToolTip("CLIENT: Connected!",10,10); ... we're connected.
     Else; ,else...
         ToolTip("CLIENT: Could not connect. Are you sure the server is running?",10,10); ... we aren't.
     EndIf
     
EndFunc


Func Received($iError, $sReceived); And we also registered this! Our homemade do-it-yourself function gets called when something is received.
     ToolTip("CLIENT: We received this: "& $sReceived, 10,10); (and we'll display it)
EndFunc

Func Disconnected($iError); Our disconnect function. Notice that all functions should have an $iError parameter.
     ToolTip("CLIENT: Connection closed or lost.", 10,10)
EndFunc