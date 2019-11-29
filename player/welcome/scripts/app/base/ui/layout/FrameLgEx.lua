--[[
	大窗口
	@Author: ccb
	@Date: 2017-11-01
]]
local base = import("app.base.ui.layout.FrameLg");
local FrameLgEx = class("FrameLgEx", base);

-- 默认大小
FrameLgEx.DEF_SIZE = cc.size(628, 904);
FrameLgEx.VIEW_TYPE = xg.baseView.LG_VIEW;
FrameLgEx.BG_SCL9_KEY = nil;

--[[ 背景 ]]
function FrameLgEx:addBgIf_()
    local bg = display.newSprite("ui/discover/details/details_bg.png");
    bg:align(display.CENTER, self._size.width/2, self._size.height/2);
    bg:addTo(self);
    self._arrView.bg = bg;
end

return FrameLgEx;
