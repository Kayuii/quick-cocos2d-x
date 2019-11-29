--[[
	存储数据到本地
	@Author: ccb
	@Date: 2017-07-10
]]
local TAG = "#####XgLocalData";
local print = print_r or print;
local userdata = CCUserDefault:sharedUserDefault();
local LocalData = {};
LocalData.INSTANCE = nil;

-- 唯一标识
LocalData.KEYS = {
	CUR_IP = "ip",	-- ip
	TIME_STAMP = "time_stamp", -- 时间戳
	TIME_STAMP_EG = "time_stamp_bg", -- 进入后台时间
	CUR_SOCKET_IP_IDX = "SOCKET_IP_IDX", -- 当前socket ip索引(对应选服标签栏)

	LOGIN_WAY = "LoginWay", 	-- 登录方式
	LOG_ACC = "logAcc", 		-- 登录账号
	LOG_PASS = "logPass", 		-- 登录密码
	LOG_NATION = "logNation", 	-- 登录国家
	LOGIN_INFO = "LOGIN_INFO", 	-- 登录信息
	QQ_OPEN_ID = "qq_openId", 	-- QQ openid
	QQ_TOKEN = "qq_token",		-- QQ token
	IS_MEMORY_ACC = "isMemoryAcc", -- 记录账号标识

	CUR_VER_CODE = "current-version-code", -- 当前版本号
	CUR_VER_CODE_POST = "currentVersionCodePost", -- 已上传服务器的当前版本号？
	
	ROOM_CREATE_INFO = "ROOM_CREATE_INFO", -- 创房信息
	ROOM_CREATE_INFO_TEXAS = "ROOM_CREATE_INFO_TEXAS", -- poker创房信息
	TEXAS_ROOM_JOIN_REC_TIME = "TEXAS_ROOM_JOIN_REC_TIME", -- 记录时间
	TEXAS_ROOM_JOIN_REC = "TEXAS_ROOM_JOIN_REC", -- 记录加入某牌局(买入或者报名)
	TEXAS_ROOM_ENTER_REC = "TEXAS_ROOM_ENTER_REC", -- 记录进入某牌局

	USR_SET_IS_SOUND = "isSound", -- 音效设置
	USR_SET_IS_VIBRATE = "isVibrate", 	-- 震动设置
	USR_SET_IS_SHOWMONEY = 'isShowRMB', --货币转换
	USR_SET_RAISE_CONFIRM = "user_set_raise_confirm", -- 自由下注拉杆确认
	USR_MULT_DESK_AUTO_ST = "user_mult_desk_auto_st", -- 多牌桌自动切换
	USR_DEFINED_BET = 'user_defined_bet', --玩家快捷下注设置
	UPD_DEBUG = "update_debug",
};

--[[ 构造方法 ]]
function LocalData:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	
	return o;
end

--[[ 检测是否加密 ]]
function LocalData:checkIsNeedCrypto_(bCrypto)
	return bCrypto ~= nil and type(bCrypto) == "boolean" and bCrypto;
end

--[[ 设置/获取int数据 ]]
function LocalData:setInt(key, value, bCrypto)
	if not key or not value then return end
	if tonumber(value) == nil then
		print(string.format("%s setInt error: set [%s] need a integer value [%s].", TAG, key, value));
		return;
	end

	bCrypto = self:checkIsNeedCrypto_(bCrypto);
	if bCrypto then
		self:setString(key, tostring(value), bCrypto);
	else
		userdata:setIntegerForKey(key, value);
		userdata:flush();
	end
end

function LocalData:getInt(key, default, bCrypto)
	if not key then return end

	bCrypto = self:checkIsNeedCrypto_(bCrypto);
	if bCrypto then
		local value = self:getString(key, default, bCrypto);
		return tonumber(value);
	else
		local value;
		if not default then
			value = userdata:getIntegerForKey(key);
		else
			value = userdata:getIntegerForKey(key, default);
		end
		return value;
	end
