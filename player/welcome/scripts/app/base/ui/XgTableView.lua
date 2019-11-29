--[[
	整理 XgTableView
	@Author: ccb
	@Date: 2017-09-01
	---------------------
]]
local XgTableView = class("XgTableView", function()
	local node = display.newNode();
	cc(node):addComponent("components.behavior.EventProtocol"):exportMethods();
	return node;
end);

XgTableView.EVENT_PULL_UP = "pull_up";
XgTableView.EVENT_DROP_DOWN = "drop_down";
XgTableView.EVENT_SCROLL = "list_scroll";
XgTableView.EVENT_CELL_TOUCHED = "cell_touch";
XgTableView.EVENT_CELL_AT_INDEX = "cell_at_index";
XgTableView.DEF_SIZE = cc.size(400, 300);
XgTableView.DEF_PULL_SPACE_H = 50;

--[[ 构造函数 ]]
function XgTableView:ctor(options)
	self._ops = options or {};
	self._data = self._ops.data or {};
	self._size = self._ops.size or self.DEF_SIZE;
	self._itemSize = self._ops.item_size or self.DEF_SIZE;
	self._bAutoRestp = self._ops.b_autorestp or nil;
	self._bAutoRestp = (self._bAutoRestp == nil or self._bAutoRestp) and true or false;
	self._cellsizeFunc = self._ops.cellsizeFunc;
	self._pull_space_h = self._ops.pull_space_h or self.DEF_PULL_SPACE_H;

	self:init();
end

--[[ 初始化 ]]
function XgTableView:init()
	self:setContentSize(self._size);

	local tableView = CCTableView:create(self._size);
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown);
	tableView:setDirection(kCCScrollViewDirectionVertical);
	tableView:registerScriptHandler(handler(self, self._listViewHandup), 1001);
	tableView:registerScriptHandler(handler(self, self._listViewScroll), CCScrollView.kScrollViewScroll);
	tableView:registerScriptHandler(handler(self, self._tableCellTouched), CCTableView.kTableCellTouched);
	tableView:registerScriptHandler(handler(self, self._tableCellAtIndex), CCTableView.kTableCellSizeAtIndex);
	tableView:registerScriptHandler(handler(self, self._cellSizeForTable), CCTableView.kTableCellSizeForIndex);
	tableView:registerScriptHandler(handler(self, self._numberOfCellsInTableView), CCTableView.kNumberOfCellsInTableView);
	tableView:setPosition(cc.p(0, 0));
	self:addChild(tableView);
	self._tableview = tableView;
end

--[[ 列表手抬 ]]
function XgTableView:_listViewHandup(event, listView)
	if not listView then return end

	self._bolPullUp = nil;
	self._bolDroupDown = nil;

	-- 处理下拉的时候，原本列表为空的情况
	local data = self._data;
	if not data or not next(data) then
		-- 数据为空时手抬回调
		self:dispatchEvent({name = self.EVENT_CELL_TOUCHED, instance = listView});
		return;
	end

	local minH = listView:minContainerOffset().y
	local offy = listView:getContentOffset().y;

	-- 上滑手抬起回调
	if (minH < 0 and offy > self._pull_space_h)
	or (minH > 0 and (offy - minH) > self._pull_space_h) then
		self._bolPullUp = true;
		self:dispatchEvent({name = self.EVENT_PULL_UP, instance = listView});
	end

	-- 下拉手抬起回调
	if (minH - offy) >= self._pull_space_h then
		self._bolDroupDown = true;
		self:dispatchEvent({name = self.EVENT_DROP_DOWN, instance = listView});
	end
	self._tableviewoffset = listView:getContentOffset();
end

--[[ 列表滚动 ]]
function XgTableView:_listViewScroll(listView)
	if not listView then return end

	local offy = listView:getContentOffset().y;
	local minH = listView:minContainerOffset().y;
	local bDDRef = (minH - offy) >= self._pull_space_h;
	self:dispatchEvent({name = self.EVENT_SCROLL, instance = listView, drop_down_ref = bDDRef});
	self._tableviewoffset = listView:getContentOffset();
end

--[[ 列表项点击回调 ]]
function XgTableView:_tableCellTouched(listView, cell)
	if not listView then return end

    local index = cell:getIdx() + 1;
    local data = self._data[index];
    self:dispatchEvent({name = self.EVENT_CELL_TOUCHED, instance = listView, index = index, data = data, cell = cell});
end

--[ 处于某个列表项 ]
function XgTableView:_tableCellAtIndex(listView, idx)
	if not listView then return end

	local cell = listView:dequeueCell() or CCTableViewCell:new();
	cell:removeAllChildren();

	local index = idx + 1;
	local data = self._data[index];
	self:dispatchEvent({name = self.EVENT_CELL_AT_INDEX, instance = listView, index = index, data = data, cell = cell});

	return cell;
end

--[[ 列表项高宽 ]]
function XgTableView:_cellSizeForTable(listView, idx)
	if not listView then return end

	if self._cellsizeFunc and type(self._cellsizeFunc) == "function" then
		local index = idx + 1;
		local data = self._data;
		local h, w = self._cellsizeFunc(data[index], index);
		return h or 0, w or 0;
	else
		return self._itemSize.height, self._itemSize.width;
	end
end

--[[ 列表项个数 ]]
function XgTableView:_numberOfCellsInTableView(listView)
	if not listView then return end

	local num = 0;
	local data = self._data;
	if self._cellnumFunc and type(self._cellnumFunc) == "function" then
		num = self._cellnumFunc(data);
	else
		if data and next(data) then
			num = #data;
		end
	end

	return num;
end

--[[ 重新加载数据 ]]
function XgTableView:reloadData(data)
	self._data = data or self._data;

	local tablev = self._tableview;
	local preOff = self._tableviewoffset;
	local preMinH = tablev:minContainerOffset().y;
	tablev:getContainer():stopAllActions();
	tablev:reloadData();

	if self._bAutoRestp then
		local minH = tablev:minContainerOffset().y;
		preOff = preOff or cc.p(0, minH);
		preOff.y = (minH >= 0 or preMinH >= 0) and minH or preOff.y;
		preOff.y = (minH < 0 and preMinH < 0) and math.min(minH + preOff.y - preMinH, 0) or preOff.y;
		preOff.y = self._bolDroupDown and minH or preOff.y;
		tablev:setContentOffset(preOff);
		self._tableviewoffset = preOff;
	end

	self._bolPullUp = nil;
	self._bolDroupDown = nil;
end

--[[ 获取数据 ]]
function XgTableView:getData()
	return self._data;
end

return XgTableView;
