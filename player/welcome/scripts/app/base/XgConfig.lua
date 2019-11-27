local config = {};

config.raw = config.raw or {};
setmetatable(config.raw, {
	__index = function(t, k)
		return rawget(t, k) or (
			try{
				function()
					-- 原打算做只读表，发现一级键之外的其他键值修改并不报错，
					-- 所以此处直接clone，避免配置被修改。
					local cfg = require("app.config.raw" .. "." .. k);
					cfg = clone(cfg);
					return cfg;
				end,
				function()
					return rawget(t, k);
				end,
			});
	end
});

setmetatable(config, {
	__index = function(t, k)
		return rawget(t, k) or (
			try{
				function()
					return require("app.config" .. "." .. k);
				end,
				function()
					return rawget(t, k);
				end,
			});
	end
});

return config;
