Engine = class("Engine")

Engine.scale = nil    -- 设计尺寸比例转换尺（按画面显示效果，有可能画面超过屏幕大小）
Engine.scalec = nil   -- 设计尺寸比例转换尺（按屏幕实际效果）
Engine.cenPo = nil     -- 屏幕上显示的坐标（眼见坐标）
Engine.gameCenPo = nil -- 包括超出屏幕的部分算起的坐标（实际坐标）
Engine.overWidth = false -- 是否横向超出屏幕范围
Engine.leftDt = nil
Engine.DB = nil -- UserDefault

function Engine:ctor()
    -- math.newrandomseed()
    local ok, socket = pcall(function()
        return require("socket")
    end)
    if ok then
        -- 如果集成了 socket 模块，则使用 socket.gettime() 获取随机数种子
        math.randomseed(socket.gettime())
    else
        math.randomseed(os.time())
    end
    math.random()
    math.random()
    math.random()
    math.random()
end

-- split 分解字符串
function Engine:split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end
-- concat 拼接字符串
function Engine:concat(tb,delimiter)
	return table.concat(tb,delimiter)
end
-- 分解成多行  每行保证相同的长度(文本,行数,最小原子长度(汉字占3位))
function Engine:splitLine(str,lineNum,minWidthNum)
    if str == nil or lineNum == nil then
        return
    end
    local ret = nil
    local sStr = str
    local tCode = {}
    local tStr = {}
    local nLenInByte = #sStr
    print("长度:",nLenInByte,minWidthNum)
    if nLenInByte <= minWidthNum then return str end -- 比最小分割长度还小 就不换行了
    local nWidth = 0
    local lineWidth = nLenInByte / lineNum -- 每行的字数
    local k = 1
    for i=1,nLenInByte do
        local curByte = string.byte(sStr, i)
        local byteCount = 0;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
        local char = nil
        if byteCount > 0 then
            char = string.sub(sStr, i, i+byteCount-1)
            i = i + byteCount -1
        end
        if byteCount == 1 then
            nWidth = nWidth + 1
            table.insert(tStr,char)
            table.insert(tCode,1)
            
        elseif byteCount > 1 then
            nWidth = nWidth + 2
            table.insert(tStr,char)
            table.insert(tCode,2)
        end
         if i / lineWidth > k then
            table.insert(tStr,'\n')
            k = k + 1
            table.insert(tCode,1)
         end
    end
    local _sN = ""
    local _len = 0
    for i=1,#tStr do
        _sN = _sN .. tStr[i]
        _len = _len + tCode[i]
    end
    ret = _sN
    return ret
end
-- 文本长度具象化
function Engine:getStringLen(str)
  local len,nWidth = #str,0
  local tCode,tStr = {},{}
  for i=1,len do
    local curByte = string.byte(str, i)
    local byteCount = 0
    if curByte>0 and curByte<=127 then
        byteCount = 1
    elseif curByte>=192 and curByte<223 then
        byteCount = 2
    elseif curByte>=224 and curByte<239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    local char = nil
    if byteCount > 0 then
        char = string.sub(str, i, i+byteCount-1)
        i = i + byteCount - 1
    end
    if byteCount == 1 then
        nWidth = nWidth + 1
        table.insert(tStr,char)
        table.insert(tCode,1)
    elseif byteCount > 1 then
        nWidth = nWidth + 2
        table.insert(tStr,char)
        table.insert(tCode,2)
    end
  end
  return nWidth,tStr,tCode -- 总文字长度（全半角），文字数组，每个文字长度
end
-- 填充末端达到指定长度(按表格对齐文本函数，传入文本内容，表格中每格文本长度，填充字符（默认空白）。返回用于填充的空白)
function Engine:repFill(str,len,repChar)
  if str and type(str) == "string" and len > 0 then
    repChar = repChar or ' '
    local curLen = self:getStringLen(str)
    if curLen < len then
      return string.rep(repChar, len - curLen)
    end
  end
  return ''
