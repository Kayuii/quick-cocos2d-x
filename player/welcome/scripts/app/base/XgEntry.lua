--[[
	入口/跳转管理
	@Author: ccb
	@Date: 2017-06-06
]]
local XgEntry = {};

local tbEntry = {
	register = { -- 注册
		func = "view_register",
		path = "app.hall.login.views.RegLayer",
	},
	retrieve_pwd = { -- 找回密码
		func = "view_retrieve_pwd",
		path = "app.hall.login.views.RetrievePwdView",
	},
	smscode_login = { -- 验证码登录
		func = "view_smscode_login",
		path = "app.hall.login.views.SmsCodeLoginView",
	},
	set_new_pwd = { -- 设置新密码
		func = "view_set_new_pwd",
		path = "app.hall.login.views.SetNewPwdView",
	},
	confirm_pwd = { -- 确认密码
		func = "view_confirm_pwd",
		path = "app.hall.login.views.ConfirmPwdView",
	},
	bind_phone = { -- 绑定手机号
		func = "view_bind_phone",
		path = "app.hall.login.views.BindPhoneView",
	};
	improve_user_info = { -- 完善用户信息
		func = "view_improve_user_info",
		path = "app.hall.login.views.ImproveUserInfoView",
	};
	user_edit = { -- 用户编辑
		func = "view_user_edit",
		path = "app.hall.user.EditMyInfo"
	},
	customer_care = { -- 用户客服
		func = "view_customer_care",
		path = "app.hall.user.CustomServiceLayer",
	},
	user_setting = { -- 用户设置
	 	func = "view_user_setting",
	 	path = "app.hall.user.SettingLayer",
	},
	store_shop = { -- 商城
		func = "view_store_shop",
		path = "app.hall.store.layer.StoreLayer",
	},
	club_store = { -- 俱乐部商城
		func = "view_club_store_shop",
		path = "app.hall.store.layer.ClubStoreLayer",
	},
	create_room = { -- 创建房间
		func = "view_create_room",
		path = "app.hall.home.view.CreateRoomMainView",
	},
	create_texas_room = { -- 创建房间
		func = "view_create_texas_room",
		path = "app.hall.home.view.TexasCreateRoomMainView",
	},
	photo_menu = { -- 图册菜单
		func = "view_photo_menu",
		path = "app.hall.user.PhotoMenu",
	},
	about = { -- 用户关于
		func = "view_about",
		path = "app.hall.user.AboutLayer",
	},
	extensionAgent = { -- 推广员
		func = "view_extension",
		path = "app.hall.promote.AgentMainView",
	},
	discover_filter = { -- 发现列表筛选
		func = "view_discover_filter",
		path = "app.hall.discover.view.DiscoverFilterView",
	},
	discover_room = { -- 游戏内发现列表
		func = "view_discover_room",
		path = "app.hall.discover.view.DiscoverListFpIGView",
	},
	discover_hall_room_fp = { -- 德扑大厅发现列表
		func = "view_discover_hall_room_fp",
		path = "app.hall.discover.view.DiscoverListFpView",
	};
	discover_hall_room_md = { -- 斗牛大厅发现列表
		func = "view_discover_hall_room_md",
		path = "app.hall.discover.view.DiscoverListMdView",
	};
	discover_hall_room_gf = { -- 金花大厅发现列表
		func = "view_discover_hall_room_gf",
		path = "app.hall.discover.view.DiscoverListGfView",
	};
	discover_hall_room_mj = { -- 麻将大厅发现列表
		func = "view_discover_hall_room_mj",
		path = "app.hall.discover.view.DiscoverListMjView",
	};

	discover_hall_room_lb = {	--拉霸大厅
		func = "view_discover_hall_room_lb",
		path = "app.hall.discover.view.DiscoverListLbView",
	};

	jp_detail = { -- jackpot详情
		func = "view_jp_detail",
		path = "app.hall.jackpot.JpDetailView",
	},
	jp_league_main = { -- 联盟jackpot主界面
		func = "view_jp_league_main",
		path = "app.hall.jackpot.JpAllianceJackpotLayer",
	},
	jp_league_set = { -- 联盟jackpot设置
		func = "view_jp_league_set",
		path = "app.hall.jackpot.JpAllianceSetLayer",
	},
	jp_set = { -- jackpot额度设置
		func = "view_jp_set",
		path = "app.hall.jackpot.JpSetView",
	},
	home_pagev = { -- 大厅分栏
		func = "view_home_pagev",
		path = "app.hall.home.scenes.HomePageView",
	},
	capital_main = { -- 资金主入口
		func = "view_capital_main",
		path = "app.hall.home.view.capital.CapitalMainView",
	},
	capital_recharge = { -- 资金充值
		func = "view_capital_recharge",
		path = "app.hall.home.view.capital.CapitalRechargeView",
	},
	capital_cash = { -- 资金提现
		func = "view_capital_cash",
		path = "app.hall.home.view.capital.CapitalCashView",
	},
	capital_recharge_4_rem = { -- 资金给玩家充值
		func = "view_capital_recharge_4_rem",
		path = "app.hall.home.view.capital.CapitalRecharge4RemView",
	},
	capital_payway_list = { -- 支付方式列表
		func = "view_capital_payway_list",
		path = "app.hall.home.view.capital.CapitalPaywayListView",
	},
	capital_payway_bind = { -- 支付方式绑定
		func = "view_capital_payway_bind",
		path = "app.hall.home.view.capital.CapitalPaywayBindView",
	},
	capital_cash_deal = { -- 提现处理
		func = "view_capital_cash_deal",
		path = "app.hall.home.view.capital.CapitalCashDealView",
	},
	social_main = { -- 社交主入口
		func = "view_social_main",
		path = "app.hall.home.view.social.SocialMainView",
	},
	social_club_create = { -- 创建俱乐部
		func = "view_social_club_create",
		path = "app.hall.home.view.social.SocialClubCreate",
	},
	social_club_join = { -- 加入俱乐部
		func = "view_social_club_join",
		path = "app.hall.home.view.social.SocialClubJoin",
	},
	social_club_setting = { -- 俱乐部设置
		func = "view_social_club_setting",
		path = "app.hall.home.view.social.SocialClubSetting",
	},
	social_club_member = { -- 俱乐部成员
		func = "view_social_club_member",
		path = "app.hall.home.view.social.SocialClubMemList",
	},
	social_club_mem_mgr_tip = { -- 俱乐部成员管理tip
		func = "view_social_club_mem_mgr_tip",
		path = "app.hall.home.view.social.SocialClubMemMgrTip",
	},
	social_club_upgrade = { -- 俱乐部升级
		func = "view_social_club_upgrade",
		path = "app.hall.home.view.social.SocialClubUpgrade",
	},
	social_league_create = { -- 创建联盟
		func = "view_social_league_create",
		path = "app.hall.home.view.social.SocialLeagueCreate",
	},
	social_league_join = { -- 加入联盟
		func = "view_social_league_join",
		path = "app.hall.home.view.social.SocialLeagueJoin",
	},
	social_league_setting = { -- 联盟设置
		func = "view_social_league_setting",
		path = "app.hall.home.view.social.SocialLeagueSetting",
	},
	social_league_member = { -- 联盟成员
		func = "view_social_league_member",
		path = "app.hall.home.view.social.SocialLeagueMemList",
	},
	social_league_mem_mgr_tip = { -- 联盟成员管理tip
		func = "view_social_league_mem_mgr_tip",
		path = "app.hall.home.view.social.SocialLeagueMemMgrTip",
	},
	social_verify_query = { -- 俱乐部/联盟审批询问框
		func = "view_social_verify_query",
		path = "app.hall.home.view.social.SocialVerifyQuery",
	},
	social_extagent_setting = { -- 推广员设置比例
		func = "view_social_extagent_setting",
		path = "app.hall.home.view.social.SocialExtAgentSetting",
	},
	military_list = { -- 战绩列表
		func = "view_military_list",
		path = "app.hall.view.military.MilitaryListView",
	},
	military_detail = { -- 战绩详情
		func = "view_military_detail",
		path = "app.hall.view.military.MilitaryDetailView",
	},
	sng_room_detail = { -- sng房间详情
		func = "view_sng_room_detail",
		path = "app.game.texas.view.SNGRoomDetail",
	},
	create_room_entry = { -- 创建房间入口
		func = "view_create_room_entry",
		path = "app.hall.home.view.CreateRoomEntryView",
	},
};

