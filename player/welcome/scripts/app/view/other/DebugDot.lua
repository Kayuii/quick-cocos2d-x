--[[
	调试用
	@Author: ccb
	@Date: 2018-03-27
]]
local DebugDot = class("DebugDot", function()
	local node = display.newNode();
	return node;
end);

DebugDot.PN_STATE = {
	OFF = 0,
	ON = 1
};

DebugDot.CON_LIST = {
	{text = "Device Token", tag = "d_t"},
	{text = "Other", tag = "other"},
};

DebugDot.AC_TAG_IDLE = 0x00001;
DebugDot.AC_TAG_OUT_JUMP = 0x00002;
DebugDot.AC_TAG_BACK_JUMP = 0x00003;

DebugDot.CON_ITEM_DISTANCE = 40;

-- 默认大小
DebugDot.DEF_SIZE = cc.size(60, 60);

-- 是否所有游戏场景开启
OPEN_DEBUG_DOT_ALLGSCENE = true;

--[[ 构造方法 ]]
function DebugDot:ctor(options)
	try{
		function()
			self._options 	= options or {};
			self._size 		= self._options.size or self.DEF_SIZE;
			self:init();
		end
	};
end

--[[ 初始化 ]]
function DebugDot:init()

	local baseNode = display.newNode();
	baseNode:setContentSize(self._size);
	baseNode:align(display.CENTER, 0, display.cy);
	baseNode:addTo(self, 1);
	self._baseNode = baseNode;

	local conNode = display.newNode();
	conNode:setContentSize(self._size);
	conNode:align(display.CENTER, self._size.width/2, self._size.height/2);
	conNode:addTo(baseNode, 1);
	self._conNode = conNode;

	conNode:swallowTouch(true);
	conNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onNodeTouch));
	
	local dn = cc.DrawNode:create();
	dn:drawDot(cc.p(self._size.width/2, self._size.height/2), self._size.width/2, xg.color.c3b2C4f(xg.color.black, 125));  
	dn:addTo(conNode);
	self._body = dn;
	
	self._aryEye = {};
	for i = 1, 2 do
		local sp = display.newSprite("ui/home/home_icon_hongdian.png");
		sp:setOpacity(100);
		sp:setScale(0.5);
		sp:align(display.CENTER, self._size.width * 0.6, self._size.height * ((i == 1) and 0.3 or 0.7));
		sp:addTo(conNode);
		self._aryEye[i] = sp;
	end
	
	self:idleAc();
end

--[[ 触摸监听 ]]
function DebugDot:onNodeTouch(event)
	if event.name == "began" then
		self._clicked = event;
		return true;
	elseif event.name == "moved" then
		if self._clicked and getDistance(event, self._clicked) > 20 then
			self._clicked = nil;
		else
			self:dragAc();
			local pos = self:getBorderPos(cc.p(event.x, event.y));
			self._baseNode:setPosition(pos.x, pos.y);
		end
		return true;
	elseif event.name == "ended" then
		if self._clicked then
			self:onClicked();
		else
			self:goBackAc();
		end
	end
end

--[[ 点击 ]]
function DebugDot:onClicked()
	self._bOpen = not self._bOpen;

	if self._bOpen then
		self:outAc();
	else
		self:goBackAc();
	end

	self:createListNode();
	self:createOtherFuncNode();
	self._listNode:setVisible(self._bOpen);
	self._otherFuncNode:setVisible(self._bOpen);
end

--[[ 创建列表 ]]
function DebugDot:createListNode()
	if self._listNode then return end

	local ct = #self.CON_LIST;
	local size = cc.size(250, 0);
	size.height = ct * self.CON_ITEM_DISTANCE;
	size.height = math.min(size.height, 300);

	local node = display.newNode();
	node:setContentSize(size);
	node:swallowTouch(true);
	node:align(display.LEFT_CENTER, self._size.width, self._size.height/2);
	node:addTo(self._baseNode, 0);
	self._listNode = node;

	local listSize = cc.size(size.width, size.height);
	local listPos = cc.p(size.width/2 - listSize.width/2, 0);
    local list = xg.ui:newScollView{
        viewRect = cc.rect(listPos.x, listPos.y, listSize.width, listSize.height),
        direction = xg.ui.SCROLL_VIEW_DIR.VER,
	};
	list:onTouch(handler(self, self.onListTouch));
    list:onCreateItem(handler(self, self.createListItemNode));
    list:addTo(node, 0);
	self._list = list;
	self._listSize = listSize;

	self._list:setDataAndReload(self.CON_LIST, function(a, b)
		return a < b;
	end);
