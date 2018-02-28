
local Body = class("Body")
local SnakeCfg = require("SnakeCfg")

-- id:1 头 
function Body:ctor(data) -- ,snakeBatch
    self.bodyType = data.bodyType
    self.mapSize = data.mapSize
    self.id = data.id
    self.lenth = data.lenth
    self.pos = data.pos
    self.parentID = data.parentID
    self.parent = data.parent
    self.node = nil
    self.scale = data.scale or 0.2
end

function Body:createOne(type)
    local cfg = SnakeCfg.bodys[self.bodyType]
    if cfg then
        local node = cc.Sprite:createWithSpriteFrameName(cfg.res)
        self.originSize = node:getContentSize()
        self.size = self.originSize
        node:setScale(self.scale)
        self.radius = self.size.width * 0.5 * self.scale
        self.node = node
    end
end

function Body:create()
    local cfg = SnakeCfg.bodys[self.bodyType]
    if cfg then
        local node
        if cfg.head and self.id == 1 then
            node = cc.Sprite:createWithSpriteFrameName(cfg.head)
            node:setOpacity(0)
        else
            if type(cfg.res) == "string" then
                node = cc.Sprite:createWithSpriteFrameName(cfg.res)
            else
                node = cc.Sprite:createWithSpriteFrameName(cfg.res[(self.id - 1) % #cfg.res + 1])
            end
           
        end
        node:setScale(self.scale)
        self.originSize = node:getContentSize()
        self.size = self.originSize
        self.radius = self.size.width * 0.5 * self.scale
        self.node = node
        if self.id == 1 then
            if not cfg.head then
                local eye = cc.Sprite:createWithSpriteFrameName(SnakeCfg.eye)
                eye:setRotation(90) -- 初始化蛇头为坐标系x轴朝向
                eye:setPosition(self.size.width * 0.8, self.size.height * 0.5)
                node:addChild(eye)
            else
                local eye = cc.Sprite:createWithSpriteFrameName(cfg.head)
                eye:setRotation(90) -- 初始化蛇头为坐标系x轴朝向
                eye:setPosition(self.size.width * 0.5, self.size.height * 0.5)
                node:addChild(eye)
            end
            local minx = self.size.width * 10 * self.scale
            local miny = self.size.height * 10 * self.scale
            self.pos = self.pos or cc.p(
                math.random(minx, self.mapSize.width - minx),
                math.random(miny, self.mapSize.height - miny)
                )
            node:setPosition(self.pos)
        elseif self.id == 2 and cfg.middle then
            local middle = cc.Sprite:createWithSpriteFrameName(cfg.middle)
            middle:setRotation(90) -- 初始化蛇头为坐标系x轴朝向
            middle:setPosition(self.size.width * 0.5, self.size.height * 0.5)
            node:addChild(middle)
            node:setOpacity(0)
        end
        return node
    end
    return node
end

function Body:getColor()
    local cfg = SnakeCfg.bodys[self.bodyType]
    if cfg then
        return cfg.color
    end
    return
end

function Body:getColorId()
    local cfg = SnakeCfg.bodys[self.bodyType]
    if cfg then
        return cfg.colorId
    end
    return
end

function Body:remove()
    if self.node and self.node.valid then
        self.node:removeFromParent()
    end
end

function Body:setScale(scale)
    if not scale then return end
    self.scale = scale
    -- self.size = cc.size(self.originSize.width * scale, self.originSize.height * scale)
    -- self.radius = self.size.width * 0.5
    self.radius = self.size.width * 0.5 * self.scale
    self.node:setScale(self.scale)
end

function Body:setPos(pos)
    if not pos then return end
    self.pos = pos
end

return Body