local SnakeSkinView = class("SnakeSkinView",function()
		return cc.Layer:create()
	end)

function SnakeSkinView:initSkinView()
	-- csb
	local para = {}
	para.csb = "game/SkinScene.csb"
	para.setSize = true
	self.skinView = ViewBase.new(para)
	self:addChild(self.skinView)

    local mainPl = self.skinView:getChildByName("panel_skin")
    local panelTop = mainPl:getChildByName("panel_top")
    self.panelList = mainPl:getChildByName("panel_list")
    self.panelList.panleIitem = self.panelList:getChildByName("panle_item")
    self.panelList.panleIitem:setVisible(false)
 	self.backBtn = panelTop:getChildByName("btn_back")
    self.coinText = panelTop:getChildByName("text_num_coin")
    self.coinText:setString(cc.UserDefault:getInstance():getIntegerForKey("coin"))
 	local panel_list = self.panelList:getChildByName("panel_list")
 	self.ScrollView = self.panelList:getChildByName("ScrollView")
    self.scrollViewSize = self.ScrollView:getContentSize()
 	self.skinItems = {}

    self.buyDialog = self.skinView:getChildByName("black_buy")
    self.buyBtn = self.buyDialog:getChildByName("panel_buy"):getChildByName("btn_confirm")
    self.closeBuyDialogBtn = self.buyDialog:getChildByName("panel_buy"):getChildByName("btn_close")
    self.notEnoughDialog = self.skinView:getChildByName("panel_fail")
    self.buyDialog:setVisible(false)
    self.notEnoughDialog:setVisible(false)

    self:loadSkin()
end

