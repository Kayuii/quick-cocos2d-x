--[[
	时间选择器
	@Author: ccb
	@Date: 2017-09-02
	---------------------
]]
local TimeSelector = class("TimeSelector", function(options)
	local node = display.newNode();
	cc(node):addComponent("components.behavior.EventProtocol"):exportMethods();
	return node;
end);

-- 默认列表项大小
TimeSelector.DEF_ITEM_SIZE = cc.size(display.width, 410);

-- 选择事件
TimeSelector.ON_SELECT_EVENT = "TIME_SELECTOR_ON_SELECT";

--[[ 构造函数 ]]
function TimeSelector:ctor(ops)
	self._ops 	= ops or {};
	self._size	= self._ops.size or self.DEF_ITEM_SIZE;
	self._size.height = self._size.height + xg.fitPolicy.BOT_HEIGHT_EX;

	self._date = self._ops.date or os.time();
	self._date_num = self._ops.date_num or 7;
	self._idx_date = self._ops.idx_date or 1;

	self._tagDateInfo = {};
	
	self:init();
end

--[[ 初始化 ]]
function TimeSelector:init()
	self:setContentSize(self._size);

	-- 背景
	local bg = display.newScale9Sprite("ui/texas/texas_bg_toumingdikuang.png");
	bg:setPreferredSize(self._size);
	bg:align(display.CENTER, self._size.width/2, self._size.height/2);
	bg:addTo(self);

	-- 清空文本
	local lb_clear = xg.ui:newLabel({
		text = XTEXT.com_t_clean,
		color = xg.color.blue_t,
	});
	lb_clear:align(display.CENTER, 70, self._size.height - 45);
	lb_clear:addTo(self, 2);

	-- 确定文本
	local lb_confirm = xg.ui:newLabel({
		text = XTEXT.com_confirm,
		color = xg.color.blue_t,
	});
	lb_confirm:align(display.CENTER, self._size.width - 70, self._size.height - 45);
	lb_confirm:swallowTouch(false);
	lb_confirm:onClicked(function()
		local tm = os.time(self._tagDateInfo);
		dump_r(self._tagDateInfo, "#####_tagDateInfo" .. (xg.date.getTimeString(tm, 4)));
	end);
	lb_confirm:addTo(self, 2);

	-- 日期
	local pos = cc.p(80, self._size.height - 150);
	local listSize = cc.size(350, 250);
	local itemSize = cc.size(listSize.width, 50);
	local listPos = cc.p(0, pos.y - listSize.height);

	-- 选择线
	local linePos = cc.p(0, listPos.y + listSize.height/2 + itemSize.height/2);
	local lineSize = cc.size(self._size.width, 1);
	local lineTop = display.newLine(
		{{linePos.x, linePos.y}, {linePos.x + lineSize.width, linePos.y}},
		{borderColor = xg.color.c3b2C4f(xg.color.gray, 200), borderWidth = lineSize.height}
	);
	lineTop:addTo(self, 1);

	linePos.y = linePos.y - itemSize.height;
	local lineBot = display.newLine(
		{{linePos.x, linePos.y}, {linePos.x + lineSize.width, linePos.y}},
		{borderColor = xg.color.c3b2C4f(xg.color.gray, 200), borderWidth = lineSize.height}
	);
	lineBot:addTo(self, 1);

	-- 列表
	local list = xg.ui:newScollView({
		direction = xg.ui.SCROLL_VIEW_DIR.VER,
		viewRect = cc.rect(listPos.x, listPos.y, listSize.width, listSize.height),
		pull_space_h = itemSize.height * 2,
	});
	list:onTouch(handler(self, self.onDateListTouch));
	list:onCreateItem(handler(self, self.newDateItem));
	list:addTo(self);
	self._dateList = list;
	self._dateListPos = listPos;
	self._itemSize = itemSize;

	local hIdx = os.date("%H", self._date) + 1;
	local mIdx = os.date("%M", self._date) + 1;
	self._tagDateInfo.year = os.date("%Y", self._date);
	self._tagDateInfo.month = os.date("%m", self._date);
	self._tagDateInfo.day = os.date("%d", self._date);
	self._tagDateInfo.hour = os.date("%H", self._date);
	self._tagDateInfo.min = os.date("%M", self._date);

	local minData = {};
	for i = 0, 59 do
		table.insert(minData, string.format("%02d", i));
	end
	local CircleSelector = import("app.xgame.base.ui.XgCircleSelector");
	local view = CircleSelector.new({data = minData, sel_idx = mIdx});
	view:align(display.RIGHT_BOTTOM, self._size.width - 50, listPos.y);
	view:addEventListener(view.ON_SELECT_EVENT, function(event)
		if event.idx then
			self._tagDateInfo.min = event.idx - 1;
		end
	end);
	view:addTo(self);

	local hData = {};
	for i = 0, 23 do
		table.insert(hData, string.format("%02d", i));
	end
	local CircleSelector = import("app.xgame.base.ui.XgCircleSelector");
	local view = CircleSelector.new({data = hData, sel_idx = hIdx});
	view:align(display.RIGHT_BOTTOM, self._size.width - 50 - 110, listPos.y);
	view:addEventListener(view.ON_SELECT_EVENT, function(event)
		if event.idx then
			self._tagDateInfo.hour = event.idx - 1;
		end
	end);
	view:addTo(self);

	local date = xg.date.getInRowDays(os.time(), self._date_num);
	list:setDataAndReload(date, nil, true);
	self._dateData = date;

	self._idx_date = self:getYMDIdx(self._date);
	self:updateDateSelect(self._idx_date);
