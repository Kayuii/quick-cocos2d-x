--[[
	小窗口
	@Author: ccb
	@Date: 2017-11-01
]]
local FrameTiny = class("FrameTiny", function()
	return display.newNode();
end);

-- 默认大小
FrameTiny.DEF_SIZE = cc.size(594, 245);
FrameTiny.VIEW_TYPE = xg.baseView.TINY_VIEW;
FrameTiny.BG_SCL9_KEY = "bg_join_game";

--[[ 构造 ]]
function FrameTiny:ctor(ops)
	self._ops = ops or {};
	self._size = self._ops.size or self.DEF_SIZE;
    self._bgScl9Key = self._ops.bgScl9Key or self.BG_SCL9_KEY;
    self._arrView = {};

	self:setContentSize(self._size);

	self:addBgIf_();
	self:addTitleIf_();
	self:addClsBtnIf_();
end

--[[ 背景 ]]
function FrameTiny:addBgIf_()
    local cfg = xg.assetUtil:getScl9CfgByKey(self._bgScl9Key);
    local bg = display.newScale9Sprite(cfg.res, nil, nil, nil, cfg.rect);
    bg:setContentSize(self._size);
    bg:align(display.CENTER, self._size.width/2, self._size.height/2);
    bg:addTo(self);
    self._arrView.bg = bg;
end

--[[ 标题 ]]
function FrameTiny:addTitleIf_()
	local lbTitle = xg.ui:newLabel({
        text = "Title",
        color = xg.color.white,
        size = xg.font.size.ntitle,
    })
    lbTitle:align(display.CENTER, self._size.width/2, self._size.height - 30);
    lbTitle:addTo(self, 1);
    self._arrView.lb_title = lbTitle;
end

--[[ 关闭按钮 ]]
function FrameTiny:addClsBtnIf_()
	local btn = xg.ui:newButton({
        images = {
            normal = "ui/douniu/popup/game_btn_x.png",
            pressed = "ui/douniu/popup/game_btn_x.png",
        },
        limitSecond = true,
    });
    btn:align(display.RIGHT_TOP, self._size.width - 2, self._size.height - 2);
    btn:addTo(self, 1);
    self._arrView.btn_cls = btn;
end

--[[ 获取控件 ]]
function FrameTiny:findViewByKey(key)
    if not key then return end

    return self._arrView[key];
end

return FrameTiny;
