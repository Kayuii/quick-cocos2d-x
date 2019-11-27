--[[
	network扩展
	@Author: ccb
	@Date: 2017-06-06
]]
local TAG = "#####Network";
local XgNetwork = {};
XgNetwork.INSTANCE = nil;
XgNetwork.LOCAL_C_IP = nil;
XgNetwork.DEF_TIME_OUT_REQ_GET = 4;
XgNetwork.URL_LOG = "https://game.facepoker.cc:8080/log";
XgNetwork.URL_GET_SERVER_IP = "https://www.facepoker.cc/APIDN/App/getServerIp";
XgNetwork.URL_UPD_SVR_INFO_2 = "https://cdn.facepoker.cc/updateDn/serverInfo2.php";
XgNetwork.URL_GET_PARITIES = "https://www.facepoker.cc/APIDN/app/getRate"; -- 请求汇率
XgNetwork.URL_LOCAL_C_IP = "http://ip.taobao.com/service/getIpInfo.php"; -- 客户端本地Ip

XgNetwork.BASE_DOMAIN = "https://cdn.qq409.cn";
XgNetwork.FSER_DOMAIN = "https://www.qq409.cn";
XgNetwork.FILE_UPLOAD_URL = XgNetwork.BASE_DOMAIN .. "/mobile/Uploadify/uploadFile";

--[[ 构造方法 ]]
function XgNetwork:new(o)
	o = o or {}; 
	setmetatable(o, self);
	self.__index = self;
	self:init();
	return o;
end

--[[ 初始化 ]]
function XgNetwork:init()

end

--[[ 网络是否可用 ]]
function XgNetwork:bolReachable()
	local status = network.getInternetConnectionStatus();
	return status ~= kCCNetworkStatusNotReachable;
end

--[[ 获取网络连接状态 ]]
function XgNetwork:getNetConnectStatus(status)
	return network.getInternetConnectionStatus();
end

--[[ 获取网络连接状态 ]]
function XgNetwork:getNetConnectStatusStr()
	local status = self:getNetConnectStatus();
	local arr = {
		[kCCNetworkStatusNotReachable] = "none",
		[kCCNetworkStatusReachableViaWiFi] = "wifi",
		[kCCNetworkStatusReachableViaWWAN] = "3g/4g",
	};
	return arr[status];
end

--[[ 创建http请求 ]]
function XgNetwork:createRequest(callback, url, method)
	if network and type(network.createHTTPRequest) == "function" then
		return network.createHTTPRequest(callback, url, method);
	else
		method = method or "GET";
		if string.upper(tostring(method)) == "GET" then
			method = kCCHTTPRequestMethodGET;
		else
			method = kCCHTTPRequestMethodPOST;
		end
		return CCHTTPRequest:createWithUrl(callback, url, method);
	end
end

--[[ get http 请求 ]]
function XgNetwork:requestGet(url, callback, keys, timeout, ...)
	if not url then return end

	local args = { ... };
	if keys and next(keys) then
		local idx = 0;
		for k,v in pairs(keys) do
			idx = idx + 1;
			url = string.format("%s%s%s=%s", url, (idx == 1 and "?" or "&"), k, v);
		end
	end

	local function onCallback(request, msg, response, errCode)
		if not callback or type(callback) ~= "function" then return end
		callback({request = request, msg = msg, info = response, errorCode = errCode}, unpack(args, 1, table.maxn(args)));
		-- dump_r({url = url, msg = msg, info = response, errorCode = errCode}, "######requestGet callback");
	end

	local function onRespone(event)
		local request = event.request;
		if event.name == "inprogress" then
			onCallback(request, event.name, {dlnow = event.dlnow, dltotal = event.dltotal});
		end
		if event.name == "completed" then
			local code = request:getResponseStatusCode();
			if code ~= 200 then
				onCallback(request, "failed", nil, code);
			else
				local response = request:getResponseString();
				onCallback(request, "success", response);
			end
		end
		if event.name == "failed" or event.name == "cancelled" then
			local errCode = request:getErrorCode();
			local errMsg = request:getErrorMessage();
			onCallback(request, event.name, errMsg, errCode);
		end
	end
	local request = self:createRequest(onRespone, url, "GET");
	request:setTimeout(tonumber(timeout) or self.DEF_TIME_OUT_REQ_GET);
	request:start();

	-- (dump_r or dump)({url = url, args = args}, "#####requestGet do");

	return request;
end

