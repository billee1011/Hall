local GameDefs = {}
GameDefs.__index = GameDefs

local AppConfig = require("AppConfig")

GameDefs.CommonInfo = {
	Game_Name = "飞鸟红中麻将",
	View_Width  = 1280,
	View_Height = 720,

	Game_ID = 12,
	Game_Version = 1,	

	Code_Path = "czmj/",
	Mj_Path = "resources/images/mahjong/",
	Img_Path = "czmj/images/",
	Music_Path = "czmj/music/",
	Putonghua_Path = "resources/music/mahjong/",
	
	Logic_Path = "czmj/Game/GameLogic",

	GameLib_File = "czmj/GameLibSink",
	ClientFrame_File = "czmj/ClientFrameSink",

	DeskBtn_Priority = kCCMenuHandlerPriority - 1,

	DeskCard_Priority = kCCMenuHandlerPriority,
	DeskOpearator_Priority = kCCMenuHandlerPriority - 1,
	DeskChi_Priority = kCCMenuHandlerPriority - 2,

	DeskPanel_Priority = kCCMenuHandlerPriority - 5,
	ResultPanel_Priority = kCCMenuHandlerPriority - 8,
}

GameDefs.CmdInfo = {
	Out_Card = 1, 				--广播出牌命令			
	Operate_Card = 2,
	Trustee_Game = 3,
	C_PiaoStatus = 4,

	S_Game_Start = 50, 			--游戏开始广播
	S_Out_Card = 51, 			--广播出牌命令
	S_Send_Card = 52,			--广播发送扑克
	S_Operate_Notify = 53,		--操作提示
	S_Operate_Result = 54,		--操作结果
	S_Game_End = 55,			--游戏结算
	S_Trustee = 56,				--玩家托管
	S_Get_Bird = 57,			--抓鸟
	S_ChoosePiao = 58,			--用户选择飘玩法
	S_UserPiaoStatus = 59,		--广播用户飘玩法状态
}


GameDefs.OperateCmd = {
	No = 0x00,
	Left_Chi = 		0x01,
	Middle_Chi = 	0x02,
	Right_Chi = 	0x04,

	Peng =			0x08,
	Gang =			0x10,
	Ting =			0x20,
	Chi_Hu =		0x40,
}

GameDefs.HuType = {
	QingYiSe_Hu = 		0x01,
	PengPeng_Hu = 		0x02,
	QiDui_Hu = 			0x04,

	SiHongZhong_Hu =	0x08,
	QiangGang_hu =			0x10
}

-- 快捷聊天
GameDefs.quickChat = {
    "难产啊，还不快点出",
    "不要走啊，今天打通宵",
    "各位老板不好意思，我要暂停一下",
    "信号不好，各位老板不好意思啊",
    "屌古滴，打不赢你们",

    "大家好，很高兴见到各位",
    "哈哈，手气真好",
    "快点出牌哟",
    "你的牌打的太好了",
    "怎么又断线了，网络怎么这么差啊",
}
return GameDefs
