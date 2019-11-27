--[[
	XgMask
	@Author: ccb
	@Date: 2017-11-01
	----------------------------

	参数说明:
	_clipRect 			裁剪区域信息，如果为nil，则为普通遮罩。
	_clipStencil		裁剪模板, 现在暂定为贴图。
	_clipTouchEnable 	决定裁剪区域是否可点击。
	_clipShowStencil 	模板原本倒置的，看不到的，也可以让其在添加可见。

	示例:
	local options = {
		alpha = 200,
		debugTips = "mask test",
		clipRect = cc.rect(200, 200, 200, 200),
	};
	local mask = xg.ui:newMask(options);
	mask:addTo(self, 900);
]]

local XgMask = class("XgMask", function(options)
	local node = display.newNode();
	node:setNodeEventEnabled(true);
	cc(node):addComponent("components.behavior.EventProtocol"):exportMethods();
	return node;
end);

XgMask.DEF_DEBUG_MOD = 0;
XgMask.EVENT_TOUCH = "XG_MASK_EVENT_TOUCH"; -- 触摸事件
XgMask.EVENT_CLICKED = "XG_MASK_EVENT_CLICKED"; -- 点击事件
XgMask.EVENT_ON_CLEAN_UP = "XG_MASK_EVENT_ON_CLEAN_UP"; -- 从父节点清除事件
XgMask.EVENT_CLIP_AREA_TOUCH = "XG_MASK_EVENT_CLIP_AREA_TOUCH"; -- 裁剪区域点击事件

--[[ 构造函数 ]]
function XgMask:ctor(options)
	self._options 			= options or {};
	self._alpha 			= self._options.alpha or 100;
	self._color 			= self._options.color or xg.color.black;
	self._debugTips 		= self._options.debugTips or nil;
	self._isDebug 			= self._options.isDebug or self.DEF_DEBUG_MOD;

	-- 裁剪相关参数
	self._clipRect 			= self._options.clipRect or nil;			-- 裁剪区域位置大小信息
	self._clipStencil 		= self._options.clipStencil or nil;			-- 裁剪区域填补使用的贴图
	self._clipCapinsets 	= self._options.clipCapinsets;				-- 裁剪区域贴图用的九宫格参数
	self._clipTouchEnable 	= self._options.clipTouchEnable or nil;		-- 裁剪区域是否可点击，默认为可点击
	self._clipShowStencil	= self._options.clipShowStencil or nil;		-- 模板原本倒置的，看不到的，也可以让其在添加可见
	self._rectSwallow		= self._options.rectSwallow;				-- 点击空白区域是否穿透消息
end

--[[ 进入父节点 ]]
function XgMask:onEnter()
	self:setContentSize(cc.size(display.width, display.height));
	self:setTouchEnabled(true);
	self:swallow(true);
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouchHandler));

	self:addClipArea();
	self:addDebugTips();

	self:setClipTouchEnable(self._clipTouchEnable);
end

--[[ 添加裁剪区域 ]]
function XgMask:addClipArea()
	if self._clipRect == nil then
		local layer = display.newColorLayer(xg.color.c3b2C4b(self._color, self._alpha));
		layer:setTouchEnabled(true);
		layer:setTouchSwallowEnabled(false);
		layer:addTo(self);
		self._colorLayer = layer;
	else
		-- 在层上添加内容
		local x, y = self._clipRect.x, self._clipRect.y;
		local w, h = self._clipRect.width, self._clipRect.height;

		if checkbool(self._clipShowStencil) and self._clipStencil then
			local tagSize = cc.size(w, h);
			local sp = display.newScale9Sprite(self._clipStencil, 0, 0, tagSize, self._clipCapinsets);
			sp:align(display.CENTER, x, y);
			self:addChild(sp);
		end
		
		-- 底板
		local layer = display.newColorLayer(xg.color.c3b2C4b(self._color, self._alpha));
		layer:setTouchEnabled(true);
		layer:setTouchSwallowEnabled(false);
		self._colorLayer = layer;
		
		-- 模板
		local stencil = display.newNode();

		-- 模板内容
		if self._clipStencil then
			local sp = display.newScale9Sprite(self._clipStencil);
			sp:setContentSize(cc.size(w, h));
			sp:align(display.CENTER, x, y);
			stencil:addChild(sp);
		else
			local r = math.max(w, h);
			local dn = cc.DrawNode:create();
			dn:drawDot(cc.p(x, y), r/2, cc.c4f(1, 0, 0, 1));  
			stencil:addChild(dn);
		end

		local clipNode = cc.ClippingNode:create();
		clipNode:setStencil(stencil);
		clipNode:setInverted(true);
		clipNode:addChild(layer);
		clipNode:addTo(self);

		if not self._clipStencil then
			clipNode:setAlphaThreshold(0.0);
		end
	end
