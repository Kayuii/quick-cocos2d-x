--[[
	扩展包更新管理
	@Author: ccb
	@Date: 2017-07-10
]]
local scheduler = require("framework.scheduler");
local UpdExtMgr = {};
UpdExtMgr.INSTANCE = nil;

-- 下载状态枚举
UpdExtMgr.DL_STATUS = {
	STOP = 0,
	CHECK_UPD = 1,
	DOWNLOADING = 2,
	COMPLETE = 3,
};

-- 结果类型枚举
UpdExtMgr.RET_TYPE = {
	CFG_INFO_GET_ERR = 1,	-- 配置文件md5获取错误
	CFG_FILE_DL_ERR = 2,	-- 配置文件下载错误
	DL_FILE_CHECK_RET = 3,	-- 需下载文件检测
	DL_FILE_INPROGRESS = 4, -- 下载文件进度
	DL_FILE_RATE = 5,		-- 下载文件速率
	DL_UPD_EX_CANCEL = 7,	-- 扩展更新下载取消
	DL_UPD_EX_COMPLETE = 8,	-- 扩展更新下载完成
	DL_NET_STATUS_UPD = 9, 	-- 网络状态变更
};
UpdExtMgr.RETRY_DL_CT = 3; -- 重试下载次数
UpdExtMgr.RETRY_DL_SAVE_REP_CT = 30; -- 尝试保存文件次数

UpdExtMgr.UPDEXT_SERVER = "http://192.168.200.212";
UpdExtMgr.UPDEXT_URL = UpdExtMgr.UPDEXT_SERVER .. "/xgextupd/"; 	-- 服务器扩展根目录
UpdExtMgr.RES_SERVER_URL = UpdExtMgr.UPDEXT_URL .. "res_zips/"; 	-- 服务器加密资源目录

UpdExtMgr.CFG_FNAME = "xgupdCfg.lua"; 					-- 加密列表配置文件
UpdExtMgr.CFG_INFO_FNAME = "xgupdManifest.lua"; 			-- 加密配置信息文件
UpdExtMgr.RES_CLIENT_DIR_N = "res"; 					-- 客户端项目资源目录
UpdExtMgr.RES_EXT_CLIENT_DIR_N = "res_ext"; 			-- 客户端扩展资源目录

UpdExtMgr.EVENT_RET = "EVENT_UPD_EXT_RET";

--[[ 构造方法 ]]
function UpdExtMgr:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;

	self:init();

	return o;
end

--[[ 初始化 ]]
function UpdExtMgr:init()
	self._updCfg = nil;	-- 扩展热更配置
	self._dlKey = nil;	-- 当前下载文件键值
	self._dlList = {};	-- 需要下载文件列表
	self._dlCurPSize = 0; 	-- 当前下载的大小
	self._dlTolPSize = 0; 	-- 需要下载的总大小
	self._dlCurFName = nil; -- 当前下载文件名
	self._dlRetryCt = 0; 	-- 下载保存失败重试次数
	self._dlErrList = {};	-- 下载错误或者保存失败文件列表

	self._dlRequest = nil; -- http请求对象
	self._dlDlyScheduler = nil; -- 延迟计划句柄

	self._dlStatus = nil; -- 下载状态
	self._netStatus = nil; -- 网络状态

	self._cfgFName = self.CFG_FNAME;
	self._cfgInfoFName = self.CFG_INFO_FNAME;
	self._resSerUrl = self.RES_SERVER_URL;

	self:resetDlRate();
end

--[[ 检测更新 ]]
function UpdExtMgr:checkUpd()
	self:init();
	self:checkCfgMd5();
end

--[[ 开始更新 ]]
function UpdExtMgr:startUpd()
	self:checkAndDownloadExtRes();
end

--[[ 停止更新 ]]
function UpdExtMgr:stopUpd()
	self:cancelDlRequest();
	self:unscheduleDlDly();
	self:init();

	self._dlStatus = self.DL_STATUS.STOP;
	self:dispatchUpdRetEvent(self.RET_TYPE.DL_UPD_EX_CANCEL);
end

