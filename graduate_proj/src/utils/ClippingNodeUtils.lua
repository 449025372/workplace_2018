--[[
-- 基于ClippingNode封装实现遮罩层
-- Author: Jacky
-- Date: 2014-11-26 9:30
]]
ClippingNodeUtils = class("ClippingNodeUtils")
--[[
添加editBox输入框
【参数说明】
parent:原输入框的父节点
old_com 原输入文本框
para：其他参数(设置了para则启用EditBox来显示，否则使用原输入文本框显示) 
（全为可选项）para = {isPassword,flag,mode,btnType,bgURL,isPlist,default,fontSize,order,len,foColor,bgColor,callBack}
	isPassword:是否密码框（自动设置flag和mode）
	flag:文本框显示模式(参数参见下面<INPUT_FLAG>)
	mode:文本框输入模式(参数参见下面<INPUT_MODE>)
	btnType: 弹出的输入键盘右下角按钮的显示文字（类型）(参数参见下面<RETURN_TYPE>)
	bgURL：文本框控件背景图（默认为登录框背景）
	isPlist: bgURL是否plist，默认不是
	fontSize: 文本大小
	foColor: 文本颜色
	default: 默认显示提示文本
	bgColor: 提示文本颜色
	order: 层叠次序（控件摆放顺序,默认与原输入控件同层）
	len: 最多允许输入长度（默认可以换行）
	callBack: 输入完成后的回调 (sender)
return：创建好的控件（已被添加到parent中）,场景结束时要在onExit中移除：ClippingNodeUtils:removeEditBox(..) (也会自动删除？)
flag 参数：<INPUT_FLAG>
cc.EDITBOX_INPUT_FLAG_PASSWORD 			设置密码框，表明输入的文本是保密的数据，任何时候都应该隐藏起来 它隐含了EDIT_BOX_INPUT_FLAG_SENSITIVE
cc.EDITBOX_INPUT_FLAG_SENSITIVE 		表明输入的文本是敏感数据， 它禁止存储到字典或表里面，也不能用来自动补全和提示用户输入。 一个信用卡号码就是一个敏感数据的例子。
cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD 这个标志的作用是设置一个提示,在文本编辑的时候，是否把每一个单词的首字母大写。
cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE 		这个标志的作用是设置一个提示,在文本编辑，是否每个句子的首字母大写。
cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_ALL_CHARACTERS 	自动把输入的所有字符大写。
mode 参数：<INPUT_MODE>
cc.EDITBOX_INPUT_MODE_ANY 				用户可以输入任何文本,包括换行符。
cc.EDITBOX_INPUT_MODE_SINGLELINE 		除了换行符以外，用户可以输入任何文本,
cc.EDITBOX_INPUT_MODE_EMAIL_ADDRESS 	允许用户输入一个电子邮件地址。
cc.EDITBOX_INPUT_MODE_NUMERIC 			允许用户输入一个整数值。
cc.EDITBOX_INPUT_MODE_PHONE_NUMBER 		允许用户输入一个电话号码。
cc.EDITBOX_INPUT_MODE_URL 				允许用户输入一个URL。
cc.EDITBOX_INPUT_MODE_DECIMAL 			允许用户输入一个实数 通过允许一个小数点扩展了kEditBoxInputModeNumeric模式
btnType 参数：<RETURN_TYPE>
cc.KEYBOARD_RETURNTYPE_DEFAULT 			弹出的键盘右下角按钮显示“确定”
cc.KEYBOARD_RETURNTYPE_DONE				弹出的键盘右下角按钮显示“完成”
cc.KEYBOARD_RETURNTYPE_SEND				弹出的键盘右下角按钮显示“发送”
cc.KEYBOARD_RETURNTYPE_SEARCH			弹出的键盘右下角按钮显示“搜索”
cc.KEYBOARD_RETURNTYPE_GO				弹出的键盘右下角按钮显示“确定”
]]
--[[example
self.a_user = ClippingNodeUtils:getEditBox(self.A_user_name_bg,self.A_username_input,{default="请输入账号",len=20,fontSize=25,foColor=cc.c3b(240,240,240)})
self.a_password = ClippingNodeUtils:getEditBox(self.A_user_password_bg,self.A_userpw_input,{default="请输入密码",isPassword=true,len=10,fontSize=25,foColor=cc.c3b(240,240,240)})
self.b_user = ClippingNodeUtils:getEditBox(self.B_user_name_bg,self.B_username_input,{default="请输入手机号",mode=cc.EDITBOX_INPUT_MODE_NUMERIC,len=11,fontSize=25,foColor=cc.c3b(238,198,121)})
self.b_ycode = ClippingNodeUtils:getEditBox(self.B_user_password_bg,self.B_userpw_input,{default="请输入验证码",mode=cc.EDITBOX_INPUT_MODE_NUMERIC,len=6,fontSize=25,foColor=cc.c3b(238,198,121)})
self.c_password1 = ClippingNodeUtils:getEditBox(self.C_user_name_bg,self.C_username_input,{default="请输入新密码",len=10,fontSize=25,foColor=cc.c3b(238,198,121)})
self.c_password2 = ClippingNodeUtils:getEditBox(self.C_user_password_bg,self.C_userpw_input,{default="请再输入一遍",len=10,fontSize=25,foColor=cc.c3b(238,198,121)})
]]
function ClippingNodeUtils:getEditBox(parent,old_com,para)
	local useNewStyle = false
	if para then useNewStyle = true end
	para = para or {}
	para.bgURL = para.bgURL or "res/bar_denglu_kuang.png"
	local new_com = nil
    -- local function editBoxTextEventHandle(strEventName,pSender)
    --     local edit = pSender
    --     local strFmt 
    --     if strEventName == "began" then
    --     	if edit.callBackBegan then edit.callBackBegan(edit) end
    --     elseif strEventName == "ended" then
    --     	old_com:setString(edit:getText())
    --         if not edit.useNewStyle then
    --         	edit:setText("")
    --         end
    --         if edit.callBack then edit.callBack(edit) end
    --     elseif strEventName == "return" then
    --     elseif strEventName == "changed" then
    --     end
    -- end
	old_com:setTouchEnabled(false)
	local size,po = old_com:getContentSize(),cc.p(old_com:getPosition())
	local imgType = ccui.TextureResType.localType
	if para.isPlist then imgType = ccui.TextureResType.plistType end
	new_com = cc.EditBox:create(size, para.bgURL, imgType)
    new_com:setPosition(po)
    if para.fontSize then
    	new_com:setFontSize(para.fontSize)
    	new_com:setPlaceholderFontSize(para.fontSize)
    else
    	if old_com.getFontSize then
    		new_com:setFontSize(old_com:getFontSize())
    		new_com:setPlaceholderFontSize(old_com:getFontSize())
    	end
    end
    if para.foColor then
    	new_com:setFontColor(para.foColor)
    	if not para.bgColor then new_com:setPlaceholderFontColor(para.foColor) end
    elseif old_com.getTextColor then
    	new_com:setFontColor(old_com:getTextColor())
    end
    if para.bgColor then
    	if not para.foColor then new_com:setFontColor(para.bgColor) end
    	new_com:setPlaceholderFontColor(para.bgColor)
    elseif old_com.getPlaceHolderColor then
    	new_com:setPlaceholderFontColor(old_com:getPlaceHolderColor())
    end
    if para.order then new_com:setLocalZOrder(para.order)
    else
    	new_com:setLocalZOrder(old_com:getLocalZOrder())
    end
    new_com:setPlaceHolder(para.default or "")
    if para.flag then new_com:setInputFlag(para.flag)
    else new_com:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE) end
    if para.mode then new_com:setInputMode(para.mode)
    else new_com:setInputMode(cc.EDITBOX_INPUT_MODE_URL) end
    if para.isPassword or (old_com.isPasswordEnabled and old_com:isPasswordEnabled()) then
	    new_com:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	    new_com:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    end
    if para.btnType then new_com:setReturnType(para.btnType)
    else new_com:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE) end
    if para.len then new_com:setMaxLength(para.len) end
    if para.callBack and type(para.callBack) == "function" then new_com.callBack = para.callBack end
    new_com.useNewStyle = useNewStyle
	--new_com:registerScriptEditBoxHandler(editBoxTextEventHandle)
	new_com:setTouchEnabled(true)
	parent:addChild(new_com)
    if useNewStyle then old_com:setVisible(false) end
    return new_com
