
require("app.base.XgInit");
local MyTestScene = class("MyTestScene", xg.baseScene);

local arrTestCfg = {
    {title = "mask", tag = "mask", color = xg.color.red},
    {title = "label", tag = "label", color = xg.color.green},
    {title = "button", tag = "btn", color = xg.color.gold},
    {title = "tabbar", tag = "tab_bar", color = xg.color.white},
    {title = "listView", tag = "list_view", color = xg.color.black},
    {title = "pageView", tag = "page_view", color = xg.color.red},
    {title = "textInput", tag = "text_input", color = xg.color.green},
    {title = "comFrame", tag = "com_frame", color = xg.color.gold},
    {title = "updext", tag = "upd_ext", color = xg.color.gold},
    {title = "eftdemo", tag = "eft_demo", color = xg.color.gold},
};

function MyTestScene:ctor()
    MyTestScene.super.ctor(self);

    local bg = CCLayerColor:create(xg.color.c3b2C4b(xg.color.green, 200));
    self:addChild(bg);

    local spBg = display.newSprite("ui/home/home_bg.png");
    spBg:align(display.CENTER, display.cx, display.cy);
    spBg:setScaleX(display.width/spBg:getContentSize().width);
    spBg:setScaleY(display.height/spBg:getContentSize().height);
    spBg:addTo(self);

    local barBg = display.newSprite("ui/home/home_bg_jb_nor.png");
    barBg:align(display.CENTER, display.cx, display.height - 52/2 - 10);
    barBg:addTo(self);

    self._arrNodes = {};

    local arrTest = {};
    for k,v in ipairs(arrTestCfg) do
        table.insert(arrTest, {
            text = {text = v.title, color = v.color or xg.color.white}
        });
    end
    local options = {
        text = arrTest,
        btn = {
            images = {
                normal = "texas_icon_sjx_nor.png",
                pressed = "texas_icon_sjx_nor.png",
            },
        },
        btnOffset = cc.p(-10, 0);
        topBg = "descirbe_btn_paixu.png",
        itemBg = "texas_bg_toumingdikuang_2.png",
        size = cc.size(212, 54),
        itemSize = cc.size(212, 40);
        bArrowBtn = true,
        select = 9,
    };
    local drop = xg.ui:newDropDownList(options);
    drop:align(display.CENTER, display.width - 10 - 212/2, display.height - 10 - 54/2);
    drop:addEventListener(drop.ON_SELECT_EVENT, handler(self, self.onDDSelected));
    drop:addTo(self, 10);

    -- local BroadcastView = import("app.BroadcastView");
    -- local view = BroadcastView.new();
    -- view:align(display.CENTER, display.cx, display.height - 62);
    -- view:addTo(self, 100);
    -- self._bdctView = view;

    -- local DebugDot = require("app.view.other.DebugDot");
    -- local view = DebugDot.new();
    -- view:addTo(self, 1000)

    local ServerListView = require("app.view.other.ServerListView");
    local view = ServerListView.new();
    view:addTo(self, 1000);


    -- self:getAndDoUncompressZip("zips/home.zip");


    -- local luazlib = require 'zlib';
    -- dump(luazlib.inflate, "luazlib");
end

function MyTestScene:onDDSelected(event)
    local idx = event.index;
    local cfg = arrTestCfg[idx];
    if not cfg then return end

    local tag = cfg.tag;
    if not tag then return end

    local view = self._arrNodes[tag];
    if not view then
        local func = self["test_" .. tag];
        if func then
            view = func(self);
            if view then
                view:addTo(self);
                self._arrNodes[tag] = view;
            end
        end
    end

    for k,v in pairs(self._arrNodes) do
        v:setVisible(k == tag);
    end
end

function MyTestScene:test_btn()
    local size = cc.size(display.width, display.height);
    local node = display.newNode();
    node:setContentSize(size);

    local btn = xg.ui:newButton({
        images = {
            normal = "texas_btn_xiaotanchuan_nor.png",
            pressed = "texas_btn_xiaotanchuan_sel.png",
        },
        text = {
            text = "Test",
            size = xg.font.size.sml,
            color = xg.color.green,
        },
        zoom = true,
        limitSecond = true,
    });
    btn:onClicked(function()
        self._testOff = not self._testOff;
        btn:setLabel({
            text = "Test  " .. (self._testOff and "off" or "on"),
            color = self._testOff and xg.color.red or xg.color.green,
            size = xg.font.defSize(),
        });
        xg.audio:testPlay();

        self._bdctView:replayLongStandby();

    end);
    btn:align(display.CENTER, size.width/2, size.height/2);
    btn:addTo(node);

    return node;
end

