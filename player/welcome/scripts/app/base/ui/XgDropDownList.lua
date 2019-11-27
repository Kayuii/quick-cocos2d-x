--[[
	下拉列表
	@Author: ccb
	@Date: 2017-09-02
	---------------------
	简单下拉列表实现
	
	示例:
	local options = {
		text = {
			[1] = {text = {text = "text 1", color = xg.color.red}},
			[2] = "text 2",
			[3] = {text = "text 3"},
		},
		btn = {
			images = {
				normal = "texas_icon_sjx_nor.png",
				pressed = "texas_icon_sjx_nor.png",
			},
		},
		btnOffset = cc.p(-10, 0),
		topBg = "descirbe_btn_paixu.png",
		itemBg = "texas_bg_toumingdikuang_2.png",
		size = cc.size(212, 54),
		itemSize = cc.size(212, 40),
		bArrowBtn = true,
	};
	local drop = xg.ui:newDropDownList(options);
	drop:align(display.CENTER, 750, 400);
	drop:addEventListener(drop.ON_SELECT_EVENT, function(event)
		print("#####DropDownList selectd idx:", event.index, event.data.text.text);
	end);
	drop:addTo(self);

	参数说明: 	
		text是个文本集合，每条数据的参数设定可参考XgLabel。
		btn是下拉按钮的参数设定，可以是XgButton按钮对象，也可以是参数集合, 可参考XgButton(可选，为nil创建默认风格按钮)。
		size此处是每个列表项的大小(可选，为nil创建默认大小列表项)。
]]
local XgDropDownList = class("XgDropDownList", function(options)
	local node = display.newNode();
	cc(node):addComponent("components.behavior.EventProtocol"):exportMethods();
	return node;
end);

-- 默认列表项高间距
XgDropDownList.DEF_ITEM_INTER_H = 0;

-- 默认列表项大小
XgDropDownList.DEF_ITEM_SIZE = cc.size(220, 40);

-- 默认的按钮参数
XgDropDownList.DEF_BTN_OPS = {
	images = {
		normal = "texas_icon_sjx_nor.png",
		pressed = "texas_icon_sjx_nor.png",
		disabled = nil,
	},
};

-- 默认标题头
XgDropDownList.DEF_TOP_TEXT = {
	text = "All", 
	color = xg.color.green,
};

-- 选择事件
XgDropDownList.ON_SELECT_EVENT = "XG_DROP_DOWN_LIST_ON_SELECT";

--[[ 构造函数 ]]
function XgDropDownList:ctor(options)
	self._options 		= options or {};
	self._text 			= self._options.text or {};
	self._topText 		= self._options.topText or clone(self.DEF_TOP_TEXT);
	self._btn 			= self._options.btn or clone(self.DEF_BTN_OPS);
	self._btnOffset		= self._options.btnOffset or cc.p(0, 0);
	self._size 			= self._options.size or self.DEF_ITEM_SIZE;
	self._itemSize		= self._options.itemSize or self._size;
	self._interH 		= self._options.interH or self.DEF_ITEM_INTER_H;
	self._topBg 		= self._options.topBg or nil;
	self._listBg 		= self._options.listBg or nil;
	self._itemBg 		= self._options.itemBg or nil;
	self._itemSelectBg 	= self._options.itemSelectBg or nil;
	self._itemClass 	= self._options.itemClass or nil;
	self._select		= self._options.select or nil;
	
	self._bOpen = false;
	self._curSelectIndex = nil;
	self._aryDropDownListItem = {};
	self:handlerTextData();
	
	self:init();
end

--[[ 初始化 ]]
function XgDropDownList:init()
	self:setContentSize(self._size);
	
	-- 创建列表头
	self:createTopItem();

	-- 创建下拉按钮
	self:createDropDownBtn();
	
	-- 选择某下拉项
	-- 需要延迟一小段时间，以便实例对象能注册监听
	self:performWithDelay(function()
		self:onItemSelect({itemPos = self._select});
	end, 0.1);
end

--[[ 创建列表头 ]]
function XgDropDownList:createTopItem()
	local options = {
		text = self._topText,
		size = self._size,
		itemBg = self._topBg,
		itemSelectBg = self._itemSelectBg,
	};
	local cls = self._itemClass;
	local top = cls.new(options);
	top:addEventListener(top.ON_CLICKED_EVENT, function(event)
		self:showDropDownList(not self._bOpen);
	end);
	top:addTo(self, 1);
	self._top = top;
end

