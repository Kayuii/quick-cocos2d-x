--[[
	平台相关的luaj/luaoc接口
	@Author: ccb
	@Date: 2017-06-06
]]
local platform = {};
platform.INSTANCE = nil;
platform.VIDEO_P_J = "res/loading.mp4";

platform.CLS_NAME_OC = "AppController";
platform.CLS_NAME_OC_SVU_UID = "SvUUIDTools";
platform.CLS_NAME_J_DEF = g_AndroidGameConfig and g_AndroidGameConfig.AndroidActivityName;
platform.CLS_NAME_J = g_AndroidGameConfig and g_AndroidGameConfig.AndroidActivityName or platform.CLS_NAME_J_DEF;
platform.CLS_NAME_J_VIDEO = "com/game515/video/VideoView";
platform.CLS_NAME_J_GT_SDK = "com/game515/getui/GeTuiSdk";
platform.CLS_NAME_J_WX_SHARE = "com/game515/share/WeChatShare";
platform.CLS_NAME_J_QQ_SHARE = "com/game515/share/QQOpenShare";

platform.BUNDLE_ID_FP = "com.alchemy.facepoker";
platform.BUNDLE_ID_ABROAD_FP = "com.alchemy.facepokerabroad";
platform.BUNDLE_ID_XY_FP = "com.game515.dezhou.xy";
platform.BUNDLE_ID_WYW_FP = "com.game515.wywdezhou";
platform.BUNDLE_ID_515_FP = "com.game515.515dezhou";
platform.BUNDLE_ID_515_EX_FP = "com.game515.dezhou515";
platform.BUNDLE_ID_DN = "com.alchemy.bullcircle";
platform.BUNDLE_ID_DN_2 = "com.alchemy.bullcircleds";
platform.BUNDLE_ID_DN_3 = "com.alchemy.microbull";
platform.BUNDLE_ID_DW = "com.alchemy.supergame";

platform.INTERFACE_PREFIX = {
	[platform.BUNDLE_ID_FP] = "xgfp_",
	[platform.BUNDLE_ID_DW] = "xgdw_",
	[platform.BUNDLE_ID_DN_2] = "xgdn_",
	[platform.BUNDLE_ID_DN_3] = "xgdn_",
	[platform.BUNDLE_ID_ABROAD_FP] = "xgabd_",
	[platform.BUNDLE_ID_DN_3] = "xgdn_",
};

local print = print_r or print;

--[[ 构造方法 ]]
function platform:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;

	-----------------------------------------------
	-- 此处处理为兼容海外代签包不同版本
	-- 注意: 如果全升级为最新版本，此处代码最好删除
	if self._bIosOldBuildV == nil then
		-- IOS低构造版本，新构造版本luaoc接口增加前缀
		local uid = self:getIdentifier();
		self._bIosOldBuildV = (uid == nil);
	end
	-----------------------------------------------

	return o;
end

--[[ 判断是否为海外app ]]
function platform:isAbroadApp()
	if device.platform == "android" then
		-- 没有国内包,统一海外全球包.
		return g_AndroidGameConfig.isAbroad;
	elseif device.platform == "ios" then
		local bId = self:getBundleId();
		return bId == self.BUNDLE_ID_ABROAD_FP;
	end
end

--[[ 设置app的相关信息 ]]
function platform:setAppInfoByBundleId()
	local bId = self:getBundleId();
	if XConstants and type(XConstants) == "table" then
		local arrCfg = {
			[self.BUNDLE_ID_FP] = {
				MyiOSAppID = "1207205524",
				APP_MNAME = XTEXT.appName,
				WXAppId = "wx0906a2b575ae38d4",
				QQAppId = "1105912648",
				QQLocalAppId = "XGame",
				UMengAppKey = "",
			},
			[self.BUNDLE_ID_ABROAD_FP] = {
				MyiOSAppID = "1373172705",
				APP_MNAME = XTEXT.appName_ex,
				WXAppId = "wxb9447989408fc1f1",
				QQAppId = "",
				QQLocalAppId = "",
				UMengAppKey = "",
			},
			[self.BUNDLE_ID_WYW_FP] = {
				MyiOSAppID = "1054312856",
				APP_MNAME = "face pocker",
				WXAppId = "wx0906a2b575ae38d4",
				QQAppId = "1105912648",
				QQLocalAppId = "wywdezhou",
				UMengAppKey = "563332a567e58ea34400278e",
			},
			[self.BUNDLE_ID_515_FP] = {
				MyiOSAppID = "1066070758",
				APP_MNAME = "515",
				WXAppId = "wx0906a2b575ae38d4",
				QQAppId = "1105912648",
				QQLocalAppId = "dezhou515",
				UMengAppKey = "561e263f67e58e3757000b21",
			},
			[self.BUNDLE_ID_DN] = {
				MyiOSAppID = "1332914668",
				APP_MNAME = XTEXT.appName,
				WXAppId = "wxdc6d764b3d28b47d",
				QQAppId = "1106504418",
				QQLocalAppId = "NGame",
				UMengAppKey = "",
			},
			[self.BUNDLE_ID_DW] = {
				MyiOSAppID = "1332914668",
				APP_MNAME = XTEXT.appName,
				WXAppId = "wxdc6d764b3d28b47d",
				QQAppId = "1106504418",
				QQLocalAppId = "WGame",
				UMengAppKey = "",
			},
		};
		local cfg = arrCfg[bId];
		if cfg and next(cfg) then
			for k,v in pairs(cfg) do
				XConstants[k] = v;
			end
		end
	end
