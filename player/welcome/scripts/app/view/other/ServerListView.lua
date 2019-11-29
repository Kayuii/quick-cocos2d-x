--[[
	服务器列表
	@Author: ccb
	@Date: 2018-03-27
]]
local ServerListView = class("ServerListView", function()
	local node = display.newNode();
	return node;
end);

local XConstants = {
	SOCKET_SERVER_IP_0 = "192.168.200.209",
	SOCKET_SERVER_IP_1 = "aipoker.facepoker.cc",
	SOCKET_SERVER_IP_2 = "192.168.5.95",
	SOCKET_SERVER_IP_3 = "192.168.200.235",
	SOCKET_SERVER_IP_5 = "120.78.185.125", 		-- 审核正式 39.108.94.147 新加坡加速节点 47.74.184.128  47.254.23.10
	SOCKET_SERVER_IP_6 = "192.168.200.112", 	-- 沛迎
	SOCKET_SERVER_IP_7 = "192.168.5.80", 		-- TT
};

ServerListView.SER_CFG = {
	{name = "国服", ip = XConstants.SOCKET_SERVER_IP_1, wxip = XConstants.SERVER_ADDR_1},
	{name = "内网", ip = XConstants.SOCKET_SERVER_IP_2, wxip = XConstants.SERVER_ADDR_2},
	{name = "如意", ip = XConstants.SOCKET_SERVER_IP_3, wxip = XConstants.SERVER_ADDR_6}, 
	{name = "荣翼", ip = XConstants.SOCKET_SERVER_IP_0, wxip = XConstants.SERVER_ADDR_4},
	{name = "沛迎", ip = XConstants.SOCKET_SERVER_IP_6, wxip = XConstants.SERVER_ADDR_6},
	{name = "编译", ip = "192.168.200.83", wxip = "192.168.5.48"},

};

ServerListView.AC_DLY_HIDE_CONT = 0x1008611;
ServerListView.AC_CLD_FADEINOUT = 0x1008612;

--[[ 构造方法 ]]
function ServerListView:ctor(ops)
	try{
		function()
			self._ops = ops or {};
			self._size = self._ops.size;
			self._bHideAreaShow = false;
			self._curIdx = xg.localData:getCurSocketIpIdx() or 1;
			self:init();
		end
	};
end

