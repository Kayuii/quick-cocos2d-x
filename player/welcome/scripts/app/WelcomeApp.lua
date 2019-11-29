
require("config")
require("framework.init")

local WelcomeApp = class("WelcomeApp", cc.mvc.AppBase)

function WelcomeApp:run()
    CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(nil, function() self:enterSampleScene() end, "WELCOME_LIST_SAMPLES")
    CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(nil, function() self:enterMainFrame() end, "WELCOME_APP")

    g_DEBUG = false;
    local BOL_MY_TEST = true;
	if BOL_MY_TEST then
		local XgFitPolicy = require("app.base.utils.XgFitPolicy"); 
		-- XgFitPolicy:displaySetting();
		self:enterScene("MyTestScene");
	else
		CCFileUtils:sharedFileUtils():addSearchPath("res/");
		self:enterScene("WelcomeScene");
	end
end

function WelcomeApp:enterMainFrame()
    self:enterScene("WelcomeScene", nil, "slideInL", 0.3, display.COLOR_WHITE)
end

function WelcomeApp:enterSampleScene()
    self:enterScene("SampleScene", nil, "pageTurn", 0.5, false)
end

function WelcomeApp:backToMainScene()
    self:enterScene("WelcomeScene", nil, "pageTurn", 0.5, true)
end

return WelcomeApp
