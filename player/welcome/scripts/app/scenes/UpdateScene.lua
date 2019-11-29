require "lfs";
require("app.base.XgInit");

local UpdateScene = class("UpdateScene", function()
    return display.newScene("UpdateScene");
end)

local updVerPhp = "version.php";
local updInfoPhp = "descriptor2.php";
local updServer = "https://mutong.facepoker.cc/update/";
-- local bk_updServer = "192.168.40.1/update/";
local updLocalPath = device.writablePath .. "poker/";

local smlId = 1;
print("#####updLocalPath", updLocalPath);

local function checkDir(path)
    local oldPath = lfs.currentdir();
    if lfs.chdir(path) then
        lfs.chdir(oldPath);
        return true;
    end
    if lfs.mkdir(path) then
        return true;
    end
end

local function createDir(path)
    if not checkDir(path) then
        printf("createDir %s fail.", path);
        return;
    else
        printf("createDir %s dir is exist or create sucess.", path);
    end
end

local function delAllFilesInDir(path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path .. '/' .. file;
            local attr = lfs.attributes(f);
            assert (type(attr) == "table");

            if attr.mode == "directory" then
                delAllFilesInDir(f);
            else
                os.remove(f);
            end
        end
    end
end

local function createUpdDownDir(path)
    createDir(path);
    createDir(path .. "res/");
    createDir(path .. "scripts/");
end

function UpdateScene:ctor()
    local bg = CCLayerColor:create(ccc4(0, 0, 0, 0));
    self:addChild(bg);

    self._curDownIdx = nil; -- 下载索引
    self._needDownVers = nil; -- 从后台获取的热更包列表

    self:getNewVersion();
end

function UpdateScene:getNewVersion()

    function callback(event)
        local request = event.request;
        local eventName = event.name;
        if eventName ~= "completed" then
            if eventName == "failed" or eventName == "cancelled" then
                print("getVersion 请求失败 " .. request:getErrorMessage());
            end
            return;
        end

        local code = request:getResponseStatusCode();
        if code ~= 200 then            
            print("getVersion 请求失败 " .. request:getErrorMessage());
            return;
        end
        
        local response = request:getResponseString();
        local arr = json.decode(response);
        if arr.list and next(arr.list) then
            self._needDownVers = arr.list;
        end

        dump(arr, "#####热更信息");

        self:checkUpdateState();
    end

    local url = self:formatGetUrl(updServer .. updInfoPhp, {
        id = smlId or 0,
        bigversion = "2.1",
        v = os.time(),
    });
    local request = network.createHTTPRequest(callback, url, "GET");
    request:setTimeout(4);
    request:start();
end

function UpdateScene:checkUpdateState()
    local vers = self._needDownVers;
    if vers and next(vers) then
        for i,v in ipairs(vers) do
            if v.needRestart ~= 0 then
                self._needRestart = true;
                break;
            end
        end
        for i,v in ipairs(vers) do
            if v.needDel == 200 then
                self._needDel = true;
                break;
            end
        end
    end

    if vers and next(vers) then
        createUpdDownDir(updLocalPath);
        self:downloadCurVer();
    else
        print("没有版本信息");
        self:gotoMain();
    end 
end

--[[ 根据索引下载版本文件 ]]
function UpdateScene:downloadCurVer()

    if self._needDel then
        delAllFilesInDir(updLocalPath);
        createUpdDownDir(updLocalPath);
    end
    self._needDel = false;

    self._curDownIdx = self._curDownIdx or 1;
    local verInfo = self._needDownVers[self._curDownIdx];
    if not verInfo then return end

    updServer = bk_updServer or updServer;
    local pUrl = self:formatGetUrl(updServer .. verInfo.fileUrl, {v = os.time()});
    local vUrl = self:formatGetUrl(updServer .. updVerPhp, {
        v = os.time(),
        fileVersion = string.format("%s.%s", verInfo.version, verInfo.id),
    });

    local assetsManager = self._assetsManager;
    if not assetsManager then
        assetsManager = AssetsManager:new(pUrl, vUrl, updLocalPath);
        assetsManager:registerScriptHandler(handler(self, self.downloadVerHandle));
        assetsManager:setConnectionTimeout(5);
        assetsManager:deleteVersion();
        self._assetsManager = assetsManager;
    else
        assetsManager:setPackageUrl(pUrl);
        assetsManager:setVersionFileUrl(vUrl);
    end

    self:performWithDelay(function()
        if assetsManager:checkUpdate() then
            assetsManager:update();
        end
    end, 0.2);

    self:performWithDelay(function()
        self:gotoMain();
    end, 0.3);
    
    dump({
        cur_idx = self._curDownIdx,
        p_url = pUrl,
        v_url = vUrl,
    }, "根据索引下载版本文件");
end

--[[ 下载处理 ]]
function UpdateScene:downloadVerHandle(event)
    if event == "success" then -- 下载成功
        local vers = self._needDownVers;
        local verInfo = vers[self._curDownIdx];
        local vId = verInfo and verInfo.id;
        if self._curDownIdx < #vers then
            print("downloadCurVer sucess:", vId);
            self._curDownIdx = self._curDownIdx + 1;
            self:downloadCurVer();
        else
            self:gotoMain();
            print("downloadCurVer sucess and update completed:", vId);
        end
    elseif string.find(event, "error") == 1 then -- 下载出错
        local arr = {
            errorNetwork = "网络错误",
            errorUncompress = "解压出错",
            errorCreateFile = "文件下载失败",
            errorNoNewVersion = "已是最新版本",
            errorUnknown = "未知错误",
        };
        local tip = arr[event];
        print("downloadCurVer error:", event, tip);
        self:gotoMain();
    else -- 下载中
        -- print("downloadCurVer ing...", event);
    end
end

function UpdateScene:formatGetUrl(url, keys)
    if keys and next(keys) then
        local idx = 0;
        for k,v in pairs(keys) do
            idx = idx + 1;
            url = string.format("%s%s%s=%s", url, (idx == 1 and "?" or "&"), k, v);
        end
    end
    print("formatGetUrl = ", url);
    return url;
end

function UpdateScene:gotoMain()
    if self._assetsManager then
        self._assetsManager:unregisterScriptHandler();
    end


    print("#####gotoMain");
    display.replaceScene(require("app.scenes.MyTestScene").new());
end

return UpdateScene;
