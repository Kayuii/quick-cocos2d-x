/*
** Lua binding: SkeletonRenderer_luabinding
** Generated automatically by tolua++-1.0.92 on 08/29/16 13:01:45.
*/

#include "SkeletonRenderer_luabinding.h"
#include "CCLuaEngine.h"

using namespace cocos2d;

#include "../../../extensions/spine/spine.h"
#include "../../../extensions/spine/Atlas.h"
#include "../../../extensions/spine/SkeletonRenderer.h"
/* function to release collected object via destructor */
#ifdef __cplusplus

static int tolua_collect_ccBlendFunc (lua_State* tolua_S)
{
 ccBlendFunc* self = (ccBlendFunc*) tolua_tousertype(tolua_S,1,0);
    Mtolua_delete(self);
    return 0;
}
#endif


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"spSlot"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spSlot)), "spSlot");
 tolua_usertype(tolua_S,"CCBlendProtocol"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(CCBlendProtocol)), "CCBlendProtocol");
 tolua_usertype(tolua_S,"SkeletonRenderer"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spine::SkeletonRenderer)), "SkeletonRenderer");
 tolua_usertype(tolua_S,"spAttachment"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spAttachment)), "spAttachment");
 tolua_usertype(tolua_S,"spBone"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spBone)), "spBone");
 tolua_usertype(tolua_S,"ccBlendFunc"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(ccBlendFunc)), "ccBlendFunc");
 tolua_usertype(tolua_S,"CCNode"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(CCNode)), "CCNode");
 tolua_usertype(tolua_S,"spSkeletonData"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spSkeletonData)), "spSkeletonData");
 tolua_usertype(tolua_S,"spAtlas"); toluafix_add_type_mapping(CLASS_HASH_CODE(typeid(spAtlas)), "spAtlas");
}

/* method: createWithData of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_createWithData00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_createWithData00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"spSkeletonData",0,&tolua_err) ||
     !tolua_isboolean(tolua_S,3,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spSkeletonData* skeletonData = ((spSkeletonData*)  tolua_tousertype(tolua_S,2,0));
  bool ownsSkeletonData = ((bool)  tolua_toboolean(tolua_S,3,false));
  {
   spine::SkeletonRenderer* tolua_ret = (spine::SkeletonRenderer*)  spine::SkeletonRenderer::createWithData(skeletonData,ownsSkeletonData);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"SkeletonRenderer");
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

/* method: createWithFile of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_createWithFile00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_createWithFile00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
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
   spine::SkeletonRenderer* tolua_ret = (spine::SkeletonRenderer*)  spine::SkeletonRenderer::createWithFile(skeletonDataFile,atlas,scale);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"SkeletonRenderer");
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

/* method: createWithFile of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_createWithFile01
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_createWithFile01(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
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
   spine::SkeletonRenderer* tolua_ret = (spine::SkeletonRenderer*)  spine::SkeletonRenderer::createWithFile(skeletonDataFile,atlasFile,scale);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"SkeletonRenderer");
  }
 }
 return 1;
tolua_lerror:
 return tolua_SkeletonRenderer_luabinding_SkeletonRenderer_createWithFile00(tolua_S);
}
#endif //#ifndef TOLUA_DISABLE

/* method: updateWorldTransform of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_updateWorldTransform00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_updateWorldTransform00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'updateWorldTransform'", NULL);
#endif
  {
   self->updateWorldTransform();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'updateWorldTransform'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setToSetupPose of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setToSetupPose00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setToSetupPose00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setToSetupPose'", NULL);
#endif
  {
   self->setToSetupPose();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setToSetupPose'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setBonesToSetupPose of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setBonesToSetupPose00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setBonesToSetupPose00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setBonesToSetupPose'", NULL);
#endif
  {
   self->setBonesToSetupPose();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setBonesToSetupPose'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setSlotsToSetupPose of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setSlotsToSetupPose00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setSlotsToSetupPose00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setSlotsToSetupPose'", NULL);
#endif
  {
   self->setSlotsToSetupPose();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setSlotsToSetupPose'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: findBone of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_findBone00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_findBone00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
  const char* boneName = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'findBone'", NULL);
#endif
  {
   spBone* tolua_ret = (spBone*)  self->findBone(boneName);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"spBone");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'findBone'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: findSlot of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_findSlot00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_findSlot00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
  const char* slotName = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'findSlot'", NULL);
#endif
  {
   spSlot* tolua_ret = (spSlot*)  self->findSlot(slotName);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"spSlot");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'findSlot'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setSkin of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setSkin00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setSkin00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
  const char* skinName = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setSkin'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->setSkin(skinName);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setSkin'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getAttachment of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_getAttachment00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_getAttachment00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
  const char* slotName = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* attachmentName = ((const char*)  tolua_tostring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getAttachment'", NULL);
#endif
  {
   spAttachment* tolua_ret = (spAttachment*)  self->getAttachment(slotName,attachmentName);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"spAttachment");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getAttachment'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setAttachment of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setAttachment00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setAttachment00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
  const char* slotName = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* attachmentName = ((const char*)  tolua_tostring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setAttachment'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->setAttachment(slotName,attachmentName);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setAttachment'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getBlendFunc of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_getBlendFunc00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_getBlendFunc00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getBlendFunc'", NULL);
#endif
  {
   ccBlendFunc tolua_ret = (ccBlendFunc)  self->getBlendFunc();
   {
#ifdef __cplusplus
    void* tolua_obj = Mtolua_new((ccBlendFunc)(tolua_ret));
     tolua_pushusertype(tolua_S,tolua_obj,"ccBlendFunc");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
#else
    void* tolua_obj = tolua_copy(tolua_S,(void*)&tolua_ret,sizeof(ccBlendFunc));
     tolua_pushusertype(tolua_S,tolua_obj,"ccBlendFunc");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
#endif
   }
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getBlendFunc'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setBlendFunc of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setBlendFunc00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setBlendFunc00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !tolua_isusertype(tolua_S,2,"ccBlendFunc",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
  ccBlendFunc var = *((ccBlendFunc*)  tolua_tousertype(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setBlendFunc'", NULL);
#endif
  {
   self->setBlendFunc(var);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setBlendFunc'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setOpacityModifyRGB of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setOpacityModifyRGB00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setOpacityModifyRGB00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isboolean(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
  bool value = ((bool)  tolua_toboolean(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setOpacityModifyRGB'", NULL);
#endif
  {
   self->setOpacityModifyRGB(value);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setOpacityModifyRGB'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: isOpacityModifyRGB of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_isOpacityModifyRGB00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_isOpacityModifyRGB00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'isOpacityModifyRGB'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->isOpacityModifyRGB();
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'isOpacityModifyRGB'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getNodeForSlot of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_SkeletonRenderer_luabinding_SkeletonRenderer_getNodeForSlot00
static int tolua_SkeletonRenderer_luabinding_SkeletonRenderer_getNodeForSlot00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"SkeletonRenderer",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
  const char* slotName = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getNodeForSlot'", NULL);
#endif
  {
   CCNode* tolua_ret = (CCNode*)  self->getNodeForSlot(slotName);
    int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCNode");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getNodeForSlot'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* get function: __CCBlendProtocol__ of class  SkeletonRenderer */
