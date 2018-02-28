local Bean = class("Bean")
local SnakeCfg = require("SnakeCfg")
function Bean:ctor(para)
    self.res = string.format("img_eat%d_tcs.png",math.random(1,14))

    self.area = para.area
    self.pos = para.pos
    self.scale = para.scale or 0.7
    self.node = nil
    self.isCorpse = para.isCorpse -- 是否是蛇分解后的尸体
    if self.isCorpse then
        self.score = 3
    else
        self.score = 1
        local value = math.random()
        if value <= 0.2 then
            self.res = "icon_coin_tcs.png"
            self.score = 0
            self.coinValue = math.random(100, 500)
            self.isCoin = true
        end
    end
end

function Bean:create()
    local node = cc.Sprite:createWithSpriteFrameName(self.res)
    self.originSize = node:getContentSize()
    self.size = self.originSize
    self.size = cc.size(self.size.width * self.scale, self.size.width * self.scale)
    self.radius = self.size.width * 0.5
    self.node = node

    node:setScale(self.scale)
    if self.pos then node:setPosition(self.pos) end
    return node
end

function Bean:remove()
    if self.node and self.node.valid then
        self.node:removeFromParent()
    end
end

return Bean