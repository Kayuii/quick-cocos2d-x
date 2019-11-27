--[[
	公共窗体
	@Author: bingo
	@Date: 2015-09-25
	------------------
]]
local base = xg.ui:getClass("panelBase");
local XgComFrame = class("XgComFrame", base);

-- 窗口风格
XgComFrame.FRAME_STYLE = {
	FrameLg = "FrameLg",
	FrameLgEx = "FrameLgEx",
	FrameMid = "FrameMid",
	FrameSml = "FrameSml",
	FrameTiny = "FrameTiny",
};

XgComFrame.AC_TAG_APPEAR_EFT = 0x1008699;


--[[ 添加或修改参数 ]]
function XgComFrame:setExtParams()
	XgComFrame.super.setExtParams(self);

	self._titleName = self._options.title or self._titleName or "";
	self._style = self._options.style or self._style or self.FRAME_STYLE.FrameLgEx;
	self._appearEft = self._options.appearEft or self._appearEft;
	self._appearEft = (self._appearEft == nil) and true or self._appearEft;

	self:initFrameCfg_();
	self._size = self._frameCls and self._frameCls.DEF_SIZE or self._size;
end

--[[ 初始化配置 ]]
function XgComFrame:initFrameCfg_()
	if not self._style then return end

	if self._frameCfg == nil then
		self._frameCfg = {};
		setmetatable(self._frameCfg, {
			__index = function(t, k)
				local ref = self.FRAME_STYLE[k];
				return rawget(t, k) or (ref and import(string.format("%s.layout.%s", xg.ui.PACKAGE_NAME, ref))) or rawget(t, k);
			end
		});
	end

	self._frameCls = self._frameCfg and self._frameCfg[self._style];
end

--[[ 创建基础内容 ]]
function XgComFrame:createBase()
	XgComFrame.super.createBase(self);

	self:createFrameByStyle_();
	self:addDebugColorLayer_();
end

--[[ 根据风格创建外框 ]]
function XgComFrame:createFrameByStyle_()
	local cls = self._frameCls;
	if not cls then return end

	local layout = cls.new();
	layout:align(display.LEFT_TOP, 0, self._size.height);
	layout:addTo(self);

	self._frameLayout = layout;
	self._lbTitle = layout:findViewByKey("lb_title");
	self._btnClose = layout:findViewByKey("btn_cls");

	if self._titleName and self._lbTitle then
		self._lbTitle:setString(self._titleName);
	end
	if self._btnClose then
		self._btnClose:onClicked(handler(self, self.closeView));
	end

	-- 注册视图类型
	self:registerViewType(cls.VIEW_TYPE);
end

--[[ 设置标题 ]]
function XgComFrame:setTitleName(name)
	if not name or name == self._titleName then
		return;
	end

	self._titleName = name;
	if self._lbTitle then
		self._lbTitle:setString(name);
	end
end

--[[ 显示出现特效 ]]
function XgComFrame:showAppear()
	if not checkbool(self._appearEft) then return end

	self:stopActionByTag(self.AC_TAG_APPEAR_EFT);
	local ac = cca.seqEx({
		cca.callFunc(function()
			if self._mask then
				self._mask:setScale(1.1);
			end
		end),
		cca.scaleTo(0.025, 0.98),
		cca.scaleTo(0.025, 1.03),
		cca.scaleTo(0.025, 1),
		cca.callFunc(function()
			if self._mask then
				self._mask:setScale(1);
			end
			xg.event:dispatchEvent({name = "EnterView", view = self});
		end),
	});
	ac:setTag(self.AC_TAG_APPEAR_EFT);
	self:runAction(ac);
end

--[[ 进入父节点 ]]
function XgComFrame:onEnter()
	self:showAppear();

	if not self:getActionByTag(self.AC_TAG_APPEAR_EFT) then
		xg.event:dispatchEvent({name = "EnterView", view = self});
	end
end

return XgComFrame;