end

--[[ 获取账户代理人信息 ]]
function platform:getAccAgentInfo()
	local arrTag = {
		agentID = 0,
		mobileDevice = 0,
	};
	if device.platform == "ios" then
		local arr = {
			[self.BUNDLE_ID_515_FP] = 10004,
			[self.BUNDLE_ID_WYW_FP] = 10015,
		};
		local bId = self:getBundleId();

		arrTag.mobileDevice = 1;
		arrTag.agentID = arr[bId] or arrTag.agentID;
	elseif device.platform == "android" then
		--[[
			10005官网
			10006应用宝
			10013百度联运
			10019联通
			10028应用汇
			10033小辣椒
			10026卓易
			10031魅族
		]]
		arrTag.agentID = 10005;
		arrTag.mobileDevice = 2;
	end
	return arrTag;
end

--[[ 获取appId和渠道名 ]]
function platform:getAppIdChannel()
	local arrTag = {
		AppleAppId = "1207205524",
		CHANNEL_NAME = "iOS_AppStore",
	};
	if device.platform == "ios" then
		local arrCfg = {
			[self.BUNDLE_ID_WYW_FP] = {
				AppleAppId = "1054312856",
				CHANNEL_NAME = "iOS_com.game515.wywdezhou",
			},
			[self.BUNDLE_ID_515_FP] = {
				AppleAppId = "1066070758",
				CHANNEL_NAME = "iOS_com.game515.515dezhou",
			},
			[self.BUNDLE_ID_515_EX_FP] = {
				AppleAppId = "1066070758",
				CHANNEL_NAME = "iOS_AppStore",
			},
			[self.BUNDLE_ID_XY_FP] = {
				AppleAppId = "1066070758",
				CHANNEL_NAME = "iOS_com.game515.dezhou.xy",
			},
		};
		local bId = self:getBundleId();
		arrTag = arrCfg[bId] or arrTag;
	elseif device.platform == "android" then
		arrTag.CHANNEL_NAME = "Android";
	end
	return arrTag;
end

--[[ 获取设备Identifier ]]
function platform:getIdentifier()
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC_SVU_UID, "UDID");
		if ok then return ret end
	elseif device.platform == "android" then
		if androidIdentifier then return androidIdentifier end;
		
		local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "getDeviceId", {}, "()Ljava/lang/String;");
		if ok then
			androidIdentifier = ret;
			return ret;
		end
	end
	return nil;
end

--[[ 获取bundle Id ]]
function platform:getBundleId()
	if device.platform == "ios" then
		-- 该方法不参与混淆，用于判断国内海外包
		local ok, ret = luaoc.callStaticMethod(self.CLS_NAME_OC, "getBundleIdentifier");
		if ok then return ret end
	elseif device.platform == "android" then
		return "android";
	end
	return "";
end

--[[ 获取版本号, 检测是否ios审核中 ]]
function platform:getBundleVersion()
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "getCurrentBundleVerison");
		if ok then return ret end
	elseif device.platform == "android" then
		-- local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "getCurrentVersionName",{},"()V");
		-- if ok then return ret end
		return g_AndroidGameConfig.GameVersion or "1.0";
	end
	return nil;
end

--[[ 获取构建版本 ]]
function platform:getBuildVersion()
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "getCurrentBundleBuild");
		if ok then return ret end
	elseif device.platform == "android" then
		local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "getCurrentVersionCode", {}, "()I");
		if ok then return ret end
	end
end