end

--[[ 更新日期选择项 ]]
function TimeSelector:updateDateSelect(idx)
	if not self._dateList then return end

	self._dateList:scrollTo(0, -1 * (self._date_num - idx - 1) * self._itemSize.height);
	self:doCorrectiveItems();
end

--[[ 创建日期列表项 ]]
function TimeSelector:newDateItem(event)
	-- 创建列表项
	local item = event.item;
	local node = event.node;
	local data = event.data;

	local itemSize = self._itemSize;
	item:setItemSize(itemSize.width, itemSize.height);
	node:setContentSize(itemSize);
	node:align(display.CENTER, itemSize.width/2, itemSize.height/2);
	item._itemcont = node;

	local label = xg.ui:newLabel({
		text = xg.date.getTimeString(data, xg.date.I2S_TYPE.MDW),
		size = xg.font.size.nor,
		color = xg.color.white,
	});
	label:align(display.LEFT_CENTER, 80, itemSize.height/2);
	label:addTo(node);
	node._label = label;

	node:setScaleY(0.6);
	label:setOpacity(100);
end

--[[ 日期列表触摸监听 ]]
function TimeSelector:onDateListTouch(event)
	local itemSize = self._itemSize;

	-- 矫正
	local function doCorrective(y)
		local idx = math.floor(y/itemSize.height + 0.5);
		return idx * itemSize.height;
	end

	-- 边界检测
	local function doBorderCheck(y)
		local r1 = itemSize.height * 2;
		local r2 = -itemSize.height * (self._date_num - 2);
		if y >= r1 then
			y = r1;
		elseif y <= r2 then
			y = r2;
		end
		return y;
	end

	local ename = event.name;
	local tagList = event.listView;
	local scrollNode = tagList and tagList.scrollNode;
	if ename == "began" or ename == "moved" or ename == "ended" then
		scrollNode:setPositionY(doBorderCheck(scrollNode:getPositionY()));
	end
	if ename == "began" then
		self._touchposy = {event.y};
		scrollNode:stopActionByTag(0x100001);
		scrollNode:stopActionByTag(0x100002);
	end
	if ename == "moved" then
		self._touchposy = self._touchposy or {};
		table.insert(self._touchposy, event.y);
		self:doCorrectiveItems();
	end
	if ename == "ended" then
		if scrollNode then
			scrollNode:stopAllActions();
		end
		local yn = #self._touchposy;
		local suby = self._touchposy[yn] - self._touchposy[1];
		if yn <= 30 and math.abs(suby) > itemSize.height * 2 then
			local tagy = doBorderCheck(scrollNode:getPositionY() + suby);
			tagy = doCorrective(tagy);

			local tk = 0.5;
			local ac = cca.spawnEx({
				cca.sineOut(cca.moveTo(tk, scrollNode:getPositionX(), tagy), 5),
				cca.rep(cca.seqEx({
					cca.callFunc(handler(self, self.doCorrectiveItems)),
					cca.delay(tk/10),
				}), 10),
			});
			ac:setTag(0x100002);
			scrollNode:stopActionByTag(0x100002);
			scrollNode:runAction(ac);
		else
			local tagy = doBorderCheck(scrollNode:getPositionY());
			tagy = doCorrective(tagy);
			local ac = cca.seqEx({
				cca.moveTo(0.1, scrollNode:getPositionX(), tagy),
				cca.callFunc(handler(self, self.doCorrectiveItems)),
			});
			ac:setTag(0x100001);
			scrollNode:stopActionByTag(0x100001);
			scrollNode:runAction(ac);
		end
	end

	if ename == "clicked" and event.itemPos and event.itemPos ~= self._idx_date then
		self:updateDateSelect(event.itemPos);
	end
end

--[[ 矫正列表项 ]]
function TimeSelector:doCorrectiveItems()
	local tagList = self._dateList;
	local listSize = tagList:getListSize();
	local centery = listSize.height/2;
	for i,v in ipairs(tagList.items_) do
		local box = v:getCascadeBoundingBox();
		local tmpy = box.y - self._dateListPos.y - self:getPositionY();
		local idx = math.ceil((tmpy - listSize.height/2)/self._itemSize.height);

		local contNode = v._itemcont;
		if contNode then
			contNode:setVisible(true);
			if math.abs(idx) == 0 then
				self._idx_date = i;

				local seltm = self._dateData[self._idx_date];
				if seltm then
					self._tagDateInfo.year = os.date("%Y", seltm);
					self._tagDateInfo.month = os.date("%m", seltm);
					self._tagDateInfo.day = os.date("%d", seltm);
				end
				contNode:setScale(1.1);
				contNode._label:setOpacity(255);
			elseif math.abs(idx) == 1 then
				contNode:setScaleX(1);
				contNode:setScaleY(0.8);
				contNode._label:setOpacity(175);
			elseif math.abs(idx) == 2 then
				contNode:setScaleX(1);
				contNode:setScaleY(0.6);
				contNode._label:setOpacity(100);
			else
				contNode:setVisible(false);
			end
		end
	end
end

--[[ 获取年月日索引 ]]
function TimeSelector:getYMDIdx(date)
	local idx = self._idx_date;
	for k,v in ipairs(self._dateData) do
		if os.date("%Y", v) == os.date("%Y", date)
		and os.date("%m", v) == os.date("%m", date)
		and os.date("%d", v) == os.date("%d", date) then
			idx = k;
			break;
		end
	end
	return idx;
end

return TimeSelector;