--[[
	前往
	@params tag[string] 键值
			options[table(缺省)] 参数列表
]]
function XgEntry.goTo(tag, options)
	if not tag then return end

	local self = XgEntry;
	local fucKey = tbEntry[tag] and tbEntry[tag].func or tag;
	fucKey = string.format("__%s", tostring(fucKey));
	local func = self[fucKey];
	if func then
		self._tag = tag;
		return func(self, options);
	else -- 如果未找到成员方法，则尝试获取视图
		local vpath = self:__getViewPath(tag);
		local viewClass = vpath and require(vpath);
		if viewClass then

			dump_r(options, "#####前往 options:" .. tostring(tag));

			local scene = self:__getScene();
			local view = scene:openView(vpath, nil, options);
			if scene and view then
				local tmpZorder = options and options.zorder;
				tmpZorder = tmpZorder and tonumber(tmpZorder);
				if tmpZorder then
					view:setLocalZOrder(tmpZorder);
				end
			end
			return view;
		end
	end
end

--[[ 获取视图 ]]
function XgEntry.getView(tag)
	local self = XgEntry;
	local path = self:__getViewPath(tag) or tag;
	if not path then return end

	local scene = self:__getScene();
	if not scene then return end

	if type(scene.getView) ~= "function" then
		print_r("#####XgEntry getView error: cur scene is not extend from baseScene.");
		return;
	end

	return scene:getView(path);
