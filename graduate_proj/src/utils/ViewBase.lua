ViewBase = class("ViewBase", function(para)
	return cc.CSLoader:createNode(para.csb)
end)

function ViewBase:ctor(para)
    para = para or {}
    if para.setSize then
        self:setContentSize(para.size or display.size)
        ccui.Helper:doLayout(self)
    end
	self:setAnchorPoint(para.anchorPoint or cc.p(0.5,0.5))
	self:setPosition(para.pos or display.center)
end

return ViewBase