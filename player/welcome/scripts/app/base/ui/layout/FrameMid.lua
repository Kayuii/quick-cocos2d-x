--[[
	中窗口
	@Author: ccb
	@Date: 2017-11-01
]]
local base = import("app.base.ui.layout.FrameTiny");
local FrameMid = class("FrameMid", base);

-- 默认大小
FrameMid.DEF_SIZE = cc.size(530, 650);
FrameMid.VIEW_TYPE = xg.baseView.MID_VIEW;
FrameMid.BG_SCL9_KEY = "bg_buy_in";

--[[ 关闭按钮 ]]
function FrameMid:addClsBtnIf_()
    FrameMid.super.addClsBtnIf_(self);

    local btnCls = self:findViewByKey("btn_cls");
    if btnCls then
        btnCls:align(display.RIGHT_TOP, self._size.width - 1, self._size.height);
    end
end

return FrameMid;