end

--[[
	是否允许Node吞噬触摸，默认为true。
	如果设置为false，则Node响应触摸事件后，仍然会将事件继续传递给父对象。
]]
function XgMask:swallow(flag)
	if type(flag) == "boolean" then
		self:setTouchSwallowEnabled(flag);
	end
end

--[[ 设置裁剪区域是否可点击 ]]
function XgMask:setClipTouchEnable(flag)
	if flag == nil then
		flag = true; --默认为可触摸
	end

	if type(flag) == "boolean" then
		self._clipTouchEnable = flag;
	end
end

--[[ 设置裁剪区域是否可穿透 ]] 
function XgMask:setClipTouchSwallow(flag)
	if type(flag) == "boolean" and self._colorLayer then
		self._colorLayer:setTouchSwallowEnabled(flag);
	end
end

--[[ 触摸监听 ]]
function XgMask:onTouchHandler(event)
	if event.name == "began" then
		if self:isOnClipArea(cc.p(event.x, event.y)) then
			self._beganPos = cc.p(event.x, event.y);
		end
		self._touchEvent = event;
		self:dispatchEvent({name = self.EVENT_TOUCH, event = event});
		return true;
	elseif event.name == "moved" then
		if self._touchEvent and getDistance(event, self._touchEvent) > 20 then
			self._touchEvent = nil;
		end
		self:dispatchEvent({name = self.EVENT_TOUCH, event = event});
		return true;
	elseif event.name == "ended" then
		if self._beganPos and self:isOnClipArea(cc.p(event.x, event.y)) then
			self._beganPos = nil;
			-- 点击在裁剪区域内
			self:dispatchEvent({name = self.EVENT_CLIP_AREA_TOUCH, event = event});
		end

		self:dispatchEvent({name = self.EVENT_TOUCH, event = event});

		if self._touchEvent then
			self._touchEvent = nil;
			self:dispatchEvent({name = self.EVENT_CLICKED, event = event});
		end
	end
end

--[[
	判断当前点击的点是否在裁剪区域内
	@params pt[table] 点
	@return flag[boolean] 是否在裁剪区域内标志
]]
function XgMask:isOnClipArea(pt)
	if self._clipTouchEnable == false or self._clipRect == nil then
		return false;
	end

	-- self._clipRect 是以Pos为中心点的矩形
	-- 而用于判断的是Pos居于左下角的矩形
	local tagPos = cc.p(self._clipRect.x - self._clipRect.width * 0.5, self._clipRect.y - self._clipRect.height * 0.5);
	local tagRec = cc.rect(tagPos.x, tagPos.y, self._clipRect.width, self._clipRect.height);
	local flag = cc.rectContainsPoint(tagRec, pt);

	self:handleOnClickClipArea(not flag or self._rectSwallow);

	return flag;
end

--[[ 点击到裁剪区域的处理 ]]
function XgMask:handleOnClickClipArea(flag)
	-- 裁剪区域内，可穿透，裁剪区域外，不可穿透
	self:swallow(checkbool(flag));
end

--[[ 设置颜色层透明值 ]]
function XgMask:setColorLayerOpacity(opacity)
	if self._colorLayer then
		self._alpha = opacity or self._alpha;
		self._colorLayer:setOpacity(self._alpha);
	end
end

--[[ 添加提示(测试时候用) ]]
function XgMask:addDebugTips()
	if self._isDebug == 1 then
		local tip = self._debugTips;
		if type(tip) ~= "table" then
			if tostring(tip) then
				tip = {text = tip, color = xg.color.white};
				self._debugTips = tip;
			end
		end

		local label = xg.ui:newLabel(tip);
		label:align(display.LEFT_TOP, 10, display.height - 10);
		self:addChild(label);
		self._debugTipLabel = label;
	end
end

--[[ 清除监听 ]]
function XgMask:onCleanup()
	self:dispatchEvent({name = self.EVENT_ON_CLEAN_UP, instance = self});
end

return XgMask;