end

function ClippingNodeUtils:removeEditBox(box)
	if 1 then return end
	if box then
		box:unregisterScriptEditBoxHandler()
	end
end

-- 生成全屏蒙版用于阴影效果
function ClippingNodeUtils:initScreenShadow(color)
	local para = {
		startW = 0,
		startH = 0,
		width = display.width,
		height = display.height,
		colour = color or cc.c4f(0, 0, 0, 0.8)
	}
	local shadow = ClippingNodeUtils:createRectangleStencil(para)
	return shadow
end
-- 创建可裁剪的节点用于指定区域显示
function ClippingNodeUtils:createClippingNode(size, pos)
	local clipper = cc.ClippingNode:create()
	clipper.size = size
	clipper:setContentSize(size)
	clipper:setAnchorPoint(cc.p(0,0))
	if pos then clipper:setPosition(pos) end
	return clipper
end
-- 创建矩形区域
function ClippingNodeUtils:createRectangleStencil(para)
	local stencil = cc.DrawNode:create()
	local rectanglePoints = {
		cc.p(para.startW, para.startH),
		cc.p(para.width, para.startH),
		cc.p(para.width, para.height),
		cc.p(para.startW, para.height)
	}
	stencil:drawPolygon(rectanglePoints, 4, para.colour, 0, para.colour)
	return stencil
