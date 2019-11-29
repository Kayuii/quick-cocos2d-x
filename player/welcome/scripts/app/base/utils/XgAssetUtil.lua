--[[
	资源简单管理
	@Author: ccb
	@Date: 2017-07-10
]]
local TAG = "#####XgAssetUtil";
local print = print_r or print;
local armaMgr = CCArmatureDataManager:sharedArmatureDataManager();
local AssetUtil = {};
AssetUtil.INSTANCE = nil;

--[[ 构造方法 ]]
function AssetUtil:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;

	return o;
end

--[[ 初始化点9图配置 ]]
function AssetUtil:initScl9Cfg_()
	if self._scl9Cfg then return end

	local arr = {
		texas_bg_op = {
			res = "ui/texas/texas_bg_toumingdikuang.png",
			size = cc.size(690, 116),
			rect = cc.rect(5, 5, 680, 106),
		},
		g_bg_xz = {
			res = "ui/game/game_bg_xz.png",
			size = cc.size(110, 30),
			rect = cc.rect(15, 15, 80, 3),
		},
		g_btn_zyjz = {
			res = "ui/game/raise/game_btn_zyjz.png",
			size = cc.size(120, 52),
			rect = cc.rect(25, 25, 70, 2),
		},
		des_bg_op = {
			res = "ui/discover/descirbe_bg_heisezz.png",
			size = cc.size(350, 60),
			rect = cc.rect(10, 10, 330, 40),
		},
		bg_buy_in = {
			res = "ui/douniu/popup/game_bg_mrtc.png",
			size = cc.size(530, 650),
			rect = cc.rect(5, 5, 520, 640),
		},
		frame_sml_1 = {
			res = "ui/common/com_frame_sml_1.png",
			size = cc.size(502, 320),
			rect = cc.rect(10, 80, 482, 240),
		},
		frame_mid_1 = {
			res = "ui/common/com_frame_mid_1.png",
			size = cc.size(652, 600),
			rect = cc.rect(10, 80, 632, 520),
		},
		frame_lg_1 = {
			res = "ui/common/com_frame_lg_1.png",
			size = cc.size(652, 878),
			rect = cc.rect(10, 80, 632, 798),
		},
		tab_bar_bg_1 = {
			res = "ui/common/tab_bar_bg_1.png",
			size = cc.size(264, 56),
			rect = cc.rect(20, 20, 224, 16),
		},
		list_bg_liebiaodi = {
			res = "ui/discover/list_bg_liebiaodi.png",
			size = cc.size(700, 100),
			rect = cc.rect(10, 10, 680, 80),
		},
	};
	self._scl9Cfg = arr;
end