--[[ 检测配置文件md5 ]]
function UpdExtMgr:checkCfgMd5()
	-- 如果本地没有配置文件，则直接从文件服拉取
	-- 有则，进行md5对比，不一致则下载，反之，使用缓存配置
	local lfMd5 = getFileMd5(self:getResextFilePath());
	if not lfMd5 then
		self:downloadCfgFile();
	else
		self:getCfgInfoOnFServer(function(data)
			local sfmd5 = data and data.md5;
			local nclean = data and data.clean;
			if not sfmd5 or not lfMd5 or sfmd5 ~= lfMd5 then
				if nclean and nclean == 1 then
					-- 删除目录
					rmvallfilesindir(self:getResextFilePath(""));
				end

				-- 不一致则重新下载
				self:downloadCfgFile();
			else
				-- 一致直接使用配置文件
				self:loadCfgAndCheckDownload();
			end
		end);
	end
end

--[[ 获取文件服上的配置文件信息 ]]
function UpdExtMgr:getCfgInfoOnFServer(callback)
	local url = self.UPDEXT_URL .. self._cfgInfoFName;
	xg.network:requestGet(url, function(event)
		local info = event and event.info;
		local request = event and event.request;
		if event.msg == "success" then
			local data = loadLuaData(info);
			callback(data);
		else
			if event.msg and event.errorCode then
				self:dispatchUpdRetEvent(self.RET_TYPE.CFG_FILE_DL_ERR);
				callback();
			end
		end
	end, nil, 60);
end

--[[ 下载配置文件 ]]
function UpdExtMgr:downloadCfgFile()
	local url = self.UPDEXT_URL .. self._cfgFName;
	xg.network:requestGet(url, function(event)
		local info = event and event.info;
		local request = event and event.request;
		if event.msg == "success" then
			local data = loadLuaData(info);
			if data then
				writeFile(self:getResextFilePath(), info);
			end
			self:loadCfgAndCheckDownload();
		else
			if event.msg and event.errorCode then
				self:dispatchUpdRetEvent(self.RET_TYPE.CFG_INFO_GET_ERR);
			end
		end
	end, nil, 60);
end

--[[ 加载配置文件并检测更新 ]]
function UpdExtMgr:loadCfgAndCheckDownload()
	self._dlList = {};
	self._dlErrList = {};
	self._dlTolPSize = 0;
	self._dlCurPSize = 0;
	self._updCfg = loadLua(self:getResextFilePath()) or {};

	local key = "duofu";
	local arrDld4Ck = self._updCfg[key];

	dump(arrDld4Ck, "arrDld4Ck");

	local lfmd5, cfmd5;
	if arrDld4Ck and next(arrDld4Ck) then
		for k,v in pairs(arrDld4Ck) do
			lfmd5 = getFileMd5(ospathconcat(self.RES_CLIENT_DIR_N, k));
			if lfmd5 and lfmd5 == v[1] then
				-- 项目目录包含资源
			else
				cfmd5 = getFileMd5(ospathconcat(self.RES_EXT_CLIENT_DIR_N, k));
				if cfmd5 and cfmd5 == v[1] then
					-- 扩展目录包含资源
				else
					-- 需要下载或更新
					self._dlList[ospathconcat(key, k)] = v[2];
					self._dlTolPSize = self._dlTolPSize + v[2];
				end
			end
		end
	end

	dump(self._dlList, "self._dlList" .. tostring(self._dlTolPSize));

	self._dlStatus = self.DL_STATUS.CHECK_UPD;
	local dlnum = table.nums(self._dlList);
	local dlsize = self:countFmtSize(self._dlTolPSize);
	self:dispatchUpdRetEvent(self.RET_TYPE.DL_FILE_CHECK_RET, {dlnum = dlnum, dlsize = dlsize});
end

--[[ 检测并执行下载扩展资源 ]]
function UpdExtMgr:checkAndDownloadExtRes()
	local dllist = self._dlList;
	if not dllist or not next(dllist) then
		if self._dlErrList and next(self._dlErrList) then
			-- 说明还存在未下载扩展，重新检测
			self:loadCfgAndCheckDownload();
		else
			self._dlStatus = self.DL_STATUS.COMPLETE;
			self:dispatchUpdRetEvent(self.RET_TYPE.DL_UPD_EX_COMPLETE);
		end
		return;
	end

	self._dlRetryCt = 0;
	self._dlKey = next(dllist);
	self._dlStatus = self.DL_STATUS.DOWNLOADING;
	self:downloadExtRes();