end
-- 获取table内容
function Engine:tableString(tb,showIndex)
	if type(tb)~="table" then return tostring(tb) end
	local str = "{ "
	local len = table.maxn(tb)
	for ti,tValue in pairs(tb) do -- ipairs无法实现下标为字符的遍历，只能读取数字的遍历
		if showIndex then str = str .." ["..ti.."] = " end
		local tp = type(tValue)
		if tp == "table" then
			str = str..Engine:tableString(tValue,showIndex)
		elseif tp == "string" then
			-- if tp == "string" then str = str.."\"" end
			str = str..string.format("%q",tValue) -- tostring(tValue) 使用format方式可以避免恶意代码
		else
			str = str..tostring(tValue)
		end
		if ti~=len then str = str..' , ' end
	end
	str = str.." }"
	return str
end

function Engine:printTable(tb,showIndex)
	print(self:tableString(tb,showIndex))
end

--[[
    获取屏幕适配比例及适配调整位置
    keepScale 保持宽高比，适配最小比例
    可传入参数：(下面参数都可以填nil)
    containSize 需要调整的组件大小
    showSize 实际显示大小
    designSize 设计尺寸
    一般不适配宽高比的话不需要利用containSize改变位置
    return designScale(x,y) 设计比例变更,poScale(x,y) 设计比例位置偏移
]]
function Engine:getDesignScale(keepScale,containSize,showSize,designSize)
    containSize = containSize or nil
    showSize = showSize or display or cc.Director:getInstace():getWinSize()
    designSize = designSize or {width = CC_DESIGN_RESOLUTION.width,height = CC_DESIGN_RESOLUTION.height}
    local designScale = {x = showSize.width / designSize.width,y = showSize.height / designSize.height}
    local poScale = {x=0,y=0}
    -- 固定宽高比
    if keepScale then
        if designScale.x < designScale.y then
            designScale.y = designScale.x
            if containSize then poScale.y = containSize.height * (1 - designScale.y) / 2 end
        elseif designScale.x > designScale.y then
            designScale.x = designScale.y
            if containSize then poScale.x = containSize.width * (1 - designScale.x) / 2 end
        end
    else
        if designScale.y < 1 then poScale.y = containSize.height * (1 - designScale.y) / 2 end
        if designScale.x < 1 then poScale.x = containSize.width * (1 - designScale.x) / 2 end
    end
    if self.scale == nil then self.scale = {x = designScale.x,y = designScale.y} end
    return designScale,poScale
end

--[[
    所有参数都可以不填
    keepScale   缩放是否不形变
    showSize    当前显示尺寸
    designSize  设计尺寸（设计图片的尺寸）
]]
function Engine:initScale(keepScale,showSize,designSize)
    showSize = showSize or display.size
    local screenSize = display.size
    self.leftDt = cc.p((showSize.width - screenSize.width)/2,0)
    designSize = designSize or {width = CC_DESIGN_RESOLUTION.width,height = CC_DESIGN_RESOLUTION.height}
    local designScale = {x = showSize.width / designSize.width,y = showSize.height / designSize.height}
    local designSCScale = {x = screenSize.width / designSize.width,y = screenSize.height / designSize.height}
    -- print("sizex:",showSize.width,designSize.width,designScale.x,designSCScale.x)
    -- 固定宽高比
    if keepScale then
        if designScale.x < designScale.y then
            designScale.y = designScale.x
        elseif designScale.x > designScale.y then
            designScale.x = designScale.y
        end
        if designSCScale.x < designSCScale.y then
            designSCScale.y = designSCScale.x
        elseif designSCScale.x > designSCScale.y then
            designSCScale.x = designSCScale.y
        end
    end
    self.scale = {x = designScale.x,y = designScale.y}
    self.scalec = {x = designSCScale.x,y = designSCScale.y}
    self.cenPo = {x=screenSize.width/2,y=screenSize.height/2}
    self.gameCenPo = cc.p(showSize.width/2,showSize.height/2)
    local ratio = display.size.width / display.size.height
    self.overWidth = true
    if ratio <= 1.34 then self.overWidth = false end
    print("Engine:initScale => ",self.scale.x .. " : " .. self.scale.y)
