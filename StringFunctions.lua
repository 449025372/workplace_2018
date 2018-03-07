--[[
    -- 两个字符串操作函数
    -- Author : CaiEnHao
    -- Data : 2018.3.8
--]]

-- 省略小数 参数1-数字 参数2-保留小数点位数 
local function GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum
    end
    if nNum > 10000 then
        n = 0
    else
        -- n = 1
    end
    n = n or 0;
    n = math.floor(n)
    if n < 0 then
        n = 0
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(nNum * nDecimal)
    local nRet = nTemp / nDecimal
    print("GetPreciseDecimal = ", nNum, n, nRet)
    return nRet
end

-- 数字转化为字符串 例如传入1000000 返回1,000,000
local function checkNumToString(nums)
    local str = tostring(nums)
    local newStr = ""
    if #str > 3 then
        local count = math.floor(#str / 3)
        local remain = #str % 3
        if remain == 0 then
            for i=1,count do
                if i ~= count then
                    newStr = newStr..string.sub(str, (i - 1) * 3 + 1, 3 * i)..","
                else
                    newStr = newStr..string.sub(str, (i - 1) * 3 + 1, 3 * i)
                end
            end
        else
            newStr = string.sub(str, 1, remain)..","
            for i=1,count do
                if i ~= count then
                    newStr = newStr..string.sub(str, remain + (i - 1) * 3 + 1, 3 * i + remain)..","
                else
                    newStr = newStr..string.sub(str, remain + (i - 1) * 3 + 1, 3 * i + remain)
                end
            end
        end
    else
        newStr = str
    end
    print("checkNumToStringcheckNumToStringcheckNumToString", newStr)
    return newStr
end