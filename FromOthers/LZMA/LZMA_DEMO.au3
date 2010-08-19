; ------------------------------------------------------------------
; LZMA Data Compression UDF
; Purpose: Demonstrate the usage of LZMA UDF
; Author:  Ward
; ------------------------------------------------------------------

#include "LZMA.AU3"
#include "LZMA.DLL.AU3" ; Delete this line to use the external LZMA.DLL file

LzmaInit()
Demo0()
;~ Demo1()
;~ Demo2()
;~ LzmaExit()

Func Demo0()
	Local $Source = StringToBinary('人机命令资源编译器V2')
	Local $Compressed = LzmaEnc($Source)
	ConsoleWrite($Compressed & @CRLF)
	Local $Decompressed = LzmaDec($Compressed)
	ConsoleWrite($Decompressed & @CRLF)
	ConsoleWrite(BinaryToString($Decompressed) & @CRLF)
;~ 	Output($Source, $Compressed, $Decompressed)
EndFunc

Func Demo1()
	Local $String = FileRead(@ScriptFullPath)
	Local $Source = StringToBinary($String)

	Local $Timer = TimerInit()
	Local $Compressed = LzmaEnc($Source)
	If @Error Then
		MsgBox(0, 'LZMA Demo', "Compress Fail (Unable To Compress ?)")
		Exit
	EndIf
	Local $Decompressed = BinaryToString(LzmaDec($Compressed))

	Output($Source, $Compressed, $Decompressed, $Timer)
EndFunc


Func Demo2()
	Local $FileName = FileOpenDialog("Select file to test (don't too big)", @ScriptDir, "Any File (*.*)")
	If $FileName = "" Then Exit

	If FileGetSize($FileName) > 50 * 1024 * 1024 Then
		If MsgBox(4, "LZMA Demo", "File size is larger than 50mb, really want to try it?") = 7 Then Exit
	EndIf

	Local $File = FileOpen($FileName, 16)
	Local $Source = FileRead($File)
	FileClose($File)

	Local $Timer = TimerInit()
	Local $Compressed = LzmaEnc($Source)
	If @Error Then
		MsgBox(0, 'LZMA Demo', "Compress Fail (Unable To Compress ?)")
		Exit
	EndIf
	Local $Decompressed = LzmaDec($Compressed)

	Output($Source, $Compressed, $Decompressed, $Timer)
EndFunc


Func Output($Source, $Compressed, $Decompressed, $Timer = 0)
	Local $Msg = "Source Size: " & BinaryLen($Source) & @LF
	$Msg &= "Compressed Size: " & BinaryLen($Compressed) & @LF
	$Msg &= "Decompression Succeed: " & ($Source = $Decompressed) & @LF
	$Msg &= "Ratio: " & Round(BinaryLen($Compressed)/BinaryLen($Source), 4) * 100 & "%" & @LF
	If $Timer Then $Msg &= "Time: " & Round(TimerDiff($Timer)) & " ms"
	MsgBox(0, 'LZMA Demo', $Msg)
EndFunc