--[[ 获取版本号 ]]
function platform:getVersionStr(def)
	local ver = self:getBundleVersion();
	ver = (not ver or ver == "") and (def or "1.0") or ver;
	local s, e = string.find(ver, "^%d+%.%d+$");
	if s and e then
		-- ios大版本
		ver = string.format("%s.0", ver);
	end
	return ver;
end

--[[ 获取小版本号 ]]
function platform:getMinVersionStr()
	local ver = self:getVersionStr();
	if device.platform == "android" then
		return ver;
	end 

	local localData = require("app.xgame.base.utils.XgLocalData"):getInstance();
	local curVer = localData:getCurVerCode();
	curVer = (curVer and curVer ~= "") and curVer or ver;
	return curVer or "0.0.1";
end

--[[ 获取审核期间伪版本号 ]]
function platform:getFackVersionStr()
	if device.platform ~= "ios" then return end

	local ver = self:getMinVersionStr();
	local arrver = string.split(ver, ".");
	local minVer = arrver and arrver[3];
	local tagver = ver;
	if minVer and minVer ~= 0 then
		tagver = string.format("%s.%s.0", tonumber(arrver[1] or 0), tonumber(arrver[2] or 0) + 1);
	end
	return tagver;
end

--[[ 获取本地ip ]]
function platform:getLocalIP()
	if device.platform == "ios" then
		local ok, ip = self:luaoc_callsmethod(self.CLS_NAME_OC, "localIPAddress");
		if ok then return ip end
	end

	return "127.0.0.1";
end

--[[ 获取渠道id ]]
function platform:getPlatformId()
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "getPlatformId", {}, "()Ljava/lang/String;");
		if ok then return tonumber(ret) end
	end
end

--[[ 获取个推的clientId ]]
function platform:getGeTuiClientId()
	if self:isAbroadApp() then return end

	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "getGeTuiClientid");
		if ok then return ret end
	elseif device.platform == "android" then
		local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J_GT_SDK, "getClientid", {}, "()Ljava/lang/String;");
		if ok then return ret end
	end
end

--[[ 获取设备令牌(推送用) ]]
function platform:getDeviceTokenEx()
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "getDeviceTokenEx");
		if ok then return ret end
	end
end

--[[ 获取设备类型 ]]
function platform:getDeviceName()
	if device.platform == "ios" then
		return CCNative:getDeviceName();
	elseif device.platform == "android" then
		local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "getDeviceName", {}, "()Ljava/lang/String;");
		if ok then return ret end
	end
	return "Guest";
end

--[[ qq微信-注册appid ]]
function platform:qqwx_registerApp()
	if self:isAbroadApp() then return end

	if device.platform == "ios" then
		if XConstants.QQAppId and XConstants.QQAppId ~= "" then
			local ops = {
				appid = tostring(XConstants.QQAppId),
				localAppId = tostring(XConstants.QQLocalAppId),
			};
			self:luaoc_callsmethod(self.CLS_NAME_OC, "TencentOAuthAlloc", ops);
		end
		if XConstants.WXAppId and XConstants.WXAppId ~= "" then
			self:luaoc_callsmethod(self.CLS_NAME_OC, "WXApiRegisterApp", {tostring(XConstants.WXAppId)});
		end
	end
end

--[[ 微信-授权 ]]
function platform:wx_authorize()
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "ReqWXAuth");
	else
		luaj.callStaticMethod(self.CLS_NAME_J, "WeChatLogin", {}, "()V");
	end
end

--[[ 微信-开始支付 ]]
function platform:wx_startPay(tb)
	if self:isAbroadApp() then return end

	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "StartWXPayment", tb);
	elseif device.platform == "android" then
		local tStr = "Ljava/lang/String;";
		local sigs = string.format("(%s%s%s%s%s%s%s)V", tStr, tStr, tStr, tStr, tStr, tStr, tStr);
		local args = {tb.appid, tb.partnerid, tb.prepayid, tb.package, tb.noncestr, tb.timestamp, tb.sign};
		luaj.callStaticMethod(self.CLS_NAME_J, "StartWXPayment", args, sigs);
	end
end

--[[ 微信-分享 ]]
function platform:wx_share(tb)
	if self:isAbroadApp() then return end
	
	local def = {
		title = "TestShare",
		description = "This is a Test.",
		icon = device.writablePath .. "share.png",
	};
	local data = tb or def;
	data.url = tb.url or data.url;
	data.icon = data.icon or def.icon;
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "WeixinOrientationShare", data);
	elseif device.platform == "android" then
		local shareType = (tb.scene and tb.scene == "WXSceneTimeline") and 2 or 1;
		local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V";
		local args = {tostring(data.url), tostring(data.title), tostring(tb.description), shareType};
		luaj.callStaticMethod(self.CLS_NAME_J_WX_SHARE, "WeixinOrientationShare", args, sigs);
	end
