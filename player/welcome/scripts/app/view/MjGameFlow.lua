--[[
	麻将对局流水
	@Author: bingo
	@Date: 2015-09-25
	------------------
]]
local base = xg.ui:getClass("panelBase");
local MjGameFlow = class("MjGameFlow", base);

--[[ 添加或修改参数 ]]
function MjGameFlow:setExtParams()
	MjGameFlow.super.setExtParams(self);
end

--[[ 创建基础内容 ]]
function MjGameFlow:createBase()
	MjGameFlow.super.createBase(self);
	self:swallowTouch(false);

	local nodeSz = cc.size(613, 333);
	local node = display.newNode();
	node:setContentSize(nodeSz);
	node:align(display.RIGHT_CENTER, self._size.width - 120, self._size.height/2);
	node:addTo(self, 1);
	self._baseNode = node;

	local bg = display.newScale9Sprite("ui/game_majiang/majiang_bg_gongyongtanchuangdi.png");
	bg:setContentSize(nodeSz);
	bg:align(display.CENTER, nodeSz.width/2, nodeSz.height/2);
	bg:swallowTouch(true);
	bg:addTo(node);

	local sptitle = display.newSprite("ui/game_majiang/majiang_biaoti_duijuliushui.png");
	sptitle:align(display.LEFT_TOP, 19, nodeSz.height - 25);
	sptitle:addTo(node);

	local lbTolChip = xg.ui:newLabel({
		text = 0,
		size = xg.font.size.nor,
		color = xg.color.green,
	});
	lbTolChip:align(display.RIGHT_CENTER, nodeSz.width - 82, nodeSz.height - 52);
	lbTolChip:addTo(node);
	self._lbTolChip = lbTolChip;

	local spTolCoin = display.newSprite("ui/game_majiang/majiang_icon_jinbi.png");
	spTolCoin:align(display.RIGHT_CENTER, lbTolChip:getPositionX() - lbTolChip:getContentSize().width - 12, lbTolChip:getPositionY());
	spTolCoin:addTo(node);
	self._spTolCoin = spTolCoin;

	self:addGameFlowList();

	self:setGameFlowListData();
	self:updTotalChip();
end

--[[ 添加流水列表 ]]
function MjGameFlow:addGameFlowList()
	local node = self._baseNode;
	local nodeSz = node:getContentSize();

	local listRect = cc.rect(36, 20, nodeSz.width - 36*2, nodeSz.height - 75 - 20);
	local itemSize = cc.size(listRect.width, 53);
	local list = xg.ui:newTableView({
		size = cc.size(listRect.width, listRect.height),
		item_size = itemSize,
	});
	list:addEventListener(list.EVENT_CELL_AT_INDEX, function(event) -- 创建列表项
		local item, data = event.cell, event.data;
		local node = display.newNode();
		node:setContentSize(itemSize);
		node:align(display.CENTER, itemSize.width/2, itemSize.height/2);
		node:addTo(item);

		local bgSize = cc.size(itemSize.width, itemSize.height - 5);
		local itemBg = display.newScale9Sprite("ui/game_majiang/majiang_bg_liushuidi.png");
		itemBg:setContentSize(bgSize);
		itemBg:align(display.CENTER_TOP, itemSize.width/2, itemSize.height);
		itemBg:addTo(node);

		local lbOpe = xg.ui:newLabel({
			text = data.des,
			size = xg.font.size.nor,
			color = xg.color.black,
		});
		lbOpe:align(display.LEFT_CENTER, 10, bgSize.height/2);
		lbOpe:addTo(itemBg);

		local strh = (data.change > 0) and "+" or "";
		local lbBankrool = xg.ui:newLabel({
			text = strh .. string.convertChipFormat(data.change),
			size = xg.font.size.nor,
			color = data.change > 0 and xg.color.red or xg.color.green,
		});
		lbBankrool:align(display.RIGHT_CENTER, bgSize.width - 45, bgSize.height/2);
		lbBankrool:addTo(itemBg);

		local spCoin = display.newSprite("ui/game_majiang/majiang_icon_jinbi.png");
		spCoin:align(display.RIGHT_CENTER, lbBankrool:getPositionX() - lbBankrool:getContentSize().width - 12, bgSize.height/2);
		spCoin:addTo(itemBg);
	end);
	list:align(display.LEFT_BOTTOM, listRect.x, listRect.y);
	list:addTo(node);
	self._gameFlowList = list;
end

--[[ 设置流水列表数据 ]]
function MjGameFlow:setGameFlowListData(data, bUpd)
	data = data or self:getData() or {};
	self._flowData = data;
	if bUpd == nil or (type(bUpd) == "boolean" and bUpd == true) then
		if self._gameFlowList then
			self._gameFlowList:reloadData(data);
		end
	end
end

function MjGameFlow:updTotalChip()
	local ntol = 0;
	if self._flowData and next(self._flowData) then
		for k,v in ipairs(self._flowData) do
			ntol = ntol + v.change;
		end
	end

	local lbChip, spcoin = self._lbTolChip, self._spTolCoin;
	if lbChip then
		local strh = (ntol > 0) and "+" or "";
		lbChip:setString(strh .. string.convertChipFormat(ntol));
		lbChip:setColor(ntol > 0 and xg.color.red or xg.color.green);
		spcoin:setPositionX(lbChip:getPositionX() - lbChip:getContentSize().width - 12);
	end 
end

function MjGameFlow:getData()
	-- 模拟数据
	math.randomseed(tostring(os.time()):reverse():sub(1, 6));
	local data = {
		{type = 1, change = math.random(0, 200)},
		{type = 2, change = math.random(-200, 0)},
		{type = 3, change = math.random(-100, 100)},
		{type = 4, change = math.random(500, 2000)},
		{type = 5, change = math.random(-1000, 1000)},
	};

	local arrdes = {
		[1] = "首次听牌",
		[2] = "被下雨",
		[3] = "被自摸(平胡)",
		[4] = "自摸(平胡)",
		[5] = "被自摸(清一色)",
	};
	for k,v in ipairs(data) do
		v.des = arrdes[v.type] or "";
	end

	return data;
end

function MjGameFlow:closeView()
	self:removeSelf();
end

--[[ 进入父节点 ]]
function MjGameFlow:onEnter()
	MjGameFlow.super.onEnter(self);
end

return MjGameFlow;
