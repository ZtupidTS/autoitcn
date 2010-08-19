/*
/*
 *
 * AutoIt v3 Plugin SDK - Au3Zip
 *
 * Stephen Podhajecki <gehossafats at netmdc com>
 *
 * Au3Zip.c
 *
 */
//#define ___DBUG

#include <stdio.h>
#include <windows.h>
#include <tchar.h>
#include <string>
#include <inttypes.h>
#include <limits.h>

#include "AU3_Plugin_SDK\au3plugin.h"
#include "include\zip.h"
#include "include\unzip.h"
#include "include\addremove.h"

ZRESULT _RecurseDir(HZIP hz, std::string csPath, int iUseRecursion);

/****************************************************************************
 * Function List
 *
 * This is where you define the functions available to AutoIt.  Including
 * the function name (Must be the same case as your exported DLL name), the
 * minimum and maximum number of parameters that the function takes.
 *
 ****************************************************************************/

/* "FunctionName", min_params, max_params */
AU3_PLUGIN_FUNC g_AU3_Funcs[] =
    {
        //       {"_PointerTest", 0, 0},
        {"_ZipPluginAbout", 0 , 0},
        {"_ZipAdd", 2, 3},
        {"_ZipAddDir", 2, 3},
        {"_ZipAddFileToZip", 2, 3},
        {"_ZipAddFolder", 2 , 2},
        {"_ZipGetCount" , 1 , 1},
        {"_ZipGetItemInfo", 1 , 2},
        {"_ZipClose", 1 , 1},
        {"_ZipCreate", 1, 3},
        {"_ZipDeleteFile", 2, 2},
        {"_ZipFormatMessage" , 1 , 2},
        {"_ZipUnZip", 1 , 2},
        {"_ZipUnZipItem" , 3 , 3}
    };


/****************************************************************************
 * AU3_GetPluginDetails()
 *
 * This function is called by AutoIt when the plugin dll is first loaded to
 * query the plugin about what functions it supports.  DO NOT MODIFY.
 *
 ****************************************************************************/

AU3_PLUGINAPI int AU3_GetPluginDetails(int *n_AU3_NumFuncs, AU3_PLUGIN_FUNC **p_AU3_Func)
{
	/* Pass back the number of functions that this DLL supports */
	*n_AU3_NumFuncs	= sizeof(g_AU3_Funcs) / sizeof(AU3_PLUGIN_FUNC);

	/* Pack back the address of the global function table */
	*p_AU3_Func = g_AU3_Funcs;

	return AU3_PLUGIN_OK;
}


/****************************************************************************
 * DllMain()
 *
 * This function is called when the DLL is loaded and unloaded.  Do not
 * modify it unless you understand what it does...
 *
 ****************************************************************************/

BOOL WINAPI DllMain(HANDLE hInst, ULONG ul_reason_for_call, LPVOID lpReserved)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}
/****************************************************************************
 * _ZipCreate
 * This function creates a new zip file and returns a file handle to it
 * call the _ZipClose function when done.
 ****************************************************************************/

