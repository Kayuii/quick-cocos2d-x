--[[
	User
	@Author: ccb
	@Date: 2017-06-14
]]
local User = class("User");

User.RAW_CH_KEY = {
	MY_CLUB_LIST 		= "my_club_list",
	MIT_HISTORY_DATA 	= "military_history_data",
	AUTH_LIST			= "auth_list",
	AUTH_HISTORY_LIST	= "auth_history_list",
	LOCATION_DATA 		= "location_data",
	DISCOVER_ROOM_LIST 	= "discover_room_list",
	CAPITAL_FLOW_LIST	= "capital_flow_list",
	PAYWAY_DETAIL_LIST	= "payway_detail_list",
};

--[[ 构造 ]]
function User:ctor()
	self:init();
end

--[[ 初始化 ]]
function User:init()
	self._mgrs = {};
	self._mgrPaths = {};

	-- 缓存数据
	self._dataCache = newBindTable({
		redDotInfo = nil, -- 红点信息
		leagueCreditClubs = nil, -- 联盟信用俱乐部列表
		jpLeagueData = nil, -- jackpot联盟数据
		jpRwdRecord = nil, -- jackpot奖励记录
		hallGameMemCt = nil, -- 大厅游戏人数
		hallGameRoomCt = nil, -- 大厅游戏牌局数
		GameTmpCfg = nil, -- 游戏临时配置
	});

	-- 原始缓存数据(指非绑定的缓存数据)
	self._rawDataCache = {
		[self.RAW_CH_KEY.MY_CLUB_LIST] = {}, -- 俱乐部信息
		[self.RAW_CH_KEY.MIT_HISTORY_DATA] = {}, -- 历史战绩快照
		[self.RAW_CH_KEY.AUTH_LIST] = {}, -- 审批数据
		[self.RAW_CH_KEY.AUTH_HISTORY_LIST] = {}, -- 审批历史数据
		[self.RAW_CH_KEY.LOCATION_DATA] = {}, -- 定位信息
		[self.RAW_CH_KEY.DISCOVER_ROOM_LIST] = {}, -- 发现列表数据
		[self.RAW_CH_KEY.CAPITAL_FLOW_LIST] = {}, -- 资金流水列表
		[self.RAW_CH_KEY.PAYWAY_DETAIL_LIST] = {}, -- 支付方式列表
	};

	-- 管理模块
	try{
		function()
			-- 大厅相关管理
			self:addMgr("homeMgr", "app.hall.mgr.HomeMgr");
			-- 俱乐部管理
			self:addMgr("clubMgr", "app.hall.mgr.ClubMgr");
			-- 联盟管理
			self:addMgr("leagueMgr", "app.hall.mgr.LeagueMgr");
			-- 历史数据管理
			self:addMgr("militaryMgr", "app.hall.mgr.MilitaryMgr");
			-- IOS平台相关管理
			self:addMgr("platformMgr4Ios", "app.hall.mgr.PlatformMgr4Ios");

			-- 红点相关
			self:addMgr("redDotMgr", "app.hall.mgr.RedDotMgr");
			-- 发现相关管理
			self:addMgr("discoverMgr", "app.hall.mgr.DiscoverMgr");
			-- 彩池相关
			self:addMgr("jackpotMgr", "app.hall.mgr.JackpotMgr");

			-- 金币场(金花,斗牛等)
			self:addMgr("glodgameMgr", "app.hall.mgr.GlodGameMgr");
			-- 提前结算历史
			self:addMgr("earlysettleMgr", "app.hall.mgr.EarlySettleMgr");

			-- 资金相关
			self:addMgr("capitalMgr", "app.hall.mgr.CapitalMgr");

			--推广员相关
			self:addMgr("AgentMgr", "app.hall.mgr.AgentMgr");

			-- 游戏临时配置
			self:addMgr("gameTmpCfgMgr", "app.hall.mgr.GameTmpCfgMgr");

			-- httpdnsApiHelp管理
			-- self:addMgr("httpDnsApiMgr", "app.hall.mgr.HttpDnsApiMgr");
			
			-- GuanduSdk管理
			self:addMgr("guanduSdkMgr", "app.hall.mgr.GuanduSdkMgr");
		end
	};
end

--[[ 添加管理模块 ]]
function User:addMgr(mgrName, mgrPath)
	mgrName = tostring(mgrName);
	self._mgrPaths[mgrName] = mgrPath;
