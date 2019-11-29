--[[
	String Extension
	@Author: ccb
	@Date: 2017-06-10
]]
local string = string or {};

GetPreciseDecimal = GetPreciseDecimal or function(nNum, n)
	if type(nNum) ~= "number" then
		return nNum
	end
	n = n or 0
	n = math.floor(n)
	if n < 0 then
		n = 0
	end
	local nDecimal = 10 ^ n
	local nTemp = math.floor(nNum * nDecimal)
	local nRet = nTemp / nDecimal
	return nRet
end

function string.conversiondigitalcn(num)
	num = tonumber(num)
	if math.floor(num/10000)>=1 and math.floor(num/10000)<10000 then
		return string.format("%d万", math.floor(num/10000))
	elseif math.floor(num/100000000)>=1 then
		return string.format("%d亿", math.floor(num/100000000))
	end
	return tostring(num)
end

--[[ 纯数字转化成带单位的模式 ]]
function string.convertChipFormat(param)
	if not param then return 0 end

	local num = tonumber(param);
	if not num then return 0 end

	local sign = "";
	if num < 0 then
		sign = "-";
	end
	num = math.abs(num);

	local value = "";
	local unit = "";
	local nNum = 0;
	if num < 10000000 then
		return sign .. tostring(num);
	elseif num < 1000000000 then
		nNum = num/1000000;
		unit = "M";
	else
		nNum = num/1000000000;
		unit = "T";
	end

	if nNum > 1000 then
		value = tostring(GetPreciseDecimal(nNum, 1)) .. unit;
	elseif nNum>100 then
		value = tostring(GetPreciseDecimal(nNum, 2)) .. unit;
	elseif nNum>0 then
		value = tostring(GetPreciseDecimal(nNum, 3)) .. unit;
	end

	if value ~= "" then
		local s, e = string.find(value, "%.000%a");
		if s ~= nil then
			return sign .. string.sub(value,1,s-1) .. string.sub(value, e);
		end
		s, e = string.find(value, "%.00%a");
		if s ~= nil then
			return sign .. string.sub(value, 1, s - 1) .. string.sub(value, e);
		end
		s, e = string.find(value, "00%a");
		if s ~= nil and string.find(value, "%.") then
			return sign .. string.sub(value, 1, s - 1) .. string.sub(value, e);
		end
		s, e = string.find(value, "%.0%a");
		if s ~= nil then
			return sign .. string.sub(value, 1, s - 1) .. string.sub(value, e);
		end
		s, e = string.find(value, "0%a");
		if s ~= nil and string.find(value, "%.") then
			return sign .. string.sub(value, 1, s - 1) .. string.sub(value, e);
		end
		return sign .. value;
	end
end

function string.convertChipFormat2(param)
	local num = tonumber(param);
	local sign = "";
	if num < 0 then
		sign = "-";
	end
	num = math.abs(num);

	local value=""
	local unit=""
	local nNum=0
	if num<10000000  then
		return sign..tostring(num)
	elseif num<10000000000 then
		nNum=num/1000000
		unit="M"
	else
		nNum=num/1000000000
		unit="T"
	end

	if nNum>0 then
		value=tostring(GetPreciseDecimal(nNum,1))..unit
	end
	if value ~="" then
		s,e=string.find(value,"%.0%a")
		if s~=nil then
			return sign..string.sub(value,1,s-1)..string.sub(value,e)
		end

		s,e=string.find(value,"0%a")
		if s~=nil then
			return sign..string.sub(value,1,s-1)..string.sub(value,e)
		end
		return sign..value
	end
end

--[[ 带单位模式的字符串转化成纯数字 ]]
function string.convertBackNum(param)
	local text = tostring(param)
	local s, e = string.find(text, "K")

	if s==nil then
		s,e=string.find(text,"M")
	else
		return tonumber(string.sub(text,1,s-1).."000")
	end


	if s==nil then
		s,e=string.find(text,"T")
	else
		return tonumber(string.sub(text,1,s-1)).."000000"
	end

	if s==nil then
		return text 
	else
		return tonumber(string.sub(text,1,s-1).."000000000")
	end

	return tonumber(text)
end

