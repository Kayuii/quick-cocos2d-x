--[[
	面板基类
	Author: ccb
	Date: 2017-11-01
]]
local XgPanelBase = class("XgPanelBase", xg.baseView);

XgPanelBase.DEF_DEBUG_MOD = 0;
XgPanelBase.DEF_MASK_ALPHA = 100;
XgPanelBase.EVENT_ON_CLOSE = "XG_PANEL_BASE_EVENT_ON_CLOSE";

--[[ 构造方法 ]]
function XgPanelBase:ctor(options)
	XgPanelBase.super.ctor(self, options);

	self._options 	= options or {};
	self._size		= self._options.size or cc.size(display.width, display.height);
	self._addMask	= self._options.addMask == nil and true or self._options.addMask;
	self._maskAlpha = self._options.maskAlpha or self.DEF_MASK_ALPHA;
	self._maskClkCb = self._options.maskClkCb or nil;
	self._isDebug	= self._options.isDebug or self.DEF_DEBUG_MOD;

	-- 注册视图类型
	self:registerViewType(self.FULL_VIEW);

	self:setExtParams();
	self:init();
end

--[[ 添加或修改参数(规范给子类) ]]
function XgPanelBase:setExtParams()

end

--[[ 初始化 ]]
function XgPanelBase:init()
	self:setContentSize(self._size);

	-- 添加屏蔽
	self:addMask_();

	-- 添加颜色层
	self:addDebugColorLayer_();

	-- 设置触摸监听
	local touchNode = display.newNode();
	touchNode:setContentSize(self._size);
	touchNode:align(display.CENTER, self._size.width/2, self._size.height/2);
	touchNode:setTouchEnabled(true);
	touchNode:setTouchSwallowEnabled(true);
	touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch));
	touchNode:addTo(self);
	self._touchNode = touchNode;
	
	-- 创建基础内容
	self:createBase();
end

--[[ 创建基础内容(规范给子类) ]]
function XgPanelBase:createBase()
	
end

--[[ 是否允许Node吞噬触摸，默认为true ]]
function XgPanelBase:swallowTouch(flag)
	if type(flag) == "boolean" then
		if self._touchNode then
			self._touchNode:setTouchSwallowEnabled(flag);
		end
	end
end

--[[ 触摸监听 ]]
function XgPanelBase:onTouch(event)
	-- print("触摸监听");
end

--[[ 添加屏蔽 ]]
function XgPanelBase:addMask_(options)
	if self._mask then return end
	if not checkbool(self._addMask) then return end

	options = options or {};
	options.alpha = options.alpha or self._maskAlpha or 100;
	options.debugTips = {text = "XgPanelBase -mask", color = xg.color.green};
	local mask = xg.ui:newMask(options);
	mask:addEventListener(mask.EVENT_CLICKED, function(event)
		if self._maskClkCb and type(self._maskClkCb) == "function" then
			self._maskClkCb();
		else
			self:closeView();
		end
	end);
	mask:align(display.CENTER, self._size.width/2, self._size.height/2);
	mask:addTo(self,  -1);
	self._mask = mask;
end

--[[ 移除屏蔽 ]]
function XgPanelBase:removeMask_()
	if not self._mask then return end

	self._mask:runAction(cc.RemoveSelf:create());
	self._mask = nil;
end

--[[ 添加颜色层(主要测试时用) ]]
function XgPanelBase:addDebugColorLayer_()
	if not self._size then return end

	if self._isDebug and self._isDebug == 1 then
		if nil == self._colorLayer then
			local color = xg.color.c3b2C4b(xg.color.red, 100);
			local layer = display.newColorLayer(color, self._size.width, self._size.height);
			layer:addTo(self);
			self._colorLayer = layer;
		else
			self._colorLayer:setContentSize(self._size);
		end
	end
end

--[[ 关闭视图 ]]
function XgPanelBase:closeView()
	self:dispatchEvent({name = self.EVENT_ON_CLOSE});
	XgPanelBase.super.closeView(self);
end

--[[ 清除监听 ]]
function XgPanelBase:onCleanup()
	XgPanelBase.super.onCleanup(self);
	self:removeMask_();
end

return XgPanelBase;