end

 -- 恢复原大小(通过viewBase的ccui.Helper:doLayout设置后某些控件会变形，调用本方法修改变形控件大小)
function Engine:resumeNode(node)
    if not E.scale then E:initScale() end
    local ss,po = node:getContentSize(),cc.p(node:getPosition())
    if node.setContentSize then
      node:setContentSize(ss.width / self.scale.x,ss.height / self.scale.y)
    elseif node.setScale then
      node:setScale(1 / self.scale.x, 1 / self.scale.y)
    else
      print("无法恢复控件形变!!请检查控件类型")
    end
end

Engine.reArg = nil
Engine.reArgKss = nil
--传入设计尺寸上的位置，返回正确的实际坐标  [定位函数]
function Engine:kssPo(pox,poy)
    local po = nil
    if poy then po = cc.p(pox,poy) else po = pox end
    if self.reArgKss == nil then
      self.reArgKss = {}
      self.reArgKss.des,self.reArgKss.cur,self.reArgKss.fix = CC_DESIGN_RESOLUTION,display.size,0.26 -- 设计尺寸和当前尺寸
      self.reArgKss.desCen,self.reArgKss.curCen = cc.p(self.reArgKss.des.width / 2,self.reArgKss.des.height / 2),cc.p(self.reArgKss.cur.width / 2,self.reArgKss.cur.height / 2)
      self.reArgKss.sc = cc.p(self.reArgKss.cur.width / self.reArgKss.des.width,self.reArgKss.cur.height / self.reArgKss.des.height)
      self.reArgKss.ratio = self.reArgKss.cur.width / self.reArgKss.cur.height
      self.reArgKss.dt = (self.reArgKss.des.width - self.reArgKss.cur.width) * self.reArgKss.fix
      if self.reArgKss.ratio <= 1.34 then
        self.reArgKss.dt = (self.reArgKss.des.height - self.reArgKss.cur.height) * self.reArgKss.fix
      end
    end
    local resetPo = nil
    if self.reArgKss.ratio <= 1.34 then
      local per = math.abs(0.5 - po.y / self.reArgKss.des.height)
      resetPo = cc.p(po.x,self.reArgKss.curCen.y - (self.reArgKss.desCen.y - po.y) * self.reArgKss.sc.y + self.reArgKss.dt * per)
    else
      local per = math.abs(0.5 - po.x / self.reArgKss.des.width)
      resetPo = cc.p(self.reArgKss.curCen.x - (self.reArgKss.desCen.x - po.x) * self.reArgKss.sc.x + self.reArgKss.dt * per,po.y)
      -- print("进行坐标转换(" .. po.x .. "," .. po.y .. ") => (" .. resetPo.x .. "," .. resetPo.y .. "):")
      -- print("坐标转换公式： 当前中心点x - ( 原中心点x - 原坐标x ) × x缩放比例 + x偏移值 × x百分比")
      -- print("\n当前中心点x：" .. self.reArgKss.curCen.x .. "\n原中心点x：" .. self.reArgKss.desCen.x .. "\nx缩放比例：" .. self.reArgKss.sc.x .. "\nx偏移值：" .. self.reArgKss.dt .. "\nx百分比：" .. per)
    end
    return resetPo
end

