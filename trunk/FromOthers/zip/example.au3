; An example file to create a ZIP file.

#include "zip.au3"

; First, let's create a ZIP first.
$myzip = _zipCreate();

; Due to the limitation of the script, you must create a directory first.
_zipAddDir  ($myzip, 'main');

; And you can put the file inside that folder.
_zipAddFile ($myzip, 'This is the test file in the main folder.', 'main/test-1.txt');

; Or outside...
_zipAddFile ($myzip, 'This is the test file.', 'main/test-2.txt');

; You may create another directory and put a file in it.
_zipAddDir  ($myzip, 'anotherdir');
_zipAddFile ($myzip, 'This is the test file in the another folder.', 'anotherdir/test-3.txt');

; Or directory in a direcory.
_zipAddDir  ($myzip, 'anotherdir/test');
_zipAddFile ($myzip, 'Hahahahaha.', 'anotherdir/test/test-4.txt');

; Now write to the file.
$fp = fileOpen('thezip.zip', 18);
fileWrite ($fp, Binary(_zipOutput($myzip)));
fileClose ($fp);;