end

--[[ 其他功能项的节点 ]]
function DebugDot:createOtherFuncNode()
	if self._otherFuncNode then return end

	local size = cc.size(85, 155);
	local node = display.newNode();
	node:setContentSize(size);
	node:align(display.CENTER, self._size.width/2, self._size.height/2);
	node:addTo(self._baseNode, 0);
	self._otherFuncNode = node;

	-- 版本
	local pos = cc.p(size.width + 180, 25);
	local ver = "2.2.2";
	if ver then
		local lbVer = xg.ui:newLabel({
			text = string.format("ver:%s", ver),
			size = xg.font.size.xtiny,
			color = xg.color.white,
		});
		lbVer:align(display.RIGHT_CENTER, pos.x, pos.y);
		lbVer:addTo(node);

		pos.x = pos.x - lbVer:getContentSize().width - 10;
	end

	-- 网络状态
	if device.platform ~= "windows" then
		local lbNet = xg.ui:newLabel({
			text = "",
			size = xg.font.size.xtiny,
			color = xg.color.white,
		});
		lbNet:align(display.RIGHT_CENTER, pos.x, pos.y);
		lbNet:addTo(node);

		local ac = cca.seqEx({
			cca.callFunc(function()
				local ary = {[0] = "none", [1] = "wifi", [2] = "3g"};
				local status = network.getInternetConnectionStatus();
				lbNet:setString("net:" .. ary[status]);
			end),
			cca.delay(5),
		});
		ac = cca.repeatForever(ac);
		lbNet:runAction(ac);
	end

	-- 开关按钮
	pos.y = 30;
	pos.x = size.width/2;
	local pm = {
		state = OPEN_DEBUG_DOT_ALLGSCENE and self.PN_STATE.ON or self.PN_STATE.OFF;
		callback = function(state)
			OPEN_DEBUG_DOT_ALLGSCENE = (state == self.PN_STATE.ON);
		end
	};
	local btn = self:createSwitchBtn(pm);
	btn:align(display.CENTER, pos.x, pos.y);
	btn:addTo(node);
end

--[[ 创建列表项 ]]
function DebugDot:createListItemNode(event)
	local item = event.item;
	local node = event.node;
	local data = event.data;
	local index = event.index;
	data.index = index;

	local itemSize = cc.size(self._listSize.width, self.CON_ITEM_DISTANCE);
	item:setItemSize(itemSize.width, itemSize.height)

	local nodeSize = cc.size(itemSize.width, itemSize.height);
	node:setContentSize(nodeSize);
	node:align(display.CENTER, itemSize.width * 0.5, itemSize.height * 0.5);

	if index == 1 then
		local line = display.newLine(
			{{0, nodeSize.height - 2}, {nodeSize.width * 0.75, nodeSize.height - 2}},
			{borderColor = xg.color.c3b2C4f(xg.color.black, 100), borderWidth = 1}
		);
		line:addTo(node);
	end

	local line = display.newLine(
		{{0, 2}, {nodeSize.width * 0.75, 2}},
		{borderColor = xg.color.c3b2C4f(xg.color.black, 100), borderWidth = 1}
	);
	line:addTo(node);

	local title = xg.ui:newLabel({
		text = data.text,
		size = xg.font.size.tiny_ex,
		color = xg.color.goldlt,
	});
	title:align(display.LEFT_CENTER, 10, nodeSize.height/2);
	title:addTo(node, 1);
end

--[[ 列表点击 ]]
function DebugDot:onListTouch(event)
	if event.name ~= "clicked" then return end

	local info = self.CON_LIST[event.itemPos];
	if not info then return end

	local tag = info.tag;
	if tag == "d_t" then
		self:showMsgBox("052dfdc77e6854343083a2564a65a522f2dcbedb6e60c627750df0de245426cf", true);
	end
	if tag == "other" then

	end
end