end	

-- 创建圆形区域
function ClippingNodeUtils:createCircleStencil(para)
	local stencil = cc.DrawNode:create()
	stencil:drawSolidCircle(cc.p(0,0),para.radius,360,para.pointsNum,1,1,para.colour)
	-- local circlePoints = {}
	-- for i = 1,para.pointsNum do
	-- 	local radian = i * para.angle
	-- 	local x = para.radius * math.cos(radian)
	-- 	local y = para.radius * math.sin(radian)
	-- 	circlePoints[i] = cc.p(x,y)
	-- end
	-- 由drawPolygon多边形间接实现圆形遮罩
	-- stencil:drawPolygon(circlePoints, para.pointsNum, para.colour, 0, para.colour)
	return stencil
end

--[[创建圆形图片
	parent 父节点
	nodeOra 图片精灵重构
	poNum 圆形精细度（数值越大越圆，同时处理效率越低）
	margin 环边距(半径缩小的像素)（需要缩小的大小，默认0  如果设为2 则半径缩小2像素）
	return:
	node：可以操纵的处于遮罩中的源对象

	例程：
    local head_img = self.userPanel:getChildByName("head_icon"):getChildByName("avater_bg")     -- 传入的对象可以是sprite或imageview
    local cpNode,node = ClippingNodeUtils:createCircle(head_img,100,2)  -- imageview,精细度,缩小图片多大
    self.userPanel:getChildByName("head_icon"):addProtectedChild(cpNode) -- 将处理好的遮罩对象添加到父节点
    self.roleImage = node  -- 返回的对象可以被操纵，该对象位于遮罩中 self.roleImage:loadTexture
]]
function ClippingNodeUtils:createCircle(parent,nodeOra,poNum,margin,maskImage,maskScale,maskPy)
	local node = nodeOra:clone()
	nodeOra:setVisible(false)
	local size = node:getContentSize()
	local pox,poy = node:getPosition()
	local ax,ay = node:getAnchorPoint()
	-- 取较小边为半径
	local cRadius = (size.width < size.height and size.width or size.height) / 2
	margin = margin or 0
	cRadius = cRadius - margin
	poNum = poNum or 50
	local cAngle = math.rad(360/poNum)
	local stencil = self:createCircleStencil({
			pointsNum = poNum,
			radius = cRadius,
			angle = cAngle,
			colour = cc.c4f(0,0,0,0),
			})
	local cpNode = self:createClippingNode(size,cc.p(pox,poy))
	cpNode:setStencil(stencil)
	cpNode:setInverted(false)
	node:setAnchorPoint(0.5,0.5)
	node:setPosition(0,0)
	cpNode:addChild(node)
	cpNode:setPosition(cc.p(pox,poy))
	parent:setClippingType(1)
	parent:setContentSize(size.width+margin,size.height+margin)
	parent:addChild(cpNode)
	-- parent:getTexture():setAntiAliasTexParameters()
	if maskImage then
		maskScale = maskScale or 0.96
		if type(maskPy) == "number" then
			maskPy = cc.p(maskPy,maskPy)
		end
		maskPy = maskPy or cc.p(-0.1,-0.1)
		local po = cc.p(size.width / 2 + maskPy.x,size.height / 2 + maskPy.y)
		maskImage:removeFromParent(false)
		parent:addChild(maskImage)
		maskImage:setPosition(po)
		maskImage:setScale(maskScale)
	end
	return node