end

--[[ 下载扩展资源 ]]
function UpdExtMgr:downloadExtRes()
	self:checkNetworkStatus();
	if not self._dlKey then return end

	local url = self._resSerUrl .. self._dlKey;
	local fspath = self:getResextFilePath(url2path(self._dlKey));
	local dirpath, fname = ospathsplit(fspath);
	self._dlCurFName = fname;


	print("url", url);
	print("fspath", fspath);

	self:cancelDlRequest();
	self:unscheduleDlDly();
	self._dlRequest = xg.network:requestGet(url, function(event)
		local info = event and event.info;
		local request = event and event.request;
		if event.msg == "success" then
			if info then
				createDirectoryEx(dirpath);

				-- 保存到指定路径
				local nSaveRepDataCt = 1;
				while (not request:saveResponseData(fspath))
				and nSaveRepDataCt < self.RETRY_DL_SAVE_REP_CT do
					nSaveRepDataCt = nSaveRepDataCt + 1;
				end
				if nSaveRepDataCt >= self.RETRY_DL_SAVE_REP_CT then
					self:checkRetryDownload();
				else
					local dlkey = self._dlKey;
					self._dlKey = nil;
					if not dlkey then return end
					self._dlCurPSize = self._dlCurPSize + self._dlList[dlkey];

					self:countDlRate();
					self:resetDlRate();

					self._dlList[dlkey] = nil;
					self._dlErrList[dlkey] = nil;

					self:unscheduleDlDly();
					self._dlDlyScheduler = scheduler.performWithDelayGlobal(handler(self, self.checkAndDownloadExtRes), 0.1);
					self:dispatchUpdRetEvent(self.RET_TYPE.DL_FILE_INPROGRESS, {file = fname, status = self:fmtDlSizeStatus()});
				end
			else
				self:checkRetryDownload();
			end
		else
			if event.msg and event.errorCode then
				self:checkRetryDownload(event.msg);
			elseif event.msg == "inprogress" then
				self:resetDlRate(info.dlnow ~= 0 and info.dltotal ~= 0);
				self:countDlRate(info.dlnow);
			end
		end
	end, nil, self:getPredictDlTm());

	self._preReqTm = device.gettime().tv_sec;
	self:dispatchUpdRetEvent(self.RET_TYPE.DL_FILE_INPROGRESS, {file = fname, status = self:fmtDlSizeStatus()});
end

--[[ 发生错误时检测重新下载 ]]
function UpdExtMgr:checkRetryDownload()
	self:resetDlRate();

	local ct = self._dlRetryCt;
	if ct >= self.RETRY_DL_CT then
		self._dlList[self._dlKey] = nil;
		self._dlErrList[self._dlKey] = 1;
		self:checkAndDownloadExtRes();
	else
		self._dlRetryCt = self._dlRetryCt + 1;
		self:downloadExtRes();
	end
end

--[[ 取消下载 ]]
function UpdExtMgr:cancelDlRequest()
	local requestIns = self._dlRequest;
	if not toluaIsNil(requestIns) and toluaType(requestIns.cancel) == "function" then
		requestIns:cancel();
		self._dlRequest = nil;
	end
end

--[[ 取消延迟下载计时 ]]
function UpdExtMgr:unscheduleDlDly()
	if self._dlDlyScheduler then
		scheduler.unscheduleGlobal(self._dlDlyScheduler);
		self._dlDlyScheduler = nil;
	end
end

--[[ 获取扩展文件路径 ]]
function UpdExtMgr:getResextFilePath(fname)
	fname = fname or self._cfgFName;
	local wPath = getwritablepath();
	local fpath = ospathconcat(wPath .. self.RES_EXT_CLIENT_DIR_N, fname);
	return fpath;
end

--[[ 获取预计下载时间 ]]
function UpdExtMgr:getPredictDlTm(psz)
	psz = psz or self._dlList[self._dlKey] or 0;

	dump(self._dlList, "self._dlList" .. tostring(self._dlKey));


	local tmpkb = psz/1024;
	local tagtm = 30 + math.max(tmpkb/30, 1);
	return tagtm;
