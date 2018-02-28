local SnakeGameController = class("SnakeGameController",require("views.SnakeGameView"))

local Map = require("models.Map")
local Snake = require("models.Snake")
local AiSnake = require("models.AiSnake")

function SnakeGameController:ctor(mode)
	self.mode = mode
	self:enableNodeEvents()
end

function SnakeGameController:onEnter()
	-- 游戏初始化
	self:gameInit()
	-- 初始化界面
	self:initGameView()
	-- 更新
	self:initUpdateScheduler()
end

-- 游戏初始化
function SnakeGameController:gameInit()
	-- 如果是限时模式
	if self.mode == 1 then
		-- 剩余时间
		self.restTime = 300
		local str = self:timeExchange(self.restTime)
		self.countTimeLabel = cc.Label:createWithTTF(str, "font/YOUYUAN.TTF", 48)
		self.countTimeLabel:setPosition(cc.p(display.width * 0.5,display.height * 0.9))
		self:addChild(self.countTimeLabel,80)

		-- 倒数定时器
		local function countDown()
			self.restTime = self.restTime - 1
			local minute = math.floor(self.restTime / 60)
			local second = self.restTime % 60
			local str = self:timeExchange(self.restTime)
			self.countTimeLabel:setString(str)

			-- 时间到了
			if self.restTime == 0 then
				-- 显示游戏结束界面
				self:initEndView(self.mSnake.lenth,self.mSnake.killing)
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_game_countdown)
				-- 玩家死亡
				if self.mSnake then
					self.mSnake:dead()
					self.mSnake = nil
				end
			end	
		end
		self.scheduler_game_countdown = cc.Director:getInstance():getScheduler():scheduleScriptFunc(countDown,1,false)
	end

	-- 地图背景
	local mapBg = Map.new()
	local mapBgNode = mapBg:create(true)
	self:addChild(mapBgNode, 1)
	self.mapBg = mapBg
	-- 地图
	local map = Map.new()
	local mapNode = map:create()
	self.map = map
	self:addChild(mapNode, 3)

	local shade = cc.Sprite:create("res/tcs_use/shade.png")
    shade:setAnchorPoint(cc.p(0.5, 0.5))
    shade:setPosition(cc.p(display.width/2,display.height/2))
    self:addChild(shade,2)

    -- 蛇
	self.timeCount = 0
	self.snakes = {}
	self.deadSnakes = {}
	local currentSkin = self:getCurrentSkin()
	local count = 10	-- 数量
	for i = 1, count do
		local snake = nil
		if i == 1 then	-- 玩家
			local para = {map = self.map,mapBg = self.mapBg, id = i,bodyType = currentSkin, name = SnakeCfg.name}
			snake = Snake.new(para)
		else			-- AI
			local nick = string.format("游客%d%d%d%d",math.random(0,9),math.random(0,9),math.random(0,9),math.random(0,9))
			local para = {map = self.map,mapBg = self.mapBg, id = i, name = nick}
			snake = AiSnake.new(para)
		end
		snake:init(i == 1)
		table.insert(self.snakes, snake)
		if i == 1 then
			self.mSnake = snake
			self.angle = snake.angle
		end
	end

	local default_userHabit = cc.UserDefault:getInstance():getIntegerForKey("userHabit")	-- 用户操作习惯
	if default_userHabit == 0 then
		cc.UserDefault:getInstance():setIntegerForKey("userHabit",1)
	end
	local para = {
		onEnded = handler(self, self.JoyStickOnEnd),
		onMoved = handler(self, self.JoyStickOnMove),
		onSpeedBegan = handler(self, self.speedBtnBegan),
		onSpeedEnded = handler(self, self.speedBtnEnded),
		pos = cc.p(display.width * 0.15, display.height * 0.15),
		userHabit = default_userHabit
	}
    self.joystick = require("src.views.JoyStickView").new(para)
    self:addChild(self.joystick, 10)

	-- self:initRankView()
	-- self:updateRank(1)
	-- if self.isTimer then
	-- 	self:initTimerText()
	-- end
end

-- 获得当前皮肤
function SnakeGameController:getCurrentSkin()
	local skinID = cc.UserDefault:getInstance():getIntegerForKey("skinID")
	return skinID
end

-- 游戏更新
function SnakeGameController:initUpdateScheduler()
	local function update(dt)
		-- 设置帧率
		local value = 1 / dt
		if value < 40 then
			cc.Application:getInstance():setAnimationInterval(1/60)
		end

		-- 地图更新
		self.map:update(dt, self.mSnake)
		self.mapBg:update(dt, self.mSnake)

		-- 蛇的更新
		for i,v in ipairs(self.snakes) do
			v:update(dt)
		end

		-- 豆子的更新
		self.map:updateBeans()

		-- 碰撞检测
		self:collisionChecking()

		-- AI复活
		self:checkAiNewLife()

		-- 排行榜更新
		self:rankUpdate()
	end
	self:scheduleUpdateWithPriorityLua(update, 0)
