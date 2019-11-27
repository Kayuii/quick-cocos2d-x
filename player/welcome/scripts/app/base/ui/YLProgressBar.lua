--
-- Author: rice
-- Date: 2014-05-08  
-- 进度条

local YLProgressBar = class("YLProgressBar", function()
    return display.newNode()
end)

-- 示例代码
-- local  options = {}
-- options.need9Img = true
-- options.imgBg9X = 0 -- 背景尺寸
-- options.imgBg9Y = 0 
-- options.imgFront9X = 0 -- 前景尺寸
-- options.imgFront9Y = 0
-- options.imgBg = "combobox/taskProBarBg.png"
-- options.imgFront = "combobox/taskProFront.png"
-- options.percent = 0.2
-- options.offX = 2 -- 前景左右占的空白间隙
-- options.posX = 0 --前图的x位置
-- options.posY = 0 --前图的y位置
-- options.num1 = 0 --前图的x位置
-- options.num2 = 0 --前图的y位置
-- options.bolAnimation = false
-- local YLProgressBar = import("app.ui.YLProgressBar")
-- ylProgressBar = YLProgressBar.new()
-- ylProgressBar:createProgressBar(options)
-- taskImg:addChild(ylProgressBar)
-- ylProgressBar:updateSale(0.1)

function YLProgressBar:ctor()
	self.imgFront = nil
	self.bolAnimation = nil
	self.offX = nil
	self.posX = nil
end

-- options.imgBg 背景地址
-- options.imgFront 前景地址
-- options.percent 当前进度百分比(0.X)
-- options.offX 前景左右占的空白间隙
-- options.bolAnimation 是否有动画
-- options.revert 是否反转显示，即进度条时间减少而增加
function YLProgressBar:createProgressBar(options)
	self.options = options
	if options.need9Img then
		self.imgBg = display.newScale9Sprite((options.imgBg),0,0,cc.size(options.imgBg9X,options.imgBg9Y))
	else
		self.imgBg = display.newSprite(options.imgBg)
	end
	self.imgBg:align(display.LEFT_BOTTOM, 0,0)
	self.imgBg:addTo(self)

	self.rate =  UiManager.getInstance():createLabel({
		text = "",
		font = YLFont.defaultName(),
		size = YLFont.defaultSize(),
		color = YLColor.ricewhite,
	}):addTo(self,10)
	self.rate:align(display.CENTER, options.imgBg9X/2, options.imgBg9Y/2-1)
	if options.num1 and options.num2 then
		self.rate:setString(_N(options.num1) .. "/" .. _N(options.num2))
	end
	if options.posX == nil then
		self.posX = 0
	else
		self.posX = tonumber(options.posX)
	end
	if options.posY == nil then
		options.posY = 0
	end

	if options.need9Img then
		self.imgFront = display.newScale9Sprite((options.imgFront),0,0,cc.size(options.imgFront9X,options.imgFront9Y))
	else
		self.imgFront = display.newSprite(options.imgFront)
	end

	if options.loadIcon then
		self.loadIcon = display.newSprite(options.loadIcon)
		self.loadIcon:addTo(self,20)
		self.loadIcon:align(display.CENTER, 0, options.imgBg9Y/2+2)
	end

	self.imgFront:align(display.LEFT_BOTTOM, self.posX,options.posY)
	self.imgFront:addTo(self)

	if options.bolAnimation == nil then
		self.bolAnimation = false
	else 
		self.bolAnimation = options.bolAnimation
	end
	if options.offX == nil then
		self.offX = 0
	else
		self.offX = options.offX
	end
	self:updateSale(tonumber(options.percent) or 0.2)
end

-- 更新进度条长度
-- bolClear == nil 说明更新时，进度条长度先置0，再设置为最新长度，不为nil时，在原来的基础上直接更新
function YLProgressBar:updateSale(scale,bolClear)
	if scale > 1 then
		scale = 1
	end
	if self.options.revert then
		scale = 1 - scale
	end
	if self.bolAnimation == true then
		if bolClear == nil then
			self.imgFront:setScaleX(0)
			if self.loadIcon then
				self.loadIcon:setPositionX(0)
			end
		else
			self.imgFront:setScaleX(self.scale)
			if self.loadIcon then
				self.loadIcon:setPositionX(self.options.imgBg9X * self.scale)
			end
		end
		transition.scaleTo(self.imgFront, {time = 0.7,scaleX=scale})

		if self.loadIcon then
			self.loadIcon:stopAllActions()
			self.loadIcon:moveTo(0.7, self.options.imgBg9X * scale, self.loadIcon:getPositionY())
		end
	else
		self.imgFront:setScaleX(scale)

		if self.loadIcon then
			self.loadIcon:setPositionX(self.options.imgBg9X * scale)
		end
	end
	self.imgFront:setPositionX(self.posX+self.offX*(1-scale))
	self.scale = scale
end

function YLProgressBar:getYLWidth()
	return self.imgBg:getContentSize().width
end

function YLProgressBar:getYLHeight()
	return self.imgBg:getContentSize().height
end

function YLProgressBar:setTime(counts)
	if self.rate then
		self.rate:setString(tool.getTimeString(counts))
	end
end

function YLProgressBar:setRate(num1,num2,bolMax,scale)
	if self.rate then
		if bolMax then
			self.rate:setString("MAX")
		else
			self.rate:setString(_N(num1) .. "/" .. _N(num2))
		end
		if scale then
			self.rate:setScale(scale)
		end
	end
end

return YLProgressBar