--[[ post http 请求 ]]
function XgNetwork:requestPost(url, callback, data, ...)
	if not url then return end

	local args = { ... };
	local function onCallback(msg, response, errCode)
		if not callback or type(callback) ~= "function" then return end
		callback({msg = msg, info = response, errorCode = errCode}, data, unpack(args, 1, table.maxn(args)));
	end

	local function onRespone(event)
		local request = event.request;
		if event.name == "completed" then
			local code = request:getResponseStatusCode();
			if code ~= 200 then
				onCallback("failed", nil, code);
			else
				local response = request:getResponseString();
				onCallback("success", response);
			end
		end
		if event.name == "failed" or event.name == "cancelled" then
			local errMsg = request:getErrorMessage();
			onCallback(event.name, errMsg);
		end
	end

	local request = self:createRequest(onRespone, url, "POST");

	-- 添加头信息
	if data and data.header then
		request:addRequestHeader(data.header);
	end

	-- 添加表单数据
	if data and data.form_file and next(data.form_file) then
		-- content_type常见文件类型 可参看http://tool.oschina.net/commons
		local fname = data.form_file.filed_name;
		local fpath = data.form_file.file_path;
		local ctype = data.form_file.content_type;
		if fname or fpath then
			if not ctype then
				request:addFormFile(fname, fpath);
			else
				request:addFormFile(fname, fpath, ctype);
			end

			-- 增加附加的表单变量
			local conts = data.form_file.contents;
			if conts and next(conts) then
				local contdata;
				for i in ipairs(conts) do
					contdata = conts[i];
					request:addFormContents(contdata[1], contdata[2]);
				end
			end
		end
	end

	if data and data.post_data then
		local postdata = data.post_data;
		if type(postdata) == "table" and next(postdata) then
			postdata = json.encode(postdata);
		end
		request:setPOSTData(tostring(postdata));
	end

	if data.timeout and tonumber(data.timeout) then
		request:setTimeout(tonumber(data.timeout));
	end

	request:start();

	return request;
end

--[[ 获取 server ip ]]
function XgNetwork:getServerIp(ops)

	------------------------------------------------------
	-- 暂时不用从后台拉去server ip
	-- modifyed by ccb 20190228
	if true then
		local callback = ops and ops.callback;
		if callback and type(callback) == "function" then
			callback({msg == "success", info = ServerIp});
		end
		return;
	end
	------------------------------------------------------

	local ver = ops and ops.ver;
	local callback = ops and ops.callback;
	if not ver then
		local texasnowId = "0";
		local platform = require("app.xgame.base.XgPlatform"):getInstance();
		local localData = require("app.xgame.base.utils.XgLocalData"):getInstance();
		ver = platform:getBundleVersion();
		local curVer = localData:getCurVerCode();
		if curVer and curVer ~= "" then
			local temp = string.split(curVer, ".");
			if temp and #temp == 3 then
				texasnowId = temp[3];
			end
			local bigV = temp[1] .. "." .. temp[2];
			if bigV ~= tostring(ver) then
				-- 记录的大版本与当前不符，小版本清0
				texasnowId = "0";
			end
		end
		ver = ver .. "." .. texasnowId;
	end

	local function reqCallback(event)
		local info = event and event.info;
		if event.msg == "success" then
			local str = string.split(info, '.');
			if #str >= 3 then
				if info ~= xg.mainEntryHelp.SERVER_IP_BK then
					-- 默认serverIp为正式服
					-- 如果获取的IP不一致, 就理解为走审核服
					ShowGuestLogin = true;
				end
				ServerIp = info;
			end
			if ServerIp and XConstants then
				XConstants.SOCKET_SERVER_IP = ServerIp;
				if callback and type(callback) == "function" then
					callback(event);
				end
			end
			print(TAG, "getServerIp success", info);
		else
			if event.errorCode then
				XConstants.SOCKET_SERVER_IP = ServerIp;
				if callback and type(callback) == "function" then
					callback(event);
				end
				print(TAG, "getServerIp fail:", tostring(info));
			end
		end
	end
	self:requestGet(self.URL_GET_SERVER_IP, reqCallback, {v = ver});
end

--[[ 获取转换的 server ip ]]
function XgNetwork:getConvertServerIp(def_ip, def_port)

	local ret = {};
	--------------------------------------------------------
	-- 获取Ip
	local tagIp, tagPort;
	local httpDnsApiMgr = xg.user:getMgr("httpDnsApiMgr");
	if httpDnsApiMgr and httpDnsApiMgr.AT_WORK then
		local httpDnsApiHelp = httpDnsApiMgr:getHelp("login");
		tagIp = httpDnsApiHelp and httpDnsApiHelp:getIp();
		ret.http_dns_at_work = true;
	end
	--------------------------------------------------------

	--------------------------------------------------------
	-- 转换Ip
	local guanduSdkMgr = xg.user:getMgr("guanduSdkMgr");
	if guanduSdkMgr and guanduSdkMgr.AT_WORK then
		tagIp, tagPort = guanduSdkMgr:getSerIpAndPort({port = def_port or guanduSdkMgr.PORT_HTTPS});
		ret.guandu_sdk_at_work = true;
	end
	--------------------------------------------------------

	ret.ip = tagIp;
	ret.port = tagPort or def_port;
	if tagIp then
		tagIp = tagPort and string.format("%s:%s", tagIp, tagPort) or tagIp;
	end
	tagIp = tagIp or def_ip or ServerIp;
	ret.ip = ret.ip or tagIp;
	ret.ser_ip = tagIp;

	return tagIp, ret;