end
-- 使用图片模版裁切图片
-- selfArea自定义裁切区域
function ClippingNodeUtils:createMaskedSprite(srcObj, maskObj, selfArea)
	local srcSize = srcObj:getContentSize()
	local maskSize = maskObj:getContentSize()
	local rt = cc.RenderTexture:create(srcSize.width, srcSize.height, kCCTexture2DPixelFormat_RGBA8888)

	maskObj:setPosition(cc.p(selfArea.width, selfArea.height) or cc.p(srcSize.width * 0.5, srcSize.height * 0.5))
	srcObj:setPosition(cc.p(srcSize.width * 0.5, srcSize.height * 0.5))

	maskObj:setBlendFunc(cc.blendFunc(GL_ONE, GL_ZERO))
	srcObj:setBlendFunc(cc.blendFunc(GL_DST_ALPHA, GL_ZERO))
	rt:begin()
	maskObj:visit()
	srcObj:visit()
	rt:endToLua()

	local retval = cc.Sprite:createWithTexture(rt:getSprite():getTexture())
	retval:setAnchorPoint(cc.p(0, 0))
	retval:setFlippedY(true)
	return retval
end

--创建椭圆形遮罩
function ClippingNodeUtils:createCStencil(parent,nodeOra,image,fromFile,maskImage,maskScale,maskPy)
	--parent 父节点 nodeOra:new好的原型图片节点;image:模板图片
	local node = nodeOra:clone()
	nodeOra:setVisible(false)
	local size = node:getContentSize()
	local pox,poy = node:getPosition()
	local ax,ay = node:getAnchorPoint()
	local stencil = nil
	if fromFile then
		stencil = cc.Sprite:create(image)
	else
		stencil = cc.Sprite:createWithSpriteFrameName(image)
		local scale = size.width / stencil:getContentSize().width
		stencil:setScale(scale)-- 1.88
	end
	local cpNode = self:createClippingNode(size,cc.p(pox,poy)) -- cc.p(po.x+size.width/2,po.y+size.height/2)
	cpNode:setInverted(false);--设置显示被裁剪的部分，还是显示裁剪
    cpNode:setAlphaThreshold(0.5);--设置绘制底板的Alpha值为0
	cpNode:setStencil(stencil)
	node:setAnchorPoint(0.5,0.5)
	node:setPosition(0,0)
	cpNode:addChild(node)
	cpNode:setPosition(cc.p(pox,poy))
	parent:setClippingType(1)
	parent:addChild(cpNode,2)
	if maskImage then
		maskScale = maskScale or 0.96
		if type(maskPy) == "number" then
			maskPy = cc.p(maskPy,maskPy)
		end
		maskPy = maskPy or cc.p(-0.1,-0.1)
		local po = cc.p(size.width / 2 + maskPy.x,size.height / 2 + maskPy.y)
		maskImage:removeFromParent(false)
		parent:addChild(maskImage)
		maskImage:setPosition(po)
		maskImage:setScale(maskScale)
	end
	return node