end

--[[ 设置/获取bool数据 ]]
function LocalData:setBool(key, value)
	if not key then return end
	if type(value) ~= "boolean" then
		print(string.format("%s setBool error: set [%s] need a boolean value [%s].", TAG, key, tostring(value)));
		return;
	end

	userdata:setBoolForKey(key, value);
	userdata:flush();
end

function LocalData:getBool(key, default)
	if not key then return end

	local value;
	if default == nil or type(default) ~= "boolean" then
		value = userdata:getBoolForKey(key);
	else
		value = userdata:getBoolForKey(key, default);
	end
	return value;
end

--[[ 设置/获取string数据 ]]
function LocalData:setString(key, value, bCrypto)
	if not key or not value then return end

	string.trim = string.trim or function(input)
		input = string.gsub(input, "^[ \t\n\r ]+", "");
		return string.gsub(input, "[ \t\n\r ]+$", "");
	end

	if string.trim(value) == "" then
		print(string.format("%s setString error: set [%s] need a string value [%s].", TAG, key, value));
		return;
	end
	bCrypto = self:checkIsNeedCrypto_(bCrypto);
	if bCrypto then
		key = crypto.encodeBase64(key);
		value = crypto.encodeBase64(value);
	end
	if not key or not value then
		print(string.format("%s setString error: set [%s] need a string value [%s] bCrypto[%s].", TAG, key, value, tostring(bCrypto)));
	end
	userdata:setStringForKey(key, value);
	userdata:flush();
end

function LocalData:getString(key, default, bCrypto)
	if not key then return end
	bCrypto = self:checkIsNeedCrypto_(bCrypto);
	if bCrypto then
		key = crypto.encodeBase64(key);
	end
	if not key then return end

	local value = userdata:getStringForKey(key);
	local prev = clone(value);
	if value and bCrypto then
		value = crypto.decodeBase64(value);
	end
	value = value or default;

	return value;
end

--[[ 设置/获取json数据 ]]
function LocalData:setJsonData(key, value, bCrypto)
	if not key or not value then return end

	self:setString(key, json.encode(value), bCrypto);
end

function LocalData:getJsonData(key, bCrypto)
	if not key then return end
	local data = self:getString(key, nil, bCrypto);
	if data and data ~= "" then
		data = json.decode(data);
	else
		data = {};
	end
	return data;
end

--[[ 设置/获取当前版本号 ]]
function LocalData:setCurVerCode(value)
	self:setString(self.KEYS.CUR_VER_CODE, value);
end

function LocalData:getCurVerCode()
	return self:getString(self.KEYS.CUR_VER_CODE);
end

--[[ 设置/获取已上传服务器的当前版本号 ]]
function LocalData:setCurVerCodePost(value)
	self:setString(self.KEYS.CUR_VER_CODE_POST, value);
end

function LocalData:getCurVerCodePost()
	return self:getString(self.KEYS.CUR_VER_CODE_POST);
end

--[[ 设置/获取当前IP ]]
function LocalData:setCurIp(ip)
	self:setString(self.KEYS.CUR_IP, ip);
end

function LocalData:getCurIp()
	return self:getString(self.KEYS.CUR_IP, "127.0.0.1");
end

--[[ 设置/获取QQ openid ]]
function LocalData:setQQOpenIp(id)
	self:setString(self.KEYS.QQ_OPEN_ID, id);
end

function LocalData:getQQOpenIp()
	return self:getString(self.KEYS.QQ_OPEN_ID);
end

--[[ 设置/获取QQ token ]]
function LocalData:setQQToken(token)
	self:setString(self.KEYS.QQ_TOKEN, token);
end

function LocalData:getQQToken(def)
	return self:getString(self.KEYS.QQ_TOKEN, def);
end

--[[ 设置/获取socket ip 索引 ]]
function LocalData:setCurSocketIpIdx(idx)
	self:setInt(self.KEYS.CUR_SOCKET_IP_IDX, idx);
