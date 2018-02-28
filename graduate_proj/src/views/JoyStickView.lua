local JoyStickView = class("JoyStickView",function()
    return ccui.Layout:create()
end)

function JoyStickView:ctor(para)
    self.para = para or {}
    self:enableNodeEvents()
    self:initCircle(self.para)

    self:initTouchListener()
end

function JoyStickView:onCleanup()
    self:unregistTouchListener()
end

function JoyStickView:initCircle(para)
    self.outCircle = ccui.ImageView:create("btn_ctrl_box_tcs.png",1)
    self.innerCircle = ccui.ImageView:create("btn_ctrl_ball_tcs.png",1)
    self.speedBtn = ccui.ImageView:create("btn_hit_tcs.png",1)
    self:addChild(self.outCircle)
    self:addChild(self.innerCircle)
    self:addChild(self.speedBtn)

    self.outSize = self.outCircle:getContentSize()
    if para.outScale then
        self.outSize = sMul(self.outSize, para.outScale)
        self.outCircle:setScale(para.outScale)
    end

    self.innerSize = self.innerCircle:getContentSize()
    if para.innerScale then
        self.innerSize = sMul(self.innerSize, para.innerScale)
        self.innerCircle:setScale(para.innerScale)
    end

    self.speedBtn.size = self.speedBtn:getContentSize()

    --根据用户习惯设置 操作位置
    local offset = 100
    if para.userHabit == 2 then
        local pos1 = cc.p(self.speedBtn.size.width * 0.5 + offset, self.speedBtn.size.height * 0.5 + offset)
        local pos2 = cc.p(display.width - self.outSize.width * 0.5 - offset, self.outSize.height * 0.5 + offset)
        self.outCircle:setPosition(pos2)
        self.srcPos = cc.p(self.outCircle:getPosition())
        self.innerCircle:setPosition(self.srcPos)
        self.speedBtn:setPosition(pos1)
        print("设置2")
    else
        local pos1 = cc.p(self.outSize.width * 0.5 + offset, self.outSize.height * 0.5 + offset)
        local pos2 = cc.p(display.width - self.speedBtn.size.width * 0.5 - offset, self.speedBtn.size.height * 0.5 + offset)
        self.outCircle:setPosition(pos1)
        self.srcPos = cc.p(self.outCircle:getPosition())
        self.innerCircle:setPosition(self.srcPos)
        self.speedBtn:setPosition(pos2)
        print("设置1")
    end

    self.speedBtn:setTouchEnabled(true)
    local function onSpeed(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            if self.para.onSpeedBegan then
                self.para.onSpeedBegan()
            end
            sender:setColor(cc.c3b(150, 150, 150))
        elseif eventType == ccui.TouchEventType.ended then
            if self.para.onSpeedEnded then
                self.para.onSpeedEnded()
            end
            sender:setColor(cc.c3b(255, 255, 255))
        elseif eventType == ccui.TouchEventType.canceled then
            if self.para.onSpeedEnded then

                self.para.onSpeedEnded()
            end
            sender:setColor(cc.c3b(255, 255, 255))
        end
    end
    self.speedBtn:addTouchEventListener(onSpeed)
end

function JoyStickView:initTouchListener()
    local touchJoyStickView = false
    local function onTouchBegan( touch, event )
        local point = touch:getLocation()
        if self.para.userHabit == 2 then
            if point.x < display.cx then return false end
        else
            if point.x > display.cx then return false end
        end
        local rect = self.innerCircle:getBoundingBox()
        touchJoyStickView = true
        if not cc.rectContainsPoint(rect,point) then
            self.innerCircle:setPosition(point)
            self.outCircle:setPosition(point)
        end
        return true
    end
    local function onTouchMoved( touch, event )
        if not touchJoyStickView then return end
        local point = touch:getLocation()
        self:onMoved(point)
    end
    local function onTouchEnded( touch, event )
        touchJoyStickView = false
        self:resetPos()
        if self.para.onEnded then self.para.onEnded() end
    end

    self:unregistTouchListener()
    local touchListener = cc.EventListenerTouchOneByOne:create()
    touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    touchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    touchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    touchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener,self)
    self.touchListener = touchListener
end

function JoyStickView:unregistTouchListener()
    if self.touchListener ~= nil then
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:removeEventListener(self.touchListener)
        self.touchListener = nil
    end
end

function JoyStickView:onMoved(pTouch)
    local origin = cc.p(self.outCircle:getPosition())
    local r = self.outSize.width * 0.35
    local pos = pTouch
    local unitVector = cc.pNormalize(cc.pSub(pTouch, origin))
    if cc.pGetDistance(pTouch, origin) > r then
        -- 触摸点在摇杆外时，则摇杆位置等于触摸点相对于原点的单位向量乘以范围半径
        pos = cc.pAdd(origin, cc.pMul(unitVector, r))
    end
    self.innerCircle:setPosition(pos)

    local angle = cc.pGetAngle(cc.p(0,0), cc.pSub(pTouch, origin)) / math.pi * 180
    if angle < 0 then
        angle = 360 + angle
    end

    if self.para.onMoved then self.para.onMoved({vector = unitVector, angle = angle}) end
end

function JoyStickView:resetPos()
    -- RPGPet.shared():setMoveData(nil)
    self.outCircle:setPosition(self.srcPos)
    self.innerCircle:setPosition(self.srcPos)
end

function JoyStickView:setPos(pos)
    self.outCircle:setPosition(pos)
    self.innerCircle:setPosition(pos)
    self.srcPos = pos
end

return JoyStickView