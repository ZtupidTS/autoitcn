#include-once

; ZIP Creation Script
; by spyrorocks and the DtTvB

; Translated from PHP script by Eric Mueller
; http://www.themepark.com

#include <Array.au3>
#include "crc32.au3"

; This function parses hex strings in this way:
; XX XX XX XX .. .. ..
func _spaceSeperatedHexToString($x);
	local $len = stringLen($x);
	local $i = 1;
	local $ret = '';
	while ($i < $len)
		; msgbox (0, 0, $i);
		$ret &= chr(dec(stringMid($x, $i, 2)))
		$i += 3;
	wEnd;
	return BinaryToString($ret);
endFunc;

; Create a ZIP array.
func _zipCreate();
	local $ret[6] = ['', '', _spaceSeperatedHexToString('50 4b 05 06 00 00 00 00'), 0, 0, 0];
	return $ret;
endFunc;

; This function pack the value into 32-bit unsigned long in little endian byte order.
func _packV($x)
	return chr(mod($x, 256)) & chr(floor(mod($x, 65536) / 256)) & chr(floor(mod($x, 16777216) / 65536)) & chr(floor($x / 16777216));
endFunc;

; This adds a directory into a zip file.
; Due to the limitation of the program,
; you must create a directory first and then you can create files in or outside this folder.
func _zipAddDir(byRef $z, $name)

	$name = stringReplace($name, '\', '/');
	if (not(stringRight($name, 1) == '/')) then
		$name &= '/';
	endIf;

	local $fr;
	$fr = _spaceSeperatedHexToString('50 4b 03 04 0a 00 00 00 00 00 00 00 00 00');
	$fr &= _spaceSeperatedHexToString('00 00 00 00 00 00 00 00 00 00 00 00');

	local $nl;
	$nl = stringLen($name);
	$fr &= chr(mod($nl, 256)) & chr(floor($nl / 256));
	$fr &= _spaceSeperatedHexToString('00 00') & $name;
	$fr &= _spaceSeperatedHexToString('00 00 00 00 00 00 00 00 00 00 00 00');

	$z[0] &= $fr;
	$z[4] += 1;

	local $no;
	$no = stringLen($z[0]);

	local $cdr;
	$cdr = _spaceSeperatedHexToString('50 4b 01 02 00 00 0a 00 00 00 00 00 00 00 00 00');
	$cdr &= _spaceSeperatedHexToString('00 00 00 00 00 00 00 00 00 00 00 00');
	$cdr &= chr(mod($nl, 256)) & chr(floor($nl / 256));
	$cdr &= _spaceSeperatedHexToString('00 00 00 00 00 00 00 00 10 00 00 00');
	$cdr &= _packV($z[3])
	$z[3] = $no;
	$cdr &= $name;

	$z[1] &= $cdr;
	$z[5] += 1;

endFunc;

; And this adds a file.
func _zipAddFile(byRef $z, $data, $name);

	$name = stringReplace($name, '\', '/');

	local $nl;
	$nl = stringLen($name);

	local $fr;
	$fr = _spaceSeperatedHexToString('50 4b 03 04 14 00 00 00 00 00 00 00 00 00');

	local $ul;
	$ul = stringLen($data);

	local $cr;
	$cr = _convCRC32($data);
	
	local $lp;
	$lp = _packV($ul);

	$fr &= _packV($cr) & $lp & $lp;
	$fr &= chr(mod($nl, 256)) & chr(floor($nl / 256));
	$fr &= _spaceSeperatedHexToString('00 00') & $name & $data;
	$fr &= _packV($cr) & $lp & $lp;

	$z[0] &= $fr;
	$z[4] += 1;

	local $no;
	$no = stringLen($z[0]);

	local $cdr;
	$cdr = _spaceSeperatedHexToString('50 4b 01 02 00 00 14 00 00 00 00 00 00 00 00 00');
	$cdr &= _packV($cr) & $lp & $lp;
	$cdr &= chr(mod($nl, 256)) & chr(floor($nl / 256));
	$cdr &= _spaceSeperatedHexToString('00 00 00 00 00 00 00 00 20 00 00 00');
	$cdr &= _packV($z[3]);

	$z[3] = $no;

	$cdr &= $name;

	$z[1] &= $cdr;
	$z[5] += 1;
endFunc;

; Output to string.
func _zipOutput(byRef $z);

	local $ub;
	local $i;

	local $ret;
	$ret = $z[0] & $z[1] & $z[2];

	local $cl;
	$cl = $z[5];

	local $cp;
	$cp = chr(mod($cl, 256)) & chr(floor($cl / 256));
	$ret &= $cp & $cp & _packV(stringLen($z[1])) & _packV(stringLen($z[0]));
	$ret &= _spaceSeperatedHexToString('00 00');
	return $ret;

endFunc;