--[[ 创建下拉按钮 ]]
function XgDropDownList:createDropDownBtn()
	local btn = nil;
	if type(self._btn) == "userdata" and self._btn.__cname == "XgButton" then
		btn = self._btn;
	elseif type(self._btn) == "table" then
		btn = xg.ui:newButton(self._btn);
	end

	if btn then
		local pos = cc.p(self._top:getContentSize().width - btn:getSize().width/2 - 2, self._top:getContentSize().height/2);
		pos.x = pos.x + self._btnOffset.x;
		pos.y = pos.y + self._btnOffset.y;
		btn:align(display.CENTER, pos.x, pos.y);
		btn:onClicked(function(event) 
			self:showDropDownList(not self._bOpen);
		end);
		btn:addTo(self._top);
		self._ddBtn = btn;
	end
end

--[[ 显隐下拉列表 ]]
function XgDropDownList:showDropDownList(flag)
	self._bOpen = checkbool(flag);
	if self._bOpen and self._list == nil then
		self:createList();
	end
	
	if self._list then
		self._list:setVisible(self._bOpen);
	end
	if self._ddBtn and checkbool(self._options.bArrowBtn) then
		self._ddBtn:setScaleY(flag and -1 or 1);
	end
end

--[[ 创建下拉列表 ]]
function XgDropDownList:createList()
	local listSize = cc.size(0, 0);
	listSize.width = self._itemSize.width;
	listSize.height = #(self._text) * (self._itemSize.height + self._interH);
	
	local listPos = cc.p(self._size.width/2 - listSize.width/2, -listSize.height);
	local list = xg.ui:newScollView({
		viewRect = cc.rect(listPos.x, listPos.y, listSize.width, listSize.height),
		direction = xg.ui.SCROLL_VIEW_DIR.VER,
	});
	list:onTouch(function(event)
		if event.name == "clicked" and event.itemPos then
			self:showDropDownList(false);
			self:onItemSelect(event);
		end
	end);
	list:onCreateItem(handler(self, self.createListItemNode));
	list:addTo(self);
	self._list = list;
	self._listSize = listSize;

	if self._listBg then
		local bg = display.newScale9Sprite(self._listBg, 0, 0, listSize);
		bg:align(display.CENTER, listSize.width/2, listSize.height/2);
		bg:addTo(list, -1);
	end
	
	list:setDataAndReload(self._text);
end

--[[ 创建列表项 ]]
function XgDropDownList:createListItemNode(event)
	local item = event.item;
	local node = event.node;
	local data = event.data;
	local index = event.index;

	local itemSize = cc.size(self._listSize.width, self._itemSize.height + self._interH);
	item:setItemSize(itemSize.width, itemSize.height);

	local nodeSize = cc.size(itemSize.width, itemSize.height);
	node:setContentSize(nodeSize);
	node:align(display.CENTER, itemSize.width * 0.5, itemSize.height * 0.5);
	
	local extOptions = {
		size = self._itemSize, 
		itemBg = self._itemBg, 
		itemSelectBg = self._itemSelectBg,
	};
	local options = data;
	table.merge(options, extOptions);
	
	local cls = self._itemClass;
	local listItem = cls.new(options);
	listItem:addTo(node);
	listItem:isSelectItem(index == self._curSelectIndex);
	item._dropDownItem = listItem;

	self._aryDropDownListItem[index] = listItem;
end

--[[ 列表项选择处理 ]]
function XgDropDownList:onItemSelect(event)
	if self._curSelectIndex ~= event.itemPos then
		self._curSelectIndex = event.itemPos;
		
		local tagData = self._text[self._curSelectIndex] or {};
		if event.item and event.item._dropDownItem then
			local curItem = event.item._dropDownItem;
			self._top:setTitleName(curItem:getTitleName());
		else
			local str = tagData.text and tagData.text.text;
			self._top:setTitleName(str);
		end

		for k,v in pairs(self._aryDropDownListItem or {}) do
			v:isSelectItem(k == self._curSelectIndex);
		end
		
		self:dispatchEvent({name = self.ON_SELECT_EVENT, instance = self, index = self._curSelectIndex, data = tagData});
	end
end

--[[ 处理文本数据，以防后续创建出现参数错误 ]]
function XgDropDownList:handlerTextData()
	for k,v in pairs(self._text or {}) do
		if type(v) ~= "table" then
			self._text[k] = {text = {text = v}};
		end
		if v.text and type(v.text) ~= "table" then
			self._text[k] = {text = v};
		end
	end
end

--[[ 设置当前选择索引 ]]
function XgDropDownList:setCurSelectIndex(index)
	if not index then return end

	self._curSelectIndex = index;
end

return XgDropDownList;
