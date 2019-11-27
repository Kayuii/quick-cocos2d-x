/*
** Lua binding: SkeletonAnimation_luabinding
** Generated automatically by tolua++-1.0.92 on 08/29/16 13:01:44.
*/

#include "SkeletonAnimation_luabinding.h"
#include "CCLuaEngine.h"

using namespace cocos2d;

#include "../../../extensions/spine/spine.h"
#include "../../../extensions/spine/SkeletonAnimation.h"

/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"std::function<void(int trackIndex, int loopCount)>");
 tolua_usertype(tolua_S,"spTrackEntry"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spTrackEntry)), "spTrackEntry");
 tolua_usertype(tolua_S,"SkeletonAnimation"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spine::SkeletonAnimation)), "SkeletonAnimation");
 tolua_usertype(tolua_S,"spSkeletonData"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spSkeletonData)), "spSkeletonData");
 tolua_usertype(tolua_S,"SkeletonRenderer"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spine::SkeletonRenderer)), "SkeletonRenderer");
 tolua_usertype(tolua_S,"spEvent"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spEvent)), "spEvent");
 tolua_usertype(tolua_S,"spAnimationStateData"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spAnimationStateData)), "spAnimationStateData");
 tolua_usertype(tolua_S,"std::function<void(int trackIndex)>");
 tolua_usertype(tolua_S,"spEventType"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spEventType)), "spEventType");
 tolua_usertype(tolua_S,"std::function<void(int trackIndex, spEvent* event)>");
 tolua_usertype(tolua_S,"spAtlas"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spAtlas)), "spAtlas");
}