end

--[[ 微信-分享至朋友圈 ]]
function platform:wx_share2FrdCircle(tb)
	tb = tb or {};
	tb.scene = "WXSceneTimeline";
	self:wx_share(tb);
end

--[[ 微信-纯图片分享 ]]
function platform:wx_shareWithPicture(tb)
	if device.platform == "android" then
		tb = tb or {};
		local args = {tb.url, tb.type, display.width, display.height};
		luaj.callStaticMethod(self.CLS_NAME_J_WX_SHARE, "WeixinOrientationSharePicture", args, "(Ljava/lang/String;III)V");
	end
end

--[[ QQ-授权 ]]
function platform:qq_authorize()
	if self:isAbroadApp() then return end

	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "QQAuthorize");
	elseif device.platform == "android" then
		luaj.callStaticMethod(self.CLS_NAME_J, "QQAuthorize");
	end
end

--[[ QQ-分享(链接+标题等) ]]
function platform:qq_share(tb)
	if self:isAbroadApp() then return end

	local def = {
		title = "TestShare",
		description = "This is a Test.",
		icon = device.writablePath .. "share.png",
	};
	local data = tb or def;
	data.url = tb.url or data.url;
	data.icon = data.icon or def.icon;
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "QQOrientationShare", data);
	elseif device.platform == "android" then
		local shareType = ((data and data.scene) == "QQZone") and 2 or 1;
		local icon = "https://cdn.qq409.cn/Public/static/images/icon.png"; --网络图片地址
		local args = {data.title or "", data.url, data.description or "", icon, shareType};
		local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V";
		luaj.callStaticMethod(self.CLS_NAME_J_QQ_SHARE, "shareToQQ", args, sigs);
	end
end

--[[ QQ-分享至空间 ]]
function platform:qq_share2Qzone(tb)
	if self:isAbroadApp() then return end

	tb = tb or {};
	tb.scene = "QQZone";
	self:qq_share(tb);
end

--[[ QQ-纯图片分享 ]]
function platform:QQ_shareWithPicture(tb)
	if self:isAbroadApp() then return end

	if device.platform == "android" then
		tb = tb or {};
		local args = {tb.url, tb.type};
		luaj.callStaticMethod(self.CLS_NAME_J_QQ_SHARE, "shareToQQPicture", args, "(Ljava/lang/String;I)V");
	end
end 

--[[ 支付宝-开始支付 ]]
function platform:ali_startPay(tb)
	if self:isAbroadApp() then return end

	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "StartAlipay", tb);
	elseif device.platform == "android" then
		local args = {tb.orderSpec, tb.RSAPRIVATE};
		local sigs = "(Ljava/lang/String;Ljava/lang/String;)V";
		luaj.callStaticMethod(self.CLS_NAME_J, "StartAlipay", args, sigs);
	end
end

--[[ iap开始购买 ]]
function platform:iapStartBuy(tb)
	if not ShowGuestLogin and self:isAbroadApp() then return end
	
	-- 如果传入的是商品id
	if type(tb) == "string" or type(tb) == "number" then
		tb = {tostring(tb)};
	end
	tb = tb or {};
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "StartBuyProduct", tb);
	end
end

--[[ 添加交易监听 ]]
function platform:addPayTransactionObserver(tb)
	-- 如果传入的是监听方法
	if type(tb) == "function" then
		tb = {listener = tb};
	end
	tb = tb or {};
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "AddPaymentTransactionObserver", tb);
	end
end

--[[ iap购买成功 ]]
function platform:iapRechargeSuc(tb)
	-- 如果传入的是订单id
	if type(tb) == "string" or type(tb) == "number" then
		tb = {tostring(tb)};
	end
	tb = tb or {};
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "AppleRechargeSuccess", tb);
	end
end

--[[ 设置用户信息 ]]
function platform:setUserInfo(id)
	id = id or (UserInfo and UserInfo.id);
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "SetUserInfo", {tostring(id)});
	end
end

--[[ 判断是否可以开启录音权限(默认开启？) ]]
function platform:canRecord()
	if device.platform == "ios" then
		local ok, status = self:luaoc_callsmethod(self.CLS_NAME_OC, "canRecord");
		if ok then return status end
	end
	return "yes";
end

