--[[
	MainEntryHelp 主入口帮助类
	@Author: ccb
	@Date: 2018-03-05
]]
local MainEntryHelp = {};
MainEntryHelp.INSTANCE = nil;
MainEntryHelp.SERVER_IP_BK = "aipoker.facepoker.cc";

local VER_CODE_KEY = "current-version-code";
local CONSOLE_LOG_CATCH_ENABLE = "CONSOLE_LOG_CATCH_ENABLE";
local fileUtils = CCFileUtils:sharedFileUtils();
local userDefUtil = CCUserDefault:sharedUserDefault();

--[[ 构造方法 ]]
function MainEntryHelp:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;

	return o;
end

--[[ RunApp ]]
function MainEntryHelp:doRunApp()

	-- 重设print函数，用于收集日志
	g_old_print = print;
	print = function(...)
		if self:getConsoleLogCatch() then
			local logUtil = self:getLogUtilIns();
			if logUtil then
				logUtil:addConsoleMsg(...);
			end
		end

		if G_FUNC_SWITCH and G_FUNC_SWITCH.CTRL_PRINT then
			-- release不打印日志
			if g_old_print and type(g_old_print) == "function" then
				g_old_print(...);
			end
		end
	end

	if g_ISDEBUG then
		-- Debug下设置本地版本号
		self:setLocalVerCode(DEBUG_VER_CODE);
	end

	CCLuaLoadChunksFromZIP("framework_precompiled.zip");
	local target = self:getPlatformTag();
	if target == kTargetIphone or target == kTargetIpad then
		if g_HOTUPDATE_ENABLE then
			CCLuaLoadChunksFromZIP("game.zip");
		end
		self:loadXgConfig4App();
		require("config");
		require("framework.init");
		require("framework.shortcodes");
		require("framework.cc.init");
		require "lfs";
		self:getFitPolicy():displaySetting();
		self:loadEventDispatcher();

		if g_HOTUPDATE_ENABLE then
			CCLuaLoadChunksFromZIP("update.zip");
			self:checkIfiosReview();
		else
			self:checkIfiosReview();
			require("app.MyApp").new():run();
			return;
		end
	else
		g_HOTUPDATE_ENABLE = true;
		CCLuaLoadChunksFromZIP("game.zip");
		self:loadXgConfig4App();
		require("config");
		require("framework.init");
		require("framework.shortcodes");
		require("framework.cc.init");
		require("lfs");
		require("app.xgame.base.XgInit");
		require("app.hall.init.frameinit");
		self:getFitPolicy():displaySetting();

		self:loadEventDispatcher();

		-- 播放mp4
		if not g_isFirstPlayMP4 then
			-- device.playVideo();
			g_isFirstPlayMP4 = true;
		end
		CCLuaLoadChunksFromZIP("update.zip");

		if g_HOTUPDATE_ENABLE then
			self:getServerIp();
		else
			require("app.MyApp").new():run();
		end
	end

	xpcall(function()
		self:loadXgConfig4App();
		local director = CCDirector:sharedDirector();
		if target == kTargetIphone or target == kTargetIpad then
			director:runWithScene(require("UpdateScene").new());
		else
			if g_HOTUPDATE_ENABLE then
				-- 延时操作, 为了先播放MP4
				scheduler.performWithDelayGlobal(function()
					director:runWithScene(require("AndroidUpdateScene").new());
				end, 0.5);
			end
		end
	end, __G__TRACKBACK__);
end

--[[ 加载配置 ]]
function MainEntryHelp:loadXgConfig4App()
	package.loaded["app.xgConfig_debug"] = nil;
	package.loaded["app.xgConfig_release"] = nil;

	-- 加载配置
	if XG_CONFIG_DEBUG then
		require("app.xgConfig_debug");
	else
		require("app.xgConfig_release");
	end
end

--[[ 设置本地版本号 ]]
function MainEntryHelp:setLocalVerCode(ver)
	if not ver or ver == "" then return end
	userDefUtil:setStringForKey(VER_CODE_KEY, ver);
	userDefUtil:flush();
end

--[[ 获取本地版本号 ]]
function MainEntryHelp:getLocalVerCode()
	local ver = userDefUtil:getStringForKey(VER_CODE_KEY);
	return ver;
end

--[[ 设置控制台日志是否可捕获 ]]
function MainEntryHelp:setConsoleLogCatch(flag)
	if type(flag) == "boolean" then
		flag = flag and 1 or 0;
	end
	flag = flag or 0;

	userDefUtil:setIntegerForKey(CONSOLE_LOG_CATCH_ENABLE, flag);
	userDefUtil:flush();
end

--[[ 获取控制台日志是否可捕获 ]]
function MainEntryHelp:getConsoleLogCatch()
	local flag = userDefUtil:getIntegerForKey(CONSOLE_LOG_CATCH_ENABLE, 0);
	return flag == 1;
