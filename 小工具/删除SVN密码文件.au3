
#NoTrayIcon

$file = 'c:\Application Data\Subversion\auth\svn.simple\98e66fbe828037f676bfd8193c2cc0f5'

$ret = FileDelete($file)
If $ret == 1 Then
	MsgBox(64, "删除SVN密码文件", "成功删除文件 " & $file)
Else
	MsgBox(16, "删除SVN密码文件", "无法删除文件" & $file)
EndIf