function MyTestScene:test_label()
    local size = cc.size(display.width, display.height);
    local node = display.newNode();
    node:setContentSize(size);

    local label = xg.ui:newLabel({
        text = "Label测试Label测试Label测试",
        font = xg.font.defName(),
        size = xg.font.defSize(),
        color = xg.color.red,
        align = ui.TEXT_VALIGN_CENTER,
        valign = ui.TEXT_VALIGN_TOP,
        dimensions = cc.size(200, 200),
    })
        :align(display.CENTER, size.width/2, size.height/2)
        :addTo(node);

    local lbChange = xg.ui:newLabel({
        text = "change",
        color = xg.color.green,
    })
        :align(display.CENTER, size.width/2, size.height/2 - 100)
        :addTo(node);
    lbChange:swallowTouch(false);
    lbChange:onClicked(function()
        label:setNum(math.random(1, 1000));
    end);

    local label = xg.ui:newAtlasNum({cfgId = 2, max = 9999999});
    label:align(display.CENTER, size.width/2, size.height/2);
    label:addTo(node);

    local ac = cca.repeatForever(cca.seqEx({
        cca.callFunc(function()
           label:setNum(math.random(1, 100000), true);
        end),
        cca.delay(0.5),
    }));
    label:runAction(ac);

    local lb = ui.newTTFLabelWithOutline({
        text = "Hello, World\n您好，世界",
    });
    lb:align(display.CENTER, display.cx, display.cy - 300);
    lb:addTo(node, 1000);

    lb:performWithDelay(function()
        lb:setString("12121");
    end, 5);

    return node;
end

function MyTestScene:test_tab_bar()
    local size = cc.size(display.width, display.height);
    local node = display.newNode();
    node:setContentSize(size);

    -- 默认按钮格式
    local options = {
        data = {"Tab_1", "Tab_2"},
        size = cc.size(360, 50),
    };
    local bar = xg.ui:newTabBar(options);
    bar:addEventListener(bar.EVENT_ON_TAB_CLICKED, function(event)
        print("#####TabBar1 clicked:", event.index);
    end);
    bar:align(display.CENTER, size.width * 0.75, size.height/2);
    bar:addTo(node, 1);


    -- 自定义按钮格式
    local options2 = {
        data = {
            [1] = {
                text = {text = "Tab_1", color = xg.color.green},
                images = {
                    -- normal = "ui/club/club_btn_zcd_nor.png",
                    pressed = "ui/capital_btn_yeqian.png",
                },
            },
            [2] = {
                text = {text = "Tab_2", color = xg.color.red},
                images = {
                    -- normal = "ui/club/club_btn_zcd_nor.png",
                    pressed = "ui/capital_btn_yeqian.png",
                },
                lbImg = {
                    img = "ui/discover/descirbe_icon_addon.png",
                    offset = cc.p(-50, 0),
                },
            },
        },
        index = 2,
        size = cc.size(300, 100),
        itemSize = cc.size(150, 50);
        -- direction = xg.ui.TAB_BAR_DIR.VER,
        showItemBg = false,
        class = "tabBarEx",
    };
    local bar = xg.ui:newTabBar(options2);
    bar:addEventListener(bar.EVENT_ON_TAB_CLICKED, function(event)
        print("#####TabBar2 clicked:", event.index);
    end);
    bar:align(display.CENTER, size.width * 0.25, size.height/2);
    bar:addTo(node, 1);
    -- bar:setSelectIndex(1);

    return node;
end

function MyTestScene:test_list_view()
    local size = cc.size(display.width, display.height);
    local node = display.newNode();
    node:setContentSize(size);

    local bIsAsync = false;
    local nDirection = xg.ui.SCROLL_VIEW_DIR.VER;
    local data1, data2 = {}, {};
    for i = 1, 120 do
        data1[i] = "item" .. i;
    end
    for j = 1, 122 do
        data2[j] = "test" .. j;
    end
    local listSize = cc.size(300, 300);
    local listPos = cc.p(size.width/2 - listSize.width/2, 100);
    local list = xg.ui:newScollView({
        async = bIsAsync,

        viewRect = cc.rect(listPos.x, listPos.y, listSize.width, listSize.height),
        direction = nDirection,
    });
    list:onTouch(function(event)
        if event.name == "clicked" and event.itemPos then
            print("#####list item clicked pos is ", event.itemPos);
        end
        if event.name == list.EVENT_DROP_DOWN then
            print("#####list drop down");
        end
        if event.name == list.EVENT_PULL_UP then
            print("#####list pull up");
        end
    end);
    list:onCreateItem(function(event)
        local item = event.item;
        local node = event.node;
        local data = event.data;

        local itemSize = cc.size(listSize.width, 50);
        item:setItemSize(itemSize.width, itemSize.height)
        node:setContentSize(itemSize);
        node:align(display.CENTER, itemSize.width/2, itemSize.height/2);

        local bgSize = cc.size(itemSize.width, itemSize.height - 5);
        local bg = display.newScale9Sprite("ui/login/login_btn_huiseanniu.png");
        bg:setContentSize(bgSize);
        bg:align(display.CENTER_BOTTOM, itemSize.width/2, 5);
        bg:addTo(node);

        local label = xg.ui:newLabel({
            text = data,
            size = xg.font.size.nor,
            color = xg.color.white,
        });
        label:align(display.LEFT_CENTER, 20, itemSize.height/2);
        label:addTo(node);
    end);
    list:addTo(node);

    list:setDataAndReload(data1, nil, true);
    -- node:performWithDelay(function()
    --     list:setDataAndReload(data2, nil, true);
    -- end, 3);

    return node;