--[[ 打开相册库 ]]
function platform:openPhotoLib(tb)
	if not tb or not next(tb) then return end

	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "OpenPhotoLibrary", tb);
	elseif device.platform == "android" then
		luaj.callStaticMethod(self.CLS_NAME_J, "OpenPhotoLibrary", {tb.savePath, tb.listener}, "(Ljava/lang/String;I)V");
	end
end

--[[ 打开摄像 ]]
function platform:openCamera(tb)
	if not tb or not next(tb) then return end

	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "OpenCamera", tb);
	elseif device.platform == "android" then
		luaj.callStaticMethod(self.CLS_NAME_J, "OpenCamera", {tb.savePath, tb.listener}, "(Ljava/lang/String;I)V");
	end
end

--[[ 播放视频 ]]
function platform:playVideo(path)
	if device.platform == "android" then
		path = path or self.VIDEO_P_J;
		luaj.callStaticMethod(self.CLS_NAME_J_VIDEO, "playVideo", {path}, "(Ljava/lang/String;)V");
	end
end

--[[ 执行震动 ]]
function platform:vibrate()
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "vibrate");
	elseif device.platform == "android" then
		local time = 500; -- 0.5秒
		luaj.callStaticMethod(self.CLS_NAME_J, "vibrate", {time}, "(I)V");
	end
end

--[[ 
	打开iTunes
	@params appId：不传则打开本APP
 ]]
function platform:openiTunesApp(appId)
	appId = appId or (XConstants and XConstants.MyiOSAppID);
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "OpeniTunesApp", {appId});
		if ok then return true end
	end
	return false;
end

--[[ 
	打开其他APP
	@params appKey：app键值
 ]]
function platform:OpenOtherApp(appKey)
	appKey = appKey or "XGame";
	local tmp = {app_key = appKey};
	if appKey == "XGame" then
		tmp.app_id = XConstants.FacePokerAppID;
	end
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "OpenOtherApp", tmp);
		if ok then return true end
	elseif device.platform == "android" then
        local args = {"com.game515.poker","https://www.facepoker.cc/Admin/Wx/download"}
        luaj.callStaticMethod(g_AndroidGameConfig.AndroidActivityName, "startAppOrUrl",args,"(Ljava/lang/String;Ljava/lang/String;)V")
	end
	return false;
end


--[[ 检测相册中是否已存在某图片 ]]
function platform:searchAlbumImgByAssertId(tb)
	local key = tb.key or nil;
	if not key then return end

	local astId;
	local bFind = false;
	local cash = GameData and GameData.mltSave2AlbumCash;
	if cash and next(cash) then
		astId = cash[key];
	end

	if astId then
		-- 检测相册中是否已存在该图片
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "SearchAlbumImgByAssertId", {astId});
		if ok then
			bFind = (ret and ret == "true");
		end
	end

	return bFind;
end

--[[ 保存图片到用户本地相机胶卷相册 ]]
function platform:saveImg2UserAlbum(tb)
	local key = tb.key or nil;
	if not key then return end

	-- 此处默认已检测过相册不存在某图片
	local onSavedCallback = function(bSuc, astId)
		if bSuc then
			GameData.mltSave2AlbumCash = GameData and GameData.mltSave2AlbumCash or {};
			GameData.mltSave2AlbumCash[key] = astId;
			GameState.save(GameData);
		end
		if type(tb.callback) == "function" then
			tb.callback(bSuc, astId);
		end
	end

	local tmpData = {
		img = tb.data.icon,
		listener = onSavedCallback,
	};
	if tmpData.img then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "SaveImageToUserAlbum", tmpData);
	end
end

--[[ 复制文本 ]]
function platform:copylua(text)
	if not text or string.trim(text) == "" then return end

	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "copylua", {text});
	elseif device.platform == "android" then
		luaj.callStaticMethod(self.CLS_NAME_J, "copyText", {tostring(text)}, "(Ljava/lang/String;)V");
	end
	if TipsLayer then
		TipsLayer.show("复制成功");
	end
end

--[[
	获取网络状态
	(4G代表WWAN方式，这里简化网络环境)
	@return “Unkown”, "Nonet", "WiFi", "4G"
]]
function platform:getNetworkWay()
	if device.platform == "ios" then
		local ok, way = self:luaoc_callsmethod(self.CLS_NAME_OC, "getNetworkWay");
		if ok then return way end
	else
		local ok, way = luaj.callStaticMethod(self.CLS_NAME_J, "getNetworkWay", {}, "()Ljava/lang/String;");
		if ok then return way end
	end
end

