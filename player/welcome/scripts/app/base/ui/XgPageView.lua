--[[
	整理 XgPageView
	@Author: ccb
	@Date: 2017-09-03
	---------------------
	继承关系:
		...:
			UIScrollView:
				UIPageView:
					XgPageView:
	
	XgPageView继承于UIPageView，在其基础上整理和扩展了部分接口。
	注:先继承，以便后续扩展。
	
]]
local XgPageView = class("XgPageView", cc.ui.UIPageView);

XgPageView.STATIC_CLICK_RECT_DIS = 5;

--[[ 设置创建Item节点的方法 ]]
function XgPageView:onCreateItem(callback)
	self._createItemFuc = callback;
end

--[[
	创建Item节点
	@params idx[number] 索引值
			info[table] 数据信息
			item[UIPageViewItem] 列表项实例
	@return node[CCNode] 节点
]]
function XgPageView:createItemNode(idx, info, item, key)
	local node = display.newNode();

	if self._createItemFuc then
		self._createItemFuc({
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

--[[
	设置新数据并重载
	@params data[table] 新数据
			tag_idx[number] 重载后设置的索引
			sortFuc[function] 排序方法
]]
function XgPageView:setDataAndReload(data, tag_idx, sortFuc)
	if not data or not next(data) then
		self:removeAllItems();
		return;
	end
	self._data = data or {};
	self._sortFuc = sortFuc;
	self:removeAllItems();
	local keys = self:getKeysBySort();
	for idx, key in ipairs(keys) do
		if self._data[key] then
			local item = self:newItem();
			local node = self:createItemNode(idx, self._data[key], item, key);
			item:addChild(node);
			self:addItem(item);
		end
	end
	self:reload(tag_idx);
end

--[[ 获取排序后的keys ]]
function XgPageView:getKeysBySort()
	local keys = table.keys(self._data);
	if self._sortFuc then
		table.sort(keys, self._sortFuc);
	end
	return keys;
end

--[[ 触摸监听(覆写) ]]
function XgPageView:onTouch_(event)
	if "began" == event.name and not self:isTouchInViewRect_(event) then
		return false
	end
	
	if "began" == event.name then
		self:stopAllTransition()
		self.bDrag_ = false
		self.tbTouchEvent_ = event;
	elseif "moved" == event.name then
		if self.tbTouchEvent_ then
			local cPos = cc.p(event.x, event.y);
			local pPos = cc.p(self.tbTouchEvent_.x, self.tbTouchEvent_.y);
			local dis = cc.PointDistanceSQ(cPos, pPos);
			if dis > self.class.STATIC_CLICK_RECT_DIS then
				self.tbTouchEvent_ = nil;
			end
		end
		
		self.bDrag_ = true
		self.speed = event.x - event.prevX
		self:scroll(self.speed)
	elseif "ended" == event.name then
		if self.bDrag_ then
			self:scrollAuto()
		else
			self:resetPages_()
		end
		if self.tbTouchEvent_ then
			self:onClick_(event);
		end
		self.tbTouchEvent_ = nil;
	end

	return true
end

--[[
	自动滑动处理
	覆写父类方法, 因为父类方法少了些空值判断
]]
function XgPageView:scrollAuto()
	local page = self.pages_[self.curPageIdx_];
	local pageL = self:getNextPage(false);
	local pageR = self:getNextPage(true);
	local bChange = false
	local posX, posY = page:getPosition();
	local dis = posX - self.viewRect_.x;
	local pageRX = self.viewRect_.x + self.viewRect_.width;
	local pageLX = self.viewRect_.x - self.viewRect_.width;

	local count = #self.pages_
	if 0 == count then
		return
	elseif 1 == count then
		pageL = nil
		pageR = nil
	end

	if (dis > self.viewRect_.width/2 or self.speed > 10) then
		if (self.curPageIdx_ > 1 or self.bCirc) and count > 1 then
			bChange = true
		end
	elseif (-dis > self.viewRect_.width/2 or -self.speed > 10) then
		if (self.curPageIdx_ < self:getPageCount() or self.bCirc) and count > 1 then
			bChange = true
		end
	end

	if dis > 0 then
		if bChange then
			transition.moveTo(page,
				{x = pageRX, y = posY, time = 0.3,
				onComplete = function()
					self.curPageIdx_ = self:getNextPageIndex(false)
					self:disablePage()
					self:notifyListener_{name = "pageChange"}
				end})
			if pageL then
				transition.moveTo(pageL, {x = self.viewRect_.x, y = posY, time = 0.3});
			end
		else
			transition.moveTo(page,
				{x = self.viewRect_.x, y = posY, time = 0.3,
				onComplete = function()
					self:disablePage()
					self:notifyListener_{name = "pageChange"}
				end})
			if pageL then
				transition.moveTo(pageL, {x = pageLX, y = posY, time = 0.3});
			end
		end
	else
		if bChange then
			transition.moveTo(page,
				{x = pageLX, y = posY, time = 0.3,
				onComplete = function()
					self.curPageIdx_ = self:getNextPageIndex(true)
					self:disablePage()
					self:notifyListener_{name = "pageChange"}
				end})
			if pageR then
				transition.moveTo(pageR, {x = self.viewRect_.x, y = posY, time = 0.3});
			end
		else
			transition.moveTo(page,
				{x = self.viewRect_.x, y = posY, time = 0.3,
				onComplete = function()
					self:disablePage()
					self:notifyListener_{name = "pageChange"}
				end})
			if pageR then
				transition.moveTo(pageR, {x = pageRX, y = posY, time = 0.3});
			end
		end
	end
end

--[[ 重加载(继承) ]]
function XgPageView:reload(idx)
	XgPageView.super.reload(self, idx);
	self:setPrePageIdx_();
end

--[[ 通知监听(覆写) ]]
function XgPageView:notifyListener_(event)
	if not self.touchListener then return end
	
	if self._prePageIdx_ and self._prePageIdx_ == self.curPageIdx_ then
		return;
	end
	
	self.touchListener({
		instance = self,
		cur_page = self.curPageIdx_,
		max_page = self:getMaxPage(),
	});
	self:setPrePageIdx_();
end

--[[ 移除所有项(覆写父类方法) ]]
function XgPageView:removeAllItems()
	if self.items_ and next(self.items_) then
		for k,v in pairs(self.items_) do
			v:removeSelf();
		end
	end
	self.items_ = {};
	return self;
end

function XgPageView:isTouchInViewRect_(event, rect)
	rect = rect or self.viewRect_
	local viewRect = self:convertToWorldSpace(cc.p(rect.x, rect.y))
	viewRect.width = rect.width
	viewRect.height = rect.height
	return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
end

--[[ 翻页处理 ]]
function XgPageView:onPageChange(idx, bSmooth)
	local page = self.curPageIdx_ + checkint(idx);
	if page <= 0 then return end
	if page > self:getMaxPage() then return end

	page = math.max(page, 1);
	page = math.min(page, self:getMaxPage());
	if page == self.curPageIdx_ then return end

	self:gotoPage(page, checkbool(bSmooth));
end

--[[ 设置旧页变量，以便判断 ]]
function XgPageView:setPrePageIdx_()
	self._prePageIdx_ = self.curPageIdx_;
end

--[[ 获取当前页索引 ]]
function XgPageView:getCurPage()
	return self.curPageIdx_;
end

--[[ 获取最大页索引 ]]
function XgPageView:getMaxPage()
	return table.nums(self.pages_);
end

return XgPageView;