--[[ 纯数字转化事件 时：分：秒 ]]
function string.convertTimeFormat(sec)
	sec=tonumber(sec)
	local hour=math.floor(sec/3600)
	local min=math.floor((sec-hour*3600)/60)
	local s=sec-hour*3600-min*60
	local str=""
	if hour<10 then
		str="0"..tostring(hour)..":"
	else
		str=tostring(hour)..":"
	end
	if min<10 then
		str=str.."0"..tostring(min)..":"
	else
		str=str..""..tostring(min)..":"
	end
	if s<10 then
		str=str.."0"..tostring(s)
	else
		str=str..tostring(s)
	end

	return str
end

--[[ 秒数转换为时，分 ]]
function string.convertTimeFormat2(sec)
	sec=tonumber(sec)
	local hour=math.floor(sec/3600)
	local min=math.floor((sec-hour*3600)/60)
	local str=tostring(hour)..tostring(min)
	return str
end

--[[ 秒数转化为分，秒 ]]
function string.convertTimeFormat3(sec)
	sec=tonumber(sec)
	local hour=math.floor(sec/36000)
	local min=math.floor((sec-hour*3600)/60)
	local s=sec-hour*3600-min*60

	local str=""
	if hour>10 then
		str=tostring(hour)..":"
	elseif hour>0 then  
		str="0"..tostring(hour)..":"
	end

	if min<10 then
		str=str.."0"..tostring(min)..":"
	else
		str=str..""..tostring(min)..":"
	end

	if s<10 then
		str=str.."0"..tostring(s)
	else
		str=str..tostring(s)
	end

	return str
end

--[[ 转化时间带单位，保留一位小数点 ]]
function string.convertTimeFormat4(time)
	local sec = time
	if sec < 0 then
		sec = 0
	end
	if sec<60 then
		return sec..XTEXT.Time_sec
	elseif sec<3600 then
		return string.format("%d",sec/60)..XTEXT.Time_min
	else 
		return string.format("%.1f",sec/3600)..XTEXT.Time_hour
	end
end

--[[ 转化为分钟 ]]
function string.convertTimeFormat5(sec)
	if sec<0 then
		sec=0
	end

	return string.format("%.1f",sec/60)
end

--[[ 转化为年月日 时分 ]]
function string.convertTimeFormat6(sec)
	local date=os.date("*t",sec)
	local year=date.year
	local month=date.month
	local day=date.day

	-- local time=(date.hour or "00")..":"..(date.min or "00")

	local min = date.min or 0;
	if min <= 9 then min = "0"..min end;
	local hour = date.hour or 0;
	if hour <= 9 then hour = "0"..hour end;

	local time = hour..":"..min

	return year.."/"..month.."/"..day.." "..time
end

function string.conversionDecimaldigitalcn(num)
	num = tonumber(num)
	if num<=9999 then
		return tostring(num)
	end
	if num<=99999 then--5位X.XX万
		if num%10000==0 then
			return string.format("%d万", math.floor(num/10000))
		end
		
		local ret = string.split(num/10000,".")
		return ret[1].."."..string.sub(ret[2],1,2).."万"
	end
	if num<=999999 then--6位XX.X万
		if num%10000==0 then
			return string.format("%d万", math.floor(num/10000))
		end
		
		local ret = string.split(num/10000,".")
		return ret[1].."."..string.sub(ret[2],1,1).."万"
	end	
	if num<=99999999 then--78位 XXX XXXX万
		return string.format("%d万", math.floor(num/10000))
	end
	if num<=9999999999 then--9 10位 X.XX XX.XX亿
		if num%100000000==0 then
			return string.format("%d亿", math.floor(num/100000000))
		end

		local ret = string.split(num/100000000,".")
		return ret[1].."."..string.sub(ret[2],1,2).."亿"
	end
	if n>10000000000 then--11位 XXX.X亿
		if num%100000000==0 then
			return string.format("%d亿", math.floor(num/100000000))
		end

		local ret = string.split(num/100000000,".")
		return ret[1].."."..string.sub(ret[2],1,1).."亿"
	end
	return tostring(num)
end

