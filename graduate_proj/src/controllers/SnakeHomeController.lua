local SnakeHomeController = class("SnakeHomeController",require("views.SnakeHomeView"))

function SnakeHomeController:ctor()
    self:enableNodeEvents()
end

function SnakeHomeController:onEnter()
    -- 初始化UserDefault
    self:initUserDefault()
    -- 初始化主界面
    self:initHomeView()
    -- 初始化监听
    self:touchCall()
end

-- 初始化监听
function SnakeHomeController:touchCall()
    local function touch(sender,eventType)
        if(eventType == ccui.TouchEventType.ended) then
            if(sender == self.btn_rule) then
                -- 切换场景
                local scene = cc.TransitionFade:create(0.5,require("views.SnakeRuleScene").new())
                cc.Director:getInstance():replaceScene(scene)                
            elseif(sender == self.btn_back) then
                -- 退出应用
                cc.Director:getInstance():endToLua()
            elseif(sender == self.btn_game_type_1) then    -- 无尽模式
                self:selectMode(0)
            elseif(sender == self.btn_game_type_2) then    -- 限时模式
                self:selectMode(1)
            elseif(sender == self.btn_set) then
                -- 切换场景
                local scene = cc.TransitionFade:create(0.5,require("views.SnakeSetScene").new())
                cc.Director:getInstance():replaceScene(scene) 
            elseif(sender == self.btn_skin) then
                -- 切换场景
                local scene = cc.TransitionFade:create(0.5,require("views.SnakeSkinScene").new())
                cc.Director:getInstance():replaceScene(scene)                 
            end
        end
    end

    for i,v in pairs(self.btns) do
        v:addTouchEventListener(touch)
    end
end

-- 选择模式 0:无尽模式 1:限时模式
function SnakeHomeController:selectMode(mode)
    if(mode == 0) then
        print("选择了无尽模式")
        -- 切换场景
        local scene = cc.TransitionFade:create(0.5,require("views.SnakeGameScene").new(mode))
        cc.Director:getInstance():replaceScene(scene)
    elseif(mode == 1) then
        print("选择了限时模式")
        -- 切换场景
        local scene = cc.TransitionFade:create(0.5,require("views.SnakeGameScene").new(mode))
        cc.Director:getInstance():replaceScene(scene)
    end
end

-- 设置控件是否触发事件
function SnakeHomeController:setTouch(canTouch)
    if canTouch then
        for i,v in pairs(self.btns) do
            v:setTouchEnabled(true)
        end    
    else
        for i,v in pairs(self.btns) do
            v:setTouchEnabled(false)
        end  
    end
end

return SnakeHomeController