end

function LocalData:getCurSocketIpIdx()
	return self:getInt(self.KEYS.CUR_SOCKET_IP_IDX, 1);
end

--[[ 设置/获取时间戳 ]]
function LocalData:setTimeStamp(value)
	if not value then return end

	self:setInt(self.KEYS.TIME_STAMP, value);
end

function LocalData:getTimeStamp()
	return self:getInt(self.KEYS.TIME_STAMP, 0);
end

--[[ 设置/获取进入后台时间戳 ]]
function LocalData:setEGTimeStamp(value)
	if not value then return end

	self:setInt(self.KEYS.TIME_STAMP_EG, value);
end

function LocalData:getEGTimeStamp()
	return self:getInt(self.KEYS.TIME_STAMP_EG, 0);
end

--[[ 设置/获取登录方式 ]]
function LocalData:setLoginWay(value)
	self:setInt(self.KEYS.LOGIN_WAY, value);
end

function LocalData:getLoginWay(def)
	return self:getInt(self.KEYS.LOGIN_WAY, def);
end

--[[ 设置/获取账号信息 ]]
function LocalData:setLoginInfo(info)
	if not info or type(info) ~= "table" then return end

	local preData = self:getLoginInfo();
	table.merge(preData, info);
	self:setJsonData(self.KEYS.LOGIN_INFO, preData, true);
end

function LocalData:getLoginInfo()
	return self:getJsonData(self.KEYS.LOGIN_INFO, true);
end

--[[ 设置/获取登录账号 ]]
function LocalData:setLogAcc(acc)
	self:setString(self.KEYS.LOG_ACC, acc, true);
end

function LocalData:getLogAcc()
	return self:getString(self.KEYS.LOG_ACC, nil, true);
end

--[[ 设置/获取登录密码 ]]
function LocalData:setLogPassw(pw)
	self:setString(self.KEYS.LOG_PASS, pw, true);
end

function LocalData:getLogPassw()
	return self:getString(self.KEYS.LOG_PASS, nil, true);
end

--[[ 设置/获取登录国家 ]]
function LocalData:setLogNation(nt)
	self:setString(self.KEYS.LOG_NATION, nt, true);
end

function LocalData:getLogNation()
	return self:getString(self.KEYS.LOG_NATION, nil, true);
end

--[[ 设置获取登录信息 ]]
function LocalData:setLoginInfoEx(acc, pwd, nation)
	self:setLogAcc(acc);
	self:setLogPassw(pwd);
	self:setLogNation(nation);
end

function LocalData:getLoginInfoEx()
	return self:getLogAcc(), self:getLogPassw(), self:getLogNation();
end

--[[ 设置是否开启音效 ]]
function LocalData:setIsSound(vl)
	if type(vl) == "number" then
		vl = (vl ~= 0);
	end
	self:setBool(self.KEYS.USR_SET_IS_SOUND, vl);
end

--[[ 获取是否开启音效 ]]
function LocalData:getIsSound()
	local vl = self:getBool(self.KEYS.USR_SET_IS_SOUND, true);
	return vl;
end

--[[ 设置是否开启震动 ]]
function LocalData:setIsVibrate(vl)
	if type(vl) == "number" then
		vl = (vl ~= 0);
	end
	self:setBool(self.KEYS.USR_SET_IS_VIBRATE, vl);
end

--[[ 获取是否开启震动 ]]
function LocalData:getIsVibrate()
	local vl = self:getBool(self.KEYS.USR_SET_IS_VIBRATE, false);
	return vl;
end


--[[ 设置汇率转换 ]]
function LocalData:setIsShowMoney(vl)
	if type(vl) == "number" then
		vl = (vl ~= 0);
	end
	self:setBool(self.KEYS.USR_SET_IS_SHOWMONEY, vl);
end

