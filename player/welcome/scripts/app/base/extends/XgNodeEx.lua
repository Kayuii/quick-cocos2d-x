--[[
	Node Extension
	@Author: ccb
	@Date: 2017-06-06
]]
cc = cc or {};
local Node = cc.Node;
local TAG = "#####XgNodeEx";
if not Node then return end

function Node:isNull()
	return tolua.isnull(self);
end

function Node:notNull()
	return not tolua.isnull(self);
end

--[[
	type只能得到table, number, string, function等类型
	对于node和sprite并不能区分, 都是userdata
	typeName返回更加详细的类型, 类型注册在tolua中
	ep:
	print(display.newNode():typeName()) -- cc.Node
]]
function Node:typeName()
	return tolua.type(self);
end

--[[ 设置可触摸且设置是否吞噬 ]]
function Node:swallowTouch(flag)
	self:setTouchEnabled(true);
	self:setTouchSwallowEnabled(flag);
	return self;
end

--[[ 判断点是否包含在区域中 ]]
function Node:isPointInExt(rc, pt)
	local rect = cc.rect(rc.x, rc.y, rc.width, rc.height)
	return cc.rectContainsPoint(rect, pt);
end

--[[ 节点点击 ]]
function Node:onClicked(callback)
	local tpEvent = nil;
	local handle = self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			tpEvent = event;
			return true;
		elseif event.name == "moved" then
			if tpEvent then
				if getDistance(event, tpEvent) > 20 then
					tpEvent = nil;
				end
			end
			return true;
		elseif event.name == "ended" then
			if tpEvent then
				tpEvent = nil;
				if type(callback) == "function" then
					callback(event);
				end
			end
		end
	end);

	return handle;
end

local old_setContentSize = Node.setContentSize;
function Node:setContentSize(w, h)
	local size = w;
	if size and type(size) ~= "userdata" and tonumber(size) then
		size = cc.size(w, h or 0);
	end
	old_setContentSize(self, size);
	return self;
end

local old_setAnchorPoint = Node.setAnchorPoint;
function Node:setAnchorPoint(px, py)
	local p = px;
	if p and type(p) ~= "userdata" and tonumber(p) then
		p = cc.p(px, py or 0);
	end
	old_setAnchorPoint(self, p);
	return self;
end

--------------------------↓↓↓节点数据绑定相关↓↓↓---------------------------

--[[ 绑定属性改变事件 ]]
function Node:bind(bindTb, keyName, func, priority, isInit)
	self:__checkBindParams(bindTb, func);

	local function onPropChange(key, value)
		func(self , value);
	end
	local index = bindTb:bind(keyName , onPropChange, priority, isInit);
	self:__autoUnbind(bindTb , keyName , index);
	return index;
end

--[[ 绑定属性增加事件 ]]
function Node:bindAdd(bindTb , func, priority)
	self:__checkBindParams(bindTb, func);

	local function onAdd(key, value)
		func(self, key, value);
	end
	local index = bindTb:bindUpdEvent("add", onAdd, priority);
	self:__autoUnbind(bindTb, bindTb.UPD_EVENT_REF["add"], index);
	return index;
end

--[[ 绑定属性移除事件 ]]
function Node:bindRemove(bindTb , func, priority)
	self:__checkBindParams(bindTb, func);

	local function onRemove(key, value)
		func(self, key, value);
	end
	local index = bindTb:bindUpdEvent("remove", onRemove, priority);
	self:__autoUnbind(bindTb, bindTb.UPD_EVENT_REF["remove"], index);
	return index;
end

--[[ 绑定属性更新事件 ]]
function Node:bindUpdate(bindTb , func, priority)
	self:__checkBindParams(bindTb, func);

	local function onUpdate(key, value)
		func(self, key, value);
	end
	local index = bindTb:bindUpdEvent("update", onUpdate, priority);
	self:__autoUnbind(bindTb, bindTb.UPD_EVENT_REF["update"], index);
	return index;
end

