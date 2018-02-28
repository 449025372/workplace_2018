local Map = class("Map")
local Bean = require("src.models.Bean")

function Map:ctor(data)
    self.size = cc.size(3072, 3072)
    self.lineGap = 50
    self.grid = cc.rect(0, 0, 512, 512)  -- 默认 6 x 6
    self.beanNum = 10 					 -- 单区域内豆子数量
    self.regionSnakeBodys = {}
    self.regionBeans = {}
    self.brickSize = 512
end

function Map:create(isBg)
    local layout = ccui.Layout:create()
    if isBg then
        for c = 1,self.size.width / self.brickSize do
            for r = 1,self.size.height / self.brickSize do
                local brick = cc.Sprite:create("res/tcs_use/bg_copy_tcs.png")
                brick:setAnchorPoint(cc.p(0,0))
                brick:setPosition(cc.p((c-1)*self.brickSize,(r-1)*self.brickSize))
                layout:addChild(brick)
            end
        end
    end
    layout:setContentSize(self.size)
    layout:setAnchorPoint(cc.p(0.5, 0.5))

    self.node = layout

    if not isBg then
        self:createGrids()
        self:createBeans()
    end


    return layout
end

-- 创建区域
function Map:createGrids()
    self.grids = {}
    local num = self.size.width / self.grid.width
    self.gridSingleNum = num  -- 单排区域数量
    for i = 1, num do
        for j = 1, num do
            local rect = cc.rect(self.grid.width * (i - 1), self.grid.height * (j - 1), self.grid.width * i, self.grid.height * j)
            table.insert(self.grids, rect)
        end
    end
end

-- 创建豆子
function Map:createBeans()
    self.regionBeans = {}
    local total = #self.grids * self.beanNum
    for i = 1, #self.grids do
        self.regionBeans[i] = {}
        self.regionSnakeBodys[i] = {}
        local grid = self.grids[i]
        for j = 1, self.beanNum do
            local pos = cc.p(math.random(grid.x + 50, grid.width - 50), math.random(grid.y + 50, grid.height - 50))
            local para = {area = i, pos = pos}
            local bean = Bean.new(para)
            local node = bean:create()
            node.valid = true
            self.node:addChild(node, 0)
            table.insert(self.regionBeans[i], bean)
        end
    end
end

function Map:update(dt, mSnake)
    if mSnake then
        local frameSpeed = mSnake.speed * mSnake.aSpeed
        local increment = cc.pMul(mSnake.vector, -frameSpeed)
        self.pos = cc.pAdd(self.pos, increment)
        self.node:setPosition(self.pos)
        -- self.shade:setPosition(cc.p(-self.pos.x,-self.pos.y))
    end
end

function Map:setPos(pos)
    self.pos = pos
    self.node:setPosition(self.pos)
end

function Map:updateBeans()
    for i = 1, #self.grids do
        local grid = self.grids[i]
        if #self.regionBeans[i] < self.beanNum then
            local randomAdd = math.random(1, self.beanNum - #self.regionBeans[i])
            -- print(#self.regionBeans[i], randomAdd)
            for j = 1, randomAdd do
                local pos = cc.p(math.random(grid.x + 50, grid.width - 50), math.random(grid.y + 50, grid.height - 50))
                local para = {area = i, pos = pos}
                local bean = Bean.new(para)
                local node = bean:create()
                node.valid = true
                self.node:addChild(node, 0)
                table.insert(self.regionBeans[i], bean)
            end
        end
    end
end

return Map