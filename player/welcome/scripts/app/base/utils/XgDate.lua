--[[
	时间/日期转换
	@Author: ccb
	@Date: 2017-06-10
]]
local XgDate = {};

XgDate.I2S_TYPE = {
	HMS = 0,		-- 13:14:20 倒计时
	HM = 1,			-- 13:14 倒计时
	MD = 2,			-- 5/05 时间戳
	MDEX = 3,		-- 13:14 时间戳只取时分
	YMD = 4,		-- 2017/05/05 时间戳
	YMD_HMS = 5,	-- 2017/05/05 13:14:20 时间戳
	HMS_STP = 6,	-- 13:14:20 时间戳
	MD_HM = 7,		-- 05/05 13:14
	MDW = 8,		-- 01月01日 周一
};

--[[
	根据倒计时/时间戳转换为字符串
	@params int 倒计时/时间戳
			tType 转换类型，参考I2S_TYPE
			tLink 时间分隔符
			dLink 日期分隔符
	@return str 转换后
]]
function XgDate.getTimeString(int, tType, tLink, dLink, def)
	int = tonumber(int) or 0;
	tType = tType or XgDate.I2S_TYPE.HMS;

	if(int <= 0)then
		return def or "00:00:00";
	end

	tLink = tLink or ":";
	dLink = dLink or "/";
	local hour = math.floor(int/(60*60));
	local minute = math.floor((int/60)%60);
	local second = int%60 or 0;
	local year = os.date("%Y", int);
	local month = os.date("%m", int);
	local date = os.date("%d", int);

	local function get_ymd()
		local y, m, d = os.date("%Y", int), os.date("%m", int), os.date("%d", int);
		return y, m, d;
	end
	local function get_hms()
		local h, m, s = math.floor(int/(60*60)), math.floor((int/60)%60), int%60 or 0;
		return h, m, s;
	end
	local function get_hms_stamp()
		local h, m, s = os.date("%H", int), os.date("%M", int), os.date("%S", int);
		return h, m, s;
	end

	if tType == XgDate.I2S_TYPE.HM then
		local h, m = get_hms();
		return string.format("%02d%s%02d", h, tLink, m);
	elseif tType == XgDate.I2S_TYPE.HMS then
		local h, m, s = get_hms();
		return string.format("%02d%s%02d%s%02d", h, tLink, m, tLink, s);
	elseif tType == XgDate.I2S_TYPE.YMD then
		local y, m, d = get_ymd();
		return string.format("%d%s%02d%s%02d", y, dLink, m, dLink, d);
	elseif tType == XgDate.I2S_TYPE.YMD_HMS then
		local y, mth, d = get_ymd();
		local h, mir, s = get_hms_stamp();
		return string.format("%d%s%02d%s%02d %02d%s%02d%s%02d", y, dLink, mth, dLink, d, h, tLink, mir, tLink, s);
	elseif tType == XgDate.I2S_TYPE.MD then
		local y, mth, d = get_ymd();
		return string.format("%2d%s%02d", mth, dLink, d);
	elseif tType == XgDate.I2S_TYPE.MDEX then
		local h, m = get_hms_stamp();
		return string.format("%02d%s%02d", h, tLink, m);
	elseif tType == XgDate.I2S_TYPE.HMS_STP then
		local h, m, s = get_hms_stamp();
		return string.format("%02d%s%02d%s%02d", h, tLink, m, tLink, s);
	elseif tType == XgDate.I2S_TYPE.MD_HM then
		local y, mth, d = get_ymd();
		local h, mir, s = get_hms_stamp();
		return string.format("%02d%s%02d %02d%s%02d", mth, dLink, d, h, tLink, mir);
	elseif tType == XgDate.I2S_TYPE.MDW then
		local y, mth, d = get_ymd();
		local w = os.date("%w", int);
		return string.format("%s%s%s%s %s", mth, XTEXT.month, d, XTEXT.day, XTEXT["date_wek_" .. w]);
	end
end

