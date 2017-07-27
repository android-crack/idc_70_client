#ifndef FCOREDUMP_H_
#define FCOREDUMP_H_
#include <string>
namespace fs{ namespace debug{
	void OnUnhandledExceptionDump(const char* dmpfile);
	typedef void (*COREDUMP_HANDLER)(const char* dmpfile);
	std::string GetSelfVersion();
	void	set_coredump_handler(COREDUMP_HANDLER handler);	
}}
#endif