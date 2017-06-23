local GameDefs = {}
GameDefs.__index = GameDefs

local AppConfig = require("AppConfig")

GameDefs.CommonInfo = {
	Game_Name = "韶关麻将",
	View_Width  = 1280,
	View_Height = 720,

	Game_ID = 12,
	Game_Version = 1,	

	Code_Path = "sgmj/",
	Mj_Path = "resources/images/mahjong/",
	Img_Path = "sgmj/images/",
	Music_Path = "sgmj/music/",
	Putonghua_Path = "resources/music/mahjong/",
	
	Logic_Path = "sgmj/Game/GameLogic",

	GameLib_File = "sgmj/GameLibSink",
	ClientFrame_File = "sgmj/ClientFrameSink",

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
--	S_Trustee = 56,				--玩家托管
	S_Get_Bird = 56,			--抓鸟
	S_ChoosePiao = 58,			--用户选择飘玩法
	S_UserPiaoStatus = 59,		--广播用户飘玩法状态
}

--操作命令码
GameDefs.OperateCmd = {
	No = 0x00000000,
	Left_Chi = 		0x00000001,
	Middle_Chi = 	0x00000002,
	Right_Chi = 	0x00000004,

	Peng =			0x00000008,
	Gang =			0x00000010,
	Ting =			0x00000020,
	Chi_Hu =		0x00000040,
}
--胡牌类型
GameDefs.HuType = {
--	QingYiSe_Hu = 		0x00000001,
--	PengPeng_Hu = 		0x00000002,
--	QiDui_Hu = 			0x00000004,
--	SiHongZhong_Hu =	0x00000008,
--	QiangGang_hu =		0x00000010,
	GANG_BAO_HU	 =		0x00000001,									--杠爆胡
	QING_GANG_HU =		0x00000002,									--抢杠胡
	JIAN_REN_HU	 =		0x00000004,									--尖人胡牌
	PENG_PENG	 =		0x00000008,									--碰碰和
	HUN_YI_SE	 =		0x00000010,									--混一色
	QING_YI_SE	 =		0x00000020,									--清一色
	YAO_JIU		 =		0x00000040,									--幺九
	QI_DUI		 =		0x00000080,									--七对
	SHI_SAN_YAO	 =		0x00000100,									--十三幺
	QUAN_YAO	 =		0x00000200,									--全幺
	QUAN_FENG	 =		0x00000400									--全风
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
