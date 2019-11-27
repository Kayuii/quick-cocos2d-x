--[[
	整理Button
	@Author: ccb 
	@Date: 2017-09-01
	---------------------

	继承关系:
		CCNode:
			UIButton:(framework.cc.ui.UIButton)
				XgButton:

	该类直接继承于UIButton，UIButton使用了状态机来驱动动作事件进而改变状态，来实现按钮状态的切换。
	主要整理有：1，创建按钮的各状态图片的检测。
				2，可添加文本，文本可自定义，色彩，描边，阴影等。
				3，禁连点，默认可连点，如果不可连点，禁连点系数为0.5s。
				4，点击放大效果
				5，后续可能扩展的tips显示
				6, 一些接口的整理，会简洁点，如果觉得可能冲突，需确定。

	示例:
	local btn = xg.ui:newButton({
		images = {
			normal = "test_nor.png",
			pressed = "test_pre.png",
			disabled = "test_dis.png",
		},
		text = {
			text = "Test",
			font = xg.font.defName(),
			size = xg.font.defSize(),
			color = xg.color.green,
		},
	});
	btn:align(display.TOP_CENTER, 50, 50);
	btn:onPressed(handler(self, self.onPressedHandler));
	btn:onRelease(handler(self, self.onReleaseHandler));
	btn:onClicked(handler(self, self.onClickedHandler));
	btn:onStateChanged(handler(self, self.onStateChangedHandler));
	btn:addTo(self);

	创建入口: xg.ui:newButton(options) 
	参数说明:{
		image = {...},  -- 是各个状态的图片, 后续可能需要自己实现灰态图
		text = {...},   -- text是与文本相关的参数列表，参数的设定可以参考 XgLabel
	}
	注册事件:
	onPressed onRelease onClicked onStateChanged 分别为按压，释放/抬起，点击，状态变化事件的监听。
	设置文本/修改文本内容:
	btn:setLabelString("New Test"); -- 会将所有状态的文本都设置为该文本
	btn:setLabelString(btn.PRESSED, "New Test"); -- 将指定状态的文本修改为该文本
	btn:setLabel({
		text = "New Test",
		color = xg.color.red,
		size = xg.font.defSize(),
	}); -- 将指定文本移除，根据新参数列表重新创建文本。
	btn:setLabel({
		text = {
			text = "New Test",
			color = xg.color.red,
			size = xg.font.defSize(),
		},
		state = btn.PRESSED, -- 如果不传状态值，则取默认状态值
	}); -- 将指定文本移除，根据新参数列表重新创建文本。
	=================================================================================================
	---------------------------------------------WARNING---------------------------------------------
	尽量使用 btn:align(display.TOP_CENTER, x, y) 进行锚点注册和定位。
	使用 btn:setAnchorPoint() 和 btn:setPosition() 可能会造成文本的定位问题，如果使用该方法，
	请在addTo父节点前设置。
	=================================================================================================
]]
local UIButton = import("framework.cc.ui.UIButton");
local XgButton = class("XgButton", UIButton);

XgButton.NORMAL = "normal";
XgButton.PRESSED = "pressed";
XgButton.DISABLED = "disabled";

XgButton.DEF_LIMIT_TIME = 0.5;
XgButton.DEF_ZOOM_RATE = 1.1;
XgButton.DEF_TIME_ACT_TAG = 0x100861;
XgButton.DEF_IMAGE = "texas_btn_xiaotanchuan_nor.png";

--[[
	构造函数
	父类使用状态机来控制按钮的状态切换
	有 normal pressed disabled 3种状态
	有 press, release, disable, enable 4种动作事件
]]
function XgButton:ctor(options)
	local states =  {
		{name = "press",	from = "normal",	to = "pressed"},
		{name = "release",	from = "pressed",	to = "normal"},
		{name = "disable",	from = {"normal", "pressed"},	to = "disabled"},
		{name = "enable",	from = {"disabled"},	to = "normal"},
	};
	local initState = self.NORMAL;
	XgButton.super.ctor(self, states, initState, options);

	self._options 				= options or {};
	self._options.text 			= self._options.text or nil;
	self._options.images 		= self._options.images or self.DEF_IMAGE;
	self._options.zoom 			= self._options.zoom or nil; 				-- 如果zoom有值(放大比例)，则表示点击会进行缩放
	self._options.limitSecond 	= self._options.limitSecond or nil; 		-- 如果limitSecond有值(禁连点秒数/连点标志)，则表示该按钮不允许连点
	self._options.sound_key 	= self._options.soundKey or "short_clk"; 	-- none/nil表示无音效

	self:createImages();
	self:createLable(self._options);
	self:resetSize();

	-- 设置节点监听
	self:setNodeEventEnabled(true);

	-- 注册监听，实现诸如放大，tips等功能。
	self:onPressed(function (event)
		self:showZoomEffect(event);
	end);
	self:onRelease(function (event)
		self:showZoomEffect(event);
	end);
end

