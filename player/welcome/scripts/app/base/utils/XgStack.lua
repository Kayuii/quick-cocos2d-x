--[[
	栈
	@Author: ccb
	@Date: 2017-06-10
]]
local XgStack = class("XgStack");

--[[
	构造
]]
function XgStack:ctor()
	self._data = {};
end

--[[
	入栈
]]
function XgStack:push(item)
	table.insert(self._data, item);
end

--[[
	出栈
]]
function XgStack:pop()
	local data = self._data;
	table.remove(data, #data);
end

--[[
	获取栈顶值
]]
function XgStack:top()
	local data = self._data;
	return data[#data];
end

--[[
	获取栈底值
]]
function XgStack:back()
	local data = self._data;
	return data[1];
end

--[[
	栈大小/栈顶索引
]]
function XgStack:size()
	return #self._data;
end

--[[
	判断是否为空栈
]]
function XgStack:empty()
	return self:size() == 0;
end

--[[
	取栈某索引上的值
]]
function XgStack:at(index)
	local data = self._data;
	index = #data - index + 1;
	return data[index];
end

--[[
	移除项
]]
function XgStack:removeItem(item)
	local data = self._data;
	local index = nil;
	for i = 1, #data do
		if data[i] == item then
			index = i;
			break;
		end
	end
	
	if not index then return false end
	
	for i = index, #data - 1 do
		data[i] = data[i + 1];
	end
	
	data[#data] = nil;
	
	return true;
end

return XgStack;