function string.conversionDecimaldigitalcn2(num)
	num = tonumber(num)
	if num<=9999 then
		return tostring(num)
	end
	if num<=99999 then
		if num%10000==0 then
			return string.format("%dW", math.floor(num/10000))
		end
		
		local ret = string.split(num/10000,".")
		return ret[1].."."..string.sub(ret[2],1,2).."W"
	end
	if num<=999999 then
		if num%10000==0 then
			return string.format("%dW", math.floor(num/10000))
		end
		
		local ret = string.split(num/10000,".")
		return ret[1].."."..string.sub(ret[2],1,1).."W"
	end	
	if num<=99999999 then
		return string.format("%dW", math.floor(num/10000))
	end
	if num<=9999999999 then
		if num%100000000==0 then
			return string.format("%dY", math.floor(num/100000000))
		end

		local ret = string.split(num/100000000,".")
		return ret[1].."."..string.sub(ret[2],1,2).."Y"
	end
	if n>10000000000 then
		if num%100000000==0 then
			return string.format("%dY", math.floor(num/100000000))
		end

		local ret = string.split(num/100000000,".")
		return ret[1].."."..string.sub(ret[2],1,1).."Y"
	end
	return tostring(num)
end

--[[ 返回指定字节数的字符 中文一般占3字节 ]]
function string.subUTF8String(s, n)
	local dropping = string.byte(s, n+1)  
	if not dropping then return s end 
	if dropping >= 128 and dropping < 192 then  
		return string.subUTF8String(s, n-1)  
	end 
	return string.sub(s, 1, n)
end

--[[ 是否包含中文 ]]
function string.isExitCnchar(s)
	for i=1,#s do
		local byte = string.byte(s,i)
		if byte>127 then
			return true
		end
	end
	return nil
end

--[[
	UTF8的编码规则：
	1. 字符的第一个字节范围： 0x00—0x7F(0-127),或者 0xC2—0xF4(194-244); UTF8 是兼容 ascii 的，所以 0~127 就和 ascii 完全一致
	2. 0xC0, 0xC1,0xF5—0xFF(192, 193 和 245-255)不会出现在UTF8编码中 
	3. 0x80—0xBF(128-191)只会出现在第二个及随后的编码中(针对多字节编码，如汉字) 
]]
function string.StringToTable(s)
	local tb = {}
	for utfChar in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
		table.insert(tb, utfChar)
	end

	return tb
end

function string.GetUTFLen(s)
	local sTable = string.StringToTable(s)

	local len = 0
	local charLen = 0

	for i=1,#sTable do
		local utfCharLen = string.len(sTable[i])
		if utfCharLen > 1 then -- 长度大于1的就认为是中文
			charLen = 2
		else
			charLen = 1
		end
		len = len + charLen
	end

	return len
end

function string.GetUTFLenWithCount(s, count)
	local sTable = string.StringToTable(s)

	local len = 0
	local charLen = 0
	local isLimited = (count >= 0)

	for i=1,#sTable do
		local utfCharLen = string.len(sTable[i])
		if utfCharLen > 1 then -- 长度大于1的就认为是中文
			charLen = 2
		else
			charLen = 1
		end
		len = len + utfCharLen

		if isLimited then
			count = count - charLen
			if count <= 0 then
				break
			end
		end
	end

	return len
end

function string.cutMaxStr(str, maxLen)
	if str == nil then
		return str
	end
	local maxLen = maxLen or 10
	local sTable = string.StringToTable(str)
	local len = 0
	local len1 = 0
	local len2 = 0
	for i = 1, #sTable do
		local utfCharLen = string.len(sTable[i])
		if utfCharLen > 1 then
			len1 = len1 + 2
		else
			len1 = len1 + 1
		end
		if len1 > maxLen then
			break
		end
		len2 = len2 + utfCharLen
		len = len2
	end
	s = string.sub(str, 1, len);
	return s;
end

function string.GetMaxLenString(s, maxLen)
	local len = string.GetUTFLen(s)

	local isDst = false
	local dstString = s
	-- 超长，裁剪，加...
	if len > maxLen then
		dstString = string.sub(s, 1, string.GetUTFLenWithCount(s, maxLen))
		isDst = true;
		--dstString = dstString.."..."
	end

	return dstString, isDst;
end

function string.isAllIsDigital(s)
	local len  = string.len(s)
	local legal = true
	if len==0 then
		legal = false
	end
	for i=1,len do
		local byte = string.byte(s,i)
		if byte<48 or byte>57 then
			legal = false
			break
		end
	end
	return legal
