
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

local fileUtils = CCFileUtils:sharedFileUtils();
local writablePath = fileUtils:getWritablePath();
fileUtils:addSearchPath(writablePath .. "res_ext/");
fileUtils:addSearchPath(writablePath .. "poker/" .. "res/");
fileUtils:addSearchPath(writablePath .. "poker/" .. "res/ui");
fileUtils:addSearchPath(writablePath .. "poker/" .. "scripts/");
fileUtils:addSearchPath("res/");
fileUtils:addSearchPath("res_ext/");
fileUtils:addSearchPath("res/ui");
fileUtils:addSearchPath("scripts/");

require("app.WelcomeApp").new():run()
