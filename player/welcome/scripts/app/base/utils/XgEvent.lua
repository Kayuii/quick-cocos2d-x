--[[
	事件监听/派发
	@Author: ccb
	@Date: 2017-06-11
]]
local TAG = "#####XgEvent";
local XgEvent = class("XgEvent");

--[[ 构造 ]]
function XgEvent:ctor()
	self._GUID = 1;	-- 句柄的自增标识符
	self._aryListener = {}; -- 监听器列表
end

--[[ 添加监听 ]]
function XgEvent:addListener(eventName, handleFunc)
	self._aryListener[eventName] = self._aryListener[eventName] or {};

	self._GUID = self._GUID + 1;
	self._aryListener[eventName][self._GUID] = handleFunc;
	
	return self._GUID;
end

--[[ 取消监听 ]]
function XgEvent:removeListener(handleToRemove)
	for eventName, listenersForEvent in pairs(self._aryListener) do
		for handle, _ in pairs(listenersForEvent) do
			if handle == handleToRemove then
				listenersForEvent[handle] = nil;
				local k, v = next(listenersForEvent);
				if not k then
					self._aryListener[eventName] = nil;
				end
				return;
			end
		end
	end
end

--[[
	派发消息， 会等待所有消息响应函数同步/异步完成
	@onEndFunc 所有事件完成后调用onEndFunc， 如果不需要等待则传nil
]]
function XgEvent:dispatchEvent(event, onEndFunc)
	local eventName = event.name;
	local endFunc = (type(onEndFunc) == "function") and onEndFunc or nil;

	local l = self._aryListener[eventName];
	if not l then
		if endFunc then
			endFunc(); 
		end
		return;
	end
	
	if endFunc then
		local count = 0;
		local removeList = {};
		local function _onEndFunc()
			assert(count > 0, TAG .. ": callback function count exception.");
			count = count - 1;
			if (count == 0) then
				endFunc();
			end
		end
		
		for handle, listener in pairs(l) do
			local bAsync, bRemove = listener(event, _onEndFunc);
			
			if bAsync then
				count = count + 1;
			end
			
			if bRemove then
				table.insert(removeList, handle);
			end
		end
		
		for k, v in pairs(removeList) do
			l[v] = nil;
		end
		
		if not next(l) then
			self._aryListener[eventName] = nil;
		end
		
		if count == 0 then
			endFunc();
		end
	else
		local removeList = {};
		for handle, listener in pairs(l) do
			local bAsync, bRemove = listener(event);
			
			if bRemove then
				table.insert(removeList, handle);
			end
		end
		
		for k, v in pairs(removeList) do
			l[v] = nil;
		end
		
		if not next(l) then
			self._aryListener[eventName] = nil;
		end
	end
end

--[[ 获取事件信息 ]]
function XgEvent:getEventInfo()
	local eventCt = 0;
	local handleCt = 0;
	for eventName, listenersForEvent in pairs(self._aryListener) do
		eventCt = eventCt + 1;
		
		local curCount = 0;
		for handle, _ in pairs(listenersForEvent) do
			handleCt = handleCt + 1;
			curCount = curCount + 1;
		end
		
		print(string.format("%s: %s have %d handle.", TAG, eventName, curCount));
	end
	
	print(string.format("%s: info eventCount = %d, handleCount = %d.", TAG, eventCt, handleCt));
end

--[[ 是否存在某事件 ]]
function XgEvent:hasEvent(eventName)
	local l = self._aryListener[eventName];
	return l and true or false;
end

--[[ 获取单例 ]]
function XgEvent:getInstance(...)
	local instance = self.INSTANCE;
	if not instance then
		instance = self.new(...);
		self.INSTANCE = instance;
	end
	return instance;
end

return XgEvent;
