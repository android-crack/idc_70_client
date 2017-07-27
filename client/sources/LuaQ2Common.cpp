/*
** Lua binding: Q2Common
** Generated automatically by tolua++-1.0.92 on Sat Mar  4 00:59:53 2017.
*/

/****************************************************************************
 Copyright (c) 2011 cocos2d-x.org

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

extern "C" {
#include "tolua_fix.h"
}

#include <map>
#include <string>
#include "cocos2d.h"
#include "Q2Common.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"

#include "CCPlatform3D.h"
#include "CCLayer3D.h"
#include "CCPlistFrame.h"
#include "CCRenderTarget3D.h"
#include "QSDK.h"
#include "QShareSDK.h"
#include "QTssSDK.h"
#include "QMSCSDK.h"

using namespace cocos2d;

/* Exported function */
TOLUA_API int  tolua_Q2Common_open (lua_State* tolua_S);


/* function to release collected object via destructor */
#ifdef __cplusplus

static int tolua_collect_CCPlatform3D (lua_State* tolua_S)
{
 CCPlatform3D* self = (CCPlatform3D*) tolua_tousertype(tolua_S,1,0);
    Mtolua_delete(self);
    return 0;
}
#endif


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"QTssSDK");
 tolua_usertype(tolua_S,"CCEvent");
 tolua_usertype(tolua_S,"CCTouch");
 tolua_usertype(tolua_S,"QMSCSDK");
 tolua_usertype(tolua_S,"CCPlistFrame");
 tolua_usertype(tolua_S,"cocos2dCCObject");
 tolua_usertype(tolua_S,"QShareSDK");
 
 tolua_usertype(tolua_S,"CCLayer3D");
 tolua_usertype(tolua_S,"QSDK");
 tolua_usertype(tolua_S,"CCSprite");
 tolua_usertype(tolua_S,"CCPlatform3D");
 tolua_usertype(tolua_S,"CCRect");
 tolua_usertype(tolua_S,"CCLayer");
 tolua_usertype(tolua_S,"CCRenderTarget3D");
}

/* method: create of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_create00
static int tolua_Q2Common_CCPlatform3D_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   CCPlatform3D* tolua_ret = (CCPlatform3D*)  CCPlatform3D::create();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"CCPlatform3D");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: new of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_new00
static int tolua_Q2Common_CCPlatform3D_new00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   CCPlatform3D* tolua_ret = (CCPlatform3D*)  Mtolua_new((CCPlatform3D)());
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"CCPlatform3D");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'new'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: new_local of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_new00_local
static int tolua_Q2Common_CCPlatform3D_new00_local(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   CCPlatform3D* tolua_ret = (CCPlatform3D*)  Mtolua_new((CCPlatform3D)());
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"CCPlatform3D");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'new'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: delete of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_delete00
static int tolua_Q2Common_CCPlatform3D_delete00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCPlatform3D* self = (CCPlatform3D*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'delete'", NULL);
#endif
  Mtolua_delete(self);
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'delete'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: pause of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_pause00
static int tolua_Q2Common_CCPlatform3D_pause00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   CCPlatform3D::pause();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'pause'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: resume of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_resume00
static int tolua_Q2Common_CCPlatform3D_resume00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   CCPlatform3D::resume();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'resume'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setHandlerPriority of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_setHandlerPriority00
static int tolua_Q2Common_CCPlatform3D_setHandlerPriority00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCPlatform3D* self = (CCPlatform3D*)  tolua_tousertype(tolua_S,1,0);
  int priority = ((int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setHandlerPriority'", NULL);
#endif
  {
   self->setHandlerPriority(priority);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setHandlerPriority'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: registerWithTouchDispatcher of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_registerWithTouchDispatcher00
static int tolua_Q2Common_CCPlatform3D_registerWithTouchDispatcher00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCPlatform3D* self = (CCPlatform3D*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'registerWithTouchDispatcher'", NULL);
#endif
  {
   self->registerWithTouchDispatcher();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'registerWithTouchDispatcher'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: ccTouchBegan of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_ccTouchBegan00
static int tolua_Q2Common_CCPlatform3D_ccTouchBegan00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCTouch",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,3,"CCEvent",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCPlatform3D* self = (CCPlatform3D*)  tolua_tousertype(tolua_S,1,0);
  CCTouch* touch = ((CCTouch*)  tolua_tousertype(tolua_S,2,0));
  CCEvent* event = ((CCEvent*)  tolua_tousertype(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'ccTouchBegan'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->ccTouchBegan(touch,event);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'ccTouchBegan'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: ccTouchEnded of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_ccTouchEnded00
static int tolua_Q2Common_CCPlatform3D_ccTouchEnded00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCTouch",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,3,"CCEvent",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCPlatform3D* self = (CCPlatform3D*)  tolua_tousertype(tolua_S,1,0);
  CCTouch* touch = ((CCTouch*)  tolua_tousertype(tolua_S,2,0));
  CCEvent* event = ((CCEvent*)  tolua_tousertype(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'ccTouchEnded'", NULL);
#endif
  {
   self->ccTouchEnded(touch,event);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'ccTouchEnded'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: ccTouchCancelled of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_ccTouchCancelled00
static int tolua_Q2Common_CCPlatform3D_ccTouchCancelled00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCTouch",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,3,"CCEvent",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCPlatform3D* self = (CCPlatform3D*)  tolua_tousertype(tolua_S,1,0);
  CCTouch* touch = ((CCTouch*)  tolua_tousertype(tolua_S,2,0));
  CCEvent* event = ((CCEvent*)  tolua_tousertype(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'ccTouchCancelled'", NULL);
#endif
  {
   self->ccTouchCancelled(touch,event);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'ccTouchCancelled'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: ccTouchMoved of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_ccTouchMoved00
static int tolua_Q2Common_CCPlatform3D_ccTouchMoved00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCTouch",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,3,"CCEvent",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCPlatform3D* self = (CCPlatform3D*)  tolua_tousertype(tolua_S,1,0);
  CCTouch* touch = ((CCTouch*)  tolua_tousertype(tolua_S,2,0));
  CCEvent* event = ((CCEvent*)  tolua_tousertype(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'ccTouchMoved'", NULL);
#endif
  {
   self->ccTouchMoved(touch,event);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'ccTouchMoved'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: initialize of class  CCPlatform3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlatform3D_initialize00
static int tolua_Q2Common_CCPlatform3D_initialize00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCPlatform3D",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   CCPlatform3D::initialize();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'initialize'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class  CCLayer3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCLayer3D_create00
static int tolua_Q2Common_CCLayer3D_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCLayer3D",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  int layer = ((int)  tolua_tonumber(tolua_S,2,0));
  {
   CCLayer3D* tolua_ret = (CCLayer3D*)  CCLayer3D::create(layer);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"CCLayer3D");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setSceneName of class  CCLayer3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCLayer3D_setSceneName00
static int tolua_Q2Common_CCLayer3D_setSceneName00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCLayer3D",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCLayer3D* self = (CCLayer3D*)  tolua_tousertype(tolua_S,1,0);
  const char* name = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setSceneName'", NULL);
#endif
  {
   self->setSceneName(name);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setSceneName'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getSceneName of class  CCLayer3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCLayer3D_getSceneName00
static int tolua_Q2Common_CCLayer3D_getSceneName00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCLayer3D",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCLayer3D* self = (CCLayer3D*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getSceneName'", NULL);
#endif
  {
   std::string tolua_ret = (std::string)  self->getSceneName();
   tolua_pushcppstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getSceneName'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class  CCRenderTarget3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCRenderTarget3D_create00
static int tolua_Q2Common_CCRenderTarget3D_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCRenderTarget3D",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  unsigned int width = ((unsigned int)  tolua_tonumber(tolua_S,2,0));
  unsigned int height = ((unsigned int)  tolua_tonumber(tolua_S,3,0));
  int maxTargetCount = ((int)  tolua_tonumber(tolua_S,4,1));
  {
   CCRenderTarget3D* tolua_ret = (CCRenderTarget3D*)  CCRenderTarget3D::create(width,height,maxTargetCount);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"CCRenderTarget3D");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: addTargetSprite of class  CCRenderTarget3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCRenderTarget3D_addTargetSprite00
static int tolua_Q2Common_CCRenderTarget3D_addTargetSprite00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCRenderTarget3D",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isusertype(tolua_S,3,"CCSprite",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCRenderTarget3D* self = (CCRenderTarget3D*)  tolua_tousertype(tolua_S,1,0);
  int layer = ((int)  tolua_tonumber(tolua_S,2,0));
  CCSprite* sprite = ((CCSprite*)  tolua_tousertype(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'addTargetSprite'", NULL);
#endif
  {
   self->addTargetSprite(layer,sprite);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addTargetSprite'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: removeTargetSprite of class  CCRenderTarget3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCRenderTarget3D_removeTargetSprite00
static int tolua_Q2Common_CCRenderTarget3D_removeTargetSprite00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCRenderTarget3D",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCRenderTarget3D* self = (CCRenderTarget3D*)  tolua_tousertype(tolua_S,1,0);
  int layer = ((int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'removeTargetSprite'", NULL);
#endif
  {
   self->removeTargetSprite(layer);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'removeTargetSprite'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: removeTargetSprite of class  CCRenderTarget3D */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCRenderTarget3D_removeTargetSprite01
