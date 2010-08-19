#ifndef _Add_Remove_Zip_H
#define _Add_Remove_Zip_H
#include "zip.h"
#include "unzip.h"
#include <shlwapi.h>
#include <sys/stat.h>
ZRESULT RemoveFileFromZip(const TCHAR *zipfn, const TCHAR *zename);
ZRESULT AddFileToZip(const TCHAR *zipfn, const TCHAR *zename, const TCHAR *zefn);
ZRESULT GetFileList(const TCHAR *zipfn);
ZRESULT CloseAllHz(HZIP hz);
ZRESULT GetZipItemInfo(const char* szFN, int index);
ZRESULT RemoveFileFromZip(const TCHAR *zipfn, const TCHAR *zename)
{
	return AddFileToZip(zipfn, zename, 0);
}
ZRESULT AddFileToZip(const TCHAR *zipfn, const TCHAR *zename, const TCHAR *zefn)
{
	if (GetFileAttributes(zipfn) == 0xFFFFFFFF || (zefn != 0 && GetFileAttributes(zefn) == 0xFFFFFFFF)) return ZR_NOFILE;
	// Expected size of the new zip will be the size of the old zip plus the size of the new file
	HANDLE hf = CreateFile(zipfn, 0, 0, 0, OPEN_EXISTING, 0, 0);//7
	if (hf == INVALID_HANDLE_VALUE)
	{
#ifdef ___DBUG
		printf("\nCould not open file %s  : %d\n", zipfn, GetLastError());
		fflush(stdout);
#endif
		return ZR_NOFILE;
	}
	//bug-fix sp.
	// buffer size is now calculated using the size from each items zip entry.
	//DWORD size=GetFileSize(hf,0);
	DWORD size = 0;
	CloseHandle(hf);
	hf = 0;
	if (zefn != 0 && zefn != NULL)
	{
		HANDLE hfz = CreateFile(zefn, GENERIC_READ, 7, 0, OPEN_EXISTING, 0, 0);//7
		if (hfz == INVALID_HANDLE_VALUE)
		{
#ifdef ___DBUG
			printf("Could not locate file %s  : %d\n", zefn, GetLastError());
			fflush(stdout);
#endif

			return ZR_NOFILE;
		}
		size += GetFileSize(hfz, 0);
		FlushFileBuffers(hfz);
		CloseHandle(hfz);
	}
////// this causes problems when the archive compression is 50% or more of uncompressed size.
////// bug-fix sp//	size*=2; // just to be on the safe side.

	HZIP hzsrc = OpenZip(zipfn, 0);
	if (hzsrc == 0) return ZR_READ;

////// calculate buffer size bug-fix begin sp.
	ZIPENTRY ze;
	ZRESULT zr = GetZipItem(hzsrc, -1, &ze);
	int numitems = ze.index;
	if (zr != ZR_OK)
	{
		CloseAllHz(hzsrc);
		return zr;
	}
	for (int i = 0; i < numitems; i++)
	{
		zr = GetZipItem(hzsrc, i, &ze);
		if (zr != ZR_OK)
		{
			CloseAllHz(hzsrc);
			return zr;
		}
		size += ze.unc_size;
	}
	size += 4096;
//	CloseZip(hzsrc);
///// end  calculate buffer size bug-fix addition.

	HZIP hzdst = CreateZip(0, size, 0);
	if (hzdst == 0)
	{
#ifdef ___DBUG
		printf("Error opening dest buffer.\n");
		fflush(stdout);
#endif
		CloseAllHz(hzsrc);
		return ZR_WRITE;
	}
//	hzsrc=OpenZip(zipfn,0);
//	if (hzsrc==0) return ZR_READ;

	// hzdst is created in the system pagefile
	// Now go through the old zip, unzipping each item into a memory buffer, and adding it to the new one
	char *buf = 0;
	unsigned int bufsize = 0; // we'll unzip each item into this memory buffer
	// ze, zr and numitems were originally declared here.
	// their declarations have moved above for use with the buffer size calculation.
	//bug-fix sp. //ZIPENTRY ze;
	//bug-fix sp. //ZRESULT zr=GetZipItem(hzsrc,-1,&ze);
	//bug-fix sp. //int numitems=ze.index;
	zr = GetZipItem(hzsrc, -1, &ze);
	numitems = ze.index;

	if (zr != ZR_OK)
	{
		CloseAllHz(hzsrc);
		CloseAllHz(hzdst);
		FlushFileBuffers(hzdst);
		return zr;
	}
	for (int i = 0; i < numitems; i++)
	{
		zr = GetZipItem(hzsrc, i, &ze);
		if (zr != ZR_OK)
		{
			CloseAllHz(hzsrc);
			CloseAllHz(hzdst);
			FlushFileBuffers(hzdst);
			return zr;
		}
		if (stricmp(ze.name, zename) == 0) continue; // don't copy over the old version of the file we're changing
		if (ze.attr&FILE_ATTRIBUTE_DIRECTORY)
		{
			zr = ZipAddFolder(hzdst, ze.name);
			if (zr != ZR_OK)
			{
				CloseAllHz(hzsrc);
				CloseAllHz(hzdst);
				FlushFileBuffers(hzdst);
				return zr;
			}
			continue;
		}
		if (ze.unc_size > (long)bufsize)
		{
			if (buf != 0) delete[] buf;
			bufsize = ze.unc_size * 2; //why double ???
			buf = new char[bufsize];
		}
		zr = UnzipItem(hzsrc, i, buf, bufsize);
		if (zr != ZR_OK)
		{
			CloseAllHz(hzsrc);
			CloseAllHz(hzdst);
			FlushFileBuffers(hzdst);
			return zr;
		}
		//bug-fix sp. The commented line below cause the uncompressed size to show incorrect.
		//zr=ZipAdd(hzdst,ze.name,buf,bufsize);
		zr = ZipAdd(hzdst, ze.name, buf, ze.unc_size);// use zip entry uncompressed size.
		if (zr != ZR_OK)
		{
			CloseAllHz(hzsrc);
			CloseAllHz(hzdst);
			FlushFileBuffers(hzdst);
			return zr;
		}
	}
	delete[] buf;
	// Now add the new file
	if (zefn != 0) // this will be 0 if deleting a file.
	{
		zr = ZipAdd(hzdst, zename, zefn);
		if (zr != ZR_OK)
		{
			CloseAllHz(hzsrc);
			CloseAllHz(hzdst);
			FlushFileBuffers(hzdst);
			return zr;
		}
	}
	zr = CloseAllHz(hzsrc);
	if (zr != ZR_OK)
	{
		FlushFileBuffers(hzdst);
		CloseAllHz(hzdst);
		return zr;
	}
	//
	// The new file has been put into pagefile memory. Let's store it to disk, overwriting the original zip
	zr = ZipGetMemory(hzdst, (void**) & buf, &size);
	if (zr != ZR_OK)
	{
		FlushFileBuffers(hzdst);
		CloseAllHz(hzdst);
		return zr;
	}
#ifdef ___DBUG
	printf("Recreating File %d\n", hf);
	fflush(stdout);
#endif
//flush and close handle in case open.
	FlushFileBuffers(hf);
	CloseHandle(hf);
	CloseAllHz(hzsrc);

	hf = CreateFile(zipfn, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hf == INVALID_HANDLE_VALUE)
	{
#ifdef ___DBUG
		printf("Error opening the zip file:%s \n", zipfn);
		printf("Last Error:%d\n", GetLastError());
		fflush(stdout);
#endif
		FlushFileBuffers(hzdst);
		CloseAllHz(hzdst);
		CloseAllHz(hzsrc);
		CloseHandle(hf);
		return ZR_WRITE;
	}
	DWORD writ;
	WriteFile(hf, buf, size, &writ, 0);
	FlushFileBuffers(hf);
	CloseHandle(hf);
	CloseAllHz(hzsrc);
	zr = CloseAllHz(hzdst);
	if (zr != ZR_OK) return zr;
	return ZR_OK;
}

