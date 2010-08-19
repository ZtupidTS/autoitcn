#include "array.au3"

Global $fileSet[1]

searchFiles($fileSet, "D:\tmp\×ÊÁÏ")
_ArrayDisplay($fileSet)

Func searchFiles(ByRef $fileSet, $dir)
	Local $sch = FileFindFirstFile($dir & "\*.*")
	If $sch = -1 Then
		Return
	EndIf

	Local $file
	While 1
		$file = FileFindNextFile($sch)
		If @error Then ExitLoop
		If @error Then ;unkown type of the file, consider it as a common file
			_ArrayAdd($fileSet, $dir & "\" & $file)
			ContinueLoop
		EndIf
		If StringInStr(FileGetAttrib($dir & "\" & $file), "D") Then         ;if the file is a dir, recursion into it
			_ArrayAdd($fileSet, $dir & "\" & $file)
			searchFiles($fileSet, $dir & "\" & $file)
		Else
			_ArrayAdd($fileSet, $dir & "\" & $file)
		EndIf
	WEnd
	; Close the search handle
	FileClose($sch)
	$fileSet[0] = UBound($fileSet) - 1
EndFunc