--传入设计尺寸上的位置，返回正确的实际坐标  [定位函数]
function Engine:resumePo(pox,poy)
    local po = nil
    if poy then po = cc.p(pox,poy) else po = pox end
    if self.reArg == nil then
      self.reArg = {}
      self.reArg.des,self.reArg.cur,self.reArg.fix = CC_DESIGN_RESOLUTION,display.size,0.185 -- 设计尺寸和当前尺寸
      self.reArg.desCen,self.reArg.curCen = cc.p(self.reArg.des.width / 2,self.reArg.des.height / 2),cc.p(self.reArg.cur.width / 2,self.reArg.cur.height / 2)
      self.reArg.sc = cc.p(self.reArg.cur.width / self.reArg.des.width,self.reArg.cur.height / self.reArg.des.height)
      self.reArg.ratio,self.reArg.dt = self.reArg.cur.width / self.reArg.cur.height,cc.p((self.reArg.des.width - self.reArg.cur.width) * self.reArg.fix,(self.reArg.des.height - self.reArg.cur.height) * self.reArg.fix)
    end
    local resetPo = nil
    if self.reArg.ratio <= 1.34 then
      resetPo = cc.p(po.x,self.reArg.curCen.y - (self.reArg.desCen.y - po.y) * self.reArg.sc.y + self.reArg.dt.y)
    else
      resetPo = cc.p(self.reArg.curCen.x - (self.reArg.desCen.x - po.x) * self.reArg.sc.x + self.reArg.dt.x,po.y)
    end
    return resetPo
end

--[[转换坐标，将设计尺寸转为实际尺寸 old 不推荐使用]]
function Engine:Po(pox,poy)
    if not poy then
      local po = pox
      pox = po.x
      poy = po.y
    end
    if self.scale == nil then self:initScale() end
    return pox*self.scale.x,poy*self.scale.y
end

--[[转换大小，将设计尺寸转为实际尺寸]]
function Engine:Size(w,h)
    if self.scale == nil then self:initScale() end
    return cc.size(w*self.scale.x,h*self.scale.y)
end
--[[获取相对坐标，按百分比计算，如屏幕中心点E:perPo(0.5,0.5)]]
function Engine:perPo(perX,perY)
    local size = display.size or cc.Director:getInstace():getWinSize()
    return cc.p(perX * size.width, perY * size.height)
end
-- 计算起点到目标点间夹角（即精灵旋转的朝向,转头的角度）
function Engine:calAngle(po1,po2)
    local dx,dy = po2.x - po1.x,po2.y - po1.y
    local ro = math.deg(math.atan(dx/dy))
    return ro
end
-- 计算两点间距离
function Engine:calGap(po1,po2)
    local dx,dy = po2.x - po1.x,po2.y - po1.y
    local gap = math.sqrt(dx*dx + dy*dy)
    return gap
end
-- 打乱table顺序,返回被打乱的表和回溯表（如果tb中的内容全为正整数下标的话）
function Engine:disturbTable(tb)
  local data,len,j,oraIndex = {},#tb,-1,{}
  for i,one in ipairs(tb) do
    repeat
      j = math.random(1,len)
    until data[j] == nil
    data[j] = one
  end
  for i,id in ipairs(data) do  -- 计算反向编号表
    if type(id) == "number" and id > 0 then
      oraIndex[id] = i
    end
  end
  return data,oraIndex
end
-- 循环左移table(默认1次)
function Engine:ROL(tb,times)
  times = times or 1
  if times <= 0 then return end
  local len,tbcp = #tb,{}
  local function aligning(num)
    if num < 1 then return aligning(num + len)
    elseif num > len then return aligning(num - len) end
    return num
  end
  for i,one in ipairs(tb) do
    tbcp[aligning(i - times)] = one
  end
  return tbcp
end
-- 循环右移table(默认1次)
function Engine:ROR(tb,times)
  times = times or 1
  if times <= 0 then return end
  local len,tbcp = #tb,{}
  local function aligning(num)
    if num < 1 then return aligning(num + len)
    elseif num > len then return aligning(num - len) end
    return num
  end
  for i,one in ipairs(tb) do
    tbcp[aligning(i + times)] = one
  end
  return tbcp
