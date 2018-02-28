local SnakeRuleScene = class("SnakeRuleScene",function()
		return cc.Scene:create()
	end)

function SnakeRuleScene:ctor()
	self:enableNodeEvents()
end

function SnakeRuleScene:onEnter()
	self.ruleView = require("controllers.SnakeRuleController").new()
	self:addChild(self.ruleView)
end

return SnakeRuleScene