end

--[[ 检测是否处于ios审核状态 ]]
function XgNetwork:checkIfiosReview()
	local platform = require("app.xgame.base.XgPlatform"):getInstance();
	local ver = platform:getBundleVersion();
	local bv = platform:getBuildVersion();
	if bv then
		bv = string.format("%s.%s", ver, bv);
	end
	local function callback(event)
		local info = event and event.info;
		if event.msg == "success" then
			ShowGuestLogin = false;
			if info and tostring(ver) == tostring(info) then
				ShowGuestLogin = true;
				CCNotificationCenter:sharedNotificationCenter():postNotification("IOS_IS_REVIEW");
			end
		else
			if event.errorCode then
				RequestCheckReviewError = true;
				print(TAG, "checkIfiosReview fail:", tostring(info));
			end
		end
	end

	self:requestGet(self.URL_UPD_SVR_INFO_2, callback, {v = ver, bv = bv, time = os.time()});
end

--[[ 获取localIp ]]
function XgNetwork:getLocalIp(ip, callback)
	ip = ip or "myip";

	local function docb(flag, ip)
		if callback and type(callback) == "function" then
			self.LOCAL_C_IP = ip or self.LOCAL_C_IP;
			callback(flag, self.LOCAL_C_IP);
		end
	end

	local function req_cb(event)
		local info = event and event.info;
		if event.msg == "success" then
			if info then
				local jData = json.decode(info);
				local data = jData and jData.data;
				docb(true, data and data.ip);
				self._curLocalIpReqTmOut = 1;
			end
			print("getLocalIp success:" .. tostring(info));
		else
			if event.errorCode then
				docb(false);
				self._curLocalIpReqTmOut = self._curLocalIpReqTmOut or 1;
				self._curLocalIpReqTmOut = self._curLocalIpReqTmOut + 0.5;
				print(string.format("getLocalIp %s:%s", tostring(event.msg), tostring(info)));
			end
		end
	end

	local local_c_ip_max_time_out = 2.5;
	self._curLocalIpReqTmOut = self._curLocalIpReqTmOut or 1.5;
	local tmOut = math.min(self._curLocalIpReqTmOut, local_c_ip_max_time_out);
	self:requestGet(self.URL_LOCAL_C_IP, req_cb, {ip = ip}, tmOut);
end

--[[ 检测汇率]]
function XgNetwork:checkParities()
	PARITIES_RMB = PARITIES_RMB or 100;
	local function callback(event)
		local info = event and event.info;
		if event.msg == "success" then
			CCNotificationCenter:sharedNotificationCenter():postNotification("PARITIES_RMB");
			if event.info then 
				PARITIES_RMB = event.info;
			end
		else
			if event.errorCode then
				print(TAG, "checkParities fail:", tostring(info));
			end
		end
	end

	self:requestGet(self.URL_GET_PARITIES, callback, {serverIp = ServerIp});
end

--[[ 上传头像 ]]
function XgNetwork:uploadImage(path, url, callback)
	if not path then
		if type(callback) == "function" then
			callback();
		end
		return;
	end

	url = url or self.FILE_UPLOAD_URL;
	if not url then
		if type(callback) == "function" then
			callback();
		end
		return;
	end

	local faceUrl = nil;
	local requestIns = nil;
	CCTextureCache:sharedTextureCache():removeTextureForKey(path);
	local fdata = CCFileUtils:sharedFileUtils():getFileData(path);
	if fdata then
		local reqData = {
			form_file = {
				filed_name = "file",
				file_path = path,
				content_type = (device.platform == "android") and "multipart/form-data" or "multipart/form_data",
			},
			timeout = 240,
		};
		requestIns = xg.network:requestPost(url, callback, reqData);
	end
	return requestIns;
end

--[[ 发送错误日志 ]]
function XgNetwork:sendErrorMsg2Server(msg)
	if true then return end

	local runScene = display.getRunningScene();
	local platform = require("app.xgame.base.XgPlatform"):getInstance();
	local bundleId = platform:getBundleId();
	local pData = string.format("%s %s %s:%s", "trackback", bundleId, runScene and runScene.name or "none", msg);

	local function req_cb(event)
		(dump_r or dump)(event);
	end
	self:requestPost(self.URL_LOG, req_cb, {
		header = "Content-Type:application/json",
		post_data = pData,
	});
end

--[[ 获取单例 ]]
function XgNetwork:getInstance(...)
	local instance = self.INSTANCE;
	if not instance then
		instance = self:new(...);
		self.INSTANCE = instance;
	end
	return instance;
end

return XgNetwork;
