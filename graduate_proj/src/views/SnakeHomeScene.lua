local SnakeHomeScene = class("SnakeHomeScene",function()
		return cc.Scene:create()
	end)

function SnakeHomeScene:ctor()
	self:enableNodeEvents()
end

function SnakeHomeScene:onEnter()
	self.homeController = require("controllers.SnakeHomeController").new()
	self:addChild(self.homeController)
end

return SnakeHomeScene