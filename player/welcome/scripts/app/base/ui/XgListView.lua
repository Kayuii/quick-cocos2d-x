--[[
	整理 XgListView
	@Author: ccb
	@Date: 2017-09-01
	---------------------

	继承关系:
		...:
			UIScrollView:
				UIListView:
					XgListView:
	
	XgListView 继承于 UIListView ，在其基础上整理和扩展了部分接口。
	主要整理了异步与非异步处理的整合，尽量做到创建简单，处理简单。

	示例:
	local bIsAsync = false;
	local nDirection = xg.ui.SCROLL_VIEW_DIR.VER;
	local data1, data2 = {}, {};
	for i = 1, 20 do
		data1[i] = "item" .. i;
	end
	for j = 1, 22 do
		data2[j] = "test" .. j;
	end
	local listPos = cc.p(100, 100);
	local listSize = cc.size(300, 300);
	local list = xg.ui:newScollView({
		async = bIsAsync,
		viewRect = cc.rect(listPos.x, listPos.y, listSize.width, listSize.height),
		direction = nDirection,
	});
	list:onTouch(function(event)
		-- 触摸事件监听
		if event.name == "clicked" and event.itemPos then
			print("#####list item clicked pos is ", event.itemPos);
		end
		if event.name == list.EVENT_DROP_DOWN then
			print("#####list drop down");
		end
		if event.name == list.EVENT_PULL_UP then
			print("#####list pull up");
		end
	end);
	list:onCreateItem(function(event)
		-- 创建列表项
		local item = event.item;
		local node = event.node;
		local data = event.data;

		local itemSize = cc.size(listSize.width, 50);
		item:setItemSize(itemSize.width, itemSize.height)
		node:setContentSize(itemSize);
		node:align(display.CENTER, itemSize.width/2, itemSize.height/2);

		local label = xg.ui:newLabel({
			text = data,
			size = xg.font.size.nor,
			color = xg.color.white,
		});
		label:align(display.LEFT_CENTER, 20, itemSize.height/2);
		label:addTo(node);
	end);
	list:addTo(self);
	
	-- 更新数据
	list:setDataAndReload(data1, nil, true);
	self:performWithDelay(function()
		list:setDataAndReload(data2, nil, true);
	end, 3);

	=================================================================================================
	---------------------------------------------WARNING---------------------------------------------
	尽量通过设置 viewRect 参数来进行定位和设置大小。
	使用 setPosition() 来定位，某些情况下会造成列表滑动时内容发生偏移。例如异步加载列表。
	使用异步加载时，需要注意的是列表项数量的设置，为0将创建不了。
	=================================================================================================
]]
local UIListView = cc.ui.UIListView;
local XgListView = class("XgListView", UIListView);

XgListView.EVENT_PULL_UP = "pull_up";
XgListView.EVENT_DROP_DOWN = "drop_down";
XgListView.UNLOAD_CELL_TAG	= "UnloadCell";
XgListView.DEF_PULL_SPACE_H = 50;

--[[ 构造函数 ]]
function XgListView:ctor(options)
	self._options 	= options or {};
	self._data 		= self._options.data or {};
	self._type 		= self._options.type or xg.ui.SCROLL_VIEW_TYPE.LIST;
	self._itemCount = self._options.itemCount or 0;
	self.bAsyncLoad = self._options.async or false;
	self._options.viewRect = self._options.viewRect or cc.rect(0, 0, 0, 0);
	self.delegate_ = {};
	self.itemsFree_ = {};
	self.redundancyViewVal = 0; -- 异步的视图两个方向上的冗余大小,横向代表宽,竖向代表高
	self._pull_space_h = self._options.pull_space_h or self.DEF_PULL_SPACE_H;

	XgListView.super.ctor(self, self._options);
end

--[[ 设置创建Item节点的方法 ]]
function XgListView:onCreateItem(callback)
	if not callback or type(callback) ~= "function" then return end

	self._createItemFuc = callback;