--[[ 初始化骨骼动画配置 ]]
function AssetUtil:initArmaCfg_()
	if self._armaCfg then return end

	self._armaCfg = {};
	self._armaCfg["texas"] = {
		{png = "effect/ef_allin_tietu.png", plist = "effect/ef_allin_tietu.plist", json = "effect/you win.ExportJson"},
		{png = "effect/ef_youwin_tietu.png", plist = "effect/ef_youwin_tietu.plist", json = "effect/you win.ExportJson"},

		-- 互动特效
		{png = "effect/ef_fanqie_xulie.png", plist = "effect/ef_fanqie_xulie.plist", json = "effect/fanqie.ExportJson"},
		{png = "effect/ef_pijiu_xulie.png", plist = "effect/ef_pijiu_xulie.plist", json = "effect/pijiu.ExportJson"},
		{png = "effect/ef_zan_xulie.png", plist = "effect/ef_zan_xulie.plist", json = "effect/zan.ExportJson"},
		{png = "effect/ef_zhadan_xuelie.png", plist = "effect/ef_zhadan_xuelie.plist", json = "effect/zhadan.ExportJson"},
		{png = "effect/ef_shayu_xulie.png", plist = "effect/ef_shayu_xulie.plist", json = "effect/shayu.ExportJson"},
		{png = "effect/ef_zhuaji_xulie.png", plist = "effect/ef_zhuaji_xulie.plist", json = "effect/zhuaji.ExportJson"},
		{png = "effect/ef_wen_xulie.png", plist = "effect/ef_wen_xulie.plist", json = "effect/wen.ExportJson"},

		-- 1杀～5杀
		{png = "effect/1sha/ef_shuangsha_huaheng.png", plist = "effect/1sha/ef_shuangsha_huaheng.plist", json = "effect/1sha/1sha.ExportJson"},
		{png = "effect/1sha/ef_shuangsha_yixue.png", plist = "effect/1sha/ef_shuangsha_yixue.plist", json = "effect/1sha/1sha.ExportJson"},
		{png = "effect/ef_2sha_xulie.png", plist = "effect/ef_2sha_xulie.plist", json = "effect/2sha.ExportJson"},
		{png = "effect/1sha/ef_shuangsha_huaheng.png", plist = "effect/1sha/ef_shuangsha_huaheng.plist", json = "effect/2sha.ExportJson"},
		{png = "effect/ef_3sha_xulie.png", plist = "effect/ef_3sha_xulie.plist", json = "effect/3sha.ExportJson"},
		{png = "effect/1sha/ef_shuangsha_huaheng.png", plist = "effect/1sha/ef_shuangsha_huaheng.plist", json = "effect/3sha.ExportJson"},
		{png = "effect/ef_4sha_xulie.png", plist = "effect/ef_4sha_xulie.plist", json = "effect/4sha.ExportJson"},
		{png = "effect/1sha/ef_shuangsha_huaheng.png", plist = "effect/1sha/ef_shuangsha_huaheng.plist", json = "effect/4sha.ExportJson"},
		{png = "effect/ef_5sha_xulie.png", plist = "effect/ef_5sha_xulie.plist", json = "effect/5sha.ExportJson"},
		{png = "effect/1sha/ef_shuangsha_huaheng.png", plist = "effect/1sha/ef_shuangsha_huaheng.plist", json = "effect/5sha.ExportJson"},

		{png = "effect/stars.png", plist = "effect/ef_jishi_lizi4.plist", json = "effect/NewAnimation.ExportJson"},
		{png = "effect/baopai0010.png", plist = "effect/baopai0010.plist", json = "effect/baopai001.ExportJson"},
		{png = "effect/ef_allin_xulie001.png", plist = "effect/ef_allin_xulie001.plist", json = "effect/baopai001.ExportJson"},
		{png = "effect/ef_baopai_xulieaa.png", plist = "effect/ef_baopai_xulieaa.plist", json = "effect/baopai001.ExportJson"},
		{png = "effect/ef_XGying_xulie.png", plist = "effect/ef_XGying_xulie.plist", json = "effect/XGying.ExportJson"},

		{png = "effect/multi_desk/ef_lanse2_xulie.png", plist = "effect/multi_desk/ef_lanse2_xulie.plist", json = "effect/multi_desk/duopaizhuo.ExportJson"},
		{png = "effect/jackpot/ef_jiangchi_xulie.png", plist = "effect/jackpot/ef_jiangchi_xulie.plist", json = "effect/jackpot/ef_jiangchi.ExportJson"},
	};
	self._armaCfg["home"] = {
		{png = "effect/ef_zhujiem_xulie.png", plist = "effect/ef_zhujiem_xulie.plist", json = "effect/zhujiemian.ExportJson"},
		{png = "effect/ef_bishi_xulie.png", plist = "effect/ef_bishi_xulie.plist", json = "effect/bishi.ExportJson"},
		{png = "effect/ef_guzhuang_xulie.png", plist = "effect/ef_guzhuang_xulie.plist", json = "effect/guzhang.ExportJson"},
		{png = "effect/ef_koubishi_xulie.png", plist = "effect/ef_koubishi_xulie.plist", json = "effect/koubishi.ExportJson"},
		{png = "effect/ef_han_xulie.png", plist = "effect/ef_han_xulie.plist", json = "effect/liuhan.ExportJson"},
		{png = "effect/ef_nu_xulie.png", plist = "effect/ef_nu_xulie.plist", json = "effect/nu.ExportJson"},
		{png = "effect/ef_touxiao_xulie.png", plist = "effect/ef_touxiao_xulie.plist", json = "effect/touxiao.ExportJson"},
		{png = "effect/ef_xiaoxitx_xulie.png", plist = "effect/ef_xiaoxitx_xulie.plist", json = "effect/xiaoxitixing.ExportJson"},
		{png = "effect/ef_zhujiem_xulie2.png", plist = "effect/ef_zhujiem_xulie2.plist", json = "effect/niuniuzhujiemian.ExportJson"},
		{png = "effect/hallUIEft/ef.png", plist = "effect/hallUIEft/ef.plist", json = "effect/hallUIEft/UItubiao.ExportJson"},
		{png = "effect/hallUIEft/UItubiao0.png", plist = "effect/hallUIEft/UItubiao0.plist", json = "effect/hallUIEft/UItubiao.ExportJson"},
		{png = "effect/hallUIEft/UItubiao1.png", plist = "effect/hallUIEft/UItubiao1.plist", json = "effect/hallUIEft/UItubiao.ExportJson"},
		{png = "effect/hallUIEft/UItubiao2.png", plist = "effect/hallUIEft/UItubiao2.plist", json = "effect/hallUIEft/UItubiao.ExportJson"},
		{png = "effect/hallUIEft/UItubiao20.png", plist = "effect/hallUIEft/UItubiao20.plist", json = "effect/hallUIEft/UItubiao2.ExportJson"},
	};
	self._armaCfg["loading"] = {
		png = "effect/ef_XGloding_xulie.png",
		plist = "effect/ef_XGloding_xulie.plist",
		json = "effect/Nnloding.ExportJson",
	};
	self._armaCfg["logo"] = {
		png = "effect/ipoker_logo/ipoker_logo0.png",
		plist = "effect/ipoker_logo/ipoker_logo0.plist",
		json = "effect/ipoker_logo/ipoker_logo.ExportJson",
	};