end

--[[ 获取平台标识 ]]
function MainEntryHelp:getPlatformTag()
	local application = CCApplication:sharedApplication();
	local target = application:getTargetPlatform();
	return target;
end

--[[ 获取bundleid ]]
function MainEntryHelp:getBundleId()
	local util = self:getPlatformUtilIns();
	return util and util:getBundleId() or "";
end

--[[ 获取平台版本号 ]]
function MainEntryHelp:getCurrentVersion()
	local util = self:getPlatformUtilIns();
	return util and util:getBundleVersion() or nil;
end

--[[ 是否是海外包 ]]
function MainEntryHelp:bolAbroadApp()
	local util = self:getPlatformUtilIns();
	return util and util:isAbroadApp();
end

--[[ 检测是否ios审核中 ]]
function MainEntryHelp:checkIfiosReview()
	local netwUtil = self:getNetwUtilIns();
	if not netwUtil then return end

	netwUtil:checkIfiosReview();
end

--[[ 获取serverIp ]]
function MainEntryHelp:getServerIp(ops)
	local netwUtil = self:getNetwUtilIns();
	if not netwUtil then return end

	netwUtil:getServerIp(ops);
end

--[[ 获取localIp ]]
function MainEntryHelp:getLocalIp(ip, callback)
	local netwUtil = self:getNetwUtilIns();
	if not netwUtil then return end

	netwUtil:getLocalIp(ip, callback);
end

--[[ 上报错误日志 ]]
function MainEntryHelp:postErrLog(msg)
	local logUtil = self:getLogUtilIns();
	if logUtil and type(logUtil.addErrMsg) == "function" then
		logUtil:addErrMsg(msg);
	else
		-- 日志服暂不可用
		local netwUtil = self:getNetwUtilIns();
		if not netwUtil then return end

		netwUtil:sendErrorMsg2Server(msg);
	end
end

--[[ 加载事件派发器 ]]
function MainEntryHelp:loadEventDispatcher()
	local EventDispatcher = require("app.game.douniu.util.EventDispatcher");
	if EventDispatcher and type(EventDispatcher.getInstance) == "function" then
		g_EventDispatcher = EventDispatcher.getInstance();
	end
end

--[[ 获取平台工具实例 ]]
function MainEntryHelp:getPlatformUtilIns()
	local platformUtil = xg and xg.platform;
	if not platformUtil then
		local XgPlatform = require("app.xgame.base.XgPlatform");
		if XgPlatform and type(XgPlatform.getInstance) == "function" then
			platformUtil = XgPlatform:getInstance();
		end
	end
	return platformUtil;
end

--[[ 获取日志工具实例 ]]
function MainEntryHelp:getLogUtilIns()
	local logUtil = xg and xg.logUtil;
	if not logUtil then
		local XgLogUtil = require("app.xgame.base.utils.XgLogUtil");
		if XgLogUtil and type(XgLogUtil.getInstance) == "function" then
			logUtil = XgLogUtil:getInstance();
		end
	end
	return logUtil;
end

--[[ 获取网络模块实例 ]]
function MainEntryHelp:getNetwUtilIns()
	local netwUtil = xg and xg.network;
	if not netwUtil then
		local XgNetwork = require("app.xgame.base.XgNetwork");
		if XgNetwork and type(XgNetwork.getInstance) == "function" then
			netwUtil = XgNetwork:getInstance();
		end
	end
	return netwUtil;
end

--[[ 获取适配策略实例 ]]
function MainEntryHelp:getFitPolicy()
	local fpUtil = xg and xg.fitPolicy;
	if not fpUtil then
		fpUtil = require("app.xgame.base.utils.XgFitPolicy");
	end
	return fpUtil;
end

--[[ 获取资源管理实例 ]]
function MainEntryHelp:getAssetUtil()
	local assetUtil = xg and xg.assetUtil;
	if not assetUtil then
		local XgAssetUtil = require("app.xgame.base.utils.XgAssetUtil");
		if XgAssetUtil and type(XgAssetUtil.getInstance) == "function" then
			assetUtil = XgAssetUtil:getInstance();
		end
	end
	return assetUtil;
end

--[[ 获取UI实例 ]]
function MainEntryHelp:getUiIns()
	local uiIns = xg and xg.ui;
	if not uiIns then
		local XgUi = require("app.xgame.base.ui.XgUi");
		if XgUi and type(XgUi.getInstance) == "function" then
			uiIns = XgUi:getInstance();
		end
	end
	return uiIns;
end

--[[ 获取单例 ]]
function MainEntryHelp:getInstance(...)
	local instance = self.INSTANCE;
	if not instance then
		instance = self:new(...);
		self.INSTANCE = instance;
	end
	return instance;
end

return MainEntryHelp;

