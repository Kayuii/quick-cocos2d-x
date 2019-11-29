--[[
	日志简单管理
	@Author: ccb
	@Date: 2017-07-10
]]
require "lfs";
local TAG = "#####LogUtil";
local dump = dump_r or dump;
local print = g_old_print or print_r or print;
local fileUtils = CCFileUtils:sharedFileUtils();

local LogUtil = {};
LogUtil.INSTANCE = nil;
LogUtil.XXTEA_KEY = "xg160712";
LogUtil.LOG_EXPIRED_DAY = 2;
LogUtil.AUTO_SAVE_CONSOLE_LOG = false;
LogUtil.AUTO_SAVE_CONSOLE_LOG_CONDITION = 100000;
LogUtil.LOG_UPLOAD_URL = "https://mutong.facepoker.cc/API/Image/uploadOnePokerlog";

LogUtil.MSG_IGNORE_DICT = {
	["0"] = true,
	["makeUIControl"] = true,
};

-- 全局变量，保存log
G_LOG_UTIL_CACHE = G_LOG_UTIL_CACHE or {};

-- 容错处理
if not table then
	table = table or {};
	table.keys = table.keys or function(hashtable)
		local keys = {};
		for k, v in pairs(hashtable) do
			keys[#keys + 1] = k;
		end
		return keys;
	end
end
if not device then
	device = device or {};
	device.gettime = device.gettime or function()
		local tm = cc_timeval:new();
		CCTime:gettimeofdayCocos2d(tm, nil);

		if device.platform and device.platform == "windows" then
			tm.tv_sec = os.time();
		end
		return tm;
	end

	device.timersub = device.timersub or function(tm_start, tm_end)
		return tm_end.tv_sec - tm_start.tv_sec + (tm_end.tv_usec - tm_start.tv_usec)/1000000;
	end
end
if not string.trim then
	string.trim = function(input)
		input = string.gsub(input, "^[ \t\n\r]+", "");
		return string.gsub(input, "[ \t\n\r]+$", "");
	end
end

--[[ 构造方法 ]]
function LogUtil:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;

	self:init();

	return o;
end

--[[ 初始化 ]]
function LogUtil:init()
	G_LOG_UTIL_CACHE = G_LOG_UTIL_CACHE or {};
	G_LOG_UTIL_CACHE["console"] = G_LOG_UTIL_CACHE["console"] or {};
	self:ckErrLogCache();
end

--[[ 检测错误日志 ]]
function LogUtil:ckErrLogCache()
	if not crypto or type(crypto.decryptXXTEA) ~= "function" then return end

	G_LOG_UTIL_CACHE = G_LOG_UTIL_CACHE or {};
	G_LOG_UTIL_CACHE["error"] = G_LOG_UTIL_CACHE["error"] or self:getErrLogFromLocal() or {};
end

--[[ 检测是否存在重复控制台日志 ]]
function LogUtil:ckRepConsoleMsg(tmsg, msg)
	if not tmsg or tmsg == "" then return end

	local tagmsg, num, orgMsg;
	local s, e = string.find(tmsg, msg);
	if s and e then
		if e == string.len(tmsg) then
			num = 0;
			orgMsg = tmsg;
		else
			orgMsg = string.sub(tmsg, 1, e);
			local str = string.sub(tmsg, e + 1);
			local s2, e2 = string.find(str, "--> %d++$");
			if s2 and e2 then
				num = string.match(string.sub(str, s2, e2), "%d+");
			end
		end
	end
	if orgMsg and num then
		tagmsg = string.format("%s --> %s+", orgMsg, num + 1);
	end

	return tagmsg;
end

--[[ 添加控制台日志 ]]
function LogUtil:addConsoleMsg(...)
	local args = {...};
	if args and next(args) then
		-- 此处由于变长参数中，可能存在nil值，将导致concat报错。
		-- 所以需要重新赋值args。
		for i = 1, #args do
			args[i] = (type(args[i]) ~= "string") and tostring(args[i]) or args[i];
		end
	end
	local msg = table.concat(args, " ");
	msg = string.trim(msg);
	if not msg or msg == "" then return end

	if self.MSG_IGNORE_DICT[msg] then return end

	G_LOG_UTIL_CACHE = G_LOG_UTIL_CACHE or {};
	G_LOG_UTIL_CACHE["console"] = G_LOG_UTIL_CACHE["console"] or {};

	local arrLog = G_LOG_UTIL_CACHE["console"];
	local tagmsg = self:ckRepConsoleMsg(arrLog[#arrLog], msg);
	if tagmsg then
		arrLog[#arrLog] = tagmsg;
		return;
	end

	self._consoleMsgTm = self._consoleMsgTm or device.gettime();
	self._curmsec = device.timersub(self._consoleMsgTm, device.gettime());
	msg = string.format("[%.4f] %s", self._curmsec, msg);

	table.insert(arrLog, msg);

	-- 自动保存
	if self.AUTO_SAVE_CONSOLE_LOG then
		if #arrLog >= self.AUTO_SAVE_CONSOLE_LOG_CONDITION then
			self:saveConsoleLog2Local();
		end
	end
end

--[[ 添加错误日志 ]]
function LogUtil:addErrMsg(msg)
	if not msg or msg == "" then return end

	-- ios每次启动程序包路径都不同，所以需要去除，保证相同错误不保留。
	msg = string.gsub(msg, "%w+\-%w+\-%w+\-%w+\-%w+", "...");

	local bFind = false;
	self:ckErrLogCache();
	local arr = G_LOG_UTIL_CACHE["error"];
	if arr and next(arr) then
		for k,v in pairs(arr) do
			if v == msg then
				bFind = true;
				break;
			end
		end
	end
	if not bFind then
		table.insert(G_LOG_UTIL_CACHE["error"], msg);
		self:saveErrLog2Local();
	end
end

--[[ 获取当前的控制台日志内容 ]]
function LogUtil:getConsoleLog()
	G_LOG_UTIL_CACHE = G_LOG_UTIL_CACHE or {};
	local tb = G_LOG_UTIL_CACHE["console"];
	if not tb or not next(tb) then return end

	local totalMsg = table.concat(tb, "\n");
	return totalMsg;
end

--[[ 获取当前加密的控制台日志内容 ]]
function LogUtil:getEncryptConsoleLog()
	local msg = self:getConsoleLog();
	if not msg or msg == "" then return end

	-- 进行加密
	local encryptStr = crypto.encryptXXTEA(msg, string.rep(self.XXTEA_KEY, 3));
	return encryptStr;
end

--[[ 获取当前的错误日志内容(明文) ]]
function LogUtil:getErrDecryptLog(fname)
	if fname then
		local fmttm = self:fmtDate(os.time());
		local tname = string.format("errorlog_%s.log", fmttm);
		fname = fname ~= tname and fname or nil;
	end

	local tb;
	if fname then
		tb = self:getErrLogFromLocal(fname);
	else
		self:ckErrLogCache();
		tb = G_LOG_UTIL_CACHE["error"];
	end
	if not tb or not next(tb) then return end

	local totalMsg = table.concat(tb, self:getTipStr("error"));
	return totalMsg;
end

--[[ 获取当前的错误日志内容(json格式) ]]
function LogUtil:getErrLog()
	self:ckErrLogCache();
	local tb = G_LOG_UTIL_CACHE["error"];
	if not tb or not next(tb) then return end

	local totalMsg = json.encode(tb);
	return totalMsg;
end

--[[ 加密并保存控制台日志到本地 ]]
function LogUtil:saveConsoleLog2Local()
	-- 进行加密
	local encryptStr = self:getEncryptConsoleLog();
	if not encryptStr then return end

	local path = self:getLogPath();
	local fmttm = self:fmtTime(os.time());
	local fname = string.format("consolelog_%s.log", fmttm);
	path = string.format("%s/%s", path, fname);
	self:writeLogFile(path, encryptStr);

	-- 每次保存后清空
	G_LOG_UTIL_CACHE["console"] = {};

	return fname;
end

--[[ 加密并保存错误日志到本地(json格式) ]]
function LogUtil:saveErrLog2Local()
	local msg = self:getErrLog();
	if not msg or msg == "" then return end

	-- 进行加密
	local encryptStr = crypto.encryptXXTEA(msg, string.rep(self.XXTEA_KEY, 3));

	local path = self:getLogPath();
	local fmttm = self:fmtDate(os.time());
	local fname = string.format("errorlog_%s.log", fmttm);
	path = string.format("%s/%s", path, fname);
	self:writeLogFile(path, encryptStr);

	return fname;
end

--[[ 明文保存错误日志到本地 ]]
function LogUtil:decryptErrLog2Local(fname)
	local msg = self:getErrDecryptLog(fname);
	if not msg or msg == "" then return end

	if fname then
		local fn, fnex = filesplitex(fname);
		fname = string.format("%s_decrypt.%s", fn, fnex);
	else
		local fmttm = self:fmtDate(os.time());
		fname = string.format("errorlog_%s_decrypt.log", fmttm);
	end

	local path = self:getLogPath();
	path = string.format("%s/%s", path, fname);
	self:writeLogFile(path, msg);

	return fname;
end

--[[ 从本地获取错误日志(json格式) ]]
function LogUtil:getErrLogFromLocal(fname)
	if not fname then
		local fmttm = self:fmtDate(os.time());
		fname = string.format("errorlog_%s.log", fmttm);
	end

	-- 先解密
	fname = self:decryptLog(fname, "error");
	if not fname then return end

	-- 读取解密后文件
	local path = self:getLogPath();
	path = string.format("%s/%s", path, fname);
	local msg = self:readLogFile(path);
	if not msg or msg == "" then return end

	-- 移除解密后文件(josn格式不太好阅读，之后可进行转换)
	os.remove(path);

	local arr = json.decode(msg);
	return arr;
end

--[[ 从本地已解密的文件获取内容 ]]
function LogUtil:getDecryptLogContFromLocal(fName)
	if not fName or fName == "" then return end

	local path = self:getLogPath();
	local fn, fnex = filesplitex(fName);

	local fpath = string.format("%s/%s_bak.%s", path, fn, fnex);
	if not fileUtils:isFileExist(fpath) then return end

	local msg = self:readLogFile(fpath);
	if not msg or msg == "" then return end

	return msg;
end

--[[ 解密并重新保存日志 ]]
function LogUtil:decryptLog(fName, key)
	if not fName or fName == "" then return end
	key = key or "console";

	local path = self:getLogPath();
	local fpath = string.format("%s/%s", path, fName);
	if not fileUtils:isFileExist(fpath) then return end

	local msg = self:readLogFile(fpath);
	if not msg or msg == "" then return end

	local decryptStr = crypto.decryptXXTEA(msg, string.rep(self.XXTEA_KEY, 3));
	if not decryptStr then return end

	if key == "console" then
		decryptStr = self:getTipStr() .. decryptStr;
	end

	if not ospathsplitex or type(ospathsplitex) ~= "function" then
		require("app.xgame.base.extends.XgIoEx");
	end
	local fn, fnex = ospathsplitex(fpath);
	local fname = string.format("%s_bak.%s", fn, fnex);
	fpath = string.format("%s/%s", path, fname);
	self:writeLogFile(fpath, decryptStr);

	return fname;
end

--[[ 获取日志文件路径 ]]
function LogUtil:getLogPath()
	local wPath = fileUtils:getWritablePath();
	local logPath = wPath .. "pokerlog";
	if not fileUtils:isFileExist(logPath) then
		lfs.mkdir(logPath);
	end

	return logPath;
end

--[[ 读文件 ]]
function LogUtil:readLogFile(path)
	local function doRead()
		local f = assert(io.open(path, 'rb'));
		local cont = f:read("*a");
		f:close();
		return cont;
	end
	local str = "";
	if try and type(try) == "function" then
		try{
			function()
				str = doRead();
			end,
		};
	else
		str = doRead();
	end
	return str;
end

--[[ 写文件 ]]
function LogUtil:writeLogFile(path, str, mode)
	local function doWrite()
		mode = mode or 'wb';
		local f = assert(io.open(path, mode));
		f:write(str);
		f:close();
	end
	if try and type(try) == "function" then
		try{
			doWrite,
		};
	else
		doWrite();
	end
end

--[[ 上传日志文件 ]]
function LogUtil:uploadLog(path, cb)
	if not path then
		-- 默认为当前文件名
		local fmttm = self:fmtTime(os.time());
		path = string.format("consolelog_%s.log", fmttm);
	end

	local p, fn = ospathsplit(path);
	if not p or not fn then
		-- path是文件名
		path = string.format("%s/%s", self:getLogPath(), path);
	end
	if not fileUtils:isFileExist(path) then return end

	local function docb(flag, err)
		if not cb or type(cb) ~= "function" then return end

		cb({ret = flag, err = err});
	end

	local uid = UserInfo and UserInfo.id;
	if not uid or uid == 0 then
		uid = xg.localData:getLogAcc() or "";
	end
	local url = self.LOG_UPLOAD_URL .. "?id=" .. uid;
	local request = network.createHTTPRequest(function(event)
		if event.name == "completed" then
			LoadAnimation.stopLoading();
			local request = event.request;
			local result = request:getResponseString();
			local code = request:getResponseStatusCode();
			if code == 200 then
				docb(true);
				TipsLayer.show('upload sucess.');
			else
				docb(false, code);
				TipsLayer.show(string.format('upload fail code:%s.', code));
			end
		end

		if event.name == "failed" or event.name == "cancelled" then
			LoadAnimation.stopLoading();
			local errMsg = request:getErrorMessage();
			docb(false, errMsg);
			TipsLayer.show(string.format('upload fail error:%s.', errMsg));
		end
	end, url, "POST");

	local file_type = "multipart/form_data";
	if device.platform == "android" then
		file_type = "multipart/form-data";
	end
	request:addFormFile("file", path, file_type);
	request:setTimeout(240);
	request:start();
	LoadAnimation.showLoading("uploading...", 240);
end

--[[ 获取日志列表 ]]
function LogUtil:getLogList(key)
	key = key or "console";
	local paths = getpathfiles(self:getLogPath());
	if not paths or not next(paths) then return end

	local fn;
	local list = {};
	for k,v in pairs(paths) do
		if (key == "console" and string.find(v, "consolelog_") and not string.find(v, "_bak"))
		or (key == "console_decrypt" and string.find(v, "consolelog_") and string.find(v, "_bak"))
		or (key == "error" and string.find(v, "errorlog_") and not string.find(v, "_decrypt"))
		or (key == "error_decrypt" and string.find(v, "errorlog_") and string.find(v, "_decrypt")) then
			_, fn = ospathsplit(v);
			table.insert(list, fn);
		end
	end
	return list;
end

--[[ 判断某日志是否已解密 ]]
function LogUtil:bolLogDecrypt(file, key)
	key = key or "console";
	if not file or file == "" then return end

	local paths = getpathfiles(self:getLogPath());
	if not paths or not next(paths) then return end

	local bDecrypt = false;
	local fn, fnex = filesplitex(file);
	local fmt = (key == "console") and "%s_bak.%s" or "%s_decrypt.%s";
	local fname = string.format(fmt, fn, fnex);
	for k, v in pairs(paths) do
		if string.find(v, fname) then
			bDecrypt = true;
			break;
		end
	end
	return bDecrypt;
end

--[[ 移除文件 ]]
function LogUtil:removeFile(fname)
	local path = self:getLogPath();
	path = string.format("%s/%s", path, fname);

	if fileUtils:isFileExist(path) then
		os.remove(path);
	end
end

--[[ 移除所有已解密文件 ]]
function LogUtil:delAllDecryptFile(key)
	key = key or "console";
	local tmpKey = string.format("%s_decrypt", key);
	local list = self:getLogList(tmpKey);
	if not list or not next(list) then return end

	for k,v in ipairs(list) do
		self:removeFile(v);
	end
end

--[[ 检测或移除过期日志 ]]
function LogUtil:checkExpiredLogs()
	local paths = getpathfiles(self:getLogPath());
	if not paths or not next(paths) then return end

	local tm = os.time();
	local y, m, d = os.date("%Y", tm), os.date("%m", tm), os.date("%d", tm);
	y, m, d = tonumber(y), tonumber(m), tonumber(d);
	local tmpd, y1, m1, d1;
	for k,v in pairs(paths) do
		tmpd = string.match(v, "log_(%d+)");
		if tmpd then
			y1, m1, d1 = string.sub(tmpd, 1, 4), string.sub(tmpd, 5, 6), string.sub(tmpd, 7, 8);
			y1, m1, d1 = tonumber(y1), tonumber(m1), tonumber(d1);
			if y1 < y or m1 < m or (y1 == y and m1 == m and (d - d1) >= self.LOG_EXPIRED_DAY) then
				os.remove(v);
			end
		end
	end
end

--[[ 格式化日期 ]]
function LogUtil:fmtDate(int)
	local y, mth, d = os.date("%Y", int), os.date("%m", int), os.date("%d", int);
	return string.format("%d%02d%02d", y, mth, d);
end

--[[ 格式化时间 ]]
function LogUtil:fmtTime(int)
	local date = self:fmtDate(int);
	local h, mit, s = os.date("%H", int), os.date("%M", int), os.date("%S", int);
	return string.format("%s_%02d%02d%02d", date, h, mit, s);
end

--[[ 获取提示用语 ]]
function LogUtil:getTipStr(key)
	key = key or "console";

	local tip = "";
	if key == "console" then
		tip = tip .. "======================================================\n";
		tip = tip .. "If you find chinese garbled, please change to utf-8.\n";
		tip = tip .. "======================================================\n";
	elseif key == "error" then
		tip = tip .. "\n\n--------------------------------------------------";
		tip = tip .. "I'm split line.";
		tip = tip .. "--------------------------------------------------\n";
	end
	return tip;
end

--[[ 获取单例 ]]
function LogUtil:getInstance(...)
	local instance = self.INSTANCE;
	if not instance then
		instance = self:new(...);
		self.INSTANCE = instance;
	end
	return instance;
end

return LogUtil;
