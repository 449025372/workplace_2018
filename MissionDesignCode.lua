--[[
Author : CaiEnHao
Data : 2018.3.7
--]]

local layer = cc.Layer:create()
self:addChild(layer,100)

local isTouchable = true

local lat = ccui.Layout:create()
lat:setContentSize(display.size)
lat:setTouchEnabled(true)
self:addChild(lat)

local pos_1 = cc.p(display.width * 0.2,display.height * 0.5)
local pos_2 = cc.p(display.width * 0.5,display.height * 0.5)
local pos_3 = cc.p(display.width * 0.8,display.height * 0.5)

-- 三张图片
local sp_1 = ccui.ImageView:create("btn-a-0.png")
sp_1.index = 1
sp_1.name = "紫色球"
sp_1:setTouchEnabled(true)
sp_1:setPosition(pos_1)
lat:addChild(sp_1)

local sp_2 = ccui.ImageView:create("HelloWorld.png")
sp_2:setScale(1.5)
sp_2.index = 2
sp_2.name = "你好世界"
sp_1:setTouchEnabled(true)
sp_2:setPosition(pos_2)
lat:addChild(sp_2)

local sp_3 = ccui.ImageView:create("jianglilizi.png")
sp_3.index = 3
sp_3.name = "闪光"
sp_1:setTouchEnabled(true)
sp_3:setPosition(pos_3)
lat:addChild(sp_3)

-- 三张图片加入表
self.sp_Tbl = {}
table.insert(self.sp_Tbl,sp_1)
table.insert(self.sp_Tbl,sp_2)
table.insert(self.sp_Tbl,sp_3)

-- layer触摸监听
local beginPos = nil
local endPos = nil
local function onTouchBegan(touch,event)
	if isTouchable == false then
		return false
	end
	beginPos = touch:getLocation()
	return true
end
local function onTouchMoved(touch,event)

end
local function onTouchEnded(touch,event)
	endPos = touch:getLocation()

	-- 如果发生了滑动
	if((beginPos.x - endPos.x) ~= 0) then
		-- 禁止触摸
		isTouchable = false
		-- 1秒后恢复触摸
		local function reviveTouch()
			isTouchable = true
		end
		local seq = cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(reviveTouch))
		self:runAction(seq)
	end

	-- 往左滑
	if((beginPos.x - endPos.x) > 0) then
		-- 关卡移动
		for i,v in pairs(self.sp_Tbl) do
			if v.index == 1 then
				v:setLocalZOrder(0)	-- setZOrder在最新版本不推荐使用了 使用后控制台有warning
				v:runAction(cc.MoveTo:create(0.5,pos_3))
			end

			if v.index == 2 then
				v:setLocalZOrder(1)
				local move = cc.MoveTo:create(0.5,pos_1)
				local scale = cc.ScaleTo:create(0.5,1.0)
				local spawn = cc.Spawn:create(move,scale)
				v:runAction(spawn)
			end

			if v.index == 3 then
				v:setLocalZOrder(3)
				local move = cc.MoveTo:create(0.5,pos_2)
				local scale = cc.ScaleTo:create(0.5,1.5)
				local spawn = cc.Spawn:create(move,scale)
				v:runAction(spawn)
			end
		end

		-- 更新当前索引
		for i,v in pairs(self.sp_Tbl) do
			if v.index == 1 then
				v.index = 3
			elseif v.index == 2 then
				v.index = 1
			elseif v.index == 3 then
				v.index = 2
			end
		end
	-- 向右滑
	elseif((beginPos.x - endPos.x) < 0) then
		-- 关卡移动
		for i,v in pairs(self.sp_Tbl) do
			if v.index == 1 then
				v:setLocalZOrder(3)
				local move = cc.MoveTo:create(0.5,pos_2)
				local scale = cc.ScaleTo:create(0.5,1.5)
				local spawn = cc.Spawn:create(move,scale)
				v:runAction(spawn)
			end

			if v.index == 2 then
				v:setLocalZOrder(2)
				local move = cc.MoveTo:create(0.5,pos_3)
				local scale = cc.ScaleTo:create(0.5,1.0)
				local spawn = cc.Spawn:create(move,scale)
				v:runAction(spawn)
			end

			if v.index == 3 then
				v:setLocalZOrder(0)
				v:runAction(cc.MoveTo:create(0.5,pos_1))
			end
		end

		-- 更新当前索引
		for i,v in pairs(self.sp_Tbl) do
			if v.index == 1 then
				v.index = 2
			elseif v.index == 2 then
				v.index = 3
			elseif v.index == 3 then
				v.index = 1
			end
		end
	end

	-- 输出所有关卡各种属性 确认调换后的属性无误
	for i,v in pairs(self.sp_Tbl) do
		print("从左往右第"..v.index.."个关卡","name:"..v.name)
	end
end

local listenner = cc.EventListenerTouchOneByOne:create()  
listenner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )  
listenner:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )   
listenner:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
local eventDispatcher = self:getEventDispatcher()    
eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, layer)  