--[[
	@YLLoading
	@Author: bingo
	@Date: 2015-07-27
	----------------------------
]]
local YLMask = import("app.ui.YLMask");
local YLLoading = class("YLLoading");

-- 超时秒数
-- 因为海外网络的复杂度，这里暂定10秒
YLLoading.SECOND_TIME_OUT = 10;

--[[
	@构造函数
	@params options[table] 参数列表
]]
function YLLoading:ctor(options)

end

--[[
	@显示loading
]]
function YLLoading:showLoading(flag)
	local curScene = display.getRunningScene();
	if curScene == nil then
		return;
	end
	if curScene ~= self._parent then
		if self._loadMask then
			self._loadMask:removeSelf(true);
			self._loadMask = nil;
		end
	end
	self._parent = curScene;

	flag = checkbool(flag);
	if flag and self._loadMask == nil then
		-- 创建遮罩
		local mask = YLMask.new({isDebug = 0, debugTips = {text = "Loading tips", color = YLColor.green}, alpha = 0});
		mask:addEventListener(mask.class.EVENT_ON_CLEAN_UP, function(event)
			self._loadMask = nil;
		end);
		self._parent:addChild(mask, gSceneMgr and gSceneMgr.class.LOADING_LEVEL or 5052);
		self._loadMask = mask;
	end
	if self._loadMask then
		-- self._loadMask:setVisible(flag);
		-- self:showAni(false);
		-- print("hide animation")
		-- self._loadMask:stopActionByTag(9006);
		-- self._loadMask:stopActionByTag(9008);
		-- self._loadMask:setColorLayerOpacity(0);

		-- if flag then
		-- 	self:handleTimeOut();
		-- 	self._loadMask:swallow(true);
		-- 	self._loadMask:performWithDelay(function()
		-- 		self:showAni(true);
		-- 		print("after 0.5s show animation")
		-- 		self._loadMask:setColorLayerOpacity(0);
		-- 	end, 0.5, 9006);
		-- else
		-- 	self._loadMask:swallow(false);
		-- end


		self._loadMask:setVisible(flag);
		-- self:showAni(false);
		-- print("hide animation")
		-- self._loadMask:stopActionByTag(9006);
		self._loadMask:stopActionByTag(9008);
		self._loadMask:setColorLayerOpacity(0);

		self._loadMask:swallow(flag);
		if flag then
			-- self:handleTimeOut();
			self._loadMask:performWithDelay(function()
				self:showAni(true);
				-- print("after 0.5s show animation")
				-- self._loadMask:setColorLayerOpacity(0);
			end, 0.5, 9006);
		else
			self._loadMask:stopActionByTag(9006);
			self:showAni(false);
		end
	end
	
end

function YLLoading:showAni(flag)
	flag = checkbool(flag);
	local node = self._loadMask;
	local nodeSize = node:getContentSize();

	if flag and node._loadSprite == nil and node._actSprite == nil then
		-- local sp = display.newSprite(tool.res("com_loading.png"));
		-- sp:align(display.CENTER, nodeSize.width/2, nodeSize.height/2);
		-- sp:addTo(node);
		-- sp:setScale(1.5);
		-- node._loadSprite = sp;

		-- local acRote = cc.RotateBy:create(0.5, 120);
		-- local acRep = cc.RepeatForever:create(acRote);
		-- sp:runAction(acRep);

		local spBg = display.newSprite(tool.res("com_loading_bar_bg.png"));
		spBg:align(display.CENTER, nodeSize.width/2, nodeSize.height/2);
		spBg:setScale(0.7);
		spBg:addTo(node);
		node._loadSprite = spBg;
		local actSprite = display.newSprite(tool.res("com_loading_bar_front.png"));
		actSprite:align(display.CENTER, nodeSize.width/2, nodeSize.height/2);
		actSprite:addTo(node);
		actSprite:setScale(0.7);
		node._actSprite = actSprite;
		local callfunc = cca.callFunc(function ()
			local rotation = actSprite:getRotation()
			if rotation > 360 then
				rotation = rotation - 360;
			end
			actSprite:setRotation(rotation + 30);
		end)
		local seq = cca.seq({cca.delay(0.1), callfunc});
		actSprite:runAction(cca.repeatForever(seq));
	end
	if node._loadSprite and node._actSprite then
		node._loadSprite:setVisible(flag);
		node._actSprite:setVisible(flag)
		-- print("setvisible::::::",flag)
	end
end

--[[
	@超时处理
]]
function YLLoading:handleTimeOut()
	self._loadMask:stopActionByTag(9008);
	self._loadMask:performWithDelay(function()
		self:showLoading(false);
 		if type(self._timeoutFunc) == "function" then
 			self._timeoutFunc()
 		end
	end, self.class.SECOND_TIME_OUT, 9008);
end

function YLLoading:onTimeout(callback)
	self._timeoutFunc = callback
end

--[[
	@获取单例
]]
function YLLoading:getInstance(...)
	if self.__instance == nil then
		self.__instance = self.new(...);
	end
	return self.__instance;
end

--return YLLoading;
gLoading = YLLoading:getInstance();