end

-- 排行榜更新
function SnakeGameController:rankUpdate()
	local names = {}
	local scores = {}
	for i,v in pairs(self.snakes) do
		table.insert(names,v.name)
		table.insert(scores,v.score)
	end

	for i,v in pairs(self.snakes) do
		for n = i + 1,#self.snakes do
			if(v.score < self.snakes[n].score) then
				local tmpName = names[i]
				local tmpScore = scores[i]
				names[i] = names[n]
				scores[i] = scores[n]
				names[n] = tmpName
				scores[n] = tmpScore
			end
		end
	end
	
	for i,v in pairs(names) do
		self.ranks[i]:getChildByName("name"):setString(v)
		self.ranks[i]:getChildByName("score"):setString(scores[i])
	end
end

-- 摇杆move
function SnakeGameController:JoyStickOnMove(data)
	self.angle = data.angle or self.angle
	if self.mSnake then
		self.mSnake:setAngle(self.angle)
	end
end

-- 摇杆end
function SnakeGameController:JoyStickOnEnd(data)

end

-- 加速begin
function SnakeGameController:speedBtnBegan()
	if self.mSnake then
		self.mSnake:addSpeed(2)
	end
end

-- 加速end
function SnakeGameController:speedBtnEnded()
	if self.mSnake then
		self.mSnake:addSpeed(1)
	end
end

-- 碰撞检测
function SnakeGameController:collisionChecking()
    local k = 1
    while k <= #self.snakes do
    	local check = true
    	local snake = self.snakes[k]
    	local radius = snake.head.radius
    	local area = snake.head.area
        -- 边界检测
        if snake.head.pos.x < radius
            or snake.head.pos.y < radius
            or self.map.size.width - snake.head.pos.x < radius
            or self.map.size.height - snake.head.pos.y < radius then
            snake:dead()
            -- 如果死的是玩家
            if snake == self.mSnake then
            	-- print("collide border")
            	self.lastLenth = self.mSnake.lenth
            	self.lastScore = self.mSnake.score
            	self.lastKilling = self.mSnake.killing
            	-- 无限模式
            	if self.mode == 0 then
	            	self:initReviveView(self.mSnake.lenth,self.mSnake.killing)
	            -- 限时模式
	        	else
	        		self:initEndView(self.mSnake.lenth,self.mSnake.killing)
            	end
            	self.tmpSnake = self.mSnake
            	self.mSnake = nil
            -- 如果死的是AI
            else
            	table.insert(self.deadSnakes, snake)
            end
            table.remove(self.snakes, k)
            k = k - 1
            check = false
        end

        -- 和其它蛇碰撞
        if check and not snake.isProtected and area then
        	local i = 1
        	local curRegionBodys = self.map.regionSnakeBodys[area]
        	while i <= #curRegionBodys do
        		local body = curRegionBodys[i]
        		if check and body.parent ~= snake and cc.pGetDistance(snake.head.pos, body.pos) <= body.radius + radius then
                    snake:dead()
                    -- 如果死的是玩家
                    if snake == self.mSnake then
                    	self.lastLenth = self.mSnake.lenth
		            	self.lastScore = self.mSnake.score
		            	self.lastKilling = self.mSnake.killing
		            	-- 无限模式
		            	if self.mode == 0 then
			            	self:initReviveView(self.mSnake.lenth,self.mSnake.killing)
			            -- 限时模式
			        	else
			        		self:initEndView(self.mSnake.lenth,self.mSnake.killing)
		            	end
		            	self.tmpSnake = self.mSnake
		            	self.mSnake = nil
		            -- 如果死的是AI
		            else
		            	table.insert(self.deadSnakes, snake)
		            end
                    table.remove(self.snakes, k)
    				k = k - 1
    				check = false
    				body.parent.killing = body.parent.killing + 1
					if body.parent.comboCD > 0 then 
						body.parent.combo = body.parent.combo + 1 
					else 
						body.parent.combo = 0 
					end
					body.parent.comboCD = 2
					self:showKillHintView(body.parent,snake)

					-- 如果是玩家击杀的
					if(body.parent == self.mSnake) then
						self.killTip:setString("击杀:"..self.mSnake.killing)
					end
        		end
        		i = i + 1
        	end
	    end

        -- 蛇头与豆子碰撞检测
        if check and area then
        	local i = 1
        	local curRegionBeans = self.map.regionBeans[area]
        	while i <= #curRegionBeans do
        		local bean = curRegionBeans[i]
                if cc.pGetDistance(bean.pos, snake.head.pos) <= bean.radius + radius + 5 then
                	if snake == self.mSnake then
                		self:showGetBean(bean)
                	end
                	snake:grow(bean.score)
                    bean:remove()
                    table.remove(curRegionBeans, i)
                    i = i - 1
                end
                i = i + 1
	        end
	    end
        k = k + 1
    end