end

function MyTestScene:test_page_view()
    local size = cc.size(display.width, display.height);
    local node = display.newNode();
    node:setContentSize(size);

    local data1, data3 = {}, {};
    for i = 1, 20 do
        data1[i] = "item" .. i;
    end
    for j = 1, 5 do
        data3[j] = "test" .. j;
    end
    local listSize = cc.size(300, 300);
    local listPos = cc.p(size.width/2 - listSize.width/2, size.height/2 - listSize.height/2);
    local page = xg.ui:newScollView({
        bCirc = false,
        type = xg.ui.SCROLL_VIEW_TYPE.PAGE,
        viewRect = cc.rect(listPos.x, listPos.y, listSize.width, listSize.height),
    });
    page:onTouch(function(event)
        dump(event, "#####event");
        if node._pageBar then
            node._pageBar:setCurPage(event.cur_page or 1);
        end
    end);
    page:onCreateItem(function(event)
        local item = event.item;
        local node = event.node;
        local data = event.data;

        local itemSize = cc.size(listSize.width, listSize.height);
        item:setContentSize(itemSize.width, itemSize.height)
        node:setContentSize(itemSize);
        node:align(display.CENTER, itemSize.width/2, itemSize.height/2);

        local bgSize = cc.size(itemSize.width, itemSize.height - 5);
        local bg = display.newScale9Sprite("ui/login/login_btn_huiseanniu.png");
        bg:setContentSize(bgSize);
        bg:align(display.CENTER_BOTTOM, itemSize.width/2, 5);
        bg:addTo(node);

        local label = xg.ui:newLabel({
            text = data,
            size = xg.font.size.nor,
            color = xg.color.white,
        });
        label:align(display.LEFT_CENTER, 20, itemSize.height/2);
        label:addTo(node);
    end);
    page:addTo(node);

    page:setDataAndReload(data1);
    node:performWithDelay(function()
        page:setDataAndReload(data3);
        page:gotoPage(3);
        if node._pageBar then
            node._pageBar:setData({
                cur_page = 3,
                max_page = #data3,   -- 如果max_page与之前的max_page不等，则会重新创建
            });
        end
    end, 5);


    -- 默认按钮样式
    local options = {
        data = {
            cur_page = 1,
            max_page = 3,
        },
    };
    -- 自定义按钮样式
    local options = {
        data = {
            cur_page = 1, 
            max_page = 3,
        },
        btn = {
            images = {
                normal = "ui/texas/texas_ckx_lx_nor.png",
                pressed = "ui/texas/texas_ckx_lx_sld.png",
            },
        },
        interval = 0,
    };
    local bar = xg.ui:newPageBar(options);
    bar:align(display.CENTER, display.cx, listPos.y - 20);
    bar:addTo(node);
    bar:setScale(0.5); -- 设置缩放
    bar:setCurPage(1); -- 设置当前页
    node._pageBar = bar;

    return node;
end

function MyTestScene:test_text_input()
    local size = cc.size(display.width, display.height);
    local node = display.newNode();
    node:setContentSize(size);

    local input = xg.ui:newTextInput({
        text = "Test",                                  -- 文本内容(可选)
        placeHolder = "Enter Place",                    -- 编辑框为空时提示文本(可选)
        fontColor = xg.color.green,                     -- 设置文本颜色 (可选)
        inputType = xg.ui.TEXT_INPUT_TYPE.EDITBOX,      -- 默认是 EditBox  (可选)
        maxLength = 10,                                 -- 编辑的最大数 (可选)
        passwordEnable = true,                          -- 需要显示成密码模式，传该值，反之可为nil (可选)
        size = cc.size(200, 50),                        -- 编辑框大小
        listener = function(event, editbox)             -- 监听方法 (可选)
            dump(event, "#####event");
        end
    });
    input:setReturnType(kKeyboardReturnTypeSend);   --设置键盘中return键显示的字符，此处是send
    input:setPosition(size.width/2, size.height/2);
    input:addTo(node);

    xg.event:addListener("EnterView", function(event)
        if event.view then
            print(event.view.__cname);
        end
    end);

    local view = xg.baseView.new();
    view:addTo(node);

    return node;
end

function MyTestScene:test_mask()
    local size = cc.size(display.width, display.height);
    local node = display.newNode();
    node:setContentSize(size);

    local options = {
        alpha = 100,
        debugTips = "Mask Test",
        clipRect = cc.rect(200, 200, 200, 200),
    };
    local mask = xg.ui:newMask(options);
    mask:addEventListener(mask.EVENT_CLIP_AREA_TOUCH, function(event)
        dump(event, "#####mask clip Area");
    end);
    mask:addTo(node, 900);

    return node;
