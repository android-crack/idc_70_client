#ifndef QQGlobleVariable_H
#define QQGlobleVariable_H

/*
// π”√Ãÿ ‚ª˙÷∆µƒ»´æ÷±‰¡ø
#ifdef PLATFORM_MCARE
#define DECLARE_GLOBE_VARIABLE(type, name)		extern type* FUN_GLOBE_VARIABLE_##name(QQVOID)
#define DEFINE_GLOBE_VARIABLE(type, name,val)	extern type* FUN_GLOBE_VARIABLE_##name(QQVOID)
#define GLOBE(name)								(*FUN_GLOBE_VARIABLE_##name())
#endif

// π”√∆’Õ®»´æ÷±‰¡ø
#if (defined PLATFORM_MTK) || (defined PLATFORM_WIN32)
#define DECLARE_GLOBE_VARIABLE(type, name)		extern type name
#define DEFINE_GLOBE_VARIABLE(type, name,val)	type name=val
#define GLOBE(name)								name
#endif
*/


#define DECLARE_GLOBE_VARIABLE(type, name)		extern type name
#define DEFINE_GLOBE_VARIABLE(type, name,val)	type name=val
#define GLOBE(name)								name



#endif