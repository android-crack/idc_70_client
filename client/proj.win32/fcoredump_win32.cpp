#include "fcoredump.h"
#include <Windows.h>
#include <direct.h>
#pragma warning( push )  
#pragma warning( disable : 4091 )
#include <DbgHelp.h>
#pragma warning( pop )

#pragma comment(lib, "dbghelp.lib")
#pragma comment(lib, "Version.lib")


namespace fs{ namespace debug{
	std::string format_string(const char *f, ...)
	{
		char buff[512];
		va_list arg_list;
		va_start(arg_list, f);
		int ret = _vsnprintf(buff, 512, f, arg_list);
		va_end(arg_list);
		return std::string(buff);
	}
	void OnUnhandledExceptionDump(const char* dmpfile)
	{
		if (!dmpfile)
			return;

		const std::string& crash_msg = "crash";
		char workDir[256];
		::GetModuleFileNameA(NULL, workDir, 256);
		(strrchr(workDir, '\\'))[0] = 0;
#ifndef _PUBLISH
		std::string tip_msg = format_string("程序崩溃，请将%s下后缀为.dmp的文件以及该目录下的quick-x-player.pdb发送给程序猿！！！", workDir);
#else
		std::string tip_msg = format_string("程序崩溃，请将%s下后缀为.dmp的文件以及该目录下的quick-x-player.pdb发送给程序猿！！！", workDir);
#endif

		::MessageBoxA(NULL, tip_msg.c_str(), dmpfile, MB_OK);
	}
	static COREDUMP_HANDLER se_handler = NULL;

	LPTOP_LEVEL_EXCEPTION_FILTER WINAPI MyDummySetUnhandledExceptionFilter(LPTOP_LEVEL_EXCEPTION_FILTER lpTopLevelExceptionFilter){	return NULL;}

	std::string GetSelfVersion()  
	{
		char self_path[MAX_PATH];
		
		GetModuleFileNameA(NULL,self_path,sizeof(self_path));

		int vi_size = GetFileVersionInfoSizeA(self_path,NULL);   
		if( vi_size!= 0 )  
		{     
			char* buf = (char*)malloc(vi_size);
			if( GetFileVersionInfoA(self_path,0,vi_size,buf) )     
			{     
				VS_FIXEDFILEINFO *verinfo;
				unsigned int verinfo_size = sizeof(VS_FIXEDFILEINFO);
				if(VerQueryValueA(buf,"\\",(void**)&verinfo,&verinfo_size))     
				{
					std::string ver_str = format_string("%d.%d.%d.%d",HIWORD(verinfo->dwFileVersionMS),LOWORD(verinfo->dwFileVersionMS),
						HIWORD(verinfo->dwFileVersionLS),LOWORD(verinfo->dwFileVersionLS));
					free(buf);
					return ver_str;
				}     
			}     
			free(buf);
		}     
		return "0.0.0.0";     
	}  

	BOOL PreventSetUnhandledExceptionFilter()
	{
		HMODULE hKernel32 = LoadLibraryA(("kernel32.dll"));
		if (hKernel32== NULL) return FALSE;
		void *pOrgEntry = (void*)GetProcAddress(hKernel32, "SetUnhandledExceptionFilter");
		if(pOrgEntry==NULL) return FALSE;
		static unsigned char newJump[ 100 ];
		DWORD dwOrgEntryAddr = (DWORD) pOrgEntry;
		dwOrgEntryAddr += 5; // add 5 for 5 op-codes for jmp far
		void *pNewFunc = (void*)&MyDummySetUnhandledExceptionFilter;
		DWORD dwNewEntryAddr = (DWORD) pNewFunc;
		DWORD dwRelativeAddr = dwNewEntryAddr-dwOrgEntryAddr;

		newJump[ 0 ] = 0xE9;  // JMP absolute
		memcpy(&newJump[ 1 ], &dwRelativeAddr, sizeof(pNewFunc));
		SIZE_T bytesWritten;
		BOOL bRet = WriteProcessMemory(GetCurrentProcess(),
			pOrgEntry, newJump, sizeof(pNewFunc) + 1, &bytesWritten);
		return bRet;
	}


