--[[
	XgPageBar
	@Author: ccb
	@Date: 2017-09-03
	--------------------
	示例:
	-- 默认按钮样式
	local options = {
		data = {
			cur_page = 1,
			max_page = 3,
		},
	};
	-- 自定义按钮样式
	local options = {
		data = {
			cur_page = 1, 
			max_page = 3,
		},
		btn = {
			images = {
				normal = "ui/texas/texas_ckx_lx_nor.png",
				pressed = "ui/texas/texas_ckx_lx_sld.png",
			},
		},
		interval = 0,
	};
	local bar = xg.ui:newPageBar(options);
	bar:align(display.CENTER, 200, 100);
	bar:addTo(self);
	bar:setScale(0.5); -- 设置缩放

	-- 设置当前页
	bar:setCurPage(2);

	-- 更新数据
	bar:setData({
		cur_page = 1,
		max_page = 4,   -- 如果max_page与之前的max_page不等，则会重新创建
	});
]]

local XgPageBar = class("XgPageBar", function(options)
	local node = display.newNode();
	return node;
end);

XgPageBar.DEF_BTN = {
	images = {
		normal = "ui/texas/texas_ckx_lx_nor.png",
		pressed = "ui/texas/texas_ckx_lx_sld.png",
	},
};

XgPageBar.DEF_INTERVAL = 0;
XgPageBar.DEF_DEBUG_MOD = 0;

--[[ 构造函数 ]]
function XgPageBar:ctor(options)
	--[[
		data = {
			cur_page = 1,
			max_page = 3,
		}
	]]
	self._options 	= options or {};
	self._data 		= self._options.data or {};
	self._isDebug 	= self._options.isDebug or self.DEF_DEBUG_MOD;
	self._interval	= self._options.interval or self.DEF_INTERVAL;
	self._btnOptions = self._options.btn or clone(self.DEF_BTN);
	
	self._curPage = self._data.cur_page or 1;
	self._maxPage = self._data.max_page or 1;
	
	self:init();
end

--[[ 初始化 ]]
function XgPageBar:init()
	self._selectInfo = newBindTable({
		cur_page = -1,
		max_page = -1,
	});

	self:createContent();
	
	-- 绑定数据以便更新
	self:bind(self._selectInfo, "cur_page", function(node, index)
		if tonumber(index) == nil then return end

		index = tonumber(index);
		for k, v in ipairs(self._aryPageBtns) do
			v:setIsEnabled(true);
			v:setIsSelected(index == k);
			v:setIsEnabled(false);
		end
	end);
	self:bind(self._selectInfo, "max_page", function(node, index)
		self:removeAllChildren();
		self:createContent();
	end);
end

--[[ 创建内容 ]]
function XgPageBar:createContent()
	self:handleBtnOptions();
	
	local btnSize = display.newSprite(self._btnOptions.images.normal):getContentSize();
	self._size = cc.size(0, btnSize.height);
	self._size.width = btnSize.width * self._maxPage + self._interval * (self._maxPage - 1);
	self:setContentSize(self._size);
	
	self._aryPageBtns = {};
	
	local page = nil;
	local pos = cc.p(btnSize.width/2, self._size.height/2);
	for i = 1, self._maxPage do
		local page = xg.ui:newButton(self._btnOptions);
		page:align(display.CENTER, pos.x, pos.y);
		page:addTo(self);
		page:setIsEnabled(false);
		self._aryPageBtns[i] = page;
		pos.x = pos.x + btnSize.width + self._interval;
	end
	
	self._selectInfo.cur_page = self._curPage;
end

--[[ 设置当前页 ]]
function XgPageBar:setCurPage(index)
	self._curPage = index;
	if self._curPage then
		self._selectInfo.cur_page = self._curPage;
	end
end

--[[ 设置最大页 ]]
function XgPageBar:setMaxPage(index)
	self._maxPage = index or self._maxPage;
	local oldMaxPage = self._data.max_page;
	if self._maxPage ~= oldMaxPage then
		self._selectInfo.max_page = self._maxPage;
	end
end

--[[ 设置数据 ]]
function XgPageBar:setData(data)
	data = checktable(data);
	local temp = clone(self._data);
	table.merge(temp, data);
	data = temp;
	
	local newMaxPage = data.max_page;
	local oldMaxPage = self._data.max_page;
	
	self._data = data;
	self._curPage = self._data.cur_page or 1;
	self._maxPage = self._data.max_page or 1;
	
	if oldMaxPage ~= newMaxPage then
		newBindTable(self._data):updateTo(self._selectInfo);
	else
		self._selectInfo.cur_page = self._curPage;
	end
end

--[[ 处理按钮参数 ]]
function XgPageBar:handleBtnOptions()
	local tempBtn = clone(self.DEF_BTN);
	if type(self._btnOptions) ~= "table" then
		self._btnOptions = {text = {text = self._btnOptions, color = xg.color.white}};
	end
	table.merge(tempBtn, self._btnOptions);
	if tempBtn.text and tempBtn.text.text == "" then
		tempBtn.text = nil;
	end
	self._btnOptions = tempBtn;
end

return XgPageBar;
