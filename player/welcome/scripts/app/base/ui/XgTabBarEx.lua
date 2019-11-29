--[[
	XgTabBarEx
	@Author: ccb
	@Date: 2017-09-03
	--------------------
	示例同XgTabBar, 增加itemSize, class参数
]]
local XgTabBar = import(".XgTabBar");
local XgTabBarEx = class("XgTabBarEx", XgTabBar);

XgTabBarEx.DEF_TAB_ITEM_SIZE = cc.size(128, 0);

--[[ 添加或修改参数 ]]
function XgTabBarEx:setExtParams()
	XgTabBarEx.super.setExtParams(self);
	self._tabItemSize = self._options.itemSize or self.DEF_TAB_ITEM_SIZE;
end

--[[ 创建内容 ]]
function XgTabBarEx:createContent()
	XgTabBarEx.super.createContent(self);
	
	if self._list and self._bScrollEnable then
		local box = self._list:getContainerCascadeBoundingBox();
		if self._direction == xg.ui.TAB_BAR_DIR.HOR then
			self._list:setTouchEnabled(box.width >= self._listSize.width);
		end
		if self._direction == xg.ui.TAB_BAR_DIR.VER then
			self._list:setTouchEnabled(box.height >= self._listSize.height);
		end
	end
end

--[[ 创建列表项 ]]
function XgTabBarEx:createItemNode(event)
	local item = event.item;
	local node = event.node;
	local data = event.data;
	local key = event.key;
	local index = event.index;
	
	local itemSize = cc.size(self._tabItemSize.width, self._listSize.height);
	if self._direction == xg.ui.TAB_BAR_DIR.HOR then
		itemSize.width = itemSize.width + self._interval;
	end
	if self._direction == xg.ui.TAB_BAR_DIR.VER then
		itemSize.height = self._tabItemSize.height;
		itemSize.height = itemSize.height + self._interval;
	end
	item:setItemSize(itemSize.width, itemSize.height)
	item:setLocalZOrder(index * self._zorderDir);

	local nodeSize = cc.size(itemSize.width, itemSize.height);
	node:setContentSize(nodeSize);
	node:align(display.CENTER, itemSize.width * 0.5, itemSize.height * 0.5);
	
	local frameSize = cc.size(itemSize.width, itemSize.height - 1);
	local tabFrame = display.newScale9Sprite(data.images.normal, 0, 0, frameSize, data.rect);
	tabFrame:swallowTouch(false);
	tabFrame:onClicked(function(event)
		event.target = tabFrame;
		self:onTabBtnClicked(event);
	end);
	tabFrame:align(display.LEFT_BOTTOM, 0 + self._offset.x, 0 + self._offset.y);
	tabFrame:addTo(node);
	
	tabFrame.setUserData = function(obj, data)
		obj._userData = data;
	end
	
	tabFrame.getUserData = function(obj, data)
		return obj._userData;
	end
	
	tabFrame.setIsSelected = function(obj, flag)
		if flag and not obj._selectFrame then
			local frame = display.newScale9Sprite(data.images.pressed, 0, 0, obj:getContentSize(), data.rect);
			frame:align(display.LEFT_BOTTOM, 0 + self._offset.x, 0 + self._offset.y);
			frame:addTo(node);
			obj._selectFrame = frame;
		end
		if obj._selectFrame then
			obj:setVisible(not flag);
			obj._selectFrame:setVisible(flag);
		end
	end
	
	tabFrame:setUserData(event);

	local lbImgInfo = data.lbImg;
	if lbImgInfo then
		if type(lbImgInfo) ~= "table" then
			lbImgInfo = {img = lbImgInfo};
		end
		local offset = lbImgInfo.offset or cc.p(0, 0);
		local lbImg = display.newSprite(lbImgInfo.img);
		lbImg:align(display.CENTER, itemSize.width * 0.5 + offset.x, itemSize.height * 0.5 + offset.y);
		lbImg:addTo(node, 1);
		node._lbImgNor = lbImg;
	end
	local lbImgSelInfo = data.lbImgSel;
	if lbImgSelInfo then
		if type(lbImgSelInfo) ~= "table" then
			lbImgSelInfo = {img = lbImgSelInfo};
		end
		local offset = lbImgSelInfo.offset or cc.p(0, 0);
		local lbImg = display.newSprite(lbImgSelInfo.img);
		lbImg:align(display.CENTER, itemSize.width * 0.5 + offset.x, itemSize.height * 0.5 + offset.y);
		lbImg:addTo(node, 1);
		node._lbImgSel = lbImg;
	end

	local strText = (type(data.text) == "string") and data.text;
	strText = (type(data.text) == "table" and type(data.text.text) == "string") and data.text.text or strText;
	strText = (strText and strText ~= "nil") and strText or nil;
	if strText then
		local offset = data.text.offset or cc.p(0, 0);
		local lb = xg.ui:newLabel(data.text);
		lb:align(display.CENTER, itemSize.width * 0.5 + offset.x, itemSize.height * 0.5 + offset.y);
		lb:addTo(node, 1);
		tabFrame._lbCont = lb;
	end

	tabFrame:bind(self._selectInfo, "index", function(tabFrame, value)
		if tonumber(value) == -1 then return end

		local flag = (value == index);
		tabFrame:setIsSelected(flag);

		if node._lbImgSel and node._lbImgNor then
			node._lbImgSel:setVisible(flag);
			node._lbImgNor:setVisible(not flag);
		end

		local textInfo = data.text;
		if tabFrame._lbCont and type(textInfo) == "table" and textInfo.seld_color then
			tabFrame._lbCont:setColor(flag and textInfo.seld_color or textInfo.color);
		end
		
		-- 传参设置index时调用
		if self._index and self._selectInfo.index > 0 and self._selectInfo.preIndex == -1 then
			if flag then
				self:dispatchTabBtnClickedEvent(tabFrame, self._selectInfo.index);
			end
		end
	end);

	self._aryTabBtn[index] = node;
end

--[[ 处理数据 ]]
function XgTabBarEx:handleData()
	local textMaxSize = cc.size(0, 0);
	local tempBtn, textSize = nil, nil;
	for k,v in ipairs(self._data) do
		tempBtn = clone(self.DEF_BTN);
		if type(v) ~= "table" then
			v = {text = {text = v, color = tempBtn.text.color}};
		end
		table.merge(tempBtn, v);

		if tempBtn.text.text == "" then
			tempBtn.text = nil;
		end
		
		if type(tempBtn.text) ~= "table" then
			tempBtn.text = {
				text = tempBtn.text and tostring(tempBtn.text),
				color = v.color, 
				size = v.size,
			};
		end
		
		if tempBtn.text then
			textSize = xg.font.getFontSize(tempBtn.text, true) or cc.size(0, 0);
			if self._direction == xg.ui.TAB_BAR_DIR.HOR then
				textSize.width = textSize.width + 10;
			end
			if self._direction == xg.ui.TAB_BAR_DIR.VER then
				textSize.height = textSize.height + 10;
			end
			textMaxSize.width = math.max(textMaxSize.width, textSize.width);
			textMaxSize.height = math.max(textMaxSize.height, textSize.height);
		end

		self._data[k] = tempBtn;
	end
	
	textMaxSize.width = math.max(textMaxSize.width, self._tabItemSize.width);
	textMaxSize.height = math.max(textMaxSize.height, self._tabItemSize.height);
	self._tabItemSize = textMaxSize;
end

return XgTabBarEx;
