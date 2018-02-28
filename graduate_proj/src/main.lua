
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

local function main()
	local scene = require("views/SnakeGameWaitScene").new()
    cc.Director:getInstance():runWithScene(scene)
    
    -- 显示FPS
	cc.Director:getInstance():setDisplayStats(true)
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
