--[[
	整理Lable
	@Author: ccb
	@Date: 2017-09-01
	---------------------
	使用TTF字体创建文字显示对象，并返回Label对象。
	@param table params 参数表格对象
	@return LabelTTF LabelTTF对象
	display.newTTFLabel(params)
	可用参数：
		text: 要显示的文本
		font: 字体名，如果是非系统自带的 TTF 字体，那么指定为字体文件名
		size: 文字尺寸，因为是 TTF 字体，所以可以任意指定尺寸
		color: 文字颜色（可选），用 cc.c3b() 指定，默认为白色
		align: 文字的水平对齐方式（可选）
		valign: 文字的垂直对齐方式（可选），仅在指定了 dimensions 参数时有效
		dimensions: 文字显示对象的尺寸（可选），使用 cc.size() 指定
		x, y: 坐标（可选）
	align和valign参数可用的值：
		ui.TEXT_ALIGN_LEFT 左对齐
		ui.TEXT_ALIGN_CENTER 水平居中对齐
		ui.TEXT_ALIGN_RIGHT 右对齐
		ui.TEXT_VALIGN_TOP 垂直顶部对齐
		ui.TEXT_VALIGN_CENTER 垂直居中对齐
		ui.TEXT_VALIGN_BOTTOM 垂直底部对齐

	示例:
	实现单行，多行，描边，阴影等都可直接通过设置参数来实现。
	部分参数可选，未传参就使用默认值。

	-- 单行
	local label = xg.ui:newLabel({
		text = "Label 文本",
		font = xg.font.defName(),
		size = xg.font.defSize(),
		color = xg.color.red,
	}):addTo(self);

	-- 多行
	local label = xg.ui:newLabel({
		text = "Label 文本",
		font = xg.font.defName(),
		size = xg.font.defSize(),
		color = xg.color.red,
		align = ui.TEXT_VALIGN_CENTER,
		valign = ui.TEXT_VALIGN_TOP,
		dimensions = cc.size(400, 200),
	}):addTo(self);

	-- 数字滚动特效
	label:setNum(math.random(1, 1000));
]]
local XgLabel = class("XgLabel", function(options)
	assert(type(options) == "table", "[XgLabel invalid options")

	options.font = options.font or xg.font.defName();
	options.size = options.size or xg.font.defSize();
	options.color = options.color or xg.color.white;
	options.text = options.text;
	if options.dimensions then
		options.valign = options.valign or ui.TEXT_VALIGN_TOP;
	end
	
	return ui.newTTFLabel(options);
end);

XgLabel.ACT_TAG_NUM_SCROLL = 0x100861;

--[[ 构造函数 ]]
function XgLabel:ctor(options)
	self._options = options or {}
	self._dis_align = self._options.displayAlign or display.LEFT_CENTER;
	self._effectType = self._options.effectType or nil;

	makeUIControl_(self);
	self:setLayoutSizePolicy(display.FIXED_SIZE, display.FIXED_SIZE);
	self:align(self._dis_align);
	
	self:showEffect();
end

--[[ 设置控件大小 ]]
function XgLabel:setLayoutSize(width, height)
	self:getComponent("components.ui.LayoutProtocol"):setLayoutSize(width, height);
	return self;
end

