
local GameCfg ={}

--游戏规则信息定义

GameCfg.INVALID_CHAIR_NO= 0xFF
GameCfg.INVALID_USER_ID= 0xFFFF

--======通知消息====================

GameCfg.WAKENG_MSG_GAME_LEAVE_ROOM ="leaveRoom" --离开游戏
GameCfg.WAKENG_MSG_TIME_OUT="timeOuts" --超时
GameCfg.NOTIFICATION_CHANGETABLE = "changeTable" --换桌
GameCfg.NOTIFICATION_BROCASE = "broadcast"  --广播
GameCfg.NOTIFICATION_ROBOT = "robot" --托管
GameCfg.NOTIFICATION_ROBOTREPLACEOUTCARD = "robotReplaceOutCard" --托管出牌
GameCfg.NOTIFICATION_DISSROOM = "dissRoom" --解散房间
GameCfg.NOTIFICATION_LISTENCARD = "listenCard" --听牌
GameCfg.NOTIFICATION_SHOWTOTALSETTLE = "showtotalsettle"

return GameCfg
