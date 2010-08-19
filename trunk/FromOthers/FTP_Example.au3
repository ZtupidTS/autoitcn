#include "ftp.au3"

$server = '10.40.70.200'
$username = 'spider'
$pass = 'spider'

$Open = _FTPOpen('MyFTP Control')
MsgBox(0, "", $Open)
$Conn = _FTPConnect($Open, $server, $username, $pass)
MsgBox(0, "", $Conn)
$Ftpp = _FtpPutFile($Conn, 'C:\WINDOWS\Notepad.exe', '/somedir/Example.exe')
MsgBox(0, "", $Ftpp)
$Ftpc = _FTPClose($Open)
MsgBox(0, "", $Ftpc)