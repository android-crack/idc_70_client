#ifndef TYPE_DEFINE_H
#define TYPE_DEFINE_H
/*
 *  QQTypeDefine1.h
 *  mtt
 *
 *  Created by raycchen on 09-11-12.
 *  Copyright 2009 tencent. All rights reserved.
 *
 */

/************************************************************************/
/* basic data type defination                                                       */
/************************************************************************/
typedef char 				QQCHAR;
typedef unsigned char		QQBYTE;
typedef char				QQWCHAR;
typedef signed short		QQSHORT;
typedef unsigned short		QQUSHORT;
typedef signed long 		QQLONG;
typedef unsigned long 		QQULONG;
typedef signed int 		    QQINT;
typedef unsigned int 		QQUINT;
typedef float				QQFLOAT;
typedef unsigned char 		QQBOOL;
typedef double				QQDOUBLE;
typedef long long           QQLONGLONG;
//typedef void 				QQVOID;
#define QQVOID void

/************************************************************************/
/*DEFINE QQNULL QQFALSE QQTRUE	      									*/	
/************************************************************************/
#define QQFALSE  	0
#define QQTRUE  	1
#define QQNULL		0

#define QQMAXINT	0x7fffffff

/************************************************************************/
/* COMMON USE MATH FUNCTION                                                       */
/************************************************************************/
#define QQMIN(a, b)  ((a) <= (b) ? (a) : (b))
#define QQMAX(a, b)  ((a) >= (b) ? (a) : (b))
#define QQMED(a, b)  (((a) - (b)) / 2)
#define QQABS(a)     ((a) >= 0 ? (a) : -(a))

/************************************************************************/
/* KEYPRESS EVENT AND PENEVENT                                           */
/************************************************************************/
typedef enum _QKeyEvent{
	QKEYEVENT_DOWN,
	QKEYEVENT_UP,
	QKEYEVENT_REPEAT
}QKeyEvent;

typedef enum _QKeyCode {
	QKEY_0= 0,
	QKEY_1,
	QKEY_2,
	QKEY_3,
	QKEY_4,
	QKEY_5,
	QKEY_6,
	QKEY_7,
	QKEY_8,
	QKEY_9,
	QKEY_LSK,
	QKEY_RSK,
	QKEY_CSK,
	QKEY_UP_ARROW,	
	QKEY_DOWN_ARROW,
	QKEY_LEFT_ARROW,
	QKEY_RIGHT_ARROW,
	QKEY_SEND,
	QKEY_END,	
	QKEY_CLEAR,
	QKEY_STAR,
	QKEY_POUND,
	QKEY_VOL_UP,
	QKEY_VOL_DOWN,
	QKEY_QUICK_ACS,
	QKEY_ENTER,
	QKEY_EXTRA_1,
	QKEY_EXTRA_2,
	QKEY_VOL_ENTER,
	QKEY_ESC,
	QMAX_KEYS,	
	QKEY_INVALID=0xFE
}QKeyCode;

typedef enum _QPenEvent{
	QPENEVENT_DOWN = 1,
	QPENEVENT_UP,
	QPENEVENT_MOVE,
	QPENEVENT_PANNING
}QPenEvent;

#endif