end

--[[ 同步加载骨骼动画 ]]
function AssetUtil:loadArmaFile(key)
	if not key then return end

	local cfg = self:getArmaCfgByKey(key);
	if not cfg then return end

	local k, vl = next(cfg);
	if type(vl) == "table" then
		if cfg and next(cfg) then
			for k,v in ipairs(cfg) do
				armaMgr:addArmatureFileInfo(v.png, v.plist, v.json);
			end
		end
	elseif k then
		if cfg.png and cfg.plist and cfg.json then
			armaMgr:addArmatureFileInfo(cfg.png, cfg.plist, cfg.json);
		end
	end
end

--[[ 根据KEY获取点9相关配置 ]]
function AssetUtil:getScl9CfgByKey(key)
	if not key then return end

	self:initScl9Cfg_();

	return self._scl9Cfg[key];
end

--[[ 根据KEY获取点9相关配置 ]]
function AssetUtil:getArmaCfgByKey(key)
	if not key then return end

	self:initArmaCfg_();

	return self._armaCfg[key];
end

--[[ 某些资源需要进行转换，例如国内和海外app部分资源不一样 ]]
function AssetUtil:covert2DiffAppByBundleid(path)
	local platformUtil = xg and xg.platform;
	if not platformUtil then
		local XgPlatform = require("app.xgame.base.XgPlatform");
		if XgPlatform then
			platformUtil = XgPlatform:getInstance();
		end
	end
	if not platformUtil then return path end

	local ext = xg and xg.extends;
	if ext == nil then
		ext = require("app.xgame.base.extends.XgExInit");
	end

	local arrCfg = {
		[platformUtil.BUNDLE_ID_ABROAD_FP] = "abroad";
	};

	-------------------------------------------------------
	-- 安卓处理
	local application = CCApplication:sharedApplication();
	local target = application:getTargetPlatform();
	if target == kTargetAndroid then
		-- 如果为海外包
		if g_AndroidGameConfig and g_AndroidGameConfig.isAbroad then
			arrCfg["android"] = "abroad";
		end
	end
	-------------------------------------------------------

	if not ospathsplitex or type(ospathsplitex) ~= "function" then
		require("app.xgame.base.extends.XgIoEx");
	end

	local bid = platformUtil:getBundleId();
	local apdEx = arrCfg[bid];
	if apdEx then
		local fp = ospathsplit(path);
		local fn, fexn = ospathsplitex(path);
		return string.format("%s\/%s_%s.%s", fp, fn, apdEx, fexn);
	else
		return path;
	end
end

--[[ 获取单例 ]]
function AssetUtil:getInstance(...)
	local instance = self.INSTANCE;
	if not instance then
		instance = self:new(...);
		self.INSTANCE = instance;
	end
	return instance;
end

return AssetUtil;
