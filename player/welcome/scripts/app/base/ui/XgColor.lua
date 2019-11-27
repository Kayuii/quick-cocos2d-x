--[[
	自定义颜色
	@Author: ccb
	@Date: 2017-06-06 
]]
-- 兼容处理
cc = cc or {};
cc.c3b = cc.c3b or ccc3;
cc.c4b = cc.c4b or ccc4;
cc.c4f = cc.c4f or ccc4f;

local XgColor = {
	red = cc.c3b(195, 29, 29),
	redl = cc.c3b(255, 209, 209),
	green = cc.c3b(32, 198, 71),
	greenlt = cc.c3b(170, 227, 210),
	greendt1 = cc.c3b(83, 142, 140),
	gold = cc.c3b(233, 205, 137),
	goldlt = cc.c3b(255, 242, 134),
	goldlt2 = cc.c3b(255, 241, 186),
	gray = cc.c3b(104, 104, 104),
	grayd = cc.c3b(129, 152, 155),
	black = cc.c3b(0, 0, 0),
	white = cc.c3b(255, 255, 255),
	bluelt = cc.c3b(0, 234, 255), -- 亮蓝
	bluesl = cc.c3b(15, 241, 198), -- 海蓝
	grayblue = cc.c3b(151, 178, 178), -- 灰蓝
	graybluelt = cc.c3b(136, 196, 197), -- 亮灰蓝
	cyanblue = cc.c3b(192, 255, 235), -- 浅青色
	cyanblue2 = cc.c3b(33, 183, 153), -- 青色
	blue_t = cc.c3b(202, 214, 224), -- 浅蓝色标题
	orange = cc.c3b(255, 134, 0), -- 橘色
	orange2 = cc.c3b(255, 210, 109), -- 橘色
};
local tpColor = XConstants and XConstants.Colors or {};
table.merge(XgColor, tpColor);

--[[
	c3b转c4b(ccc3转ccc4)
	@params c3b[table] 
			alpha[number 0~255] 透明值
]]
function XgColor.c3b2C4b(c3b, alpha)
	if nil == c3b then return end

	return cc.c4b(c3b.r, c3b.g, c3b.b, alpha or 255);
end

--[[
	c3b转c4f(ccc3转ccc4f)
	@params c3b[table] 
			alpha[number 0~255] 透明值
]]
function XgColor.c3b2C4f(c3b, alpha)
	if nil == c3b then return end

	local a = (alpha or 255)/255;
	return cc.c4f(c3b.r/255, c3b.g/255, c3b.b/255, a);
end

--[[
	16进制颜色码转rgb值
	@params xstr[string] 16进制颜色码
	@return c3b[table] rgb值
]]
function XgColor.hex2Rgb(xstr)
	if not xstr then return end

	local s, e = string.find(xstr, "#");
	if s and e then
		local function toTen(v)
			return tonumber(string.format("0x%s", v));
		end

		local b = string.sub(xstr, -2, -1);
		local g = string.sub(xstr, -4, -3);
		local r = string.sub(xstr, -6, -5);
		r, g, b = toTen(r), toTen(g), toTen(b);
		if r and g and b then 
			return cc.c3b(r, g, b);
		end
	else
		-- 如果非16进制颜色码，
		-- 默认为自定义的 XgColor.GoldColor 或者 GoldColor
		xstr = string.gsub(xstr, "XgColor.", "");
		return XgColor[xstr];
	end
end

--[[ rgb值转16进制颜色码 ]]
function XgColor.rgb2Hex(c3b)
	if not c3b then return end

	local r = string.format("%02X", c3b.r);
	local g = string.format("%02X", c3b.g);
	local b = string.format("%02X", c3b.b);
	return string.format("#%s%s%s", r, g, b);
end

--[[ 判断是否为相同颜色 ]]
function XgColor.bSame3bColor(c1, c2)
	return (c1.r == c2.r and c1.g == c2.g and c1.b == c2.b);
end

return XgColor;