--[[ 初始化 ]]
function ServerListView:init()
	self._size = cc.size(display.width, 90 + xg.fitPolicy.TOP_HEIGHT_EX);

	local conNode = display.newNode();
	conNode:setContentSize(self._size);
	conNode:align(display.CENTER_TOP, display.cx, display.height);
	conNode:addTo(self, 1);
	self._conNode = conNode;

	local bg = display.newScale9Sprite("ui/discover/descirbe_btn_tab_nor.png");
	bg:setContentSize(self._size);
	bg:align(display.CENTER, self._size.width/2, self._size.height/2);
	bg:addTo(conNode);

	local btnCfg = {};
	for k, v in ipairs(self.SER_CFG) do
		table.insert(btnCfg, {
			images = {
				normal = "ui/discover/descirbe_btn_tab_nor.png",
				pressed = "ui/discover/descirbe_btn_tab_sld.png",
			},
			text = {
				text = v.name,
				color = xg.color.gray,
				seld_color = xg.color.white,
			},
		});
	end
	local opstion = {
		data = btnCfg,
		index = self._curIdx,
		class = "tabBarEx",
		itemSize = cc.size(self._size.width/#btnCfg, 90),
		size = cc.size(self._size.width, 90),
		direction = xg.ui.TAB_BAR_DIR.HOR,
		showItemBg = false,
	};
	local bar = xg.ui:newTabBar(opstion);
	bar:addEventListener(bar.EVENT_ON_TAB_CLICKED, function(event)
		local bFstSel = event and event.b_fstsel;
		if not bFstSel then
			xg.audio:playNorBtnSound();
		end
		self:onMenuClicked(event.index, not bFstSel);
	end);
	bar:align(display.CENTER_BOTTOM, self._size.width/2, 0);
	bar:addTo(conNode);
	self._serBar = bar;

	-- 隐藏区域
	local hideNode = display.newNode();
	hideNode:setContentSize(cc.size(360, 50));
	hideNode:align(display.CENTER_TOP, self._size.width/2, -30);
	hideNode:swallowTouch(false);
	hideNode:onClicked(function()
		if self._hideNode and self._hideNode:getNumberOfRunningActions() == 0 then
			self:showHideCont(not self._bHideAreaShow);
		end
	end);
	hideNode:addTo(conNode);
	self._hideNode = hideNode;
end

--[[ 显示隐藏区域内容 ]]
function ServerListView:showHideCont(flag)
	flag = checkbool(flag);
	if flag == self._bHideAreaShow then
		self:showSldIp(flag);
		self:showGuanduSwitch(flag);
		if flag then
			self:dlyHideContArea();
		end
		return;
	end

	self:showSldIp(true);
	self:showGuanduSwitch(true);

	local tk = 1;
	local node = self._hideNode;
	local children = node:getChildren();
	local childCt = node:getChildrenCount();
	for i = 1, childCt do
		local childNode = children:objectAtIndex(i - 1);
		if childNode then
			childNode:setVisible(true);
			childNode:setOpacity(flag and 0 or 255);
			childNode:stopActionByTag(self.AC_CLD_FADEINOUT);
			childNode:runAction(cca.seqEx({
				(flag and cca.fadeIn(tk) or cca.fadeOut(tk)),
				cca.callFunc(function()
					childNode:setVisible(flag);
				end),
			})):setTag(self.AC_CLD_FADEINOUT);
		end
	end
	node:stopActionByTag(self.AC_DLY_HIDE_CONT);
	if flag then
		self:dlyHideContArea();
	else
		node:runAction(cca.delay(tk));
	end

	self._bHideAreaShow = flag;
end

--[[ 延迟隐藏区域内容 ]]
function ServerListView:dlyHideContArea()
	local node = self._hideNode;
	if not node then return end

	node:stopActionByTag(self.AC_DLY_HIDE_CONT);
	node:runAction(cca.seqEx({
		cca.delay(5),
		cca.callFunc(function()
			self:showHideCont(not self._bHideAreaShow);
		end),
	})):setTag(self.AC_DLY_HIDE_CONT);
end

--[[ 显示选择的ip ]]
function ServerListView:showSldIp(flag, ip)
	ip = ip or ServerIp;
	flag = checkbool(flag);
	local lbIp = self._lbIp;
	if flag and not lbIp then
		local node = self._hideNode;
		local nodeSize = node:getContentSize();
		lbIp = xg.ui:newLabel({
			text = ip or "",
			color = xg.color.white,
		});
		lbIp:align(display.CENTER_TOP, nodeSize.width/2, nodeSize.height);
		lbIp:addTo(node);
		self._lbIp = lbIp;
	end
	if lbIp then
		G_FUNC_SWITCH = G_FUNC_SWITCH or {};
		local falg = G_FUNC_SWITCH.GUANDU_SDK;
		if falg then
			local guanduSdkMgr = xg.user:getMgr("guanduSdkMgr");
			ip = guanduSdkMgr and guanduSdkMgr.ORG_HOST;
			ip = string.format("ᗨ %s ᗨ", ip or "Guandu Open");
		end
		lbIp:setString(ip and string.format("- %s -", ip) or "");
	end
end

--[[ 显示太极盾开关 ]]
function ServerListView:showGuanduSwitch(flag)
	flag = checkbool(flag);
	local lbGuandu = self._lbGuandu;
	if flag and not lbGuandu then
		local node = self._hideNode;
		local nodeSize = node:getContentSize();
		lbGuandu = xg.ui:newLabel({
			text = "",
			color = xg.color.white,
		});
		lbGuandu:align(display.CENTER_TOP, nodeSize.width/2, nodeSize.height - 30);
		lbGuandu:swallowTouch(false);
		lbGuandu:onClicked(function()
			G_FUNC_SWITCH = G_FUNC_SWITCH or {};
			G_FUNC_SWITCH.GUANDU_SDK = not G_FUNC_SWITCH.GUANDU_SDK;

			local guanduSdkMgr = xg.user:getMgr("guanduSdkMgr");
			if guanduSdkMgr then
				guanduSdkMgr.AT_WORK = G_FUNC_SWITCH.GUANDU_SDK;
			end

			self:showSldIp(self._bHideAreaShow);
			self:showGuanduSwitch(self._bHideAreaShow);
		end);
		lbGuandu:addTo(node);
		self._lbGuandu = lbGuandu;
	end
	if lbGuandu then
		G_FUNC_SWITCH = G_FUNC_SWITCH or {};
		local falg = G_FUNC_SWITCH.GUANDU_SDK;
		lbGuandu:setColor(falg and xg.color.green or xg.color.red);
		lbGuandu:setString(string.format("GuanduSdk:%s", falg and "ON" or "OFF"));
	end
end

--[[ 标签栏选择回调 ]]
function ServerListView:onMenuClicked(idx)
	if not idx then return end

	local cfg = self.SER_CFG[idx];
	if cfg and next(cfg) then
		ServerIp = cfg.ip;
		if type(XConstants) == "table" then
			if cfg.wxip then
				XConstants.SERVER_ADDR = cfg.wxip;
			end
			if cfg.ip then
				XConstants.SOCKET_SERVER_IP = cfg.ip;
			end
		end
	end
	self:showHideCont(self._bHideAreaShow);
	xg.localData:setCurSocketIpIdx(idx);
end

return ServerListView;
