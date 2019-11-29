--
-- Author: Mercury
-- Date: 2015-10-27 13:45:31
--

local YLSliderBar = class("YLSliderBar",function ()
    return display.newNode()
end)

--[[
	info = {
		maxNum = 100,:最大数量
		num = 10:当前数量，如果当前数量为0或者nil，则最小可选择的数量为0，否则为1
		callback:滑动时的回调
	}
]]

function YLSliderBar:ctor(info)
	self.info = info or {maxNum = 100,num = 0,callback = nil,interval = 1}
	self:init()
end

function YLSliderBar:init()
	local node = display.newNode()
	node:addTo(self)

	-- 滑动条背景
	display.newScale9Sprite(tool.res("progressbar_load_bg.png"),0,0,cc.size(190,15))
		:addTo(node)
		:setAnchorPoint(cc.p(0,0.5))

	self.load_bar = display.newScale9Sprite(tool.res("progressbar_load_bar.png"),13,2,cc.size(1,6))
		:addTo(node)

	self.load_bar:setAnchorPoint(cc.p(0,0.5))

	self.load_bg2 = display.newScale9Sprite(tool.res("loading_progress_2_down.png"),260,0,cc.size(100, 35))
		:addTo(node)
	self.load_bg2:setAnchorPoint(cc.p(0,0.5))

	self.load_bg = display.newScale9Sprite(tool.res("num_bg.png"),260,0,cc.size(100, 35))
		:addTo(node)
	self.load_bg:setAnchorPoint(cc.p(0,0.5))

	-- 滑动条
	self.load_icon = display.newSprite(tool.res("progressbar_load_icon.png"),13,3)
		:addTo(node)
	self.selectNum  = self.info.num
	self.interval = self.info.interval or 1
	local size = self.load_icon:getContentSize()
	self.extendTouchNode = display.newNode():addTo(self.load_icon)
	self.extendTouchNode:pos(-10,-10)
	self.extendTouchNode:setContentSize(cc.size(size.width + 20,size.height + 20))
	self.extendTouchNode:setAnchorPoint(cc.p(0,0))

	self.extendTouchNode:setTouchEnabled(true)
	self.extendTouchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
		-- if self:getNum() >= self.info.maxNum then
		-- 	if event.x - event.prevX > 0 then
		-- 		return
		-- 	end
		-- end
		if event.name == "moved" then
			self:setBarShiftLength(event.x - event.prevX)
		end
		return true
	end)

	-- 加载条左边加号
	self.minusBtn = UiManager.getInstance():createButton({
		images = {
	        normal = tool.res("button_minus_normal.png"),
            pressed = tool.res("button_minus_pressed.png"),
            disabled = tool.res("button_minus_disabled.png"),
	    }
    })	:addTo(node,-1)
    	:align(display.LEFT_CENTER, -55, 0)
    	:setExtraClicks(0)
    	:onClicked(function()
    		self:setBarValue(self:getNum() - self.interval)
    	end)

	-- 加载条右边加号
	self.addBtn = UiManager.getInstance():createButton({
		images = {
	        normal = tool.res("button_add_normal.png"),
            pressed = tool.res("button_add_pressed.png"),
            disabled = tool.res("button_add_disabled.png"),
	    }
    })	:addTo(node,-1)
    	:align(display.LEFT_CENTER, 210, 0)
    	:setExtraClicks(0)
    	:onClicked(function()
    		self:setBarValue(self:getNum() + self.interval)
    	end)
 --    if self.info.maxNum == 1 then
	-- 	self.minusBtn:setIsEnabled(false)
	-- 	self.addBtn:setIsEnabled(false)
	-- end
    self:setBarValue(self.selectNum)
end

function YLSliderBar:setBarValue(nums)
	self.info.minNum = self.info.minNum or self.interval
	if nums <= self.info.minNum then
		nums = self.info.minNum
	end
	if nums > self.info.maxNum then
		return
	end
	if not self.__nums then
		self.__nums = UiManager.getInstance():createLabel({
			text = tostring(nums),
			color= YLColor.ricewhite,
		})
			:align(display.CENTER, 50, 17)
			:addTo(self.load_bg)
	else
		self.__nums:setString(tostring(nums))
	end
	self.selectNum = nums
	local percent = nums/(self.info.maxNum)
	self.load_bar:setContentSize(cc.size(percent * 180 - 10,6))
	local x = percent * 180 - 2 
	if x <= 5 then x = 5 end
	self.load_icon:setPositionX(x)

	if self.info.callback then
		continue = self.info.callback(self,nums)
	end
end

-- 设置滚动条
function YLSliderBar:setBarShiftLength(len)
	self.load_icon:setPositionX(self.load_icon:getPositionX() + len)	
	if self.load_icon:getPositionX() <= 5 then
		self.load_icon:setPositionX(5)
	end
	if self.load_icon:getPositionX() >= 75 + 110 then
		self.load_icon:setPositionX(75 + 110)
	end
	self.load_bar:setContentSize(cc.size(self.load_icon:getPositionX() - 15,6))
	local percentage = (self.load_icon:getPositionX() - 5) / 180
	local nums = math.floor(self.info.maxNum * percentage)
	-- if nums == 0 then
	-- 	nums = 1
	-- end
	if nums <= self.info.minNum then
		nums = self.info.minNum
	end
	if not self.__nums then
		self.__nums = UiManager.getInstance():createLabel({
			text = tostring(nums),
			color= YLColor.ricewhite,
		})
			:align(display.CENTER, 50, 17)
			:addTo(self.load_bg)
	else
		self.__nums:setString(tostring(nums))
	end
	self.selectNum = nums
	if self.info.callback then
		self.info.callback(self,self.selectNum)
	end
end


-- len表示进度标识位置变化，newValue表示当前选择数值
function YLSliderBar:changeProgressBarWidth(len,newValue)
	self.selectNum = newValue
	self.load_icon:setPositionX(self.load_icon:getPositionX() + len)
	self.load_bar:setContentSize(cc.size(self.load_icon:getPositionX() - 15,6))
end

function YLSliderBar:getNum()
	return checknumber(self.selectNum)
end

function YLSliderBar:setAddButtonEnabled(bol)
	self.addBtn:setIsEnabled(bol)
end

function YLSliderBar:getMaxNum()
	return checknumber(self.info.maxNum)
end

function YLSliderBar:setNumVisible(bol)
	self.load_bg:setVisible(bol)
	self.load_bg2:setVisible(bol)
end

return YLSliderBar