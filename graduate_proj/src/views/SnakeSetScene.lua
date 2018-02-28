local SnakeSetScene = class("SnakeSetScene",function()
		return cc.Scene:create()
	end)

function SnakeSetScene:ctor()
	self:enableNodeEvents()
end

function SnakeSetScene:onEnter()
	self.setView = require("controllers.SnakeSetController").new()
	self:addChild(self.setView)
end

return SnakeSetScene