--[[ 绑定表的更新事件 ]]
function Node:bindUpdateTo(bindTb, func, priority)
	self:__checkBindParams(bindTb, func);

	local function onUpdateTo (key, value)
		func(self, key, value);
	end
	local index = bindTb:bindUpdEvent("update_to", onUpdateTo, priority);
	self:__autoUnbind(bindTb, bindTb.UPD_EVENT_REF["update_to"], index);
	return index;
end

--[[ 解绑 ]]
function Node:unbind(bindTb, bindName, index)
	local allBinds = self.__allBinds;
	if not allBinds then return end

	local bindsList = allBinds[bindTb];
	if not bindsList then return end

	bindName = bindTb.UPD_EVENT_REF[bindName] or bindName;
	local binds = bindsList[bindName];
	if not binds then return end

	local unbinder = binds[index];
	if not unbinder then return end

	binds[index] = nil;
	unbinder();
	return true;
end

--[[ 解绑所有 ]]
function Node:unbindAll()
	local allBinds = self.__allBinds;
	if not allBinds then return end

	for _, bindsList in pairs(allBinds) do
		for _, unbinderList in pairs(bindsList) do
			for _, unbinder in pairs(unbinderList) do
				unbinder();
			end
		end
	end
	self.__allBinds = nil;

	if self.__onNodeEvent4Bind then
		self:unregisterScriptHandler(self.__onNodeEvent4Bind);
		self.__onNodeEvent4Bind = nil;
	end
end

--[[ 自动解绑 Node对象释放时进行解绑 ]]
function Node:__autoUnbind(bindTb, bindName, bindIndex)

	local function unbind()
		bindTb:unbind(bindIndex);
	end

	self.__allBinds = self.__allBinds or {};
	local allBinds = self.__allBinds;
	allBinds[bindTb] = allBinds[bindTb] or {};
	local bindsList = self.__allBinds[bindTb];
	bindsList[bindName] = bindsList[bindName] or {};

	-- 如果之前绑定过，则先解绑
	local unbinder = bindsList[bindName][bindIndex];
	if unbinder then
		unbinder();
	end
	bindsList[bindName][bindIndex] = unbind;

	if not self.__onNodeEvent4Bind then
		local function onNodeEvent(event)
			if event.name == "cleanup" then
				self:unbindAll();
			end
		end
		self:registerScriptHandler(onNodeEvent);
		self.__onNodeEvent4Bind = onNodeEvent;
	end
end

--[[ 检查参数 ]]
function Node:__checkBindParams(bindTb, func)
	assert(type(bindTb) == "table", TAG .. " __checkBindParams: need a table value.");
	assert(type(func) == "function", TAG .. " __checkBindParams: need a function value.");
	assert(xg.bindTable:isBindTable(bindTb), TAG .. " __checkBindParams: table is not support data bindding.");
end
--------------------------↑↑↑节点数据绑定相关↑↑↑---------------------------

--------------------------↓↓↓事件注册回调重载↓↓↓---------------------------
-- 重载的目的:支持注册多个事件响应函数
-- local old_registerScriptHandler = Node.registerScriptHandler;
-- local old_unregisterScriptHandler = Node.unregisterScriptHandler;
--[[ 注册事件 ]]
function Node:registerScriptHandler(handler)
	assert(type(handler) == "function", TAG .. " registerScriptHandler: handler is not a valid function.");

	if self.__scriptHanderList then
		self.__scriptHanderList[handler] = handler;
	else
		self.__scriptHanderList = {};
		self.__scriptHanderList[handler] = handler;

		local function onNodeEvent(event)
			if self.__scriptHanderList and next(self.__scriptHanderList) then
				for k, v in pairs(self.__scriptHanderList) do
					v(event);
				end
			end
		end
		self:addNodeEventListener(cc.NODE_EVENT, onNodeEvent);
	end
end

