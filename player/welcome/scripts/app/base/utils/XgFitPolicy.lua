--[[
	适配相关
	@Author: ccb
	@Date: 2017-06-10
]]
local FitPolicy = {};
FitPolicy.MODEL_EX = {
	NON = 0,
	IPHONE_X = 1,
	HUAWEI_P20 = 2,
};
FitPolicy.TOP_HEIGHT_EX = 0;
FitPolicy.BOT_HEIGHT_EX = 0;
FitPolicy.USE_NEW_FIT_POLICY = 1;
FitPolicy.FIX_RESW = 720;
FitPolicy.FIX_RESH = 1280;

local TO_LUA_TYPE_POINT = "CCPoint";

local print = print_r or print;
local printf = printf_r or printf;
local director = CCDirector:sharedDirector();
local application = CCApplication:sharedApplication();

--[[ 初始化 ]]
function FitPolicy:init_(w, h)
	if not w or not h then
		local glview = director:getOpenGLView();
		local size = glview:getFrameSize();
		w, h = size.width, size.height;
	end
	self._bFit = false;
	self._model = self.MODEL_EX.NON;

	local target = application:getTargetPlatform();
	local sclwh =  math.max(w, h)/math.min(w, h);
	if sclwh > 2.16 then
		-- 类iphone x
		self.TOP_HEIGHT_EX = 43;
		self.BOT_HEIGHT_EX = 43;
		self._model = self.MODEL_EX.IPHONE_X;
	elseif sclwh > 2.07 then
		-- 类华为 p20
		self.TOP_HEIGHT_EX = 30;
		self.BOT_HEIGHT_EX = 30;
		self._model = self.MODEL_EX.HUAWEI_P20;
	end
end

--[[ 获取额外设备类型 ]]
function FitPolicy:getModel_(w, h)
	if not self._model then
		self:init_(w, h);
	end
	return self._model;
end

--[[ 判断是否是IPhoneX ]]
function FitPolicy:bIPhoneX(w, h)
	local fmodel = self:getModel_();
	return table.indexof({
		self.MODEL_EX.IPHONE_X,
		self.MODEL_EX.HUAWEI_P20,
	}, fmodel);
end

--[[ 设置适配方案 ]]
function FitPolicy:displaySetting()
	-- if self._bFit then return end

	print("#####设置适配方案", self.USE_NEW_FIT_POLICY);

	if self.USE_NEW_FIT_POLICY == 1 then
		XConstants_SCREEN_ORIENTATION = nil;
		self:initDisplaySetting("portrait");
	else
		require("app.util.ex_functions");
		display.setDirectionAndResolutionPolicy("portrait", kResolutionNoBorder);
		local target = application:getTargetPlatform();
		if target == kTargetIpad or target == kTargetIphone then
			display.width = self.FIX_RESW;
			display.height = self.FIX_RESH;
			display.cx = display.width/2;
			display.cy = display.height/2;
			director:getOpenGLView():setDesignResolutionSize(display.width, display.height, kResolutionShowAll);
		end
	end
	self._bFit = true;
end