	static LONG WINAPI UnhandledExceptionHandler(_EXCEPTION_POINTERS* pExceptionInfo)
	{
		static bool IsHandledExecption = false;

		if (IsHandledExecption || pExceptionInfo == NULL)
		{
			return EXCEPTION_CONTINUE_EXECUTION;
		}

		IsHandledExecption = true;

		std::string version = GetSelfVersion();
		char workDir[256];
		::GetModuleFileNameA(NULL, workDir, 256);
		(strrchr(workDir, '\\'))[0] = 0;
		//引擎信息
		std::string filename = format_string("%s\\crash-%08X-%08X-%s.dmp", workDir, pExceptionInfo->ExceptionRecord->ExceptionCode, pExceptionInfo->ExceptionRecord->ExceptionAddress, version.c_str());

		BOOL dump_ok = false;
		HANDLE hFile = CreateFileA(filename.c_str(), GENERIC_WRITE , 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_RANDOM_ACCESS, NULL);
		if( hFile != INVALID_HANDLE_VALUE )
		{
			MINIDUMP_EXCEPTION_INFORMATION   stMDEI ;
			stMDEI.ThreadId = GetCurrentThreadId();
			stMDEI.ExceptionPointers = pExceptionInfo ;
			stMDEI.ClientPointers = TRUE ;
			dump_ok = MiniDumpWriteDump ( GetCurrentProcess(), GetCurrentProcessId(), hFile, MiniDumpWithDataSegs, &stMDEI, NULL, NULL) ;

			if (!dump_ok)
			{
				std::string lasterr = format_string("保存当前环境信息失败！LastError:0x%08X", GetLastError());
				MessageBoxA(NULL, lasterr.c_str(), "Dump failed", MB_OK);
				CloseHandle(hFile);

				return EXCEPTION_CONTINUE_SEARCH;
			}

			CloseHandle(hFile);
		}
		se_handler( dump_ok?filename.c_str():NULL );
		/*
		// 文件名
		char filename_zip[256];
		sprintf_s(filename_zip,"crash-%08X-%08X-%s.zip", (unsigned int)pExceptionInfo->ExceptionRecord->ExceptionCode, (unsigned int)pExceptionInfo->ExceptionRecord->ExceptionAddress, version.c_str());

		//生成zip包 上传错误文件
		_mkdir("crash");
		char filepath_zip[256];
		sprintf_s(filepath_zip,"crash\\%s", filename_zip);
		
		HZIP zip = CreateZip((void*)filepath_zip, 0,ZIP_FILENAME);
		ZipAdd(zip,"crash.dmp",(void*)filename.c_str(),0,ZIP_FILENAME);
		//ZipAdd(zip,"q1.exe","q1.exe",0,ZIP_FILENAME);
		//ZipAdd(zip,"q1.pdb","q1.pdb",0,ZIP_FILENAME);
		//保存当前环境配置
		system_info sys;
		sys.LogComputerInfo();
		logger::instance().close_stream();
		ZipAdd(zip,"log.txt","log.txt",0,ZIP_FILENAME);
		CloseZip(zip);

		//启动报告器
		// file path
// 		char env[256];
// 		sprintf_s(env,"report_file=%s",filepath_zip);
// 		_putenv(env);
		// file name
		char report_name[256];
		sprintf_s(report_name,"report_name=%s", filename_zip);
		_putenv(report_name);
		// version
		char version_str[256];
		sprintf_s(version_str,"report_version=%s",version.c_str());
		_putenv(version_str);
		
		// http server dir
		std::string report_setting = fs::world::app::instance()->get_config("settings", "report_addr", "");
		char report_addr[256];
		sprintf_s(report_addr,"report_addr=%s", report_setting.c_str());
		_putenv(report_addr);

		// addr
		char crash_addr[256];
		sprintf_s(crash_addr,"crash_addr=%08X", (unsigned int)pExceptionInfo->ExceptionRecord->ExceptionAddress);
		_putenv(crash_addr);

		PROCESS_INFORMATION pi;
		STARTUPINFOA si;
		ZeroMemory(&pi, sizeof(PROCESS_INFORMATION));
		ZeroMemory(&si, sizeof(STARTUPINFOA));
		BOOL bRet = CreateProcess("crashreport.exe", NULL, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi);
		if( bRet==FALSE )
		{

		}
		*/
		return EXCEPTION_EXECUTE_HANDLER;
	}

	void set_coredump_handler(COREDUMP_HANDLER handler)
	{
		se_handler = handler;
		SetUnhandledExceptionFilter(UnhandledExceptionHandler);
		PreventSetUnhandledExceptionFilter();
	}

}}
