--[[
	字体相关
	@Author: ccb
	@Date: 2017-06-06 
]]
local XgFont = {};
local tpFont = XConstants and XConstants.Fonts or {};

-- 字体名(格式)
XgFont.name = {
	def = "微软雅黑",
	tf_ariali = "Arial-ItalicMT",
	pf_blood = tpFont.PFBlod,
	pf_medium = tpFont.PFMedium,
	pf_regular = tpFont.PFRegular,
};

-- 字体大小
XgFont.size = {
	xtiny 	= 14, 	-- 微小
	tiny 	= 18, 	-- 微小
	tiny_ex = 20, 	-- 微小
	sml 	= 22, 	-- 小
	mid 	= 24, 	-- 中
	nor 	= 26, 	-- 普通
	big 	= 28, 	-- 大
	title 	= 30, 	-- 标题
	mtitle 	= 32, 	-- 标题
	supbig 	= 38, 	-- 超大号
};

-- 缓存计算过的字体大小
XgFont.cashFontSize = {};

--[[
	获取默认字体名(格式)
	@return name[string] 字体名(格式)
]]
function XgFont.defName()
	local name = XgFont.name.def;
	return name;
end

--[[
	获取默认字体大小
	@return size[number] 字体大小
]]
function XgFont.defSize()
	return XgFont.size.nor;
end

--[[
	获取文本大小
	@params options[table] 创建文本的参数列表
			bWithOutDimensions[CCSize] 限定宽高
	@return size[CCSize] 该文本长度
]]
function XgFont.getFontSize(options, bWithOutDimensions)
	if not options then return end
	if type(options) ~= "table" then return end
	if not options.text then return end

	options = clone(options);
	if checkbool(bWithOutDimensions) then
		options.dimensions = nil;
	end
	local text = options.text;
	local font = options.font or XgFont.defName();
	local size = options.size or XgFont.defSize();
	local dimensionsW = checktable(options.dimensions).width or 0;
	local key = text;
	if options.text_key then
		key = "cn" .. "_" .. options.text_key;
		if type(options.text_params) ~= "table" then
			options.text_params = {[1] = options.text_params};
		end
		if options.text_params and next(options.text_params) then
			for k,v in ipairs(options.text_params) do
				key = key .. "_" .. v;
			end
		end
	end
	key = string.format("%s_%s_%s_%s", key, font, size, dimensionsW);

	if not XgFont.cashFontSize[key] then
		local label = xg.ui:newLabel(options);
		local labelSize = label:getContentSize();
		label = nil;
		XgFont.cashFontSize[key] = labelSize;
	end
	local tagSize = XgFont.cashFontSize[key];
	tagSize = cc.size(tagSize.width, tagSize.height);

	return tagSize;
end

--[[
	获取文本宽度
	该方法适用于默认字体，其他字体尚未测试，如果出现偏差
	请使用getFontSize，这个方法会消耗性能，同一帧大量调用将导致掉帧
]]
function XgFont.getFontWidthEx(str, fSize)
	if not str or str == "" then return 0 end

	fSize = fSize or XgFont.defSize();

	local i = 1;
	local width = 0;
	local len = string.len(str);
	while i <= len do
		local shift = 1;
		local c = string.byte(str, i);
		if c > 0 and c <= 127 then
			shift = 1;
		elseif (c >= 192 and c <= 223) then
			shift = 2;
		elseif (c >= 224 and c <= 239) then
			shift = 3;
		elseif (c >= 240 and c <= 247) then
			shift = 4;
		end
		local char = string.sub(str, i, i + shift - 1);
		i = i + shift;

		if shift == 1 then
			width = width + fSize * 0.5;
		else
			width = width + fSize;
		end
	end

	return width;
end

return XgFont;
