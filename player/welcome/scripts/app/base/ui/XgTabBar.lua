--[[
	XgTabBar
	@Author: ccb
	@Date: 2017-09-03
	--------------------
	示例:
	-- 默认按钮样式
	local options = {
		data = {"Tab_1", "Tab_2"},
		size = cc.size(360, 50),
	};
	-- 自定义按钮样式
	local options2 = {
		data = {
			[1] = {
				text = {text = "Tab_1", color = xg.color.green},
				images = {
					normal = "ui/club/club_btn_zcd_sld.png",
					pressed = "ui/club/club_btn_zcd_nor.png",
				},
			},
			[2] = {
				text = {text = "Tab_2", color = xg.color.red},
				images = {
					normal = "ui/club/club_btn_zcd_sld.png",
					pressed = "ui/club/club_btn_zcd_nor.png",
				},
				lbImg = {
					img = "ui/discover/descirbe_icon_addon.png",
					offset = cc.p(-50, 0),
				},
			},
		},
		index = 2,
		size = cc.size(360, 65),
		direction = xg.ui.TAB_BAR_DIR.HOR,
		showItemBg = false,
	};
	local bar = xg.ui:newTabBar(options2);
	bar:addEventListener(bar.EVENT_ON_TAB_CLICKED, function(event)
		print("#####TabBar clicked:", event.index);
	end);
	bar:align(display.LEFT_BOTTOM, 10, display.height - 250);
	bar:addTo(self, 1);
	bar:setSelectIndex(1);
]]

local XgTabBar = class("XgTabBar", function(options)
	local node = display.newNode();
	node:setNodeEventEnabled(true);
	cc(node):addComponent("components.behavior.EventProtocol"):exportMethods();
	return node;
end);

-- 默认按钮样式
XgTabBar.DEF_BTN = {
	text = {
		text = "", 
		color = xg.color.white,
	},
	images = {
		normal = "ui/discover/descirbe_btn_tab_nor.png",
		pressed = "ui/discover/descirbe_btn_tab_sld.png",
		disabled = "ui/discover/descirbe_btn_tab_nor.png",
	},
};

XgTabBar.DEF_INTERVAL = 0;
XgTabBar.DEF_DEBUG_MOD = 0;
XgTabBar.DEF_SIZE = cc.size(128, 45);
XgTabBar.EVENT_ON_TAB_CLICKED = "ON_TAB_CLICKED";

--[[ 构造函数 ]]
function XgTabBar:ctor(options)
	self._options 	= options or {};
	self._data 		= self._options.data or {};
	self._index		= self._options.index or nil;
	self._offset 	= self._options.offset or cc.p(0, 0);
	self._size 		= self._options.size or self.DEF_SIZE;
	self._isDebug 	= self._options.isDebug or self.DEF_DEBUG_MOD;
	self._interval	= self._options.interval or self.DEF_INTERVAL;
	self._direction = self._options.direction or xg.ui.TAB_BAR_DIR.HOR;
	self._zorderDir = self._options.zorderDir or 1;
	self._isEnabled = self._options.isEnabled;
	self._showItemBg = self._options.showItemBg;
	self._bScrollEnable = self._options.bScrollEnable;
	self._isEnabled = (self._isEnabled == nil) and true or self._isEnabled;
	self._showItemBg = (self._showItemBg == nil) and true or self._showItemBg;
	self._bScrollEnable = (type(self._bScrollEnable) == "boolean" and self._bScrollEnable);
	self._aryTabBtn = {};

	self:setExtParams();
	self:init();
end

--[[ 添加或修改参数 ]]
function XgTabBar:setExtParams()
	
end

--[[ 初始化 ]]
function XgTabBar:init()
	self:handleData();
	self._selectInfo = newBindTable({
		index = -1,
		preIndex = -1,
	});
end

--[[ 进入父节点监听 ]]
function XgTabBar:onEnter()
	self:createContent();
end

--[[ 创建内容 ]]
function XgTabBar:createContent()
	self:setContentSize(self._size);
	
	-- 创建列表
	self._listSize = self._size;
	self._listPos = cc.p(self._size.width/2 - self._listSize.width/2, self._size.height/2 - self._listSize.height/2);
	local list = xg.ui:newScollView({
		viewRect = cc.rect(self._listPos.x, self._listPos.y, self._listSize.width, self._listSize.height),
		direction = self._direction,
	});
	list:setTouchEnabled(self._bScrollEnable);
	list:onCreateItem(handler(self, self.createItemNode));
	list:addTo(self, 1);

	self._list = list;
	list:setDataAndReload(self._data);
	
	self:setSelectIndex(self._index);
	
	if self._isDebug == 1 then
		local layer = cc.LayerColor:create(xg.color.c3b2C4b(xg.color.green, 100), self._size.width, self._size.height);
		layer:addTo(self);
	end
end