end

--[[ 关闭视图 ]]
function XgEntry.closeView(tag)
	if not tag then return end

	local self = XgEntry;
	local scene = self:__getScene();
	if not scene then return end
	
	if type(tag) == "string" then
		local path = self:__getViewPath(tag) or tag;
		if type(scene.closeViewByViewPath) ~= "function" then
			print_r("#####XgEntry closeViewByViewPath error: cur scene is not extend from baseScene.");
			return;
		end
		scene:closeViewByViewPath(path);
	else
		if type(scene.closeView) ~= "function" then
			print_r("#####XgEntry closeView error: cur scene is not extend from baseScene.");
			return;
		end
		scene:closeView(tag);
	end
end

--[[ 推广员 ]]
function XgEntry:__view_extension(params)
	-- local path = self:__getViewPath();
	-- return self:__getScene():addChild(import(path).new());

	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(10);
	return view;
end

--[[ 商城 ]]
function XgEntry:__view_store_shop(params)
	params = checktable(params)
	if params and type(params) ~= "table" then
		params = {toType = params};
	end

	local toType = params and params.toType;
	local conData  = game.g_hallCommonDatas or {};
	local exgProList = conData.exchangeProductList;
	if exgProList and next(exgProList) then
		local shopGiftList = conData.shopGiftList;
		local storeProList = conData.storeProductList;
		local scene = self:__getScene();
		local path = self:__getViewPath();

		-- if scene.openView then
		-- 	print("__view_store_shop  scene:openView")
		-- 	return scene:openView(path, nil, storeProList, exgProList, shopGiftList, toType);
		-- else
			local view = require(path);
			local node = view.new(storeProList, exgProList, shopGiftList, toType);
			if params.parent then
				params.parent:addChild(node,params.zorder)
			else
				scene:addChild(node, params and params.zorder or 0)
			end
			return node;
		-- end
	else
		xg.user:getMgr("homeMgr"):reqShopList(toType);
	end
end

--[[ 俱乐部商城 ]]
function XgEntry:__view_club_store_shop(params)
	if params and type(params) ~= "table" then
		params = {toType = params};
	end
	local club = params and params.club;
	local toType = params and params.toType;
	local conData  = game.g_hallCommonDatas or {};
	local protList = conData.clubExchangeProductList;
	if protList and next(protList) then
		local scene = self:__getScene();
		local path = self:__getViewPath();
		local clubstore = scene:openView(path,nil, protList, toType, club);
		clubstore:setPosition(cc.p(0,0))
		return clubstore
	else
		xg.user:getMgr("homeMgr"):reqClubShopList(club, toType);
	end
end

--[[ 相册菜单 ]]
function XgEntry:__view_photo_menu(params)
	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(99);
	return view;
end

--[[ 联盟信用 ]]
function XgEntry:__view_league_credit(params)
	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(10);
	return view;
end

--[[ 联盟信用设置 ]]
function XgEntry:__view_league_credit_set(params)
	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(10);
	return view;
end

--[[ 联盟信用详情 ]]
function XgEntry:__view_league_credit_detail(params)
	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(10);
	return view;
end

--[[ 联盟信用结算提示 ]]
function XgEntry:__view_league_credit_settle_tip(params)
	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(10);
	return view;
end

--[[ 游戏内发现列表 ]]
function XgEntry:__view_discover_room(params)
	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(3);
	return view;
end

--[[ 提前结算历史界面 ]]
function XgEntry:__view_discover_earlySettle_history(params)
	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(100);
	return view;
end

--[[ 发现列表筛选 ]]
function XgEntry:__view_discover_filter(params)
	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(100);
	return view;
end

--[[ jackpot详情 ]]
function XgEntry:__view_jp_detail(params)
	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(100);
	return view;
end

--[[ jackpot联盟 ]]
function XgEntry:__view_jp_league_main(params)
	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(10);
	return view;
end

--[[ jackpot设置 ]]
function XgEntry:__view_jp_league_set(params)
	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(10);
	return view;
end

--[[ jackpot设置 ]]
function XgEntry:__view_jp_set(params)
	local scene = self:__getScene();
	local path = self:__getViewPath();
	local view = scene:openView(path, nil, params);
	view:setLocalZOrder(10);
	return view;
end

--[[ 获取视图路径 ]]
function XgEntry:__getViewPath(tag)
	tag = tag or self._tag;
	if not tag then return end

	return tbEntry[tag] and tbEntry[tag].path;
end

--[[ 获取当前场景 ]]
function XgEntry:__getScene()
	return display.getRunningScene();
end

return {
	goto = XgEntry.goTo,
	getview = XgEntry.getView,
	closeview = XgEntry.closeView,
};
