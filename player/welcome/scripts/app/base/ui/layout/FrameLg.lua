--[[
	大窗口
	@Author: ccb
	@Date: 2017-11-01
]]
local base = import("app.base.ui.layout.FrameTiny");
local FrameLg = class("FrameLg", base);

-- 默认大小
FrameLg.DEF_SIZE = cc.size(628, 904);
FrameLg.VIEW_TYPE = xg.baseView.LG_VIEW;
FrameLg.BG_SCL9_KEY = nil;

--[[ 背景 ]]
function FrameLg:addBgIf_()
    local bg = display.newSprite("ui/share/share_bg_dikuang.png");
    bg:align(display.CENTER, self._size.width/2, self._size.height/2);
    bg:addTo(self);
    self._arrView.bg = bg;
end

--[[ 标题 ]]
function FrameLg:addTitleIf_()
	FrameLg.super.addTitleIf_(self);

	local lbTitle = self:findViewByKey("lb_title");
    if lbTitle then
        lbTitle:align(display.CENTER, self._size.width/2, self._size.height - 50);
    end
end

--[[ 关闭按钮 ]]
function FrameLg:addClsBtnIf_()
    FrameLg.super.addClsBtnIf_(self);

    local btnCls = self:findViewByKey("btn_cls");
    if btnCls then
        btnCls:align(display.RIGHT_TOP, self._size.width + 1, self._size.height);
    end
end

return FrameLg;