end
--打印当前系统时间
function Engine:nowTime()
  local tm = os.date()
  print("当前时间 " .. tm)
  return tm
end
-- 激活文本阴影：E:openShadow(self,{skip={self.countDownPl.countdown}})
function Engine:openShadow(root,para)
  para = para or {} -- 阴影的参数
  para.shadowColor = para.shadowColor or cc.c4b(0,0,0,255)
  para.offset = para.offset or cc.size(2,-2)
  para.blurRadius = para.blurRadius or 0
  para.skip = para.skip or {} -- 过滤控件列表(过滤可过滤其子控件)
  para.skipFunc = para.skipFunc or nil -- 过滤函数（检测某控件 如果需要过滤的话就return true）
  local isSkip = false
  for k,o in pairs(root:getChildren()) do
    isSkip = false
    for k,s in pairs(para.skip) do
      if s == o then isSkip = true;break end
    end
    if not isSkip and o and o.getString and o.enableShadow then
      if para.skipFunc and type(para.skipFunc) == "function" then
        isSkip = para.skipFunc(o)
      end
      if not isSkip then
        o:enableShadow(para.shadowColor,para.offset,para.blurRadius)
      end
    end
    if not isSkip and o:getChildrenCount() > 0 then
      self:openShadow(o,para)
    end
  end
end
-- 激活文本特效(默认为开启发光，设置size线宽参数则开启描边) E:openTTFEF(self,{color=cc.c3b(255,0,0),size=1})
function Engine:openTTFEF(root,para)
  para = para or {} -- 阴影的参数
  para.color = para.color or cc.c4b(0,0,0,255)
  para.size = para.size or -1
  para.skip = para.skip or {} -- 过滤控件列表(过滤可过滤其子控件)
  para.skipFunc = para.skipFunc or nil -- 过滤函数（检测某控件 如果需要过滤的话就return true）
  local isSkip = false
  for k,o in pairs(root:getChildren()) do
    isSkip = false
    for k,s in pairs(para.skip) do
      if s == o then isSkip = true;break end
    end
    if not isSkip and o and o.getString and o.enableOutline and o.enableGlow then -- 检测是TextFieldTTF控件
      if para.skipFunc and type(para.skipFunc) == "function" then
        isSkip = para.skipFunc(o)
      end
      if not isSkip then
        if para.size > 0 then
          o:enableOutline(para.color,para.size)
        else
          o:enableGlow(para.color)
        end
      end
    end
    if not isSkip and o:getChildrenCount() > 0 then
      self:openTTFEF(o,para)
    end
  end
end

function Engine:getIndentSpace(indent)
     local str = ""
     for i =1, indent do
          str = str .. " "
     end
     return str
end


function Engine:newLine(indent)
     local str = "\n"
     str = str .. self:getIndentSpace(indent)
     return str
end


function Engine:createKeyVal(key, value, bline, deep, indent)
     local str = "";
     if (bline[deep]) then
     str = str .. self:newLine(indent)
     end
     if type(key) == "string" then
          str = str.. key .. " = "
     end
     if type(value) == "table" then
          str = str .. self:getTableStr(value, bline, deep+1, indent)
     elseif type(value) == "string" then
          str = str .. '"' .. tostring(value) .. '"'
     else
          str = str ..tostring(value)
     end
     str = str .. ","
     return str
end


function Engine:getTableStr(t, bline, deep, indent)
     local str
     if bline[deep] then
          str = self:newLine(indent) .. "{"
          indent = indent + 4
     else
          str = "{"
     end
     for key, val in pairs(t) do
          str = str .. self:createKeyVal(key, val, bline, deep, indent)
     end
     if bline[deep] then
          indent = indent-4
          str = str .. self:newLine(indent) .. "}"
     else
          str = str .. "}"
     end
     return str
end


