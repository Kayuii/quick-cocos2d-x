--[[
	循环滚动的选择器
	@Author: ccb
	@Date: 2017-09-02
	---------------------
]]
local CircleSelector = class("CircleSelector", function()
	local node = display.newNode();
	cc(node):addComponent("components.behavior.EventProtocol"):exportMethods();
	return node;
end);

-- 默认列表项大小
CircleSelector.DEF_ITEM_SIZE = cc.size(110, 250);

-- 选择事件
CircleSelector.ON_SELECT_EVENT = "TIME_SELECTOR_ON_SELECT";

--[[ 构造函数 ]]
function CircleSelector:ctor(ops)
	self._ops = ops or {};
	self._data = self._ops.data or {};
	self._sel_idx = self._ops.sel_idx or 1;
	self._size = self._ops.size or self.DEF_ITEM_SIZE;
	self._itemSize = self._ops.itemSize or cc.size(self._size.width, 50);

	self._items = {};
	self._arrScroll = {};
	
	self:init();
end

--[[ 初始化 ]]
function CircleSelector:init()
	self:setContentSize(self._size);
	self:setTouchEnabled(true);
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onNodeTouch));

	-- 裁剪节点
	local clipSize = cc.size(self._size.width, self._size.height);
	local clipNode = cc.ClippingRegionNode:create();
	clipNode:setClippingRegion(cc.rect(0, 0, clipSize.width, clipSize.height));
	clipNode:setPosition(cc.p(0, 0));
	clipNode:addTo(self, 1);
	self._clipNode = clipNode;

	local scroll1 = self:newScrollNode(1);
	scroll1:align(display.CENTER_BOTTOM, clipSize.width/2, self._itemSize.height * 3 - scroll1:getContentSize().height);
	scroll1:addTo(clipNode);
	self._arrScroll[1] = scroll1;

	local scroll2 = self:newScrollNode(2);
	scroll2:align(display.CENTER_BOTTOM, clipSize.width/2, self._itemSize.height * 3);
	scroll2:addTo(clipNode);
	self._arrScroll[2] = scroll2;

	local tmpIdx = self._sel_idx;
	self._sel_idx = 1;
	self:updateScrollSelect(tmpIdx);
end