--[[ 初始化适配方案 ]]
function FitPolicy:initDisplaySetting(direction)
	local bChangeDirection = false;
	if XConstants_SCREEN_ORIENTATION == direction then return end

	bChangeDirection = true;
	XConstants_SCREEN_ORIENTATION = direction;

	local glview = director:getOpenGLView();
	local size = glview:getFrameSize();
	display.sizeInPixels = {width = size.width, height = size.height};
	local w = size.width;
	local h = size.height;
	if XConstants_SCREEN_ORIENTATION == "landscape" then
		XConstants_SCREEN_WIDTH = self.FIX_RESH;
		XConstants_SCREEN_HEIGHT = self.FIX_RESW;
	elseif XConstants_SCREEN_ORIENTATION == "portrait" then
		XConstants_SCREEN_WIDTH = self.FIX_RESW;
		XConstants_SCREEN_HEIGHT = self.FIX_RESH;
	end

	if XConstants_SCREEN_WIDTH == nil or XConstants_SCREEN_HEIGHT == nil then
		XConstants_SCREEN_WIDTH  = w;
		XConstants_SCREEN_HEIGHT = h;
	end

	if not CONFIG_SCREEN_AUTOSCALE then
		if w > h then
			CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT";
		else
			CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH";
		end
	else
		CONFIG_SCREEN_AUTOSCALE = string.upper(CONFIG_SCREEN_AUTOSCALE);
	end

	local scale, scaleX, scaleY;
	local function CONFIG_SCREEN_AUTOSCALE_CALLBACK(w, h)
		if self:bIPhoneX(w, h) then
			CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH";
		end
	end

	if CONFIG_SCREEN_AUTOSCALE and CONFIG_SCREEN_AUTOSCALE ~= "NONE" then
		if type(CONFIG_SCREEN_AUTOSCALE_CALLBACK) == "function" then
			scaleX, scaleY = CONFIG_SCREEN_AUTOSCALE_CALLBACK(w, h);
		end
		if CONFIG_SCREEN_AUTOSCALE == "EXACT_FIT" then
			scale = 1.0;
			glview:setDesignResolutionSize(XConstants_SCREEN_WIDTH, XConstants_SCREEN_HEIGHT, kResolutionExactFit);
		elseif CONFIG_SCREEN_AUTOSCALE == "FILL_ALL" then
			scale = 1.0;
			XConstants_SCREEN_WIDTH = w;
			XConstants_SCREEN_HEIGHT = h;
			if cc and cc.bPlugin_ then
				glview:setDesignResolutionSize(XConstants_SCREEN_WIDTH, XConstants_SCREEN_HEIGHT, kResolutionNoBorder);
			else
				glview:setDesignResolutionSize(XConstants_SCREEN_WIDTH, XConstants_SCREEN_HEIGHT, kResolutionShowAll);
			end
		else
			if not scaleX or not scaleY then
				scaleX, scaleY = w/XConstants_SCREEN_WIDTH, h/XConstants_SCREEN_HEIGHT;
			end
			if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH" then
				scale = scaleX;
				XConstants_SCREEN_HEIGHT = h/scale;
			elseif CONFIG_SCREEN_AUTOSCALE == "FIXED_HEIGHT" then
				scale = scaleY;
				XConstants_SCREEN_WIDTH = w/scale;
			else
				scale = 1.0;
			end
			glview:setDesignResolutionSize(XConstants_SCREEN_WIDTH, XConstants_SCREEN_HEIGHT, kResolutionNoBorder);
		end
	else
		XConstants_SCREEN_WIDTH = w;
		XConstants_SCREEN_HEIGHT = h;
		scale = 1.0;
	end

	local winSize = director:getWinSize();
	display.contentScaleFactor	= scale;
	display.size 				= {width = winSize.width, height = winSize.height};
	display.width 				= display.size.width;
	display.height 				= display.size.height;
	display.cx 					= display.width/2;
	display.cy 					= display.height/2;
	display.c_left 				= -display.width/2;
	display.c_right 			= display.width/2;
	display.c_top 				= display.height/2;
	display.c_bottom 			= -display.height/2;
	display.left 				= 0;
	display.right 				= display.width;
	display.top 				= display.height;
	display.bottom 				= 0;
	display.widthInPixels 		= display.sizeInPixels.width;
	display.heightInPixels 		= display.sizeInPixels.height;

	printf("#1 XConstants_SCREEN_AUTOSCALE 	= %s", CONFIG_SCREEN_AUTOSCALE)
	printf("#1 XConstants_SCREEN_WIDTH 		= %0.2f", XConstants_SCREEN_WIDTH)
	printf("#1 XConstants_SCREEN_HEIGHT 	= %0.2f", XConstants_SCREEN_HEIGHT)
	printf("#1 display.widthInPixels 		= %0.2f", display.widthInPixels)
	printf("#1 display.heightInPixels 		= %0.2f", display.heightInPixels)
	printf("#1 display.contentScaleFactor 	= %0.2f", display.contentScaleFactor)
	printf("#1 display.width 				= %0.2f", display.width)
	printf("#1 display.height 				= %0.2f", display.height)
	printf("#1 display.cx 					= %0.2f", display.cx)
	printf("#1 display.cy 					= %0.2f", display.cy)
	printf("#1 display.left 				= %0.2f", display.left)
	printf("#1 display.right 				= %0.2f", display.right)
	printf("#1 display.top 					= %0.2f", display.top)
	printf("#1 display.bottom 				= %0.2f", display.bottom)
	printf("#1 display.c_left 				= %0.2f", display.c_left)
	printf("#1 display.c_right 				= %0.2f", display.c_right)
	printf("#1 display.c_top 				= %0.2f", display.c_top)
	printf("#1 display.c_bottom 			= %0.2f", display.c_bottom)
	printf("#1 ")

	return bChangeDirection;
end

