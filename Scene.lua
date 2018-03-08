local Scene = class("Scene",function()
	return cc.Scene:createWithPhysics()	-- 物理场景
end)

function Scene:ctor()
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


	-- -- 世界大小
	-- self.visibleSize = cc.Director:getInstance():getVisibleSize()

	-- -- 设置物理世界重力
	-- local gravity = cc.p(0,-1000)
	-- self:getPhysicsWorld():setGravity(gravity)

	-- -- 物理世界显示包围盒
	-- self:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_NONE) -- cc.PhysicsWorld.DEBUGDRAW_ALL显示包围盒 cc.PhysicsWorld.DEBUGDRAW_NONE不显示包围盒

	-- -- 创建物理边框
	-- local edgeBody = cc.PhysicsBody:createEdgeBox( self.visibleSize, cc.PhysicsMaterial( 1,1 ,0), 3)
	-- local edgeNode = cc.Node:create()
	-- layer:addChild( edgeNode)
	-- edgeNode:setPosition( self.visibleSize.width * 0.5 , self.visibleSize.height * 0.5 )  
	-- edgeNode:setPhysicsBody( edgeBody)

	-- -- 材质类型
	-- local MATERIAL_DEFAULT = cc.PhysicsMaterial(0.1, 0.5, 0.5)						-- 密度、碰撞系数、摩擦力

 --    -- 球
 --    local ball = cc.Sprite:create("btn-a-0.png")

	-- -- 刚体
 --    local body = cc.PhysicsBody:createBox(ball:getContentSize(), MATERIAL_DEFAULT)	-- 刚体大小，材质类型

 --    -- 设置球的刚体属性
 --    ball:setPhysicsBody(body)	-- 设置球的刚体
 --    ball:setPosition(display.center)
 --    layer:addChild(ball)

 --    -- 触摸事件
	-- local function onTouchBegan(touch, event)
	--     local location = touch:getLocation()
	--     local arr = self:getPhysicsWorld():getShapes(location)
	    
	--     local body = nil
	--     for _, obj in ipairs(arr) do
	--     	if obj:getBody() then
	--     		body = obj:getBody()
	--     	end
	--     end
	    
	--     if body then
	--         local mouse = cc.Node:create()
	--         local physicsBody = cc.PhysicsBody:create(PHYSICS_INFINITY, PHYSICS_INFINITY)
	--         mouse:setPhysicsBody(physicsBody)
	--         physicsBody:setDynamic(false)
	--         mouse:setPosition(location)
	--         layer:addChild(mouse)
	--         local joint = cc.PhysicsJointPin:construct(physicsBody, body, location)
	--         joint:setMaxForce(5000.0 * body:getMass())
	--         cc.Director:getInstance():getRunningScene():getPhysicsWorld():addJoint(joint)
	--         touch.mouse = mouse
	        
	--         return true
	--     end
	    
	--     return false
	-- end

	-- local function onTouchMoved(touch, event)
	--     if touch.mouse then
	--         touch.mouse:setPosition(touch:getLocation())
	--     end
	-- end

	-- local function onTouchEnded(touch, event)
	--     if touch.mouse then
	--         layer:removeChild(touch.mouse)
	--         touch.mouse = nil
	--     end
	-- end
 --    local touchListener = cc.EventListenerTouchOneByOne:create()
 --    touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
 --    touchListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
 --    touchListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
 --    local eventDispatcher = layer:getEventDispatcher()
 --    eventDispatcher:addEventListenerWithSceneGraphPriority(touchListener, layer) 

	-- -- EditBox
	-- local imgType = ccui.TextureResType.localType
	-- -- imgType = ccui.TextureResType.plistType
	-- local box = cc.EditBox:create(cc.size(200,50), "cover.png", imgType)
	-- self:addChild(box)
	-- box:setInputFlag(cc.EDITBOX_INPUT_MODE_NUMERIC)
 --    box:setPosition(display.center)

	-- local str = "abcadklaicoa"
	-- local spl = string.split(str,"a")
	-- for i,v in pairs(spl) do
	-- 	print(i,v)
	-- end

	-- print(os.clock())
	-- for i = 1,100 do
	-- 	i = i + 1
	-- end
	-- print(os.clock())
	-- print("GetPreciseDecimal",self:GetPreciseDecimal(9056595.63265,3))
	-- print("checkMoneyString",self:checkMoneyString(12000333))
	-- local layer = cc.Layer:create()
	-- self:addChild(layer)

	-- local name = "SGJyxjs"
	-- local json = "SGJyxjs.json"
	-- local atlas = "SGJyxjs.atlas"
	-- local rabbitSp = sp.SkeletonAnimation:create(json,atlas,1)	-- 第三个参数 放大系数
	-- rabbitSp:setAnimation(0, name, false)	-- 第三个参数 是否无线循环
	-- rabbitSp:setAnchorPoint(cc.p(0.5,0.5))
	-- rabbitSp:setPosition(display.center)
	-- layer:addChild(rabbitSp)

	-- rabbitSp:registerSpineEventHandler(function(event)
	-- 	print("xxxxxxxxxxxx")
	-- 	if(event.type == "end") then
	-- 		print("anim end!!!!!!!!!!!!!!")
	-- 	end
 --    end, sp.EventType.ANIMATION_END)

	-- local layer = cc.Layer:create()
	-- self:addChild(layer)

	-- local name = "SGJyxjs"
	-- local atlas = "SGJyxjs.atlas"
	-- local json =   "SGJyxjs.json"
	-- local anim = sp.SkeletonAnimation:create(json,atlas,1)
	-- anim:setPosition(display.width * 0.5, display.height * 0.5)
	-- anim:setAnimation(0, name, false)
	-- anim:registerSpineEventHandler(function(event)
	-- 	if event.type == "end" then
	-- 		print("anim end!!!!!!!")
	-- 	end
	-- 	end, sp.EventType.ANIMATION_END)
	
	-- layer:addChild(anim)

	-- print("kkk",os.time())
	