function Engine:tableTree(t,title)
    local strP = ""
    if title then strP = "[" .. title .. "] type:" .. type(t) end
    if type(t) == "table" then
        local str = self:getTableStr(t, {true, true, true}, 1, 0)
        if title then
            strP = strP .. "\n" .. str
        else
            strP = str
        end
    else
        strP = strP .. " value:" .. tostring(t)
    end
    print(strP)
end

-- 动态改变文字动画 (控件，格式化，初始值，最终值，次数，总时间)
-- E:switchText(ctl,"%d",oraScore,newScore,15,1.5,nil,true)
-- 适用于数字标签和普通文本等setString方式的控件
function Engine:switchText(text,formatString,fromNum,toNum,times,during,waitTime,showSymbol)
    local dt,du = (toNum - fromNum) / times,during / times
    text.curNum = fromNum
    text.dtNum = dt
    text.showSymbol = showSymbol
    local ani = cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(du),cc.CallFunc:create(function(sender)
        sender.curNum = sender.curNum + sender.dtNum
        if sender.showSymbol and sender.curNum > 0 then
            sender:setString(string.format("+" .. formatString,sender.curNum))
        else
            sender:setString(string.format(formatString,sender.curNum))
        end
    end)),times)
    text:stopAllActions()
    if waitTime then
        text:runAction(cc.Sequence:create(cc.DelayTime:create(waitTime),ani))
    else
        text:runAction(ani)
    end
end
-- 创建数字文本控件 prop:url,types,w,h 对应标签文本的图片路径，匹配字段类型(1:12位 2:10位 ./0123456789)，宽、高
function Engine:createNumText(prop,num)
    local tps = "./0123456789"
    if prop.types == 2 then tps = "0123456789" end
    local len,first = string.len(tps),string.sub(tps,1,1)
    local scoreLab = ccui.TextAtlas:create()
    scoreLab:setProperty(tps, prop.url, prop.w / len, prop.h, first)
    scoreLab:setString(num)
    if string.len(num .. "") > 4 then
     scoreLab:setScale(0.7)
    else
     scoreLab:setScale(1)
    end
    scoreLab:setAnchorPoint(0.5,0.5)
    return scoreLab
end


---------------------------------------------碰撞检测系列函数---------------------------------------------
-- spriteCollision(sprite1,sprite2) 检测两个sprite是否碰撞
-- 结构体 圆Table:Circle{o=圆心,r=半径} 多边形Table:Polygon{dot1,dot2,dot3,dot4..}
-- circleCollision(c1,c2) 检测两个圆形碰撞
-- polygonCollision(a,b) 检测两个多边形是否碰撞
-- polygonCircleCollision(p,c) 凸多边形与圆形碰撞
-- rectangleCircleCollision(cocorect,circle) 矩形与圆形碰撞 cocorect：cc.rect
-- 

function Engine:vectSub(v1,v2)
  return cc.p(v1.x - v2.x,v1.y - v2.y)
end

function Engine:vectPerp(v)
  return cc.p(-v.y, v.x)
end

function Engine:vectDot(v1,v2)
  return v1.x*v2.x + v1.y*v2.y;
end

-- 检测两个多边形是否碰撞，碰撞返回true，不碰撞返回false
-- 必须是两个凸多边形，凹多边形必须拆分成多个凸多边形或三角形
function Engine:polygonCollision(a,b)
  local edge, axis;
  local minA,maxA,minB,maxB=0,0,0,0;
  local i,j,am,bm = 1,#a,#a,#b
  while i <= (am + bm) do
    if i <= am then
      edge = self:vectSub(a[i], a[j]);
    elseif i == am + 1 then
      j = am + bm
      edge = self:vectSub(b[i-am], b[j-am]);
    else
      edge = self:vectSub(b[i-am], b[j-am]);
    end
    axis = self:vectPerp(edge); -- 向量的垂直向量
    -- 以边的垂线为坐标轴进行投影，取得投影线段[min, max]
    minA,maxA = self:projectPolygon(axis, a);
    minB,maxB = self:projectPolygon(axis, b);
    -- 检查两个投影的距离，如果两投影没有重合部分，那么可以判定这两个多边形没有碰撞
    if self:intervalDistance(minA, maxA, minB, maxB) > 0 then
      return false;
    end
    j=i
    i=i+1
  end
  return true;
