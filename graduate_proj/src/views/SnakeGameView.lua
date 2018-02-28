local SnakeGameView = class("SnakeGameView",function()
		return cc.Layer:create()
	end)

function SnakeGameView:initGameView()
	-- 游戏场景csb
	local para = {}
	para.csb = "game/gameScene.csb"
	para.setSize = true
	self.gameView = ViewBase.new(para)
	self:addChild(self.gameView)

    -- 排行榜csb
	local para = {}
	para.csb = "game/GameRank.csb"
	para.setSize = true
	self.rankView = ViewBase.new(para)
	self:addChild(self.rankView,10)	

    self.ranks = {}
    for i = 1,10 do
        local str = string.format("currentRank%d",i)
        local tmp = self.rankView:getChildByName("panel"):getChildByName("Panel_rank"):getChildByName(str)
        print(tmp)
        table.insert(self.ranks,tmp)
    end

	-- 左上角分数和击杀数
	self.scoreTip = cc.Label:createWithTTF("得分:"..self.mSnake.score, "font/YOUYUAN.TTF", 25)
	self.killTip  = cc.Label:createWithTTF("击杀:"..self.mSnake.killing, "font/YOUYUAN.TTF", 25)
	self.scoreTip:setPosition(cc.p(display.width * 0.01,display.height * 0.97))
	self.killTip:setPosition(cc.p(display.width * 0.01,display.height * 0.92))
	self.scoreTip:setAnchorPoint(cc.p(0,0.5))
	self.killTip:setAnchorPoint(cc.p(0,0.5))
	self:addChild(self.scoreTip,20)
	self:addChild(self.killTip,20)
end

--击杀提示文字
--type 1: 双杀  2：三杀 3：四杀 4：五杀 5：终结
-- 6:一血 7：暴走  8：主宰战场 9：接近神  10：超神
function SnakeGameView:showKillHint(type,obj,target)
    if self.killHint then self.killHint:removeFromParentAndCleanup(true) end
    local hintImg = {
        "tcs_use/combo2.png",
        "tcs_use/combo3.png",
        "tcs_use/combo4.png",
        "tcs_use/combo5.png",
        "tcs_use/shutdown.png",
        "tcs_use/firstblood.png",
        "tcs_use/rampage.png",
        "tcs_use/killingspree.png",
        "tcs_use/godlike.png",
        "tcs_use/legendary.png",
    }

    if type <= 5 then
        self.killHint = cc.Sprite:create("tcs_use/kill_hint_bg_1.png")
    else
        self.killHint = cc.Sprite:create("tcs_use/kill_hint_bg_2.png")
    end
    self.killHint:setPosition(display.width/2,display.height*0.85)
    self:addChild(self.killHint,9)
    local hint = cc.Sprite:create(hintImg[type])
    hint:setAnchorPoint(cc.p(0.5,0))
    hint:setPosition(self.killHint:getContentSize().width/2,0)
    self.killHint:addChild(hint)

 --    local para = {
	-- 	{color = cc.c3b(0,224,255), str = obj or "贪吃蛇"},
	-- 	{color = cc.c3b(255,255,255), str = "击败了"},
	-- 	{color = cc.c3b(234,83,46), str = target or "贪吃蛇"},
	-- 	{color = cc.c3b(255,255,255), str = "！"},
	-- }
	-- local para = {fontSize = 20, font = "Arial"}

	local label_0 = cc.Label:createWithTTF("击败了", "font/YOUYUAN.TTF", 30)
    label_0:setPosition(self.killHint:getContentSize().width * 0.5,-25)
    label_0:setTextColor(cc.c3b(255,255,255))
    self.killHint:addChild(label_0)

	local label_1 = cc.Label:createWithTTF(obj, "font/YOUYUAN.TTF", 30)
    label_1:setPosition(label_0:getPositionX() - label_0:getBoundingBox().width * 0.5 - label_1:getBoundingBox().width * 0.5,-25)
    label_1:setTextColor(cc.c3b(0,224,255))
    self.killHint:addChild(label_1)

	local label_2 = cc.Label:createWithTTF(target, "font/YOUYUAN.TTF", 30)
    label_2:setPosition(label_0:getPositionX() + label_0:getBoundingBox().width * 0.5 + label_2:getBoundingBox().width * 0.5,-25)
    label_2:setTextColor(cc.c3b(234,83,46))
    self.killHint:addChild(label_2)

	local label_3 = cc.Label:createWithTTF("!", "font/YOUYUAN.TTF", 30)
    label_3:setPosition(label_2:getPositionX() + label_3:getBoundingBox().width * 0.5 + label_2:getBoundingBox().width * 0.5,-25)
    label_3:setTextColor(cc.c3b(255,255,255))
    self.killHint:addChild(label_3)

    self.killHint:setScaleX(5)
    hint:setVisible(false)
    label_0:setVisible(false)
    label_1:setVisible(false)
    label_2:setVisible(false)
    label_3:setVisible(false)
    self.killHint:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1,1),cc.DelayTime:create(2),cc.CallFunc:create(function()
            self.killHint:removeFromParent()
            self.killHint = nil
        end
    )))
    hint:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
            hint:setVisible(true)
            label_0:setVisible(true)
            label_1:setVisible(true)
            label_2:setVisible(true)
            label_3:setVisible(true)
        end    
    )))