--[[ 网络是否可用 ]]
function platform:isNetworkAvailable()
	if network.isLocalWiFiAvailable() or network.isInternetConnectionAvailable() then
		return true;
	else
		return false;
	end
	return true;

	-- if device.platform == "ios" then
	-- 	local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "isNetworkAvailableReturnStr");
	-- 	if ok and ret ~= nil and ret == "true" then
	-- 		return true;
	-- 	end
	-- elseif device.platform == "android" then
	-- 	local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "isNetworkAvailable", {} ,"()Z");
	-- 	if ok then return ret end
	-- end

	-- return false;
end

--[[ 获取电量 ]]
function platform:getBatteryLevel()
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "getBatteryLevel");
		if ok then return ret end
	elseif device.platform == "android" then
		local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "getBatteryLevel", {}, "()I");
		if ok then return ret end
	end
	return 100;
end

--[[ TalkData登录 ]]
function platform:tkdataCpaLogin(data)
	if true then return end

	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "TalkingDataAppCpaOnLogin", {tostring(data.userId)});
	elseif device.platform == "android" then
		local args = {data.userId};
		luaj.callStaticMethod(self.CLS_NAME_J, "TalkingDataAppCpaOnLogin", args, "(Ljava/lang/String;)V");
	end
end

--[[ TalkData支付 ]]
function platform:tkDataCpaPay(data)
	if true then return end

	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "TalkingDataAppCpaOnPay", data);
	elseif device.platform == "android" then
		local tStr = "Ljava/lang/String;";
		local args = {data.account, data.payType, data.orderId,
			data.total, data.currencyType, data.category, data.itemId,
			data.name, data.unitPrice, data.amount};
		local sigs = string.format("(%s%s%sI%s%s%s%sII)V", tStr, tStr, tStr, tStr, tStr, tStr, tStr);
		luaj.callStaticMethod(self.CLS_NAME_J, "TalkingDataAppCpaOnPay", args, sigs);
	end		
end

--[[ 通过太极盾获取安全IP ]]
function platform:getSecurityServerIpByGuandu(ops)
	-- if xg.platform:isAbroadApp() then return end

	--[[
		ops = {
			org_host = nil,
			org_port = nil,
		};

		return "ip;port"
	]]
	ops = ops or {};
	if device.platform == "android" then
		local args = {ops.org_host, ops.org_port};
		local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "taiJiSdkContent", args, "(Ljava/lang/String;I)Ljava/lang/String;");
		if ok then return ret end
	elseif device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "getSecurityServerIpByGuandu", ops);
		if ok then return ret end
	end
end

--[[ HttpDns初始化 ]]
function platform:initHttpDns(ops)
	--[[
		ops = {
			acc_id = nil,
			secret_key = nil,
			def_url = nil, -- 多个用;分隔
		};
	]]
	ops = ops or {};
	if device.platform == "android" then
		local args = {tostring(ops.acc_id), tostring(ops.secret_key), ops.def_url};
		local sigs = string.format("(%s%s%s)V", luaj_str, luaj_str, luaj_str);
		local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "initHttpDns", args, sigs);
		if ok then
			print("android call initHttpDns sucess.", ret);
		end
	elseif device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "initHttpDns", ops);
		if ok then
			print("ios call initHttpDns sucess.", ret);
		end
	end
end

--[[ 通过host获取ip列表 ]]
function platform:getIpsByHost(ops)
	--[[
		ops = {
			url = nil,
			callback = nil,
		};
	]]
	ops = ops or {};
	if device.platform == "android" then
		local args = {tostring(ops.url), ops.callback};
		local sigs = string.format("(%s%I)V", luaj_str);
		local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "getIpsByHost", args, sigs);
		if ok then
			print("android call getIpsByHost sucess.", ret);
		end
	elseif device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "getIpsByHost", ops);
		if ok then
			print("ios call getIpsByHost sucess.", ret);
		end
	end
end

--[[ 获取经度纬度 ]]
function platform:getLocationLatAndLng()
	--[[
		jsonData = {
			"latitude"  = 22.546511,	--纬度
			"longitude" = 113.933524,	--经度
		};
	]]
	if false then
		return json.decode(json.encode({}));
	end

	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "getBaiduLocalInfo", {}, "()Ljava/lang/String;");
		if ok then
			return json.decode(ret), ret;
		end
	elseif device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "getBMKLocationInfo");
		if ok then
			return json.decode(ret);
		end
	end
end

--[[ 设置BMKAk并初始化 ]]
function platform:setBMKAk() 
	local tb = {
		bmk_ak = xg.const.BMK_AK,
	};
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "setBMKAk", tb);
	end