std::string szBasePath;
bool bCancel = false;
ZRESULT _RecurseDir(HZIP hz, std::string csPath, int iUseRecursion)
{
 	ZRESULT ZRETURN = ZR_OK;
	ZRESULT zr = ZR_OK;
	std::string csPathMask;
	std::string csFullPath;
	std::string csZipPath;
	if (szBasePath.empty())
	{
		szBasePath = csPath;
	}
	csPath += _T("\\");
	int iBaseLen = szBasePath.length();
	int iBase = szBasePath.rfind('\\') + 1;
	if (iBase < 0)
	{
		iBase = 0;
	};
	if ((iBase == iBaseLen) && iBaseLen != 0)
	{
		iBase--;
	}

#ifdef ___DBUG
	printf("BasePath:%s\tLen:%i\n", szBasePath.c_str(), iBase);
	printf("%s\n", szBasePath.substr(iBase, iBaseLen).c_str());
	fflush(stdout);
#endif
	csPathMask = csPath + _T("*.*");

	WIN32_FIND_DATA ffData;
	HANDLE hFind;

	hFind = FindFirstFile(_T(csPathMask.c_str()), &ffData);

	if (hFind == INVALID_HANDLE_VALUE)
	{
#ifdef ___DBUG
		printf("ZipDir:Invalid Handle Value");
		fflush(stdout);
#endif
		return ZR_SEEK;
	}

	while (hFind && FindNextFile(hFind, &ffData) && (bCancel ==false) )
	{
		csFullPath = csPath + ffData.cFileName;
		csZipPath =  ffData.cFileName;

		if ( (_tcscmp(ffData.cFileName, _T(".")) != 0) &&
		        (_tcscmp(ffData.cFileName, _T("..")) != 0) )
		{

			if ( (ffData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) )
			{
#ifdef ___DBUG
				//MessageBox(NULL,ffData.cFileName,"Dir",MB_OK);
				printf("Dir:%s\n", csFullPath.c_str());
				printf("Base:%s\n", szBasePath.c_str());
				printf("iUseRecursion:%d\n", iUseRecursion);
				fflush(stdout);
#endif
				if (iUseRecursion == 1)
				{
					//ZRETURN = ZipAddFolder(hz,_T(csFullPath.c_str() + iBase)); // its a dir
					zr = _RecurseDir(hz, csFullPath, iUseRecursion);
					if ( !zr )
					{
#ifdef ___DBUG
						printf("Return from zipDir:%d\n", zr);
						fflush(stdout);
#endif
						ZRETURN = zr;
					}
				}
			}
			else // add the file
			{

#ifdef ___DBUG
				printf("File:%s\n", csFullPath.c_str());
				printf("Adding:%s\n", csFullPath.c_str() + iBase);
				fflush(stdout);
#endif
				{
					//std::string source = csFullPath;
					ZRETURN = (int)ZipAdd(hz, _T(csFullPath.c_str() + iBase), _T(csFullPath.c_str()));
					if (ZRETURN != ZR_OK)
					{
#ifdef ___DBUG
						printf("Return form Zipdir:ZipAdd %d\n", ZRETURN);
						fflush(stdout);
#endif
						return ZRETURN;
					}
					//free(&source);
				}
			}
		}
		Sleep(5);
		if (GetAsyncKeyState(VK_ESCAPE) & 0x8000)
		{
         int mbreturn = MessageBox(NULL,"Do you really wish to abort the operation?","Abort",MB_YESNO|MB_TOPMOST|MB_TASKMODAL);
#ifdef ___DBUG
         printf("return value was: %d\n", mbreturn);
			printf("Cancel pressed during Zipdir:ZipAdd %d\n", ZRETURN);
			fflush(stdout);
#endif
      if (mbreturn == 6) {bCancel = true; ZRETURN = ZR_ABORT; break;}
		}
	}
	FindClose(hFind);
	//delete szFN1;
	free(&csPath);
	free(&csPathMask);
	free(&csFullPath);
	return ZRETURN;
}