--[[
	将时间字符串转时间戳
	ep: 2017/06/10 23:59:59 -> 1497110399
	@params des 字符串
			dLink 日期分隔符
			tLink 时间分隔符
	@return tagDate 转换后
]]
function XgDate.getTimeFromString(des, dLink, tLink)
	if not des then return end

	dLink = dLink or "/";
	tLink = tLink or ":";
	local aryDate = string.split(des, " ");
	local date = string.split(aryDate[1], dLink);
	local time = string.split(aryDate[2], tLink);

	local tb = {
		year 	= date[1],
		month 	= date[2],
		day 	= date[3],
		hour 	= time[1],
		min 	= time[2],
		sec 	= time[3],
	};
	local tag = os.time(tb);
	return tag;
end

--[[
	将时间字符串转时间数据
	ep: 2017/06/10 23:59:59
	@params des 字符串
			dLink 日期分隔符
			tLink 时间分隔符
	@return tagDate 转换后
]]
function XgDate.getDateFromString(des, dLink, tLink)
	local tm = XgDate.getTimeFromString(des, dLink, tLink);
	if not tm then return end

	local tagDate = os.date("*t", tm);
	return tagDate;
end

--[[
	获取相差天数(只限于同一年内)
	@params t1 时间戳1
			t2 时间戳2
	@return dif 相差天数
]]
function XgDate.getDifDay(t1, t2)
	local tm1, tm2 = os.date("*t", t1), os.date("*t", t2);
	local dif = math.abs(tm1.yday - tm2.yday);
	return dif;
end

--[[ 转换秒为s/m/h ]]
function XgDate.covertSec2SMH(sec)
	sec = sec or 0;
	sec = math.max(0, sec);

	if sec < 60 then
		return string.format("%ss", sec);
	elseif sec < 3600 then
		return string.format("%dm", sec/60);
	else 
		return string.format("%.1fh", sec/3600);
	end
end

--[[ 转换字符串为秒(ep:1800, 1800s, 30m, 0.5h) ]]
function XgDate.convertStr2Sec(str)
	if not str then return end

	local sec = tonumber(str);
	if not sec then
		if string.find(str, "s") then
			sec = tonumber(string.sub(str, 1, -2));
		elseif string.find(str, "m") then
			sec = tonumber(string.sub(str, 1, -2)) * 60;
		elseif string.find(str, "h") then
			sec = tonumber(string.sub(str, 1, -2)) * 60 * 60;
		end
	end
	return sec;
end

--[[ 转换字符串为分钟(ep:1800, 1800s, 30m, 0.5h) ]]
function XgDate.convertStr2Mint(str)
	if not str then return end

	local mint = tonumber(str);
	if not mint then
		if string.find(str, "s") then
			mint = tonumber(string.sub(str, 1, -2))/60;
			mint = math.floor(mint);
		elseif string.find(str, "m") then
			mint = tonumber(string.sub(str, 1, -2));
		elseif string.find(str, "h") then
			mint = tonumber(string.sub(str, 1, -2)) * 60;
		end
	end
	return mint;
end

--[[ 获取当年当月天数 ]]
function XgDate.getMonthDay(str_tm)
	local y = os.date("%Y", str_tm);
	local m = os.date("%m", str_tm);
	local tmptm = os.time({year = y, month = m + 1, day = 0});
	local day = os.date("%d", tmptm);
	return tonumber(day);
end

--[[ 获取连续几天的天数 ]]
function XgDate.getInRowDays(str_tm, int)
	local y = os.date("%Y", str_tm);
	local m = os.date("%m", str_tm);
	local d = os.date("%d", str_tm);

	local arr = {str_tm};
	local tagd, tagm, tagtm = d, m, nil;
	local maxd = XgDate.getMonthDay(str_tm);
	for i = 1, (int or 1) do
		tagd = tagd + 1;
		if tonumber(tagd) > maxd then
			tagd = 1;
			tagm = tagm + 1;
			tagtm = os.time({year = y, month = tagm, day = tagd});
			maxd = XgDate.getMonthDay(tagtm);
		else
			tagtm = os.time({year = y, month = tagm, day = tagd});
		end
		table.insert(arr, tagtm);
	end
	return arr;
end

return XgDate;