end

-- 无限模式重生界面
function SnakeGameView:showReviveView(lenth,killNums)
    if self.reviveView then
        self.reviveView:removeFromParent()
    else
        -- csb
        local para = {}
        para.csb = "game/ReviveScene.csb"
        para.setSize = true
        self.reviveView = ViewBase.new(para)
        self:addChild(self.reviveView,100)

        -- 设置长度和击杀
        self.reviveView:getChildByName("panel_revive"):getChildByName("panel_middle"):getChildByName("num_long"):setString(lenth)
        self.reviveView:getChildByName("panel_revive"):getChildByName("panel_middle"):getChildByName("num_kill"):setString(killNums)

        -- 关闭按钮
        self.reviveViewCloseBtn = self.reviveView:getChildByName("panel_revive"):getChildByName("panel_middle"):getChildByName("btn_close")
        -- 重来按钮
        self.reviveViewReplayBtn = self.reviveView:getChildByName("panel_revive"):getChildByName("panel_middle"):getChildByName("btn_replay")
        -- 复活按钮
        self.reviveViewReViveBtn = self.reviveView:getChildByName("panel_revive"):getChildByName("panel_middle"):getChildByName("btn_revive")

        self.countdown = 10
        -- 倒计时
        local function countDown()
            self.countdown = self.countdown - 1
            self.reviveView:getChildByName("panel_revive"):getChildByName("panel_middle"):getChildByName("num_countdown"):setString(self.countdown)

            if self.countdown == 0 then
                -- 移除定时器
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_countdown)
                self.reviveView:removeFromParent()
                -- 切换场景
                local scene = cc.TransitionFade:create(0.5,require("views/SnakeHomeScene").new())
                cc.Director:getInstance():replaceScene(scene)
            end
        end
        self.scheduler_countdown = cc.Director:getInstance():getScheduler():scheduleScriptFunc(countDown,1,false)
    end   
end

-- 限时模式游戏结束界面
function SnakeGameView:showEndView(lenth,killNums)
    if self.endView then
        self.endView:removeFromParent()
        self.endView = nil
    else
        -- csb
        local para = {}
        para.csb = "game/EndScene.csb"
        para.setSize = true
        self.endView = ViewBase.new(para)
        self:addChild(self.endView,100)        
    end

    -- 长度
    self.endView:getChildByName("panel_end"):getChildByName("panel_main"):getChildByName("long_num"):setString(lenth)
    -- 击杀
    self.endView:getChildByName("panel_end"):getChildByName("panel_main"):getChildByName("kill_num"):setString(killNums)

    -- 退出按钮
    self.endViewBackBtn = self.endView:getChildByName("panel_end"):getChildByName("panel_back"):getChildByName("btn_back")
    -- 重来按钮
    self.endViewReplayBtn = self.endView:getChildByName("panel_end"):getChildByName("panel_replay"):getChildByName("btn_replay")
end

return SnakeGameView