ZRESULT CloseAllHz(HZIP hz)
{
	ZRESULT zr = CloseZip(hz);
	CloseHandle(hz);
	return zr;
}

bool FileExists( const char* zipfn)
{
   struct stat St;
   bool bRes = ( stat( zipfn, &St ) == 0 );
   return bRes;
/* //#ifdef ___DBUG
 *    printf("\nFileExists Function");
 *    fflush(stdout);
 * //#endif
 *    HANDLE hf = CreateFile(zipfn, 0, 0, 0, OPEN_EXISTING, 0, 0);//7
 *    if (hf == INVALID_HANDLE_VALUE)
 *    {
 * //#ifdef ___DBUG
 *       printf("\nCould not open file %s  : %d\n", zipfn, GetLastError());
 *       fflush(stdout);
 * //#endif
 *       return false;
 *    }
 *    CloseHandle(hf);
 *    return true;
 */
//	return PathFileExists(zipfn);
}
/***************************************************************
 * Returns a pointer to the first item of an array of zip item *
 * file information.                                           *
 **************************************************************/
ZRESULT GetZipItemInfo(const char* szFN, int index)
{
	if (index == NULL)
	{
		index = -255;
	}

//================================================
	HZIP hzsrc = OpenZip(_T(szFN), 0);
	if (hzsrc == 0) return ZR_READ;
	ZIPENTRY ze;
	ZRESULT zr = GetZipItem(hzsrc, -1, &ze);
	int numitems = ze.index;
	ZIPENTRY *zelist;
	if (index == -255)
	{
		zelist = new ZIPENTRY[numitems];
	}
	else
	{
		zelist = new ZIPENTRY[1];
	}
	if (zr == ZR_OK)
	{
		for (int i = 0; i < numitems; i++)
		{
			zr = GetZipItem(hzsrc, i, &ze);
			if (zr == ZR_OK)
			{
				if (index == -255)
				{
					zelist[i] = ze;
				}
				else
				{
					if (i == index)
					{
						zelist[0] = ze;
						break;
					}
				}
			}
			else
			{
				break;
			}
		}
	}
	CloseZip(hzsrc);
	CloseHandle(hzsrc);
//=======================================
	return (int) zelist;
}

bool IsZipFile(const char* szFN)
{
	DWORD bytesRead;
	BOOL iszip = false;
	char c[2];
	if (PathFileExists(szFN))
	{
		HANDLE hf = CreateFile(szFN, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
		if (hf == INVALID_HANDLE_VALUE)
		{
#ifdef ___DBUG
			printf("\nCould not open file %s  : %d\n", szFN, GetLastError());
			fflush(stdout);
#endif
			return false;
		}
		ReadFile(hf, &c, 2, &bytesRead, 0);
		CloseHandle(hf);
		//are the first 2 bytes "PK"
		if (c[0] ==0x50 && c[1] == 0x4b)
		{
			iszip = true;
		}
		delete(c);
		return iszip;
	}
}
bool CancelPressed(void){
     if (GetAsyncKeyState(VK_ESCAPE) & 0x8000)
     { return true;}
   return false;
}
#endif
//${PROJECT_NAME} ${PROJECT_DIR} ${PROJECT_FILENAME} ${ALL_PROJECT_FILES}
//{PROJECT_DIR}\${PROJECT_NAME}.zip ${PROJECT_FILENAME} ${ALL_PROJECT_FILES}
