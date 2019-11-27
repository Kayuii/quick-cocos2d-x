--[[
	ProgressBarStrip
	@Author: ccb
	@Date: 2017-09-03
	--------------------
	示例:
	-- 默认按钮样式
	local options = {
		cur = 1,
		max = 3,
	};
	-- 自定义按钮样式
	local options = {
		cur = 1,
		max = 3,
		imgs = {
			bg = "ui/club/game_img_sjhg2.png",
			img_nor = "ui/club/game_img_sjhg1.png",
		},
		interval = 10,
	};
	local probar = xg.ui:newProgressBarStrip(options);
	probar:align(display.CENTER, display.cx, 200);
	probar:addTo(self);

	-- 设置当前页
	probar:setCurNum(2);

	-- 更新数据
	probar:setData({
		cur = 1,
		max = 4,   -- 如果max与之前的max不等，则会重新创建
	});
]]
local ProgressBarStrip = class("ProgressBarStrip", function(options)
	local node = display.newNode();
	return node;
end);

ProgressBarStrip.DEF_IMG = {
	bg = "ui/discover/pro_bar_1_bg.png",
	img_nor = "ui/discover/pro_bar_1_st1.png",
	img_max = "ui/discover/pro_bar_1_st2.png",
};

ProgressBarStrip.DEF_INTERVAL = 7;
ProgressBarStrip.DEF_DEBUG_MOD = 0;

--[[ 构造 ]]
function ProgressBarStrip:ctor(ops)
	--[[
		ops = {
			cur = 1,
			max = 3,
		}
	]]
	self._ops = ops or {};
	self._cur = self._ops.cur or 0;
	self._max = self._ops.max or 1;
	self._imgs = self._ops.imgs or nil;
	self._isDebug = self._ops.isDebug or self.DEF_DEBUG_MOD;
	self._interval = self._ops.interval or self.DEF_INTERVAL;

	self._stateInfo = newBindTable({
		cur_num = -1,
		max_num = -1,
	});
	
	self:init();
end

--[[ 初始化 ]]
function ProgressBarStrip:init()
	self:handleImgOptions();
	self:createContent();
	
	-- 绑定数据以便更新
	self:bind(self._stateInfo, "cur_num", function(node, num)
		if tonumber(num) == nil then return end

		num = tonumber(num);
		for k, v in ipairs(self._aryBgImg) do
			v:showProgress(num >= k);
		end
	end);
	self:bind(self._stateInfo, "max_num", function(node, num)
		if tonumber(num) == nil then return end

		self:removeAllChildren();
		self:createContent();
	end);
end

--[[ 创建内容 ]]
function ProgressBarStrip:createContent()
	local bgSize = display.newSprite(self._imgs.bg):getContentSize();
	self._size = cc.size(0, bgSize.height);
	self._size.width = bgSize.width * self._max + self._interval * (self._max - 1);
	self:setContentSize(self._size);
	
	self._aryBgImg = {};

	local pBg, pSt1 = nil;
	local pos = cc.p(bgSize.width/2, self._size.height/2);
	for i = 1, self._max do
		pBg = display.newSprite(self._imgs.bg);
		pBg:align(display.CENTER, pos.x, pos.y);
		pBg:addTo(self);

		pBg.showProgress = function(obj, flag)
			flag = checkbool(flag);
			local spSt = obj._spSt;
			if flag and not spSt then
				spSt = display.newSprite(self._imgs.img_nor);
				spSt:align(display.CENTER, bgSize.width/2, bgSize.height/2);
				spSt:addTo(obj);
				spSt.__imgstf = self._imgs.img_nor;
				obj._spSt = spSt;
			end
			if spSt then
				spSt:setVisible(flag);
				if flag and self._imgs.img_max and self._imgs.img_max ~= "-" then
					local bMax = self._cur >= self._max;
					local spStf = bMax and self._imgs.img_max or self._imgs.img_nor;
					if spStf ~= spSt.__imgstf then
						spSt.__imgstf = spStf;
						spSt:setTexture(display.newSprite(spStf):getTexture());
					end
				end
			end
		end

		self._aryBgImg[i] = pBg;
		pos.x = pos.x + bgSize.width + self._interval;
	end
	
	self._stateInfo.cur_num = self._cur;
end

--[[ 设置当前数 ]]
function ProgressBarStrip:setCurNum(num)
	if not num then return end

	self._cur = num;
	if num ~= self._stateInfo.cur_num then
		self._stateInfo.cur_num = num;
	end
end

--[[ 设置最大数 ]]
function ProgressBarStrip:setMaxNum(num)
	if not num then return end

	local oldMax = self._max;
	self._max = num;
	if num ~= oldMax then
		self._stateInfo.max_num = num;
	end
end

--[[ 设置数据 ]]
function ProgressBarStrip:setData(data)
	data = checktable(data);
	local temp = {cur = self._cur, max = self._max};
	table.merge(temp, data);
	data = temp;
	
	local newMax = data.max;
	local oldMax = self._max;
	self._cur = data.cur or 1;
	self._max = data.max or 1;
	
	if oldMax ~= newMax then
		local tmpdata = {cur_num = self._cur, max_num = self._max};
		newBindTable(data):updateTo(self._stateInfo);
	else
		self._stateInfo.cur_num = self._cur;
	end
end

--[[ 处理图集参数 ]]
function ProgressBarStrip:handleImgOptions()
	local tempImg = clone(self.DEF_IMG);

	if self._imgs then
		if type(self._imgs) ~= "table" then
			self._imgs = {img_nor = self._imgs, img_max = "-"};
		else
			if self._imgs.img_nor and not self._imgs.img_max then
				self._imgs.img_max = "-";
			end
		end
	end
	self._imgs = self._imgs or {};
	table.merge(tempImg, self._imgs);
	self._imgs = tempImg;
end

return ProgressBarStrip;