--[[ 获取汇率 ]]
function LocalData:getIsShowMoney()
	local vl = self:getBool(self.KEYS.USR_SET_IS_SHOWMONEY, false);
	return vl;
end

--[[ 设置／获取创房设置 ]]
function LocalData:setCreateRoomInfo(idx, info)
	if not info or type(info) ~= "table" then return end
	local key = string.format("%s_%s", self.KEYS.ROOM_CREATE_INFO, idx);
	self:setJsonData(key, info, true);
end

function LocalData:getCreateRoomInfo(idx)
	local key = string.format("%s_%s", self.KEYS.ROOM_CREATE_INFO, idx);
	return self:getJsonData(key, true);
end

--[[ 设置／获取创房设置 ]]
function LocalData:setTexasCreateRoomInfo(idx, info)
	if not info or type(info) ~= "table" then return end
	local key = string.format("%s_%s", self.KEYS.ROOM_CREATE_INFO_TEXAS, idx);
	self:setJsonData(key, info, true);
end

function LocalData:getTexasCreateRoomInfo(idx)
	local key = string.format("%s_%s", self.KEYS.ROOM_CREATE_INFO_TEXAS, idx);
	return self:getJsonData(key, true);
end

--[[ 设置／获取加入牌局的记录 ]]
function LocalData:setTexasRoomJoinRec(tb)
	if not tb or type(tb) ~= "table" then return end
	
	self:setJsonData(self.KEYS.TEXAS_ROOM_JOIN_REC, tb, true);
end

function LocalData:getTexasRoomJoinRec()
	return self:getJsonData(self.KEYS.TEXAS_ROOM_JOIN_REC, true);
end

--[[ 设置／获取进入牌局的记录 ]]
function LocalData:setTexasRoomEnterRec(tb)
	if not tb or type(tb) ~= "table" then return end
	
	self:setJsonData(self.KEYS.TEXAS_ROOM_ENTER_REC, tb, true);
end

function LocalData:getTexasRoomEnterRec()
	return self:getJsonData(self.KEYS.TEXAS_ROOM_ENTER_REC, true);
end

--[[ 设置／获取加入牌局的记录时间戳 ]]
function LocalData:setTexasRoomJoinRecTime(value)
	self:setInt(self.KEYS.TEXAS_ROOM_JOIN_REC_TIME, value);
end

function LocalData:getTexasRoomJoinRecTime()
	return self:getInt(self.KEYS.TEXAS_ROOM_JOIN_REC_TIME, 0);
end

--[[ 设置/获取自由下注拉杆确认 ]]
function LocalData:setRaiseConfirm(value)
	if type(value) == "boolean" then
		value = value and 1 or 0;
	end
	value = value or 0;
	self:setInt(self.KEYS.USR_SET_RAISE_CONFIRM, value);
end

function LocalData:getRaiseConfirm()
	local vl = self:getInt(self.KEYS.USR_SET_RAISE_CONFIRM, 0);
	return vl == 1;
end

--[[ 设置/获取多牌桌自动切换 ]]
function LocalData:setMultDeskAutoSt(value)
	if type(value) == "boolean" then
		value = value and 1 or 0;
	end
	value = value or 0;
	self:setInt(self.KEYS.USR_MULT_DESK_AUTO_ST, value);
end

function LocalData:getMultDeskAutoSt()
	local vl = self:getInt(self.KEYS.USR_MULT_DESK_AUTO_ST, 0);
	return vl == 1;
end

function LocalData:setUpdDebug(vl)
	self:setInt(self.KEYS.UPD_DEBUG, vl);
end

function LocalData:getUpdDebug()
	local vl = self:getInt(self.KEYS.UPD_DEBUG, 0);
	return vl;
end

--[[ 获取单例 ]]
function LocalData:getInstance(...)
	local instance = self.INSTANCE;
	if not instance then
		instance = self:new(...);
		self.INSTANCE = instance;
	end
	return instance;
end

return LocalData;
