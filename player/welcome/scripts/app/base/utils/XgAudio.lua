--[[
	音效简单管理
	@Author: ccb
	@Date: 2017-07-10
]]
local TAG = "#####XgAudio";
-- local print = print_r or print;

local AudioMgr = {};
AudioMgr.INSTANCE = nil;

-- 音效
AudioMgr.SOUNDS = {
	cd_1s 		= "sound/game/CountDown1s.mp3", -- 倒计时
	clt_chips 	= "sound/game/collect_chips.wav", -- 收集筹码
	deal_1_sg 	= "sound/game/deal_1-single.wav", -- 未知？
	win_sml 	= "sound/game/win_small.wav", -- 胜利
	fold_tk 	= "sound/game/Fold_TimerTick.mp3", -- 未知？
	y_turn 		= "sound/game/your_turn.wav", -- 自己顺序
	slider_top 	= "sound/game/slider_top.wav", -- 拖动下注栏
	slider_drag = "sound/game/slider.wav",
	slider_bet	= "sound/game/bet_slider.wav",
	notice 		= "sound/lobby/notice.wav", -- 提示
	check_1 	= "sound/game/check_01.wav",
	fold_r1		= "sound/game/fold_r1.wav",
	all_in 		= "sound/game/all_in.wav",
	lower_clk 	= "sound/lobby/ui_lowerClick_03.wav", -- 按钮点击
	cls_select 	= "sound/lobby/close_selection_r6.wav", -- 关闭窗口
	pay_shop 	= "sound/lobby/purchase_package_button.wav", -- 购物入袋
	short_clk 	= "sound/lobby/ui_click_short_bloop_deal_01.wav", -- 按钮点击
	jp_rwd_eft	= "sound/game/jp_rwd_eft.mp3",
	appear_thunder = "sound/game/multi_desk_appear_thunder.mp3",
};

--[[ 构造方法 ]]
function AudioMgr:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	return o;
end

--[[ 播放音效，并返回音效句柄 ]]
function AudioMgr:playSound(file, isLoop)
	if not file then return end

	file = self.SOUNDS[file] or file;
	return audio.playSound(file, isLoop);
end

--[[ 播放音乐 ]]
function AudioMgr:playMusic(file, isLoop, vol)
	if not file then return end

	file = self.SOUNDS[file] or file;
	isLoop = (isLoop == nil or (type(isLoop) == "boolean" and isLoop));

	self:stopMusic();
	audio.setMusicVolume(vol or 0.1);
	audio.playMusic(file, isLoop);
	self._fileMusic = file;
end

--[[ 停止音乐 ]]
function AudioMgr:stopMusic(bRelease)
	self._fileMusic = nil;
	audio.stopMusic(bRelease);
end

--[[ 暂停音乐 ]]
function AudioMgr:pauseMusic()
	audio.pauseMusic();
end

--[[ 恢复音乐 ]]
function AudioMgr:resumeMusic()
	audio.resumeMusic();
	self:checkMusicStateWhenAppResume();
end

--[[ 提醒音效 ]]
function AudioMgr:playNotice()
	self:playSound("notice");
end

--[[ 点击音效 ]]
function AudioMgr:playClick()
	self:playSound("short_clk");
end

--[[ 主界面tab音效 ]]
function AudioMgr:playMainMenuSound()
	self:playSound("lower_clk");
end

--[[ 进入房间音效 ]]
function AudioMgr:playEnterRoomSound()
	
end

--[[ 常规按钮音效 ]]
function AudioMgr:playNorBtnSound()
	self:playSound("short_clk");
end

--[[ 窗口关闭音效 ]]
function AudioMgr:playWindowClsSound()
	self:playSound("cls_select");
end

--[[ 商城点击音效 ]]
function AudioMgr:playShopPaySound()
	self:playSound("pay_shop");
end

--[[ 通过key获取文件 ]]
function AudioMgr:getFileByKey(key)
	if not key then return end

	local file = self.SOUNDS[key] or key;
	if file and xg and xg.altPackHelp then
		file = xg.altPackHelp:convertSoundFileP(file);
	end
	return file;
end

--[[ 程序唤醒时检测音乐播放状态 ]]
function AudioMgr:checkMusicStateWhenAppResume()
	if device.platform ~= "ios" then return end

	if self._fileMusic == nil then
		self:stopMusic();
	end
end

--[[ 顺序试听 ]]
function AudioMgr:orderAudition()
	local sounds = self.SOUNDS;
    self._adKeys = self._adKeys or table.keys(sounds);
    self._curAdIdx = self._curAdIdx or 0;
    self._curAdIdx = self._curAdIdx + 1;
    local sd = self._adKeys[self._curAdIdx];
    if self._curAdIdx > #self._adKeys then
        self._curAdIdx = 0;
    end

    self:playSound(sd);
end

--[[ 打印日志 ]]
function AudioMgr:printLog(...)
	if not print then return end

	print(...);
end

--[[ 获取单例 ]]
function AudioMgr:getInstance(...)
	local instance = self.INSTANCE;
	if not instance then
		instance = self:new(...);
		self.INSTANCE = instance;
	end
	return instance;
end

return AudioMgr;