end

function MyTestScene:test_com_frame()
    local size = cc.size(display.width, display.height);
    local node = display.newNode();
    node:setContentSize(size);

    local arr = xg.ui:getClass("comFrame").FRAME_STYLE;
    local keys = table.keys(arr);
    dump(keys, "#####keys");

    local idx = 0;
    local function openFrame(style)
        local style = style or keys[idx];
        local path = "app.base.ui.XgComFrame";
        local view = self:openView(path, nil, {style = style, title = style, size = cc.size(300, 400)});
        if view then
            view:setLocalZOrder(900);
            view:addEventListener(view.EVENT_ON_CLOSE, function(event)
                dump(event, "#### frame EVENT_ON_CLOSE event");
            end);
        end
    end

    local btn = xg.ui:newButton({
        images = {
            normal = "texas_btn_xiaotanchuan_nor.png",
            pressed = "texas_btn_xiaotanchuan_sel.png",
        },
        text = {
            text = "Open Frame",
            color = xg.color.green,
        },
        zoom = true,
        limitSecond = true,
    });
    btn:onClicked(function()
        if idx >= #keys then
            idx = 0;
        end
        idx = idx + 1;
        openFrame();
    end);
    btn:align(display.CENTER, size.width/2, size.height/2);
    btn:addTo(node);


    -- local fontSize = 20;
    -- local str = "H啊Jimmy: 你好,世界!漢字——_  戰鬥";
    -- local label = xg.ui:newLabel({
    --     text = str,
    --     font = "黑体",
    --     size = fontSize,
    --     color = xg.color.red,
    -- })
    --     :align(display.CENTER, size.width/2, size.height/2 - 100)
    --     :addTo(node);
     
    -- print("总宽度: ", xg.font.getFontWidthEx(str, fontSize), label:getContentSize().width)


    local ary = {
        [1] = "老妈特宠我，记得有一次，我睡了三天三夜，可把老妈急坏了,<br />",
        [2] = "<font size=1 color='xg.color.green'>终于找到钥匙打开了<font size=2 color=3>房门</font>!!!</font>",
        [3] = "没吵没骂...",
    };
    local ary = {
        [1] = "世界上最浪费生命的三件事：<br />",
        [2] = "<font size=1 color='xg.color.green'>一、评论。别人不靠你活着，何况你未必了解他的全部，论人长短不如取人之长补己之短。</font><br />",
        [3] = "<font size=1 color='xg.color.green'>二、责怪。责怪人人都会，</font>",
        [4] = "却无法改变现状。共勉之所以，<u>在于既好过责怪",
        [5] = "提高了自己</u>，也<link>欢喜</link>了大家。",
        [6] = "哈哈<img src=ui/btn_help.png alt=help_icon />",
    };
    local str = table.concat(ary);

    local parsedtable = xg.rtParser.parse(str);
    dump(parsedtable, "parsedtable===");

    local w = 400;
    -- local label = xg.ui:newLabel({
    --     text = str,
    --     font = xg.font.defName(),
    --     size = xg.font.defSize(),
    --     color = xg.color.red,
    --     align = ui.TEXT_VALIGN_CENTER,
    --     valign = ui.TEXT_VALIGN_TOP,
    --     dimensions = cc.size(w, 0),
    -- })
    --     :align(display.CENTER, size.width/2, size.height/2 - 200)
    --     :addTo(node);

    local str1, str2, strw1, strw2 = splitStrByWidth("二、责怪。责怪人人都会，", w);
    dump({
        s1 = str1,
        s2 = str2,
        sw1 = strw1,
        sw2 = strw2,
    });

    local idx = 1;
    local fSize = 26;
    local disa = w;

    local rowIdx = 1;
    local arrRSize = {};
    local curRSz = cc.size(0, 0);
    local arr = clone(parsedtable);
    
    while arr[idx] or idx <= #arr do
        local info = arr[idx];
        if info.tagType == "div" or info.tagType == "font" or info.tagType == "u" or info.tagType == "link" then
            local offW = disa - curRSz.width;
            local s1, s2, sw1, sw2 = splitStrByWidth(info.cont, offW, fSize);
            if s1 then
                if s2 then
                    -- 分裂出来的项，并插入到队列
                    local tmp = clone(arr[idx]);
                    tmp.cont = s2;
                    table.insert(arr, idx + 1, tmp);

                    -- 更新原有项，并标记为段落
                    arr[idx].p = 1;
                    arr[idx].cont = s1;

                    -- 保存当前行宽高
                    curRSz.width = math.max(curRSz.width, disa);
                    curRSz.height = math.max(curRSz.height, fSize);
                    arrRSize[rowIdx] = cc.size(curRSz.width, curRSz.height);

                    -- 重置，行数自增
                    curRSz.width = 0;
                    curRSz.height = 0;
                    rowIdx = rowIdx + 1;
                else
                    -- 当前行
                    curRSz.width = curRSz.width + sw1;
                    curRSz.height = math.max(curRSz.height, fSize);
                end
                idx = idx + 1;
            else
                -- s1为空串情况
                -- 一般为当行所剩宽度不足截取到一个字符
                arr[idx - 1].p = 1; -- 前一项标记为段落

                -- 保存当前行宽高
                arrRSize[rowIdx] = cc.size(curRSz.width, curRSz.height);

                -- 重置，行数自增
                curRSz.width = 0;
                curRSz.height = 0;
                rowIdx = rowIdx + 1;
            end
        elseif info.tagType == "img" then
            local sp = display.newSprite(info.src);
            if sp then
                local w, h, scl = info.width, info.height, 1;
                if (w and not tonumber(w)) or (h and not tonumber(h)) then
                    local sclStr = w or h;
                    local sIdx, eIdx = string.find(sclStr, "[%%]+$");
                    scl = string.sub(sclStr, sIdx, -1);
                    scl = scl/100;
                    w, h = nil, nil;
                end
                if not w or not h then
                    local spSz = display.newSprite(info.src):getContentSize();
                    w, h = spSz.width * scl, spSz.height * scl;
                end
                if curRSz.width + w <= disa then
                    curRSz.width = curRSz.width + w;
                    curRSz.height = math.max(curRSz.height, h);
                    idx = idx + 1;
                else
                    arr[idx].p = 1;

                    -- 保存当前行宽高
                    arrRSize[rowIdx] = cc.size(curRSz.width, curRSz.height);

                    -- 重置，行数自增
                    curRSz.width = 0;
                    curRSz.height = 0;
                    rowIdx = rowIdx + 1;
                end
            end
        elseif info.tagType == "br" then

            -- 保存当前行宽高
            arrRSize[rowIdx] = cc.size(curRSz.width, curRSz.height);

            -- 重置，行数自增
            curRSz.width = 0;
            curRSz.height = 0;
            rowIdx = rowIdx + 1;
            idx = idx + 1;
        else
            idx = idx + 1;
        end
    end
    dump(arr, "#####arr2222");
    
    for k,v in ipairs(arrRSize) do
        print("arrRSize", k, v.width, v.height);
    end


    local rIdx = 1;
    local pos = cc.p(0, size.height - 10);
    local orgPos = cc.p(pos.x, pos.y);
    for k,v in ipairs(arr) do
        local rH = arrRSize[rIdx] and arrRSize[rIdx].height or 0;
        if v.tagType == "div" or v.tagType == "font" or v.tagType == "u" or v.tagType == "link" then
            local label = xg.ui:newLabel({
                text = v.cont,
                font = xg.font.defName(),
                size = xg.font.defSize(),
                color = xg.color.red,
            });
            label:align(display.LEFT_BOTTOM, pos.x, pos.y - rH);
            label:addTo(node);
            if v.tagType == "u" or v.tagType == "link" then
                local spPos = cc.p(0, 0);
                local size = label:getContentSize();
                local shape3 = display.newLine(
                    {{spPos.x, spPos.y}, {spPos.x + size.width, spPos.y}},
                    {borderColor = xg.color.c3b2C4f(xg.color.gold), borderWidth = 1}
                );
                shape3:addTo(label);
            end
            if v.tagType == "link" then
                label:swallowTouch(true);
                label:onClicked(function()
                    dump(v, "点击到");
                end);
            end

            local lbSz = label:getContentSize();
            pos.x = pos.x + lbSz.width;
            if v.p and v.p == 1 then
                rIdx = rIdx + 1;
                pos.x = orgPos.x;
                pos.y = pos.y - rH;
            end
        else
            -- br换行
            rIdx = rIdx + 1;
            pos.x = orgPos.x;
            pos.y = pos.y - fSize;
        end
    end

    CCTextureCache:sharedTextureCache():dumpCachedTextureInfo();

    return node;
