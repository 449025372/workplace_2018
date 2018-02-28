local SnakeSkinScene = class("SnakeSkinScene",function()
		return cc.Scene:create()
	end)

function SnakeSkinScene:ctor()
	self:enableNodeEvents()
end

function SnakeSkinScene:onEnter()
	self.skinView = require("controllers.SnakeSkinController").new()
	self:addChild(self.skinView)
end

return SnakeSkinScene