#ifndef TOLUA_DISABLE_tolua_get_SkeletonRenderer___CCBlendProtocol__
static int tolua_get_SkeletonRenderer___CCBlendProtocol__(lua_State* tolua_S)
{
  spine::SkeletonRenderer* self = (spine::SkeletonRenderer*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable '__CCBlendProtocol__'",NULL);
#endif
#ifdef __cplusplus
   tolua_pushusertype(tolua_S,(void*)static_cast<CCBlendProtocol*>(self), "CCBlendProtocol");
#else
   tolua_pushusertype(tolua_S,(void*)((CCBlendProtocol*)self), "CCBlendProtocol");
#endif
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_SkeletonRenderer_luabinding_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"SkeletonRenderer","SkeletonRenderer","CCNode",NULL);
  tolua_beginmodule(tolua_S,"SkeletonRenderer");
   tolua_function(tolua_S,"createWithData",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_createWithData00);
   tolua_function(tolua_S,"createWithFile",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_createWithFile00);
   tolua_function(tolua_S,"createWithFile",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_createWithFile01);
   tolua_function(tolua_S,"updateWorldTransform",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_updateWorldTransform00);
   tolua_function(tolua_S,"setToSetupPose",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setToSetupPose00);
   tolua_function(tolua_S,"setBonesToSetupPose",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setBonesToSetupPose00);
   tolua_function(tolua_S,"setSlotsToSetupPose",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setSlotsToSetupPose00);
   tolua_function(tolua_S,"findBone",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_findBone00);
   tolua_function(tolua_S,"findSlot",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_findSlot00);
   tolua_function(tolua_S,"setSkin",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setSkin00);
   tolua_function(tolua_S,"getAttachment",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_getAttachment00);
   tolua_function(tolua_S,"setAttachment",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setAttachment00);
   tolua_function(tolua_S,"getBlendFunc",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_getBlendFunc00);
   tolua_function(tolua_S,"setBlendFunc",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setBlendFunc00);
   tolua_function(tolua_S,"setOpacityModifyRGB",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_setOpacityModifyRGB00);
   tolua_function(tolua_S,"isOpacityModifyRGB",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_isOpacityModifyRGB00);
   tolua_function(tolua_S,"getNodeForSlot",tolua_SkeletonRenderer_luabinding_SkeletonRenderer_getNodeForSlot00);
   tolua_variable(tolua_S,"__CCBlendProtocol__",tolua_get_SkeletonRenderer___CCBlendProtocol__,NULL);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_SkeletonRenderer_luabinding (lua_State* tolua_S) {
 return tolua_SkeletonRenderer_luabinding_open(tolua_S);
};
#endif

