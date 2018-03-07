--[[
	Author : CaienHao
	Data : 2018.3.7
--]]

-- ListView
local listView = ccui.ListView:create()
-- listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)  -- 设置方向为水平方向  
listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)     -- 设置方向为垂直方向  
listView:setBounceEnabled(true)                             -- 滑动惯性
-- listView:setBackGroundImage("white_bg.png")              -- 背景图片
listView:setBackGroundImageScale9Enabled(true)              -- 设置背景图片酒店图
listView:setContentSize(600,300)  
listView:setPosition(cc.p(s.width / 2,s.height / 2)) 
listView:setAnchorPoint(cc.p(0.5,0.5))
listView:setItemsMargin(10)                                 -- item间距
listView:setScrollBarEnabled(false)                         -- 设置滚动条隐藏
self:addChild(listView)

-- 创建10个item
for i = 1,10 do
    local layout = ccui.Layout:create()
    layout:setContentSize(300,300)
    layout:setAnchorPoint(cc.p(0.5,0.5))
    listView:addChild(layout)

    -- 这里创建的是ImageView 实际项目中可能会使用Label和Button
    local image = ccui.ImageView:create("HelloWorld.png")
    image:setPosition(cc.p(listView:getContentSize().width / 2,listView:getContentSize().height / 2))
    layout:addChild(image)
end