AU3_PLUGIN_DEFINE(_ZipCreate)
{
	//params  filename, buffer, password.

	AU3_PLUGIN_VAR	*pMyResult;

	/* Allocate the return variable */
	pMyResult = AU3_AllocVar();
	HZIP hz = 0;
	/* Check the base type of the parameters, if not what we what then return 1 */
#ifdef ___DBUG
	printf("args = %d\n", n_AU3_NumParams);
	fflush(stdout);
#endif
	switch (n_AU3_NumParams)
	{
	case 1:
		{
			if ( AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_STRING )
			{
				AU3_SetInt32(pMyResult, 0);
				*p_AU3_Result		= pMyResult;
				*n_AU3_ErrorCode	= ZR_ARGS;
				*n_AU3_ExtCode		= 0;

				return AU3_PLUGIN_OK;
			}
			char *szFN = AU3_GetString(&p_AU3_Params[0]);
			hz = CreateZip(_T(szFN), (int)0);
			AU3_FreeString(szFN);
			AU3_SethWnd(pMyResult, (HWND) hz);
		}
		break;
	case 2:
		{
			if (( AU3_GetType(&p_AU3_Params[0]) == AU3_PLUGIN_STRING ) &&
			        ( AU3_GetType(&p_AU3_Params[1]) == AU3_PLUGIN_STRING ))
			{
#ifdef ___DBUG
				printf("Creating Zip with Password\n");
				fflush(stdout);
#endif
				char *szFN = AU3_GetString(&p_AU3_Params[0]);
				char *szPS = AU3_GetString(&p_AU3_Params[1]);
				hz = CreateZip(_T(szFN), _T(szPS));
				AU3_FreeString(szFN);
				AU3_FreeString(szPS);
				AU3_SethWnd(pMyResult, (HWND) hz);
			}
			else
				if (( AU3_GetType(&p_AU3_Params[0]) == AU3_PLUGIN_STRING ) &&
				        ( AU3_GetType(&p_AU3_Params[1]) == AU3_PLUGIN_INT32 ))
				{
#ifdef ___DBUG
					printf("Creating Zip with Password\n");
					fflush(stdout);
#endif
					char *szFN = AU3_GetString(&p_AU3_Params[0]);
					hz = CreateZip(_T(szFN), (int)0);
					AU3_FreeString(szFN);
					AU3_SethWnd(pMyResult, (HWND) hz);
				}
				else

				{
					if (( AU3_GetType(&p_AU3_Params[0]) == AU3_PLUGIN_INT32 ) &&
					        ( AU3_GetType(&p_AU3_Params[1]) == AU3_PLUGIN_INT32 ))
					{
						int buff = AU3_GetInt32(&p_AU3_Params[0]);
						unsigned int len = AU3_GetInt32(&p_AU3_Params[1]);
						hz = CreateZip( &buff, len, "");
						// AU3_FreeVar(buff);
						// AU3_FreeVar(len);
						AU3_SethWnd(pMyResult, (HWND) hz);
					}

				}
		}
		break;
	case 3:
		{
			if (( AU3_GetType(&p_AU3_Params[0]) == AU3_PLUGIN_INT32 ) &&
			        ( AU3_GetType(&p_AU3_Params[1]) == AU3_PLUGIN_INT32 ) &&
			        ( AU3_GetType(&p_AU3_Params[2]) == AU3_PLUGIN_STRING ))
			{
				int buff = AU3_GetInt32(&p_AU3_Params[0]);
				unsigned int len = AU3_GetInt32(&p_AU3_Params[1]);
				char *szPS = AU3_GetString(&p_AU3_Params[2]);
				hz = CreateZip(&buff, len, _T(szPS));
//         AU3_FreeVar(buff);
//         AU3_FreeVar(len);
				AU3_FreeString(szPS);
				AU3_SethWnd(pMyResult, (HWND) hz);
			}

		}
		break;
	default:
		{
			AU3_SetInt32(pMyResult, 0);
			*p_AU3_Result		= pMyResult;
			*n_AU3_ErrorCode	= ZR_ARGS;
			*n_AU3_ExtCode		= 0;

			return AU3_PLUGIN_OK;
		}
	}
	/* Pass back the result, error code and extended code.
	 * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
	 */
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= (hz != 0);
	*n_AU3_ExtCode		= 0;

	return AU3_PLUGIN_OK;
}

/****************************************************************************
 * _ZipAdd
 * This function adds files to a newly created zip file.
 * This function cannot add files to the zip once the archive has
 * been closed with the _ZipClose function.  Use _ZipAddToZip for that.
 ****************************************************************************/

