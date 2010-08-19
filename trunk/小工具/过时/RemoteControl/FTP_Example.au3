#include "ftp.au3"

;~ $server = '218.94.131.205'
;~ $username = 'root'
;~ $pass = 'zylg@))*'
$server = '10.40.70.200'
$username = 'spider'
$pass = 'spider'

$Open = _FTPOpen('test')
$Conn = _FTPConnect($Open, $server, $username, $pass, 21)
MsgBox(0, "", $Conn)
$Ftpp = _FtpPutFile($Conn, 'E:\AutoItWork\RemoteControl\MSN.au3', '/d:/tmp/MSN.au3')
MsgBox(0, "", $Ftpp)
$Ftpc = _FTPClose($Open)