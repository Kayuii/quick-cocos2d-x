--[[
	图片集文本，带数字滚动效果
	@Author: ccb
	@Date: 2018-03-17
]]
local ATLAS_CFG = {};
ATLAS_CFG[1] = {
	file = "fonts/0123456789-export.png",
	width = 68,
	height = 64,
	start = string.byte('0, 9'),
};
ATLAS_CFG[2] = {
	file = "fonts/0123456789-xiao.png",
	width = 28,
	height = 44,
	start = string.byte('0, 9'),
};

ATLAS_CFG[3] = {
	file = "fonts/num1.png",
	width = 26,
	height = 63,
	start = string.byte('0, :'),
};

ATLAS_CFG[4] = {
	file = "fonts/num2.png",
	width = 26,
	height = 63,
	start = string.byte('0, :'),
};

ATLAS_CFG[5] = {
	file = "fonts/num3.png",
	width = 26,
	height = 63,
	start = string.byte('0, :'),
};


local ALTLAS_NUM_AC_TAG_NUM_EFT = 0x0000001;

local AtlasNum = class("AtlasNum", function(ops)
	ops = checktable(ops);
	ops.cfgId = ops.cfgId or 1;
	ops.num = tostring(ops.num);

	local cfg = ops.cfg or ATLAS_CFG[ops.cfgId];
	assert(cfg, "AtlasNum cfg is nil.");

	local label;
	if "function" == type(cc.LabelAtlas._create) then
		label = cc.LabelAtlas:_create(ops.num, cfg.file, cfg.width, cfg.height, cfg.start);
	else
		label = cc.LabelAtlas:create(ops.num, cfg.file, cfg.width, cfg.height, cfg.start);
	end
	label._ops = ops;

	return label;
end);

--[[ 初始化绑定表 ]]
function AtlasNum:_initBindData()
	self._bindData = newBindTable({
		cur = -1,
		old = -1,
	});

	local function setStringEx(num)
		local v = checkint(num);
		local maxv = self._ops.max;
		v = math.max(0, v);
		if maxv then
			v = math.min(v, maxv);
			local subLen = string.len(maxv) - string.len(v);
			if subLen > 0 then
				v = string.rep("0", subLen) .. v;
			end
		end
		self:setString(v);
	end
	
	self:bind(self._bindData, "cur", function(node, value)
		if value and self._bindData.old ~= value then
			setStringEx(self._bindData.old);
			node:stopActionByTag(ALTLAS_NUM_AC_TAG_NUM_EFT);
			
			if "function" == type(node.updateAtlasValues) then
				node:updateAtlasValues();
			end
			node._cur = clone(self._bindData.old);

			local sub = value - node._cur;
			local ct = self._effect and 10 or 1;
			local change_rate = node._ops.rate or 0.06;
			local totalTk = change_rate * ct;
			local bLtSub = math.abs(sub) < ct;
			totalTk = (bLtSub and 1.25 or 1) * totalTk;
			ct = bLtSub and math.max(math.abs(sub), 1) or ct;
			local interval = sub/ct;
			change_rate = totalTk/ct;

			local acDly = cca.delay(change_rate);
			local acFuc = cca.callFunc(function()
				node._cur = node._cur + interval;
				setStringEx(node._cur);
			end);
			local acRep = cca.rep(cca.seqEx({acFuc, acDly}), ct);
			acRep:setTag(ALTLAS_NUM_AC_TAG_NUM_EFT);
			node:runAction(acRep);
			self._bindData.old = value;
		end
	end);
end

--[[
	设置数值
	@params num 数值
			effect 显示滚动特效标志, 值为true，显示特效; 值为false，不显示特效; 
]]
function AtlasNum:setNum(num, effect)
	if self._bindData == nil then
		self:_initBindData();
	end
	self._effect = checkbool(effect);
	self._bindData.cur = num;
	if self._effect == false then
		self:setString(self._bindData.cur);
	end
end

--[[ 获取数值 ]]
function AtlasNum:getNum()
	local num = 0;
	if self._bindData then
		num = self._bindData.cur;
	end
	return num;
end

return AtlasNum;