--[[ 创建按钮图片 ]]
function XgButton:createImages()
	self:getImageInfo();
	self:setButtonImage(self.NORMAL, self._options.images[self.NORMAL], true);
	self:setButtonImage(self.PRESSED, self._options.images[self.PRESSED], true);
	self:setButtonImage(self.DISABLED, self._options.images[self.DISABLED], true);
end

--[[ 创建文本 ]]
function XgButton:createLable(options, state)
	options = options or {};
	state = state or self.initialState_;
	self:checkError(state);

	if options.text == nil then
		return;
	end

	if type(options.text) ~= "table" then
		options.text = {text = options.text};
		options.text.font = options.font or nil;
		options.text.size = options.size or nil;
		options.text.color = options.color or nil;
	else
		options.text = options.text or {};
	end

	local label = xg.ui:newLabel(options.text);
	self:setButtonLabel(state, label);

	-- 设置文本在按钮上的偏移
	if options.text.offset then
		self:setButtonLabelOffset(options.text.offset.x, options.text.offset.y);
	end

	-- 设置文本在按钮上的停靠方式
	if options.text.align then
		self:setButtonLabelAlignment(options.text.align);
	end
end

--[[ 获取各状态图片信息 ]]
function XgButton:getImageInfo()
	local function getFile(file)
		if not file or file == "" then
			file = self._options.images[self.NORMAL];
			file = file or self._options.images[self.PRESSED];
			file = file or self._options.images[self.DISABLED];
			file = file or self.DEF_IMAGE;
		end
		return file;
	end

	if type(self._options.images) ~= "table" then
		local file = getFile(self._options.images);
		self._options.images = {};
		self._options.images[self.NORMAL] = file;
	else
		local tagFile = getFile(self._options.images[self.NORMAL]);
		if tagFile then
			self._options.images[self.NORMAL] = tagFile;
		end
		tagFile = getFile(self._options.images[self.PRESSED]);
		if tagFile then
			self._options.images[self.PRESSED] = tagFile;
		end
		tagFile = getFile(self._options.images[self.DISABLED]);
		if tagFile then
			self._options.images[self.DISABLED] = tagFile;
		end
	end
end

--[[ 注册按压监听 ]]
function XgButton:onPressed(callback)
	return XgButton.super.onButtonPressed(self, callback);
end

--[[ 注册抬起监听 ]]
function XgButton:onRelease(callback)
	return XgButton.super.onButtonRelease(self, callback);
end

--[[ 注册点击监听 ]]
function XgButton:onClicked(callback)
	return XgButton.super.onButtonClicked(self, callback);
end

--[[ 注册状态改变监听 ]]
function XgButton:onStateChanged(callback)
	return XgButton.super.onButtonStateChanged(self, callback);
end

--[[ 触摸监听，状态机的状态切换 ]]
function XgButton:onTouch_(event)
	local name, x, y = event.name, event.x, event.y
	if name == "began" then
		self.touchBeganX, self.touchBeganY = x, y;
		if not self:checkTouchInSprite_(x, y) then return false end

		-- press动作事件，状态: normal -> pressed
		self.fsm_:doEvent("press");
		self:dispatchEvent({name = self.PRESSED_EVENT, x = x, y = y, touchInTarget = true, target = self});
		return true;
	end

	local touchInTarget = self:checkTouchInSprite_(self.touchBeganX, self.touchBeganY) and self:checkTouchInSprite_(x, y);
	if name == "moved" then
		-- 移动的时候，根据判断是否触摸到区域，再通过执行 press 和 release 动作来切换 pressed 和 normal 状态。
		if touchInTarget and self.fsm_:canDoEvent("press") then
			self.fsm_:doEvent("press");
			self:dispatchEvent({name = self.PRESSED_EVENT, x = x, y = y, touchInTarget = true,target = self});
		elseif not touchInTarget and self.fsm_:canDoEvent("release") then
			self.fsm_:doEvent("release");
			self:dispatchEvent({name = self.RELEASE_EVENT, x = x, y = y, touchInTarget = false,target = self});
		end
	else
		if self.fsm_:canDoEvent("release") then
			self.fsm_:doEvent("release");
			self:dispatchEvent({name = self.RELEASE_EVENT, x = x, y = y, touchInTarget = touchInTarget,target = self});
		end
		if name == "ended" and touchInTarget then
			self:setLimitSecond(event);
			self:dispatchEvent({name = self.CLICKED_EVENT, x = x, y = y, touchInTarget = true,target = self});
			local sKey = self._options.sound_key;
			if sKey and sKey ~= "none" and xg and xg.audio then
				xg.audio:playSound(sKey);
			end
		end
	end
end

--[[ 显示缩放效果 ]]
function XgButton:showZoomEffect(event)
	self._options = self._options or {};
	if self._options.zoom == nil then
		return;
	end

	-- 如果为boolean，且为true，则取默认
	if type(self._options.zoom) == "boolean" and self._options.zoom == true then
		self._options.zoom = self.DEF_ZOOM_RATE;
	end

	if event.name == self.PRESSED_EVENT then
		self:setScale(tonumber(self._options.zoom));
	end

	if event.name == self.RELEASE_EVENT then
		self:setScale(1);
	end