end

--[[ 请求定位 ]]
function platform:reqBMKLocationInfo(tb)
	tb = tb or {};
	tb.listener = tb.listener or function(event)
		print_r("reqBMKLocationInfo call empty function.", event);
	end
	if device.platform == "ios" then
		if not self:bolLocationSerEnable() then
			return;
		end
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "reqBMKLocationInfo", tb);
	elseif device.platform == "android" then
		if type(tb.listener) == "function" then
			local _, ret = self:getLocationLatAndLng();
			tb.listener(ret);
		end
	end
end

--[[ 清除请求定位回调 ]]
function platform:releaseLuaHdReqBMKLocCallback()
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "releaseLuaHdReqBMKLocCallback");
	end
end

--[[ 开始定位 ]]
function platform:startBMKLocation()
	if device.platform == "ios" then
		if not self:bolLocationSerEnable() then
			return;
		end

		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "startBMKLocation");
	end
end

--[[ 取消/停止定位 ]]
function platform:stopBMKLocation()
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "stopBMKLocation");
	end
end

--[[ 位置定位是否可用 ]]
function platform:bolLocationSerEnable(bShowTip)
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "bolLocationSerEnable");
		local bEnable = (ret and ret == "true");
		if ok then
			if not bEnable and (bShowTip == nil or (type(bShowTip) == "boolean" and bShowTip)) then
				self:showConfirmAlertView({
					message = string.format(XTEXT.com_gps_tips_1, XConstants.APP_MNAME),
				});
			end
			return bEnable;
		end
	elseif device.platform == "android" then
		return true;
	end
end

--[[ 显示确认框 ]]
function platform:showConfirmAlertView(data)
	if not data or not next(data) then return end

	data.message = data.message or "";
	data.title = data.title or XTEXT.public_dialogTitle;

	if CCMessageBox then
		-- 此处延时弹窗，防止ios弹窗导致cocos控件状态异常
		scheduler.performWithDelayGlobal(function()
			CCMessageBox(data.message, data.title);
		end,0.1)
	end
end

--[[ 获取设备类型 ]]
function platform:getDeviceModel()
	if device.platform == "ios" then
		local bundle = self:getBundleId();
		local version = self:getBundleVersion();
		if (bundle == self.BUNDLE_ID_515_FP and version > "1.2")
		or (bundle == self.BUNDLE_ID_WYW_FP and version > "1.5") then
			local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "getDeviceModel");
			return ret;
		else
			return "iOSDevice";
		end
	elseif device.platform == "android" then
		local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "getDeviceName", {}, "()Ljava/lang/String;");
		if ok then return ret end
	end

	return nil;
end

--[[ 获取设备系统版本 ]]
function platform:getDeviceSystemVersion()
	if device.platform == "ios" then
		local bundle = self:getBundleId();
		local version = self:getBundleVersion();
		if (bundle == self.BUNDLE_ID_515_FP and version > "1.2")
		or (bundle == self.BUNDLE_ID_WYW_FP and version > "1.5") then
			local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "getDeviceSystemVersion");
			return ret;
		end
	elseif device.platform == "android" then
		local ok, ret = luaj.callStaticMethod(self.CLS_NAME_J, "getDeviceSystemVersion", {}, "()Ljava/lang/String;");
		if ok then return ret end
	end
end

--[[ 获取邀请的房间Id ]]
function platform:getInviteRoom()
	if device.platform == "ios" then
		local ok, v = self:luaoc_callsmethod(self.CLS_NAME_OC, "getInviteUrl");
		return v;
	end
	return "0";
end

--[[ 清空邀请房间 ]]
function platform:emptyInviteRoom()
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "emptyInviteUrl");
	end
end

--[[ 注册邀请房间监听 ]]
function platform:registerInviteRoomHandler()
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "registerInviteUrlHandler", {listener = device.inviteRoomHandler});
	end
end

--[[ 是否越狱？ ]]
function platform:isJailBreak()
	if device.platform == "ios" then
		local funcn = "isJailBreakReturnStr";
		local bundle = self:getBundleId();
		local version = self:getBundleVersion();
		if (bundle == self.BUNDLE_ID_WYW_FP and version < "1.2") then
			funcn = "isJailBreak";
		end
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, funcn);
		if ok and ret ~= nil and ret == "true" then
			return true;
		end
	end

	return false;
end

