--[[
	马甲包2辅助类
	@Author: ccb
	@Date: 2017-07-10
	-------------------
	1,	assets文件夹下为骨骼动画的表情, 需修改的有atlas文件及文件中对应的png
	2,	effect文件夹下为css/csb导出动画, 需修改的有ExportJson文件及文件中[config_file_path]和[config_png_path]
		plist文件需修改[realTextureFileName]和[textureFileName]
	3,	fonts文件夹下为bmf和atlas文件, bmf需修改fnt文件的[file]对应的png, atlas在调用的地方修改文件名即可
	4,	sound文件夹下为wav和mp3音效文件, 修改文件名，在调用的地方修改文件名即可
	6,	createRoom_1.json, CreateRoomUI_1.json, home.json这几个json文件无用
]]
local TAG = "#####XgAltPackHelp";
local print = print_r or print;
local fileUtils = CCFileUtils:sharedFileUtils();

local AltPackHelp = {};
AltPackHelp.AT_WORK = false;
AltPackHelp.INSTANCE = nil;

--[[ 构造方法 ]]
function AltPackHelp:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;

	-- 安卓不处理
	if device.platform == "android" then
		self.AT_WORK = false;
	end

	return o;
end

--[[ 应用 ]]
function AltPackHelp:apply()
	if not self.AT_WORK then return end

	self:__applyNewSprite();
	self:__applyPlaySound();
end

--[[ 创建精灵方法覆写 ]]
function AltPackHelp:__applyNewSprite()
	if not display or not display.newSprite or type(display.newSprite) ~= "function" then return end

	local oldfunc = display.newSprite;
	display.newSprite = function(filename, x, y, params)
		return oldfunc(self:convertResFileP(filename), x, y, params);
	end
end

--[[ 播放音效方法覆写 ]]
function AltPackHelp:__applyPlaySound()
	if not audio or not audio.playSound or type(audio.playSound) ~= "function" then return end

	local oldfunc = audio.playSound;
	audio.playSound = function(file, isLoop)
		oldfunc(self:convertSoundFileP(file), isLoop);
	end
end

--[[ 转换资源文件路径 ]]
function AltPackHelp:convertResFileP(file)
	if not self.AT_WORK then return file end

	local ftype = type(file);
	ftype = (ftype and ftype == "userdata") and (tolua.type(file)) or ftype;
	if ftype and ftype == "string" and string.byte(file) ~= 35 and not string.find(file, "netSprite") then
		-- 贴图路径且非精灵帧贴图、非网络拉取的资源, 则进行贴图名转换
		local putil = self:__getPlatformUtilIns();
		if putil and putil:isAbroadApp() then
			local p, fn = ospathsplit(file);
			local tmpfn = string.format("%s%sxgabd_%s", p or "", p and device.directorySeparator or "", fn);
			local tmpp = fileUtils:fullPathForFilename(tmpfn);
			file = fileUtils:isFileExist(tmpp) and tmpfn or file;
		end
	end
	return file;
end

--[[ 转换音效文件路径 ]]
function AltPackHelp:convertSoundFileP(file)
	if not self.AT_WORK then return file end

	local putil = self:__getPlatformUtilIns();
	if putil and putil:isAbroadApp() then
		local p, fn = ospathsplit(file);
		if fn then
			local tmpfn = string.format("%s%sxgabd_%s", p or "", p and device.directorySeparator or "", fn);
			local tmpp = fileUtils:fullPathForFilename(tmpfn);
			file = fileUtils:isFileExist(tmpp) and tmpfn or file;
		end
	end
	return file;
end

--[[ 获取平台工具实例 ]]
function AltPackHelp:__getPlatformUtilIns()
	local platformUtil = xg and xg.platform;
	if not platformUtil then
		local XgPlatform = require("app.xgame.base.XgPlatform");
		if XgPlatform and type(XgPlatform.getInstance) == "function" then
			platformUtil = XgPlatform:getInstance();
		end
	end
	return platformUtil;
end

--[[ 获取单例 ]]
function AltPackHelp:getInstance(...)
	local instance = self.INSTANCE;
	if not instance then
		instance = self:new(...);
		self.INSTANCE = instance;
	end
	return instance;
end

return AltPackHelp;
