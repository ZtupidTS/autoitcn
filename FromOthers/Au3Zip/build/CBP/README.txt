Apr 20, 2007   Initial release.
May 31, 2007   Added checks for zip file existence
May 31, 2007   Added check to determine if file is a zip file.
Jun 21, 2007   Found and fixed bug in _ZipAddDir() with validating args.
Jun 21, 2007   Added some sleep in _ZipAddDir() and an checking for esc key to abort.
Jul 22, 2007   Change the return value from 0 to ZR_CORRUPT for file that do not detect as zip.
Jul 23, 2007   Fixed crash on corrupt or otherwise no zip file.
Apr 18, 2008   Fixed extraction problem with path containing spaces
Apr 23, 2008   Fixed _ZipAddDir failing because checking for source folder failed.
