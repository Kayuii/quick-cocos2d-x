--[[
	下拉列表项，辅助YLDropDownList
	@Author: ccb
	@Date: 2017-09-02
]]
local XgDropDownListItem = class("XgDropDownListItem", function(options)
	local node = display.newNode();
	cc(node):addComponent("components.behavior.EventProtocol"):exportMethods();
	return node;
end);

XgDropDownListItem.DEF_SIZE = cc.size(212, 50);
XgDropDownListItem.ON_CLICKED_EVENT = "XG_DROP_DOWN_LIST_ITEM_ON_CLICKED";

--[[ 构造函数 ]]
function XgDropDownListItem:ctor(options)
	self._options 		= options or {};
	self._text 			= self._options.text or {};
	self._size 			= self._options.size or self.DEF_SIZE;
	self._itemBg 		= self._options.itemBg or nil;
	self._itemSelectBg 	= self._options.itemSelectBg or nil;

	self:init();
end

--[[ 初始化 ]]
function XgDropDownListItem:init()
	self:setContentSize(self._size);
	
	self:createStyle();

	self:swallowTouch(false);
	self:onClicked(function()
		self:dispatchEvent({name = self.ON_CLICKED_EVENT, instance = self});
	end);
end

--[[ 创建风格(子类可以创建自己的风格) ]]
function XgDropDownListItem:createStyle()
	if self._itemBg then
		local spriteBg = display.newScale9Sprite(self._itemBg, 0, 0, self._size);
		spriteBg:setPosition(self._size.width/2, self._size.height/2);
		self:addChild(spriteBg, 0);
		self._itemBg = spriteBg;
	end
	
	local label = xg.ui:newLabel(self._text);
	label:align(display.CENTER, self._size.width/2, self._size.height/2);
	self:addChild(label, 1);
	self._titleName = label;
end

--[[ 显隐选中态 ]]
function XgDropDownListItem:isSelectItem(flag)
	flag = checkbool(flag);
	if flag and self._selectBg == nil then
		if self._itemSelectBg then
			local spriteBg = display.newScale9Sprite(self._itemSelectBg, 0, 0, self._size);
			spriteBg:setPosition(self._size.width/2, self._size.height/2);
			self:addChild(spriteBg, 0);
			self._selectBg = spriteBg;
		end
	end

	if self._selectBg then
		self._selectBg:setVisible(flag);
		if self._itemBg then
			self._itemBg:setVisible(not flag);
		end
	end
end

--[[ 设置标题文本 ]]
function XgDropDownListItem:setTitleName(name)
	self._text = self._text or {text = self._text};
	self._text.text = name;
	
	if self._titleName then
		self._titleName:setString(name);
	end
end

--[[ 获取标题文本 ]]
function XgDropDownListItem:getTitleName()
	if self._titleName then
		return self._titleName:getString();
	end
	return "";
end

return XgDropDownListItem;