end

function MyTestScene:test_upd_ext()
    local size = cc.size(display.width, display.height);
    local node = display.newNode();
    node:setContentSize(size);

    local lbUpdck = xg.ui:newLabel({
        text = "check updex",
        color = xg.color.green,
    });
    lbUpdck:align(display.CENTER, size.width * 0.25, size.height/2);
    lbUpdck:addTo(node);
    lbUpdck:swallowTouch(false);
    lbUpdck:onClicked(function()
        xg.updextHelp:checkUpd();
    end);

    local lbUpdck = xg.ui:newLabel({
        text = "start updex",
        color = xg.color.green,
    });
    lbUpdck:align(display.CENTER, size.width * 0.25, size.height/2 - 100);
    lbUpdck:addTo(node);
    lbUpdck:swallowTouch(false);
    lbUpdck:onClicked(function()
        xg.updextHelp:startUpd();
    end);

    local lbUpdCancel = xg.ui:newLabel({
        text = "cancel updex",
        color = xg.color.green,
    });
    lbUpdCancel:align(display.CENTER, size.width * 0.75, size.height/2);
    lbUpdCancel:addTo(node);
    lbUpdCancel:swallowTouch(false);
    lbUpdCancel:onClicked(function()
        xg.updextHelp:stopUpd();
    end);

    local lbUpdCancel = xg.ui:newLabel({
        text = "play audio",
        color = xg.color.green,
    });
    lbUpdCancel:align(display.CENTER, size.width * 0.75, size.height/2 - 100);
    lbUpdCancel:addTo(node);
    lbUpdCancel:swallowTouch(false);
    lbUpdCancel:onClicked(function()
        audio.stopAllSounds();
        audio.unloadSound("sound/ddz/ddz_bgm.mp3");
        xg.audio:playSound("sound/ddz/ddz_bgm.mp3", true);
    end);

    local lbsetnets = xg.ui:newLabel({
        text = "set network status",
        color = xg.color.green,
    });
    lbsetnets:align(display.CENTER, size.width * 0.25, size.height/2 - 200);
    lbsetnets:addTo(node);
    lbsetnets:swallowTouch(false);
    lbsetnets:onClicked(function()
        local state = xg.network:getNetConnectStatus(math.random(0, 2));
        print("netstatus", state);
    end);

    local lbUpdStatus = xg.ui:newLabel({
        text = "Check update ...",
        color = xg.color.gold,
    });
    lbUpdStatus:align(display.CENTER, size.width * 0.5, size.height/2 + 100);
    lbUpdStatus:addTo(node);

    local lbUpddlreate = xg.ui:newLabel({
        text = "",
        color = xg.color.orange,
    });
    lbUpddlreate:align(display.CENTER, size.width * 0.5, size.height/2 + 60);
    lbUpddlreate:addTo(node);

    xg.event:addListener(xg.updextHelp.EVENT_RET, function(event)
        local strtip = nil;
        local updexenum = xg.updextHelp.RET_TYPE;
        local rettype, info = event.ret_type, event.info;
        if rettype == updexenum.DL_FILE_CHECK_RET then
            strtip = string.format("Need download %s file, total size %s ...", info.dlnum, info.dlsize);
            lbUpddlreate:setString("");
        elseif rettype == updexenum.DL_FILE_INPROGRESS then
            strtip = string.format("%s\n %s ...", info.file, info.status);
        elseif rettype == updexenum.DL_FILE_RATE then
            lbUpddlreate:setString(info.rate);
        elseif rettype == updexenum.DL_UPD_EX_CANCEL then
            xg.updextHelp:checkUpd();
        elseif rettype == updexenum.DL_UPD_EX_COMPLETE then
            -- strtip = "Download complete ...";
            -- lbUpddlreate:setString("");
        elseif rettype == updexenum.DL_NET_STATUS_UPD then
            print("网络状态！！！！", info.status, xg.updextHelp:getDlStatus());

            local dlstatus = xg.updextHelp:getDlStatus();
            if info.status == 0 or info.status == 2 then
                if dlstatus == xg.updextHelp.DL_STATUS.DOWNLOADING then
                    print("处于无网络或者3g4g状态，停止下载！");
                    xg.updextHelp:stopUpd();
                end
            else
                if dlstatus == xg.updextHelp.DL_STATUS.STOP
                or dlstatus == xg.updextHelp.DL_STATUS.CHECK_UPD then
                    print("处于wifi状态，恢复下载！");
                    xg.updextHelp:startUpd();
                end
            end
            print("网络状态 aft！！！！", info.status, xg.updextHelp:getDlStatus());
        end
        lbUpdStatus:setString(strtip);
    end);

    return node;
