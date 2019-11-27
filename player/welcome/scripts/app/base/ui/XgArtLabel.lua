--[[
	艺术字
	@Auth: ccb
	@Date: 2017-11-02
]]
local XgArtLabel = class("XgArtLabel", function()
	local node = display.newNode();
	return node;
end);

XgArtLabel.DEF_OUT_LINE_FSH = "shader/outlineEx.fsh";
XgArtLabel.DEF_TEXT_TEXTURE = "ui/home/home_bg_ziti.png";
XgArtLabel.TEXT_TEXTURE_GRAY = "ui/home/home_bg_ziti2.png";

--[[ 构造 ]]
function XgArtLabel:ctor(ops)
	--[[
		ops = {
			text = nil, 	-- 要显示的文本
			texture = nil, 	-- 纹理贴图
			font = nil, 	-- 字体
			size = nil, 	-- 字号
			outlineSize = nil, 	-- 描边大小（像素）
			outlineColor = nil, -- 描边颜色
			horizontal = nil, 	-- 如果文本是多行的话， 用来设置对齐方式
		};
	]]
	self._ops = ops or {};
	self._text = self._ops.text;
	self._font = self._ops.font or xg.font.defName(); 	-- 字体
	self._fsize = self._ops.size or xg.font.defSize(); 	-- 字号
	self._outLineSize = self._ops.outlineSize; 			-- 描边大小
	self._outLineColor = self._ops.outlineColor; 		-- 描边颜色
	self._textureFile = self._ops.texture or self.DEF_TEXT_TEXTURE; -- 纹理图
	self._horizontal = self._ops.horizontal or ui.TEXT_ALIGN_CENTER; -- 多行模式下的对齐方式
	self._sprite = nil;
	self.__render = nil;

	self:setString(self._text or "");
end

--[[ 设置文本 ]]
function XgArtLabel:setString(text)
	if self._sprite then
		self._sprite:removeFromParent();
		self._sprite = nil;
	end
	if self.__render then
		self.__render:removeFromParent();
		self.__render = nil;
	end

	if not text or text == "" then
		self:setContentSize(cc.size(0, 0));	
		return;
	end
	self._text = text;
	
	local w, h = 0, 0;
	local function setSprite(tex)
		local sp;
		local outLineSize = self._outLineSize;
		if outLineSize then
			sp = CCFilteredSpriteWithOne:createWithTexture(tex);

			-- 当前版本不支持定义滤镜
			-- local color = self._outLineColor or xg.color.c3b2C4b(xg.color.black);
			-- local shaderName = string.format("outlineShaderEx_%d_%d_%d_%d", color.r, color.g, color.b, color.a);
			-- local param = json.encode({
			-- 	frag = self.DEF_OUT_LINE_FSH,
			-- 	shaderName = shaderName,
			-- 	v_outlineSize = {outLineSize/w, outLineSize/h},
			-- 	v_outlineColor = {color.r/255, color.g/255, color.b/255, color.a/255},
			-- 	alphaThreshold = 0.3
			-- });
			-- local spFilter = filter.newFilter("CUSTOM", param);
			-- sp:setFilter(spFilter);
		else
			sp = display.newSprite(tex);
		end
		sp:align(display.CENTER, w/2, h/2);
		sp:addTo(self);
		self._sprite = sp;
	end

	local textureCache = CCTextureCache:sharedTextureCache();
	local textureName = string.format("xg_alt_text_%s_%s_%d_%s", text, self._font, self._fsize, self._textureFile);
	local tex = textureCache:textureForKey(textureName);
	if tex then -- 以前创建过， 直接用
		local texSize = tex:getContentSize();
		w, h = texSize.width, texSize.height;
		self:setContentSize(cc.size(w, h));
		setSprite(tex);
	else -- 创建
		local textList = string.split(text, "\n");
		local label, spMask, labelSize, spSize;
		local labelList, maskList, sizeList = {}, {}, {};
		for i = 1, #textList do
			label = xg.ui:newLabel({
				text = textList[i],
				font = self._font,
				size = self._fsize,
				color = xg.color.gold,
				outlineSize = 0.5,
				effectType = xg.ui.LABEL_EFT_TYPE.OUTLINE,
			});
			labelSize = label:getContentSize();
			spMask = display.newSprite(self._textureFile);
			assert(spMask, "XgArtLabel load texture fail, " .. tostring(self._textureFile));
			
			spSize = spMask:getContentSize();
			spMask:setScaleX(labelSize.width/spSize.width);
			spMask:setScaleY(labelSize.height/spSize.height);
			
			-- 计算宽高
			h = h + labelSize.height;
			w = math.max(w, labelSize.width);

			labelList[i] = label;
			maskList[i] = spMask;
			sizeList[i] = labelSize;
		end
		
		self:setContentSize(cc.size(w, h));
		local render = cc.RenderTexture:create(w, h);
		self.__render = render;

		render:beginWithClear(0, 0, 0, 0);

		local y = h;
		for i = 1, #textList do
			label = labelList[i];
			spMask = maskList[i];
			labelSize = sizeList[i];
			y = y - labelSize.height;
			if self._horizontal == ui.TEXT_ALIGN_CENTER then
				label:align(display.CENTER_BOTTOM, w/2, y);
				spMask:align(display.CENTER_BOTTOM, w/2, y);
			elseif self._horizontal == ui.TEXT_ALIGN_LEFT then
				label:align(display.LEFT_BOTTOM, 0, y);
				spMask:align(display.LEFT_BOTTOM, 0, y);
			elseif self._horizontal == ui.TEXT_ALIGN_RIGHT then
				label:align(display.LEFT_BOTTOM, w - labelSize.width, y);
				spMask:align(display.LEFT_BOTTOM, w - labelSize.width, y);
			else
				local strErr = "XgArtLabel unknown alignment.";
				error(strErr);
			end
			local blen_1, blen_2 = ccBlendFunc(), ccBlendFunc();
			blen_1.src = GL_ONE;
			blen_1.dst = GL_ZERO;
			blen_2.src = GL_DST_ALPHA;
			blen_2.dst = GL_ZERO;
			label:setBlendFunc(blen_1);
			spMask:setBlendFunc(blen_2);
			
			label:visit();
			spMask:visit();
		end
		
		render:endToLua();
		render:addTo(self);
		render:setVisible(false);
		render:performWithDelay(function()
			local img = render:newCCImage();
			render:removeFromParent();
			self.__render = nil;
			tex = textureCache:addUIImage(img, textureName);
			img:release();
			setSprite(tex);
		end, 0.01);
	end
end

--[[ 设置描边颜色 ]]
function XgArtLabel:setOutLineSize(color)
	if not color then return end
	
	self._outLineColor = color;
	self:setString(self._text);
end

--[[ 设置描边大小 ]]
function XgArtLabel:setOutLineSize(size)
	if size and size ~= self._outLineSize then
		self._outLineSize = size;
		self:setString(self._text);
	end
end

--[[ 设置字体大小 ]]
function XgArtLabel:setFontSize(size)
	if size and size ~= self._fsize then
		self._fsize = size;
		self:setString(self._text);
	end
end

--[[ 设置纹理图 ]]
function XgArtLabel:setTextureFile(path)
	if path and path ~= self._textureFile then
		self._textureFile = path;
		self:setString(self._text);
	end
end

return XgArtLabel;
