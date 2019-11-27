
#ifndef __SKELETONANIMATION_LUABINDING_H_
#define __SKELETONANIMATION_LUABINDING_H_

extern "C" {
#include "lua.h"
#include "tolua++.h"
#include "tolua_fix.h"
}

TOLUA_API int luaopen_SkeletonAnimation_luabinding(lua_State* tolua_S);

#endif // __SKELETONANIMATION_LUABINDING_H_