--[[ 创建开关按钮 ]]
function DebugDot:createSwitchBtn(ops)
	local preState = ops and ops.state;
	preState = preState or self.PN_STATE.OFF;
	local state = newBindTable({
		ON = (preState == self.PN_STATE.ON);
	});

	local btnSize = cc.size(50, 22);
	local base = display.newNode();
	base:setContentSize(btnSize);
	base:setTouchEnabled(true);
	base:onClicked(function()
		state.ON = not state.ON;
		if ops and type(ops.callback) == "function" then
			local n = state.ON and self.PN_STATE.ON or self.PN_STATE.OFF;
			ops.callback(n);
		end
	end);

	local shap = display.newRect(cc.rect(25, 10, btnSize.width, btnSize.height), nil, {
		color = xg.color.c3b2C4f(xg.color.red, 100),
		borderWidth = 0,
	});
	shap:addTo(base);
	
	-- 关按钮
	local offBtn = cc.DrawNode:create();
	offBtn:drawDot(cc.p(10, btnSize.height/2), 8, xg.color.c3b2C4f(xg.color.red, 100));
	offBtn:addTo(base, 2);

	-- 开按钮
	local onBtn = cc.DrawNode:create();
	onBtn:drawDot(cc.p(btnSize.width - 10, btnSize.height/2), 7.5, xg.color.c3b2C4f(xg.color.green, 100));
	onBtn:addTo(base, 2);
	
	-- 关文本
	local offLabel = xg.ui:newLabel({
		text = "OFF",
		size = xg.font.size.xtiny,
		color = xg.color.white,
	});
	offLabel:align(display.CENTER, 36, btnSize.height/2);
	offLabel:addTo(base, 1);
	
	-- 开文本
	local onLabel = xg.ui:newLabel({
		text = "ON",
		size = xg.font.size.xtiny,
		color = xg.color.white,
	});
	onLabel:align(display.CENTER, btnSize.width - offLabel:getPositionX(), offLabel:getPositionY());
	onLabel:addTo(base, 1);
	
	-- 绑定数据
	base:bind(state, "ON", function(node, flag)
		onBtn:setVisible(flag);
		offBtn:setVisible(not flag);
		onLabel:setVisible(flag);
		offLabel:setVisible(not flag);
	end);
	
	return base;
end

--[[ 消息提示框 ]]
function DebugDot:showMsgBox(msg, canCopy)
	if self._msgBox then return end

	local nodeSz = cc.size(400, 300);
	local node = display.newNode();
	node:setContentSize(nodeSz);
	node:align(display.CENTER, display.cx, display.cy);
	node:addTo(self, 99);
	self._msgBox = node;

	local mask = cc.LayerColor:create(xg.color.c3b2C4b(xg.color.black, 75), display.width, display.height);
	mask:setPosition(nodeSz.width/2 - display.cx, nodeSz.height/2 - display.cy);
	mask:swallowTouch(true);
	mask:onClicked(function()
		self._msgBox = nil;
		node:removeSelf();
	end);
	mask:addTo(node);

	local baseNode = cc.LayerColor:create(xg.color.c3b2C4b(xg.color.black, 100), nodeSz.width, nodeSz.height);
	baseNode:addTo(node);

	local contMask = display.newNode();
	contMask:setContentSize(nodeSz);
	contMask:swallowTouch(true);
	contMask:addTo(baseNode);

	local shap = display.newRect(cc.rect(0, 0, nodeSz.width, nodeSz.height), nil, {
		color = xg.color.c3b2C4f(xg.color.black, 200),
		borderWidth = 1,
	});
	shap:align(display.CENTER, nodeSz.width/2, nodeSz.height/2);
	shap:addTo(node);

	local lbCls = xg.ui:newLabel({
		text = "ㄨ",
		size = xg.font.size.big,
		color = xg.color.red,
	});
	lbCls:align(display.CENTER, nodeSz.width - 5, nodeSz.height - 5);
	lbCls:swallowTouch(true);
	lbCls:onClicked(function()
		self._msgBox = nil;
		node:removeSelf();
	end);
	lbCls:addTo(node, 1);

	local lbMsg = xg.ui:newLabel({
		text = msg or "",
		color = xg.color.goldlt,
		align = ui.TEXT_VALIGN_CENTER,
		valign = ui.TEXT_VALIGN_TOP,
		dimensions = cc.size(nodeSz.width - 10, 0),
	});
	lbMsg:align(display.CENTER, nodeSz.width/2, nodeSz.height/2);
	lbMsg:addTo(node);

	if type(canCopy) == "boolean" and canCopy then
		lbMsg:swallowTouch(true);
		lbMsg:onClicked(function()
			device.copylua(msg);
		end);
	end
