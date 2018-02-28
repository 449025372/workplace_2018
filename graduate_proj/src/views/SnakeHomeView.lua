local SnakeHomeView = class("SnakeHomeView",function()
		return cc.Layer:create()
	end)

-- 初始化主界面
function SnakeHomeView:initHomeView()
	-- csb
	local para = {}
	para.csb = "game/HomeScene.csb"
	para.setSize = true
	self.homeView = ViewBase.new(para)
	self:addChild(self.homeView)

	-- 昵称
	self.nickName = self.homeView:getChildByName("panel_main"):getChildByName("panel_infor"):getChildByName("nickname"):setString(cc.UserDefault:getInstance():getStringForKey("name"))

	-- 金币
	self.coinLabel = self.homeView:getChildByName("panel_main"):getChildByName("panel_top"):getChildByName("gold_num_coin")
	self.coinLabel:setString(cc.UserDefault:getInstance():getIntegerForKey("coin"))

	-- 按钮表
	self.btns = {}
	-- 规则
	self.btn_rule = self.homeView:getChildByName("panel_main"):getChildByName("panel_top"):getChildByName("btn_rule")
	self.btn_rule:setScale(E.scale.x)
	-- 设置
	self.btn_set = self.homeView:getChildByName("panel_main"):getChildByName("panel_top"):getChildByName("btn_set")
	self.btn_set:setScale(E.scale.x)
	-- 返回
	self.btn_back = self.homeView:getChildByName("panel_main"):getChildByName("panel_top"):getChildByName("btn_back")
	self.btn_back:setScale(E.scale.x)
	-- 无尽模式
	self.btn_game_type_1 = self.homeView:getChildByName("panel_main"):getChildByName("game_type_1")
	self.btn_game_type_1:setScale(E.scale.x)
	-- 限时模式
	self.btn_game_type_2 = self.homeView:getChildByName("panel_main"):getChildByName("game_type_2")
	self.btn_game_type_2:setScale(E.scale.x)
	-- 衣柜
	self.btn_skin = self.homeView:getChildByName("panel_main"):getChildByName("btn_skin")
	self.btn_skin:setScale(E.scale.x)
	table.insert(self.btns,self.btn_rule)
	table.insert(self.btns,self.btn_set)
	table.insert(self.btns,self.btn_back)
	table.insert(self.btns,self.btn_game_type_1)
	table.insert(self.btns,self.btn_game_type_2)
	table.insert(self.btns,self.btn_skin)
end

-- 初始化UserDefault
function SnakeHomeView:initUserDefault()
	local userDefault = cc.UserDefault:getInstance()
	-- 皮肤
	local skinID = userDefault:getIntegerForKey("skinID")
	if(skinID == 0) then
		skinID = 1
		userDefault:setIntegerForKey("skinID",skinID)
	end
	-- 玩家昵称
	local name = userDefault:getStringForKey("name")
	if(name == "") then
		userDefault:setStringForKey("name","汤姆斯陈独秀")
		SnakeCfg.name = userDefault:getStringForKey("name")
	end
	-- 玩家金币
	local coin = userDefault:getIntegerForKey("coin")
	if(coin == 0) then
		coin = 0
		userDefault:setIntegerForKey("coin",coin)
	end
	-- 操作习惯
	local habit = userDefault:getIntegerForKey("userHabit")
	if(habit == 0) then
		userDefault:setIntegerForKey("userHabit",1)
	end	
	-- 音效状态
	local effect = userDefault:getIntegerForKey("effectStatus")
	if(effect == 0) then
		userDefault:setIntegerForKey("effect",1)
	end		
	-- 音乐状态
	local music = userDefault:getIntegerForKey("musicStatus")
	if(music == 0) then
		userDefault:setIntegerForKey("music",1)
	end
	-- 皮肤购买状态
	userDefault:setBoolForKey("skin1_isBuy",true)
end

return SnakeHomeView