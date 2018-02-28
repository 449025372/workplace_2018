SnakeCfg = class("SnakeCfg")

SnakeCfg.maxLenth = 2000

SnakeCfg.eye = "img_eyes_tcs.png"

SnakeCfg.bodys = {
	{id = 1,colorId = 1,res = "img_circle_tcs_red.png", color = cc.c3b(200, 2, 0),skinName = "小红",price = 50,isbuy = true},
	{id = 2,colorId = 4, res = "img_circle_tcs_tomato.png", color = cc.c3b(214, 53, 98),skinName = "小粉",price = 50,isbuy = cc.UserDefault:getInstance():getBoolForKey("skin2_isBuy")},
	{id = 3,colorId = 6, res = "img_circle_tcs_yellow.png", color = cc.c3b(216, 167, 13),skinName = "小黄",price = 50,isbuy = cc.UserDefault:getInstance():getBoolForKey("skin3_isBuy")},
	{id = 4,colorId = 2, res = "img_circle_tcs_purple.png", color = cc.c3b(128, 0, 128),skinName = "小紫",price = 50,isbuy = cc.UserDefault:getInstance():getBoolForKey("skin4_isBuy")},
	{id = 5,colorId = 3, res = "img_circle_tcs_green.png", color = cc.c3b(45, 160, 45),skinName = "小绿",price = 50,isbuy = cc.UserDefault:getInstance():getBoolForKey("skin5_isBuy")},
	{id = 6,colorId = 10, res = "img_circle_tcs_brown.png", color = cc.c3b(139, 80, 46),skinName = "小土",price = 50,isbuy = cc.UserDefault:getInstance():getBoolForKey("skin6_isBuy")},
	{id = 7,colorId = 12, res = "img_circle_tcs_blue.png", color = cc.c3b(30, 144, 255),skinName = "小蓝",price = 50,isbuy = cc.UserDefault:getInstance():getBoolForKey("skin7_isBuy")},
	{id = 8,colorId = 7, res = "img_circle_tcs_aquamarine.png", color = cc.c3b(11, 212, 175),skinName = "小青",price = 50,isbuy = cc.UserDefault:getInstance():getBoolForKey("skin8_isBuy")},
	{id = 9,colorId = 4, head = "skin_rabbit_head_tcs.png",res = {"skin_rabbit_body1_tcs.png","skin_rabbit_body2_tcs.png"},tail = "skin_rabbit_tail_tcs.png", color = cc.c3b(11, 212, 175),skinName = "小兔",price = 100,isbuy = cc.UserDefault:getInstance():getBoolForKey("skin9_isBuy")},
	{id = 10,colorId = 8, head = "skin_tree_head_tcs.png",res = {"skin_tree_body1_tcs.png","skin_tree_body2_tcs.png"},tail = "skin_tree_tail_tcs.png", color = cc.c3b(11, 212, 175),skinName = "小树",price = 100,isbuy = cc.UserDefault:getInstance():getBoolForKey("skin10_isBuy")},
	{id = 11,colorId = 6, head = "skin_star_hand_tcs.png",res = {"skin_star_body1_tcs.png","skin_star_body2_tcs.png","skin_star_body3_tcs.png","skin_star_body4_tcs.png","skin_star_body5_tcs.png"}, color = cc.c3b(11, 212, 175),skinName = "小星星",price = 100,isbuy = cc.UserDefault:getInstance():getBoolForKey("skin11_isBuy")},
	{id = 12,colorId = 13,middle = "skin_corpse_body1_tcs.png", head = "skin_corpse_head_tcs.png",res = "skin_corpse_body2_tcs.png",tail = "skin_corpse_tail_tcs.png", color = cc.c3b(11, 212, 175),skinName = "小僵尸",price = 100,isbuy = cc.UserDefault:getInstance():getBoolForKey("skin12_isBuy")},
}
SnakeCfg.name = cc.UserDefault:getInstance():getStringForKey("name")

SnakeCfg.timer = 300

if cc.UserDefault:getInstance():getIntegerForKey("skinID") == 0 then
	SnakeCfg.currentSkin = 1
else
	SnakeCfg.currentSkin = cc.UserDefault:getInstance():getIntegerForKey("skinID")
end

return SnakeCfg