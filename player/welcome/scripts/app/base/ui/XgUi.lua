--[[
	UI控件管理器
	@Author: ccb
	@Date: 2017-08-31
]]
local CURRENT_MODULE_NAME = ...;
local PACKAGE_NAME = string.sub(CURRENT_MODULE_NAME, 1, -6);

local XgUi = {};
XgUi.INSTANCE = nil;
XgUi.PACKAGE_NAME = PACKAGE_NAME;

-- Label 特效类型
XgUi.LABEL_EFT_TYPE = {
	OUTLINE = 1,
	SHADOW = 2,
};

-- scrollView 类型
XgUi.SCROLL_VIEW_TYPE = {
	LIST = 1,
	PAGE = 2,
};

-- scrollView 方向
XgUi.SCROLL_VIEW_DIR = {
	BOTH = cc.ui.UIScrollView.DIRECTION_BOTH,
	VER = cc.ui.UIScrollView.DIRECTION_VERTICAL,
	HOR = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
};

-- 标签栏方向 类型
XgUi.TAB_BAR_DIR = {
	VER = 1,
	HOR = 2,
};

-- TextInput 类型
XgUi.TEXT_INPUT_TYPE = {
	EDITBOX = 1,
	TEXT_FIELD = 2,
};

-- checkBoxGroup 类型
XgUi.CHECK_BOX_GROUP_TYPE = {
	CHECKBOX = 1,
	RADIOBOX = 2,
};

--[[ 构造方法 ]]
function XgUi:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	self:init();
	return o;
end

--[[ 初始化 ]]
function XgUi:init()

	local tbRef = {
		mask = ".XgMask",
		label = ".XgLabel",
		artLabel = ".XgArtLabel",
		button = ".XgButton",
		tabBar = ".XgTabBar",
		tabBarEx = ".XgTabBarEx",
		listView = ".XgListView",
		pageBar = ".XgPageBar",
		pageView = ".XgPageView",
		textInput = ".XgTextInput",
		richText = ".XgRichText",
		atlasNum = ".XgAtlasNum",
		tableView = ".XgTableView",
		dropDownList = ".XgDropDownList",
		dropDownItem = ".XgDropDownListItem",
		proBarStrip = ".XgProgressBarStrip",

		panelBase = ".XgPanelBase",
		comFrame = ".XgComFrame",
	};
	self._cfg = {};
	setmetatable(self._cfg, {
		__index = function(t, k)
			local ref = tbRef[k];
			return rawget(t, k) or (ref and import(PACKAGE_NAME .. ref)) or rawget(t, k);
		end
	});
end

--[[ 获取类 ]]
function XgUi:getClass(key)
	if not key then return end

	return self._cfg[key];
end

--[[ 创建Label ]]
function XgUi:newLabel(options)
	local Label = self:getClass("label");
	return Label.new(options);
end

--[[ 创建艺术Label ]]
function XgUi:newArtLabel(options)
	local artLabel = self:getClass("artLabel");
	return artLabel.new(options);
end

--[[ 创建BMFLabel ]]
function XgUi:newBMFLabel(ops)
	if ops and ops.font and xg and xg.altPackHelp then
		ops.font = xg.altPackHelp:convertResFileP(ops.font);
	end
	return ui.newBMFontLabel(ops);
end

--[[ 创建Button ]]
function XgUi:newButton(options)
	local Button = self:getClass("button");
	return Button.new(options);
end

--[[ 创建ScollView ]]
function XgUi:newScollView(options)
	options = options or {};
	options.type = options.type or self.SCROLL_VIEW_TYPE.LIST;
	if options.type == self.SCROLL_VIEW_TYPE.LIST then
		local List = self:getClass("listView");
		return List.new(options);
	elseif options.type == self.SCROLL_VIEW_TYPE.PAGE then
		local Page = self:getClass("pageView");
		return Page.new(options);
	end
end

--[[ 创建列表 ]]
function XgUi:newTableView(options)
	local TView = self:getClass("tableView");
	return TView.new(options);
end

--[[ 创建标签栏 ]]
function XgUi:newTabBar(options)
	local class = (options and options.class) or "tabBar";
	local TabBar = self:getClass(class);
	return TabBar.new(options);
end

--[[ 创建下拉列表控件 ]]
function XgUi:newDropDownList(options)
	options = options or {};
	options.itemType = options.itemType or "dropDownItem";
	options.itemClass = self:getClass(options.itemType);
	local DropDownList = self:getClass("dropDownList");
	return DropDownList.new(options);
end

--[[ 创建分页栏 ]]
function XgUi:newPageBar(options)
	local PageBar = self:getClass("pageBar");
	return PageBar.new(options);
end

--[[ 创建文本输入控件 ]]
function XgUi:newTextInput(options)
	local Input = self:getClass("textInput");
	return Input.new(options);
end

--[[ 创建遮罩 ]]
function XgUi:newMask(options)
	local Mask = self:getClass("mask");
	return Mask.new(options);
end

--[[ 创建富文本控件 ]]
function XgUi:newRichText(options)
	local RichText = self:getClass("richText");
	return RichText.new(options);
end

--[[ 创建图片集文本 ]]
function XgUi:newAtlasNum(options)
	local AtlasNum = self:getClass("atlasNum");
	return AtlasNum.new(options);
end

--[[ 创建隔条形进度条 ]]
function XgUi:newProgressBarStrip(options)
	local ProBarStrip = self:getClass("proBarStrip");
	return ProBarStrip.new(options);
end

--[[ 创建ccs导出的骨骼动画 ]]
function XgUi:newArmature(ops)
	if ops and type(ops) == "string" then
		ops = {name = ops};
	end
	ops = ops or {};
	local armat = CCArmature:create(ops.name);
	if ops.ani and type(ops.ani) == "string" then
		armat:getAnimation():play(ops.ani, ops.dt or -1, ops.dt_tween or -1, ops.eas_twen or 1);
	end
	if ops.scl and type(ops.scl) == "number" then
		armat:setScale(ops.scl);
	end

	return armat;
end

--[[ 创建spine动画 ]]
function XgUi:newSpine(ops)
	ops = ops or {};

	if ops and ops.atlas and xg and xg.altPackHelp then
		ops.atlas = xg.altPackHelp:convertResFileP(ops.atlas);
	end
	if ops and ops.json and xg and xg.altPackHelp then
		ops.json = xg.altPackHelp:convertResFileP(ops.json);
	end
	local spineSp = SkeletonAnimation:createWithFile(ops.json, ops.atlas, ops.scl or 1);
	spineSp:setAnimation(ops.track_idx or 0, ops.ani or "idle", ops.loop or false);
	if ops.start_cb and type(ops.startcb) == "function" then
		spineSp:addHandleOfSpineEvent(ops.start_cb, CCSpineAnimationStart);
	end
	if ops.end_cb and type(ops.end_cb) == "function" then
		spineSp:addHandleOfSpineEvent(ops.end_cb, CCSpineAnimationEnd);
	end

	return spineSp;
end

--[[ 获取单例 ]]
function XgUi:getInstance(...)
	local instance = self.INSTANCE;
	if not instance then
		instance = self:new(...);
		self.INSTANCE = instance;
	end
	return instance;
end

return XgUi;
