; Shows the filenames of all files in the current directory.
FileChangeDir("G:\Games\小霸王游戏机珍藏84合1\rom")
$search = FileFindFirstFile("*.nes") 

; Check if the search was successful
If $search = -1 Then
    MsgBox(0, "Error", "No files/directories matched the search pattern")
    Exit
EndIf

While 1
    $file = FileFindNextFile($search) 
    If @error Then ExitLoop
    
    $idx = StringInStr($file, '.')-1
	$str = StringLeft($file, $idx)
	If Number($str) == 0 Then ContinueLoop
	If $str < 10 Then
		$str = '00' & $str
	ElseIf $str < 100 Then
		$str = '0' & $str
	EndIf
	FileMove($file, $str & StringRight($file, StringLen($file) - $idx))
	ConsoleWrite($str & StringRight($file, StringLen($file) - $idx) & @CRLF)
WEnd

; Close the search handle
FileClose($search)