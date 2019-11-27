--[[
	XgRichText 简单富文本
	@Author: ccb
	@Date: 2018-03-20
	---------------------

	继承关系:
		CCNode:
			YLRichText:

	XgRichText 解析使用了辅助解析器 RichTextParser ，帮助解析简单的富文本，返回信息列表后根据标签头进行创建。
	目前支持的仅有 label(XgLlabel) ，image(CCSprite) ，简单链接(lablelink)，后续可能需要扩展例如animation动画，超链等。
	后续可能扩展: 	1，支持"\n"换行。
					2，支持标签内嵌。
					3，支持动画，超链，逐字播放等功能。

	示例:
	local ary = {
		"普通文本",
		"<color=#8B008B size=28>带颜色大小描边文本</color>",
		"<color=#FFB6C1 size=22>带颜色大小阴影文本</color>",
		"<img=ui/btn_help.png scale=0.5>可缩放的图片精灵，标签间的内容会被解析但是不创建</img>",
		"普通文本2",
		"<link=name_link_ccb>名字</link>",
	};
	local str = "";
	for k,v in ipairs(ary) do
		str = str..v;
	end
	local rich = xg.ui:newRichText({dimensions = cc.size(300, 0)});
	rich:setString(str);
	rich:setPosition(display.cx - 150, display.cy);
	rich:addEventListener(rich.EVENT_ON_LINK_CLICKED, function(event)
		dump(event, "event:");
	end);
	rich:addTo(self);
]]
local XgRichText = class("XgRichText", function()
	local node = display.newNode();
	node:setNodeEventEnabled(true);
	cc(node):addComponent("components.behavior.EventProtocol"):exportMethods();
	return node;
end);

-- 链接点击事件
XgRichText.EVENT_ON_LINK_CLICKED = "RICH_TEXT_ON_LINK_CLICKED";

--[[ 构造函数 ]]
function XgRichText:ctor(ops)
	self._ops = ops or {}
	self._text = self._ops.text or nil;
	self._fontName = self._ops.fontName or xg.font.defName();
	self._fontSize = self._ops.fontSize or  xg.font.defSize();
	self._fontColor = self._ops.fontColor or xg.color.white;
	self._dimensions = self._ops.dimensions or cc.size(0, 0); -- 默认为向右无限扩展。
	self._conSize = cc.size(0, 0);

	self:init();
end

--[[ 初始化 ]]
function XgRichText:init()
	local contNode = display.newNode();
	self:addChild(contNode);
	self._contNode = contNode;
	if self._text then
		self:setString(self._text);
	end
end

--[[ 设置文本，会开始解析并创建内容 ]]
function XgRichText:setString(text)
	if self._oldText == text then return end

	-- 删除旧文本
	if self._oldText then 
		self._aryElements = nil;
		self._contNode:removeAllChildren();
	end

	self._oldText = text;
	
	-- 解析字符串并保存到数组中
	local aryParse = xg.rtParser.parse(text);
	
	-- 分割字符串
	for k, v in pairs(aryParse) do
		if v and v.cont then
			v.chars = stringToChars(v.cont);
		end
	end

	-- 添加元素
	local aryEles = self:addElements(aryParse);
	self._aryElements = aryEles;

	-- 调整元素位置
	self:adjustPosition();
end

--[[
	增加元素(文本，图片，超链等)
	如需扩展元素，需要完善相应的代码。
]]
function XgRichText:addElements(ary)
	local aryEles = {};
	local arySwith = {};
	arySwith["label"] = handler(self, self.createLabel);
	arySwith["img"] = handler(self, self.createImage);
	arySwith["link"] = handler(self, self.createLink);

	local ele = nil;
	for k,v in pairs(ary or {}) do
		if v.tagType == "img" or v["img"] then
			ele = arySwith["img"](v);
			table.insert(aryEles, ele);
		else
			for i, c in pairs(v.chars) do
				local temp = clone(v);
				table.merge(temp, {text = c});

				if v.tagType == "link" or v["link"] then
					ele = arySwith["link"](temp);
				else
					ele = arySwith["label"](temp);
				end
				table.insert(aryEles, ele);
			end
		end 
	end
	return aryEles;
end

--[[ 创建文本 ]]
function XgRichText:createLabel(info)
	-- 部分参数的转换和补全
	info.color = xg.color.hex2Rgb(info.color) or self._fontColor;
	info.size = info.size or self._fontSize;
	info.font = info.font or self._fontName;

	local label = xg.ui:newLabel(info);
	label:setAnchorPoint(cc.p(0.5, 0.5));
	label:addTo(self._contNode);
	return label;