end

-- 计算多边形polygon在坐标轴axis上得投影，得到最小值min和最大值max
function Engine:projectPolygon(axis,polygon)
  local d = self:vectDot(axis, polygon[1]);
  local min,max
  min = d;
  max = d;
  for i,p in ipairs(polygon) do
    d = self:vectDot(axis, p);
    if d < min then
      min = d
    else
      if d > max then max = d end
    end
  end
  return min,max
end

-- 计算两个投影得距离
function Engine:intervalDistance(minA,maxA,minB,maxB)
  return (minA < minB) and (minB - maxA) or (minA - maxB)
end
-- 检测精灵碰撞（包括旋转）
function Engine:spriteCollision(sprite1,sprite2)
    -- 首先取出两个sprite的AABB
    local rect1 = sprite1:getBoundingBox();
    local rect2 = sprite2:getBoundingBox();
    -- 看看是否旋转，如果都没有旋转，直接用boundingbox判断
    if sprite1:getRotation() == 0 and sprite2:getRotation() == 0 then
        return cc.rectIntersectsRect(rect1,rect2);
    else
        -- 即使有旋转，也先用AABB判断一下，如果AABB碰撞，再继续判断
        if cc.rectIntersectsRect(rect1,rect2) then
            local function genPolygon(sp) -- AABB有碰撞，然后得出矩形，再用分离轴法判断
              local poly = {}
              local pos = cc.p(sp:getPosition())
              local anchor = sp:getAnchorPoint()
              local w = sp:getContentSize().width * sp:getScaleX();
              local h = sp:getContentSize().height * sp:getScaleY();
              local vec = cc.p(pos.x-w * anchor.x,pos.y-h * anchor.y);
              table.insert(poly,vec)
              vec = cc.p(pos.x + w * (1 - anchor.x),pos.y-h * anchor.y);
              table.insert(poly,vec)
              vec = cc.p(pos.x + w * (1 - anchor.x),pos.y + h * (1 - anchor.y));
              table.insert(poly,vec)
              vec = cc.p(pos.x - w * anchor.x,pos.y + h * (1 - anchor.y));
              table.insert(poly,vec)
              -- 旋转
              local radian = sp:getRotation()
              for i,p in ipairs(poly) do
                local xValue = p.x - pos.x
                local yValue = p.y - pos.y
                p.x = xValue * math.cos(math.rad(radian)) + yValue * math.sin(math.rad(radian)) + pos.x;
                p.y = yValue * math.cos(math.rad(radian)) - xValue * math.sin(math.rad(radian)) + pos.y;
              end
              return poly
            end
            return self:polygonCollision(genPolygon(sprite1), genPolygon(sprite2));
        else
            return false;
        end
    end
    return false;
end
-- 检测两个圆形碰撞 Cir = {o,r} o:圆心坐标 r:半径
function Engine:circleCollision(c1,c2)
  local dis = (c1.o.x - c2.o.x) * (c1.o.x - c2.o.x) +  (c1.o.y - c2.o.y) * (c1.o.y - c2.o.y);
  if dis > (c1.r + c2.r) * (c1.r + c2.r) then
    return false;
  else
    return true;
  end
end

-- 向量长度
function Engine:vectLength(v)
  return math.sqrt(v.x*v.x + v.y*v.y);
end