end
-- 创建走马灯效果
--[[
	para.contents      一组内容
	para.delay 		   滚动延迟
	para.posY 		   Y位置
	para.parent  	   父节点
	para.zOrder 	   层级深度
	para.size 		   尺寸
	para.callBack 	   回调
]]
-- function ClippingNodeUtils:createNotableEffect(para)
-- 	local back = ccui.ImageView:create("res/uiscene/common/world_tips_back.png")
-- 	local top = ccui.ImageView:create("res/uiscene/common/world_tips_top.png")
function ClippingNodeUtils:createNotableLabel(para)
	local back = ccui.ImageView:create()
	local top = ccui.ImageView:create()
	back:setAnchorPoint(0.5,0.5)
	back:loadTexture("bg_voice_newhome.png", 1)
	-- local back2 = ccui.ImageView:create()
	-- back2:loadTexture("bg_voice_main.png", 1)
	-- back:addChild(back2)
	-- back2:setAnchorPoint(0,0)
	-- local back3 =ccui.ImageView:create() 
	-- back3:loadTexture("bg_voice_main.png", 1)
	-- back:addChild(back3)
	-- back3:setAnchorPoint(0,0)
	top:loadTexture("icon_voice.png", 1)
	if para.hideHorn then
		top:setOpacity(0)
	end
	para.contents = para.contents or {}
	local index = 1
	local showlabel = true
	if back and top and #para.contents > 0 then
		local node = self:createClippingNode(para.size)
		local width = para.size.width - 25
		if para.onClick then
			width = para.size.width - 70
		end
		local stencil = self:createRectangleStencil({
			startW = 67, -- 喇叭宽42 + 25
			startH = 0,
			width = width, -- 喇叭宽一半21 + 25
			height = para.size.height,
			colour = cc.c4f(0,0,0,0),
			})
		node.contents = para.contents
		node.index = index
		back:setScale9Enabled(true)
		-- back2:setScale9Enabled(true)
		-- back2:setContentSize(para.size)
		-- back3:setScale9Enabled(true)
		-- back3:setContentSize(para.size)
		-- top:setScale9Enabled(true)
		-- local backRect = cc.rect(150, 15, 1, 1)
		back:setContentSize(para.size)
		-- capInsets 中间部分区域对应的矩形参数
		--back:setCapInsets(cc.rect(25,25,25,25))
		-- top:setCapInsets(backRect)
		--back:setContentSize(cc.size(para.size.width, 51))
		-- top:setContentSize(cc.size(para.size.width, 30))
		print("para.remove:",para.remove,showlabel)
		local function actCall()
			local content = ""
			if para.remove then 
				content = node.contents[1]
				table.remove(node.contents, 1)
			else
				index = index + 1
				if index > #node.contents then index = 1 end
				content = node.contents[index]
			end
			if para.remove then
				if not showlabel then
					content = nil
				end
				if content then
					--local label = ccui.Text:create(content.content, "Arial", 28)
					local label = cc.Label:createWithTTF(content.content, "res/atlas_texts/YOUYUAN.TTF",28)
					if content.dwUserID ~= 0 then
						label:setColor(cc.c3b(223,55,212))
					else
						label:setColor(cc.c3b(0,219,1)) 
					end
					if content.msgtype == 105 then
                    	label:setColor(cc.c3b(255,208,65))
                	end
                	if content.msgtype == 102 then
                		if GameDataUser.shared().sevenPlayerQQTips and GameDataUser.shared().sevenPlayerQQTips ~= "" then
		                    label:setString(GameDataUser.shared().sevenPlayerQQTips)
		                end
                	end
					local labelSize = label:getContentSize()
					local actCallFunc = cc.CallFunc:create(actCall)
					local moveAct = cc.MoveTo:create(para.delay, cc.p(0, para.size.height / 2))
					local moveAct2 = cc.MoveTo:create(para.delay / 4, cc.p(- labelSize.width / 2, para.size.height / 2))
					label:setPosition(para.size.width + label:getContentSize().width / 2 + 17, para.size.height / 2) -- 喇叭偏移
					label:runAction(cc.Sequence:create(moveAct, actCallFunc, moveAct2, cc.RemoveSelf:create()))
					node:addChild(label)
					if showlabel and para.spacetime then  --spacetime时间内只显示一条动态消息
						performWithDelay(label,function()
							showlabel = true
						end,para.spacetime)
						showlabel = false
					end
				else
					if para.callBack then para.callBack() end
					node:runAction(cc.Sequence:create(cc.FadeOut:create(1), cc.RemoveSelf:create()))
					for _,v in pairs(node:getChildren()) do
						if v.runAction then
							v:runAction(cc.FadeOut:create(1))
						end
					end
					top:stopAllActions()
					back:runAction(cc.Sequence:create(cc.FadeOut:create(1), cc.RemoveSelf:create()))
					top:runAction(cc.Sequence:create(cc.FadeOut:create(1), cc.RemoveSelf:create()))
				end
			else
				--local label = ccui.Text:create(content.content, "Arial", 28)
				local label = cc.Label:createWithTTF(content.content, "res/atlas_texts/YOUYUAN.TTF",28)
				if content.dwUserID ~= 0 then
					label:setColor(cc.c3b(223,55,212))
				else
					label:setColor(cc.c3b(0,219,1)) 
				end
				if content.msgtype == 105 then
                    label:setColor(cc.c3b(255,208,65))
                end
                if content.msgtype == 102 then
            		if GameDataUser.shared().sevenPlayerQQTips and GameDataUser.shared().sevenPlayerQQTips ~= "" then
	                    label:setString(GameDataUser.shared().sevenPlayerQQTips)
	                end
            	end
				local labelSize = label:getContentSize()
				local actCallFunc = cc.CallFunc:create(actCall)
				local moveAct = cc.MoveTo:create(para.delay, cc.p(0, para.size.height / 2))
				local moveAct2 = cc.MoveTo:create(para.delay / 4, cc.p(- labelSize.width / 2, para.size.height / 2))
				label:setPosition(para.size.width + label:getContentSize().width / 2 + 17, para.size.height / 2) -- 喇叭偏移
				label:runAction(cc.Sequence:create(moveAct, actCallFunc, moveAct2, cc.RemoveSelf:create()))
				node:addChild(label)
			end
		end
		--local label = ccui.Text:create(node.contents[index].content, "Arial", 28)
		local label = cc.Label:createWithTTF(node.contents[1].content, "res/atlas_texts/YOUYUAN.TTF",28)
		-- label:setColor(cc.c3b(230,230,230))
		if node.contents[1].dwUserID ~= 0 then
			label:setColor(cc.c3b(223,55,212))
		else
			label:setColor(cc.c3b(0,219,1)) 
		end
		if node.contents[1].msgtype == 105 then
            label:setColor(cc.c3b(255,208,65))
        end
        if node.contents[1].msgtype == 102 then
    		if GameDataUser.shared().sevenPlayerQQTips and GameDataUser.shared().sevenPlayerQQTips ~= "" then
                label:setString(GameDataUser.shared().sevenPlayerQQTips)
            end
    	end
		local labelSize = label:getContentSize()
		local actCallFunc = cc.CallFunc:create(actCall)
		local moveAct = cc.MoveTo:create(para.delay, cc.p(0, para.size.height / 2))
		local moveAct2 = cc.MoveTo:create(para.delay / 4, cc.p(- labelSize.width / 2, para.size.height / 2))
		label:setPosition(para.size.width + label:getContentSize().width / 2 + 17, para.size.height / 2)
		label:runAction(cc.Sequence:create(moveAct, actCallFunc, moveAct2, cc.RemoveSelf:create()))
		if para.remove then table.remove(node.contents, 1) end

		if showlabel and para.spacetime then  --spacetime时间内只显示一条动态消息
			performWithDelay(label,function()
				showlabel = true
			end,para.spacetime)
			showlabel = false
		end

		back:setAnchorPoint(cc.p(0,0))
		top:setAnchorPoint(cc.p(0,0))
		local scale = para.scale or 1
		if para.scale then
			back:setScale(scale)
			node:setScale(scale)
			top:setScale(scale)
		end
		local cx = (display.width - para.size.width * scale) / 2
		if para.diffx then cx = cx + para.diffx end
		node:setPosition(cx, para.posY)
		back:setPosition(cx, para.posY)
		top:setPosition(cx + 16, para.posY + 4) -- 喇叭位置偏移
		local action = function(t,i,x,y)
			local sy = y or x
			if i == 0 then return cc.ScaleTo:create(t,x * scale,sy * scale) end
			if i == 1 then return cc.DelayTime:create(t) end
		end
		top:runAction(
			cc.RepeatForever:create(
				cc.Sequence:create(
					cc.DelayTime:create(2 + math.random(3,5)),					
					action(0.1,0,1.1),action(0.1,0,1),action(0.4,1),action(0.1,0,1.1),
					action(0.1,0,1),action(0.1,1),action(0.1,0,1.1),action(0.1,0,1))))
		node:setStencil(stencil)
		node:addChild(label)

		if para.onClick and type(para.onClick) == "function" then -- 添加触摸事件
	        back:setTouchEnabled(true)
	        back:addTouchEventListener(function(sender,eventType)
	            if eventType == ccui.TouchEventType.ended then
	                addAounds(allmusicsounds["buttonPress"])
	                para.onClick()
	            end
	        end)

	        local penImg = cc.Sprite:createWithSpriteFrameName("pen.png")
	        back:addChild(penImg)
	        penImg:setAnchorPoint(1,0.5)
	        penImg:setPosition(para.size.width-10,para.size.height*0.5)
		end

		if para.parent then
			para.parent:addChild(back, para.zOrder or 20)
			para.parent:addChild(node)
			para.parent:addChild(top, para.zOrder or 20)
			if para.zOrder then
				node:setLocalZOrder(para.zOrder)
			end
		end
		return node,back,top
	end
