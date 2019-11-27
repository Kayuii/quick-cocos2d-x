--[[
	视图基类
	@Author: ccb
	@Date: 2017-11-01
]]
local ViewBase = class("ViewBase", function()
	local node = display.newNode();
	node:setNodeEventEnabled(true);
	cc(node):addComponent("components.behavior.EventProtocol"):exportMethods();
	return node;
end);

-- 类型
ViewBase.FULL_VIEW 		= 4; 	-- 全屏
ViewBase.LG_VIEW		= 3; 	-- 大
ViewBase.MID_VIEW		= 2; 	-- 中
ViewBase.SML_VIEW		= 1; 	-- 小
ViewBase.TINY_VIEW		= 0; 	-- 小
ViewBase.UNKOWN_VIEW 	= -1; 	-- 未知
ViewBase.VT_MIN			= ViewBase.SML_VIEW;
ViewBase.VT_MAX			= ViewBase.FULL_VIEW;

--[[ 构造 ]]
function ViewBase:ctor()

	-- 视图类型
	self._viewType = self.UNKOWN_VIEW;
	
	-- 注册视图id
	self._viewId = xg.const.VIEW_ID[self.__cname];
end

--[[ 判断是否是view对象 ]]
function ViewBase:isViewObject()
	return self._viewType ~= nil;
end

--[[ 注册视图类型 ]]
function ViewBase:registerViewType(viewType)
	self._viewType = viewType;
end

--[[ 获取视图类型 ]]
function ViewBase:getViewType()
	return self._viewType;
end

--[[ 获取视图Id ]]
function ViewBase:getViewId()
	return self._viewId;
end

--[[ 关闭视图 ]]
function ViewBase:closeView()
	local bInterrupt = self:onCloseView();
	if not bInterrupt then
		display.getRunningScene():closeView(self);
	end
end

--[[ 即将关闭视图 ]]
function ViewBase:onCloseView()
	-- 返回true表示取消关闭
	-- 返回false或nil表示继续关闭
	return false;
end

--[[ 退出父节点监听 ]]
function ViewBase:onExit()
	xg.event:dispatchEvent({name = "ExitView", view = self});
end

--[[ 进入父节点监听 ]]
function ViewBase:onEnter()
	-- 派发节点onEnter消息
	xg.event:dispatchEvent({name = "EnterView", view = self});
end

--[[ 进入新场景时的特效结束 ]]
function ViewBase:onEnterTransitionFinish()

end

--[[ 退出现有场景时的特效开始 ]]
function ViewBase:onExitTransitionStart()

end

--[[ 被完全清理并从内存删除时 ]]
function ViewBase:onCleanup()

end

return ViewBase;