--[[ 下载接口 ]]
function platform:downloadFile(data)
	data = checktable(data);

	local path = device.writablePath .. "download/"; -- 获取本地存储目录
	if not io.exists(path) then
		lfs.mkdir(path); -- 目录不存在，创建此目录
	end

	if device.platform == "android" then
		data.savePath = path .. "poker.apk";
		local args = {data.url, data.label, data.savePath, data.md5, data.size, data.isEnterApk};
		local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;II)V";
		luaj.callStaticMethod(self.CLS_NAME_J, "downloading", args, sigs);
	end
end

--[[ APP消息通知 ]]
function platform:AppNotification(data)
	data = checktable(data);
	if device.platform == "android" then
		local title = data.title or "title";
		local context = data.context or "content";
		local args = {title, context, "ticker"};
		local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
		luaj.callStaticMethod(self.CLS_NAME_J, "appNotification", args, sigs);
	end
end

--[[ 获取appstore广告idfa ]]
function platform:getIDFA()
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC_SVU_UID, "IFA");
		if ok then return ret end
	end
	return nil;
end

--[[ 增加别名 ]]
function platform:AddUMessageAlias(uid)
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "AddUMessageAlias", {tostring(uid)});
	elseif device.platform == "android" then
		luaj.callStaticMethod(self.CLS_NAME_J, "AddUMessageAlias", {tostring(uid)}, "(Ljava/lang/String;)V");
	end
end

--[[ 转为横屏 ]]
function platform:changeRootv2Landscape()
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "changeToRootViewController2");
	elseif device.platform == "android" then
		luaj.callStaticMethod(self.CLS_NAME_J, "Landscape", {}, "()V");
	end
end

--[[ 转为竖屏 ]]
function platform:changeRootv2Portrait()
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "changeToRootViewController");
	elseif device.platform == "android" then
		luaj.callStaticMethod(self.CLS_NAME_J, "Portrait");
	end
end


--[[ 打开斗地主录像 ]]
function platform:openDouDiZhuVideo(url)
	--url大概是如下, 我们要截取video后面的东西
	--//jump?openApp=1&gameName=ddz&video=80b56af970d350add8f2de73a8d7ff8e

	if url and string.find(url,"gameName=ddz") and string.find(url,"video=") then
	   	local str = string.split(url,'?');
	    if str and str[2] then
	        local info = string.split(str[2],"&");
	        dump(info,"toScheme ddz info")
	        if info then
	            local videoInfo = nil;
	            for k , v in ipairs(info) do
	                if v and string.find(v,"video=") then
	                    videoInfo = v;
	                    break;
	                end
	            end
	            if videoInfo then
	                local videoList = string.split(videoInfo,"=");
	                dump(videoList,"videoList")
	                if videoList and videoList[2] then
	                    --videoList[2]就是我们要的录像id
	                    local scene = display.getRunningScene();
						if scene and scene.name and scene.name == "HomeScene" then
				            local ddz = {
				                room_id = 100000,
				                ip = "",
				                port = "",
				                id = "",
				                enter_clubid = 0,
				                sub_mod = 1,
				                room_size = 10,
				                isVideo = true,
				                videoName = videoList[2],
				            }
				           	home2ddzScene(ddz)
				        else
				        	print("10555555555555552")
				        	TipsLayer.show("为了更好体验，请在大厅界面观看回放！");
				        end
	                end
	            end

	        end

    	end
    end
end

--[[ 显隐状态栏 ]]
function platform:setStatusBarShow(flag)
	local sflag = tostring(flag);
	print_r("#####显隐状态栏", flag, sflag);
	if device.platform == "ios" then
		self:luaoc_callsmethod(self.CLS_NAME_OC, "setStatusBarShow", {sflag});
	end
end

--[[ 设置ShareInstall并初始化 ]]
function platform:setShareInstallAk() 
	local tb = {
		ak = xg.const.SHAREINSTALL_AK,
	};
	if device.platform == "ios" then
		local ok, ret = self:luaoc_callsmethod(self.CLS_NAME_OC, "setShareInstallAk", tb);
	end
end

--[[ luaoc再封装，代码混淆用 ]]
function platform:luaoc_callsmethod(clsn, funcn, args)
	local prefix = "";
	local bundleId = self:getBundleId();
	if not self._bIosOldBuildV then
		prefix = self.INTERFACE_PREFIX[bundleId] or "";
	end
	local tagFuncn = string.format("%s%s", prefix, funcn);
	return luaoc.callStaticMethod(clsn, tagFuncn, args);
end

--[[ 获取单例 ]]
function platform:getInstance(...)
	local instance = self.INSTANCE;
	if not instance then
		instance = self:new(...);
		self.INSTANCE = instance;
	end
	return instance;
end

return platform;
