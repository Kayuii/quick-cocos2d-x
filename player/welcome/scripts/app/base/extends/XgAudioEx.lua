--[[
	audio Extension
	@Author: ccb
	@Date: 2017-06-10
]]
local audio = _G.audio or require("framework.audio");
_G.audio = audio;

-- 音效
local sound_fpath = {
	short_clk 	= "sound/lobby/ui_click_short_bloop_deal_01.wav", -- 按钮点击
	cls_select 	= "sound/lobby/close_selection_r6.wav", -- 关闭窗口
	pay_shop 	= "sound/lobby/purchase_package_button.wav", -- 购物入袋
};

local function getAudioUtil()
	local audioUtil = xg and xg.audio;
	if not audioUtil then
		local XgAudio = require("app.xgame.base.utils.XgAudio");
		if XgAudio and type(XgAudio.getInstance) == "function" then
			audioUtil = XgAudio:getInstance();
		end
	end
	return audioUtil;
end

local function playSoundWithUtil(file)
	audio.playSound(file);
end

audio.playClick = audio.playClick or function()
	local util = getAudioUtil();
	if util then
		util:playClick();
	else
		playSoundWithUtil(sound_fpath.short_clk);
	end
end

audio.playNormalButtonSound = audio.playNormalButtonSound or function()
	local util = getAudioUtil();
	if util then
		util:playNorBtnSound();
	else
		playSoundWithUtil(sound_fpath.short_clk);
	end
end

audio.playWindowCloseSound = audio.playWindowCloseSound or function()
	local util = getAudioUtil();
	if util then
		util:playWindowClsSound();
	else
		playSoundWithUtil(sound_fpath.cls_select);
	end
end

audio.playShopButtonSound = audio.playShopButtonSound or function()
	local util = getAudioUtil();
	if util then
		util:playShopPaySound();
	else
		playSoundWithUtil(sound_fpath.pay_shop);
	end
end
