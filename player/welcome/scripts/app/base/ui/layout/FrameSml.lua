--[[
	小窗口
	@Author: ccb
	@Date: 2017-11-01
]]
local base = import("app.base.ui.layout.FrameTiny");
local FrameSml = class("FrameSml", base);

-- 默认大小
FrameSml.DEF_SIZE = cc.size(548, 368);
FrameSml.VIEW_TYPE = xg.baseView.SML_VIEW;
FrameSml.BG_SCL9_KEY = "bg_buy_in";

--[[ 关闭按钮 ]]
function FrameSml:addClsBtnIf_()
    FrameSml.super.addClsBtnIf_(self);

    local btnCls = self:findViewByKey("btn_cls");
    if btnCls then
        btnCls:align(display.RIGHT_TOP, self._size.width - 1, self._size.height);
    end
end

return FrameSml;