end

-- 无限模式重生界面
function SnakeGameController:initReviveView(lenth,killNums)
	-- 显示重生界面
	self:showReviveView(lenth,killNums)
	-- 添加重生界面监听事件
	self:addReviveViewListener()
end

-- 无限模式添加重生界面监听事件
function SnakeGameController:addReviveViewListener()
	local function touchCall(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			-- 关闭按钮
			if(sender == self.reviveViewCloseBtn) then
                -- 切换场景
                local scene = cc.TransitionFade:create(0.5,require("views/SnakeHomeScene").new())
                cc.Director:getInstance():replaceScene(scene)
                if self.scheduler_countdown then
	                -- 移除定时器
	                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_countdown)
                end
            -- 重来按钮
            elseif(sender == self.reviveViewReplayBtn) then
                -- 切换场景
                local scene = cc.TransitionFade:create(0.5,require("views/SnakeGameScene").new(0))
                cc.Director:getInstance():replaceScene(scene)
                if self.scheduler_countdown then
	                -- 移除定时器
	                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_countdown)
                end
			-- 花钱复活按钮
			elseif(sender == self.reviveViewReViveBtn) then
            	-- 如果钱够
            	local coin = cc.UserDefault:getInstance():getIntegerForKey("coin")
            	if(coin > 10000) then
            		-- 扣钱
            		local coin = cc.UserDefault:getInstance():getIntegerForKey("coin")
            		coin = coin - 10000
            		cc.UserDefault:getInstance():setIntegerForKey("coin",coin)
            		-- 还原之前战绩
					self.tmpSnake.srcData.lenth = self.lastLenth
					self.tmpSnake.srcData.score = self.lastScore
					self.tmpSnake.srcData.killing = self.lastKilling
					self.tmpSnake:newlife()
					self.time = SnakeCfg.timer
					-- self:updateTimer(1)
					self.mSnake = self.tmpSnake
					self.reviveView:removeFromParent()
					self.reviveView = nil
					table.insert(self.snakes, self.mSnake)
					self.scoreTip:setString("得分:"..self.tmpSnake.score)
					self.killTip:setString("击杀:"..self.tmpSnake.killing)
	                if self.scheduler_countdown then
		                -- 移除定时器
		                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_countdown)
	                end
				else
					Dialog:showTip(self.reviveView,"对不起！您身上的金币不足！")
				end
			end
		end
	end
	self.reviveViewCloseBtn:addTouchEventListener(touchCall)
	self.reviveViewReplayBtn:addTouchEventListener(touchCall)
	self.reviveViewReViveBtn:addTouchEventListener(touchCall)
end

-- 限时模式游戏结束界面
function SnakeGameController:initEndView(lenth,killNums)
	-- 停止倒数
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduler_game_countdown)
	-- 显示游戏结束界面
	self:showEndView(lenth,killNums)
	-- 添加游戏结束界面监听事件
	self:addEndViewListener()
end