-- 计算圆形circle在坐标轴axis上得投影，得到最小值min和最大值max
function Engine:projectCircle(axis,circle)
  local d = self:vectDot(axis, circle.o);
  local axisLength = self:vectLength(axis);
  local min = d - (circle.r * axisLength);
  local max = d + (circle.r * axisLength);
  return min,max
end
-- 凸多边形与圆形碰撞 圆Cir = {o,r} o:圆心坐标 r:半径
function Engine:polygonCircleCollision(p,c)
  local edge,axis;
  local minP,maxP,minC,maxC = 0,0,0,0;
  local i,j,pm = 0,#p,#p
  while i < pm do
    edge = self:vectSub(p[i], p[j]);
    axis = self:vectPerp(edge);
    -- 以边的垂线为坐标轴进行投影，取得投影线段[min, max]
    minP,maxP = self:projectPolygon(axis, p);
    minC,maxC = self:projectCircle(axis, c);
    -- 检查两个投影的距离，如果两投影没有重合部分，那么可以判定这两个图形没有碰撞
    if self:intervalDistance(minP, maxP, minC, maxC) > 0 then
      return false;
    end
    j=i
    i=i+1
  end
  for i,pObj in pairs(p) do
    axis = self:vectSub(c.o, pObj);
    minP,maxP = self:projectPolygon(axis, p);
    minC,maxC = self:projectCircle(axis, c);
    if self:intervalDistance(minP, maxP, minC, maxC) > 0 then
      return false;
    end
  end
  return true;
end

-- 两点距离的平方
function Engine:disSquare(p1,p2)
  return (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y);
end

-- 矩形与圆形碰撞 传入cc.rect 和 圆对象Cir = {o,r} o:圆心坐标 r:半径
function Engine:rectangleCircleCollision(cocorect,circle)
  local rect={left=cocorect.x,right=cocorect.x+cocorect.width,bottom=cocorect.y,top=cocorect.y+cocorect.height}
  if circle.o.x > rect.left - circle.r
    and circle.o.x < rect.right + circle.r
    and circle.o.y > rect.bottom - circle.r
    and circle.o.y < rect.top + circle.r then
    -- 左上角
    if circle.o.x < rect.left and circle.o.y > rect.top then
      local dis = self:disSquare(cc.p(rect.left, rect.top), circle.o);
      if dis > circle.r * circle.r then
        return false;
      end
    end
    
    if circle.o.x > rect.right and circle.o.y > rect.top then
      local dis = self:disSquare(cc.p(rect.right, rect.top), circle.o);
      if dis > circle.r * circle.r then
        return false;
      end
    end
    
    if circle.o.x < rect.left and circle.o.y < rect.bottom then
      local dis = self:disSquare(cc.p(rect.left, rect.bottom), circle.o);
      if dis > circle.r * circle.r then
        return false;
      end
    end
    
    if circle.o.x > rect.right and circle.o.y < rect.bottom then
      local dis = self:disSquare(cc.p(rect.right, rect.bottom), circle.o);
      if dis > circle.r * circle.r then
        return false;
      end
    end

    return true;
  end
  return false;
end
----------------------------------------------------------------------------------------------------------
-- 保存表到本地(UserDefault)
function Engine:Save(name,table)
    if table == nil or type(name) ~= "string" then return nil end
    if self.DB == nil then
        self.DB = cc.UserDefault:getInstance()
    end
    local str = json.encode(table)
    if str then
        self.DB:setStringForKey(name,str)
        return str
    end
    return false
end
-- 从本地读取表(UserDefault)
function Engine:Load(name)
    if type(name) ~= "string" then return nil end
    if self.DB == nil then
        self.DB = cc.UserDefault:getInstance()
    end
    local str = self.DB:getStringForKey(name)
    if str and type(str) == "string" and string.len(str) > 1 then
        return json.decode(str)
    end
    return nil
end

-- require("app.Manager.Engine")
if not _G["E"] then _G["E"] = Engine.new() E:initScale() end
return _G["E"]