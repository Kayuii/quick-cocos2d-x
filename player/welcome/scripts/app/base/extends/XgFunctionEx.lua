--[[
	Function Extension
	@Author: ccb
	@Date: 2017-06-10 
]]

--[[ 读取语言包 ]]
function _T(...)
	if xg and xg.language and type(xg.language.getDataByKey) == "function" then
		return xg.language:getDataByKey(...);
	else
		local args = {...};
		local key = args[1];
		if not key then return end

		local str = XTEXT[key] or key;
		if #args > 1 then
			for i = 1, #args do
				args[i] = tostring(args[i]);
			end
			str = string.format(str, unpack(args, 2, table.maxn(args)));
		end
		return str;
	end
end

--[[ 读取语言 + ":" ]]
function _TC(...)
	return _T(...) .. ":";
end

--[[ 读取语言 + "：" ]]
function _TC2(...)
	return _T(...) .. "：";
end

--[[ 读取语言 + 左右引号 ]]
function _TQ(...)
	return "\"" .. _T(...) .. "\"";
end

--[[ 读取语言 + 左右括号 ]]
function _TB(...)
	return "(" .. _T(...) .. ")";
end

--[[ 读取语言 + 左右方括号 ]]
function _TSB(...)
	return "[" .. _T(...) .. "]";
end

--[[ 获取错误码对应的文本 ]]
function _TERR(...)
	if xg and xg.config and xg.config.errCode_cn then
		local args = {...};
		local code = args[1];
		if not code then return end

		code = xg.config.errCode_cn:getData(code);
		args[1] = code;
		return _T(unpack(args, 1, table.maxn(args)));
	else
		return _T(...);
	end
end

--[[
	模拟三元运算
	---------------------------------
	local res = cal_3(math.random(0, 1) == 1, 1, 2);
	local res = cal_3(function()
		-- todo
		return flag;
	end, 1, 2);
]]
function cal_3(flag, a, b)
	if type(flag) == "function" then
		flag = flag();
	end

	if not a then
		if flag then
			return a;
		else
			return b;
		end
	else
		return flag and a or b;
	end
end

--[[
	模拟try-catch
	---------------------------------
	try{
		function()
			print(s + 1);
		end,
		catch = function()
			-- 捕获到异常
		end,
	};
]]
function try(args)
	if type(args) ~= "table" then
		print("try user error:", debug.traceback());
		return;
	end
	local func = args[1];
	local errorH = (#args >= 2) and args[2] or __G__TRACKBACK__;
	args.catch = args.catch or errorH;
	assert(type(func) == "function", "try need a function value.");
	assert(type(args.catch) == "function", "catch need a function value.");
	local _, ret = xpcall(func, args.catch);
	args = nil;
	return ret;
end

--[[
	模拟switch-case
	---------------------------------
	switch(2):case({
		[1] = function()
			print("value 1");
	    end,
		[2] = function()
			print("value 2");
		end,
		["default"] = function()
			print("value def");
		end,
	});
]]
local switchOpe = {};
switchOpe.s_def = "default";
switchOpe.s_metatable = {
	__index = function(t, k)
		if rawget(t, switchOpe.s_def) then
			return rawget(t, switchOpe.s_def);
		end
	end,
	__metatable = "switch_metatable",
};
switchOpe.create = function()
	local sTb = {};
	setmetatable(sTb, switchOpe.s_metatable);
	sTb.case = function(t, desTb, ...)
		table.merge(t, desTb or {});
		local k = t._select or switchOpe.s_def;
		local branch = t[k];
		if type(branch) == "function" then
			return branch(...);
		else
			return branch;
		end
	end

	return sTb;
end

function switch(k)
	local sw = switchOpe:create();
	sw._select = k;
	return sw;
end

--[[ 获取已注册的控件信息 ]]
function getCtrlById(id)
	if not id then return end
	return xg and xg.ctrlMap and xg.ctrlMap[id];
end

--[[ 创建绑定表 ]]
function newBindTable(tb)
	return xg.bindTable:newBindTable(tb);
end

--[[ 创建嵌套绑定表 ]]
function newNestBindTable(tb)
	return xg.bindTable:newNestBindTable(tb);
end

--[[ 获取类型 ]]
function toluaType(obj)
	return tolua.type(obj);
end

--[[ 判断对象是否为空 ]]
function toluaIsNil(obj)
	return tolua.isnull(obj);
end

--[[ 获取2点间距 ]]
function getDistance(ps, pe)
	if not ps or not pe then return end

	local tagType = "CCPoint";
	if toluaType(ps) ~= tagType and ps.x and ps.y then
		ps = cc.p(ps.x, ps.y);
	end
	if toluaType(pe) ~= tagType and pe.x and pe.y then
		pe = cc.p(pe.x, pe.y);
	end

	if toluaType(ps) ~= tagType or toluaType(pe) ~= tagType then
		return;
	end

	local pSub = cc.pSub or ccpSub;
	local pLen = cc.pGetLength or ccpLength;
	local sub = pSub(ps, pe);
	local len = pLen(sub);
	return len;
end

--[[
	获取utf8编码字符串正确长度
	@params str[string] 字符串
	@return number[number] 长度
]]
function utfstrlen(str)
	if str == nil then 
		return 0;
	end

	local len = #str;
	local left = len;
	local cnt = 0;
	local ary = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc};
	while left ~= 0 do
		local tmp = string.byte(str, -left);
		local i = #ary;
		while ary[i] do
			if tmp >= ary[i] then 
				left = left - i;
				break;
			end
			i = i - 1;
		end
		cnt = cnt + 1;
	end
	return cnt;