end

function ClippingNodeUtils:createRollingLabel(para)--创建上下翻滚的走马灯控件
	local back = ccui.ImageView:create()
	local top = ccui.ImageView:create()
	back:loadTexture("bg_voice_main.png", 1)
	top:loadTexture("icon_voice.png", 1)
	para.contents = para.contents or {}
	local index = 1
	if back and top and #para.contents > 0 then
		local node = self:createClippingNode(para.size)
		local stencil = self:createRectangleStencil({
			startW = 67, -- 喇叭宽42 + 25
			startH = 0,
			width = para.size.width - 25, -- 喇叭宽一半21 + 25
			height = para.size.height,
			colour = cc.c4f(0,0,0,0),
			})
		node.contents = para.contents
		back:setScale9Enabled(true)
		-- top:setScale9Enabled(true)
		-- local backRect = cc.rect(150, 15, 1, 1)
		back:setContentSize(para.size)
		-- capInsets 中间部分区域对应的矩形参数
		back:setCapInsets(cc.rect(30,25,12,1))
		-- top:setCapInsets(backRect)
		back:setContentSize(cc.size(para.size.width, 51))
		-- top:setContentSize(cc.size(para.size.width, 30))
		back:setVisible(false)
		back:setScaleX(0.01)
		node:setVisible(false)
		node:setScaleX(0.01)
		top:setVisible(false)

		local scale = para.scale or 1
		if para.scale then
			back:setScale(scale)
			node:setScale(scale)
			top:setScale(scale)
		end
		local cx = (display.width - para.size.width * scale) / 2
		if para.diffx then cx = cx + para.diffx end
		local action = function(t,i,x,y)
			local sy = y or x
			if i == 0 then return cc.ScaleTo:create(t,x * scale,sy * scale) end
			if i == 1 then return cc.DelayTime:create(t) end
		end
		back:runAction(cc.Sequence:create(cc.CallFunc:create(function(sender)sender:setVisible(true)end),cc.EaseBackOut:create(action(0.5,0,1))))
		node:runAction(cc.Sequence:create(cc.CallFunc:create(function(sender)sender:setVisible(true)end),action(0.5,0,1)))
		top:runAction(cc.Sequence:create(action(0.6,1),cc.CallFunc:create(function(sender) sender:setVisible(true) end)))
		top:runAction(
			cc.RepeatForever:create(
				cc.Sequence:create(
					cc.DelayTime:create(2 + math.random(3,5)),					
					action(0.1,0,1.1),action(0.1,0,1),action(0.4,1),action(0.1,0,1.1),
					action(0.1,0,1),action(0.1,1),action(0.1,0,1.1),action(0.1,0,1))))
		local function actCall()
			--table.remove(node.contents, 1)
			index = index + 1
			if index > #node.contents then index = 1 end
			local content = node.contents[index]

			--if content then
				local label = ccui.Text:create(content, "Arial", para.fontsize)
				label:setAnchorPoint(cc.p(0.476,0.5))
				-- label:setColor(cc.c3b(230,230,230))
				local labelSize = label:getContentSize()
				local actCallFunc = cc.CallFunc:create(actCall)
				local movedelay = cc.DelayTime:create(para.delay/3.5)
				local beformove = cc.FadeOut:create(0.01)
				local moveAct = cc.Spawn:create(cc.MoveTo:create(para.delay / 6, cc.p(para.size.width/2, para.size.height / 2)),cc.FadeIn:create(para.delay / 6))
				local showdelay = cc.DelayTime:create(para.delay/3)
				local moveAct2 = cc.Spawn:create(cc.MoveTo:create(para.delay / 6, cc.p(para.size.width/2, para.size.height+20)),cc.FadeOut:create(para.delay / 6))
				label:setPosition(para.size.width/2, -para.size.height) -- 喇叭偏移
				label:runAction(cc.Sequence:create(movedelay,beformove,moveAct, actCallFunc,showdelay,moveAct2, cc.RemoveSelf:create()))
				node:addChild(label)
			-- else
			-- 	if para.callBack then para.callBack() end
			-- 	node:runAction(cc.Sequence:create(cc.FadeOut:create(1), cc.RemoveSelf:create()))
			-- 	for _,v in pairs(node:getChildren()) do
			-- 		if v.runAction then
			-- 			v:runAction(cc.FadeOut:create(1))
			-- 		end
			-- 	end
			-- 	top:stopAllActions()
			-- 	back:runAction(cc.Sequence:create(cc.FadeOut:create(1), cc.RemoveSelf:create()))
			-- 	top:runAction(cc.Sequence:create(cc.FadeOut:create(1), cc.RemoveSelf:create()))
			--end
		end
		local label = ccui.Text:create(node.contents[index], "Arial", para.fontsize)		
		label:setAnchorPoint(cc.p(0.476,0.5))
		-- label:setColor(cc.c3b(230,230,230))
		local labelSize = label:getContentSize()
		local actCallFunc = cc.CallFunc:create(actCall)
		local movedelay = cc.DelayTime:create(1.2)
		local beformove = cc.FadeOut:create(0.01)
		local moveAct = cc.Spawn:create(cc.MoveTo:create(para.delay / 6, cc.p(para.size.width/2, para.size.height / 2)),cc.FadeIn:create(para.delay / 6))
		local showdelay = cc.DelayTime:create(para.delay/3)
		local moveAct2 = cc.Spawn:create(cc.MoveTo:create(para.delay / 6, cc.p(para.size.width/2, para.size.height+20)),cc.FadeOut:create(para.delay / 6))
		label:setPosition(para.size.width/2, para.size.height / 2)
		label:setOpacity(0)
		label:runAction(cc.Sequence:create(action(0.3,1), moveAct, actCallFunc,showdelay,moveAct2, cc.RemoveSelf:create()))

		back:setAnchorPoint(cc.p(0,0))
		top:setAnchorPoint(cc.p(0,0))
		node:setAnchorPoint(cc.p(0.5,0))
		back:setAnchorPoint(cc.p(0.5,0))
		node:setPosition(display.cx, para.posY)
		back:setPosition(display.cx, para.posY)
		top:setPosition(cx + 16, para.posY + 4) -- 喇叭位置偏移
		node:setStencil(stencil)
		node:addChild(label)

		if para.onClick and type(para.onClick) == "function" then -- 添加触摸事件
	        back:setTouchEnabled(true)
	        back:addTouchEventListener(function(sender,eventType)
	            if eventType == ccui.TouchEventType.ended then
	                addAounds(allmusicsounds["buttonPress"])
	                para.onClick()
	            end
	        end)
		end

		if para.parent then
			para.parent:addChild(back, para.zOrder or 20)
			para.parent:addChild(node, para.zOrder or 20)
			para.parent:addChild(top, para.zOrder or 20)
		end
		return node,back,top
	end
end