function FitPolicy:resetDisplay(resPolicy)

	local temp = XConstants_SCREEN_HEIGHT;
	XConstants_SCREEN_HEIGHT = XConstants_SCREEN_WIDTH;
	XConstants_SCREEN_WIDTH = temp;

	local glview = director:getOpenGLView();
	local size = glview:getFrameSize();
	display.sizeInPixels = {width = size.width, height = size.height};
	
	local scale, scaleX, scaleY = 1, 1, 1;
	local preDir = XConstants_SCREEN_ORIENTATION;
	if resPolicy and resPolicy == kResolutionExactFit then
		if preDir == "portrait" then
			XConstants_SCREEN_WIDTH = self.FIX_RESH;
			XConstants_SCREEN_HEIGHT = self.FIX_RESW;
		else
			XConstants_SCREEN_WIDTH = self.FIX_RESW;
			XConstants_SCREEN_HEIGHT = self.FIX_RESH;
		end
		glview:setDesignResolutionSize(XConstants_SCREEN_WIDTH, XConstants_SCREEN_HEIGHT, kResolutionExactFit);		
	else
		local function CONFIG_SCREEN_AUTOSCALE_CALLBACK(w, h)
			if self:bIPhoneX(w, h) then
				if preDir == "portrait" then
					XConstants_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
				else
					XConstants_SCREEN_AUTOSCALE = "FIXED_WIDTH";
				end
			end
		end

		XConstants_SCREEN_AUTOSCALE = nil;
		local w = display.sizeInPixels.width;
		local h = display.sizeInPixels.height;
		if type(CONFIG_SCREEN_AUTOSCALE_CALLBACK) == "function" then
			scaleX, scaleY = CONFIG_SCREEN_AUTOSCALE_CALLBACK(w, h);
		end
		if not XConstants_SCREEN_AUTOSCALE then
			if w > h then
				XConstants_SCREEN_AUTOSCALE = "FIXED_HEIGHT";
			else
				XConstants_SCREEN_AUTOSCALE = "FIXED_WIDTH";
			end
		end

		if XConstants_SCREEN_AUTOSCALE then
			local scaleX, scaleY = w/XConstants_SCREEN_WIDTH, h/XConstants_SCREEN_HEIGHT;

			if XConstants_SCREEN_AUTOSCALE == "FIXED_WIDTH" then
				scale = scaleX;
				XConstants_SCREEN_HEIGHT = h/scale;
			elseif XConstants_SCREEN_AUTOSCALE == "FIXED_HEIGHT" then
				scale = scaleY;
				XConstants_SCREEN_WIDTH = w/scale;
			else
				scale = 1.0;
			end
			glview:setDesignResolutionSize(XConstants_SCREEN_WIDTH, XConstants_SCREEN_HEIGHT, kResolutionNoBorder);
		end
	end

	local winSize = director:getWinSize();
	display.contentScaleFactor 	= scale;
	display.size 				= {width = winSize.width, height = winSize.height};
	display.width 				= display.size.width;
	display.height 				= display.size.height;
	display.cx 					= display.width/2;
	display.cy 					= display.height/2;
	display.c_left 				= - display.width/2;
	display.c_right 			= display.width/2;
	display.c_top 				= display.height/2;
	display.c_bottom 			= - display.height/2;
	display.left 				= 0;
	display.right 				= display.width;
	display.top 				= display.height;
	display.bottom 				= 0;
	display.widthInPixels 		= display.sizeInPixels.width;
	display.heightInPixels 		= display.sizeInPixels.height;

	local printf = printf_r or printf;

	printf("#2 XConstants_SCREEN_AUTOSCALE 	= %s", CONFIG_SCREEN_AUTOSCALE)
	printf("#2 XConstants_SCREEN_WIDTH 		= %0.2f", XConstants_SCREEN_WIDTH)
	printf("#2 XConstants_SCREEN_HEIGHT 	= %0.2f", XConstants_SCREEN_HEIGHT)
	printf("#2 display.widthInPixels 		= %0.2f", display.widthInPixels)
	printf("#2 display.heightInPixels 		= %0.2f", display.heightInPixels)
	printf("#2 display.contentScaleFactor 	= %0.2f", display.contentScaleFactor)
	printf("#2 display.width 				= %0.2f", display.width)
	printf("#2 display.height 				= %0.2f", display.height)
	printf("#2 display.cx 					= %0.2f", display.cx)
	printf("#2 display.cy 					= %0.2f", display.cy)
	printf("#2 display.left 				= %0.2f", display.left)
	printf("#2 display.right 				= %0.2f", display.right)
	printf("#2 display.top 					= %0.2f", display.top)
	printf("#2 display.bottom 				= %0.2f", display.bottom)
	printf("#2 display.c_left 				= %0.2f", display.c_left)
	printf("#2 display.c_right 				= %0.2f", display.c_right)
	printf("#2 display.c_top 				= %0.2f", display.c_top)
	printf("#2 display.c_bottom 			= %0.2f", display.c_bottom)
	printf("#2 ");
end

