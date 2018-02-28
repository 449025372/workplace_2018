local Snake = class("Snake")
local Body = require("src.models.Body")
local SnakeCfg = require("SnakeCfg")
local Bean = require("src.models.Bean")

function Snake:ctor(para)
    para = para or {}
    self.id = para.id
    if self.id == 1 then
        self:getRandomAbc()
    end
    self.bodyType = para.bodyType or 1
    self.headType = para.headType
    self.tailType = para.tailType
    self.lenth = para.lenth or 5            -- 蛇身长度包括蛇头
    self.speed = para.speed or 3.5
    self.aSpeed = para.aSpeed or 1          -- 加速度系数
    self.angle = para.angle or math.random(0, 360)
    self.latestAngle = self.angle
    self.gapFactor = para.gapFactor or 20   -- 蛇身间距系数
    self.map = para.map
    self.mapBg = para.mapBg
    self.name = para.name or "贪吃蛇"
    self.bodys = {}
    self.bodysPos = {}
    self.bodysAngle = {}
    self.isDead = false
    self.growFactor = 6                     -- 成长系数
    self.growScale = 0.01                   --蛇变大倍率
    local score = para.score or self.lenth * 6
    self.score = score
    self:saveScoreSignFunc(score)
    self.minScore = self.score
    self.tick = self.tick or 0
    self.lastASpeed = aSpeed
    self.srcData = para
    self.killing = para.killing or 0
    self.comboCD = 0
    self.combo = 0
    self.lastCoverDis = nil
    self.scale = 0.2
    self.timeCount = 0
    self.vector = cc.p(
        math.cos(self.angle * math.pi / 180),
        math.sin(self.angle * math.pi / 180)
    )
end