/* method: createWithData of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_createWithData00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_createWithData00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"spSkeletonData",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spSkeletonData* skeletonData = ((spSkeletonData*)  tolua_tousertype(tolua_S,2,0));
  {
   spine::SkeletonAnimation* tolua_ret = (spine::SkeletonAnimation*)  spine::SkeletonAnimation::createWithData(skeletonData);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"SkeletonAnimation");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'createWithData'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: createWithFile of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_createWithFile00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_createWithFile00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isusertype(tolua_S,3,"spAtlas",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const char* skeletonDataFile = ((const char*)  tolua_tostring(tolua_S,2,0));
  spAtlas* atlas = ((spAtlas*)  tolua_tousertype(tolua_S,3,0));
  float scale = ((float)  tolua_tonumber(tolua_S,4,0));
  {
   spine::SkeletonAnimation* tolua_ret = (spine::SkeletonAnimation*)  spine::SkeletonAnimation::createWithFile(skeletonDataFile,atlas,scale);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"SkeletonAnimation");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'createWithFile'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: createWithFile of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_createWithFile01
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_createWithFile01(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  const char* skeletonDataFile = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* atlasFile = ((const char*)  tolua_tostring(tolua_S,3,0));
  float scale = ((float)  tolua_tonumber(tolua_S,4,0));
  {
   spine::SkeletonAnimation* tolua_ret = (spine::SkeletonAnimation*)  spine::SkeletonAnimation::createWithFile(skeletonDataFile,atlasFile,scale);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"SkeletonAnimation");
  }
 }
 return 1;
tolua_lerror:
 return tolua_SkeletonAnimation_luabinding_SkeletonAnimation_createWithFile00(tolua_S);
}
#endif //#ifndef TOLUA_DISABLE

/* method: setAnimationStateData of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setAnimationStateData00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setAnimationStateData00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"spAnimationStateData",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
  spAnimationStateData* stateData = ((spAnimationStateData*)  tolua_tousertype(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setAnimationStateData'", NULL);
#endif
  {
   self->setAnimationStateData(stateData);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setAnimationStateData'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setMix of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setMix00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setMix00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
  const char* fromAnimation = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* toAnimation = ((const char*)  tolua_tostring(tolua_S,3,0));
  float duration = ((float)  tolua_tonumber(tolua_S,4,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setMix'", NULL);
#endif
  {
   self->setMix(fromAnimation,toAnimation,duration);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setMix'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setAnimation of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setAnimation00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setAnimation00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,4,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
  int trackIndex = ((int)  tolua_tonumber(tolua_S,2,0));
  const char* name = ((const char*)  tolua_tostring(tolua_S,3,0));
  bool loop = ((bool)  tolua_toboolean(tolua_S,4,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setAnimation'", NULL);
#endif
  {
   spTrackEntry* tolua_ret = (spTrackEntry*)  self->setAnimation(trackIndex,name,loop);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"spTrackEntry");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setAnimation'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: addAnimation of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_addAnimation00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_addAnimation00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,4,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,5,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
  int trackIndex = ((int)  tolua_tonumber(tolua_S,2,0));
  const char* name = ((const char*)  tolua_tostring(tolua_S,3,0));
  bool loop = ((bool)  tolua_toboolean(tolua_S,4,0));
  float delay = ((float)  tolua_tonumber(tolua_S,5,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'addAnimation'", NULL);
#endif
  {
   spTrackEntry* tolua_ret = (spTrackEntry*)  self->addAnimation(trackIndex,name,loop,delay);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"spTrackEntry");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addAnimation'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getCurrent of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_getCurrent00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_getCurrent00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
  int trackIndex = ((int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getCurrent'", NULL);
#endif
  {
   spTrackEntry* tolua_ret = (spTrackEntry*)  self->getCurrent(trackIndex);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"spTrackEntry");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getCurrent'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: clearTracks of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_clearTracks00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_clearTracks00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'clearTracks'", NULL);
#endif
  {
   self->clearTracks();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'clearTracks'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: clearTrack of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_clearTrack00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_clearTrack00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
  int trackIndex = ((int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'clearTrack'", NULL);
#endif
  {
   self->clearTrack(trackIndex);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'clearTrack'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setStartListener of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setStartListener00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setStartListener00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"spTrackEntry",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !tolua_isusertype(tolua_S,3,"std::function<void(int trackIndex)>",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
  spTrackEntry* entry = ((spTrackEntry*)  tolua_tousertype(tolua_S,2,0));
   std::function<void(int trackIndex)> listener = *((  std::function<void(int trackIndex)>*)  tolua_tousertype(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setStartListener'", NULL);
#endif
  {
   self->setStartListener(entry,listener);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setStartListener'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setEndListener of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setEndListener00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setEndListener00(lua_State* tolua_S)
{
    int argc = 0;
    spine::SkeletonAnimation* cobj = nullptr;
    bool ok  = true;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif
    
    
#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err)) goto tolua_lerror;
#endif
    
    cobj = (spine::SkeletonAnimation*)tolua_tousertype(tolua_S,1,0);
    
#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_spine_SkeletonAnimation_setEndListener'", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(tolua_S)-1;
    if (argc == 2)
    {
        std::function<void (int)> arg0;
        
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_spine_SkeletonAnimation_setEndListener'", nullptr);
            return 0;
        }
        spTrackEntry *  entry= ((spTrackEntry* ) tolua_touserdata(tolua_S, 2, 0));
        cobj->setEndListener(entry,arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sp.SkeletonAnimation:setEndListener",argc, 1);
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_spine_SkeletonAnimation_setEndListener'.",&tolua_err);
#endif
    
    return 0;}
#endif //#ifndef TOLUA_DISABLE

/* method: setCompleteListener of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setCompleteListener00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setCompleteListener00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"spTrackEntry",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !tolua_isusertype(tolua_S,3,"std::function<void(int trackIndex, int loopCount)>",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
  spTrackEntry* entry = ((spTrackEntry*)  tolua_tousertype(tolua_S,2,0));
   std::function<void(int trackIndex, int loopCount)> listener = *((  std::function<void(int trackIndex, int loopCount)>*)  tolua_tousertype(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setCompleteListener'", NULL);
#endif
  {
   self->setCompleteListener(entry,listener);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setCompleteListener'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setEventListener of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setEventListener00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setEventListener00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"spTrackEntry",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !tolua_isusertype(tolua_S,3,"std::function<void(int trackIndex, spEvent* event)>",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
  spTrackEntry* entry = ((spTrackEntry*)  tolua_tousertype(tolua_S,2,0));
   std::function<void(int trackIndex, spEvent* event)> listener = *((  std::function<void(int trackIndex, spEvent* event)>*)  tolua_tousertype(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setEventListener'", NULL);
#endif
  {
   self->setEventListener(entry,listener);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setEventListener'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: onAnimationStateEvent of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_onAnimationStateEvent00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_onAnimationStateEvent00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !tolua_isusertype(tolua_S,3,"spEventType",0,&tolua_err)) ||
     !tolua_isusertype(tolua_S,4,"spEvent",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,5,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
  int trackIndex = ((int)  tolua_tonumber(tolua_S,2,0));
  spEventType type = *((spEventType*)  tolua_tousertype(tolua_S,3,0));
  spEvent* event = ((spEvent*)  tolua_tousertype(tolua_S,4,0));
  int loopCount = ((int)  tolua_tonumber(tolua_S,5,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'onAnimationStateEvent'", NULL);
#endif
  {
   self->onAnimationStateEvent(trackIndex,type,event,loopCount);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'onAnimationStateEvent'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: onTrackEntryEvent of class  SkeletonAnimation */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation_onTrackEntryEvent00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation_onTrackEntryEvent00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !tolua_isusertype(tolua_S,3,"spEventType",0,&tolua_err)) ||
     !tolua_isusertype(tolua_S,4,"spEvent",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,5,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
  int trackIndex = ((int)  tolua_tonumber(tolua_S,2,0));
  spEventType type = *((spEventType*)  tolua_tousertype(tolua_S,3,0));
  spEvent* event = ((spEvent*)  tolua_tousertype(tolua_S,4,0));
  int loopCount = ((int)  tolua_tonumber(tolua_S,5,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'onTrackEntryEvent'", NULL);
#endif
  {
   self->onTrackEntryEvent(trackIndex,type,event,loopCount);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'onTrackEntryEvent'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE
/* method: addHandleOfControlEvent of class  Spine */
#ifndef TOLUA_DISABLE_tolua_SkeletonAnimation_luabinding_SkeletonAnimation__addHandleOfSpineEvent00
static int tolua_SkeletonAnimation_luabinding_SkeletonAnimation__addHandleOfSpineEvent00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isusertype(tolua_S,1,"SkeletonAnimation",0,&tolua_err) ||
        (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
        !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
        !tolua_isnoobj(tolua_S,4,&tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        spine::SkeletonAnimation* self = (spine::SkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
        LUA_FUNCTION nFunID = (  toluafix_ref_function(tolua_S,2,0));
        unsigned int controlEvent = (( unsigned int)  tolua_tonumber(tolua_S,3,0));
#ifndef TOLUA_RELEASE
        if (!self) tolua_error(tolua_S,"invalid 'self' in function 'addHandleOfSpineEvent'", NULL);
#endif
        {
            self->addHandleOfSpineEvent(nFunID,controlEvent);
        }
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'addHandleOfSpineEvent'.",&tolua_err);
    return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


/* Open function */
TOLUA_API int tolua_SkeletonAnimation_luabinding_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"SkeletonAnimation","SkeletonAnimation","SkeletonRenderer",NULL);
  tolua_beginmodule(tolua_S,"SkeletonAnimation");
   tolua_function(tolua_S,"createWithData",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_createWithData00);
   tolua_function(tolua_S,"createWithFile",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_createWithFile00);
   tolua_function(tolua_S,"createWithFile",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_createWithFile01);
   tolua_function(tolua_S,"setAnimationStateData",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setAnimationStateData00);
   tolua_function(tolua_S,"setMix",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setMix00);
   tolua_function(tolua_S,"setAnimation",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setAnimation00);
   tolua_function(tolua_S,"addAnimation",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_addAnimation00);
   tolua_function(tolua_S,"getCurrent",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_getCurrent00);
   tolua_function(tolua_S,"clearTracks",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_clearTracks00);
   tolua_function(tolua_S,"clearTrack",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_clearTrack00);
   tolua_function(tolua_S,"setStartListener",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setStartListener00);
   tolua_function(tolua_S,"setEndListener",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setEndListener00);
   tolua_function(tolua_S,"setCompleteListener",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setCompleteListener00);
   tolua_function(tolua_S,"setEventListener",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_setEventListener00);
   tolua_function(tolua_S,"onAnimationStateEvent",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_onAnimationStateEvent00);
   tolua_function(tolua_S,"onTrackEntryEvent",tolua_SkeletonAnimation_luabinding_SkeletonAnimation_onTrackEntryEvent00);
   tolua_function(tolua_S,"addHandleOfSpineEvent",tolua_SkeletonAnimation_luabinding_SkeletonAnimation__addHandleOfSpineEvent00);
   tolua_endmodule(tolua_S);
   tolua_constant(tolua_S,"CCSpineAnimationStart",CCSpineAnimationStart);
   tolua_constant(tolua_S,"CCSpineAnimationEnd",CCSpineAnimationEnd);
   tolua_constant(tolua_S,"CCSpineAnimationCompelete",CCSpineAnimationCompelete);
   tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_SkeletonAnimation_luabinding (lua_State* tolua_S) {
 return tolua_SkeletonAnimation_luabinding_open(tolua_S);
};
#endif

