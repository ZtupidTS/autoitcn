; ------------------------------------------------------------------
; LZMA Data Compression UDF
; Purpose: Warp for LZMA.DLL in AutoIt
; Author:  Ward
; ------------------------------------------------------------------

; ------------------------------------------------------------------
; Functions:
;  LzmaInit
;  LzmaExit
;  LzmaEnc
;  LzmaDec
;  LzmaDecGetSize
;  LzmaEncSetting
; ------------------------------------------------------------------

#include-once

Global $__LZMADLL = Default, $__LZMAEMBED = False, $__LZMAINIT = False

Func _LzmaEmbedCheck()
	If IsDeclared('__LZMABIN') Then
		$__LZMAEMBED = True
		If IsKeyword($__LZMADLL) Then $__LZMADLL = $__LZMABIN
	Else
		$__LZMAEMBED = False
		If IsKeyword($__LZMADLL) Then $__LZMADLL = "LZMA.DLL"
	EndIf
EndFunc

Func LzmaInit()
	_LzmaEmbedCheck()
	If Not $__LZMAINIT Then
		If $__LZMAEMBED Then
			$__LZMADLL = MemoryDllOpen($__LZMABIN)
		Else
			$__LZMADLL = DllOpen("LZMA.DLL")
		EndIf
		$__LZMAINIT = True
	EndIf
EndFunc

Func LzmaExit()
	_LzmaEmbedCheck()
	If $__LZMAINIT Then
		If $__LZMAEMBED Then
			MemoryDllClose($__LZMADLL)
		Else
			DllClose($__LZMADLL)
		EndIf
		$__LZMAINIT = False
		$__LZMADLL = Default
	EndIf
EndFunc

Func LzmaEnc($Source, $Setting = 5)
	_LzmaEmbedCheck()
	If Not IsBinary($Source) Then Return SetError(1, 0, $Source)

	Local $Src = DllStructCreate("byte[" & BinaryLen($Source) & "]")
	Local $Dest = DllStructCreate("byte[" & Int(BinaryLen($Source) * 1.1 + 1024) & "]")
	DllStructSetData($Src, 1, $Source)

	If IsNumber($Setting) Then
		$Setting = LzmaEncSetting(Int($Setting))
	ElseIf Not IsDllStruct($Setting) Then 
		$Setting = LzmaEncSetting()
	EndIf

	Local $Ret
	If $__LZMAEMBED Then
		$Ret = MemoryDllCall($__LZMADLL , "int:cdecl", "LzmaEnc", _
			"ptr", DllStructGetPtr($Dest), "uint*", DllStructGetSize($Dest), _
			"ptr", DllStructGetPtr($Src), "uint", DllStructGetSize($Src), _
			"ptr", DllStructGetPtr($Setting), "ptr", 0)
	Else
		$Ret = DllCall($__LZMADLL , "int:cdecl", "LzmaEnc", _
			"ptr", DllStructGetPtr($Dest), "uint*", DllStructGetSize($Dest), _
			"ptr", DllStructGetPtr($Src), "uint", DllStructGetSize($Src), _
			"ptr", DllStructGetPtr($Setting), "ptr", 0)
	EndIf
	
	
	If Not @Error Then
		If $Ret[0] = 0 Then 
			Return BinaryMid(DllStructGetData($Dest, 1), 1, $Ret[2])
		Else
			Return SetError(1, $Ret[0], $Source)
		EndIf		
	Else
		Return SetError(1, -1, $Source)
	EndIf
EndFunc

Func LzmaDec($Source)
	_LzmaEmbedCheck()
	If Not IsBinary($Source) Or BinaryLen($Source) < 9 Then Return SetError(1, 0, $Source) ; 9 is the size of header

	Local $Src = DllStructCreate("byte[" & BinaryLen($Source) & "]")
	DllStructSetData($Src, 1, $Source)

	Local $DestSize = LzmaDecGetSize($Source)
	If @Error Or $DestSize = 0 Then Return SetError(1, 0, $Source)

	Local $Dest = DllStructCreate("byte[" & $DestSize & "]")

	Local $Ret
	If $__LZMAEMBED Then
		$Ret = MemoryDllCall($__LZMADLL, "int:cdecl", "LzmaDec", _
			"ptr", DllStructGetPtr($Dest), "uint*", $DestSize, _
			"ptr", DllStructGetPtr($Src), "uint", BinaryLen($Source))
	Else
		$Ret = DllCall($__LZMADLL, "int:cdecl", "LzmaDec", _
			"ptr", DllStructGetPtr($Dest), "uint*", $DestSize, _
			"ptr", DllStructGetPtr($Src), "uint", BinaryLen($Source))
	EndIf
	
	If Not @Error Then
		Return SetExtended($Ret[0], DllStructGetData($Dest, 1))
	Else
		Return SetError(1, 0, $Source)
	EndIf
EndFunc

Func LzmaDecGetSize($Source)
	_LzmaEmbedCheck()
	If Not IsBinary($Source) Or BinaryLen($Source) < 9 Then Return SetError(1, 0, 0) ; 9 is the size of header

	Local $Src = DllStructCreate("byte[" & BinaryLen($Source) & "]")
	DllStructSetData($Src, 1, $Source)
	
	Local $Ret
	If $__LZMAEMBED Then
		$Ret = MemoryDllCall($__LZMADLL , "uint:cdecl", "LzmaDecGetSize", "ptr", DllStructGetPtr($Src))
	Else
		$Ret = DllCall($__LZMADLL , "uint:cdecl", "LzmaDecGetSize", "ptr", DllStructGetPtr($Src))
	EndIf
	
	If Not @Error Then
		Return $Ret[0]
	Else
		Return SetError(1, 0, 0)
	EndIf
EndFunc

Func LzmaEncSetting($Level = 5, $DictSize = 0, $LC = -1, $LP = -1, $PB = -1, $ALGO = -1, $FB = -1, $BtMode = -1, $NumHashBytes = -1, $MC = 0, $NumThreads = -1)
	Local $LzmaEncSet = DllStructCreate("int level;uint dictSize;int lc;int lp;int pb;int algo;int fb;int btMode;int numHashBytes;uint mc;uint writeEndMark;int numThreads")
	DllStructSetData($LzmaEncSet, "level", $Level)
	DllStructSetData($LzmaEncSet, "dictSize", $DictSize)
	DllStructSetData($LzmaEncSet, "lc", $LC)
	DllStructSetData($LzmaEncSet, "lp", $LP)
	DllStructSetData($LzmaEncSet, "pb", $PB)
	DllStructSetData($LzmaEncSet, "algo", $ALGO)
	DllStructSetData($LzmaEncSet, "fb", $FB)
	DllStructSetData($LzmaEncSet, "btMode", $BtMode)
	DllStructSetData($LzmaEncSet, "numHashBytes", $NumHashBytes)
	DllStructSetData($LzmaEncSet, "mc", $MC)
	DllStructSetData($LzmaEncSet, "writeEndMark", 0)
	DllStructSetData($LzmaEncSet, "numThreads", $NumThreads)
	Return $LzmaEncSet
EndFunc
