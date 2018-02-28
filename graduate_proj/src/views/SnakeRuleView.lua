local SnakeRuleView = class("SnakeRuleView",function()
		return cc.Layer:create()
	end)

function SnakeRuleView:initRuleView()
	-- csb
	local para = {}
	para.csb = "game/RuleScene.csb"
	para.setSize = true
	self.ruleView = ViewBase.new(para)
	self:addChild(self.ruleView)

	self.page = self.ruleView:getChildByName("PageView_1")
	self.dian1 = self.ruleView:getChildByName("panel_bottom"):getChildByName("dian1")
	self.dian2 = self.ruleView:getChildByName("panel_bottom"):getChildByName("dian2")
	self.dian3 = self.ruleView:getChildByName("panel_bottom"):getChildByName("dian3")
end

return SnakeRuleView