end

--[[
	创建Item节点
	@params idx[number] 索引值
			info[table] 数据信息
			item[UIListViewItem] 列表项实例
	@return node[CCNode] 节点
]]
function XgListView:createItemNode(idx, info, item, key)
	local node = display.newNode();

	local func = self._createItemFuc;
	if func and type(func) == "function" then
		func({
			node 	= node or nil,
			item  	= item or nil,
			index 	= idx,
			key 	= key,
			data 	= info or self._data[key] or {},
			name 	= "ON_CREATE_ITEM",
		});
	end

	return node;
end

--[[ 设置异步加载代理 ]]
function XgListView:setAsyncDelegate()
	if self.bAsyncLoad then
		self:setDelegate(handler(self, self.sourceDelegate));
	end
end

--[[设置delegate函数 ]]
function XgListView:setDelegate(delegate)
	self.delegate_[UIListView.DELEGATE] = delegate;
end

--[[
	异步加载代理处理
	@params listView[XgListView] 自身
			tag[string] 目标值
			idx[number] 索引值
]]
function XgListView:sourceDelegate(listView, tag, idx)
	if UIListView.CELL_TAG == tag then
		local item = self:dequeueItem();
		if item == nil then
			-- 如果是空闲项则创建Item
			item = self:newItem();
		else
			-- 如果非空闲项则移除Item,便于重新创建ItemNode
			item:removeAllChildren();
		end
		local keys = self:getKeysBySort();
		local node = self:createItemNode(idx, nil, item, keys[idx]);
		item:addContent(node);

		return item;
	elseif UIListView.UNLOAD_CELL_TAG == tag then

	elseif UIListView.COUNT_TAG == tag then
		return self:getItemCount();
	end
end

--[[
	设置新数据并重载
	@params data[table] 新数据
			sortFuc[function] 排序方法
			bAutoPos[boolean] 是否自动复位
]]
function XgListView:setDataAndReload(data, sortFuc, bAutoPos)
	if not data or not next(data) then
		self._preData = nil;
		self:removeAllItems();
		return;
	end
	self._data = data;
	self._sortFuc = sortFuc;
	bAutoPos = checkbool(bAutoPos);

	local preSubY;
	-- 自动复位，由于游戏竖版，大多纵向列表，暂只处理纵向
	if self.DIRECTION_VERTICAL == self.direction 
	and bAutoPos and table.nums(self._preData or {}) ~= 0 then
		local offy = self.container:getPositionY();
		local box = self:getContainerCascadeBoundingBox();
		preSubY = offy - (self:getListSize().height - box.height);
	end

	if self.bAsyncLoad then
		-- 一般情况下，item的数量是和data的数吻合的。
		self:setItemCount(table.nums(self._data));
		self:setAsyncDelegate();
		self:reload();
	else
		self:removeAllItems();
		local keys = self:getKeysBySort();
		for idx, key in ipairs(keys) do
			if self._data[key] then
				local item = self:newItem();
				local node = self:createItemNode(idx, self._data[key], item, key);
				item:addContent(node);
				self:addItem(item);
			end
		end
		self:reload();
	end
	self._preData = clone(self._data);

	-- 自动复位, 异步加载有问题，暂不做处理
	if not self.bAsyncLoad and preSubY then
		local box = self:getContainerCascadeBoundingBox();
		local subH = self:getListSize().height - box.height;
		if subH < 0 then
			local offy = preSubY + subH;
			offy = math.min(offy, 0);
			self:scrollTo(0, offy);
		end
	end
end

--[[ 获取排序方法(有些数据非数组，则需要进行排序) ]]
function XgListView:getKeysBySort()
	local keys = table.keys(self._data);
	if self._sortFuc then
		table.sort(keys, self._sortFuc);
	else
		table.sort(keys);
	end
	return keys;
end

