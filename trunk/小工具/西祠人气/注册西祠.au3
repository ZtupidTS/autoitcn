#include "file.au3"
#include "array.au3"

;~ http://www.xici.net/user/regist.asp

HotKeySet('{esc}', '_reg')
HotKeySet('{NUMPADADD}', '_next')

Dim $arr[1], $idx = IniRead('save.ini', 'main', 'index', 1)
_FileReadToArray('����.txt', $arr)
TrayTip('����ע��', '��ǰ ' & $arr[$idx] & ', index=' & $idx, 2000)
;~ _ArrayDisplay($arr)

While True
	Sleep(22222222)
WEnd

Func _reg()
	TrayTip('����ע��', '��ǰ ' & $arr[$idx] & ', index=' & $idx, 2000)
	Dim $delay = 300

	ClipPut($arr[$idx])
	Sleep(20)
	Send('^v{tab}')
	Sleep($delay)

	Send('cx091026{tab}')
	Sleep($delay)

	Send('cx091026{tab}')
	Sleep($delay)

	Send('oicqcx' & $idx & '@tom.com' & '{tab}')
	Sleep($delay)

	Send('{space}{tab}')
	Sleep($delay)

	Send('{down}{tab}')
	Sleep($delay)

	Send('{down}{tab}')
	Sleep($delay)

	Send('{down}{tab}{tab}')

;~ 	MsgBox(0, '����ע��','�رմ˶Ի������')

;~ 	Sleep($delay)

;~ 	Send('{enter}{tab}')
;~ 	Sleep($delay)

;~ 	Send('{tab}{space}{tab}')
;~ 	Sleep($delay)

;~ 	Send('{tab 2}{enter}')
;~ 	Sleep($delay)
EndFunc

Func _next()
	IniWrite('save.ini', 'main', 'name' & $idx, $arr[$idx])
	IniWrite('save.ini', 'main', 'pwd' & $idx, 'cx091026')
	IniWrite('save.ini', 'main', 'email' & $idx, 'oicqcx' & $idx & '@tom.com')
	TrayTip('����ע��', '�ɹ�ע�� ' & $arr[$idx] & ', index=' & $idx, 2000)

	$idx += 1
	IniWrite('save.ini', 'main', 'index', $idx)
EndFunc