end

--[[ 重设下载速率相关的变量 ]]
function UpdExtMgr:resetDlRate(bInpro)
	if not bInpro then
		self._preDlTk = nil;
		self._preDlCur = nil;
		self._recvDlCur = nil;
		self._dlTmpCurPSize = nil;
	end
	self._preReqTm = nil;
	self._bInprogressed = bInpro;
end

--[[ 计算下载速率 ]]
function UpdExtMgr:countDlRate(dlcur)
	self:checkNetworkStatus();

	if not self._dlKey then return end

	dlcur = dlcur or (self._dlKey and self._dlList[self._dlKey]);
	if not dlcur then return end

	local kper = nil;
	local curtk = device.gettime().tv_sec;
	if self._bInprogressed then
		self._preDlTk = self._preDlTk or curtk;
		self._preDlCur = self._preDlCur or dlcur;
		self._recvDlCur = self._recvDlCur or 0;
		self._recvDlCur = self._recvDlCur + (dlcur - self._preDlCur);
		self._dlTmpCurPSize = self._dlTmpCurPSize or self._dlCurPSize;
		if dlcur == self._preDlCur then return end

		local subtk = curtk - self._preDlTk;
		if subtk >= 1 then
			kper = self._recvDlCur/1024/subtk;
			self._recvDlCur = nil;
		end

		self._dlTmpCurPSize = self._dlTmpCurPSize + (dlcur - self._preDlCur);
		self:dispatchUpdRetEvent(self.RET_TYPE.DL_FILE_INPROGRESS, {
			file = self._dlCurFName,
			status = self:fmtDlSizeStatus(self._dlTmpCurPSize),
		});

		self._preDlTk = curtk;
		self._preDlCur = dlcur;
	else
		if dlcur ~= 0 then
			self._preReqTm = self._preReqTm or curtk;
			local subtk = curtk - self._preReqTm;
			kper = dlcur/1024/(math.max(subtk, 1));
		end
	end

	if kper and tonumber(kper) then
		local strkper;
		if kper >= 1024 then
			strkper = string.format("%.01fM/s", kper/1024);
		else
			strkper = string.format("%.01fK/s", kper);
		end
		self:dispatchUpdRetEvent(self.RET_TYPE.DL_FILE_RATE, {rate = strkper});
	end
end

--[[ 检测当前的网络状态 ]]
function UpdExtMgr:checkNetworkStatus()
	if true then return end

	local status = xg.network:getNetConnectStatus();
	local preStatus = self._netStatus;
	self._netStatus = self._netStatus or status;
	if not preStatus or preStatus ~= self._netStatus or status ~= self._netStatus then
		-- 网络状态发生变化，则派发通知
		self._netStatus = status;
		self:dispatchUpdRetEvent(self.RET_TYPE.DL_NET_STATUS_UPD, {status = self._netStatus});
	end
end

--[[ 格式化下载进度 ]]
function UpdExtMgr:fmtDlSizeStatus(cur, total)
	local cur, tol = cur or self._dlCurPSize, total or self._dlTolPSize;
	return string.format("%s/%s", self:countFmtSize(cur), self:countFmtSize(tol));
end

--[[ 计算格式化的大小 ]]
function UpdExtMgr:countFmtSize(fsize)
	if fsize <= 1024 * 1024 then
		return string.format("%.02fKB", fsize/1024);
	else
		return string.format("%.02fMB", fsize/1024/1024);
	end
end

--[[ 派发结果事件 ]]
function UpdExtMgr:dispatchUpdRetEvent(r_type, info)
	xg.event:dispatchEvent({name = self.EVENT_RET, ret_type = r_type, info = info});
end

--[[ 获取下载状态 ]]
function UpdExtMgr:getDlStatus()
	return self._dlStatus;
end

--[[ 获取单例 ]]
function UpdExtMgr:getInstance(...)
	local instance = self.INSTANCE;
	if not instance then
		instance = self:new(...);
		self.INSTANCE = instance;
	end
	return instance;
end

return UpdExtMgr;
