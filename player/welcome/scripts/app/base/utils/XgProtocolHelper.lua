--[[
	协议帮助相关
	@Author: ccb
	@Date: 2017-06-10
]]
local ProtocolHelper = {};

ProtocolHelper.KEYS = {
	TEXAS = "TPvpdHoldEm",
};

--[[ 获取poker加解密key ]]
function ProtocolHelper:getTexasCodeKey(key)
	if not key then return end

	return string.format("%s.%s", self.KEYS.TEXAS, key);
end

--[[ 获取poker的协议id ]]
function ProtocolHelper:getTexasProtoId(key)
	if not key then return end

	local pid = Texas_tpvp_pb and Texas_tpvp_pb[key];
	if not pid then
		printf_r("ProtocolHelper -getTexasProtoId get nil protocol id[%s].", key);
	end
	return pid;
end

return ProtocolHelper;
