local GameWaitScene = class("GameWaitScene",function()
		return cc.Scene:create()
	end)

require("headers")

function GameWaitScene:ctor()
	-- 初始化加载界面
	self:initWaitingView()
end

function GameWaitScene:initWaitingView()
	-- 加载层
	self.waitingView = cc.Layer:create()
	self:addChild(self.waitingView,0)

	-- 加载界面
	local para = {}
	para.csb = "game/LoadingScene.csb"
	para.setSize = true
	self.showWaitingView = ViewBase.new(para)
	self.waitingView:addChild(self.showWaitingView)

	-- 动画
	local name  = "TCS-LOADing"
	local json  = "anim/TCS-LOADing.json"
	local atlas = "anim/TCS-LOADing.atlas"
	self.loadingAni = sp.SkeletonAnimation:create(json,atlas,1)	-- 第三个参数 放大系数
	self.loadingAni:setAnimation(0, name, true)					-- 第三个参数 是否无限循环
	self.loadingAni:setAnchorPoint(cc.p(0.5,0.5))
	self.loadingAni:setPosition(display.center)
	self.showWaitingView:addChild(self.loadingAni)

	-- 加载资源
	for i,v in pairs(RESOURCES.plist) do
		cc.SpriteFrameCache:getInstance():addSpriteFrames(v)
	end

	-- 加载完资源开始进度条
	local loadingBar = self.showWaitingView:getChildByName("panel_loading"):getChildByName("panel_press"):getChildByName("loading_bar")
	local number = 0
	local scheduler = cc.Director:getInstance():getScheduler()
	local schedulerID = nil
	local function callBack()
		loadingBar:setPercent(number)
		number = number + 1
		if(number == 100) then
			-- 停止定时器
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)
			-- -- 移除加载层
			-- local act = cc.FadeOut:create(0.5)
			-- local function call()
			-- 	self.waitingView:removeFromParent()
			-- end
			-- local seq = cc.Sequence:create(act,cc.CallFunc:create(call))
			-- self.showWaitingView:runAction(seq)
			-- -- 出现主界面
			-- performWithDelay(self,function()
			-- 		self.home = require("controllers/SnakeHomeController").new()
			-- 		self:addChild(self.home)
			-- 	end,0.5)

			-- 切换场景
	        local scene = cc.TransitionFade:create(0.5,require("views/SnakeHomeScene").new(mode))
	        cc.Director:getInstance():replaceScene(scene)
		end
	end  
	schedulerID = scheduler:scheduleScriptFunc(callBack,0.01,false)  
end

return GameWaitScene