--[[ 改变横竖屏 ]]
function FitPolicy:updOrientation(orientation, resPolicy)
	orientation = orientation or "portrait";
	XConstants_SCREEN_ORIENTATION = XConstants_SCREEN_ORIENTATION or "portrait";
	if XConstants_SCREEN_ORIENTATION == orientation then return end

	if display.getRunningScene() then
		display.getRunningScene():hide();
	end

	local platformUtil = xg and xg.platform;
	if not platformUtil then
		local XgPlatform = require("app.xgame.base.utils.XgPlatform");
		if XgPlatform and type(XgPlatform.getInstance) == "function" then
			platformUtil = XgPlatform:getInstance();
		end
	end
	if orientation == "portrait" then
		platformUtil:changeRootv2Portrait();
	elseif orientation == "landscape" then
		platformUtil:changeRootv2Landscape();
	end

	-- 设置FrameSize
	local glview = director:getOpenGLView();
	local frameSize = glview:getFrameSize();
	glview:setFrameSize(frameSize.height, frameSize.width);
	
	-- 设置DesignResolutionSize
	self:resetDisplay(resPolicy);

	XConstants_SCREEN_ORIENTATION = orientation;

	return true;
end

--[[ 获取百分比X坐标 ]]
function FitPolicy:getFitX(x)
	if not x then return end

	if self.USE_NEW_FIT_POLICY ~= 1 then
		return x;
	end

	local tagX = self:checkX_(x);
	if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH"
	or CONFIG_SCREEN_AUTOSCALE == "FIXED_HEIGHT" then
		local offX = (XConstants_SCREEN_WIDTH - FIX_RES_WIDTH)/2;
		if tagX then
			tagX = tagX + offX;
		end
	end

	return tagX;
end

--[[ 获取百分比Y坐标 ]]
function FitPolicy:getFitY(y)
	if not y then return end

	if self.USE_NEW_FIT_POLICY ~= 1 then
		return y;
	end

	local tagY = self:checkY_(y);
	if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH"
	or CONFIG_SCREEN_AUTOSCALE == "FIXED_HEIGHT" then
		local offY = (XConstants_SCREEN_HEIGHT - FIX_RES_HEIGHT)/2;
		if tagY then
			tagY = tagY + offY;
		end
	end

	return tagY;
end

--[[ 获取适配XY坐标 ]]
function FitPolicy:getFitXy(x, y)
	x, y = self:checkXY_(x, y);
	return self:getFitX(x), self:getFitY(y);
end

--[[ 获取适配坐标 ]]
function FitPolicy:getFitPos(x, y)
	local tagX, tagY = self:getFitXy(x, y);
	return cc.p(tagX, tagY);
end

--[[ 获取百分比X坐标 ]]
function FitPolicy:getDRPercX(x)
	if not x then return end

	local tagX = self:checkX_(x);
	if tagX then
		tagX = tagX * self:getDRSclX();
	end

	return tagX;
end

--[[ 获取百分比Y坐标 ]]
function FitPolicy:getDRPercY(y)
	if not y then return end

	local tagY = self:checkY_(y);
	if tagY then
		tagY = tagY * self:getDRSclY();
	end

	return tagY;
end

--[[ 获取百分比XY坐标 ]]
function FitPolicy:getDRPercXy(x, y)
	x, y = self:checkXY_(x, y);
	return self:getDRPercX(x), self:getDRPercY(y);
end

--[[ 获取百分比坐标 ]]
function FitPolicy:getDRPercPos(x, y)
	local tagX, tagY = self:getDRPercXy(x, y);
	return cc.p(tagX, tagY);
end

--[[ 获取资源分辨率 ]]
function FitPolicy:getResRPSize()
	return cc.size(FIX_RES_WIDTH, FIX_RES_HEIGHT);
end

--[[ 获取设计与资源分辨率缩放X比例 ]]
function FitPolicy:getDRSclX()
	return display.width/FIX_RES_WIDTH;
end

--[[ 获取设计与资源分辨率缩放Y比例 ]]
function FitPolicy:getDRSclY()
	return display.height/FIX_RES_HEIGHT;
end

--[[ 检测X ]]
function FitPolicy:checkX_(x)
	local tagX;
	if tolua.type(x) == TO_LUA_TYPE_POINT then
		tagX = x.x;
	else
		tagX = x;
	end
	return tagX;
end

--[[ 检测Y ]]
function FitPolicy:checkY_(y)
	local tagY;
	if tolua.type(y) == TO_LUA_TYPE_POINT then
		tagY = y.y;
	else
		tagY = y;
	end
	return tagY;
end

--[[ 检测XY ]]
function FitPolicy:checkXY_(x, y)
	local tagX, tagY;
	if tolua.type(x) == TO_LUA_TYPE_POINT then
		tagX, tagY = x.x, x.y;
	else
		tagX, tagY = x, y;
	end
	assert(tagX and tagY, "FitPolicy:checkXY_ get error point.");

	return tagX, tagY;
end

return FitPolicy;