function SnakeSkinView:loadSkin()
    local listIndex = 1
    for i,cfg in ipairs(SnakeCfg.bodys) do
        local item = self.panelList.panleIitem:clone()
        item:setName("skinName_"..listIndex)
        item.listIndex = listIndex
        item:setVisible(true)
        local text_color_size = item:getChildByName("panel_skin_name"):getChildByName("text_color_size")
        item:getChildByName("panel_skin_name"):setLocalZOrder(10)
        text_color_size:setString(cfg.skinName)
        -- text_color_size:setTextColor(userData.textXColor)
        local haveBtn = item:getChildByName("btn_have")
        haveBtn.listIndex = listIndex
        local setText = haveBtn:getChildByName("btn_text")
        local buyText = haveBtn:getChildByName("diamond_img")
        if cfg.isbuy and cfg.isbuy == true then
            buyText:setVisible(false)
            setText:setVisible(true)
        else
            buyText:setVisible(true)
            setText:setVisible(false)
            local priceText = buyText:getChildByName("price_text")
            priceText:setString(cfg.price or 100)
        end
        -- haveBtn:setScale9Enabled(true)
    	-- haveBtn:setCapInsets(cc.rect(15, 15, 15, 15))
    	-- haveBtn:setContentSize(cc.size(157, 47))
        local scaleSize = 0.5
        for i=1,3 do
            local body
            if cfg.middle and i == 3 then
                body = cc.Sprite:createWithSpriteFrameName(cfg.middle)
            else
                if type(cfg.res) == "string" then
                    body = cc.Sprite:createWithSpriteFrameName(cfg.res)
                else
                    body = cc.Sprite:createWithSpriteFrameName(cfg.res[(i - 1) % #cfg.res + 1])
                end
                if cfg.head and i == 1 then body:setVisible(false) end
            end
            body:setScale(scaleSize)
            if cfg.head then
                if cfg.middle then
                    body:setPosition(110,15+40*(i - 1))
                else
                    body:setPosition(110,5+40*i)
                end
            else
                body:setPosition(110,40+40*i)
            end
            item:addChild(body,0)
        end
        if not cfg.head then
            local eye = cc.Sprite:createWithSpriteFrameName(SnakeCfg.eye)
            eye:setScale(scaleSize)
            eye:setPosition(110,50+40*3)
            item:addChild(eye,0)
        else
            local eye = cc.Sprite:createWithSpriteFrameName(cfg.head)
            eye:setScale(scaleSize)
            eye:setPosition(110,55+40*3)
            item:addChild(eye,0)
        end
        if i % 3 == 0 then
            item:setPosition(cc.p(self.scrollViewSize.width* (0.15 + (0.35* 2)),1132 - (0 + 280*(math.ceil(i/3)-1))))
        else
            item:setPosition(cc.p(self.scrollViewSize.width* (0.15 + (0.35* ((i%3)-1))),1132 - (0 + 280*(math.ceil(i/3)-1))))
        end
        
        self.ScrollView:addChild(item)
        table.insert(self.skinItems,item)
        item.data = cfg
        haveBtn.data = cfg
        listIndex = listIndex + 1
    end

    for _,item in pairs(self.skinItems) do
        local imageName = ""
        local str = ""
        local outlineColor 
        local textColor 
        local itemIndex  = tonumber(E:split(item:getName(),"_")[2])
        print("itemIndex",itemIndex,SnakeCfg.currentSkin)
        if itemIndex  == SnakeCfg.currentSkin then
            imageName = "btn_red_shop_tcs.png"
            str = "已装扮"
            outlineColor = cc.c3b(255,142,141)
            textColor = cc.c3b(182,25,25)
            SnakeCfg.currentSkin = itemIndex
            cc.UserDefault:getInstance():setIntegerForKey("skinID",itemIndex)
        else
            imageName = "btn_green_shop_tcs.png"
            outlineColor = cc.c3b(170,252,92)
            textColor = cc.c3b(51,131,8)
            str = "装扮"
        end
        -- item:setBackGroundImage(imageName,1)
        item:getChildByName("btn_have"):loadTextures(imageName,imageName,imageName,1)
        local btnText = item:getChildByName("btn_have"):getChildByName("btn_text")
        btnText:setString(str)
        btnText:enableOutline(outlineColor)
        btnText:setTextColor(textColor)
    end
end

function SnakeSkinView:skinItemClick(sender)
    -- self:selectItem(tonumber(E:split(sender:getName(),"_")[2]))
    print(sender.data.skinName,sender.data.isbuy)
    if sender.data.isbuy == true then
        self:selectItem(sender.listIndex)
    else
        self:showBuyDialog(sender.data)
    end
end

function SnakeSkinView:showBuyDialog(data)
    local price = data.price or 100

    self.buyDialog:setVisible(true)
    self.buyBtn.data = data
    local tipsText = self.buyDialog:getChildByName("panel_buy"):getChildByName("text_confirm")
    tipsText:setString(string.format("确定要花%d金币购买%s皮肤吗？", price, data.skinName))
    local coinImg = self.buyDialog:getChildByName("panel_buy"):getChildByName("btn_confirm"):getChildByName("icon_coin")
    local numText = self.buyDialog:getChildByName("panel_buy"):getChildByName("btn_confirm"):getChildByName("text_num")
    coinImg:loadTexture("icon_coin_tcs.png", 1)
    numText:setString(price)
end

function SnakeSkinView:selectItem(selectIndex)
    for _,item in pairs(self.skinItems) do
        local imageName = ""
        local str = ""
        local outlineColor 
        local textColor 
        local itemIndex  = tonumber(E:split(item:getName(),"_")[2])
        print("itemIndex",itemIndex,selectIndex)
        if itemIndex  == selectIndex then
            imageName = "btn_red_shop_tcs.png"
            str = "已装扮"
            outlineColor = cc.c3b(255,142,141)
            textColor = cc.c3b(182,25,25)
            SnakeCfg.currentSkin = itemIndex
            cc.UserDefault:getInstance():setIntegerForKey("skinID",itemIndex)
        else
            imageName = "btn_green_shop_tcs.png"
            outlineColor = cc.c3b(170,252,92)
            textColor = cc.c3b(51,131,8)
            str = "装扮"
        end
        -- item:setBackGroundImage(imageName,1)
        item:getChildByName("btn_have"):loadTextures(imageName,imageName,imageName,1)
        local btnText = item:getChildByName("btn_have"):getChildByName("btn_text")
        btnText:setString(str)
        btnText:enableOutline(outlineColor)
        btnText:setTextColor(textColor)
    end
end

return SnakeSkinView