end

function string.checkUrlLegal( urlStr )
	if string.find(urlStr,"http://") then
		return true
	end
	return false
end

--[[ 随机字符串 ]]
function string.getNonceStr()
	math.newrandomseed()
	local str = crypto.md5(tostring(math.random()))
	if str then
		return str
	end
	return "getNonceStrNull"
end

--[[ 倒计时转换 ]]
function string.convertToCountdown( seconds )
	local h = math.floor(seconds/3600)
	local m = math.floor((seconds-h*3600)/60)
	local s = seconds-h*3600-m*60
	return string.format("%02d:%02d:%02d",h,m,s)
end

--[[ 字符串截取加省略号 ]]
function string.truncatedApo(str,len)
	local str = tostring(str)
	if string.len(str)>len then
		str = string.subUTF8String(str, len)
		str = str.."..."
	end
	return str
end

--[[ 解析字符串参数 ]]
function string.parseUrlParam(url )
	local t1 = nil

	--,
	t1= string.split(url,',')

	--?
	url = t1[1]
	t1=string.split(t1[1],'?')
	url=t1[2]

	--&
	t1=string.split(t1[2],'&')
	local res = {}
	for k,v in pairs(t1) do
		i = 1
		t1 = string.split(v,'=')
		res[t1[1]]={}
		res[t1[1]]=t1[2]
		i=i+1
	end
	return res
end

--[[ 是否是几位-几位中文汉字 例:string.isPureCnWithPlace("啦啦",2,10) ]]
function string.isAllCnWithPlace( str,leftNum,rightNum )
	local allZhByte = true
	local len = #str
	for i=1,len do
		local byte = string.byte(str,i)
		if byte<=127 then
			allZhByte = false
		end
	end
	
	if allZhByte then
		local zhSymbols = { "‘","“","，","。","？","！","、","：","；","…","〝","〞","‘","’","（","）","《","》","【","】","『","』","〖","〗","［","］","〔","〕","「","」","﹁","﹃","﹂","﹄","¸"}
		local isExistSynbols = false
		for i=1,math.floor(len/3) do
			local s = (i-1)*3+1
			local oneZh = string.sub(str,s,s+2)
			for i2,v in ipairs(zhSymbols) do
				if v==oneZh then
					isExistSynbols = true
					break
				end
			end
		end

		if not isExistSynbols then
			if len>=leftNum*3 and len<=rightNum*3 then
				return true
			end
		end
	end	
	return false
end

--[[ 是否是几位-几位数字 ]]
function string.isAllDigWithSpace(str,leftNum,rightNum)
	local len = #str
	if len>=leftNum and len<=rightNum then
		return string.isAllIsDigital(str)
	end
	return false
end

--[[ 是否全是空格 ]]
function string.isAllSpaces(str)
	if str~="" then
		for i=1,#str do
			local byte = string.byte(str,i)
			if byte~=32 then
				return false
			end
		end
		return true
	else
		return false
	end
end

--[[ 是否含有空格 ]]
function string.isContainSpaces(str)
	if str~="" then
		for i=1,#str do
			local byte = string.byte(str,i)
			if byte==32 then
				return true
			end
		end
	end
	return false
end

function string.includeSensitiveword(str)
	local file = io.open(CCFileUtils:sharedFileUtils():fullPathForFilename("profiles/textfilter.txt"),"r")
	if file then
		for line in file:lines() do
			if line~="" and string.find(str,line)~=nil then
				TipsLayer.show( string.format(XTEXT.error_sensitiveWord,line))
				return true,line
			end
		end
		file:close()
	end

	return false
end

--[[ str 字符串3位分割，逗号隔开 ]]
function string.conversionWithComma(str)
	local sub_str=""
	local param_str=str
	--if string.isAllIsDigital(str) then
	if string.len(str)>3 then
		for i=string.len(str),1,-3 do
			local sub1=string.sub(param_str,i-2,i)
			if sub1 =="" then
				sub1=string.sub(param_str,1,i)
				sub_str=sub1..sub_str
			else
				if i<=3 then
					sub_str=sub1..sub_str
				else
					sub_str=","..sub1..sub_str
				end
			end
		end
	else
		sub_str=str
	end
	return sub_str
end