end

--[[ 获取管理模块 ]]
function User:getMgr(mgrName)
	if self._mgrPaths[mgrName] then
		if not package.loaded[self._mgrPaths[mgrName]] or not self._mgrs[mgrName] then
			try{
				function()
					self._mgrs[mgrName] = import(self._mgrPaths[mgrName]).new();
				end,
				catch = function()
					printf("%s getMgr error.", mgrName);
				end
			};
		end
	end
	return self._mgrs[mgrName];
end

--[[ 判断是非存在某管理模块 ]]
function User:bolExistMgr(mgrName)
	if not mgrName then return end

	if not self._mgrs or not next(self._mgrs) then return end
	if not self._mgrPaths or not next(self._mgrPaths) then return end

	if not package.loaded[self._mgrPaths[mgrName]] then return end
	if not self._mgrs[mgrName] then return end

	return self._mgrs[mgrName];
end

--[[ 清除管理模块 ]]
function User:cleanMgr(mgrName)
	if not self._mgrPaths and not next(self._mgrPaths) then return end

	if not mgrName then
		for k, v in pairs(self._mgrPaths) do
			self:cleanMgr(k);
		end
		self._mgrs = {};
	else
		local mgr = self._mgrs[mgrName];
		local path = self._mgrPaths[mgrName];
		if mgr and path then
			if type(mgr.dtor) == "function" then
				mgr:dtor();
			end
			self._mgrs[mgrName] = nil;
			package.loaded[path] = nil;
		end
	end
end

--[[ 获取缓存数据 ]]
function User:getCacheData(key)
	if not key then return end
	
	return self._dataCache[key];
end

--[[ 更新缓存数据 ]]
function User:updateCacheData(key, data)
	if not key then return end

	if self._dataCache[key] then
		data:updateTo(self._dataCache[key]);
	else
		self._dataCache[key] = data;
	end
end

--[[ 清除缓存 ]]
function User:cleanCacheData(key)
	if not key then return end

	self._dataCache[key] = nil;
end

--[[ 获取原始缓存数据 ]]
function User:getRawCacheData(key)
	if not key then return end

	self._rawDataCache = self._rawDataCache or {};
	self._rawDataCache[key] = self._rawDataCache[key] or {};
	return self._rawDataCache[key];
end

--[[ 清除原始缓存数据 ]]
function User:clearRawCacheData(key)
	key = key or "all";
	if key == "all" then
		self._rawDataCache = nil;
	else
		if self._rawDataCache and self._rawDataCache[key] then
			self._rawDataCache[key] = nil;
		end
	end
end

--[[ 所有管理模块执行实例方法 ]]
function User:callFunc2AllMgr(funckey)
	if not funckey or type(funckey) ~= "string" then return end

	if self._mgrs and next(self._mgrs)
	and self._mgrPaths and next(self._mgrPaths) then
		local mgr, func;
		for k, v in pairs(self._mgrPaths) do
			mgr = self._mgrs[k];
			if mgr then
				func = mgr[funckey];
				if func and type(func) == "function" then
					func(mgr);
				end
			end
		end
	end
end

--[[ 所有管理模块执行类方法 ]]
function User:callClassFunc2AllMgr(funckey)
	if not funckey or type(funckey) ~= "string" then return end

	if self._mgrPaths and next(self._mgrPaths) then
		local mgrClass, func;
		for k, v in pairs(self._mgrPaths) do
			mgrClass = import(v);
			if mgrClass then
				func = mgrClass[funckey];
				if func and type(func) == "function" then
					func();
				end
			end
		end
	end
end

--[[ 切换账号时清除操作 ]]
function User:cleanupOnSwitchAccount()
	self:callFunc2AllMgr("onSwitchAccountCleanup");
end

--[[ 热更前清除操作 ]]
function User:cleanupOnHotUpdBefore()
	self:callFunc2AllMgr("onHotUpdBeforeCleanup");
end

--[[ app启动时检测 ]]
function User:onAppRunCheck()
	self:callClassFunc2AllMgr("onAppRunCheck");
end

--[[ 获取单例 ]]
function User:getInstance(...)
	local instance = self.INSTANCE;
	if not instance then
		instance = self.new(...);
		self.INSTANCE = instance;
	end
	return instance;
end

return User;