end

--[[ 待机 ]]
function DebugDot:idleAc()
	local ac = cca.repeatForever(cca.seqEx({
		cca.scaleTo(1.5, 0.9, 1),
		cca.delay(0.5),
		cca.scaleTo(2, 1, 1),
	}));
	ac:setTag(self.AC_TAG_IDLE);
	self._body:stopActionByTag(self.AC_TAG_IDLE);
	self._body:runAction(ac);
	
	for k,v in ipairs(self._aryEye) do
		local ac = cca.repeatForever(cca.seqEx({
			cca.scaleTo(1.5, 0.1, v:getScaleY()),
			cca.delay(0.5),
			cca.scaleTo(2, v:getScaleX(), v:getScaleY()),
		}));
		ac:setTag(self.AC_TAG_IDLE);
		v:stopActionByTag(self.AC_TAG_IDLE);
		v:runAction(ac);
	end

	self._conNode:setTouchEnabled(true);
end

--[[ 抓取 ]]
function DebugDot:dragAc()
	self._conNode:setRotation(-90);
	self._body:setScale(1);
	self._body:stopActionByTag(self.AC_TAG_IDLE);
	for k,v in ipairs(self._aryEye) do
		v:setScale(0.5);
		v:stopActionByTag(self.AC_TAG_IDLE);
	end
end

--[[ 跑出 ]]
function DebugDot:outAc()
	self:dragAc();

	local interW = display.cx/3;
	local pos = self:getBorderPos();
	local tagX = self._size.width/2 + 20;
	tagX = (self:getRunDir() == -1) and tagX or (display.width - tagX * 4);
	local jCt = math.ceil(math.abs(pos.x - tagX)/interW);
	local ac = cca.seqEx({
		cca.jumpTo(0.4 * jCt, tagX, pos.y, 20, jCt),
		cca.callFunc(function()
			self._conNode:setTouchEnabled(true);
		end),
	});
	ac:setTag(self.AC_TAG_BACK_JUMP);
	self._baseNode:stopActionByTag(self.AC_TAG_BACK_JUMP);
	self._baseNode:runAction(ac);
	self._conNode:setTouchEnabled(false);
end

--[[ 跑回 ]]
function DebugDot:goBackAc()
	if self._bOpen then return end

	local interW = display.cx/3;
	local pos = self:getBorderPos();
	local rt = (self:getRunDir() == -1) and 0 or 180;
	local tagX = (self:getRunDir() == -1) and 0 or display.width;
	local jCt = math.ceil(math.abs(pos.x - tagX)/interW);

	local ac = cca.seqEx({
		cca.jumpTo(0.4 * jCt, tagX, pos.y, 30, jCt),
		cca.callFunc(function()
			self._conNode:runAction(cca.rotateTo(0.4, rt));
		end),
		cca.callFunc(handler(self, self.idleAc)),
	});
	ac:setTag(self.AC_TAG_BACK_JUMP);
	self._baseNode:stopActionByTag(self.AC_TAG_BACK_JUMP);
	self._baseNode:runAction(ac);

	self._conNode:setTouchEnabled(false);
end

--[[ 获取跑回的方向 ]]
function DebugDot:getRunDir()
	local curPos = cc.p(self._baseNode:getPosition());
	local dir = curPos.x < display.cx and -1 or 1;
	return dir;
end

--[[ 获取边界坐标 ]]
function DebugDot:getBorderPos(pos)
	local bd = self._size.height/2 + 10;
	local pos = pos or cc.p(self._baseNode:getPosition());
	pos.y = math.max(pos.y, bd);
	pos.y = math.min(pos.y, display.height - bd);
	pos.x = math.max(pos.x, 0);
	pos.x = math.min(pos.x, display.width);
	return pos;
end

return DebugDot;