--[[ 滑动监听(覆写父类方法) ]]
function XgListView:scrollListener(event)
	if "clicked" == event.name or "moved" == event.name then
		local nodePoint = self.container:convertToNodeSpace(cc.p(event.x, event.y));
		local pos;
		local idx;

		if self.bAsyncLoad then
			local itemRect;
			for i,v in ipairs(self.items_) do
				local posX, posY = v:getPosition();
				local itemW, itemH = v:getItemSize();
				itemRect = cc.rect(posX, posY, itemW, itemH);
				if cc.rectContainsPoint(itemRect, nodePoint) then
					idx = v.idx_;
					pos = idx;
					break;
				end
			end
		else
			nodePoint.x = nodePoint.x - self.viewRect_.x;
			nodePoint.y = nodePoint.y - self.viewRect_.y;
			local width, height = 0, self.size.height;
			local itemW, itemH = 0, 0;

			if self.DIRECTION_VERTICAL == self.direction then
				for i,v in ipairs(self.items_) do
					itemW, itemH = v:getItemSize();
					if nodePoint.y < height and nodePoint.y > height - itemH then
						pos = i;
						idx = pos;
						nodePoint.y = nodePoint.y - (height - itemH);
						break;
					end
					height = height - itemH;
				end
			else
				for i,v in ipairs(self.items_) do
					itemW, itemH = v:getItemSize();
					if nodePoint.x > width and nodePoint.x < width + itemW then
						pos = i;
						idx = pos;
						break;
					end
					width = width + itemW;
				end
			end
		end

		self:notifyListener_({
			name = event.name,
			listView = self, 
			itemPos = pos, 
			item = self.items_[pos],
			point = nodePoint,
			x = event.x,
			y = event.y,
		});
	else
		if self.DIRECTION_VERTICAL == self.direction and event.name == "ended" then
			if not self.bAsyncLoad then
				local curOffy = self.container:getPositionY();
				local box = self:getContainerCascadeBoundingBox();
				local subH = self.viewRect_.height - box.height;
				local subY = curOffy - subH;
				if subY < 0 and subY < self._pull_space_h * -1 then
					self:notifyListener_({name = self.EVENT_DROP_DOWN, listView = self});
				end
				if (subH >= 0 and subY > 0 and subY > self._pull_space_h) or (subH < 0 and curOffy > 0 and curOffy > self._pull_space_h) then
					self:notifyListener_({name = self.EVENT_PULL_UP, listView = self});
				end
			end
		end
		
		event.scrollView = nil;
		event.listView = self;
		self:notifyListener_(event);
	end
end

--[[ 加载列表(覆写父类方法) ]]
function XgListView:reload()
	if self.bAsyncLoad then
		self:asyncLoad_();
	else
		self:layout_();
	end
	return self;
end

--[[ 更新(覆写父类方法) ]]
function XgListView:update_(dt)
	XgListView.super.update_(self, dt);

	self:checkItemsInStatus_();
	if self.bAsyncLoad then
		self:increaseOrReduceItem_();
	end
end

