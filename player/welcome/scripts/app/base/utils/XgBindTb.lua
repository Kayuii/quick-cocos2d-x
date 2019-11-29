--[[
	metatableEx
]]
local metatableEx = {};

metatableEx.UPD_EVENT_REF = {
	add 		= "__add",
	remove 		= "__remove",
	set 		= "__set",
	update 		= "__update",
	update_to 	= "__updateTo",
};

--[[ 访问 ]]
function metatableEx:__index(key)
	local data = rawget(self, "_data");
	local value = data[key] or metatableEx[key];
	-- print(string.format("access to elm [%s], value is %s.", key, tostring(value)));
	return value;
end

--[[ 更新 ]]
function metatableEx:__newindex(key, value)
	local data = rawget(self, "_data");
	local preV = data[key];
	data[key] = value;

	local upEvent;
	if preV == nil and value ~= nil then
		-- 新增
		upEvent = self.UPD_EVENT_REF["add"];
		self:dispathBindEvent(key, key, value);
	elseif preV and value == nil then
		-- 删除
		upEvent = self.UPD_EVENT_REF["remove"];
	else
		-- 更新
		upEvent = self.UPD_EVENT_REF["set"];
		self:dispathBindEvent(key, key, value);
	end
	self:dispathBindEvent(upEvent, key, value);
	self:dispathBindEvent(self.UPD_EVENT_REF["update"], key, value);
	-- print(string.format("%s elm [%s] to %s.", upEvent, key, tostring(value)));
end

--[[ 绑定 ]]
function metatableEx:bind(key, func, priority, bInit)
	local idx = self:bindEvent(key, func, priority);
	if not bInit then
		if type(func) == "function" then
			func(key, self[key]);
		end
	end
	return idx;
end

--[[ 绑定更新事件 ]]
function metatableEx:bindUpdEvent(key, func, priority)
	local key = self.UPD_EVENT_REF[key];
	if not key then return end

	return self:bind(key, func, priority, true);
end

--[[ 解绑 ]]
function metatableEx:unbind(index)
	if not index then return end

	local keys = rawget(self, "_bind_key");
	local key = keys[index];
	if not key then return end

	keys[index] = nil;
	local binds = rawget(self, "_binds");
	binds[key][index] = nil;
	if not next(binds[key]) then
		binds[key] = nil;
	end
end

--[[ 解绑所有 ]]
function metatableEx:unbindAll()
	rawset(self, "_binds", {});
	rawset(self, "_bind_key", {});
	rawset(self, "_bind_index", 0);
end

--[[ 绑定事件 ]]
function metatableEx:bindEvent(key, func, priority)
	assert(type(func) == "function", "metatableEx func need a function value.");

	local idx = rawget(self, "_bind_index");
	rawset(self, "_bind_index", idx + 1);

	local binds = rawget(self, "_binds");
	binds[key] = binds[key] or {};
	binds[key][idx] = {func = func, prot = priority or 1};

	local keys = rawget(self, "_bind_key");
	keys[idx] = key;

	return idx;
end

--[[ 派发绑定事件 ]]
function metatableEx:dispathBindEvent(upEvent, key, value)
	local binds = rawget(self, "_binds");
	local tag = binds[upEvent];
	if not tag then return end

	-- 根据优先级排序
	local tmp = {};
	for k,v in pairs(tag) do
		table.insert(tmp, v);
	end
	if tmp and next(tmp) then
		table.sort(tmp, function(a, b)
			return a.prot < b.prot;
		end);
	end

	for idx, v in ipairs(tmp) do
		v.func(key, value);
	end
end

--[[
	更新数据，将新表数据更新至旧表，并将旧绑定表作为新表
	原因是旧表可能已经存在绑定，为了是不影响原先的绑定。
	不能仅简单的赋值，这将导致元素发生变化，绑定的事件不会派发。
]]
function metatableEx:updateTo(t)
	if not t or getmetatable(t) ~= metatableEx then 
		return self;
	end

	-- 处理新增和修改
	local bUpdate;
	for k,v in self:pairs() do
		bUpdate = false;
		if type(v) == "table" then
			-- 判断是否绑定表
			if t[k] and getmetatable(v) == metatableEx then
				bUpdate = true;
				t[k] = v:updateTo(t[k]);
			end
		end
		if not bUpdate then
			t[k] = v;
		end
	end

	-- 处理删除
	for k,v in t:pairs() do
		if not self[k] then
			t[k] = nil;
		end
	end

	t:dispathBindEvent(self.UPD_EVENT_REF["update_to"], t);

	return t;
end

--[[ next函数 ]]
function metatableEx:next(key)
	local data = rawget(self, "_data");
	return next(data, key);
end

--[[ pairs函数 ]]
function metatableEx:pairs()
	local key, value;
	local data = rawget(self, "_data");
	return function()
		key, value = next(data, key);
		return key, value;
	end
end

--[[ ipairs函数 ]]
function metatableEx:ipairs()
	local key, value = 0, nil;
	local data = rawget(self, "_data");
	return function()
		key = key + 1;
		value = data[key];
		return (value) and key or nil, value;
	end
end

--[[ 获取原始数据 ]]
function metatableEx:getRawData()
	local data = rawget(self, "_data");
	return data;
end

--[[ 获取原始数据 ]]
function metatableEx:getTotalRawData(t)
	t = t or clone(self:getRawData());
	if next(t) then
		for k, v in pairs(t) do
			if type(v) == "table" and rawget(v, "_binds")
			and getmetatable(v) == metatableEx then
				t[k] = v:getTotalRawData(clone(v:getRawData()));
			end
		end
	end
	return t;
end
--------------------------↑↑↑绑定表↑↑↑---------------------------

local bindTb = {};

--[[ 代理table ]]
local function _newTempTable(t)
	local temp = {
		_data = t,
		_binds = {},		-- 保存回调函数和优先级
		_bind_key = {},		-- 保存绑定的key，解绑时用
		_bind_index = 0,	-- 索引
	};
	return temp;
end

--[[ 检查表是否支持绑定 ]]
function bindTb:isSupportBind(t)
	local binds = rawget(t, "_binds");
	return binds ~= nil;
end

--[[ 检测是否是绑定表 ]]
function bindTb:isBindTable(t)
	local flag = self:isSupportBind(t);
	flag = flag and (getmetatable(t) == metatableEx);
	return flag;
end

--[[ 创建绑定表 ]]
function bindTb:newBindTable(t)
	assert(type(t) == "table", "bindTb t need a table value.");
	local proxy = _newTempTable(t);
	setmetatable(proxy, metatableEx);
	return proxy;
end

--[[ 创建嵌套绑定表 ]]
function bindTb:newNestBindTable(t)
	t = t or {};
	if next(t) then
		for k,v in pairs(t) do
			if type(v) == "table" then
				t[k] = self:newNestBindTable(v);
			end
		end
	end
	return self:newBindTable(t);
end

return bindTb;