function Snake:getRandomAbc()
    local tab = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",}
    self.abcTab = {}
    
    local function getABC()
        local index = math.random(1, #tab)
        local abc = tab[index]
        table.remove(tab, index)
        return abc
    end
    for i=1,10 do
        local abc = getABC()
        table.insert(self.abcTab, abc)
    end
end

function Snake:update(dt)
    if self.isDead then return end
    self:moving(dt)
    self:updateSnakeScale()
    if self.comboCD > 0 then
        self.comboCD = self.comboCD - dt
        if self.comboCD < 0 then self.comboCD = 0 end
    end
end

function Snake:moving(dt)
    local frameSpeed = self.speed * self.aSpeed
    self.angle = (self.angle + 360) % 360
    if self.angle ~= self.latestAngle then
        local angleSub = self.angle - self.latestAngle
        local dis = frameSpeed + frameSpeed -- 旋转角度小于多少直接旋转
        -- print(self.angle, angleSub, dis)
        if math.abs(angleSub) < dis then
            self.angle = self.latestAngle
        else
            if (angleSub > 0 and angleSub < 180) or angleSub < -180 then
                self.angle = self.angle - dis
            else
                self.angle = self.angle + dis
            end
        end
        self.vector = cc.p(
            math.cos(self.angle * math.pi / 180),
            math.sin(self.angle * math.pi / 180)
        )
    end

    local increment = cc.pMul(self.vector, self.speed)
    local pos = cc.pAdd(self.head.pos, increment)
    local lag = math.round(self.gapFactor / self.speed)
    table.insert(self.bodysAngle, 1, self.angle)
    table.insert(self.bodysPos, 1, pos)
    for i = 1, self.aSpeed - 1 do
        pos = cc.pAdd(pos, increment)
        table.insert(self.bodysAngle, 1, self.angle)
        table.insert(self.bodysPos, 1, pos)
    end
    self.nameText:setPosition(pos.x,pos.y + 35)
    local coverData = nil
    for k,v in ipairs(self.bodys) do
        local tmpIndex = (k - 1) * lag + 1
        local index = math.min(tmpIndex, #self.bodysPos)
        local nextpos = self.bodysPos[index]
        if self.map then -- 标记蛇身所在区域
            local factorx = math.floor(nextpos.x / self.map.grid.width)
            local factory = math.floor(nextpos.y / self.map.grid.height)
            local gridIndex = factorx * self.map.gridSingleNum + factory + 1
            v.area = gridIndex
            -- print(v.node.area)
            if v.area ~= v.lastArea then
                if v.lastArea then
                    local lastRegionBodys = self.map.regionSnakeBodys[v.lastArea]
                    for i,sv in ipairs(lastRegionBodys) do
                        if v == sv then
                            table.remove(lastRegionBodys, i)
                            break
                        end
                    end
                end

                local curRegionBodys = self.map.regionSnakeBodys[v.area]
                curRegionBodys = curRegionBodys or {}
                table.insert(curRegionBodys, v)
            end
            v.lastArea = v.area
        end
        v.node:setPosition(nextpos)
        v.node:setRotation(-self.bodysAngle[index])
        if k == #self.bodys and self.tail then
            self.tail:setPosition(nextpos)
            self.tail:setRotation(-self.bodysAngle[index])
        end
        v.pos = nextpos
        if k == #self.bodys and #self.bodysPos >= tmpIndex then
            table.remove(self.bodysPos, #self.bodysPos)
            table.remove(self.bodysAngle, #self.bodysAngle)
        end
        if k ~= 1 and self.isProtected then
            if coverData then
                local tmp = cc.pGetDistance(pos, v.pos)
                if coverData.dis < tmp then
                    coverData.dis = tmp
                    coverData.points = {pos, v.pos}
                end
            else
                coverData = {}
                coverData.dis = cc.pGetDistance(pos, v.pos)
                coverData.points = {pos, v.pos}
            end
        end
    end

    if coverData and self.isProtected then
        coverData.dis = coverData.dis + 50
        self:drawCircleCover(coverData)
    end
end

function Snake:grow(score)
    local addScore = score
    if addScore > 3 then
        addScore = 3
    end
    self.score = self.score + addScore
    if self.id == 1 then
        local newScore = self:getAbcScore() + addScore
        self:saveScoreSignFunc(newScore)
    end
    local lenth = math.floor(self.score / self.growFactor) - #self.bodys
    if lenth > 0 then
        self:addBody(#self.bodys + 1)
        self.lenth = #self.bodys
    end
end

function Snake:dead()
    if self.isDead then return end
    self.isDead = true

    for i = 1, #self.bodys do
        local body = self.bodys[i]
        local bean = Bean.new({area = body.area, pos = body.pos, scale = 1, isCorpse = true,colorId = body:getColorId(),color = body:getColor()})
        local node = bean:create()
        node:runAction(cc.MoveBy:create(0.2, cc.p(math.random(-10, 10), math.random(-10, 10))))
        node.valid = true
        self.map.node:addChild(node, 0)
        table.insert(self.map.regionBeans[bean.area], bean)
        self:clearRegionBodys(body)
        body:remove()
    end
    if self.tail then
        self.tail:removeFromParent()
        self.tail = nil
    end
    if self.nameText then
        self.nameText:removeFromParent()
    end
    if self.cover and self.cover.valid then
        self.cover:setVisible(false)
    end

    self.bodys = {}
end

function Snake:revive()
    self.isDead = false
    self.aSpeed = 1
    self.bodys = {}
    self.angle = math.random(0, 360)
    self.latestAngle = self.angle
    self.vector = cc.p(
        math.cos(self.angle * math.pi / 180),
        math.sin(self.angle * math.pi / 180)
    )
    self:init(true)
end

function Snake:newlife()
    self:ctor(self.srcData)
    self:init(true)
end

function Snake:init(setMap)
    self.isProtected = true -- 保护罩
    self.bodysAngle = {}
    self.bodysPos = {}
    for i = 1, self.lenth do
        local body = self:addBody(i)
        if i == 1 then self.head = body end

        local factorx = math.floor(self.head.pos.x / self.map.grid.width)
        local factory = math.floor(self.head.pos.y / self.map.grid.height)
        local gridIndex = factorx * self.map.gridSingleNum + factory + 1
        body.pos = self.head.pos
        body.area = gridIndex
        body.lastArea = gridIndex
    end

     if SnakeCfg.bodys[self.bodyType] and SnakeCfg.bodys[self.bodyType].tail then
        local node = cc.Node:create()
        local tail = cc.Sprite:createWithSpriteFrameName(SnakeCfg.bodys[self.bodyType].tail)
        tail:setRotation(90) -- 初始化蛇尾为坐标系x轴朝向
        tail:setPosition(-self.bodys[#self.bodys].size.width/3*2,0 )
        node:addChild(tail)
        node:setScale(0.2)
        self.tail = node
        self.map.node:addChild(self.tail, SnakeCfg.maxLenth - #self.bodys)
    end

    self.nameText = cc.Label:createWithTTF(self.name,"font/YOUYUAN.TTF",16)
    self.nameText:setAnchorPoint(cc.p(0.5,0.5))
    self.map.node:addChild(self.nameText,SnakeCfg.maxLenth)

    table.insert(self.bodysAngle, self.angle)
    table.insert(self.bodysPos, self.head.pos)

    if setMap then
        local offset = cc.p(self.head.pos.x - self.map.size.width * 0.5, self.head.pos.y - self.map.size.height * 0.5)
        local pos = cc.p(display.cx - offset.x, display.cy - offset.y)
        self.map:setPos(pos)
        self.mapBg:setPos(pos)
    end
end

function Snake:addBody(id)
    local para = {
        id = id,
        mapSize = self.map.size,
        lenth = self.lenth,
        bodyType = self.bodyType,
        headType = self.headType,
        tailType = self.tailType,
        parentID = self.id,
        name = self.name,
        scale = self.scale,
        parent = self
    }
    local body = Body.new(para)
    body:create()
    if #self.bodys > 0 then
        body.pre = self.bodys[#self.bodys]
    end
    table.insert(self.bodys, body)
    body.node.valid = true
    self.map.node:addChild(body.node, SnakeCfg.maxLenth - id + 1)
    if self.tail then
        self.tail:setLocalZOrder(SnakeCfg.maxLenth - id)
    end
    return body
end

function Snake:setAngle(angle)
    self.latestAngle = angle or self.latestAngle
end

function Snake:setVector(vector)
    self.vector = vector or self.vector
end

function Snake:addSpeed(aspeed)
    self.aSpeed = aspeed or self.aSpeed
    
    -- self:initSpeedCheckScheduler()
end

function Snake:initSpeedCheckScheduler()
    -- if not self.head.node or not self.head.node.valid then
    --     return
    -- end
    -- if self.aSpeed == 1 or self.score == self.minScore then
    --     if self.speedCheckAct then
    --         self.head.node:stopAction(self.speedCheckAct)
    --         self.speedCheckAct = nil
    --     end
    --     return
    -- end
    -- local function call()
    --     if self.tick >= 3 then
    --         self.tick = 0
    --         -- print(self.score)
    --         if self.score > self.minScore then
    --             self.score = self.score - 1
    --             if self.id == 1 then
    --                 local newScore = self:getAbcScore() - 1
    --                 self:saveScoreSignFunc(newScore)
    --             end
    --             local lenth = math.floor(self.score / self.growFactor) - #self.bodys
    --             if #self.bodys > 5 and lenth < 0 then
    --                 local body = self.bodys[#self.bodys]
    --                 self:clearRegionBodys(body)
    --                 body:remove()
    --                 table.remove(self.bodys)
    --                 self.lenth = #self.bodys
    --             end
    --         else
    --             self:addSpeed(1)
    --         end
    --     end
    --     self.tick = self.tick + 1
    --     if self.speedCheckAct then
    --         self.speedCheckAct = performWithDelay(self.head.node, call, 0.2)
    --     end
    -- end
    -- if self.speedCheckAct then
    --     self.head.node:stopAction(self.speedCheckAct)
    -- end
    -- self.tick = self.tick + 1
    -- if self.tick >= 3 then
    --     call()
    -- else
    --     self.speedCheckAct = performWithDelay(self.head.node, call, 0.2)
    -- end
end

-- 绘制圆形保护罩
function Snake:drawCircleCover(coverData)
    local origin = cc.pMidpoint(coverData.points[1], coverData.points[2])
    if self.lastCoverDis and self.lastCoverDis >= coverData.dis then
        coverData.dis = self.lastCoverDis
    end
    self.lastCoverDis = coverData.dis
    if self.cover and self.cover.valid then
        -- self.cover:removeFromParent()
        self.cover:setVisible(true)
        self.cover:setPosition(origin)
        self.cover:setScale((coverData.dis + 30)/570)
        self.cover.originDis = coverData.dis
    else
        self.cover = cc.Sprite:create("res/tcs_use/baohuzhao.png")
        self.cover.valid = true
        self.cover:setPosition(origin)
        self.map.node:addChild(self.cover, 100)
        self.cover:setScale((coverData.dis + 30)/570)
        self.cover.originDis = coverData.dis
    end

    if self.head.node.valid and not self.head.node.act then
        local function call()
            self.isProtected = false
            self.head.node.act = nil
            if self.cover and self.cover.valid then
                self.cover:setVisible(false)
            end
        end
        local seq = cc.Sequence:create(cc.DelayTime:create(4), cc.CallFunc:create(call))
        self.head.node.act = self.head.node:runAction(seq)
    end
end

function Snake:clearRegionBodys(body)
    local regionBodys = self.map.regionSnakeBodys[body.area]
    if regionBodys then
        for k,v in ipairs(regionBodys) do
            if v == body then
                table.remove(regionBodys, k)
                break
            end
        end
    end
    if body.lastArea and body.lastArea ~= body.area then
        local regionBodys = self.map.regionSnakeBodys[body.lastArea]
        if regionBodys then
            for k,v in ipairs(regionBodys) do
                if v == body then
                    table.remove(regionBodys, k)
                    break
                end
            end
        end
    end
end

function Snake:updateSnakeScale()
    self.timeCount = self.timeCount + 1
    local scale = 0.2 + (math.floor(math.sqrt((self.lenth-5)/5*2))) * self.growScale
    if scale > 0.25 then
        scale = 0.25
    end
    if self.bodys[1].scale >= scale then return end
    self.scale = scale
    self.gapFactor = 100 * self.scale
    for i,v in ipairs(self.bodys) do
        v:setScale(scale)
    end
end

function Snake:saveScoreSignFunc(score)
    if self.id ~= 1 then
        return
    end
    local str = tostring(score)
    local abcStr = ""
    for i=1,string.len(str) do
        local num = string.sub(str, i, i)
        local ab = self:getNumToAbc(num)
        abcStr = string.format("%s%s", abcStr, ab)
    end
    self.socreSign = abcStr
end

function Snake:getNumToAbc(num)
    return self.abcTab[num + 1]
end

function Snake:getAbcToNum(abc)
    for i,v in ipairs(self.abcTab) do
        if v == abc then
            return i - 1
        end
    end
    return 0
end

function Snake:getAbcScore()
    local function getNums(count)
        local str = "1"
        for i=1,count do
            str = str .. "0"
        end
        return tonumber(str)
    end
    local score = 0
    local lenth = string.len(self.socreSign)
    for i=1,lenth do
        local str = string.sub(self.socreSign, i, i)
        local num = self:getAbcToNum(str)
        score = score + num * getNums(lenth - i)
    end
    return score
end

return Snake
