local GameDefs = {}
GameDefs.__index = GameDefs

local AppConfig = require("AppConfig")

GameDefs.FONT_ARIAL = "Arial"
GameDefs.FONT_ARIAL_BOLD = "Arial-BoldMT"
GameDefs.FONT_SIZE = 22

GameDefs.Resources_Head_Path = "k510/Resources/"
GameDefs.REQUIRE_GAMELIBSINK  = "k510/GameLibSink"

GameDefs.CommonInfo = {
	View_Width  = 1280,
	View_Height = 720,

	Game_ID = 24,
	Game_Version = 1,	

	Code_Path = "k510/",
	Img_Path = "k510/Resources/",
	Music_Path = "k510/music/",

	GameLib_File = "k510/GameLibSink",
	ClientFrame_File = "k510/ClientFrameSink",

	DeskBtn_Priority = kCCMenuHandlerPriority - 1,

	DeskCard_Priority = kCCMenuHandlerPriority,
	DeskOpearator_Priority = kCCMenuHandlerPriority - 1,
	DeskChi_Priority = kCCMenuHandlerPriority - 2,

	DeskPanel_Priority = kCCMenuHandlerPriority - 5,
	ResultPanel_Priority = kCCMenuHandlerPriority - 8
}

-- 快捷聊天
GameDefs.quickChat = {
    {"大家好，很高兴见到各位",          "resources/music/mahjong/%s/chat6.mp3"},
    {"哈哈，手气真好",                  "resources/music/mahjong/%s/chat7.mp3"},
    {"快点出牌哟",                      "resources/music/mahjong/%s/chat8.mp3"},
    {"你的牌打的太好了",                "resources/music/mahjong/%s/chat9.mp3"},
    {"怎么又断线了，网络怎么这么差啊",  "resources/music/mahjong/%s/chat10.mp3"},
}

GameDefs.DESC_SPEAKER_SENDTIPS  = ("请在此处输入您想说的话，需要500金币！")
GameDefs.DESC_FREESPEAKER_NUM  = ("请在此处输入您想说的话，您还有%d个免费大喇叭！")
GameDefs.DESC_GLOBAL_SYSTEM                = ("【系统】")

GameDefs.SPEAKER_NODE_TAG = 1005--大喇叭的标签,在RunningScene下面添加

GameDefs.LHB_BTN_SPEAKER = 36

return GameDefs
