local Snake = require("src.models.Snake")
local AiSnake = class("AiSnake", Snake)
local SnakeCfg = require("SnakeCfg")

AiSnake.warnRadius = {40, 80} -- 检测范围
AiSnake.udpateDeltas = {2, 1} -- 检测频率 0.05 0.1

function AiSnake:ctor(data)
    data = data or {}
    self.super.ctor(self, data)

    self.bodyType = math.random(1, #SnakeCfg.bodys)
    self.level = data.level or math.random(1, 2) -- ai等级
    self.delta = 0
    self.deltaRotate = math.random(1, 5)
    self.deltaResetSpeed = math.random(1, 2)
end

function AiSnake:update(dt)
    if self.isDead then return end

    self:aiCall(dt)

    self:moving(dt)

    self:updateSnakeScale()

    if self.comboCD > 0 then
        self.comboCD = self.comboCD - dt
        if self.comboCD < 0 then self.comboCD = 0 end
    end
end

function AiSnake:aiCall(dt)
    local checkDelta = AiSnake.udpateDeltas[self.level]
    self.delta = self.delta + dt
    self.deltaRotate = self.deltaRotate - dt
    self.deltaResetSpeed = self.deltaResetSpeed - dt
    if self.delta < checkDelta then
        return
    end
    self.delta = self.delta - checkDelta
    local warningRaius = self.head.radius + AiSnake.warnRadius[self.level]

    local curRegionBodys = self.map.regionSnakeBodys[self.head.area]
    local i = 1
    if curRegionBodys then
        while i <= #curRegionBodys do
            local body = curRegionBodys[i]
            if body.parent ~= self and cc.pGetDistance(self.head.pos, body.pos) <= body.radius + warningRaius then
                self.vector = cc.pNormalize(cc.pSub(self.head.pos, body.pos))
                self:setAngle(self:getAngle())
                return
            end
            i = i + 1
        end
    end

    local collideWall = false
    if self.head.pos.x < warningRaius or self.map.size.width - self.head.pos.x < warningRaius then
        if self.head.pos.x < warningRaius then
            self.vector.x = 1
        else
            self.vector.x = -1
        end
        collideWall = true
    end

    if self.head.pos.y < warningRaius or self.map.size.height - self.head.pos.y < warningRaius then
        if self.head.pos.y < warningRaius then
            self.vector.y = 1
        else
            self.vector.y = -1
        end
        collideWall = true
    end

    if collideWall then
        self:setAngle(self:getAngle())
        return
    end

    local i = 1
    local curRegionBeans = self.map.regionBeans[self.head.area]
    if self.deltaResetSpeed < 0 then
        self.deltaResetSpeed = math.random() * 2
        self:addSpeed(1)
    end
    if curRegionBeans then
        while i <= #curRegionBeans do
            local bean = curRegionBeans[i]
            if cc.pGetDistance(bean.pos, self.head.pos) <= bean.radius + warningRaius then
                self.vector = cc.pNormalize(cc.pSub(bean.pos, self.head.pos))
                self:setAngle(self:getAngle())

                local id = math.random(1, 10)
                if id == 1 then self:addSpeed(2) end
                return
            end
            i = i + 1
        end
    end

    if self.deltaRotate < 0 then
        self.deltaRotate = math.random() * 5
        self:setAngle(math.random(0, 360))
    end
    self.delta = self.delta - checkDelta
end

function AiSnake:getAngle()
    local angle = cc.pGetAngle(cc.p(0,0), self.vector) / math.pi * 180
    if angle < 0 then
        angle = 360 + angle
    end
    return angle
end

function AiSnake:newlife()
    self:ctor(self.srcData)
    self:init(false)
end

function AiSnake:revive()
    self.isDead = false
    self.aSpeed = 1
    self.bodys = {}
    self.angle = math.random(0, 360)
    self.latestAngle = self.angle
    self.vector = cc.p(
        math.cos(self.angle * math.pi / 180),
        math.sin(self.angle * math.pi / 180)
    )
    self:init(false)
end

return AiSnake
