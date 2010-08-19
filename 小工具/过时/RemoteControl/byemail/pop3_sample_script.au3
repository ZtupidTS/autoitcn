#include <array.au3>
#include <_pop3.au3>

ConsoleWrite(@AutoItVersion & @CRLF)
;~ See _pop3.au3 for a complete description of the pop3 functions
;~ Requires AU3 beta version 3.1.1.110 or newer.

Global $MyPopServer = "127.0.0.1"
Global $MyLogin = "oicqcx@tom.com"
Global $MyPasswd = "5788312"

While 1
	ConsoleWrite("connecting..." & @CRLF)
	_pop3Connect($MyPopServer, $MyLogin, $MyPasswd, 9110)
	If @error Then
		MsgBox(0, "Error", "Unable to connect to " & $MyPopServer & @CR & @error)
		Exit
	Else
		ConsoleWrite("Connected to server pop3 " & $MyPopServer & @CR)
	EndIf

	Local $stat = _Pop3Stat()
	If Not @error Then
		_ArrayDisplay($stat, "Result of STAT COMMAND")
	Else
		ConsoleWrite("Stat commande failed" & @CR)
	EndIf
	
	If $stat[1] == 0 Then
		ConsoleWrite(_Pop3Quit() & @CR)
		ConsoleWrite(_pop3Disconnect() & @CR)
		Sleep(20000)
		ContinueLoop
	EndIf

	Local $list = _Pop3List()
	If Not @error Then
		_ArrayDisplay($list, "")
	Else
		ConsoleWrite("List commande failed" & @CR)
	EndIf

	;~ Local $noop = _Pop3Noop()
	;~ If Not @error Then
	;~ 	ConsoleWrite($noop & @CR)
	;~ Else
	;~ 	ConsoleWrite("List commande failed" & @CR)
	;~ EndIf

	;~ Local $uidl = _Pop3Uidl()
	;~ If Not @error Then
	;~ 	_ArrayDisplay($uidl, "")
	;~ Else
	;~ 	ConsoleWrite("Uidl commande failed" & @CR)
	;~ EndIf

	;~ Local $top = _Pop3Top(1, 0)
	;~ If Not @error Then
	;~ 	ConsoleWrite(StringStripCR($top) & @CR)
	;~ Else
	;~ 	ConsoleWrite("top commande failed" & @CR)
	;~ EndIf

;~ 	Local $retr = _Pop3Retr(1)
;~ 	If Not @error Then
;~ 		ConsoleWrite(StringStripCR($retr) & @CR)
;~ 	Else
;~ 		ConsoleWrite("Retr commande failed" & @CR)
;~ 	EndIf

	Local $dele = _Pop3Dele(1)
	If Not @error Then
		MsgBox(0, "", $dele)
	Else
		ConsoleWrite("Dele commande failed" & @CR)
	EndIf

	ConsoleWrite(_Pop3Quit() & @CR)
	ConsoleWrite(_pop3Disconnect() & @CR)
	Sleep(20000)
WEnd