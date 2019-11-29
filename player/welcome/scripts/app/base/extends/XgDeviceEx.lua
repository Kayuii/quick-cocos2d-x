--[[
	Device Extension
	@Author: ccb
	@Date: 2017-06-10
]]
local device = device or {};

--[[ 判断录音是否可用 ]]
function device.handleRecord()
	local reValue = xg.platform:canRecord();
	if reValue == "restricted" then
		TipsLayer.show(string.format(XTEXT.audioRestrict, XConstants.APP_MNAME), 1);
		return "no";
	elseif reValue == "yes" then
		return "yes";
	else
		return "no";
	end
end

--[[ 房间邀请处理 ]]
function device.inviteRoomHandler(url)
	local scene = display.getRunningScene();
	if not scene then return end

	if scene.name == "HomeScene" then
		if scene.inviteRoomHandler then
			scene:inviteRoomHandler(url)
		end
	end
end

--[[ 是否是pad ]]
function device.isPad()
	local size = CCDirector:sharedDirector():getWinSize();
end

--[[ 检测是否为手机号 ]]
function device.checkIsPhone(str)
	local num = tonumber(str);
	if num then
		return num;
	else
		return false;
	end
end

--[[ 播放视频 ]]
function device.playVideo()
	xg.platform:playVideo();
end