-- 限时模式添加游戏结束界面监听事件
function SnakeGameController:addEndViewListener()
	local function touchCall(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if(sender == self.endViewBackBtn) then
                -- 切换场景
                local scene = cc.TransitionFade:create(0.5,require("views/SnakeHomeScene").new())
                cc.Director:getInstance():replaceScene(scene)
            elseif(sender == self.endViewReplayBtn) then
                local scene = cc.TransitionFade:create(0.5,require("views/SnakeGameScene").new(1))
                cc.Director:getInstance():replaceScene(scene)
			end
		end
	end
	self.endViewBackBtn:addTouchEventListener(touchCall)
	self.endViewReplayBtn:addTouchEventListener(touchCall)
end

-- 吃到豆子
function SnakeGameController:showGetBean(bean)
	local score = self.mSnake.score
	local coin = cc.UserDefault:getInstance():getIntegerForKey("coin")
	-- 蛇身体变成的豆子
	if bean.isCorpse then
		score = score + 3
		self.scoreTip:setString("得分:"..score)
		self.scoreTip:setPosition(cc.p(display.width * 0.01,display.height * 0.97))
	-- 金币
	elseif bean.isCoin then
		local addCoin = math.random(100,500)
		coin = coin + addCoin
		cc.UserDefault:getInstance():setIntegerForKey("coin",coin)
		-- 效果
		local str = string.format("+%d",addCoin)
		local label = cc.Label:createWithTTF(str, "font/YOUYUAN.TTF", 25)
		label:setPosition(cc.p(bean.node:getPositionX(),bean.node:getPositionY()))
		label:setTextColor(cc.c3b(0,255,0))
		self.map.node:addChild(label,SnakeCfg.maxLenth + 100)
		local act_1 = cc.FadeOut:create(1)
		local act_2 = cc.JumpBy:create(0.3,cc.p(0,label:getBoundingBox().height),label:getBoundingBox().height,1)
		local spawn = cc.Spawn:create(act_1,act_2)
		label:runAction(spawn)
		performWithDelay(self,function()
				label:removeFromParent()
			end,1)
		self.scoreTip:setPosition(cc.p(display.width * 0.01,display.height * 0.97))
	-- 普通豆子
	else
		score = score + 1
		self.scoreTip:setString("得分:"..score)
		self.scoreTip:setPosition(cc.p(display.width * 0.01,display.height * 0.97))
	end
end

-- 显示击杀
function SnakeGameController:showKillHintView(obj,target)
	-- self.music:playEffect("killing")
	local type = 0
	-- print("击杀数",self.mSnake.killing)
	if obj == self.mSnake then
		if self.mSnake.killing == 1 then
			type = 6
		elseif self.mSnake.killing == 3 then
			type = 7
		elseif self.mSnake.killing == 6 then
			type = 8
		elseif self.mSnake.killing == 9 then
			type = 9
		elseif self.mSnake.killing >= 12 then
			type = 10
		end
	end

	if obj.combo == 1 then

	elseif obj.combo == 2 then
		type = 1
	elseif obj.combo == 3 then
		type = 2
	elseif obj.combo == 4 then
		type = 3
	elseif obj.combo >= 5 then
		type = 4
	end

	if target.rank and target.rank == 1 then
		type = 5
	end

	-- 音效
	-- if type == 1 then
	-- 	self.music:playEffect("cv_doublekill_01")
	-- elseif type == 2 then
 --        self.music:playEffect("cv_triplekill_01")
	-- elseif type == 3 then
 --        self.music:playEffect("cv_quatarykill_01")
	-- elseif type == 4 then
 --        self.music:playEffect("cv_pentakill_01")
	-- elseif type == 5 then
 --        self.music:playEffect("cv_shutdown_01")
	-- elseif type == 6 then
 --        self.music:playEffect("cv_firstblood_01")
 --    elseif type == 7 then
 --        self.music:playEffect("cv_rampage_01")
 --    elseif type == 8 then
 --        self.music:playEffect("cv_killingspree_01")
 --    elseif type == 9 then
 --        self.music:playEffect("cv_godlike_01")
 --    elseif type == 10 then
 --        self.music:playEffect("cv_legendary_01")
 --    end
	if type ~= 0 then 
		self:showKillHint(type,obj.name,target.name)
	end
end

-- AI复活
function SnakeGameController:checkAiNewLife()
	self.timeCount = self.timeCount + 1
	if self.timeCount % 100 == 0 then
		for k,v in pairs(self.deadSnakes) do
			if v.lenth > 5 then
				v.lenth = v.lenth - 1
			end
		end
		local deadCount = #self.deadSnakes
		if deadCount > 0 then
			local index = math.random(1, deadCount)
			local deadSnake = self.deadSnakes[index]
			local reLifeValue = math.random(1, 100)
			print("checkAiNewLifecheckAiNewLife = ", reLifeValue, deadCount, #self.snakes)
			if reLifeValue < 50 then  --不复活
				return
			else
				local reviveRate = 0
				if deadSnake.lenth > 500 then
					reviveRate = 50
				elseif deadSnake.lenth > 100 then
					reviveRate = 25
				else
					reviveRate = 10
				end
				local value = math.random(1, 100)
				if value < reviveRate then  -- 复活
					deadSnake:revive()
				else 						-- 重来
					deadSnake:newlife()
				end
				print("ai复活 = ", #self.deadSnakes, #self.snakes)
				table.remove(self.deadSnakes, index)
				table.insert(self.snakes, deadSnake)
				print("ai复活 = ", #self.deadSnakes, #self.snakes)
			end
		end
	end
end

-- 时间转换
function SnakeGameController:timeExchange(num)
	local minute = math.floor(num / 60)
	local second = num % 60
	local str = ""

	if minute == 0 then
		minute = "00"
	end

	if second == 0 then
		str = minute..":".."00"
	elseif second < 10 then
		str = minute..":".."0"..second
	else
		str = minute..":"..second
	end	
	return str
end



return SnakeGameController