end

function MyTestScene:test_eft_demo()
    local size = cc.size(display.width, display.height);
    local node = display.newNode();
    node:setContentSize(size);

    local arr = {
        {
            png = "texiao/fangpaopai/fangpaoshandian_majiang0.png",
            plist = "texiao/fangpaopai/fangpaoshandian_majiang0.plist",
            json = "texiao/fangpaopai/fangpaoshandian_majiang.ExportJson",
        },
        {
            png = "texiao/gang/gang_majiang0.png",
            plist = "texiao/gang/gang_majiang0.plist",
            json = "texiao/gang/gang_majiang.ExportJson",
        },
        {
            png = "texiao/gang/gang_majiang1.png",
            plist = "texiao/gang/gang_majiang1.plist",
            json = "texiao/gang/gang_majiang.ExportJson",
        },
        {
            png = "texiao/ganghua/gangshanghua_majiang0.png",
            plist = "texiao/ganghua/gangshanghua_majiang0.plist",
            json = "texiao/ganghua/gangshanghua_majiang.ExportJson",
        },
        {
            png = "texiao/ganghua/gangshanghua_majiang1.png",
            plist = "texiao/ganghua/gangshanghua_majiang1.plist",
            json = "texiao/ganghua/gangshanghua_majiang.ExportJson",
        },
        {
            png = "texiao/ganghua/gangshanghua_majiang2.png",
            plist = "texiao/ganghua/gangshanghua_majiang2.plist",
            json = "texiao/ganghua/gangshanghua_majiang.ExportJson",
        },
        {
            png = "texiao/haidilaoyue/haidilaoyue_majiang0.png",
            plist = "texiao/haidilaoyue/haidilaoyue_majiang0.plist",
            json = "texiao/haidilaoyue/haidilaoyue_majiang.ExportJson",
        },
        {
            png = "texiao/haidilaoyue/haidilaoyue_majiang1.png",
            plist = "texiao/haidilaoyue/haidilaoyue_majiang1.plist",
            json = "texiao/haidilaoyue/haidilaoyue_majiang.ExportJson",
        },
        {
            png = "texiao/haidilaoyue/haidilaoyue_majiang2.png",
            plist = "texiao/haidilaoyue/haidilaoyue_majiang2.plist",
            json = "texiao/haidilaoyue/haidilaoyue_majiang.ExportJson",
        },
        {
            png = "texiao/hu/hu_majiang0.png",
            plist = "texiao/hu/hu_majiang0.plist",
            json = "texiao/hu/hu_majiang.ExportJson",
        },
        {
            png = "texiao/hu/hu_majiang1.png",
            plist = "texiao/hu/hu_majiang1.plist",
            json = "texiao/hu/hu_majiang.ExportJson",
        },
        {
            png = "texiao/hupai/hupaiguangxiao_majiang0.png",
            plist = "texiao/hupai/hupaiguangxiao_majiang0.plist",
            json = "texiao/hupai/hupaiguangxiao_majiang.ExportJson",
        },
        {
            png = "texiao/liuju_majiang/liuju_majiang0.png",
            plist = "texiao/liuju_majiang/liuju_majiang0.plist",
            json = "texiao/liuju_majiang/liuju_majiang.ExportJson",
        },
        -- {
        --     png = "texiao/nishule_majiang/nishule_majiang0.png",
        --     plist = "texiao/nishule_majiang/nishule_majiang0.plist",
        --     json = "texiao/nishule_majiang/nishule_majiang.ExportJson",
        -- },
        {
            png = "texiao/niyingle_majiang/niyingle_majiang0.png",
            plist = "texiao/niyingle_majiang/niyingle_majiang0.plist",
            json = "texiao/niyingle_majiang/niyingle_majiang.ExportJson",
        },
        {
            png = "texiao/paixing_majiang_1/paixing_majiang0.png",
            plist = "texiao/paixing_majiang_1/paixing_majiang0.plist",
            json = "texiao/paixing_majiang_1/paixing_majiang.ExportJson",
        },
        {
            png = "texiao/paixing_majiang_1/paixing_majiang1.png",
            plist = "texiao/paixing_majiang_1/paixing_majiang1.plist",
            json = "texiao/paixing_majiang_1/paixing_majiang.ExportJson",
        },
        {
            png = "texiao/peng/peng_majiang0.png",
            plist = "texiao/peng/peng_majiang0.plist",
            json = "texiao/peng/peng_majiang.ExportJson",
        },
        {
            png = "texiao/peng/peng_majiang1.png",
            plist = "texiao/peng/peng_majiang1.plist",
            json = "texiao/peng/peng_majiang.ExportJson",
        },
        {
            png = "texiao/start/kaiju_majiang0.png",
            plist = "texiao/start/kaiju_majiang0.plist",
            json = "texiao/start/kaiju_majiang.ExportJson",
        },
        {
            png = "texiao/zimo/zimo_majiang0.png",
            plist = "texiao/zimo/zimo_majiang0.plist",
            json = "texiao/zimo/zimo_majiang.ExportJson",
        },
        {
            png = "texiao/zimo/zimo_majiang1.png",
            plist = "texiao/zimo/zimo_majiang1.plist",
            json = "texiao/zimo/zimo_majiang.ExportJson",
        },
        {
            png = "texiao/zimo/zimo_majiang2.png",
            plist = "texiao/zimo/zimo_majiang2.plist",
            json = "texiao/zimo/zimo_majiang.ExportJson",
        },
        {
            png = "texiao/nishule_majiang/nishule_majiang0.png",
            plist = "texiao/nishule_majiang/nishule_majiang0.plist",
            json = "texiao/nishule_majiang/nishule_majiang.ExportJson",
        },
        {
            png = "texiao/majiangtubiao/majiangtubiao0.png",
            plist = "texiao/majiangtubiao/majiangtubiao0.plist",
            json = "texiao/majiangtubiao/majiangtubiao.ExportJson",
        },
    };
    local armaMgr = CCArmatureDataManager:sharedArmatureDataManager();
    for k,v in ipairs(arr) do
        armaMgr:addArmatureFileInfo(v.png, v.plist, v.json);
    end

    local arrani = {
        {name = "fangpaoshandian_majiang", ani = "Animation1"},
        {name = "gang_majiang", ani = "Animation1"},
        {name = "gangshanghua_majiang", ani = "Animation1"},
        {name = "haidilaoyue_majiang", ani = "Animation1"},
        {name = "hu_majiang", ani = "Animation1"},
        {name = "hupaiguangxiao_majiang", ani = "Animation1"},
        {name = "liuju_majiang", ani = "biaoqian_chuxian"},
        {name = "liuju_majiang", ani = "biaoqian_xunhuan"},
        {name = "nishule_majiang", ani = "chuxian"},
        {name = "nishule_majiang", ani = "daiji"},
        {name = "niyingle_majiang", ani = "niyingle"},
        {name = "niyingle_majiang", ani = "niyingle_xunhuan"},
        {name = "paixing_majiang", ani = "koupaizhong"},
        {name = "paixing_majiang", ani = "dingquezhong"},
        {name = "paixing_majiang", ani = "huazhu_kaishi", scl = 1},
        {name = "paixing_majiang", ani = "renshu_kaishi"},
        {name = "paixing_majiang", ani = "tuishui_kaishi"},
        {name = "paixing_majiang", ani = "weitingpai_kaishi"},
        {name = "paixing_majiang", ani = "yipaoduoxiang_kaishi", scl = 1},
        {name = "paixing_majiang", ani = "huazhu_jieshu"},
        {name = "paixing_majiang", ani = "renshu_jieshu"},
        {name = "paixing_majiang", ani = "tuishui_jieshu"},
        {name = "paixing_majiang", ani = "weitingpai_jieshu"},
        {name = "paixing_majiang", ani = "yipaoduoxiang_jieshu"},
        {name = "paixing_majiang", ani = "weitingpai_jieshu"},
        {name = "peng_majiang", ani = "Animation1"},
        {name = "kaiju_majiang", ani = "Animation1"},
        {name = "zimo_majiang", ani = "Animation1"},
        {name = "majiangtubiao", ani = "majiang"},
    };

    local function createArm(idx)
        local arm = node._armani;
        if arm then
            arm:removeSelf();
        end
        local info = arrani[idx];
        arm = xg.ui:newArmature(info);
        arm:align(display.CENTER, display.cx, display.cy + 100);
        arm:addTo(node, 100);
        node._armani = arm;
    end

    local spBg = display.newSprite("majiang_bg_beijing2.png");
    spBg:align(display.CENTER, display.cx, display.cy);
    spBg:setScaleX(display.width/spBg:getContentSize().width);
    spBg:setScaleY(display.height/spBg:getContentSize().height);
    spBg:addTo(node);

    local spdnxb = display.newSprite("dxnb/majiang_dnxb_di1_bg.png");
    spdnxb:setScale(0.57);
    spdnxb:align(display.CENTER, display.cx, display.cy + 70);
    spdnxb:swallowTouch(false);
    spdnxb:onClicked(function()
        self._aniIdx = self._aniIdx or 0;
        if self._aniIdx >= #arrani then
            self._aniIdx = 0;
        end
        self._aniIdx = self._aniIdx + 1;

        createArm(self._aniIdx);
    end);
    spdnxb:addTo(node);

    local MjGameFlow = import("app.view.MjGameFlow");
    local view = MjGameFlow.new();
    view:align(display.CENTER, display.cx, display.cy);
    view:addTo(node);

    return node;
