
#NoTrayIcon

$file = 'c:\Application Data\Subversion\auth\svn.simple\98e66fbe828037f676bfd8193c2cc0f5'

$ret = FileDelete($file)
If $ret == 1 Then
	MsgBox(64, "ɾ��SVN�����ļ�", "�ɹ�ɾ���ļ� " & $file)
Else
	MsgBox(16, "ɾ��SVN�����ļ�", "�޷�ɾ���ļ�" & $file)
EndIf