--[[
	local sp = cc.Sprite:create("HelloWorld.png")
	sp:setPosition(display.width / 2,display.height / 2)
	self:addChild(sp,0)
	print("width:"..sp:getContentSize().width,"height:"..sp:getContentSize().height)

	local sp_1 = cc.Sprite:create("green_edit.png")
	sp:addChild(sp_1,0)
	print("width:"..sp_1:getContentSize().width,"height:"..sp_1:getContentSize().height)
	print("sp_1 posX:"..sp_1:getPositionX(),"sp_1 posY:"..sp_1:getPositionY())
	local point = sp_1:convertToWorldSpace(cc.p(0,0))
	print("point X:"..point.x,"point Y:"..point.y)

	-- ccui.ImageView
	cc.SpriteFrameCache:getInstance():addSpriteFrames("tcs_plist.plist")
	local img = ccui.ImageView:create("bg_rank_self_tcs.png",1)
	img:setPosition(display.width * 0.2,display.height * 0.5)
	self:addChild(img)

	-- cocos2d-lua中两种定时器的用法 定时器绑定在节点上 当节点被移除时 定时器也会被移除
	performWithDelay(self,function()
		print("performWithDelay")	
	end,2.0)

	schedule(self,function()
			print("schedule")
		end,4.0)
--]]
	
	-- local json = "SGJzbksz.json"
	-- local atlas = "SGJzbksz.atlas"
	-- local ani = sp.SkeletonAnimation:create(json,atlas,1)	-- 第三个参数是缩放
	-- ani:setPosition(display.center)
	-- ani:setAnimation(0, "SGJzbksz", false)
	-- self:addChild(ani,0)

	-- ani:registerSpineEventHandler(function(event)
	-- 	if event.type == "end" then
	-- 		print("end")
	-- 	end
 --    	end, sp.EventType.ANIMATION_END)
 	-- local layer = cc.Layer:create()
 	-- self:addChild(layer)

 -- 	local layout_0 = ccui.Layout:create()
	-- layout_0:setContentSize(display.size)
	-- layer:addChild(layout_0)
	-- layout_0:setBackGroundColorType(LAYOUT_COLOR_SOLID)
	-- layout_0:setColor(cc.c3b(100,100,100))
	-- layout_0:setAnchorPoint(0.5,0.5)
	-- layout_0:setPosition(display.width / 2,display.height / 2)

	-- local layout = ccui.Layout:create()
	-- layout:setContentSize(cc.size(200 ,100))
	-- layer:addChild(layout)
	-- layout:setBackGroundColorType(LAYOUT_COLOR_SOLID)
	-- layout:setColor(cc.c3b(255,255,255))
	-- layout:setAnchorPoint(0.5,0.5)
	-- layout:setPosition(display.width / 2,display.height * 0.8)

	-- local sp = ccui.ImageView:create("HelloWorld.png")
	-- sp:setAnchorPoint(cc.p(0,0))
	-- self:addChild(sp)

	-- local btn = ccui.Button:create("green_edit.png","green_edit.png","green_edit.png")
	-- btn:setPosition(display.center)
	-- layer:addChild(btn)

	-- local function touchCall(sender,eventType)
	-- 	if(eventType == ccui.TouchEventType.ended) then
	-- 		print("btn click")
	-- 	end
	-- end

	-- btn:addTouchEventListener(touchCall)

	-- btn:setEnabled(false)

	-- local pos = sp:getPosition()

	-- local sp = cc.Sprite:create("HelloWorld.png")
	-- layout:addChild(sp)

	-- local str = "abcdefg"
	-- print(str,#str)

	-- local sp = cc.Sprite:create("HelloWorld.png")
	-- sp:setPosition(layout:getBoundingBox().width / 2,layout:getBoundingBox().height / 2)
	-- layout:addChild(sp,0)

	-- layout:setScale(0.5)


	-- local layer = cc.Layer:create()
	-- self:addChild(layer)
	------------------------ 刮奖效果 ------------------------

	-- -- 底图
	-- local sp_1 = cc.Sprite:create("HelloWorld.png")
	-- sp_1:setPosition(display.width / 2,display.height * 0.7)
	-- layer:addChild(sp_1)

	-- local sp_2 = cc.Sprite:create("HelloWorld.png")
	-- sp_2:setPosition(display.width / 2,display.height * 0.3)
	-- layer:addChild(sp_2)

	-- -- 创建一个橡皮擦 颜色是全透明的黑色
	-- local eraser = cc.DrawNode:create()
	-- eraser:drawDot(cc.p(0,0),10,cc.c4b(0,0,0,0))
	-- eraser:retain()

	-- -- 创建画布 并显示它
	-- local RTex = cc.RenderTexture:create(display.width,display.height)
	-- RTex:setPosition(display.center)
	-- layer:addChild(RTex,10)

	-- -- 创建被擦除的内容 将其渲染到画布上
	-- local bg_1 = cc.Sprite:create("cover.png")
	-- bg_1:setPosition(sp_1:getPosition())
	-- RTex:begin()
	-- bg_1:visit()
	-- RTex:endToLua()

	-- local bg_2 = cc.Sprite:create("cover.png")
	-- bg_2:setPosition(sp_2:getPosition())
	-- RTex:begin()
	-- bg_2:visit()
	-- RTex:endToLua()

	-- -- layer触摸事件
 --    local eventDispatcher = layer:getEventDispatcher()
 --    local function onTouchBegan(touch, event)

 --        return true
 --    end

 --    local function onTouchMoved(touch, event)

 --        -- 获取触摸坐标并移动橡皮擦到该坐标
 --        local touchLocation = touch:getLocation()
 --        eraser:setPosition(touchLocation)
 --        -- 设置混合模式
 --        eraser:setBlendFunc({GL_ONE,GL_ZERO})
 --        -- 将橡皮擦的像素渲染到画布上 与原来的像素进行混合
 --        RTex:begin()
 --        eraser:visit()
 --        RTex:endToLua()

 --        -- -- 检测是否碰到了刮奖图
 --        -- if(cc.rectContainsPoint(sp:getBoundingBox(),touchLocation)) then
        	
 --        -- end
 --    end

 --    local  function onTouchEnded(touch, event)

 --    end
 --    local listener = cc.EventListenerTouchOneByOne:create()
 --    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
 --    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
 --    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
 --    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,layer)

	----------------------------------------------------------

	-- local sp = ccui.ImageView:create("HelloWorld.png")
	-- sp:setPosition(display.center)
	-- self:addChild(sp)

	-- function Scene:test(para)
	-- 	print("this is a test",para.a,para.b)
	-- end

	-- local ts = handler(self,self.test)
	-- local tb = {a = 1,b = 2}
	-- ts(tb)

	-- local function callback()
	-- 	print("call")
	-- end
	-- if(callback) then
	-- 	print("call exist!")
	-- else
	-- 	print("call is not exist")
	-- end


	----------------------- 动画滚动效果 -------------------------
