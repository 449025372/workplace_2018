local SnakeSetView = class("SnakeSetView",function()
		return cc.Layer:create()
	end)

function SnakeSetView:initSetView()
	-- csb
	local para = {}
	para.csb = "game/SetScene.csb"
	para.setSize = true
	self.setView = ViewBase.new(para)
	self:addChild(self.setView)
end

return SnakeSetView