AU3_PLUGIN_DEFINE(_ZipAdd)
{
	AU3_PLUGIN_VAR	*pMyResult;

	/* Allocate the return variable */
	pMyResult = AU3_AllocVar();
	char *szFN;
	char *szFN1;

	/* Check the base type of the parameters,
	   then return 1 */
	if ( AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_HWND  )
	{
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	if (AU3_GetType(&p_AU3_Params[1]) != AU3_PLUGIN_STRING )
	{
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	szFN = AU3_GetString(&p_AU3_Params[1]);

	if (n_AU3_NumParams == 3)
	{
//      MessageBox(NULL,_T("NumParams=3"),_T("Notice"),MB_OK);
		if (AU3_GetType(&p_AU3_Params[2]) != AU3_PLUGIN_STRING )
		{
			AU3_SetInt32(pMyResult, 0);
			*p_AU3_Result		= pMyResult;
			*n_AU3_ErrorCode	= ZR_ARGS;
			*n_AU3_ExtCode		= 0;

			return AU3_PLUGIN_OK;
		}

		szFN1 = AU3_GetString(&p_AU3_Params[2]);

	}
	else
	{
		szFN1 = strrchr(szFN, '\\');
		szFN1++;
	}
	//    MessageBox(NULL,_T(szFN),_T("File"),MB_OK);
	//    MessageBox(NULL,_T(szFN1),_T("File"),MB_OK);

	HZIP hz = (HZIP)AU3_GethWnd(&p_AU3_Params[0]);
	int ZRETURN = (int)ZipAdd(hz, _T(szFN1), _T(szFN));
	AU3_FreeString(szFN);
	AU3_FreeString(szFN1);

	AU3_SetInt32(pMyResult, ZRETURN);
	/* Pass back the result, error code and extended code.
	 * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
	 */
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= ZRETURN;
	*n_AU3_ExtCode		= 0;
	//delete[] buffer;

	return AU3_PLUGIN_OK;
}
/****************************************************************************
 * _ZipAddFolder
 * This function adds a folder to a newly created zip file.
 * This function cannot add a folder to the zip once the archive has
 * been closed with the _ZipClose function.  Use _ZipAddToZip for that.
 ****************************************************************************/

AU3_PLUGIN_DEFINE(_ZipAddFolder)
{
	AU3_PLUGIN_VAR	*pMyResult ;
	/* Allocate the return variable */
	pMyResult = AU3_AllocVar();
	/* Check the base type of the parameters,
	 if they are not correct then return 0 */

	if ( AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_HWND)
	{
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	if ( AU3_GetType(&p_AU3_Params[1]) != AU3_PLUGIN_STRING)
	{
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	HZIP hz = (HZIP)AU3_GethWnd(&p_AU3_Params[0]);
	char *szFL = AU3_GetString(&p_AU3_Params[1]);

	int ZRETURN = (int)ZipAddFolder(hz, _T(szFL));
	AU3_SetInt32(pMyResult, ZRETURN);

	/* Pass back the result, error code and extended code.
	 * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
	 */
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= ZRETURN;
	*n_AU3_ExtCode		= 0;

	AU3_FreeString(szFL);
	return AU3_PLUGIN_OK;
}
/****************************************************************************
 * _ZipClose
 * Closes an open file handle  requires 1 arg the file handle.
 ****************************************************************************/

AU3_PLUGIN_DEFINE(_ZipClose)
{
	AU3_PLUGIN_VAR	*pMyResult ;
	/* Allocate the return variable */
	pMyResult = AU3_AllocVar();
	/* Check the base type of the parameters,
	 if they are not correct then return 1 */

	if ( AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_HWND)
	{
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	HZIP hz = (HZIP)AU3_GethWnd(&p_AU3_Params[0]);
	int ZRETURN = (int)CloseZipZ(hz);
#ifdef ___DBUG
	printf("Closed zip.\n");
	fflush(stdout);
#endif
	CloseHandle(hz);
	AU3_SetInt32(pMyResult, ZRETURN);

	/* Pass back the result, error code and extended code.
	 * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
	 */
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= ZRETURN;
	*n_AU3_ExtCode		= 0;

	return AU3_PLUGIN_OK;
}

/****************************************************************************
 * _ZipFormatMessage
 * This function returns the string message associated with an error code.
 * Pass ZR_RECENT to get the last code set or any code returned from a function
 * to get the message.
 ****************************************************************************/
AU3_PLUGIN_DEFINE(_ZipFormatMessage)
{
	AU3_PLUGIN_VAR	*pMyResult ;
	/*int				nNum1, nNum2, nResult;*/
	DWORD code;
	//char *buf;
	unsigned int len;

	/* Allocate the return variable */
	/*Handle*/
	pMyResult = AU3_AllocVar();
	/* Check the base type of the parameters, if they are not both int32
	   then return 1 */
	if ( AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_INT32 )
	{
		//MessageBox(NULL, _T("int required:"),_T("Notice"), MB_OK);
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	code = (DWORD)AU3_GetInt32(&p_AU3_Params[0]);
	TCHAR buf[128] ;
	len  = FormatZipMessage(code, buf, 128);
	AU3_SetString(pMyResult, buf);
	/* Pass back the result, error code and extended code.
	 * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
	   */
	//AU3_SetInt32(pMyResult,(unsigned int) &buf);
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= 0;
	*n_AU3_ExtCode		= 0;
	AU3_FreeString(buf);
	//delete buf;
	return AU3_PLUGIN_OK;
}
/****************************************************************************
 * _ZipUnZipItem
 * You guessed it, this UnZips the archive.
 * It takes 3 params: ZipFileName ,FileInZip, Dest dir.
 ****************************************************************************/
AU3_PLUGIN_DEFINE(_ZipUnZipItem)
{
	AU3_PLUGIN_VAR	*pMyResult ;
	/* Allocate the return variable */
	pMyResult = AU3_AllocVar();
	/* Check the base type of the parameters,
	 if they are not correct then return 1 */

	if (AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_STRING || AU3_GetType(&p_AU3_Params[1]) != AU3_PLUGIN_STRING )
	{
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	char *szSRC = AU3_GetString(&p_AU3_Params[0]);
	if (FileExists(szSRC) == 0)
	{
#ifdef ___DBUG
		printf("%s does not exists.\n", szSRC);
		fflush(stdout);
#endif
		AU3_FreeString(szSRC);
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_NOFILE;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	if (IsZipFile(szSRC) == 0)
	{
#ifdef ___DBUG
		printf("%s is not a zip file.\n", szSRC);
		fflush(stdout);
#endif
		AU3_FreeString(szSRC);
		AU3_SetInt32(pMyResult, ZR_CORRUPT);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_CORRUPT;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	char *szFILE = AU3_GetString(&p_AU3_Params[1]);
	char *szDEST = AU3_GetString(&p_AU3_Params[2]);

	if (szDEST == NULL || szDEST == "")
	{
		szDEST = _T("\\");
	}
	EnsureDirectory(0,szDEST);
	int code = ZR_OK;
	int found = 0;
	HZIP hz = 0;
	int ZRETURN = 0;
	if (FileExists(_T(szSRC)))
	{
		hz = OpenZip(_T(szSRC), 0);
		if (hz != 0)
		{
			SetUnzipBaseDir(hz, _T(szDEST));
			ZIPENTRY ze;
			code = GetZipItem(hz, -1, &ze);
			if (code == ZR_OK)
			{
				int numitems = ze.index;
				for (int zi = 0; zi < numitems; zi++)
				{
					if ((code = GetZipItem(hz, zi, &ze)) != ZR_OK)
					{
						break;
					}
					if (stricmp(szFILE, ze.name) == 0)
					{
#ifdef ___DBUG
						printf("UnzipItem-%s\n", ze.name);
#endif
						if ((code = UnzipItem(hz, zi, ze.name)) != ZR_OK)
						{
							break;
						}
						found = 1;
					}
				}
			}
		}
		ZRETURN = (int) CloseZip(hz);
	}
	if (found == 0)
	{
		code = ZR_NOTFOUND;
	}
	if (hz == 0 || code != ZR_OK )
	{
		AU3_SetInt32(pMyResult, code);
	}
	else
	{
		AU3_SetInt32(pMyResult, ZRETURN);
	}


	AU3_FreeString(szSRC);
	AU3_FreeString(szDEST);
	AU3_FreeString(szFILE);

	/* Pass back the result, error code and extended code.
	 * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
	 */
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= ZRETURN;
	*n_AU3_ExtCode		= 0;

	return AU3_PLUGIN_OK;
}
/****************************************************************************
 * _ZipUnZip
 * You guessed it, this UnZips the archive.
 * It takes 2 params: ZipFileName , Dest dir.
 ****************************************************************************/
AU3_PLUGIN_DEFINE(_ZipUnZip)
{
	AU3_PLUGIN_VAR	*pMyResult ;
	/* Allocate the return variable */
	pMyResult = AU3_AllocVar();
	/* Check the base type of the parameters,
	 if they are not correct then return 1 */

	if (AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_STRING || AU3_GetType(&p_AU3_Params[1]) != AU3_PLUGIN_STRING )
	{
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	char *szSRC = AU3_GetString(&p_AU3_Params[0]);

	if (FileExists(szSRC) == 0)
	{
#ifdef ___DBUG
		printf("%s does not exists.\n", szSRC);
		fflush(stdout);
#endif
		AU3_FreeString(szSRC);
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_NOFILE;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	if (IsZipFile(szSRC) == 0)
	{
#ifdef ___DBUG
		printf("%s is not a zip file.\n", szSRC);
		fflush(stdout);
#endif
		AU3_FreeString(szSRC);
		AU3_SetInt32(pMyResult, ZR_CORRUPT);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_CORRUPT;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	char *szDEST = AU3_GetString(&p_AU3_Params[1]);

	if (szDEST == NULL || szDEST == "")
	{
		szDEST = _T("\\");
	}
	int code = ZR_OK;
	int found = 0;
	HZIP hz = 0;
	int ZRETURN = 0;

	if (FileExists(_T(szSRC)))
	{
		hz = OpenZip(_T(szSRC), 0);
      if (hz != 0)
		{
			SetUnzipBaseDir(hz, _T(szDEST));
			ZIPENTRY ze;
			code = GetZipItem(hz, -1, &ze);
			if (code == ZR_OK)
			{
				int numitems = ze.index;
				for (int zi = 0; zi < numitems; zi++)
				{
					if ((code = GetZipItem(hz, zi, &ze)) != ZR_OK)
					{
						break;
					}
					if ((code = UnzipItem(hz, zi, ze.name)) != ZR_OK)
					{
						break;
					}
					found++;
				}
			}
		}
		ZRETURN = (int) CloseZip(hz);
	}
	if (found == 0)
	{
		code = ZR_NOTFOUND;
	}
	if (hz == 0 || code != ZR_OK )
	{
		AU3_SetInt32(pMyResult, code);
	}
	else
	{
		AU3_SetInt32(pMyResult, ZRETURN);
	}

	AU3_FreeString(szSRC);
	AU3_FreeString(szDEST);

	/* Pass back the result, error code and extended code.
	 * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
	 */
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= ZRETURN;
	*n_AU3_ExtCode		= 0;

	return AU3_PLUGIN_OK;
}
/****************************************************************************
 * _ZipAddFileToZip
 * Add a file to an existing archive.  Takes 3 params, the Zip filename, the
 * file to add. The 3rd is optional and is the name the file will have in the
 * archive.
 ****************************************************************************/
AU3_PLUGIN_DEFINE(_ZipAddFileToZip)
{
	AU3_PLUGIN_VAR	*pMyResult;

	/* Allocate the return variable */
	pMyResult = AU3_AllocVar();
	char *szZip;
	char *szFN;
	char *szFN1;

	/* Check the base type of the parameters,
	   then return 1 */
	if ( AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_STRING  )
	{
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	szZip = AU3_GetString(&p_AU3_Params[0]);
	if (FileExists(szZip) == 0)
	{
#ifdef ___DBUG
		printf("%s does not exists.\n", szZip);
		fflush(stdout);
#endif
		AU3_FreeString(szZip);
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_NOFILE;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	if (IsZipFile(szZip) == 0)
	{
#ifdef ___DBUG
		printf("%s is not a zip file.\n", szZip);
		fflush(stdout);
#endif
		AU3_FreeString(szZip);
		AU3_SetInt32(pMyResult, ZR_CORRUPT);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_CORRUPT;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	if (AU3_GetType(&p_AU3_Params[1]) != AU3_PLUGIN_STRING )
	{
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	szFN = AU3_GetString(&p_AU3_Params[1]);

	if (n_AU3_NumParams == 3)
	{
		if (AU3_GetType(&p_AU3_Params[2]) != AU3_PLUGIN_STRING )
		{
			AU3_SetInt32(pMyResult, 0);
			*p_AU3_Result		= pMyResult;
			*n_AU3_ErrorCode	= ZR_ARGS;
			*n_AU3_ExtCode		= 0;

			return AU3_PLUGIN_OK;
		}
		szFN1 = AU3_GetString(&p_AU3_Params[2]);
	}
	else
	{
		szFN1 = strrchr(szFN, '\\');
		szFN1++;
	}
#ifdef ___DBUG
	printf("calling AddFileToZip with the following args:\n");
	printf("\t%s\t%s\t%s\n", szZip, szFN1, szFN);
	fflush(stdout);
#endif
	int ZRETURN = (int) AddFileToZip(_T(szZip), _T(szFN1) , _T(szFN));
#ifdef ___DBUG
	printf("Back from AddFileToZip\n");
	fflush(stdout);
#endif
	AU3_FreeString(szFN);
	AU3_FreeString(szFN1);
	AU3_FreeString(szZip);

	AU3_SetInt32(pMyResult, ZRETURN);
	/* Pass back the result, error code and extended code.
	 * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
	 */
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= ZRETURN;
	*n_AU3_ExtCode		= 0;
	//delete[] buffer;
#ifdef ___DBUG
	printf("Returning back to script.\n");
	fflush(stdout);
#endif
	return AU3_PLUGIN_OK;
}
/****************************************************************************
 * _ZipDeleteFile
 * Deletes a file from an existing archive.
 * Requires 2 params, the Zip file, and the filename in the archive to delete.
 ****************************************************************************/

AU3_PLUGIN_DEFINE(_ZipDeleteFile)
{
	AU3_PLUGIN_VAR	*pMyResult;

	/* Allocate the return variable */
	pMyResult = AU3_AllocVar();
	char *szFN;
	char *szFN1;

	/* Check the base type of the parameters,
	   then return 1 */
	if ( AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_STRING  )
	{
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	if (AU3_GetType(&p_AU3_Params[1]) != AU3_PLUGIN_STRING )
	{
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	szFN  = AU3_GetString(&p_AU3_Params[0]);

	if (FileExists(szFN) == 0)
	{
#ifdef ___DBUG
		printf("%s does not exists.\n", szFN);
		fflush(stdout);
#endif
		AU3_FreeString(szFN);
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_NOFILE;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	if (IsZipFile(szFN) == 0)
	{
#ifdef ___DBUG
		printf("%s is not a zip file.\n", szFN);
		fflush(stdout);
#endif
		AU3_FreeString(szFN);
		AU3_SetInt32(pMyResult, ZR_CORRUPT);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_CORRUPT;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	szFN1 = AU3_GetString(&p_AU3_Params[1]);

	int ZRETURN = (int) RemoveFileFromZip(_T(szFN), _T(szFN1));
	AU3_FreeString(szFN);
	AU3_FreeString(szFN1);

	AU3_SetInt32(pMyResult, ZRETURN);
	/* Pass back the result, error code and extended code.
	 * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
	 */
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= ZRETURN;
	*n_AU3_ExtCode		= 0;
	//delete[] buffer;

	return AU3_PLUGIN_OK;
}

/****************************************************************************
 * _ZipAddDir
 * Add a Directory to an existing archive.  Takes 3 params, the Zip filename, the
 * Dir to add. The 3rd is optional and is the recursion flag:
 *                 1 = recursion (default), 0 = no recursion.
 *It should be noted that the paths are stored relative to the directory passed in.
 ****************************************************************************/

AU3_PLUGIN_DEFINE(_ZipAddDir)
{
	AU3_PLUGIN_VAR	*pMyResult ;
	char *szFN;
	char *szDIR;
//	AU3_PLUGIN_VAR  *pNewDir;
	/* Allocate the return variable */
	pMyResult = AU3_AllocVar();
	/* Check the base type of the parameters,
	 if they are not correct then return 1 */

	if ( AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_HWND)
	{
		AU3_SetInt32(pMyResult, ZR_ARGS);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	szFN  = AU3_GetString(&p_AU3_Params[0]);

	if (AU3_GetType(&p_AU3_Params[1]) != AU3_PLUGIN_STRING )
	{
		AU3_SetInt32(pMyResult,(int)  ZR_ARGS);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	szDIR  = AU3_GetString(&p_AU3_Params[1]);

	if (FileExists(szDIR) == 0)
	{
#ifdef ___DBUG
		printf("%s does not exists.\n", szDIR);
		fflush(stdout);
#endif
		AU3_FreeString(szDIR);
		AU3_SetInt32(pMyResult, (int) ZR_NOFILE);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_NOFILE;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	int iUseRecursion = 1;
	if (n_AU3_NumParams == 3)
	{
		if (AU3_GetType(&p_AU3_Params[2]) == AU3_PLUGIN_INT32)
		{
			iUseRecursion = AU3_GetInt32(&p_AU3_Params[2]);
			if (iUseRecursion)
			{
				iUseRecursion = 1;
			}
		}
	}
	bCancel = false;
	HZIP hz = (HZIP)AU3_GethWnd(&p_AU3_Params[0]);
	char baseDir[MAX_PATH];
	sprintf(baseDir, "%s", szDIR);
	ZRESULT ZRETURN = _RecurseDir(hz, _T(baseDir), iUseRecursion);
	if (bCancel = true) ZRETURN = ZR_ABORT;
	free(baseDir);
	AU3_SetInt32(pMyResult, (int) ZRETURN);

	/* Pass back the result, error code and extended code.
	 * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
	 */
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= ZRETURN;
	*n_AU3_ExtCode		= 0;
	AU3_FreeString(szFN);
	AU3_FreeString(szDIR);
	AU3_FreeString(baseDir);
	return AU3_PLUGIN_OK;
}
/****************************************************************************
 * _ZipGetItemInfo
 * This function returns a pointer to an array of file information.
 ****************************************************************************/

AU3_PLUGIN_DEFINE(_ZipGetItemInfo)
{
	AU3_PLUGIN_VAR	*pMyResult;
	/*int				nNum1, nNum2, nResult;*/

	/* Allocate the return variable */
	pMyResult = AU3_AllocVar();
	/* Check the base type of the parameters, if they are not both int32
	  then return 1 */
	int zptr;
	int iIndex;
	if ( AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_STRING )
	{
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}
	char *szFN = AU3_GetString(&p_AU3_Params[0]);
	szFN  = AU3_GetString(&p_AU3_Params[0]);

	if (FileExists(szFN) == 0)
	{
#ifdef ___DBUG
		printf("%s does not exists.\n", szFN);
		fflush(stdout);
#endif
		AU3_FreeString(szFN);
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_NOFILE;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	if (IsZipFile(szFN) == 0)
	{
#ifdef ___DBUG
		printf("%s is not a zip file.\n", szFN);
		fflush(stdout);
#endif
		AU3_FreeString(szFN);
		AU3_SetInt32(pMyResult, ZR_CORRUPT);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_CORRUPT;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	if (n_AU3_NumParams == 2)
	{
		if ( AU3_GetType(&p_AU3_Params[1]) != AU3_PLUGIN_INT32 )
		{
			AU3_SetInt32(pMyResult, 0);
			*p_AU3_Result		= pMyResult;
			*n_AU3_ErrorCode	= ZR_ARGS;
			*n_AU3_ExtCode		= 0;

			return AU3_PLUGIN_OK;
		}
		iIndex = AU3_GetInt32(&p_AU3_Params[1]);

	}
	else
	{
		iIndex = -255;
	}
	zptr = GetZipItemInfo( szFN, iIndex);
	//=======================================
	AU3_FreeString(szFN);
	AU3_SetInt32(pMyResult, zptr);

	/* Pass back the result, error code and extended code.
	 * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
	 */
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= (zptr != 0);
	*n_AU3_ExtCode		= 0;

	return AU3_PLUGIN_OK;
}

////****************************************************************************
// * _ZipGetList
// * This function returns a pointer to an array of file information.
// ****************************************************************************/
//
//AU3_PLUGIN_DEFINE(_ZipGetList)
//{
//   AU3_PLUGIN_VAR	*pMyResult;
//   /*int				nNum1, nNum2, nResult;*/
//
//   /* Allocate the return variable */
//   pMyResult = AU3_AllocVar();
//
//   /* Check the base type of the parameters, if they are not both int32
//      then return 1 */
//   if ( AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_STRING )
//   {
//      AU3_SetInt32(pMyResult, 0);
//      *p_AU3_Result		= pMyResult;
//      *n_AU3_ErrorCode	= ZR_ARGS;
//      *n_AU3_ExtCode		= 0;
//
//      return AU3_PLUGIN_OK;
//   }
//
//   char *szFN = AU3_GetString(&p_AU3_Params[0]);
////================================================
//   int zelist = GetZipItemInfo( szFN, -255);
////================================================
//   AU3_FreeString(szFN);
//   //AU3_SetString(pMyResult, zipe);
//   AU3_SetInt32(pMyResult, (int) zelist);
//
//   /* Pass back the result, error code and extended code.
//    * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
//    */
//   *p_AU3_Result		= pMyResult;
//   *n_AU3_ErrorCode	= (zelist !=0);
//   *n_AU3_ExtCode		= 0;
//
//   return AU3_PLUGIN_OK;
//}
/****************************************************************************
 * _ZipGetCount
 * This function return the number of entries int the zip.
 ****************************************************************************/

AU3_PLUGIN_DEFINE(_ZipGetCount)
{
	AU3_PLUGIN_VAR	*pMyResult;
	/*int				nNum1, nNum2, nResult;*/

	/* Allocate the return variable */
	pMyResult = AU3_AllocVar();

	/* Check the base type of the parameters, if they are not both int32
	   then return 1 */
	if ( AU3_GetType(&p_AU3_Params[0]) != AU3_PLUGIN_STRING )
	{
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_ARGS;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	char *szFN = AU3_GetString(&p_AU3_Params[0]);
//================================================
	if (FileExists(szFN) == 0)
	{
#ifdef ___DBUG
		printf("%s does not exists.\n", szFN);
		fflush(stdout);
#endif
		AU3_FreeString(szFN);
		AU3_SetInt32(pMyResult, 0);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_NOFILE;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	if (IsZipFile(szFN) == 0)
	{
#ifdef ___DBUG
		printf("%s is not a zip file.\n", szFN);
		fflush(stdout);
#endif
		AU3_FreeString(szFN);
		AU3_SetInt32(pMyResult, ZR_CORRUPT);
		*p_AU3_Result		= pMyResult;
		*n_AU3_ErrorCode	= ZR_CORRUPT;
		*n_AU3_ExtCode		= 0;

		return AU3_PLUGIN_OK;
	}

	HZIP hzsrc = OpenZip(_T(szFN), 0);
	if (hzsrc == 0) return ZR_READ;
	ZIPENTRY ze;
	int numitems = 0;
	ZRESULT zr = GetZipItem(hzsrc, -1, &ze);
	if (zr == ZR_OK)
	{
		numitems = ze.index;
	}
	CloseZip(hzsrc);
	CloseHandle(hzsrc);
//=======================================
	AU3_SetInt32(pMyResult, numitems);
	AU3_FreeString(szFN);

	/* Pass back the result, error code and extended code.
	 * Note: AutoIt is responsible for freeing the memory used in p_AU3_Result
	 */
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= (zr != ZR_OK);
	*n_AU3_ExtCode		= 0;

	return AU3_PLUGIN_OK;
}
AU3_PLUGIN_DEFINE(_ZipPluginAbout)
{
	AU3_PLUGIN_VAR	*pMyResult;
	/*int				nNum1, nNum2, nResult;*/

	/* Allocate the return variable */
	pMyResult = AU3_AllocVar();
	char buffer[] = "First incarnation of a Zip plugin for AutoIt V3\n\tBy Stephen Podhajecki\n\nBased on CodeProject- 'Zip utils' by Lucian Wischik.";
	//sprintf(buffer, "First incarnation of a Zip plugin for AutoIt V3\n\tBy Stephen Podhajecki\n\nBased on CodeProject- 'Zip utils' by Lucian Wischik.");
	AU3_SetString (pMyResult, buffer);
	*p_AU3_Result		= pMyResult;
	*n_AU3_ErrorCode	= ZR_ARGS;
	*n_AU3_ExtCode		= 0;
	delete(buffer);
	return AU3_PLUGIN_OK;
}
