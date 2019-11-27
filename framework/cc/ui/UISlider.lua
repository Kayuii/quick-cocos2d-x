
local UISliderTexas = class("UISliderTexas", function()
    return display.newNode()
end)

UISliderTexas.BAR             = "bar"
UISliderTexas.BUTTON          = "button"
UISliderTexas.BAR_PRESSED     = "bar_pressed"
UISliderTexas.BUTTON_PRESSED  = "button_pressed"
UISliderTexas.BAR_DISABLED    = "bar_disabled"
UISliderTexas.BUTTON_DISABLED = "button_disabled"
UISliderTexas.PROSESS         = "prosess"

UISliderTexas.PRESSED_EVENT = "PRESSED_EVENT"
UISliderTexas.RELEASE_EVENT = "RELEASE_EVENT"
UISliderTexas.STATE_CHANGED_EVENT = "STATE_CHANGED_EVENT"
UISliderTexas.VALUE_CHANGED_EVENT = "VALUE_CHANGED_EVENT"

UISliderTexas.BAR_ZORDER = 0
UISliderTexas.PROSESS_ZORDER = 1
UISliderTexas.MID_ZORDER=2
UISliderTexas.BUTTON_ZORDER = 10
UISliderTexas.LABEL_ZORDER = 11

function UISliderTexas:ctor(direction, images, options)
    self.fsm_ = {}
    cc(self.fsm_)
        :addComponent("components.behavior.StateMachine")
        :exportMethods()
    self.fsm_:setupState({
        initial = {state = "normal", event = "startup", defer = false},
        events = {
            {name = "disable", from = {"normal", "pressed"}, to = "disabled"},
            {name = "enable",  from = {"disabled"}, to = "normal"},
            {name = "press",   from = "normal",  to = "pressed"},
            {name = "release", from = "pressed", to = "normal"},
        },
        callbacks = {
            onchangestate = handler(self, self.onChangeState_),
        }
    })

    makeUIControl_(self)
    self:setLayoutSizePolicy(display.FIXED_SIZE, display.FIXED_SIZE)

    options = checktable(options)
    self.direction_ = direction
    self.isHorizontal_ = direction == display.LEFT_TO_RIGHT or direction == display.RIGHT_TO_LEFT
    self.images_ = clone(images)
    self.scale9_ = options.scale9
    self.scale9Size_ = nil
    --phase={{start=0,end=minRaise,steps=1},{start=minRaise,end=max,steps=99}}
    self.phases=options.phases
    self.stepOffset=0
    if self.phases and #self.phases>=1 then
        self.min_=self.phases[1].start_
        self.max_=self.phases[1].end_
        self.value_=self.min_
    else
    self.min_ = checknumber(options.min or 0)
    self.max_ = checknumber(options.max or 100)
    self.value_ = self.min_
    end
    self.buttonPositionRange_ = {min = 0, max = 0}
    self.buttonPositionOffset_ = {x = 0, y = 0}
    self.touchInButtonOnly_ = true
    if type(options.touchInButton) == "boolean" then
        self.touchInButtonOnly_ = options.touchInButton
    end
    self.show = options.show or false
    self.showSize = options.showSize or 24
 
    self.buttonRotation_ = 0
    self.barSprite_ = nil
    self.buttonSprite_ = nil
    self.prosessSprite_ = nil
    self.currentBarImage_ = nil
    self.currentButtonImage_ = nil
    self.showLabel=nil
    self.currentShowLabel=nil 

    self.buttonText = nil

    self:updateImage_()
    self:updateButtonPosition_()

    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch_(event.name, event.x, event.y)
    end)
end

function UISliderTexas:setSliderSize(width, height)
    assert(self.scale9_, "UISliderTexas:setSliderSize() - can't change size for non-scale9 slider")
    self.scale9Size_ = {width, height}
    if self.barSprite_ then
        self.barSprite_:setContentSize(CCSize(self.scale9Size_[1], self.scale9Size_[2]))
    end
    return self
end

