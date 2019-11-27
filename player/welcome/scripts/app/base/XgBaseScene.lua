--[[
	场景基类
	@Author: ccb
	@Date: 2017-06-22
]]
local TAG = "#####XgSceneBase";
local SceneBase = class("SceneBase", function()
	return display.newScene(); 
end);

-- 场景ID
SceneBase.SCENE_ID = {
	MainScene = 0,
	HomeScene = 1,
	TexasScene = 2,
};

--[[ 构造 ]]
function SceneBase:ctor(ops)

	self._ops = ops;
	
	-- 保存view对象
	self._viewsStack = xg.stack.new();

	-- 转换场景名
	if self.name and self.name == "<unknown-scene>" then
		self.name = nil;
		self.name = self:getSceneName();
	end
end

--[[ 进入监听 ]]
function SceneBase:onEnter()

	local function menuBackHandle()
		self:setKeypadEnabled(true);
		self.canRepAndroidBackKey = true;
		self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
			if event.key == "back" then
				if self.canRepAndroidBackKey then
					ToastLayerNew.show({text = _T("com_tip_quit_game"), type = 2, okCallfun = function()
						app:exit();
					end});
				end
			end
		end);
	end

	if device.platform == "android" or device.platform == "windows" then
		self:performWithDelay(menuBackHandle, 0.05);
	end

	local gameTmpCfgMgr = xg.user:getMgr("gameTmpCfgMgr");
	if gameTmpCfgMgr and type(gameTmpCfgMgr.handleReenterOpe) == "function" then
		gameTmpCfgMgr:handleReenterOpe();
	end

	self:showDebugDot();
	self:addDebugABBtn();
end

--[[ 退出监听 ]]
function SceneBase:onExit()
	-- local textureCache = CCTextureCache:sharedTextureCache();
	-- local spframeCache = CCSpriteFrameCache:sharedSpriteFrameCache();
	-- spframeCache:removeUnusedSpriteFrames();
	-- textureCache:removeUnusedTextures();
end

--[[ 获取一个打开的视图 ]]
function SceneBase:getView(viewPath)
	local viewClass = require(viewPath);
	assert(viewClass, string.format("%s %s can not find view class[%s].", TAG, "getView", tostring(viewPath)));

	self:checkViewsStack();
	
	local stack = self:getViewsStack();
	local className = viewClass.__cname;
	for i = 1, stack:size() do
		local viewObj = stack:at(i);
		if viewObj and viewObj.__cname == className then
			return viewObj;
		end
	end
	
	return nil;
end

--[[ 打开一个视图 ]]
function SceneBase:openView(viewPath, parentNode, ...)
	local args = {...};
	local viewClass = require(viewPath);
	assert(viewClass, string.format("%s %scan not find view class[%s].", TAG, "openView", tostring(viewPath)));

	self:checkViewsStack();

	-- 一般的策略是不允许打开相同的2个视图
	-- 如果已存在打开的视图，此处处理有2:1 直接返回当前视图 2关闭当前视图，重新创建。
	-- 这里暂时选择返回当前视图
	local view = self:getView(viewPath);
	if view then return view end
	
	local stack = self:getViewsStack();
	local viewObj = viewClass.new(unpack(args, 1, table.maxn(args)));
	viewObj:align(display.CENTER, display.cx, display.cy);
	viewObj:addTo(parentNode or self);
	stack:push(viewObj);

	return viewObj;
end

--[[ 关闭一个视图 ]]
function SceneBase:closeView(viewObj)
	self:checkViewsStack();
	local stack = self:getViewsStack();
	if stack:empty() then return end
	
	if stack:top() == viewObj then
		stack:pop();
	else
		if stack:removeItem(viewObj) then
			print(string.format("%s %s the view is not top view[%s].", TAG, "closeView", viewObj.__cname));
		else
			print(string.format("%s %s the view is not on this scene views stack[%s].", TAG, "closeView", viewObj.__cname));
		end
	end
	
	viewObj:removeFromParent();