-- 	self.items = {}
-- 	-- 滚动item
-- 	for i = 1,3 do
-- 		local item = cc.Sprite:create("green_edit.png")
-- 		item:setPosition(display.width * (0.4 + 0.1 * (i - 1)),display.height * 0.65)
-- 		self:addChild(item)
-- 		self.items[i] = item
-- 	end
-- 	for i = 1,3 do
-- 		local item = cc.Sprite:create("green_edit.png")
-- 		item:setPosition(display.width * (0.4 + 0.1 * (i - 1)),display.height * 0.35)
-- 		self:addChild(item)
-- 		self.items[i + 2 * (4 - i)] = item
-- 	end

-- 	local item = cc.Sprite:create("green_edit.png")
-- 	item:setPosition(display.width * 0.4,display.height * 0.5)
-- 	self:addChild(item)
-- 	self.items[8] = item

-- 	local item_0 = cc.Sprite:create("green_edit.png")
-- 	item_0:setPosition(display.width * 0.6,display.height * 0.5)
-- 	self:addChild(item_0)
-- 	self.items[4] = item_0

-- 	self:startRollAnim(8,8)
-- end

-- -- 开奖滚动动画
-- function Scene:startRollAnim(beginIndex,targetIndex)
-- 	local timeLit = {
-- 		0.5,0.47,0.36,0.31,0.257, -- 3.963s 2
-- 		3.763,0.43,0.63,0.77,1.03 -- 3.763
-- 	}
-- 	local roTimes = 3
-- 	local counts,startID,endID = #self.items,beginIndex,targetIndex -- 个数 起点位置 终点位置
-- 	local totalCounts = counts * roTimes + ((endID - startID + counts) % counts)
-- 	local roCounts = totalCounts - 9
-- 	local endCount = roCounts + 5
-- 	local speed = timeLit[6] / roCounts
-- 	print("speed:",timeLit[6],roCounts,speed,startID,endID,totalCounts)
-- 	local actDu = speed + 0.6 -- 每次显示耗时
-- 	local actionFade = cc.Sequence:create(
-- 			cc.FadeIn:create(speed * 0.4),
-- 			cc.DelayTime:create(speed * 0.6 + 0.3),
-- 			cc.FadeOut:create(0.3)
-- 		)

