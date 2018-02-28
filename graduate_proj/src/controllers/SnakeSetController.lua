local SnakeSetController = class("SnakeSetController",require("views.SnakeSetView"))

local enableColor = cc.c3b(0, 166, 255)
local disableColor = cc.c3b(199, 199, 199)

function SnakeSetController:ctor()
    self:enableNodeEvents()
end

function SnakeSetController:onEnter()
	self:initSetView()
	self:initTouchListener()
end

function SnakeSetController:initTouchListener()
	local mainPl = self.setView:getChildByName("panel_foot")
	local setPanel = mainPl:getChildByName("panel_set")
	local closeBtn = setPanel:getChildByName("btn_close")

	local checkBoxLeft = setPanel:getChildByName("check_left")
	local checkBoxRight = setPanel:getChildByName("check_right")
	checkBoxLeft.txt = setPanel:getChildByName("text_left")
	checkBoxRight.txt = setPanel:getChildByName("text_right")

	local img_habit = setPanel:getChildByName("img_habit")
	local img_ctrl = img_habit:getChildByName("img_ctrl")
	local img_hit = img_habit:getChildByName("img_hit")
	local pos1 = cc.p(img_ctrl:getPosition())
	local pos2 = cc.p(img_hit:getPosition())
	if cc.UserDefault:getInstance():getIntegerForKey("userHabit") == 1 then
		checkBoxLeft:setSelected(true)
		checkBoxRight:setSelected(false)
		img_ctrl:setPosition(pos1)
		img_hit:setPosition(pos2)
		checkBoxLeft.txt:setTextColor(enableColor)
		checkBoxRight.txt:setTextColor(disableColor)
	else
		checkBoxLeft:setSelected(false)
		checkBoxRight:setSelected(true)
		img_hit:setPosition(pos1)
		img_ctrl:setPosition(pos2)
		checkBoxRight.txt:setTextColor(enableColor)
		checkBoxLeft.txt:setTextColor(disableColor)
	end

	-- 操作习惯
	local function checkBoxCall(sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			if sender == checkBoxLeft then
				img_ctrl:setPosition(pos1)
				img_hit:setPosition(pos2)
				checkBoxRight:setSelected(false)
				cc.UserDefault:getInstance():setIntegerForKey("userHabit",1)
				checkBoxLeft.txt:setTextColor(enableColor)
				checkBoxRight.txt:setTextColor(disableColor)
			elseif sender== checkBoxRight then
				img_ctrl:setPosition(pos2)
				img_hit:setPosition(pos1)
				checkBoxLeft:setSelected(false)
				cc.UserDefault:getInstance():setIntegerForKey("userHabit",2)
				checkBoxRight.txt:setTextColor(enableColor)
				checkBoxLeft.txt:setTextColor(disableColor)
			end
		elseif eventType == ccui.CheckBoxEventType.unselected then
			if sender == checkBoxLeft then
				img_ctrl:setPosition(pos2)
				img_hit:setPosition(pos1)
				checkBoxRight:setSelected(true)
				cc.UserDefault:getInstance():setIntegerForKey("userHabit",2)
				checkBoxRight.txt:setTextColor(enableColor)
				checkBoxLeft.txt:setTextColor(disableColor)
			elseif sender == checkBoxRight then
				img_ctrl:setPosition(pos1)
				img_hit:setPosition(pos2)
				checkBoxLeft:setSelected(true)
				cc.UserDefault:getInstance():setIntegerForKey("userHabit",1)
				checkBoxLeft.txt:setTextColor(enableColor)
				checkBoxRight.txt:setTextColor(disableColor)
			end
		end
	end
	checkBoxLeft:addEventListener(checkBoxCall)
	checkBoxRight:addEventListener(checkBoxCall)

	---------------------------------------------------------------

	local on = 1
	local off = 2

	local effect = cc.UserDefault:getInstance():getIntegerForKey("effectStatus")	-- 音效状态
	local music = cc.UserDefault:getInstance():getIntegerForKey("musicStatus")		-- 音乐状态
	if effect == 0 then
		cc.UserDefault:getInstance():setIntegerForKey("effectStatus",1)
	end
	if music == 0 then
		cc.UserDefault:getInstance():setIntegerForKey("musicStatus",1)
	end

	local checkBoxMusic = setPanel:getChildByName("check_music")
	local checkBoxEffect = setPanel:getChildByName("check_voice")
	checkBoxMusic.icon_music = checkBoxMusic:getChildByName("icon_music")
	checkBoxEffect.icon_voice = checkBoxEffect:getChildByName("icon_voice")
	checkBoxMusic.txt = checkBoxMusic:getChildByName("text_music_on")
	checkBoxEffect.txt = checkBoxEffect:getChildByName("text_voice_off")

	-- 音乐和音效
	local function checkBoxMusicCall(sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			if sender == checkBoxMusic then
				cc.UserDefault:getInstance():setIntegerForKey("musicStatus",on)
				checkBoxMusic.icon_music:setPositionX(16)
				checkBoxMusic.txt:setString("开启")
				checkBoxMusic.txt:setPositionX(86)
			elseif sender == checkBoxEffect then
				checkBoxEffect.icon_voice:setPositionX(16)
				cc.UserDefault:getInstance():setIntegerForKey("effectStatus",on)
				checkBoxEffect.txt:setString("开启")
				checkBoxEffect.txt:setPositionX(86)
			end
		elseif eventType == ccui.CheckBoxEventType.unselected then
			if sender == checkBoxMusic then
				cc.UserDefault:getInstance():setIntegerForKey("musicStatus",off)
				checkBoxMusic.icon_music:setPositionX(127)
				checkBoxMusic.txt:setString("关闭")
				checkBoxMusic.txt:setPositionX(57)
			elseif sender == checkBoxEffect then
				checkBoxEffect.icon_voice:setPositionX(127)
				cc.UserDefault:getInstance():setIntegerForKey("effectStatus",off)
				checkBoxEffect.txt:setString("关闭")
				checkBoxEffect.txt:setPositionX(57)
			end
		end
	end
	
	checkBoxMusic:addEventListener(checkBoxMusicCall)
	checkBoxEffect:addEventListener(checkBoxMusicCall)

	--退出
	local function back()
        -- 切换场景
        local scene = cc.TransitionFade:create(0.5,require("views/SnakeHomeScene").new())
        cc.Director:getInstance():replaceScene(scene)
	end
	closeBtn:addTouchEventListener(back)
end

return SnakeSetController