--[[ 创建列表项 ]]
function XgTabBar:createItemNode(event)
	local item = event.item;
	local node = event.node;
	local data = event.data;
	local key = event.key;
	local index = event.index;
	
	local btn = xg.ui:newButton(data);

	local itemSize = clone(btn:getSize());
	if self._direction == xg.ui.TAB_BAR_DIR.HOR then
		itemSize.width = itemSize.width + self._interval;
	end
	if self._direction == xg.ui.TAB_BAR_DIR.VER then
		itemSize.height = itemSize.height + self._interval;
	end
	item:setItemSize(itemSize.width, itemSize.height);
	item:setLocalZOrder(index * self._zorderDir);

	local nodeSize = cc.size(itemSize.width, itemSize.height);
	node:setContentSize(nodeSize);
	node:align(display.CENTER, itemSize.width * 0.5, itemSize.height * 0.5);

	-- 默认显示常态按钮作为背景
	if self._showItemBg and data.images and data.images.normal then
		local btnBg = display.newSprite(data.images.normal);
		btnBg:align(display.LEFT_BOTTOM, 0 + self._offset.x, 0 + self._offset.y);
		btnBg:addTo(node);
	end
	
	btn:setUserData(event);
	btn:onClicked(handler(self, self.onTabBtnClicked));
	btn:align(display.LEFT_BOTTOM, 0 + self._offset.x, 0 + self._offset.y);
	btn:addTo(node);

	local lbImgInfo = data.lbImg;
	if lbImgInfo then
		if type(lbImgInfo) ~= "table" then
			lbImgInfo = {img = lbImgInfo};
		end
		local offset = lbImgInfo.offset or cc.p(0, 0);
		local lbImg = display.newSprite(lbImgInfo.img);
		lbImg:align(display.CENTER, btn:getWidth() * 0.5 + offset.x, btn:getHeight() * 0.5 + offset.y);
		lbImg:addTo(btn);
	end

	btn:bind(self._selectInfo, "index", function(btn, value)
		if tonumber(value) == -1 then return end

		local flag = (value == index);
		btn:setIsSelected(flag);

		local textInfo = data.text;
		local lb = btn:getLabel();
		if lb and type(textInfo) == "table" and textInfo.seld_color then
			lb:setColor(flag and textInfo.seld_color or textInfo.color);
		end

		-- 传参设置index时调用
		if self._index and self._selectInfo.index > 0 and self._selectInfo.preIndex == -1 then
			if flag then
				self:dispatchTabBtnClickedEvent(btn, self._selectInfo.index);
			end
		end
	end);

	self._aryTabBtn[index] = btn;
end

--[[ 标签按钮点击 ]]
function XgTabBar:onTabBtnClicked(event)
	if self._isEnabled then
		event = checktable(event);
		local tag = event.target;
		local uData = tag:getUserData();
		if self._selectInfo.index ~= uData.index then
			self._selectInfo.index = uData.index;
			self:dispatchTabBtnClickedEvent(tag, uData.index);
		end
	end
end

--[[ 派发标签按钮点击事件 ]]
function XgTabBar:dispatchTabBtnClickedEvent(tag, index)
	self._selectInfo.preIndex = index;
	self._bFstSel = (type(self._bFstSel) ~= "boolean");

	local dispathEvent = {
		instance	= self,
		tab_btn		= tag,
		index 		= index,
		data 		= tag:getUserData(),
		b_fstsel	= self._bFstSel,
		name 		= self.EVENT_ON_TAB_CLICKED,
	};
	self:dispatchEvent(dispathEvent);
end

--[[ 设置选中索引 ]]
function XgTabBar:setSelectIndex(index)
	self._index = index;
	if self._index then
		self._selectInfo.index = self._index;
	end
end

--[[ 获取按钮集合 ]]
function XgTabBar:getBtnAry()
	return checktable(self._aryTabBtn);
end

--[[ 通过索引获取按钮 ]]
function XgTabBar:getBtnByIndex(idx)
	self._aryTabBtn = checktable(self._aryTabBtn);
	return self._aryTabBtn[idx];
end

--[[ 处理数据 ]]
function XgTabBar:handleData()
	local tempBtn = nil;
	for k,v in ipairs(self._data) do
		tempBtn = clone(self.DEF_BTN);
		if type(v) ~= "table" then
			v = {text = {text = v, color = tempBtn.text.color}};
		end
		table.merge(tempBtn, v);

		if tempBtn.text.text == "" then
			tempBtn.text = nil;
		end

		self._data[k] = tempBtn;
	end
end

--[[ 设置标签页列表是否可滚动 ]]
function XgTabBar:setTabScrollEnabled(flag)
	if self._list then
		self._list:setTouchEnabled(checkbool(flag));
	end
end

--[[ 是否允许点击切换页卡 ]]
function XgTabBar:setTouchEnabled(isEnabled)
	self._isEnabled = isEnabled
end

--[[ 重新初始化参数 ]]
function XgTabBar:reInitParams()
	self._index = nil;
	self._selectInfo.index = -1;
	self._selectInfo.preIndex = -1;
end

return XgTabBar;
