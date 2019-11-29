--[[
	用于简单富文本的解析
	@Author: ccb
	@Date: 2017-07-23
]]

local _M = {};

local print = print;
local table = table;
local string = string;

local TAG = "RichTextParser";
local DIV_BEGIN = "<div>";
local DIV_END = "</div>";
local BOOLEAN_TRUE = "true";
local BOOLEAN_FALSE = "false";

function _M.parse(str)

	-- 用于存储解析结果
	local arrParsed = {};

	-- 检测开头和结尾是否为标签 <xxx>即为标签
	if not string.find(str, "^%b<>.+%b<>$") then
		-- 在最外层包装一个标签，便于解析时的统一处理，不用处理没有包装标签的情况
		str = table.concat({DIV_BEGIN, str, DIV_END})
	end

	-- 标签头栈，用于存储标签头(<div>是标签头，</div>是标签尾)
	-- 标签头存储了格式信息，碰到标签时可以直接使用当前栈顶的标签头格式信息，应用到标签之间的内容上
	-- 迭代所有格式为<xxx>的标签(包含了标签头和标签尾)

	local index = 0;
	local headStack = {};
	for sIdx, eIdx in function() return string.find(str, "%b<>", index) end do
		local tag = string.sub(str, sIdx, eIdx)
		if string.find(tag, "^</") then -- 检测字符串是否以"</"开头
			-- 标签尾
			_M.handleTail(headStack, arrParsed, str, tag, sIdx, eIdx);
		elseif string.find(tag, "/>$") then -- 检测以'/>'结尾
			-- 自闭合标签
			_M.handleSelfCls(headStack, arrParsed, str, tag, sIdx, eIdx);
		else -- 检测到标签头
			_M.handleHead(headStack, arrParsed, str, tag, sIdx, eIdx);
		end
		index = eIdx + 1;
	end

	return arrParsed;
end

--[[ 处理标签头 ]]
function _M.handleHead(headStack, arrParsed, str, head, sIdx, eIdx)

	-- 取出当前栈顶位置的标签信息
	local topInfo = _M.peekstack(headStack);
	if topInfo then
		-- 获得当前标签头和上一个标签头之间内容(标签嵌套造成)
		local cont = string.sub(str, topInfo.eIdx + 1, sIdx - 1);
		-- 解析两个标签头之间的内容
		local arrRet = _M.parseWithCont(topInfo.head, cont);
		table.insert(arrParsed, arrRet);
	end

	-- 将当前标签头和位置信息，放入栈顶位置
	_M.pushstack(headStack, {head = head, sIdx = sIdx, eIdx = eIdx});
end

--[[ 处理标签尾 ]]
function _M.handleTail(headStack, arrParsed, str, tail, sIdx, eIdx, bSelfCls)
	-- 检测到标签尾，可以解析当前标签范围内的串，标签头在栈顶位置
	-- 将与标签尾对应的标签头出栈(栈顶)
	-- 解析栈顶标签头和当前标签尾之间的内容

	local topInfo = _M.popstack(headStack)
	if topInfo then
		-- 检测标签是否匹配
		if not _M.checkHeadTailMatch(topInfo.head, tail) then
			return print(string.format("%s handleTail can not match(%s, %s).", TAG, topInfo.head, tail));
		end

		-- 获得当前标签尾和对应标签头之间内容
		local cont = string.sub(str, topInfo.eIdx + 1, sIdx - 1);
		local arrRet = _M.parseWithCont(topInfo.head, cont, bSelfCls);
		table.insert(arrParsed, arrRet);

		-- 因为此前内容都解析过了，所以修改栈顶标签头信息，让其修饰范围改变为正确的
		-- 修改当前栈顶标签头位置到当前标签尾的范围
		local topUnused = _M.peekstack(headStack);
		if topUnused then
			topUnused.sIdx = sIdx;
			topUnused.eIdx = eIdx;
		end
	end
end

--[[ 处理自闭合标签 ]]
function _M.handleSelfCls(headStack, arrParsed, str, tag, sIdx, eIdx)
	_M.handleHead(headStack, arrParsed, str, tag, sIdx, eIdx);
	_M.handleTail(headStack, arrParsed, str, tag, sIdx, eIdx, true);
end

--[[ 检测标签头和标签尾是否配对，即标签名是否相同 ]]
function _M.checkHeadTailMatch(head, tail)
	local headName = _M.parseName(head);
	local tailName = _M.parseName(tail);
	return headName == tailName;
end

--[[ 整合标签头属性和内容 ]]
function _M.parseWithCont(head, cont, bSelfCls)
	-- 非自闭合标签则，则检测内容，内容为空则直接返回
	if not bSelfCls then
		if not cont or cont == "" then return end
	else
		cont = nil; -- 自闭合标签
	end

	-- 获得标签名称
	local name = _M.parseName(head);

	-- 解析标签属性
	local arrRet = _M.parseHead(head);
	arrRet.tagType = name;
	arrRet.cont = cont;
	return arrRet;
end

--[[ 从标签头或者标签尾解析出标签名称 ]]
function _M.parseName(tag)
	-- 解析标签名
	local sIdx, eIdx = string.find(tag, "%w+")
	if not sIdx then
		print(string.format("%s parseName [%s] not found.", TAG, tag));
		return nil;
	end

	-- 获得标签名称
	local tagName = string.sub(tag, sIdx, eIdx);
	local tagName = string.lower(tagName);
	return tagName;
end

--[[ 解析标签头属性 ]]
function _M.parseHead(head)

	-- 匹配格式：pro=value
	-- value要求非空白字符并且不含有‘>’

	local arr = {};
	for pro in string.gmatch(head, "[%w%_]+%=[^%s%>]+") do
		
		-- 分离属性名和属性值
		local markPos = string.find(pro, "=");
		local proName = string.sub(pro, 1, markPos - 1);
		local proValue = string.sub(pro, markPos + 1, string.len(pro));

		-- 属性名转为小写
		proName = string.lower(proName);

		-- 属性值处理
		local continue = false;

		-- 检测是否为字符串(单引号或者双引号括起来)
		local sIdx, eIdx = string.find(proValue, "['\"].+['\"]");
		if sIdx then
			proValue = string.sub(proValue, sIdx + 1, eIdx - 1);
			continue = true;
		end

		-- 检测是否为布尔值
		if not continue then
			local proValueL = string.lower(proValue);
			if proValueL == BOOLEAN_TRUE then 
				proValue = true; 
				continue = true;
			elseif proValueL == BOOLEAN_FALSE then 
				proValue = false;
				continue = true;
			end
		end

		-- 检测是否为数字
		if not continue then
			local proValueN = tonumber(proValue);
			if proValueN then 
				proValue = proValueN;
				continue = true;
			end
		end

		-- 若以上都不是，则默认直接为字符串
		arr[proName] = proValue;
	end
	return arr;
end

function _M.peekstack(stackTb)
	return stackTb[#stackTb];
end

function _M.pushstack(stackTb, elem)
	table.insert(stackTb, elem);
end

function _M.popstack(stackTb)
	local elem = stackTb[#stackTb];
	stackTb[#stackTb] = nil;
	return elem;
end

return {
	parse = _M.parse,
};
