local SnakeSkinController = class("SnakeSkinController",require("views.SnakeSkinView"))

function SnakeSkinController:ctor()
	self:enableNodeEvents()
end

function SnakeSkinController:onEnter()
	self:initSkinView()
	self:initTouchListener()
end

function SnakeSkinController:initTouchListener()
	local function touch(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			-- 点击到返回
			if sender == self.backBtn then
                -- 切换场景
                local scene = cc.TransitionFade:create(0.5,require("views.SnakeHomeScene").new())
                cc.Director:getInstance():replaceScene(scene)    
			end
			-- 点击到商店皮肤
			for i,v in pairs(self.skinItems) do
				if sender == v then
					self:skinItemClick(sender)
				end
			end
			-- 点击商店皮肤弹出对话框的按钮事件
			if sender == self.buyBtn then
				-- 判断所持金币能否购买
				-- 可以
				if cc.UserDefault:getInstance():getIntegerForKey("coin") >= self.buyBtn.data.price then
					-- 扣除金币
					local curCoin = cc.UserDefault:getInstance():getIntegerForKey("coin") - self.buyBtn.data.price
					cc.UserDefault:getInstance():setIntegerForKey("coin",curCoin)
					self.coinText:setString(cc.UserDefault:getInstance():getIntegerForKey("coin"))

					-- 存储购买
					local str = string.format("skin%d_isBuy",self.buyBtn.data.id)
					cc.UserDefault:getInstance():setBoolForKey(str,true)
					self.buyBtn.data.isbuy = true

			        local haveBtn = self.skinItems[self.buyBtn.data.id]:getChildByName("btn_have")
			        local setText = haveBtn:getChildByName("btn_text")
			        local buyText = haveBtn:getChildByName("diamond_img")
			        buyText:setVisible(false)
			        setText:setVisible(true)
			        self.buyDialog:setVisible(false)
			        local str_skinName = string.format("购买成功！恭喜您获得了了%s皮肤!",self.buyBtn.data.skinName)
			        print("xxxxxxxxxxxxxxxxx",str_skinName)
			        Dialog:showTip(self,str_skinName)
				-- 不可以
				else
					self.buyDialog:setVisible(false)
					Dialog:showTip(self,"对不起，您的金币不足！快去玩两把游戏吧！")
				end
			elseif sender == self.closeBuyDialogBtn then
				self.buyDialog:setVisible(false)
			end
		end
	end

	self.backBtn:addTouchEventListener(touch)
	for i,v in pairs(self.skinItems) do
		v:addTouchEventListener(touch)
	end
	self.buyBtn:addTouchEventListener(touch)
	self.closeBuyDialogBtn:addTouchEventListener(touch)
end

return SnakeSkinController