--[[ 动态调整item, 是否需要加载新item, 移除旧item ]]
function XgListView:increaseOrReduceItem_()
	if 0 == #self.items_ then return end

	local count = self.delegate_[self.DELEGATE](self, self.COUNT_TAG);
	local nNeedAdjust = 2; -- 作为是否还需要再增加或减少item的标志, 2表示上下两个方向或左右都需要调整
	local cascadeBound = self:getContainerCascadeBoundingBox();
	local item;
	local itemW, itemH;

	if self.DIRECTION_VERTICAL == self.direction then
		local disH = cascadeBound.y + cascadeBound.height - self.viewRect_.y - self.viewRect_.height;
		local tempIdx;
		item = self.items_[1];
		if not item then return end

		tempIdx = item.idx_;
		if disH > self.redundancyViewVal then
			itemW, itemH = item:getItemSize();
			if cascadeBound.height - itemH > self.viewRect_.height and disH - itemH > self.redundancyViewVal then
				self:unloadOneItem_(tempIdx);
			else
				nNeedAdjust = nNeedAdjust - 1;
			end
		else
			item = nil;
			tempIdx = tempIdx - 1;
			if tempIdx > 0 then
				local localPoint = self.container:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y + cascadeBound.height));
				item = self:loadOneItem_(localPoint, tempIdx, true);
			end
			if nil == item then
				nNeedAdjust = nNeedAdjust - 1;
			end
		end

		disH = self.viewRect_.y - cascadeBound.y;
		item = self.items_[#self.items_];
		if not item then
			return;
		end
		tempIdx = item.idx_;
		if disH > self.redundancyViewVal then
			itemW, itemH = item:getItemSize();
			if cascadeBound.height - itemH > self.viewRect_.height and disH - itemH > self.redundancyViewVal then
				self:unloadOneItem_(tempIdx);
			else
				nNeedAdjust = nNeedAdjust - 1;
			end
		else
			item = nil;
			tempIdx = tempIdx + 1;
			if tempIdx <= count then
				local localPoint = self.container:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y));
				item = self:loadOneItem_(localPoint, tempIdx);
			end
			if nil == item then
				nNeedAdjust = nNeedAdjust - 1;
			end
		end
	else
		local disW = self.viewRect_.x - cascadeBound.x;
		item = self.items_[1];
		local tempIdx = item.idx_;
		if disW > self.redundancyViewVal then
			itemW, itemH = item:getItemSize();
			if cascadeBound.width - itemW > self.viewRect_.width and disW - itemW > self.redundancyViewVal then
				self:unloadOneItem_(tempIdx);
			else
				nNeedAdjust = nNeedAdjust - 1;
			end
		else
			item = nil;
			tempIdx = tempIdx - 1;
			if tempIdx > 0 then
				local localPoint = self.container:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y));
				item = self:loadOneItem_(localPoint, tempIdx, true);
			end
			if nil == item then
				nNeedAdjust = nNeedAdjust - 1;
			end
		end

		disW = cascadeBound.x + cascadeBound.width - self.viewRect_.x - self.viewRect_.width;
		item = self.items_[#self.items_];
		tempIdx = item.idx_;
		if disW > self.redundancyViewVal then
			itemW, itemH = item:getItemSize();
			if cascadeBound.width - itemW > self.viewRect_.width and disW - itemW > self.redundancyViewVal then
				self:unloadOneItem_(tempIdx);
			else
				nNeedAdjust = nNeedAdjust - 1;
			end
		else
			item = nil;
			tempIdx = tempIdx + 1;
			if tempIdx <= count then
				local localPoint = self.container:convertToNodeSpace(cc.p(cascadeBound.x + cascadeBound.width, cascadeBound.y));
				item = self:loadOneItem_(localPoint, tempIdx);
			end
			if nil == item then
				nNeedAdjust = nNeedAdjust - 1;
			end
		end
	end

	if nNeedAdjust > 0 then
		return self:increaseOrReduceItem_();
	end
end

--[[ 异步加载列表数据 ]]
function XgListView:asyncLoad_()
	self:removeAllItems();
	self.container:setPosition(0, 0);
	self.container:setContentSize(cc.size(0, 0));

	local count = self.delegate_[self.DELEGATE](self, self.COUNT_TAG);
	self.items_ = {};
	local itemW, itemH = 0, 0;
	local item;
	local containerW, containerH = 0, 0;
	local posX, posY = 0, 0;
	for i = 1, count do
		item, itemW, itemH = self:loadOneItem_(cc.p(posX, posY), i);
		if self.DIRECTION_VERTICAL == self.direction then
			posY = posY - itemH;
			containerH = containerH + itemH;
		else
			posX = posX + itemW;
			containerW = containerW + itemW;
		end

		-- 初始布局,最多保证可隐藏的区域大于显示区域就可以了
		if containerW > self.viewRect_.width + self.redundancyViewVal
		or containerH > self.viewRect_.height + self.redundancyViewVal then
			break;
		end
	end

	if self.DIRECTION_VERTICAL == self.direction then
		self.container:setPosition(self.viewRect_.x, self.viewRect_.y + self.viewRect_.height);
	else
		self.container:setPosition(self.viewRect_.x, self.viewRect_.y);
	end

	return self;
end

--[[
	加载一个数据项
	@params table originPoint 数据项要加载的起始位置
			number idx 要加载数据的序号
			boolean bBefore 是否加在已有项的前面
	@return UIListViewItem item
]]
function XgListView:loadOneItem_(originPoint, idx, bBefore)
	local itemW, itemH = 0, 0;
	local item;
	local containerW, containerH = 0, 0;
	local posX, posY = originPoint.x, originPoint.y;
	local content;

	item = self.delegate_[self.DELEGATE](self, self.CELL_TAG, idx);
	if nil == item then return end

	item.idx_ = idx
	itemW, itemH = item:getItemSize()
	if self.DIRECTION_VERTICAL == self.direction then
		itemW = itemW or 0;
		itemH = itemH or 0;

		if bBefore then
			posY = posY;
		else
			posY = posY - itemH;
		end
		content = item:getContent();
		content:setAnchorPoint(0.5, 0.5);
		self:setPositionByAlignment_(content, itemW, itemH, item:getMargin());
		item:setPosition(0, posY);
		containerH = containerH + itemH;
	else
		itemW = itemW or 0;
		itemH = itemH or 0;
		if bBefore then
			posX = posX - itemW;
		end

		content = item:getContent();
		content:setAnchorPoint(0.5, 0.5);
		self:setPositionByAlignment_(content, itemW, itemH, item:getMargin());
		item:setPosition(posX, 0);
		containerW = containerW + itemW;
	end

	if bBefore then
		table.insert(self.items_, 1, item);
	else
		table.insert(self.items_, item);
	end

	self.container:addChild(item);
	if item.bFromFreeQueue_ then
		item.bFromFreeQueue_ = nil;
		item:release();
	end
	return item, itemW, itemH;
end

--[[ 调整item中content的布局 ]]
function XgListView:setPositionByAlignment_(content, w, h, margin)
	local size = content:getContentSize();
	if 0 == margin.left and 0 == margin.right and 0 == margin.top and 0 == margin.bottom then
		if self.DIRECTION_VERTICAL == self.direction then
			if self.ALIGNMENT_LEFT == self.alignment then
				content:setPosition(size.width/2, h/2);
			elseif self.ALIGNMENT_RIGHT == self.alignment then
				content:setPosition(w - size.width/2, h/2);
			else
				content:setPosition(w/2, h/2);
			end
		else
			if self.ALIGNMENT_TOP == self.alignment then
				content:setPosition(w/2, h - size.height/2);
			elseif self.ALIGNMENT_RIGHT == self.alignment then
				content:setPosition(w/2, size.height/2);
			else
				content:setPosition(w/2, h/2);
			end
		end
	else
		local posX, posY;
		if 0 ~= margin.right then
			posX = w - margin.right - size.width/2;
		else
			posX = size.width/2 + margin.left;
		end
		if 0 ~= margin.top then
			posY = h - margin.top - size.height/2;
		else
			posY = size.height/2 + margin.bottom;
		end
		content:setPosition(posX, posY);
	end
end

--[[ 移除一个数据项 ]]
function XgListView:unloadOneItem_(idx)
	local item = self.items_[1];
	if nil == item then return end

	if item.idx_ > idx then return end

	local unloadIdx = idx - item.idx_ + 1;
	item = self.items_[unloadIdx];
	if nil == item then return end

	table.remove(self.items_, unloadIdx);
	self:addFreeItem_(item);
	self.container:removeChild(item, false);

	self.delegate_[self.DELEGATE](self, self.UNLOAD_CELL_TAG, idx);
end

--[[ 加一个空项到空闲列表中 ]]
function XgListView:addFreeItem_(item)
	item:retain();
	table.insert(self.itemsFree_, item);
end

--[[ 释放所有的空闲列表项 ]]
function XgListView:releaseAllFreeItems_()
	for i,v in ipairs(self.itemsFree_) do
		v:release();
	end
	self.itemsFree_ = {};
end

--[[ 获取item的CascadeBoundingBox ]]
function XgListView:getContainerCascadeBoundingBox()
	local boundingBox;
	for i, item in ipairs(self.items_) do
		local w,h = item:getItemSize();
		local x,y = item:getPosition();
		local anchor = item:getAnchorPoint();
		x = x - anchor.x * w;
		y = y - anchor.y * h;

		if boundingBox then
			local function rectUnion(rect1, rect2)
				local rect = cc.rect(0, 0, 0, 0);
				rect.x = math.min(rect1.x, rect2.x);
				rect.y = math.min(rect1.y, rect2.y);
				rect.width = math.max(rect1.x + rect1.width, rect2.x + rect2.width) - rect.x;
				rect.height = math.max(rect1.y + rect1.height, rect2.y + rect2.height) - rect.y;
				return rect;
			end

			boundingBox = rectUnion(boundingBox, cc.rect(x, y, w, h));
		else
			boundingBox = cc.rect(x, y, w, h);
		end
	end

	if not boundingBox then
		boundingBox = self.scrollNode:getCascadeBoundingBox();
	else
		local point = self.container:convertToWorldSpace(cc.p(boundingBox.x, boundingBox.y));
		boundingBox.x = point.x;
		boundingBox.y = point.y;
	end
	
	return boundingBox;
end

--[[ 取一个空闲项出来,如果没有返回空 ]]
function XgListView:dequeueItem()
	if #self.itemsFree_ < 1 then return end

	local item;
	item = table.remove(self.itemsFree_, 1);
	item.bFromFreeQueue_ = true;

	return item;
end

--[[ 设置Item数量，主要用于异步 ]]
function XgListView:setItemCount(count)
	local ct = tonumber(count);
	if ct then
		self._itemCount = ct;
	end
end

--[[ 获取Item数量 ]]
function XgListView:getItemCount()
	return self._itemCount;
end

--[[ 设置显示区域(继承父类), 尽量用传参的方法来设置 ]]
function XgListView:setViewRect(viewRect)
	if viewRect == nil then return end

	if self.DIRECTION_VERTICAL == self.direction then
		self.redundancyViewVal = viewRect.height;
	else
		self.redundancyViewVal = viewRect.width;
	end
	self._options.viewRect = viewRect;

	XgListView.super.setViewRect(self, viewRect);
end

--[[ 获取大小 ]]
function XgListView:getListSize()
	return cc.size(self._options.viewRect.width, self._options.viewRect.height);
end

--[[ 获取位置信息 ]]
function XgListView:getListPosition()
	return cc.p(self._options.viewRect.x, self._options.viewRect.y);
end

--[[ 设置是否可用触摸 ]]
function XgListView:setTouchEnabled(bEnabled)
	-- XgListView.super.setTouchEnabled(self, bEnabled);
	if self.scrollNode then
		self.scrollNode:setTouchEnabled(bEnabled);
	end
	if self.touchNode_ then
		self.touchNode_:setTouchEnabled(bEnabled);
	end
	return self;
end

--[[ 判断是否点击到视图区域 ]]
function XgListView:isTouchedViewRect(point)
	return self:isTouchInViewRect({x = point.x, y = point.y});
end

--[[ 移除所有项(覆写父类方法) ]]
function XgListView:removeAllItems()
	if self.container then
		self.container:removeAllChildren();
	end
	self.items_ = {};
	return self;
end

--[[ 获取容器偏移量 ]]
function XgListView:getContainerOffset()
	if not self.container then return end

	return cc.p(self.container:getPosition());
end

return XgListView;
