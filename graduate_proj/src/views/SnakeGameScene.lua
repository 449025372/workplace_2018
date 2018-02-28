local SnakeGameScene = class("SnakeGameScene",function()
		return cc.Scene:create()
	end)

function SnakeGameScene:ctor(mode)
	self.mode = mode
	self:enableNodeEvents()
end

function SnakeGameScene:onEnter()
	self.gameController = require("controllers.SnakeGameController").new(self.mode)
	self:addChild(self.gameController)
end

return SnakeGameScene