-- 	local timeData = {}
-- 	local id,curTime = startID + 1,0
-- 	if id > 8 then id = 1 end
-- 	for i=1,totalCounts do -- 计算时间表
-- 		if timeData[id] == nil then timeData[id] = {} end

-- 		if i < 6 then
-- 			curTime = curTime + timeLit[i]
-- 			timeData[id][1] = curTime
-- 		elseif i > roCounts + 5 then
-- 			curTime = curTime + timeLit[1 + i - roCounts]
-- 			table.insert(timeData[id],curTime)
-- 		else
-- 			curTime = curTime + speed
-- 			table.insert(timeData[id],curTime)
-- 		end

-- 		id = id + 1
-- 		if id > counts then id = 1 end
-- 	end

-- 	local endFun = function()
-- 		--转盘item选中动画
-- 	 	if self.startAnimRewardOpen then
-- 			self:startAnimRewardOpen(endID)
-- 	 	end
-- 	end

-- 	-- dump(timeData,时间数组：)
-- 	self.curEffIndex = 1
-- 	self.items[startID]:runAction(actionFade)
-- 	for i,one in ipairs(self.items) do
-- 		local timeTable = timeData[i]
-- 		if i == endID then
-- 			if #timeTable == 3 then -- roTimes = 3 则可能为3-4圈
-- 					one:runAction(cc.Sequence:create(
-- 					cc.DelayTime:create(timeTable[1]),
-- 					actionFade:clone(),
-- 					cc.DelayTime:create(timeTable[2] - timeTable[1] - actDu),
-- 					actionFade:clone(),
-- 					cc.DelayTime:create(timeTable[3] - timeTable[2] - actDu),
-- 					cc.FadeIn:create(0),
-- 					cc.Blink:create(1,8),
-- 					cc.CallFunc:create(endFun))
-- 				)
-- 			else
-- 				    one:runAction(cc.Sequence:create(
-- 					cc.DelayTime:create(timeTable[1]),
-- 					actionFade:clone(),
-- 					cc.DelayTime:create(timeTable[2] - timeTable[1] - actDu),
-- 					actionFade:clone(),
-- 					cc.DelayTime:create(timeTable[3] - timeTable[2] - actDu),
-- 					actionFade:clone(),
-- 					cc.DelayTime:create(timeTable[4] - timeTable[3] - actDu),
-- 					cc.FadeIn:create(0),
-- 					cc.Blink:create(1,8),
-- 					cc.CallFunc:create(endFun))
-- 				)
-- 			end
-- 		else
-- 			if #timeTable == 3 then -- roTimes = 3 则可能为3-4圈
-- 					one:runAction(cc.Sequence:create(
-- 					cc.DelayTime:create(timeTable[1]),
-- 					actionFade:clone(),
-- 					cc.DelayTime:create(timeTable[2] - timeTable[1] - actDu),
-- 					actionFade:clone(),
-- 					cc.DelayTime:create(timeTable[3] - timeTable[2] - actDu),
-- 					actionFade:clone()
-- 				))
-- 			else
-- 					one:runAction(cc.Sequence:create(
-- 					cc.DelayTime:create(timeTable[1]),
-- 					actionFade:clone(),
-- 					cc.DelayTime:create(timeTable[2] - timeTable[1] - actDu),
-- 					actionFade:clone(),
-- 					cc.DelayTime:create(timeTable[3] - timeTable[2] - actDu),
-- 					actionFade:clone(),
-- 					cc.DelayTime:create(timeTable[4] - timeTable[3] - actDu),
-- 					actionFade:clone()
-- 				))
-- 			end
-- 		end
-- 	end
-- end