static int tolua_Q2Common_CCRenderTarget3D_removeTargetSprite01(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCRenderTarget3D",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCSprite",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  CCRenderTarget3D* self = (CCRenderTarget3D*)  tolua_tousertype(tolua_S,1,0);
  CCSprite* sprite = ((CCSprite*)  tolua_tousertype(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'removeTargetSprite'", NULL);
#endif
  {
   self->removeTargetSprite(sprite);
  }
 }
 return 0;
tolua_lerror:
 return tolua_Q2Common_CCRenderTarget3D_removeTargetSprite00(tolua_S);
}
#endif //#ifndef TOLUA_DISABLE

/* method: loadPlist of class  CCPlistFrame */
#ifndef TOLUA_DISABLE_tolua_Q2Common_CCPlistFrame_loadPlist00
static int tolua_Q2Common_CCPlistFrame_loadPlist00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCPlistFrame",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const char* plist = ((const char*)  tolua_tostring(tolua_S,2,0));
  {
   CCPlistFrame::loadPlist(plist);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'loadPlist'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: sharedQSDK of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_sharedQSDK00
static int tolua_Q2Common_QSDK_sharedQSDK00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   QSDK* tolua_ret = (QSDK*)  QSDK::sharedQSDK();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"QSDK");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sharedQSDK'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: init of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_init00
static int tolua_Q2Common_QSDK_init00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  SDKPlatform platform = ((SDKPlatform) (int)  tolua_tonumber(tolua_S,2,0));
  LUA_FUNCTION nHandler = (  toluafix_ref_function(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'init'", NULL);
#endif
  {
   self->init(platform,nHandler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'init'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: login of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_login00
static int tolua_Q2Common_QSDK_login00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'login'", NULL);
#endif
  {
   self->login();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'login'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: qrCodeLogin of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_qrCodeLogin00
static int tolua_Q2Common_QSDK_qrCodeLogin00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'qrCodeLogin'", NULL);
#endif
  {
   self->qrCodeLogin();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'qrCodeLogin'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: switchUser of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_switchUser00
static int tolua_Q2Common_QSDK_switchUser00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isboolean(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  bool flag = ((bool)  tolua_toboolean(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'switchUser'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->switchUser(flag);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'switchUser'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: logout of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_logout00
static int tolua_Q2Common_QSDK_logout00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'logout'", NULL);
#endif
  {
   self->logout();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'logout'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getUid of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getUid00
static int tolua_Q2Common_QSDK_getUid00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getUid'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getUid();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getUid'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getOpenId of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getOpenId00
static int tolua_Q2Common_QSDK_getOpenId00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getOpenId'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getOpenId();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getOpenId'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getAccessToken of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getAccessToken00
static int tolua_Q2Common_QSDK_getAccessToken00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getAccessToken'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getAccessToken();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getAccessToken'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getPayToken of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getPayToken00
static int tolua_Q2Common_QSDK_getPayToken00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getPayToken'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getPayToken();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getPayToken'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getPf of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getPf00
static int tolua_Q2Common_QSDK_getPf00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getPf'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getPf();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getPf'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getPfKey of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getPfKey00
static int tolua_Q2Common_QSDK_getPfKey00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getPfKey'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getPfKey();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getPfKey'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getUdid of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getUdid00
static int tolua_Q2Common_QSDK_getUdid00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getUdid'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getUdid();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getUdid'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getExtraInfo of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getExtraInfo00
static int tolua_Q2Common_QSDK_getExtraInfo00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getExtraInfo'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getExtraInfo();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getExtraInfo'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: isPlatformInstalled of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_isPlatformInstalled00
static int tolua_Q2Common_QSDK_isPlatformInstalled00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  SDKPlatform platform = ((SDKPlatform) (int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'isPlatformInstalled'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->isPlatformInstalled(platform);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'isPlatformInstalled'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getUserInfo of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getUserInfo00
static int tolua_Q2Common_QSDK_getUserInfo00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getUserInfo'", NULL);
#endif
  {
   self->getUserInfo();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getUserInfo'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getFriendsInfo of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getFriendsInfo00
static int tolua_Q2Common_QSDK_getFriendsInfo00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getFriendsInfo'", NULL);
#endif
  {
   self->getFriendsInfo();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getFriendsInfo'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: openURL of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_openURL00
static int tolua_Q2Common_QSDK_openURL00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* url = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'openURL'", NULL);
#endif
  {
   self->openURL(url);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'openURL'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: pay of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_pay00
static int tolua_Q2Common_QSDK_pay00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     !tolua_isstring(tolua_S,5,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,6,0,&tolua_err) ||
     !tolua_isstring(tolua_S,7,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,8,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  int uid = ((int)  tolua_tonumber(tolua_S,2,0));
  const char* order = ((const char*)  tolua_tostring(tolua_S,3,0));
  const char* productId = ((const char*)  tolua_tostring(tolua_S,4,0));
  const char* productName = ((const char*)  tolua_tostring(tolua_S,5,0));
  float amount = ((float)  tolua_tonumber(tolua_S,6,0));
  const char* paydes = ((const char*)  tolua_tostring(tolua_S,7,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'pay'", NULL);
#endif
  {
   self->pay(uid,order,productId,productName,amount,paydes);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'pay'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: reportEvent of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_reportEvent00
static int tolua_Q2Common_QSDK_reportEvent00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,4,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* name = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* body = ((const char*)  tolua_tostring(tolua_S,3,0));
  bool isRealTime = ((bool)  tolua_toboolean(tolua_S,4,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'reportEvent'", NULL);
#endif
  {
   self->reportEvent(name,body,isRealTime);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'reportEvent'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: registerPay of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_registerPay00
static int tolua_Q2Common_QSDK_registerPay00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* env = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'registerPay'", NULL);
#endif
  {
   self->registerPay(env);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'registerPay'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: showNotice of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_showNotice00
static int tolua_Q2Common_QSDK_showNotice00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* scene = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'showNotice'", NULL);
#endif
  {
   self->showNotice(scene);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'showNotice'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getNoticeData of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getNoticeData00
static int tolua_Q2Common_QSDK_getNoticeData00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* scene = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getNoticeData'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getNoticeData(scene);
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getNoticeData'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: hideScrollNotice of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_hideScrollNotice00
static int tolua_Q2Common_QSDK_hideScrollNotice00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'hideScrollNotice'", NULL);
#endif
  {
   self->hideScrollNotice();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'hideScrollNotice'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: buglyLog of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_buglyLog00
static int tolua_Q2Common_QSDK_buglyLog00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  int level = ((int)  tolua_tonumber(tolua_S,2,0));
  const char* log = ((const char*)  tolua_tostring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'buglyLog'", NULL);
#endif
  {
   self->buglyLog(level,log);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'buglyLog'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getNearbyPersonInfo of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getNearbyPersonInfo00
static int tolua_Q2Common_QSDK_getNearbyPersonInfo00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getNearbyPersonInfo'", NULL);
#endif
  {
   self->getNearbyPersonInfo();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getNearbyPersonInfo'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: cleanLocation of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_cleanLocation00
static int tolua_Q2Common_QSDK_cleanLocation00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'cleanLocation'", NULL);
#endif
  {
   self->cleanLocation();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'cleanLocation'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getLocationInfo of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getLocationInfo00
static int tolua_Q2Common_QSDK_getLocationInfo00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getLocationInfo'", NULL);
#endif
  {
   self->getLocationInfo();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getLocationInfo'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: bindQQGroup of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_bindQQGroup00
static int tolua_Q2Common_QSDK_bindQQGroup00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     !tolua_isstring(tolua_S,5,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* cUnionid = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* cUnion_name = ((const char*)  tolua_tostring(tolua_S,3,0));
  const char* cZoneid = ((const char*)  tolua_tostring(tolua_S,4,0));
  const char* md5Str = ((const char*)  tolua_tostring(tolua_S,5,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'bindQQGroup'", NULL);
#endif
  {
   self->bindQQGroup(cUnionid,cUnion_name,cZoneid,md5Str);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'bindQQGroup'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: joinQQGroup of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_joinQQGroup00
static int tolua_Q2Common_QSDK_joinQQGroup00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* cQQGroupNum = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* cQQGroupKey = ((const char*)  tolua_tostring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'joinQQGroup'", NULL);
#endif
  {
   self->joinQQGroup(cQQGroupNum,cQQGroupKey);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'joinQQGroup'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: addGameFriendToQQ of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_addGameFriendToQQ00
static int tolua_Q2Common_QSDK_addGameFriendToQQ00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* cFopenid = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* cDesc = ((const char*)  tolua_tostring(tolua_S,3,0));
  const char* cMessage = ((const char*)  tolua_tostring(tolua_S,4,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'addGameFriendToQQ'", NULL);
#endif
  {
   self->addGameFriendToQQ(cFopenid,cDesc,cMessage);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addGameFriendToQQ'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: createWXGroup of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_createWXGroup00
static int tolua_Q2Common_QSDK_createWXGroup00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* unionid = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* chatRoomName = ((const char*)  tolua_tostring(tolua_S,3,0));
  const char* chatRoomNickName = ((const char*)  tolua_tostring(tolua_S,4,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'createWXGroup'", NULL);
#endif
  {
   self->createWXGroup(unionid,chatRoomName,chatRoomNickName);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'createWXGroup'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: joinWXGroup of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_joinWXGroup00
static int tolua_Q2Common_QSDK_joinWXGroup00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* unionid = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* chatRoomNickName = ((const char*)  tolua_tostring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'joinWXGroup'", NULL);
#endif
  {
   self->joinWXGroup(unionid,chatRoomNickName);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'joinWXGroup'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: queryWXGroupInfo of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_queryWXGroupInfo00
static int tolua_Q2Common_QSDK_queryWXGroupInfo00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* unionID = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* openIdLists = ((const char*)  tolua_tostring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'queryWXGroupInfo'", NULL);
#endif
  {
   self->queryWXGroupInfo(unionID,openIdLists);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'queryWXGroupInfo'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: feedback of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_feedback00
static int tolua_Q2Common_QSDK_feedback00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* body = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'feedback'", NULL);
#endif
  {
   self->feedback(body);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'feedback'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: openWeiXinDeeplink of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_openWeiXinDeeplink00
static int tolua_Q2Common_QSDK_openWeiXinDeeplink00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* link = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'openWeiXinDeeplink'", NULL);
#endif
  {
   self->openWeiXinDeeplink(link);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'openWeiXinDeeplink'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getWakeupInfo of class  QSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QSDK_getWakeupInfo00
static int tolua_Q2Common_QSDK_getWakeupInfo00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QSDK",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QSDK* self = (QSDK*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION nHandler = (  toluafix_ref_function(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getWakeupInfo'", NULL);
#endif
  {
   self->getWakeupInfo(nHandler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getWakeupInfo'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getInstance of class  QShareSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QShareSDK_getInstance00
static int tolua_Q2Common_QShareSDK_getInstance00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"QShareSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   QShareSDK* tolua_ret = (QShareSDK*)  QShareSDK::getInstance();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"QShareSDK");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getInstance'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: saveScreenToFile of class  QShareSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QShareSDK_saveScreenToFile00
static int tolua_Q2Common_QShareSDK_saveScreenToFile00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"QShareSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const char* filename = ((const char*)  tolua_tostring(tolua_S,2,0));
  {
   const char* tolua_ret = (const char*)  QShareSDK::saveScreenToFile(filename);
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'saveScreenToFile'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: saveScreenToFile of class  QShareSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QShareSDK_saveScreenToFile01
static int tolua_Q2Common_QShareSDK_saveScreenToFile01(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"QShareSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !tolua_isusertype(tolua_S,3,"const CCRect",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  const char* filename = ((const char*)  tolua_tostring(tolua_S,2,0));
  const CCRect* rect = ((const CCRect*)  tolua_tousertype(tolua_S,3,0));
  {
   const char* tolua_ret = (const char*)  QShareSDK::saveScreenToFile(filename,*rect);
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
tolua_lerror:
 return tolua_Q2Common_QShareSDK_saveScreenToFile00(tolua_S);
}
#endif //#ifndef TOLUA_DISABLE

/* method: shareWithPhoto of class  QShareSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QShareSDK_shareWithPhoto00
static int tolua_Q2Common_QShareSDK_shareWithPhoto00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QShareSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,5,&tolua_err) || !toluafix_isfunction(tolua_S,5,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QShareSDK* self = (QShareSDK*)  tolua_tousertype(tolua_S,1,0);
  ShareSDKPlatform platform = ((ShareSDKPlatform) (int)  tolua_tonumber(tolua_S,2,0));
  const char* imgURL = ((const char*)  tolua_tostring(tolua_S,3,0));
  const char* extInfo = ((const char*)  tolua_tostring(tolua_S,4,0));
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,5,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'shareWithPhoto'", NULL);
#endif
  {
   self->shareWithPhoto(platform,imgURL,extInfo,handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'shareWithPhoto'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: share of class  QShareSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QShareSDK_share00
static int tolua_Q2Common_QShareSDK_share00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QShareSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     !tolua_isstring(tolua_S,5,0,&tolua_err) ||
     !tolua_isstring(tolua_S,6,0,&tolua_err) ||
     !tolua_isstring(tolua_S,7,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,8,&tolua_err) || !toluafix_isfunction(tolua_S,8,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,9,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QShareSDK* self = (QShareSDK*)  tolua_tousertype(tolua_S,1,0);
  ShareSDKPlatform platform = ((ShareSDKPlatform) (int)  tolua_tonumber(tolua_S,2,0));
  const char* title = ((const char*)  tolua_tostring(tolua_S,3,0));
  const char* desc = ((const char*)  tolua_tostring(tolua_S,4,0));
  const char* url = ((const char*)  tolua_tostring(tolua_S,5,0));
  const char* imgURL = ((const char*)  tolua_tostring(tolua_S,6,0));
  const char* extInfo = ((const char*)  tolua_tostring(tolua_S,7,0));
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,8,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'share'", NULL);
#endif
  {
   self->share(platform,title,desc,url,imgURL,extInfo,handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'share'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: shareToFriend of class  QShareSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QShareSDK_shareToFriend00
static int tolua_Q2Common_QShareSDK_shareToFriend00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QShareSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     !tolua_isstring(tolua_S,5,0,&tolua_err) ||
     !tolua_isstring(tolua_S,6,0,&tolua_err) ||
     !tolua_isstring(tolua_S,7,0,&tolua_err) ||
     !tolua_isstring(tolua_S,8,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,9,&tolua_err) || !toluafix_isfunction(tolua_S,9,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,10,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QShareSDK* self = (QShareSDK*)  tolua_tousertype(tolua_S,1,0);
  ShareSDKPlatform platform = ((ShareSDKPlatform) (int)  tolua_tonumber(tolua_S,2,0));
  const char* uid = ((const char*)  tolua_tostring(tolua_S,3,0));
  const char* title = ((const char*)  tolua_tostring(tolua_S,4,0));
  const char* desc = ((const char*)  tolua_tostring(tolua_S,5,0));
  const char* url = ((const char*)  tolua_tostring(tolua_S,6,0));
  const char* imgURL = ((const char*)  tolua_tostring(tolua_S,7,0));
  const char* extInfo = ((const char*)  tolua_tostring(tolua_S,8,0));
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,9,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'shareToFriend'", NULL);
#endif
  {
   self->shareToFriend(platform,uid,title,desc,url,imgURL,extInfo,handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'shareToFriend'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: shareWithUrl of class  QShareSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QShareSDK_shareWithUrl00
static int tolua_Q2Common_QShareSDK_shareWithUrl00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QShareSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     !tolua_isstring(tolua_S,5,0,&tolua_err) ||
     !tolua_isstring(tolua_S,6,0,&tolua_err) ||
     !tolua_isstring(tolua_S,7,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,8,&tolua_err) || !toluafix_isfunction(tolua_S,8,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,9,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QShareSDK* self = (QShareSDK*)  tolua_tousertype(tolua_S,1,0);
  ShareSDKPlatform platform = ((ShareSDKPlatform) (int)  tolua_tonumber(tolua_S,2,0));
  const char* title = ((const char*)  tolua_tostring(tolua_S,3,0));
  const char* desc = ((const char*)  tolua_tostring(tolua_S,4,0));
  const char* url = ((const char*)  tolua_tostring(tolua_S,5,0));
  const char* imgURL = ((const char*)  tolua_tostring(tolua_S,6,0));
  const char* extInfo = ((const char*)  tolua_tostring(tolua_S,7,0));
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,8,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'shareWithUrl'", NULL);
#endif
  {
   self->shareWithUrl(platform,title,desc,url,imgURL,extInfo,handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'shareWithUrl'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getInstance of class  QTssSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QTssSDK_getInstance00
static int tolua_Q2Common_QTssSDK_getInstance00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"QTssSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   QTssSDK* tolua_ret = (QTssSDK*)  QTssSDK::getInstance();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"QTssSDK");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getInstance'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: initTssSdk of class  QTssSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QTssSDK_initTssSdk00
static int tolua_Q2Common_QTssSDK_initTssSdk00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QTssSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QTssSDK* self = (QTssSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'initTssSdk'", NULL);
#endif
  {
   self->initTssSdk();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'initTssSdk'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setHandler of class  QTssSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QTssSDK_setHandler00
static int tolua_Q2Common_QTssSDK_setHandler00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QTssSDK",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QTssSDK* self = (QTssSDK*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setHandler'", NULL);
#endif
  {
   self->setHandler(handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setHandler'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: send_server_data of class  QTssSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QTssSDK_send_server_data00
static int tolua_Q2Common_QTssSDK_send_server_data00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QTssSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QTssSDK* self = (QTssSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* data = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'send_server_data'", NULL);
#endif
  {
   self->send_server_data(data);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'send_server_data'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setUserInfo of class  QTssSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QTssSDK_setUserInfo00
static int tolua_Q2Common_QTssSDK_setUserInfo00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QTssSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     !tolua_isstring(tolua_S,5,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QTssSDK* self = (QTssSDK*)  tolua_tousertype(tolua_S,1,0);
  int platform = ((int)  tolua_tonumber(tolua_S,2,0));
  const char* open_id = ((const char*)  tolua_tostring(tolua_S,3,0));
  int world_id = ((int)  tolua_tonumber(tolua_S,4,0));
  const char* uid = ((const char*)  tolua_tostring(tolua_S,5,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setUserInfo'", NULL);
#endif
  {
   self->setUserInfo(platform,open_id,world_id,uid);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setUserInfo'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setGameStatusFrontground of class  QTssSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QTssSDK_setGameStatusFrontground00
static int tolua_Q2Common_QTssSDK_setGameStatusFrontground00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QTssSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QTssSDK* self = (QTssSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setGameStatusFrontground'", NULL);
#endif
  {
   self->setGameStatusFrontground();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setGameStatusFrontground'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setGameStatusBackground of class  QTssSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QTssSDK_setGameStatusBackground00
static int tolua_Q2Common_QTssSDK_setGameStatusBackground00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QTssSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QTssSDK* self = (QTssSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setGameStatusBackground'", NULL);
#endif
  {
   self->setGameStatusBackground();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setGameStatusBackground'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: callback of class  QTssSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QTssSDK_callback00
static int tolua_Q2Common_QTssSDK_callback00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QTssSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QTssSDK* self = (QTssSDK*)  tolua_tousertype(tolua_S,1,0);
  int code = ((int)  tolua_tonumber(tolua_S,2,0));
  const char* msg = ((const char*)  tolua_tostring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'callback'", NULL);
#endif
  {
   self->callback(code,msg);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'callback'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getInstance of class  QMSCSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QMSCSDK_getInstance00
static int tolua_Q2Common_QMSCSDK_getInstance00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"QMSCSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   QMSCSDK* tolua_ret = (QMSCSDK*)  QMSCSDK::getInstance();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"QMSCSDK");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getInstance'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: init of class  QMSCSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QMSCSDK_init00
static int tolua_Q2Common_QMSCSDK_init00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QMSCSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QMSCSDK* self = (QMSCSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'init'", NULL);
#endif
  {
   self->init();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'init'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: startRecogn of class  QMSCSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QMSCSDK_startRecogn00
static int tolua_Q2Common_QMSCSDK_startRecogn00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QMSCSDK",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
     (tolua_isvaluenil(tolua_S,4,&tolua_err) || !toluafix_isfunction(tolua_S,4,"LUA_FUNCTION",0,&tolua_err)) ||
     (tolua_isvaluenil(tolua_S,5,&tolua_err) || !toluafix_isfunction(tolua_S,5,"LUA_FUNCTION",0,&tolua_err)) ||
     (tolua_isvaluenil(tolua_S,6,&tolua_err) || !toluafix_isfunction(tolua_S,6,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,7,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QMSCSDK* self = (QMSCSDK*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION start_handler = (  toluafix_ref_function(tolua_S,2,0));
  LUA_FUNCTION voice_handler = (  toluafix_ref_function(tolua_S,3,0));
  LUA_FUNCTION text_handler = (  toluafix_ref_function(tolua_S,4,0));
  LUA_FUNCTION finish_handler = (  toluafix_ref_function(tolua_S,5,0));
  LUA_FUNCTION err_handler = (  toluafix_ref_function(tolua_S,6,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'startRecogn'", NULL);
#endif
  {
   self->startRecogn(start_handler,voice_handler,text_handler,finish_handler,err_handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'startRecogn'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: stopRecogn of class  QMSCSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QMSCSDK_stopRecogn00
static int tolua_Q2Common_QMSCSDK_stopRecogn00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QMSCSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QMSCSDK* self = (QMSCSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'stopRecogn'", NULL);
#endif
  {
   self->stopRecogn();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'stopRecogn'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: cancelRecogn of class  QMSCSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QMSCSDK_cancelRecogn00
static int tolua_Q2Common_QMSCSDK_cancelRecogn00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QMSCSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QMSCSDK* self = (QMSCSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'cancelRecogn'", NULL);
#endif
  {
   self->cancelRecogn();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'cancelRecogn'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: playVoice of class  QMSCSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QMSCSDK_playVoice00
static int tolua_Q2Common_QMSCSDK_playVoice00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QMSCSDK",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QMSCSDK* self = (QMSCSDK*)  tolua_tousertype(tolua_S,1,0);
  const char* voice = ((const char*)  tolua_tostring(tolua_S,2,0));
  LUA_FUNCTION mFinishHandler = (  toluafix_ref_function(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'playVoice'", NULL);
#endif
  {
   self->playVoice(voice,mFinishHandler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'playVoice'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: stopVoice of class  QMSCSDK */
#ifndef TOLUA_DISABLE_tolua_Q2Common_QMSCSDK_stopVoice00
static int tolua_Q2Common_QMSCSDK_stopVoice00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QMSCSDK",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QMSCSDK* self = (QMSCSDK*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'stopVoice'", NULL);
#endif
  {
   self->stopVoice();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'stopVoice'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_Q2Common_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  #ifdef __cplusplus
  tolua_cclass(tolua_S,"CCPlatform3D","CCPlatform3D","CCLayer",tolua_collect_CCPlatform3D);
  #else
  tolua_cclass(tolua_S,"CCPlatform3D","CCPlatform3D","CCLayer",NULL);
  #endif
  tolua_beginmodule(tolua_S,"CCPlatform3D");
   tolua_function(tolua_S,"create",tolua_Q2Common_CCPlatform3D_create00);
   tolua_function(tolua_S,"new",tolua_Q2Common_CCPlatform3D_new00);
   tolua_function(tolua_S,"new_local",tolua_Q2Common_CCPlatform3D_new00_local);
   tolua_function(tolua_S,".call",tolua_Q2Common_CCPlatform3D_new00_local);
   tolua_function(tolua_S,"delete",tolua_Q2Common_CCPlatform3D_delete00);
   tolua_function(tolua_S,"pause",tolua_Q2Common_CCPlatform3D_pause00);
   tolua_function(tolua_S,"resume",tolua_Q2Common_CCPlatform3D_resume00);
   tolua_function(tolua_S,"setHandlerPriority",tolua_Q2Common_CCPlatform3D_setHandlerPriority00);
   tolua_function(tolua_S,"registerWithTouchDispatcher",tolua_Q2Common_CCPlatform3D_registerWithTouchDispatcher00);
   tolua_function(tolua_S,"ccTouchBegan",tolua_Q2Common_CCPlatform3D_ccTouchBegan00);
   tolua_function(tolua_S,"ccTouchEnded",tolua_Q2Common_CCPlatform3D_ccTouchEnded00);
   tolua_function(tolua_S,"ccTouchCancelled",tolua_Q2Common_CCPlatform3D_ccTouchCancelled00);
   tolua_function(tolua_S,"ccTouchMoved",tolua_Q2Common_CCPlatform3D_ccTouchMoved00);
   tolua_function(tolua_S,"initialize",tolua_Q2Common_CCPlatform3D_initialize00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCLayer3D","CCLayer3D","CCLayer",NULL);
  tolua_beginmodule(tolua_S,"CCLayer3D");
   tolua_function(tolua_S,"create",tolua_Q2Common_CCLayer3D_create00);
   tolua_function(tolua_S,"setSceneName",tolua_Q2Common_CCLayer3D_setSceneName00);
   tolua_function(tolua_S,"getSceneName",tolua_Q2Common_CCLayer3D_getSceneName00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCRenderTarget3D","CCRenderTarget3D","CCLayer",NULL);
  tolua_beginmodule(tolua_S,"CCRenderTarget3D");
   tolua_function(tolua_S,"create",tolua_Q2Common_CCRenderTarget3D_create00);
   tolua_function(tolua_S,"addTargetSprite",tolua_Q2Common_CCRenderTarget3D_addTargetSprite00);
   tolua_function(tolua_S,"removeTargetSprite",tolua_Q2Common_CCRenderTarget3D_removeTargetSprite00);
   tolua_function(tolua_S,"removeTargetSprite",tolua_Q2Common_CCRenderTarget3D_removeTargetSprite01);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCPlistFrame","CCPlistFrame","cocos2dCCObject",NULL);
  tolua_beginmodule(tolua_S,"CCPlistFrame");
   tolua_function(tolua_S,"loadPlist",tolua_Q2Common_CCPlistFrame_loadPlist00);
  tolua_endmodule(tolua_S);
  tolua_constant(tolua_S,"PLATFORM_NONE",PLATFORM_NONE);
  tolua_constant(tolua_S,"PLATFORM_GUEST",PLATFORM_GUEST);
  tolua_constant(tolua_S,"PLATFORM_QQ",PLATFORM_QQ);
  tolua_constant(tolua_S,"PLATFORM_WEIXIN",PLATFORM_WEIXIN);
  tolua_constant(tolua_S,"MIDAS_ORDER",MIDAS_ORDER);
  tolua_constant(tolua_S,"MIDAS_PAY",MIDAS_PAY);
  tolua_constant(tolua_S,"MIDAS_DISTRIBUTE_GOODS",MIDAS_DISTRIBUTE_GOODS);
  tolua_constant(tolua_S,"MIDAS_RESTORABLE_PRODUCT",MIDAS_RESTORABLE_PRODUCT);
  tolua_constant(tolua_S,"MIDAS_GET_RESTORABLE_PRODUCT",MIDAS_GET_RESTORABLE_PRODUCT);
  tolua_constant(tolua_S,"MIDAS_GET_PRODUCT_INFO",MIDAS_GET_PRODUCT_INFO);
  tolua_constant(tolua_S,"MIDAS_NET_WORK",MIDAS_NET_WORK);
  tolua_constant(tolua_S,"MIDAS_LOGIN_EXPIRY",MIDAS_LOGIN_EXPIRY);
  tolua_constant(tolua_S,"MIDAS_GET_RECOMMEND_LIST",MIDAS_GET_RECOMMEND_LIST);
  tolua_constant(tolua_S,"MIDAS_LOGIN_FAIL",MIDAS_LOGIN_FAIL);
  tolua_constant(tolua_S,"SDK_EVENT_INIT",SDK_EVENT_INIT);
  tolua_constant(tolua_S,"SDK_EVENT_LOGIN",SDK_EVENT_LOGIN);
  tolua_constant(tolua_S,"SDK_EVENT_LOGOUT",SDK_EVENT_LOGOUT);
  tolua_constant(tolua_S,"SDK_EVENT_PAY",SDK_EVENT_PAY);
  tolua_constant(tolua_S,"SDK_EVENT_USER_INFO",SDK_EVENT_USER_INFO);
  tolua_constant(tolua_S,"SDK_EVENT_FRIEND_INFO",SDK_EVENT_FRIEND_INFO);
  tolua_constant(tolua_S,"SDK_EVENT_NEARBY_PERSON_INFO",SDK_EVENT_NEARBY_PERSON_INFO);
  tolua_constant(tolua_S,"SDK_EVENT_LOCATION_INFO",SDK_EVENT_LOCATION_INFO);
  tolua_constant(tolua_S,"SDK_EVENT_SHARE_NOTICE",SDK_EVENT_SHARE_NOTICE);
  tolua_cclass(tolua_S,"QSDK","QSDK","",NULL);
  tolua_beginmodule(tolua_S,"QSDK");
   tolua_function(tolua_S,"sharedQSDK",tolua_Q2Common_QSDK_sharedQSDK00);
   tolua_function(tolua_S,"init",tolua_Q2Common_QSDK_init00);
   tolua_function(tolua_S,"login",tolua_Q2Common_QSDK_login00);
   tolua_function(tolua_S,"qrCodeLogin",tolua_Q2Common_QSDK_qrCodeLogin00);
   tolua_function(tolua_S,"switchUser",tolua_Q2Common_QSDK_switchUser00);
   tolua_function(tolua_S,"logout",tolua_Q2Common_QSDK_logout00);
   tolua_function(tolua_S,"getUid",tolua_Q2Common_QSDK_getUid00);
   tolua_function(tolua_S,"getOpenId",tolua_Q2Common_QSDK_getOpenId00);
   tolua_function(tolua_S,"getAccessToken",tolua_Q2Common_QSDK_getAccessToken00);
   tolua_function(tolua_S,"getPayToken",tolua_Q2Common_QSDK_getPayToken00);
   tolua_function(tolua_S,"getPf",tolua_Q2Common_QSDK_getPf00);
   tolua_function(tolua_S,"getPfKey",tolua_Q2Common_QSDK_getPfKey00);
   tolua_function(tolua_S,"getUdid",tolua_Q2Common_QSDK_getUdid00);
   tolua_function(tolua_S,"getExtraInfo",tolua_Q2Common_QSDK_getExtraInfo00);
   tolua_function(tolua_S,"isPlatformInstalled",tolua_Q2Common_QSDK_isPlatformInstalled00);
   tolua_function(tolua_S,"getUserInfo",tolua_Q2Common_QSDK_getUserInfo00);
   tolua_function(tolua_S,"getFriendsInfo",tolua_Q2Common_QSDK_getFriendsInfo00);
   tolua_function(tolua_S,"openURL",tolua_Q2Common_QSDK_openURL00);
   tolua_function(tolua_S,"pay",tolua_Q2Common_QSDK_pay00);
   tolua_function(tolua_S,"reportEvent",tolua_Q2Common_QSDK_reportEvent00);
   tolua_function(tolua_S,"registerPay",tolua_Q2Common_QSDK_registerPay00);
   tolua_function(tolua_S,"showNotice",tolua_Q2Common_QSDK_showNotice00);
   tolua_function(tolua_S,"getNoticeData",tolua_Q2Common_QSDK_getNoticeData00);
   tolua_function(tolua_S,"hideScrollNotice",tolua_Q2Common_QSDK_hideScrollNotice00);
   tolua_function(tolua_S,"buglyLog",tolua_Q2Common_QSDK_buglyLog00);
   tolua_function(tolua_S,"getNearbyPersonInfo",tolua_Q2Common_QSDK_getNearbyPersonInfo00);
   tolua_function(tolua_S,"cleanLocation",tolua_Q2Common_QSDK_cleanLocation00);
   tolua_function(tolua_S,"getLocationInfo",tolua_Q2Common_QSDK_getLocationInfo00);
   tolua_function(tolua_S,"bindQQGroup",tolua_Q2Common_QSDK_bindQQGroup00);
   tolua_function(tolua_S,"joinQQGroup",tolua_Q2Common_QSDK_joinQQGroup00);
   tolua_function(tolua_S,"addGameFriendToQQ",tolua_Q2Common_QSDK_addGameFriendToQQ00);
   tolua_function(tolua_S,"createWXGroup",tolua_Q2Common_QSDK_createWXGroup00);
   tolua_function(tolua_S,"joinWXGroup",tolua_Q2Common_QSDK_joinWXGroup00);
   tolua_function(tolua_S,"queryWXGroupInfo",tolua_Q2Common_QSDK_queryWXGroupInfo00);
   tolua_function(tolua_S,"feedback",tolua_Q2Common_QSDK_feedback00);
   tolua_function(tolua_S,"openWeiXinDeeplink",tolua_Q2Common_QSDK_openWeiXinDeeplink00);
   tolua_function(tolua_S,"getWakeupInfo",tolua_Q2Common_QSDK_getWakeupInfo00);
  tolua_endmodule(tolua_S);
  tolua_constant(tolua_S,"kSharePlatform_NONE",kSharePlatform_NONE);
  tolua_constant(tolua_S,"kSharePlatform_QQ",kSharePlatform_QQ);
  tolua_constant(tolua_S,"kSharePlatform_WECHAT",kSharePlatform_WECHAT);
  tolua_cclass(tolua_S,"QShareSDK","QShareSDK","",NULL);
  tolua_beginmodule(tolua_S,"QShareSDK");
   tolua_function(tolua_S,"getInstance",tolua_Q2Common_QShareSDK_getInstance00);
   tolua_function(tolua_S,"saveScreenToFile",tolua_Q2Common_QShareSDK_saveScreenToFile00);
   tolua_function(tolua_S,"saveScreenToFile",tolua_Q2Common_QShareSDK_saveScreenToFile01);
   tolua_function(tolua_S,"shareWithPhoto",tolua_Q2Common_QShareSDK_shareWithPhoto00);
   tolua_function(tolua_S,"share",tolua_Q2Common_QShareSDK_share00);
   tolua_function(tolua_S,"shareToFriend",tolua_Q2Common_QShareSDK_shareToFriend00);
   tolua_function(tolua_S,"shareWithUrl",tolua_Q2Common_QShareSDK_shareWithUrl00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"QTssSDK","QTssSDK","",NULL);
  tolua_beginmodule(tolua_S,"QTssSDK");
   tolua_function(tolua_S,"getInstance",tolua_Q2Common_QTssSDK_getInstance00);
   tolua_function(tolua_S,"initTssSdk",tolua_Q2Common_QTssSDK_initTssSdk00);
   tolua_function(tolua_S,"setHandler",tolua_Q2Common_QTssSDK_setHandler00);
   tolua_function(tolua_S,"send_server_data",tolua_Q2Common_QTssSDK_send_server_data00);
   tolua_function(tolua_S,"setUserInfo",tolua_Q2Common_QTssSDK_setUserInfo00);
   tolua_function(tolua_S,"setGameStatusFrontground",tolua_Q2Common_QTssSDK_setGameStatusFrontground00);
   tolua_function(tolua_S,"setGameStatusBackground",tolua_Q2Common_QTssSDK_setGameStatusBackground00);
   tolua_function(tolua_S,"callback",tolua_Q2Common_QTssSDK_callback00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"QMSCSDK","QMSCSDK","",NULL);
  tolua_beginmodule(tolua_S,"QMSCSDK");
   tolua_function(tolua_S,"getInstance",tolua_Q2Common_QMSCSDK_getInstance00);
   tolua_function(tolua_S,"init",tolua_Q2Common_QMSCSDK_init00);
   tolua_function(tolua_S,"startRecogn",tolua_Q2Common_QMSCSDK_startRecogn00);
   tolua_function(tolua_S,"stopRecogn",tolua_Q2Common_QMSCSDK_stopRecogn00);
   tolua_function(tolua_S,"cancelRecogn",tolua_Q2Common_QMSCSDK_cancelRecogn00);
   tolua_function(tolua_S,"playVoice",tolua_Q2Common_QMSCSDK_playVoice00);
   tolua_function(tolua_S,"stopVoice",tolua_Q2Common_QMSCSDK_stopVoice00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_Q2Common (lua_State* tolua_S) {
 return tolua_Q2Common_open(tolua_S);
};
#endif

