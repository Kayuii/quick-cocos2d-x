--[[
	广播
	@Author: ccb
	@Date: 2018-03-20
]]
local CURRENT_MODULE_NAME = ...;
local BroadcastView = class("BroadcastView", function()
	local node = display.newNode();
	node:setNodeEventEnabled(true);
	return node;
end);

BroadcastView.DEBUG_MODE = 0; -- 调试模式
BroadcastView.MSG_MOVE_SPEED = 75; -- 文本移动速度
BroadcastView.DEF_SIZE = cc.size(display.width, 44); -- 默认大小

--[[ 构造方法 ]]
function BroadcastView:ctor(ops)
	try{
		function()
			self._ops = ops or {};
			self._data = self._ops.data or {};
			self._isDebug = self._ops.isDebug or self.DEBUG_MODE;
			self:init();
		end
	};
end

--[[ 初始化 ]]
function BroadcastView:init()
	self._bPlay = true;
	self._size = self.DEF_SIZE;
end

--[[ 进入父节点 ]]
function BroadcastView:onEnter()
	self:createBase();

	if checkint(self._isDebug) == 1 then
		local box = cc.LayerColor:create(xg.color.c3b2C4b(xg.color.green, 100), self._size.width, self._size.height);
		box:addTo(self, -1);
	end

	self:play();
end

--[[ 创建基础内容 ]]
function BroadcastView:createBase()
	self:setContentSize(self._size);
	
	-- 背景
	local spBg = display.newScale9Sprite("ui/jackpot/jackpot_bg_paomadeng.png");
	spBg:setContentSize(self._size);
	spBg:align(display.CENTER, self._size.width/2, self._size.height/2);
	spBg:addTo(self);
	
	-- 裁剪节点
	local clipSize = cc.size(self._size.width, self._size.height);
	local clipNode = cc.ClippingRegionNode:create();
	clipNode:setClippingRegion(cc.rect(0, 0, clipSize.width, clipSize.height));
	clipNode:setPosition(cc.p(0, 0));
	clipNode:addTo(self, 1);
	self._clipNode = clipNode;

	-- 消息文本(富文本)
	local richt = xg.ui:newRichText({
		fontSize = xg.font.size.sml,
		fontColor = xg.color.white,
	});
    richt:align(display.LEFT_TOP, clipSize.width, clipSize.height/2);
    richt:addTo(clipNode);
    self._richText = richt;
end

--[[ 播放消息 ]]
function BroadcastView:play()
	self._mnData = self._mnData or {
		{nick = "无主之命", card_type = "四条", room_name = "10-20 130", jp_num = 20000, replay = 1},
		{nick = "8x8xACD", card_type = "皇家同花顺", room_name = "20-40 131", jp_num = 130000, replay = 3},
	};
	local data = self._mnData[1] or {};
	self._bPlay = data and next(data);
	if not self._bPlay then
		-- 缓存不存在消息
		self:onHide();
		return;
	end

	table.remove(self._mnData, 1);
	
	-- 更新裁剪区域及位置
	local clipSize = cc.size(self._size.width, self._size.height);
	self._clipNode:setClippingRegion(cc.rect(0, 0, clipSize.width, clipSize.height));
	self._clipNode:setPositionX(0);
	
	-- 更新消息
	local nick = string.format("<color=XgColor.goldlt size=22>%s</color>", data.nick);
	local cardt = string.format("<color=XgColor.goldlt size=22>%s</color>", data.card_type);
	local cont = string.format('%s在"%s"击中%s获得%s奖池。', nick, data.room_name, cardt, data.jp_num);
	self._richText:setString(cont);
	local richtSz = self._richText:getTextSize();

	self._playIndex = 0;
	self._replayCount = checkint(data.replay or 1);
	self._orgPos = cc.p(self._richText:getPositionX(), clipSize.height/2 + richtSz.height/2);

	self._tagPos = cc.p(0 - richtSz.width, self._orgPos.y);
	self._moveTime = (clipSize.width + richtSz.width)/self.MSG_MOVE_SPEED;
	
	self:onShow();
	self:replay();
end

--[[ 重播 ]]
function BroadcastView:replay()
	self._playIndex = self._playIndex + 1;
	self._richText:setPosition(self._orgPos);

	if self._playIndex > self._replayCount then
		self:play();
		return;
	end
	
	self:moveToSide();
end

--[[ 移动到左侧 ]]
function BroadcastView:moveToSide()
	local acMov = cca.moveTo(self._moveTime, self._tagPos);
	local acFuc = cca.callFunc(handler(self, self.replay));
	local acSeq = cca.seqEx({acMov, acFuc});
	self._richText:runAction(acSeq);
end

--[[ 显示 ]]
function BroadcastView:onShow()
	if not self:isVisible() then
		self:setVisible(true);
	end
end

--[[ 隐藏 ]]
function BroadcastView:onHide()
	self:setVisible(false);
end

--[[ 长时间无消息则重播 ]]
function BroadcastView:replayLongStandby()
	if self._bPlay then return end

	self._mnData = nil;
	self:play();
end

--[[ 清除监听 ]]
function BroadcastView:onCleanup()
	
end

return BroadcastView;
