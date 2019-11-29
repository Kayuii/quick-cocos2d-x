--[[
	模块管理基类
	@Author: ccb
	@Date: 2017-06-14
]]
local MgrBase = class("MgrBase");

--[[ 构造 ]]
function MgrBase:ctor()
	self:init();
end

--[[ 初始化 ]]
function MgrBase:init()
	
end

--[[ 请求服务器 ]]
function MgrBase:sendDataToServer(...)

end

--[[ 处理服务器返回数据 ]]
function MgrBase:handleDataFromServer(...)
	
end

--[[ 监听大厅重连 ]]
function MgrBase:onCatchHallResumeHandle()
	self._hallResumeHandle = function()
		local func = self.onHallResumeHandle;
		if func and type(func) == "function" then
			local curTm = xg.localData:getTimeStamp();
			local etBgTm = xg.localData:getEGTimeStamp();
			func(self, {
				cur_tm = curTm,
				etbg_tm = etBgTm,
				sub_tm = (etBgTm ~= 0) and (curTm - etBgTm) or 0,
			});
		end
	end
	NotificationManager.addNotiListenerWithMsg(HALL_RESUME_NOTI, self._hallResumeHandle);
end

--[[ 注册监听 ]]
function MgrBase:registerHandler(handler)
	self._handlers = self._handlers or {};
	local key = string.format("%s_%s", handler.msgType, handler.protoId);
	if self._handlers[key] then return end

	ServerClient:registHandler(handler);
	self._handlers[key] = handler;
end

--[[ 取消单个监听 ]]
function MgrBase:unregisterSingleHandler(handler)
	if not handler and not next(handler) then return end

	local mType, proId = handler.msgType, handler.protoId;
	if not mType or not proId then return end

	local key = string.format("%s_%s", mType, proId);
	local tag = self._handlers[key];

	if not tag then return end

	ServerClient:deleteHandler(tag);
	self._handlers[key] = nil;
end

--[[ 取消监听 ]]
function MgrBase:unregisterHandler()
	if not self._handlers or not next(self._handlers) then return end

	for k, v in pairs(self._handlers) do
		ServerClient:deleteHandler(v);
	end
	self._handlers = nil;

	if self._hallResumeHandle then
		NotificationManager.removeNotiListenerWithMsg(HALL_RESUME_NOTI, self._hallResumeHandle);
		self._hallResumeHandle = nil;
	end
end

--[[ 切换账号时的清除 ]]
function MgrBase:onSwitchAccountCleanup()
	self:unregisterHandler();
end

--[[ 析构 ]]
function MgrBase:dtor()
	self:onSwitchAccountCleanup();
end

return MgrBase;