-- --开奖选中边框闪光
-- function Scene:startAnimRewardOpen(index)
-- 	if not index then return end
-- 	local node = self.items[index]
-- 	if not node or  node.anim then return end
-- 	local name = "SGJxzkklizi"
-- 	local atlas = name..".atlas"
-- 	local json =  name..".json"
-- 	local anim = sp.SkeletonAnimation:create(json,atlas,1)
-- 	local ss = node:getContentSize()
-- 	anim:setPosition(ss.width * 0.5, ss.height * 0.5)
-- 	node:addChild(anim)
-- 	node.anim = anim
-- 	anim:setAnimation(0, name, true)
-- end

--------------------------------------------------------------------------------------
end

function Scene:onEnter()
	print("Scene onEnter")
end

-- 省略小数 参数1-数字 参数2-保留小数点位数 
local function GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum
    end
    if nNum > 10000 then
        n = 0
    else
        -- n = 1
    end
    n = n or 0;
    n = math.floor(n)
    if n < 0 then
        n = 0
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(nNum * nDecimal)
    local nRet = nTemp / nDecimal
    print("GetPreciseDecimal = ", nNum, n, nRet)
    return nRet
end

-- 数字转化为字符串 例如传入1000000 返回1,000,000
local function checkNumToString(nums)
    local str = tostring(nums)
    local newStr = ""
    if #str > 3 then
        local count = math.floor(#str / 3)
        local remain = #str % 3
        if remain == 0 then
            for i=1,count do
                if i ~= count then
                    newStr = newStr..string.sub(str, (i - 1) * 3 + 1, 3 * i)..","
                else
                    newStr = newStr..string.sub(str, (i - 1) * 3 + 1, 3 * i)
                end
            end
        else
            newStr = string.sub(str, 1, remain)..","
            for i=1,count do
                if i ~= count then
                    newStr = newStr..string.sub(str, remain + (i - 1) * 3 + 1, 3 * i + remain)..","
                else
                    newStr = newStr..string.sub(str, remain + (i - 1) * 3 + 1, 3 * i + remain)
                end
            end
        end
    else
        newStr = str
    end
    print("checkNumToStringcheckNumToStringcheckNumToString", newStr)
    return newStr
end

return Scene