end

--[[
	根据开始位置和结束位置截取utf8编码字符串
	@params str[string] 字符串
			sIdx[number] 开始位置
			eIdx[number] 结束位置
	@params str[string] 字符串
	-----------------------------------------
	UTF8的编码规则：
	1. 字符的第一个字节范围：0x00—0x7F(0-127), 或者 0xC2—0xF4(194-244); UTF8 是兼容 ascii 的，所以 0~127 就和 ascii 完全一致。
	2. 0xC0, 0xC1,0xF5—0xFF(192, 193 和 245-255)不会出现在UTF8编码中 。
	3. 0x80—0xBF(128-191)只会出现在第二个及随后的编码中(针对多字节编码，如汉字) 。
]]
function truncateUtf8String(str, sIdx, eIdx)
	local dropping = string.byte(str, eIdx + 1);
	if dropping ~= nil then
		if dropping >= 128 and dropping < 192 then
			return truncateUtf8String(str, sIdx, eIdx - 1);
		end
	end
	return string.sub(str, sIdx, eIdx);
end

--[[
	拆分出单个字符
	@params str[string] 字符串
	@params list[table] 字符数组
			len[number] 字符串长度
]]
function stringToChars(str)
	local list = {}
	local len = string.len(str)
	local i = 1 
	while i <= len do
		local c = string.byte(str, i)
		local shift = 1
		if c > 0 and c <= 127 then
			shift = 1
		elseif (c >= 192 and c <= 223) then
			shift = 2
		elseif (c >= 224 and c <= 239) then
			shift = 3
		elseif (c >= 240 and c <= 247) then
			shift = 4
		end
		local char = string.sub(str, i, i+shift-1)
		i = i + shift
		table.insert(list, char)
	end
	return list, len
end

function splitStrByWidth(str, width, fSize)
	local sw = xg.font.getFontWidthEx(str, fSize);
	if sw <= width then
		return str, nil, sw, nil;
	end

	local arr = stringToChars(str);

	local curW = 0;
	local curIdx = 0;
	while curW < width do
		curIdx = curIdx + 1;
		curW = curW + xg.font.getFontWidthEx(arr[curIdx], fSize);
	end
	curIdx = curIdx - 1;
	if curIdx == 0 then
		return ;
	end

	local arrS1 = {};
	for i = 1, curIdx do
		table.insert(arrS1, arr[i]);
	end

	local s1 = table.concat(arrS1);
	local s2 = string.sub(str, string.len(s1) + 1, - 1);
	local sw2 = xg.font.getFontWidthEx(s2, fSize);

	return s1, s2, curW, sw2;
end

--[[
	@param  dst:目标数组
	@param  src:被拷贝的数组
	@param  length拷贝总长度
	@dst_offset 目标数组的起始indx
	@src_offset 拷贝起始indx
]]
function g_fuc_copyarray(dst, src, length, dst_offset, src_offset)
	length = length or 0;
	dst_offset = dst_offset or 0;
	src_offset = src_offset or 0;
	if length == 0 and src ~= nil then
		length = #src;
	end
	for i = 1, length do
		dst[dst_offset + i] = src[src_offset + i];
	end
end

if not display.newLine then
	function display.newLine(points, params)
		local radius;
		local scale;
		local borderColor;
		if not params then
			borderColor = cc.c4f(0, 0, 0, 1);
			radius = 0.5;
			scale = 1.0;
		else
			borderColor = params.borderColor or cc.c4f(0 ,0, 0, 1);
			radius = (params.borderWidth and params.borderWidth/2) or 0.5;
			scale = checknumber(params.scale or 1.0);
		end

		for i, p in ipairs(points) do
			p = cc.p(p[1] * scale, p[2] * scale);
			points[i] = p;
		end

		local drawNode = cc.DrawNode:create();
		drawNode:drawSegment(points[1], points[2], radius, borderColor);

		return drawNode;
	end
end

function setUrlMd5(url, save_path, isOvertime)
	if not url then return end

	if not isOvertime then -- 如果不是超时
		local b, path = getUrlMd5(url, save_path);
		if not b then
			GameData.netSprite = GameData.netSprite or {}; 
			GameData.netSprite[crypto.md5(url)] = 1;
			GameState.save(GameData);
		end
	end
end

function getUrlMd5(url, save_path)
	if not url then return end
	if not save_path then return end

	local tempMd5 = crypto.md5(url);
	local file = string.format("%s%s.png", save_path, tempMd5);
	GameData.netSprite = GameData.netSprite or {};
	GameState.save(GameData);

	if GameData.netSprite[tempMd5] and io.exists(file) then
		return true, file; -- 存在，返回本地存储文件完整路径
	end
	return false, file; -- 不存在，返回将要存储的文件路径备用
end

--[[ 判断是否为正整数 ]]
function bolPositiveInteger(num)
	if not num and num >= 0 then return end

	local s, e = string.find(num, "^[0-9]+");
	return (s and e and e == string.len(num));
end

--[[ 组成头像URL ]]
function fmtPhotoUrl(url)
	if not url then return end

	local netwUtil = xg and xg.network;
	if not netwUtil then
		local XgNetwork = require("app.xgame.base.XgNetwork");
		if XgNetwork and type(XgNetwork.getInstance) == "function" then
			netwUtil = XgNetwork:getInstance();
		end
	end
	if netwUtil then
		return string.format("%s%s", netwUtil.BASE_DOMAIN, url);
	else
		return url;
	end
end