--[[ 创建滚动节点 ]]
function CircleSelector:newScrollNode(idx)
	idx = idx or 1;
	local itemSize = self._itemSize;
	local nodeSize = cc.size(itemSize.width, itemSize.height * #(self._data));
	local node = display.newNode();
	node:setContentSize(nodeSize);

	self._items[idx] = {};
	for k,v in ipairs(self._data) do
		local item = display.newNode();
		item:setContentSize(itemSize);
		item:align(display.CENTER, nodeSize.width/2, nodeSize.height - itemSize.height * (k - 1 + 0.5));
		item:addTo(node);

		local label = xg.ui:newLabel({
			text = v,
			size = xg.font.size.nor,
			color = xg.color.white,
		});
		label:align(display.CENTER, itemSize.width/2, itemSize.height/2);
		label:addTo(item);
		item._lbNum = label;
		table.insert(self._items[idx], item);
	end

	return node;
end

--[[ 节点触摸监听 ]]
function CircleSelector:onNodeTouch(event)
	if event.name == "began" then
		local box = self:convertToWorldSpace(cc.p(self:getPosition()));
		if event.y < box.y or event.y > (box.y + self._size.height) then
			return false;
		end

		for k,v in ipairs(self._arrScroll) do
			v:stopActionByTag(0x100001);
			v:stopActionByTag(0x100002);
		end
		self._touchposy = {event.y};
		return true;
	elseif event.name == "moved" then
		local prey = self._touchposy[#self._touchposy];
		local suby = event.y - prey;
		table.insert(self._touchposy, event.y);

		self:updateScrollState(suby);
		self:updateItemsState();
		return true;
	elseif event.name == "ended" then

		local yn = #self._touchposy;
		local suby = self._touchposy[yn] - self._touchposy[1];
		if yn <= 30 and math.abs(suby) > self._itemSize.height * 2 then
			local scrollpos = self:getScrollPos();
			local tagy = scrollpos.y + suby;
			local tagy = self:getCorrectiveY(tagy);
			local suby = tagy - scrollpos.y;

			local tk = 0.5;
			for k,v in ipairs(self._arrScroll) do
				local ac = cca.spawnEx({
					cca.seqEx({
						cca.sineOut(cca.moveTo(tk, v:getPositionX(), v:getPositionY() + suby), 5),
						cca.callFunc(function()
							if k == 1 then
								self:dispatchEvent({name = self.ON_SELECT_EVENT, idx = self._sel_idx});
							end
						end),
					}),
					cca.rep(cca.seqEx({
						cca.callFunc(function()
							if k == 1 then
								self:updateItemsState();
								self:updateScrollState();
							end
						end),
						cca.delay(tk/20),
					}), 20),
				});
				ac:setTag(0x100002);
				v:stopActionByTag(0x100002);
				v:runAction(ac);
			end
		else
			local scrollpos = self:getScrollPos();
			local tagy = self:getCorrectiveY(scrollpos.y);
			local suby = tagy - scrollpos.y;
			for k,v in ipairs(self._arrScroll) do
				local ac = cca.seqEx({
					cca.moveTo(0.1, v:getPositionX(), v:getPositionY() + suby),
					cca.callFunc(function()
						if k == 1 then
							self:updateItemsState();
							self:updateScrollState();
							self:dispatchEvent({name = self.ON_SELECT_EVENT, idx = self._sel_idx});
						end
					end),
				});
				ac:setTag(0x100001);
				v:stopActionByTag(0x100001);
				v:runAction(ac);
			end
		end
	end
end

--[[ 更新滚动节点状态 ]]
function CircleSelector:updateScrollState(suby)
	local tagy, scontH;
	for k,v in ipairs(self._arrScroll) do
		tagy = v:getPositionY() + (suby or 0);
		scontH = v:getContentSize().height;
		v:setPositionY(tagy);
		v:setVisible(tagy >= -scontH and tagy <= self._size.height);
		if not v:isVisible() then
			if tagy >= scontH then
				v:setPositionY(tagy - scontH * 2);
			elseif tagy <= -scontH then
				v:setPositionY(tagy + scontH * 2);
			end
			tagy = v:getPositionY();
			v:setVisible(tagy >= -scontH and tagy <= self._size.height);
		end
	end
end

--[[ 更新项状态 ]]
function CircleSelector:updateItemsState()
	local scrollNode;
	local iSize = self._itemSize;
	for k,v in ipairs(self._items) do
		scrollNode = self._arrScroll[k];
		if scrollNode:isVisible() then
			for idx, it in pairs(v) do
				local box = it:getCascadeBoundingBox();
				local nodePoint = self:convertToNodeSpace(cc.p(box.x, box.y));
				if nodePoint.y <= - iSize.height or nodePoint.y >= iSize.height * 5 then
					it:setVisible(false);
				else
					it:setVisible(true);

					local lbNum = it._lbNum;
					local cidx = math.ceil((nodePoint.y - self._size.height/2)/self._itemSize.height);
					if math.abs(cidx) == 0 then
						self._sel_idx = idx;
						lbNum:setScale(1.1);
						lbNum:setOpacity(255);
					elseif math.abs(cidx) == 1 then
						lbNum:setScaleX(1);
						lbNum:setScaleY(0.8);
						lbNum:setOpacity(175);
					elseif math.abs(cidx) == 2 then
						lbNum:setScaleX(1);
						lbNum:setScaleY(0.65);
						lbNum:setOpacity(100);
					else
						it:setVisible(false);
					end
				end
			end
		end
	end
end

--[[ 更新选择项 ]]
function CircleSelector:updateScrollSelect(idx)
	local tmpIdx = (self._sel_idx - idx);
	local suby = tmpIdx * -self._itemSize.height;
	self:updateScrollState(suby);
	self:updateItemsState();
end

-- 矫正
function CircleSelector:getCorrectiveY(y)
	local idx = math.floor(y/self._itemSize.height + 0.5);
	return idx * self._itemSize.height;
end

-- 获取滚动节点位置
function CircleSelector:getScrollPos()
	local tagpos;
	for k,v in ipairs(self._arrScroll) do
		if v:isVisible() then
			tagpos = cc.p(v:getPositionX(), v:getPositionY());
			break;
		end
	end
	return tagpos;
end

return CircleSelector;