--[[ 显示特效(描边或者阴影) ]]
function XgLabel:showEffect(eType, options)
	-- quick 3.3f 使用以下方法创建
	-- quick 2.2.6 使用ui.lua中的方式创建, newTTFLabelWithOutline, newTTFLabelWithShadow

	self._effectType = eType or self._effectType or nil;
	if self._effectType == nil then return end

	options = options or {};
	if self._effectType == xg.ui.LABEL_EFT_TYPE.OUTLINE then
		self._options.outlineColor = options.color or self._options.outlineColor or cc.c4b(0, 0, 0, 255);
		self._options.outlineSize = options.size or self._options.outlineSize or 2;
		
		-- outlineColor: 描边颜色（可选），用 cc.c4b() 指定，默认为黑色
		-- outlineSize: 宽度，默认为 2
		-- self:enableOutline(self._options.outlineColor, self._options.outlineSize);

		-- quick 2.2.6 目前该方法只能用于加粗字体, 设置颜色无效
		local tmpColor = self._options.outlineColor;
		local tagColor = cc.c3b(tmpColor.r, tmpColor.g, tmpColor.b);
		self:enableStroke(tagColor, self._options.outlineSize);
	end
	
	if self._effectType == xg.ui.LABEL_EFT_TYPE.SHADOW then
		self._options.shadowColor = options.color or self._options.shadowColor or cc.c4b(0, 0, 0, 255);
		self._options.shadowSize = options.size or self._options.shadowSize or cc.size(3, -3);
		
		-- shadowColor: 阴影颜色（可选），用 cc.c4b() 指定，默认为黑色
		-- shadowSize: 应该是偏移量，用 cc.size() 指定，默认为 cc.size(1, -1)
		-- self:enableShadow(self._options.shadowColor, self._options.shadowSize);

		--  quick 2.2.6 目前只能黑色阴影
		self:enableShadow(self._options.shadowSize, 255, 1);
	end
end

--[[ 初始化绑定表 ]]
function XgLabel:initNumBindData_()
	self._numBindData = newBindTable({
		cur = 0,
		old = 0,
	});
	
	self:bind(self._numBindData, "cur", function(node, value)
		if value and self._numBindData.old ~= value then
			node:stopActionByTag(self.ACT_TAG_NUM_SCROLL);
			node:setString(self._numBindData.old);
			node._cur = self._numBindData.old;

			local ct = 10;
			local dly = 0.025;
			local sub = value - self._numBindData.old;
			local interval = sub/ct;
			local act = cca.rep(cca.seqEx({
				cca.callFunc(function(event)
					node._cur = node._cur + interval;
					local v = checkint(node._cur);
					v = math.max(0, v);
					node:setString(v);
				end),
				cca.delay(dly),
			}), ct);
			act:setTag(self.ACT_TAG_NUM_SCROLL);
			node:runAction(act);

			self._numBindData.old = value;
		end
	end);
end

--[[ 设置数值 ]]
function XgLabel:setNum(num)
	if tonumber(num) == nil then return end

	if self._numBindData == nil then
		self:initNumBindData_();
	end
	if num ~= self._numBindData.cur then
		self._numBindData.cur = num;
	end
end

--[[ 获取数值 ]]
function XgLabel:getNum()
	local num = 0;
	if self._numBindData then
		num = self._numBindData.cur;
	end
	return num;
end

--[[ 覆写设置文本 ]]
function XgLabel:setString(str)
	if not str then return self end

	local preStr = self:getString();
	getmetatable(self).setString(self, str);
	if self._underLineOps and next(self._underLineOps) then
		if preStr ~= str then
			self:addUnderLine();
		end
	end
	return self;
end

--[[ 设置下划线颜色 ]]
function XgLabel:setUnderLineColor(color)
	if not color then return self end

	if self._underLineOps and next(self._underLineOps) then
		local preColor = self._underLineOps.color;
		if not xg.color.bSame3bColor(preColor, color) then
			table.merge(self._underLineOps, {color = color});
			self:addUnderLine();
		end
	end
	return self;
end

--[[ 添加下划线 ]]
function XgLabel:addUnderLine(ops)
	-- 该方法只简单给单行文本添加下划线
	if self._underLine then
		self._underLine:removeSelf();
	end

	ops = ops or self._underLineOps or {};
	ops.offset = ops.offset or cc.p(0, 2);
	ops.borderWidth = ops.borderWidth or 1;
	ops.color = ops.color or self:getColor() or xg.color.white;
	self._underLineOps = ops;
	local size = self:getContentSize();
	local line = display.newLine(
		{{ops.offset.x, ops.offset.y}, {ops.offset.x + size.width, ops.offset.y}},
		{borderColor = xg.color.c3b2C4f(ops.color, 200), borderWidth = ops.borderWidth}
	);
	self:addChild(line, 1);
	self._underLine = line;
end

return XgLabel;
