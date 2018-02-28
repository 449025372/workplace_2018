local SnakeRuleController = class("SnakeRuleController",require("views.SnakeRuleView"))

function SnakeRuleController:ctor()
	self:enableNodeEvents()
end

function SnakeRuleController:onEnter()
	self:initRuleView()
	self:initTouchListener()
end

function SnakeRuleController:initTouchListener()
 	local page = self.ruleView:getChildByName("PageView_1")
    local panel_bottom = self.ruleView:getChildByName("panel_bottom")
	local backBtn = panel_bottom:getChildByName("btn_back")
	local dian1 = panel_bottom:getChildByName("dian1")
	local dian2 = panel_bottom:getChildByName("dian2")
	local dian3 = panel_bottom:getChildByName("dian3")
	local color1 = cc.c3b(0,165,255)
	local color2 = cc.c3b(255,255,255)

	-- pageview滑动监听事件
 	page:addEventListener(function(sender,event)
 		if event == ccui.PageViewEventType.turning then
        	local index =  page:getCurPageIndex()
        	if index == 0 then 
	        	dian1:setColor(color1)
				dian2:setColor(color2)
				dian3:setColor(color2)
        	elseif index == 1 then  
	        	dian1:setColor(color2)
				dian2:setColor(color1)
				dian3:setColor(color2)
			elseif index == 2 then
        		dian1:setColor(color2)
				dian2:setColor(color2)
				dian3:setColor(color1)
        	end      
        end
 	end)

 	-- 返回按钮事件
	local function touch(sender,eventType)
		if sender == backBtn then
            -- 切换场景
            local scene = cc.TransitionFade:create(0.5,require("views/SnakeHomeScene").new())
            cc.Director:getInstance():replaceScene(scene)
		end
	end
	backBtn:addTouchEventListener(touch)
end

return SnakeRuleController