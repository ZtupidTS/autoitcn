#include <Misc.au3>

HotKeySet("J", "saveKeyStroke")

Global $dll = DllOpen("user32.dll")

While 1
	Sleep(10)
WEnd


Func saveKeyStroke()
	If _IsPressed("A1", $dll) Or _IsPressed("A0", $dll) Then
		ConsoleWrite("ang")
		Send("ang", 1)
	Else
		ConsoleWrite("raw key")
		HotKeySet(@HotKeyPressed)
		Send(@hotkeypressed)
		HotKeySet(@HotKeyPressed, "saveKeyStroke")
	EndIf
EndFunc