end

--[[ 设置是否可连点 ]]
function XgButton:setLimitSecond(event)
	self._options = self._options or {};
	if self._options.limitSecond == nil then
		return;
	end

	-- 如果为boolean，且为true，则取默认
	if type(self._options.limitSecond) == "boolean" and self._options.limitSecond == true then
		self._options.limitSecond = self.DEF_LIMIT_TIME;
	end

	self:setIsEnabled(false);
	self:performWithDelay(function()
		self:setIsEnabled(true);
	end, tonumber(self._options.limitSecond), self.DEF_TIME_ACT_TAG);
end

--[[ 停止连点 ]]
function XgButton:forceStopLimit()
	self:stopActionByTag(self.DEF_TIME_ACT_TAG);
end

--[[ 根据状态设置文本 ]]
function XgButton:setLabel(options)
	self:createLable(options, options.state);

	if options and options.state == self.initialState_ then
		self:resetSize();
	end
end

--[[ 根据状态获取文本 ]]
function XgButton:getLabel(state)
	return XgButton.super.getButtonLabel(self, state);
end

--[[
    根据状态设置文本内容
    @params state[string] 状态值
            text[string] 文本内容 如果text是nil，则把state当做文本内容
]]
function XgButton:setLabelString(state, text)
	XgButton.super.setButtonLabelString(self, state, text);
end

--[[ 根据状态获取文本内容 ]]
function XgButton:getLabelString(state)
	return self:getLabel(state):getString();
end

--[[ 设置是否可用 ]]
function XgButton:setIsEnabled(bool)
	self:forceStopLimit();
	XgButton.super.setButtonEnabled(self, bool);
end

--[[ 获取是否可用标志 ]]
function XgButton:getIsEnabled()
	return XgButton.super.isButtonEnabled(self);
end

--[[ 设置是否选择 ]]
function XgButton:setIsSelected(selected)
	self._isSelect = checkbool(selected); 
	if self._isSelect == true then
		self:setButtonImage(self.NORMAL, self._options.images[self.PRESSED], true);
	else
		self:setButtonImage(self.NORMAL, self._options.images[self.NORMAL], true);
	end
end

--[[ 获取是否选择标志 ]]
function XgButton:getIsSelected()
	return checkbool(self._isSelect);
end

--[[ 重设大小，主要为初始化，文本，文本内容改变时进行重设 ]]
function XgButton:resetSize()
	local lblWidth = 0;
	local btnWidth = 0;
	local label = self:getLabel();
	local btnSprite = self.sprite_[1];

	if label then
		lblWidth = label:getContentSize().width;
	end
	if btnSprite then
		btnWidth = btnSprite:getContentSize().width;
	end

	-- 重设大小，导致图像变形，暂时去掉
	--[[if lblWidth > btnWidth then
		self:setButtonSize(52 * (lblWidth/btnWidth), 52);
	end]]
end

--[[ 更新按钮贴图 ]]
function XgButton:updateButtonImage_(force)
	local state = self.fsm_:getState()
	XgButton.super.updateButtonImage_(self, force);
end

--[[ 设置按钮是否可穿透 ]]
function XgButton:setTouchSwallowEnabled(flag)
	if self.touchNode_ then
		self.touchNode_:setTouchSwallowEnabled(flag);
	end
end

--[[ 获取大小 ]]
function XgButton:getSize()
	return self.sprite_[1]:getContentSize();
end

--[[ 获取宽度 ]]
function XgButton:getWidth()
	return self:getSize().width;
end

--[[ 获取高度 ]]
function XgButton:getHeight()
	return self:getSize().height;
end

--[[ 设置用户数据 ]]
function XgButton:setUserData(data)
	self._userData = data;
end

--[[ 获取用户数据 ]]
function XgButton:getUserData()
	return self._userData;
end

--[[ 检测错误 ]]
function XgButton:checkError(state)
	if state == nil then return end

	assert(state == self.NORMAL
		or state == self.PRESSED
		or state == self.DISABLED,
	string.format("XgButton - checkError() - invalid state %s", tostring(state)));
end

--[[ 可视范围中心点世界坐标和显示范围 ]]
function XgButton:getCenterRect()
	local scaleX = self:getScaleX();
	local scaleY = self:getScaleY();
	local anch = cc.p(self:getAnchorPoint());
	local wCentPos = self:convertToWorldSpaceAR(cc.p(0.5, 0.5));
	wCentPos.x = wCentPos.x - (anch.x - 0.5) * self:getWidth() * scaleX;
	wCentPos.y = wCentPos.y - (anch.y - 0.5) * self:getHeight() * scaleY;
	local size = self:getSize();
	return wCentPos, cc.size(size.width * scaleX, size.height * scaleY);
end

--[[ 进入节点监听 ]]
function XgButton:onEnter()
	self:updateButtonImage_();
	self:updateButtonLable_();
end

return XgButton
