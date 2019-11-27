--[[
	xg初始化
	@Author: ccb
	@Date: 2017-06-06
]]
local CURRENT_MODULE_NAME = ...;

xg = xg or {};
if xg.__inited then return end

xg.__inited = true;
xg.PACKAGE_NAME = string.sub(CURRENT_MODULE_NAME, 1, -8);

local tbRef = {
	font 		= "ui.XgFont",
	color 		= "ui.XgColor",
	entry 		= "XgEntry",
	baseMgr 	= "XgBaseMgr",
	baseView	= "XgBaseView",
	baseScene 	= "XgBaseScene",
	date 		= "utils.XgDate",
	stack 		= "utils.XgStack",
	bindTable 	= "utils.XgBindTb",
	fitPolicy	= "utils.XgFitPolicy",
	httpDnsHelp = "utils.XgHttpDnsApiHelp",
	protocolHelp = "utils.XgProtocolHelper",
	rtParser	= "utils.XgRichTextParser",
};
setmetatable(xg, {
	__index = function(t, k)
		local ref = tbRef[k];
		return rawget(t, k) or (ref and import(t.PACKAGE_NAME .. "." .. ref)) or rawget(t, k);
	end
});

xg.config = import(".XgConfig");
xg.extends = import(".extends.XgExInit");
xg.ui = import(".ui.XgUi"):getInstance();
xg.user = import(".XgUser"):getInstance();
xg.event = import(".utils.XgEvent"):getInstance();
xg.audio = import(".utils.XgAudio"):getInstance();
xg.network = import(".XgNetwork"):getInstance();
xg.platform = import(".XgPlatform"):getInstance();
xg.assetUtil = import(".utils.XgAssetUtil"):getInstance();
xg.localData = import(".utils.XgLocalData"):getInstance();
xg.altPackHelp = import(".utils.XgAltPackHelp"):getInstance();
xg.mainEntryHelp = import(".utils.XgMainEntryHelp"):getInstance();
xg.updextHelp = import(".utils.XgUpdExt"):getInstance();