function UISliderTexas:setSliderEnabled(enabled)
    self:setTouchEnabled(enabled)
    if enabled and self.fsm_:canDoEvent("enable") then
        self.fsm_:doEventForce("enable")
        self:dispatchEvent({name = UISliderTexas.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
    elseif not enabled and self.fsm_:canDoEvent("disable") then
        self.fsm_:doEventForce("disable")
        self:dispatchEvent({name = UISliderTexas.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
    end
    return self
end

function UISliderTexas:align(align, x, y)
    display.align(self, align, x, y)
    self:updateImage_()
    return self
end

function UISliderTexas:setTouchInButtonOnly(flag)
    self.touchInButtonOnly_=flag
end

function UISliderTexas:isButtonEnabled()
    return self.fsm_:canDoEvent("disable")
end

function UISliderTexas:getSliderValue()
    return self.value_
end

function UISliderTexas:setSliderValue(value,isEvent)
    --assert(value >= self.min_ and value <= self.max_, "UISliderTexas:setSliderValue() - invalid value")
    if self.value_ ~= value then
        self.value_ = value
        self:updateButtonPosition_()
        if isEvent then
            self:dispatchEvent({name = UISliderTexas.VALUE_CHANGED_EVENT, value = self.value_})
        end
    end
    return self
end

function UISliderTexas:setSliderButtonRotation(rotation)
    self.buttonRotation_ = rotation
    self:updateImage_()
    return self
end

function UISliderTexas:addSliderValueChangedEventListener(callback)
    return self:addEventListener(UISliderTexas.VALUE_CHANGED_EVENT, callback)
end

function UISliderTexas:onSliderValueChanged(callback)
    self:addSliderValueChangedEventListener(callback)
    return self
end

function UISliderTexas:addSliderPressedEventListener(callback)
    return self:addEventListener(UISliderTexas.PRESSED_EVENT, callback)
end

function UISliderTexas:onSliderPressed(callback)
    self:addSliderPressedEventListener(callback)
    return self
end

function UISliderTexas:addSliderReleaseEventListener(callback)
    return self:addEventListener(UISliderTexas.RELEASE_EVENT, callback)
end

function UISliderTexas:onSliderRelease(callback)
    self:addSliderReleaseEventListener(callback)
    return self
end

function UISliderTexas:addSliderStateChangedEventListener(callback)
    return self:addEventListener(UISliderTexas.STATE_CHANGED_EVENT, callback)
end

function UISliderTexas:onSliderStateChanged(callback)
    self:addSliderStateChangedEventListener(callback)
    return self
end

function UISliderTexas:getStepOffset()
    return self.stepOffset
end

function UISliderTexas:onBindTouch_(event,x,y)
    if event=="began" then
        local buttonPosition = self:convertToWorldSpace(self.buttonSprite_:getPositionInCCPoint())
        self.buttonPositionOffset_.x = buttonPosition.x - x
        self.buttonPositionOffset_.y = buttonPosition.y - y
        self.fsm_:doEvent("press")
        self.oldValue=0
        self.clickX = x --add by shi  log the x for click
        self:dispatchEvent({name = UISliderTexas.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
        return true
    end
    self:onTouch_(event,x,y)
end

function UISliderTexas:onTouch_(event, x, y)
    if event == "began" then
        if not self:checkTouchInButton_(x, y) then return false end
        local buttonPosition = self:convertToWorldSpace(self.buttonSprite_:getPositionInCCPoint())
        self.buttonPositionOffset_.x = buttonPosition.x - x
        self.buttonPositionOffset_.y = buttonPosition.y - y
        self.fsm_:doEvent("press")
        self.oldValue=0
        self.clickX = x --add by shi  log the x for click
        self:dispatchEvent({name = UISliderTexas.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
        print("UISliderTexas:onTouch_")
        return true
    end
    local nowClickX =  x
    local touchInTarget = self:checkTouchInButton_(x, y)
    x = x + self.buttonPositionOffset_.x
    y = y + self.buttonPositionOffset_.y
    local buttonPosition = self:convertToNodeSpace(CCPoint(x, y))
    x = buttonPosition.x
    y = buttonPosition.y
    local offset = 0


    if self.isHorizontal_ then
        if x < self.buttonPositionRange_.min then
            x = self.buttonPositionRange_.min
        elseif x > self.buttonPositionRange_.max then
            x = self.buttonPositionRange_.max
        end
        if self.direction_ == display.LEFT_TO_RIGHT then
            offset = (x - self.buttonPositionRange_.min) / self.buttonPositionRange_.length
        else
            offset = (self.buttonPositionRange_.max - x) / self.buttonPositionRange_.length
        end
    else
        if y < self.buttonPositionRange_.min then
            y = self.buttonPositionRange_.min
        elseif y > self.buttonPositionRange_.max then
            y = self.buttonPositionRange_.max
        end
        if self.direction_ == display.TOP_TO_BOTTOM then
            offset = (self.buttonPositionRange_.max - y) / self.buttonPositionRange_.length
        else
            offset = (y - self.buttonPositionRange_.min) / self.buttonPositionRange_.length
        end
    end

    if self.stepOffset==0 then
        self.stepOffset=offset 
    end
    print("UISliderTexas:onTouch_ 2222",self.oldValue)
    local tempV = offset * (self.max_ - self.min_) + self.min_
    print(tempV,"offset")
    if tempV > self.oldValue then
        if tempV-self.oldValue>5 then
            self.oldValue = tempV
            --audio.playSound(zz.TEXASRES .. "/ui/sound/gear.mp3")
        end
    else
        if self.oldValue-tempV>5 then
            self.oldValue = tempV
            --audio.playSound(zz.TEXASRES .. "/ui/sound/gear.mp3")
        end
    end
    --add by shi  don't send event if just click
    if not (nowClickX == self.clickX and event == "ended") then
    if self.phases then
            if self.phases[2].end_<self.phases[2].start_ then
                if offset>=self.stepOffset then
                    self.value=self.phases[2].start_
                    self:setSliderValue(self.phases[2].start_,true)
                else
                    self.value=self.phases[1].start_
                    self:setSliderValue(self.phases[1].start_,true)
                end
            else
                if offset>self.stepOffset*self.phases[1].steps then
                    self.min_=self.phases[2].start_
                    self.max_=self.phases[2].end_
                    local value=offset * (self.max_ - self.min_) + self.min_
                    print("value",value)
                    self:setSliderValue(value, true)
                elseif offset==self.stepOffset*self.phases[1].steps then
                    self.min_=self.phases[2].start_
                    self.max_=self.phases[2].end_
                    self:setSliderValue(self.phases[1].end_, true)
                else
                    self.min_=self.phases[1].start_
                    self.max_=self.phases[1].end_
                    self:setSliderValue(offset*(self.max_ - self.min_) + self.min_, true)
                end
            end
    else
        self:setSliderValue(offset*(self.max_ - self.min_) + self.min_, true)
    end
    
    else 
        self.isClick = true
        print( "click=" ,self.clickX)    
    end

    if event ~= "moved" and self.fsm_:canDoEvent("release") then
        self.fsm_:doEvent("release")    
        self:dispatchEvent({name = UISliderTexas.RELEASE_EVENT, x = x, y = y, touchInTarget = touchInTarget
        ,isClick = nowClickX == self.clickX, clickX = self.clickX})
    end
end

function UISliderTexas:checkTouchInButton_(x, y)
    if not self.buttonSprite_ then return false end
    if self.touchInButtonOnly_ then
        return self.buttonSprite_:getCascadeBoundingBox():containsPoint(CCPoint(x, y))
    else
        return self:getCascadeBoundingBox():containsPoint(CCPoint(x, y))
    end
end

function UISliderTexas:updateButtonPosition_()
    if not self.barSprite_ or not self.buttonSprite_ then return end

    local x, y = 0, 0
    local barSize = self.barSprite_:getContentSize()
    local buttonSize = self.buttonSprite_:getContentSize()
    local offset = (self.value_ - self.min_) / (self.max_ - self.min_)
    local ap = self:getAnchorPoint()

    if self.isHorizontal_ then
        x = x - barSize.width * ap.x
        y = y + barSize.height * (0.5 - ap.y)
        self.buttonPositionRange_.length = barSize.width 
        self.buttonPositionRange_.min = x 
        self.buttonPositionRange_.max = self.buttonPositionRange_.min + self.buttonPositionRange_.length
        if self.direction_ == display.LEFT_TO_RIGHT then
            x = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length
        else
            x = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
        end
    else
        x = x - barSize.width * (0.5 - ap.x)
        y = y - barSize.height * ap.y
        self.buttonPositionRange_.length = barSize.height - buttonSize.height
        self.buttonPositionRange_.min = y + buttonSize.height /2
        self.buttonPositionRange_.max = self.buttonPositionRange_.min + self.buttonPositionRange_.length
        if self.direction_ == display.TOP_TO_BOTTOM then
            y = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
        else
            y = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length
        end
    end



    self.buttonSprite_:setPosition(x, y)
    if self.showLabel then
        self.showLabel:setPosition(x,y)
        self.showLabel:setString(tostring(math.floor(self.value_)))
    end
    if self.prosessSprite_ then
        if not self.scale9Size_ then
            local size = self.barSprite_:getContentSize()
            self.scale9Size_ = {size.width, size.height}
        end

        local points = {{0,0},{x,0},{x,self.scale9Size_[2]},{0,self.scale9Size_[2]},}
        if self.isHorizontal_ then
            points = {{0,0},{x,0},{x,self.scale9Size_[2]},{0,self.scale9Size_[2]},}
        else
            points = {{0,0},{self.scale9Size_[1],0},{self.scale9Size_[1],y},{0,y},}
        end
        self.prosessSprite_:clear()
        self.prosessSprite_:drawPolygon(points)
    end
    
end

function UISliderTexas:getButtonImagePos()
    if self.buttonSprite_ then
        return self.buttonSprite_:getPositionX(),self.buttonSprite_:getPositionY()
    else
        return 0,0
    end
end

function UISliderTexas:updateImage_()
    local state = self.fsm_:getState()

    local barImageName = "bar"
    local buttonImageName = "button"
    local prosessImageName = "prosess"
    local barImage = self.images_[barImageName]
    local buttonImage = self.images_[buttonImageName]
    local prosessImage = self.images_[prosessImageName]
    local isShowNum=self.show
    if state ~= "normal" then
        barImageName = barImageName .. "_" .. state
        buttonImageName = buttonImageName .. "_" .. state
    end

    if self.images_[barImageName] then
        barImage = self.images_[barImageName]
    end
    if self.images_[buttonImageName] then
        buttonImage = self.images_[buttonImageName]
    end

    if barImage then
        if self.currentBarImage_ ~= barImage then
            if self.barSprite_ then
                self.barSprite_:removeFromParentAndCleanup(true)
                self.barSprite_ = nil
            end

            if self.scale9_ then
                self.barSprite_ = display.newScale9Sprite(barImage)
                if not self.scale9Size_ then
                    local size = self.barSprite_:getContentSize()
                    self.scale9Size_ = {size.width, size.height}
                else
                    self.barSprite_:setContentSize(CCSize(self.scale9Size_[1], self.scale9Size_[2]))
                end
            else
                self.barSprite_ = display.newSprite(barImage)
            end
            self:addChild(self.barSprite_, UISliderTexas.BAR_ZORDER)
        end

        self.barSprite_:setAnchorPoint(self:getAnchorPoint())
        self.barSprite_:setPosition(0, 0)
    else
        printError("UISliderTexas:updateImage_() - not set bar image for state %s", state)
    end

    if prosessImage then
        if self:getChildByTag(999) == nil then
            if self.prosessSprite_ then
                self.prosessSprite_:removeFromParentAndCleanup(true)
                self.prosessSprite_ = nil
            end
            if self:getChildByTag(999) then
                self:getChildByTag(999):removeFromParentAndCleanup(true)
            end



            if not self.scale9Size_ then
                local size = self.barSprite_:getContentSize()
                self.scale9Size_ = {size.width, size.height}
            end
            

           
            local _holesStencil = display.newNode()
            _holesStencil:setContentSize(CCSize(self.scale9Size_[1], self.scale9Size_[2]))
            _holesStencil:setAnchorPoint(ccp(0, 0))
            _holesStencil:setPosition(0,0)
            _holesStencil:setTag(998)
            local _clipper = cc.ClippingNode:create(_holesStencil)
            _clipper:setTag(999)
            _clipper:setContentSize(CCSize(self.scale9Size_[1], self.scale9Size_[2]))
            _clipper:setAnchorPoint(ccp(0, 0))
            _clipper:setPosition(0,0)
            self:addChild(_clipper,UISliderTexas.PROSESS_ZORDER)
           
            
            local content = display.newSprite(prosessImage)
            local posY=(self.barSprite_:getContentSize().height-content:getContentSize().height)/2
            content:setTag(10000)
            content:setAnchorPoint(cc.p(0,0))
            content:setPosition(0,posY)
            _clipper:addChild(content)
            
            

            self.prosessSprite_ = display.newDrawNode()
            self.prosessSprite_:setAnchorPoint(cc.p(0,0))
            self.prosessSprite_:setPosition(0, 0)
            _holesStencil:addChild(self.prosessSprite_)
            local points = {{0,0},{self.scale9Size_[1],0},{self.scale9Size_[1],self.scale9Size_[2]},{0,self.scale9Size_[2]},}
            self.prosessSprite_:clear()
            self.prosessSprite_:drawPolygon(points)
        end
    end


    if isShowNum then
        if self.showLabel then
            self.showLabel:removeFromParentAndCleanup(true)
            self.showLabel=nil
        end
        self.showLabel=CCLabelTTF:create(tostring(self.min_),tostring(self.min_),self.showSize)
        self:addChild(self.showLabel,UISliderTexas.LABEL_ZORDER)
        self.showLabel:setPosition(0,0)
    end

    if buttonImage then
        if self.currentButtonImage_ ~= buttonImage then
            if self.buttonSprite_ then
                self.buttonSprite_:removeFromParentAndCleanup(true)
                self.buttonSprite_ = nil
            end
            self.buttonSprite_ = display.newSprite(buttonImage)
            self:addChild(self.buttonSprite_, UISliderTexas.BUTTON_ZORDER)
        end



        self.buttonSprite_:setPosition(0, 0)
        self.buttonSprite_:setRotation(self.buttonRotation_)
        self:updateButtonPosition_()
    else
        printError("UISliderTexas:updateImage_() - not set button image for state %s", state)
    end

    
end

function UISliderTexas:onBtnBack(value)
    if value<self.min_ then return false end
    if value>self.max_ then return false end
    self.value_=value
    if not self.isClick then
    self:updateButtonPosition_()
else
    self:moveButton()
    self.isClick = false
end
    return true
end

function UISliderTexas:onChangeState_(event)
    if self:isRunning() then
        self:updateImage_()
    end
end
function UISliderTexas:moveButton()
    if not self.barSprite_ or not self.buttonSprite_ then return end
    local x, y = 0, 0
    local barSize = self.barSprite_:getContentSize()
    local buttonSize = self.buttonSprite_:getContentSize()
    local offset = (self.value_ - self.min_) / (self.max_ - self.min_)
    local ap = self:getAnchorPoint()

    if self.isHorizontal_ then
        x = x - barSize.width * ap.x
        y = y + barSize.height * (0.5 - ap.y)
        self.buttonPositionRange_.length = barSize.width 
        self.buttonPositionRange_.min = x 
        self.buttonPositionRange_.max = self.buttonPositionRange_.min + self.buttonPositionRange_.length
        if self.direction_ == display.LEFT_TO_RIGHT then
            x = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length
        else
            x = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
        end
    else
        x = x - barSize.width * (0.5 - ap.x)
        y = y - barSize.height * ap.y
        self.buttonPositionRange_.length = barSize.height - buttonSize.height
        self.buttonPositionRange_.min = y + buttonSize.height /2
        self.buttonPositionRange_.max = self.buttonPositionRange_.min + self.buttonPositionRange_.length
        if self.direction_ == display.TOP_TO_BOTTOM then
            y = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
        else
            y = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length
        end
    end
        
    --self.buttonSprite_:setPosition(x, y)
    if self.prosessSprite_ then
        if not self.scale9Size_ then
            local size = self.barSprite_:getContentSize()
            self.scale9Size_ = {size.width, size.height}
        end

        local points = {{0,0},{x,0},{x,self.scale9Size_[2]},{0,self.scale9Size_[2]},}
        if self.isHorizontal_ then
            points = {{0,0},{x,0},{x,self.scale9Size_[2]},{0,self.scale9Size_[2]},}
        else
            points = {{0,0},{self.scale9Size_[1],0},{self.scale9Size_[1],y},{0,y},}
        end
        self.prosessSprite_:clear()
        self.prosessSprite_:drawPolygon(points)
    end
    transition.moveTo(self.buttonSprite_,{x = x
        , y=self.buttonSprite_:getPositionY(),time = 0.23})

end
return UISliderTexas
