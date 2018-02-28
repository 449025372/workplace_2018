Dialog = class("Dialog")

function Dialog:showTip(parent,str)
	print("Dialog ",str)

	local tip = cc.Label:createWithTTF(str, "font/YOUYUAN.TTF", 30)
	tip:setTextColor(cc.c3b(0,0,0))
	tip:setPosition(display.center)
	parent:addChild(tip,1000)

	local function call()
		tip:removeFromParent()
		tip = nil
	end
	local fade = cc.FadeOut:create(1.0)
	local move = cc.MoveBy:create(2.0,cc.p(0,display.height))
	local spawn = cc.Spawn:create(fade,move)
	-- local move = cc.MoveBy:create(5,cc.p(0,display.height / 2))
	-- local spawn = cc.Spawn:create(fade,move)
	local seq = cc.Sequence:create(cc.DelayTime:create(1),spawn,cc.CallFunc:create(call))
	tip:runAction(seq)
end

if not _G["Dialog"] then _G["Dialog"] = Dialog.new() end
return _G["Dialog"]