end

--[[ 创建图片 ]]
function XgRichText:createImage(info)
	local sprite = display.newSprite(info.img);
	sprite:setScale(info.scale or 1);
	self._contNode:addChild(sprite);
	return sprite;
end

--[[ 创建超链 ]]
function XgRichText:createLink(info)
	local label = self:createLabel(info);
	label:addUnderLine();
	label:swallowTouch(false);
	label:onClicked(function(event)
		self:dispatchEvent({name = self.EVENT_ON_LINK_CLICKED, link = info.link});
	end);
	return label;
end

--[[ 调整元素位置 ]]
function XgRichText:adjustPosition()
	local aryEles = self._aryElements or nil;
	if aryEles == nil then return end

	local aryWidth, aryHeight = self:getSizeOfElement(aryEles);
	local aryPosX, aryPosY = self:getPointOfElement(aryWidth, aryHeight, self._dimensions);

	for i, ele in ipairs(aryEles) do
		ele:setPosition(aryPosX[i], aryPosY[i]);
	end
end

--[[ 获得元素的尺寸 ]]
function XgRichText:getSizeOfElement(ary)
	local aryWidth, aryHeight = {}, {};

	for i, ele in ipairs(ary) do
		local rect = ele:getBoundingBox();
		aryWidth[i] = rect.width;
		aryHeight[i] = rect.height;
	end

	return aryWidth, aryHeight;
end

--[[ 获取元素的位置 ]]
function XgRichText:getPointOfElement(aryW, aryH, dimensions)
	dimensions = dimensions or self._dimensions;
	local dWidth = dimensions.width;

	local aryPosX = {};
	local aryPoxY = {};
	local contSize = cc.size(0, 0);

	local curX = 0;
	local curY = 0;
	local posX = 0;
	local posY = 0;
	local hIdx = 1; 	--横轴
	local vIdx = 1;		--纵轴
	local aryHIndex = {};
	local aryVIndex = {};

	-- 计算x坐标
	for k, eleW in ipairs(aryW) do
		local tempVIdx = vIdx;
		if dWidth ~= 0 and (curX + eleW) > dWidth then
			--超界
			posX = eleW * 0.5;
			if hIdx == 1 and vIdx == 1 then
				curX = 0;
			else
				curX = eleW;
				tempVIdx = vIdx + 1;
			end
			hIdx = 1;
			vIdx = vIdx + 1;
		else
			--未超界
			posX = curX + eleW * 0.5;
			curX = curX + eleW;
			hIdx = hIdx + 1;
		end

		aryPosX[k] = posX;
		aryVIndex[k] = tempVIdx;
		aryHIndex[tempVIdx] = aryHIndex[tempVIdx] or {};
		aryHIndex[tempVIdx][#(aryHIndex[tempVIdx]) + 1] = k;

		contSize.width = math.max(contSize.width, curX);
	end

	-- 计算Y坐标
	local aryRowHeight = {};
	for i, hInfo in ipairs(aryHIndex) do
		local rowHeight = 0
		for j, index in ipairs(hInfo) do
			local height = aryH[index]
			rowHeight = math.max(rowHeight, height);
		end
		local pointY = curY + rowHeight * 0.5;
		aryRowHeight[#aryRowHeight + 1] = - pointY;
		curY = curY + rowHeight;

		contSize.height = math.max(contSize.height, curY);
	end

	for i = 1, #aryW do
		local indexY = aryVIndex[i];
		local pointY = aryRowHeight[indexY];
		aryPoxY[i] = pointY;
	end

	self._conSize = contSize;

	return aryPosX, aryPoxY;
end

--[[
	设置边界尺寸
	此处大小不要太小, 建议至少让一个文本能容纳的。
]]
function XgRichText:setDimensions(size)
	if size == nil then return end

	local tmpSize = nil;
	if type(size) ~= "table" then
		local width = tonumber(size);
		if width then
			tmpSize = cc.size(width, 0);
		end
	else
		tmpSize = size
	end
	
	if tmpSize then
		self._dimensions = tmpSize;
		self:adjustPosition();
	end
end

--[[ 获取大小 ]]
function XgRichText:getTextSize()
	return self._conSize;
end

return XgRichText;