end

--[[
	根据视图Path关闭一个视图
	推荐用closeView， 这个方法在非必要时尽量不用
]]
function SceneBase:closeViewByViewPath(path)
	if not path then return end

	local view = self:getView(path);
	if view then
		self:closeView(view);
	end
end

--[[ 关闭所有视图 ]]
function SceneBase:closeAllView()
	local stack = self:getViewsStack();
	while not stack:empty() do
		local viewObj = stack:top();
		self:closeView(viewObj);
	end
end

--[[
	检查视图栈
	有种情况是视图已经被释放，但是没有对栈进行pop处理
]]
function SceneBase:checkViewsStack()
	local stack = self:getViewsStack();
	if stack:empty() then return end

	local obj;
	local num = 0;
	local size = stack:size();
	for i = size, 1, -1 do
		obj = stack:at(i);
		if obj and obj.__cname == nil then
			num = num + 1;
			stack:removeItem(obj);
		end
	end
	if num ~= 0 then
		printf("%s exist uncorrect close views, view num is %s.", TAG, num);
	end
end

--[[ 获取视图栈 ]]
function SceneBase:getViewsStack()
	assert(self._viewsStack, string.format("%s confirm this scene extends is correct.", TAG));
	return self._viewsStack;
end

--[[ 打印视图栈 ]]
function SceneBase:dumpViewsStack()
	local obj;
	local stack = self:getViewsStack();
	for i = 1, stack:size() do
		obj = stack:at(i);
		printf("%s views stack:%s", TAG, obj.__cname);
	end
end

--[[  显示测试用爱豆 ]]
function SceneBase:showDebugDot()
	local bOpen = G_FUNC_SWITCH and G_FUNC_SWITCH.DEBUG_DOT_ALLGSCENE;
	if bOpen == nil or type(bOpen) ~= "boolean" or not bOpen then
		return;
	end

	local dot = self._debugDot;
	if not dot then
		local DebugDot = import("app.xgame.view.other.DebugDot");
		if DebugDot then
			dot = DebugDot.new();
			dot:addTo(self, 999);
			self._debugDot = dot;
		end
	end
end

--[[ 测试用 ]]
function SceneBase:addDebugABBtn()
	local sName = self:getSceneName();
	if sName == "TexasScene" then return end

	local arrOffY = {
		["MainScene"] = 0,
		["HomeScene"] = 150,
	};
	local offy = arrOffY[sName] or 0;

	local abCall = function()
		if not self._aClicked or not self._bClicked then return end
		if self._aClicked < 5 or self._bClicked < 5 then return end

		G_FUNC_SWITCH = G_FUNC_SWITCH or {};
		G_FUNC_SWITCH.DEBUG_DOT_ALLGSCENE = true;
		
		self:showDebugDot();
	end

	local tmpSize = cc.size(80, 80);
	local tmpNode = display.newNode();
	tmpNode:setContentSize(tmpSize);
	tmpNode:align(display.LEFT_BOTTOM, 0, 0 + offy);
	tmpNode:swallowTouch(false);
	tmpNode:onClicked(function()
		self._aClicked = self._aClicked or 0;
		self._aClicked = self._aClicked + 1;
		abCall();
	end);
	tmpNode:addTo(self, 10);

	local tmpNode2 = display.newNode();
	tmpNode2:setContentSize(tmpSize);
	tmpNode2:align(display.RIGHT_BOTTOM, display.width, 0 + offy);
	tmpNode2:swallowTouch(false);
	tmpNode2:onClicked(function()
		self._bClicked = self._bClicked or 0;
		self._bClicked = self._bClicked + 1;
		abCall();
	end);
	tmpNode2:addTo(self, 10);
end

--[[ 获取场景名 ]]
function SceneBase:getSceneName()
	self.name = self.name or self.__cname;
	return self.name;
end

--[[ 获取场景Id ]]
function SceneBase:getSceneId()
	local name = self:getSceneName();
	return self.SCENE_ID[name];
end

return SceneBase;