end

function MyTestScene:getAndDoUncompressZip(res_p)
    local fileUtils = CCFileUtils:sharedFileUtils();
    -- local data = fileUtils:getFileData(res_p);
    -- print("getAndDoUncompressZip", res_p, data, type(data));
    -- if data then
    --     self:uncompressZip(data);
    -- end

    print("fopen", type(fopen));
    print("unzGetGlobalInfo", type(unzGetGlobalInfo));

    local fname = "home.zip";
    local url = "http://192.168.200.212/zips/" .. fname;
    xg.network:requestGet(url, function(event)
        local info = event and event.info;
        local request = event and event.request;
        if event.msg == "success" then
            local rpdata = request:getResponseData(); 
            print("下载完成222", rpdata);
            if rpdata then
                local writablePath = fileUtils:getWritablePath();
                local dirpath = ospathconcat(writablePath, "res_ext/zips");
                print("dirpath", dirpath);
                createDirectoryEx(dirpath);

                local fpath = ospathconcat(dirpath, fname);
                
                local tm = 1;
                while (not request:saveResponseData(fpath) and tm <= 30) do
                    tm = tm + 1;
                end
                -- self:uncompressZip(rpdata);

                self:UnzipFile(fpath);
            end
        else
            if event.msg and event.errorCode then
                print("下载失败");
            elseif event.msg == "inprogress" then
                printf("下载中 %s/%s", info.dlnow, info.dltotal);
            end
        end
    end, nil, 60*60);
end

function MyTestScene:uncompressZip(data)

    local ret;
    xpcall(function()
        local zlib = require("zlib");
        local uncompress = zlib.inflate();
        ret = uncompress(data);
    end, function()
        print("uncompress fail.");
    end);

    print("uncompressZip", tostring(ret));

    return ret;
end

return MyTestScene
