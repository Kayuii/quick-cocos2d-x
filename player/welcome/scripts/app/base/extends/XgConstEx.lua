--[[
    Constant Extension
    @Author: ccb
    @Date: 2017-06-10 
]]
xg = xg or {};
xg.const = xg.const or {};
local const = xg.const;

-- 使用quick3.3final
const.XG_USE_QUICK_3_3_F = false;

-- switch case 默认项key
const.SWITCH_DEF = "default";

-- 脚本根目录
const.SRC_ROOT = const.XG_USE_QUICK_3_3_F and "src" or "scripts";

-- 热更路径
const.UPDATE_STORAGE_PATH = UPDATE_STORAGE_PATH or device.writablePath .. "poker/";

-- 输入文本框默认背景图
const.DEF_TEXT_INPUT_IMAGE = "ui/home/home_bg_srfjh_nor.png";

-- ShareInstall的appkey
const.SHAREINSTALL_AK = "AFBKK2BEKRHAEK";

-- 百度sdk的appkey
const.BMK_AK = "5wG5GErBcBWZ3FNItUd4M522LUuGTN24";

-- 商城列表项索引
const.STORE_IDX = {
	DIAMOND = 1,
	VIP_CARD = 2,
};

-- 俱乐部商城列表项索引
const.CLUB_STORE_IDX = {
	DIAMOND = 1,
	CLUB_STAR = 2,
};

-- 红点风格
const.RD_STYLE = {
	NOR = 1,
	NUM = 2,
};

-- 红点id
const.RD_ID = {
	DISCOVER_ROOM = "rd_discover_room", -- 发现列表房间
	DISCOVER_AUTH = "rd_discover_auth", -- 发现列表审批
	C_CREDIT_NTF = "rd_club_credit", 	-- 俱乐部信用
	L_CREDIT_NTF = "rd_league_credit", 	-- 联盟信用
	C_VERIFY_NTF = "rd_club_verify", 	-- 俱乐部审批
	L_VERIFY_NTF = "rd_league_verify", 	-- 联盟审批
	C_NOT_ET_ROOM = "rd_club_no_enter_room", 	-- 俱乐部未进入房间
	L_NOT_ET_ROOM = "rd_league_no_enter_room",	-- 联盟未进入房间
};

-- 视图id
const.VIEW_ID = {
	
};

-- 游戏类型
const.GAME_TYPE = {
	ALL = 0,			-- 所有
	TEXAS = 1,			-- 德扑
	MATADOR = 2, 		-- 斗牛
	GOLD_FLOWER = 3,	-- 金花
	SANG_GONG = 4,		-- 三公
	ZHONG_FA_B = 5,		-- 中发白
	BACCARAT = 6, 		-- 百家乐
};