--[[ 解注事件 ]]
function Node:unregisterScriptHandler(handler)
	if self.__scriptHanderList then
		if handler then
			self.__scriptHanderList[handler] = nil;
		end
		local index = next(self.__scriptHanderList);
		if not index then
			self.__scriptHanderList = nil;
			self:removeAllNodeEventListeners();
		end
	end
end

--[[ 解注所有事件 ]]
function Node:unregisterAllScriptHandler()
	self:removeAllNodeEventListeners();
end
--------------------------↑↑↑事件注册回调重载↑↑↑---------------------------

--------------------------↓↓↓注册控件ID相关↓↓↓---------------------------
--[[ 注册控件id ]]
function Node:registerCtrlId(id, pos, size, onClickFunc)
	if not id then return end

	xg.ctrlMap = xg.ctrlMap or {};
	assert(not xg.ctrlMap[id], string.format("%s registerCtrlId: ctrlId(%s) is registered.", TAG, id));

	xg.ctrlMap[id] = {
		ctrl = self, 
		pos = pos, 
		size = size, 
		onClickFunc = onClickFunc
	};

	local function onNodeEvent(event)
		if event.name == "cleanup" then
			xg.ctrlMap[id] = nil;
		end
	end
	self:registerScriptHandler(onNodeEvent);
end

--[[ 解注控件id ]]
function Node:unregisterCtrlId(id)
	if not id then return end

	xg.ctrlMap = xg.ctrlMap or {};
	xg.ctrlMap[id] = nil;
end
--------------------------↑↑↑注册控件ID相关↑↑↑---------------------------

--------------------------↓↓↓红点绑定相关↓↓↓---------------------------
--[[ 绑定红点 ]]
function Node:bindRedDot(options)
	options = checktable(options);
	if not options.id then return end

	local id = options.id;
	local offset = options.offset or cc.p(0, 0);

	if type(id) ~= "table" then
		id = {
			[1] = {
				id = id, 
				extId = options.extId,
			},
		};
	end

	-- 默认位置为控件右上角位置
	local function getTagInfo()
		local pos = cc.p(0, 0);
		local cPos = cc.p(0, 0);
		local cName = self.__cname;
		local box = self:getCascadeBoundingBox();
		local anch = cc.p(self:getAnchorPoint());
		if cName == "UIPushButton" then
			self.getSize = self.getSize or function(o)
				if o.sprite_[1] then
					return o.sprite_[1]:getContentSize();
				end
				return cc.size(0, 0);
			end
			pos.x = pos.x - (anch.x - 0.5) * self:getSize().width;
			pos.y = pos.y - (anch.y - 0.5) * self:getSize().height;
		else
			pos.x = pos.x + box.width * 0.5;
			pos.y = pos.y + box.height * 0.5;
		end
		cPos = cc.p(pos.x, pos.y);
		pos.x = pos.x + box.width * 0.5 + offset.x;
		pos.y = pos.y + box.height * 0.5 + offset.y;

		local tb = {
			pos = pos,
			c_pos = cPos,
			size = cc.size(box.width, box.height),
		};
		return tb;
	end

	if self.__redDot == nil then
		local tInfo = getTagInfo();
		local dot = import("app.xgame.view.other.RedDot").new({
			data = options,
			ext_data = tInfo,
		});
		dot:align(display.CENTER, tInfo.pos.x, tInfo.pos.y);
		dot:addTo(self, 100);
		self.__redDot = dot;
	end

	for idx, v in pairs(id) do
		self.__redDot:bindRdId(v.id, v.extId);
	end
	return self.__redDot;
end

--[[ 解绑红点 ]]
function Node:unbindRedDot(options)
	if self.__redDot then
		self.__redDot:unbindRdId(options.id, options.extId);
	end
end

--[[ 移除绑定的红点 ]]
function Node:removeBindRedDot()
	if self.__redDot then
		self.__redDot:removeSelf();
		self.__redDot = nil;
	end
end

--[[ 获取绑定的红点 ]]
function Node:getBindRedDot()
	return self.__redDot;
end
--------------------------↑↑↑红点绑定相关↑↑↑---------------------------
