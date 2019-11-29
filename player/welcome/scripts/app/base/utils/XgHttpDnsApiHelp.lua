--[[
	HttpDnsApi
	@Author: ccb
	@Date: 2017-06-10
]]
local TAG = "#####HttpDnsApiHelp";
local HttpDnsApiHelp = class("HttpDnsApiHelp");

local print = print_r or print;
local printf = printf_r or printf;

HttpDnsApiHelp.USE_SIGN = 1; -- 是否使用鉴权解析接口，1是0否
HttpDnsApiHelp.ACC_ID = 195001; -- httpdns accId
HttpDnsApiHelp.HTTP_DNS_SERVER_IP = "203.107.1.33"; -- httpdns 默认服务器IP
HttpDnsApiHelp.HTTP_DNS_SIGN_SK = "866d115732a6caf6f292b8d23bf71b82"; -- 鉴权秘钥
HttpDnsApiHelp.HTTP_DNS_SIGN_EXPIRED_TK = 60; -- 签名失效时长

--[[ 初始化 ]]
function HttpDnsApiHelp:ctor(ops)
	self._ops = ops or {};
	self._toParseIp = self._ops.ip or ServerIp;
	self._callback = self._ops.callback;
	self._arrIp = {};

	self:getIpsByHttp();
end

--[[ 执行回调 ]]
function HttpDnsApiHelp:doCallback(data)
	if not self._callback or type(self._callback) ~= "function" then return end

	self._callback(data);
end

--[[ 获取请求的url ]]
function HttpDnsApiHelp:getReqUrl()
	local url;
	if self.USE_SIGN == 0 then
		local urlFmt = "https://%s/%d/d?host=%s";
		url = string.format(urlFmt, self.HTTP_DNS_SERVER_IP, self.ACC_ID, self._toParseIp);
	else
		local urlFmt = "https://%s/%d/sign_d?host=%s&t=%d&s=%s";
		local epTm = os.time() + self.HTTP_DNS_SIGN_EXPIRED_TK;
		local sign = crypto.md5(string.format("%s-%s-%s", self._toParseIp, self.HTTP_DNS_SIGN_SK, epTm));
		url = string.format(urlFmt, self.HTTP_DNS_SERVER_IP, self.ACC_ID, self._toParseIp, epTm, sign);
	end
	return url;
end

--[[ 获取IPs ]]
function HttpDnsApiHelp:getIpsByHttp()
	if self._getIpCt and self._getIpCt >= 3 then
		self._getIpCt = 0;
		self:doCallback(false);
		return;
	end

	local url = self:getReqUrl();
	local request = network.createHTTPRequest(function(event)
		local ok = (event.name == "completed");
		local request = event.request;
		if not ok then
			if event.name == "failed" or event.name == "cancelled" then
				local errstr = request:getErrorMessage();
				self:getIpsByHttp();
				print(TAG, "get IPs fail:" .. errstr, event.name);
			end
		else
			local code = request:getResponseStatusCode();
			if code ~= 200 then
				local errstr = request:getErrorMessage();
				self:getIpsByHttp();
				print(TAG, "get IPs fail:" .. errstr, code);
			else
				local response = request:getResponseString();
				local data = json.decode(response);
				self._arrIp = data.ips or {};
				self:doCallback(true);

				if AccModule and type(AccModule.addLog) == "function" then
					local log = "get IPs ips:" .. json.encode(self._arrIp);
					AccModule:addLog(log);
				end
				print(TAG, "get IPs success:", response);
			end
		end
	end, url, "GET");
	request:setTimeout(5);
	request:start();

	self._getIpCt = self._getIpCt or 0;
	self._getIpCt = self._getIpCt + 1;

	print(TAG, "get IPs url:", url);
end

--[[ 获取列表头IP ]]
function HttpDnsApiHelp:getIp()
	if not self._arrIp or not next(self._arrIp) then return end

	return self._arrIp[1];
end

--[[ 废弃列表头IP ]]
function HttpDnsApiHelp:futileIp()
	table.remove(self._arrIp, 1);
end

return HttpDnsApiHelp;
