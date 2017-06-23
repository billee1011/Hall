require("AudioEngine")

local Resources = {}

local WebRequest = require("GameLib/common/WebRequest")
local getData = WebRequest.getData
local SAFEATOI = WebRequest.SAFEATOI
local SAFEATOI64 = WebRequest.SAFEATOI64
local SAFESTRING = WebRequest.SAFESTRING

Resources.__index = Resources

Resources.Resources_Head_Url = "bull/bullResources/"
Resources.Code_Head_Url = "bull/"
Resources.DeskComponentCode_Head_Url = "bull/desk/deskcomponent/"
Resources.DeskCode_Head_Url = "bull/desk/"
Resources.ImagePath = "bull/images/"
--字体颜色
Resources.FONT_COLOR = ccc3(139, 63, 31)
Resources.ccWHITE = ccc3(255,255,255)
Resources.ccBLACK = ccc3(0,0,0)
Resources.ccRED = ccc3(255,0,0)
Resources.ccGRAY = ccc3(166,166,166)
Resources.ccBLUE = ccc3(0,0,255)
Resources.ccYELLOW = ccc3(255,255,0)
Resources.ccGREEN = ccc3(0,255,0)
Resources.ccGold = ccc3(240,201,38)
Resources.ccDiamond = ccc3(69,199,223)
Resources.IMAGE_GRAY_COLOR = ccc3(77,77,77)
Resources.TEXT_COLOR = ccc3(99,7,20)
Resources.ccSafeBoxGold = ccc3(255,189,0)

--通用组件的Tag，在GetRunningScene下面使用
Resources.MSG_BOX_TAG = 1001
Resources.LOADING_BOX_TAG = 1002

Resources.ROOMCHOOSE_SCENE_TAG = 1003
Resources.ROOMCHOOSE_SCENE_LAYER_TAG = 1004--放置在ROOMCHOOSE_SCENE下的主要layer的Tag

Resources.DESK_SCENE_TAG = 1005
Resources.DESK_SCENE_LAYER_TAG = 1006--//放置在DESK_SCENE下的主要layer的Tag

Resources.TOTAL_SETTLE = 1007

Resources.DESK_DIALOG_ZORDER = 100
Resources.DESK_PERSONALINFODIALO_ZORDER = 101

Resources.BTN_BACK_TAG = 10
Resources.BASE_DIALOG = 11
--//绑定邮箱返回值定义

Resources.SPEAKER_TAG = 100 --大喇叭
Resources.PERSONALINFO_TAG = 101 --个人信息
Resources.MALL_TAG = 102 --商城
Resources.ACTIVITY_TAG = 103 --活动
Resources.ACTIVITY_DETAIL_TAG = 104 --活动
Resources.KEFU_TAG = 105 --客服
Resources.SETTING_TAG = 106 --设置
Resources.HELP_TAG = 107 --帮助
Resources.MAIL_TAG = 108 --邮件
Resources.RANK_TAG = 108 --排行榜
Resources.HOWGETQUAN_TAG = 109 --如何获得话费券
Resources.TASK_TAG = 110 --任务
Resources.INVITEFRIEND_DIALOG_TAG = 111 --邀请好友
Resources.TUIGUANGLAYER_TAG = 112 --推广
Resources.TOAST_LAYER_TAG = 113
Resources.DISSOLVEDESKDIALOG_TAG = 114--解散牌桌对话框
Resources.NOTENOUGHGOLDDIALOG_TAG = 115 --金币不足对话框

Resources.REDPOINT_TAG = 100 --红点

--商城定义
Resources.MALL_INFO_LAYER_BTN_TAG = 0
Resources.BUY_INFO_LAYER_BTN_TAG = 1
Resources.DIAMONEXCHANGE_LAYER_BTN_TAG = 2
Resources.DIAMONBUYPROPERTY_LAYER_BTN_TAG = 3
Resources.VIP_BTN_TAG = 4

Resources.EN_STANDUP_NORMAL = 0
Resources.EN_STANDUP_BACKROOM = 1 
Resources.EN_STANDUP_CHANGETABLE = 2

--牌桌聊天显示
Resources.CHAT_FACE_TAG = 1000    --//聊天表情
Resources.CHAT_WORD_TAG = 2000    --//聊天窗口

--//每日领取，返回参数定义
Resources.DAYS_AWARDS_SUCCESS = 1--//操作成功
Resources.DAYS_AWARDS_WRONG = 11--//传入参数错误
Resources.DAYS_AWARDS_NOAWARD = 12--//没有奖励可领取
Resources.FONT_ARIAL = "Arial"
Resources.FONT_BLACK = "黑体"
Resources.FONT_ARIAL_BOLD = "Arial-BoldMT"
Resources.FONT_SIZE = 20
Resources.ORDER_DELAY_SECONDS = 15

Resources.FONT_SIZE12 = 12
Resources.FONT_SIZE14 = 14
Resources.FONT_SIZE15 = 15
Resources.FONT_SIZE17 = 17
Resources.FONT_SIZE18 = 18
Resources.FONT_SIZE20 = 20
Resources.FONT_SIZE22 = 22
Resources.FONT_SIZE24 = 24
Resources.FONT_SIZE26 = 26
Resources.FONT_SIZE28 = 28
Resources.FONT_SIZE30 = 30
Resources.FONT_SIZE35 = 35
Resources.FONT_SIZE40 = 40

--//全局Notification
Resources.NOTIFICATION_UPDATEMYINFO = "updateMyInfo" --更新我的信息
Resources.NOTIFICATION_NEWSTATUS = "newStatus"
Resources.NOTIFICATION_SAFEBOXINFO = "bankinfo"
Resources.NOTIFICATION_REFRESHUSERINFO = "refreshUserInfo" --刷新玩家信息
Resources.NOTIFICATION_RECEIVESPEAKER = "receiveSpeaker" --接收大喇叭
Resources.NOTIFICATION_RECEIVETABLECHAT = "receiveTableChat" --接收牌桌聊天
Resources.NOTIFICATION_GAMEBANKOPERATERETURN = "gameBankOperateReturn" --游戏保险柜操作返回
Resources.NOTIFYCATION_SHOWRANKINTRODUCE = "showRankIntroduce"
Resources.NOTIFICATION_REFRESHTASKINFO = "refreshTaskInfo" --刷新任务信息
Resources.NOTIFICATION_SHOWREWARDDIALOG = "showRewardDialog"
Resources.NOTIFICATION_REFRESHCREATEROOMINFO = "refreshCreateRoom" --刷新创建房间
Resources.NOTIFICATION_SHOWENTERPRIVATEROOMCOSTTIPSDIALOG = "showEnterPrivateRoomCostTipsDialog" --显示进入好友房花费金币提示
Resources.NOTIFICATION_SHOWNOTENOUGHGOLDDIALOG = "showNotEnoughGoldDialog" --显示金币不足提示框
Resources.NOTIFICATION_SHOWTIPSDIALOG = "showTipsDialog" --显示提示框
Resources.NOTIFICATION_SHOWFRIENDINFO = "showFriendInfo" --显示好友信息
Resources.NOTIFICATION_REQUESTBINDCODE = "requestBindCode" --请求绑定推荐码信息

Resources.NOTIFYCATION_USERENTER = "userenter"
Resources.NOTIFYCATION_USEREXIT = "userexit"

Resources.NOTIFYCATION_USERCHAT = "userChat"
Resources.NOTIFYCATION_SYSTEMCHAT = "systemChat"

--牌桌聊天定义
Resources.EN_CHATFRAME_TAG_FACE = 1
Resources.EN_CHATFRAME_TAG_WORDS = 2
Resources.EN_CHATFRAME_TAG_VIPFACE = 3
Resources.EN_CHATFRAME_TAG_CLOSE = 4
Resources.EN_CHATFRAME_TAG_HISTRORY = 5

Resources.FACE_CHAT_MAX_NUM = 25
Resources.WORDS_CHAT_MAX_NUM = 6
Resources.VIP_FACE_CHAT_MAX_NUM = 20


Resources.QUICK_SEND_CHATS_LOCALTION = 
{
    {"老板驾扫些","1.mp3"},
    {"么怕,不要才黑","2.mp3"},
    {"神仙怕左手","3.mp3"},
    {"以是哟子哦","4.mp3"},
    {"昨夜搞哒么里哦","5.mp3"},
    {"做哒好事,里手盼哒","6.mp3"},
    {"嬲赛喀油菜籽","7.mp3"}
}

Resources.QUICK_SEND_CHATS_PUTONG =
{
    {"不要吵了,不要吵了","1.mp3"},
    {"不要走,决战到天亮","2.mp3"},
    {"大家好,很高兴见到各位","3.mp3"},
    {"和你合作真是太愉快啦","4.mp3"},
    {"快点吧,我等到花儿也谢了","5.mp3"},
    {"你的牌打得太好了","6.mp3"},
    {"下次再玩吧,我要走了","7.mp3"}
}

--[[Resources.QUICK_SEND_CHATS_PUTONG =
{
    {"谢谢你!","1.mp3"},
    {"我很抱歉!","2.mp3"},
    {"打得不错!","3.mp3"},
    {"糟了!","4.mp3"},
    {"你好！","5.mp3"},
    {"快点出牌吧","6.mp3"},
}]]

Resources.QUICK_SEND_CHATS = Resources.QUICK_SEND_CHATS_PUTONG

--//描述语言集合

Resources.str_k_fmt ="%d千"
Resources.str_k_dot_fmt ="%.1f千"
Resources.str_w_fmt ="%d万"
Resources.str_w_dot_fmt="%.1f万"
Resources.str_kw_fmt="%d千万"

Resources.DESC_GETAWARD_FAIL                = ("领取任务奖励失败,请稍候再试")
Resources.DESC_ENTERPRIVATEROOMFAIL = "房间已满或输入房间号错误，房间号为六位数字，请确认是否该房间已满人或房间号输入错误。"
Resources.DESC_CREATEPRIVATEROOMFAIL = "房间创建失败，房间底分只能是整数，圈数只能偶数。"
Resources.DESC_LEAVEROOM = "是否离开房间？（如果10分钟内没有正式开始游戏，系统将会自动解散房间并退回钻石）"
Resources.DESC_INVITECONTENT = "玩家【%s】邀请您加入斗牛好友场【%d】牌局中，请选择是否加入？"
Resources.DESC_DISSOLVECONTENT = "玩家【%s】申请解散房间，请等待其\n他玩家选择（超过2分钟未选择，则默认同意）"
Resources.DESC_PLAYERWAITCHOICE = "玩家【%s】等待选择"
Resources.DESC_DAILISHARECONTENT = "【恭喜您已成为推广员人，赶快把您的推荐码【%d】分享出去吧！】"
Resources.DESC_ENTERPRIVATEROOMCOSTTIPS = "房间号【%d】为斗牛好友场每人支付模式，进入房间需消耗钻石。请选择是否加入？"
Resources.DSEC_USRERWORD_NULL               = ("这个家伙很懒，签名都没有留下")
Resources.DESC_VIP_PAYYUAN                  = ("%d元")
Resources.DESC_OFFICE_TIME                  = ("公众号：cjkwx001  服务时间:周一至周五9：00-18：00")
Resources.DESC_OFFICE_PHONE = ("官方客服电话：400-661-9828")
Resources.DESC_OFFICE_QQQUN = ("微信号：yaoyaomajiang01、yaoyaomajiang02")
Resources.DESC_NOSYSMSG_TIPS = ("您目前没有系统消息哦")
Resources.DESC_DELETE_SUCCESS = ("删除成功")
Resources.DESC_LEADERBOARDSCENE_USERNAME = "昵称：%s"
Resources.DESC_LEADERBOARDSCENE_PLAYROUND = "局数：%d"
Resources.DESC_LEADERBOARDSCENE_USERGOLD = "金币：%d"
Resources.DESC_LEADERBOARDSCENE_DATAFAIL = "请求数据失败，请稍后再试！"
Resources.DESC_USERINFO_TIPS = "温馨提示："
Resources.DESC_UPLOADPIC_TIPS = "请确定您上传的头像符合国家网络相关规定，如果有涉黄或违反相关规定，责任将由用户承担，且官方有权进行封号处理。是否前往修改？"
Resources.DESC_SPEAKER_SENDTIPS             = ("请在此处输入您想说的话，需要500金币！")
Resources.DESC_FREESPEAKER_NUM              = ("请在此处输入您想说的话，您还有%d个免费大喇叭！")
Resources.DESC_GLOBAL_SYSTEM                = ("【系统】")
Resources.DESC_GLOBAL_PERSONAL              = ("【个人】")
Resources.DESC_ROOM_ENTERROOMNEED           = ("进房所需:%s")
Resources.DESC_DIZHU = ("底注：%s")
Resources.DESC_UPLIMIT = ("上限：%s")
Resources.PLAYERNICKNAME = ("玩家昵称")
Resources.DESC_GOLD_TEXT = ("金币")
Resources.LABEL_NICKNAME = ("昵称：")
Resources.LABEL_GOLD = ("金币：")
Resources.LABEL_SCORE = ("成绩：")
Resources.LABEL_WINRATE = ("胜率：")
Resources.DESC_BANKIN = ("存入：")
Resources.DESC_BANKOUT = ("取出：")
Resources.DESC_YOUR_GOLD2 = ("携带金币")
Resources.DESC_SAFEBOX_SAVEGOLD = ("已存金币")
Resources.DESC_SAFEBOX_CAPACITY = ("保险箱容量：")
Resources.DESC_SAFEBOX_LEVEL = ("保险箱等级：vip%d")
Resources.DESC_CONFIRM                      = ("确定")
Resources.DESC_CANCEL                       = ("取消")
Resources.DESC_SAFEBOX_GETCASH_TIPS         = ("为了您资金的安全，请及时修改密码")
Resources.DESC_INPUTBANKPSW_TIPS = ("请输入保险箱密码")
Resources.DESC_SAFEBOX_PASSWORD_OLD         = ("初始密码000000")
Resources.DESC_OLDPSW = ("旧密码")
Resources.DESC_NEWPSW = ("新密码")
Resources.DESC_SAFEBOX_PASSWORD_NEW         = ("请输入六位数")
Resources.DESC_INPUTAGAIN = ("请再次输入密码")
Resources.DESC_AGAINNEWPSW = ("再次输入新密码")
Resources.DESC_SAFEBOX_PASSWORD_TIPS        = ("提示：没有绑定邮箱的用户，只能将密码重置为初始密码")
Resources.DESC_TEXT_CONNECTKEFU = ("请联系客服获得密码")
Resources.DESC_UPLOADFACE_TIPS              = ("请确定上传的头像符合国家规定，如有涉黄或其他违规头像，责任将由用户承担，且官方有权进行封号处理")

Resources.DESC_GAMEPLAYINGEXITDIALOG_TIPS = ("亲，现在离开已下注的筹码将不会退回哦，确定离开吗？")

Resources.DESC_BUY_TOOL_PACK				= ("请前往道具商城购买表情包")

Resources.DESC_NOTENOUGHGOLD_TIPS = ("抱歉，您可下注的金额低于%d，无法进行下注，是否去获取更多金币？")
Resources.DESC_UPLIMITGOLD_TIPS = ("抱歉，您的金币高于房间上限%d，是否去更高级的房间进行游戏？")

Resources.DESC_NOTENOUGHGOLD_TIPS2 = ("抱歉，您的金币低于入场金额，无法开始游戏，是否去获取更多金币？")

Resources.DESC_LESSGOLDSENDSPEAKER_TIPS = ("您当前金币过低，无法发送广播，请增加金币后再尝试")

Resources.DESC_MOREGAMENOOPERATE_TIPS = ("您已多局未进行操作，是否再继续进行游戏？")

Resources.DESC_CUTLINE_TIPS = ("您的网络不稳定，请更换至更好的网络后再尝试。")

Resources.DESC_BANK_GOLD                    = ("存入：%d")
Resources.DESC_BANK_GOLD_TOPNULL            = ("存入：%d")
Resources.DESC_LESS_GOLD                    = ("可存：%d")

Resources.DESC_SEND_TABLE_CHAT_OFFLINE = "不能发送离线消息"
Resources.DESC_SEND_TABLE_CHAT_NULL_CONTENT ="发送聊天内容不能为空"
Resources.DESC_SEND_TABLE_CHAT_BUSY ="不能发送太频繁!"

--Resources.DOWNLOAD_PATH = require("Domain").ShareRoot .. "bull/bull.htm"
Resources.DOWNLOAD_PATH = "http://activity.chinagames.net/GamesWeb/hymj2/bull.htm"
local partnerID = CJni:shareJni():getPartnerID()
if partnerID == 11201 or partnerID == 21201 then
    Resources.DOWNLOAD_PATH = "http://activity.chinagames.net/GamesWeb/bull/bull.htm"
end

function Resources.playPersonEffect(source, isman)
	--人物相关发声，在前缀增加M或者F
    local nEffectOpen = C2dxEx:getIntegerForKey("szmjIsEffectOpen", 1)
    if (nEffectOpen == 0) then
        return
    end
    local personselect = Resources.Resources_Head_Url .. "effect/m_"
    if (isman == false) then
        personselect = Resources.Resources_Head_Url .. "effect/f_"
    end
	local finalSource = personselect .. source
	AudioEngine.playEffect(finalSource)
end

function Resources.playGlobeEffect(source)
	--全局声音，直接发声
    local nEffectOpen = C2dxEx:getIntegerForKey("szmjIsEffectOpen", 1)
    if (nEffectOpen == 0) then
        cclog("playGlobeEffect not open")
        return
    end
    cclog("playGlobeEffect %s",source)
	AudioEngine.playEffect(source)
end

function Resources.stopAllEffect()
	AudioEngine.stopAllEffects()
end

function Resources.backToHall()
    AudioEngine.stopMusic(true)
    local GameLibSink = require("bull/GameLibSink")
    local gameLib = GameLibSink.m_gameLib
    if gameLib ~= nil and gameLib:getMyself() ~= nil then
        gameLib:leaveGameRoom()
        gameLib:release()
    end
    gameLib = nil
    local HallControl = require("HallControl"):instance()
    if (HallControl:isDirectInGame() == true) then
        CCDirector:sharedDirector():endToLua()
    else
        HallControl:backToHall()
    end
end

function Resources.formatGold(gold, remaindot)
	if (math.abs(gold) < 100000) then
		--小于10W，用实在数字
		-- if (remaindot == true) then
		-- 	local finalstring = string.format("%d", gold)
		-- 	return finalstring
		-- end
		local finalstring = string.format("%d", gold)
		return finalstring
	end
	if (math.abs(gold) >= 100000 and math.abs(gold) < 100000000) then
		--大于等于10W的，小于9999W的，整数就不显示小数点，非整数取一位小数（不需要四舍五入）
		if (remaindot == true) then
			local leftNum = gold % 10000
			if (leftNum == 0) then
				local finalstring = string.format(("%d万"), gold / 10000)
				return finalstring
			else
				local finalstring = string.format("%.1f万", gold / 10000.0)
				return finalstring
			end
		end
		local finalstring = string.format("%d万", gold / 10000.0)
		return finalstring
	end
	if (math.abs(gold) >= 100000000 and math.abs(gold) <= 2000000000) then
        --大于等于1亿，且小于20亿
        if (remaindot == true) then
            local leftNum = gold % 100000000
            if (leftNum == 0) then
                local finalstring = string.format("%d亿", gold / 100000000)
                return finalstring
            else
                --cclog("%d,%d,%d",gold,gold/100000000,gold%100000000 / 10000)
                local finalstring = string.format("%d亿%d万", math.floor(gold / 100000000) , math.floor((gold % 100000000) / 10000))
                return finalstring
            end
        else
            local finalstring = string.format("%d亿", math.floor(gold / 100000000.0))
            return finalstring
        end
    end

    if math.abs(gold) <= 100000000000 then
        return string.format("%d亿", math.floor(gold / 100000000))
    end
	--大于1000亿，就是无限
	if (remaindot == true) then
		return "无限"
	end
end

function Resources.isEMail(str)
	local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
	if require("HallControl"):instance():isIOS() or targetPlatform == kTargetAndroid then
        cclog(str)
        --%w+([-+.]%w+)*@%w+([-.]%w+)*%.%w+([-.]%w+)*
        if string.len(str or "") < 6 then return false end
        local b,e = string.find(str or "", '@')
        local bstr = ""
        local estr = ""
        if b then
            bstr = string.sub(str, 1, b-1)
            estr = string.sub(str, e+1, -1)
        else
            return false
        end
 
        -- check the string before '@'
        local p1,p2 = string.find(bstr, "[%w_]+")
        if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end
     
        -- check the string after '@'
        if string.find(estr, "^[%.]+") then return false end
        if string.find(estr, "%.[%.]+") then return false end
        if string.find(estr, "@") then return false end
        if string.find(estr, "[%.]+$") then return false end
 
        _,count = string.gsub(estr, "%.", "")
        if (count < 1 ) or (count > 3) then
            return false
        end
 
        return true
	end
	return true;
end

function Resources.backToHall()
    AudioEngine.stopMusic(true)
    local GameLibSink = require("bull/GameLibSink")
    local gameLib = GameLibSink.m_gameLib
    if gameLib ~= nil and gameLib:getMyself() ~= nil then
        gameLib:leaveGameRoom()
        gameLib:release()
    end
    gameLib = nil
    local HallControl = require("HallControl"):instance()
    if (HallControl:isDirectInGame() == true) then
        CCDirector:sharedDirector():endToLua()
    else
        HallControl:backToHall()
    end
end

function Resources.loadAnimate(szFilePath, szFrameNameFormat, frameDelayTime)
	frameDelayTime = frameDelayTime or 0.1
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(szFilePath)
    local pAnimation = CCAnimation:create()
    local index = 1
    while (index > 0) do
        str = string.format(szFrameNameFormat, index)
        local pSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(str)
        if (pSpriteFrame == nil) then
            index = 0
        else
            pAnimation:addSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(str))
            index = index + 1
        end
    end
    pAnimation:setDelayPerUnit(frameDelayTime)
    local pAnimate=CCAnimate:create(pAnimation)
    return pAnimate
end

function Resources.createCheckboxWithSingleFile(szFilePath, nStatus, actionCallback)
    local sprite= CCSprite:create(szFilePath)
    local texture = sprite:getTexture()
    local rect = sprite:getTextureRect()
    local x = rect.origin.x
    local y = rect.origin.y
    local width = rect.size.width / nStatus
    local height = rect.size.height
    local normal = CCSprite:createWithTexture(texture,CCRectMake(x,y,width,height))
    local press = CCSprite:createWithTexture(texture,CCRectMake(x+width,y,width,height))
    local CCCheckbox = require("FFSelftools/CCCheckbox")
    local pCheckBox = CCCheckbox.create(press, normal, false, 0)
    if actionCallback then
        pCheckBox:addHandleOfControlEvent(actionCallback,CCControlEventTouchUpInside)
    end
	return pCheckBox
end

function Resources.createButtonWithSingleFile(szFile,tag,action)
    tag = tag or 0
    local pSprite = CCSprite:create(szFile)
    local nWidth = pSprite:getContentSize().width / 2
    local nHeight = pSprite:getContentSize().height
    local pScal9Normal=CCScale9Sprite:create(szFile,CCRectMake(0,0,nWidth,nHeight))
    local pRetButton=CCControlButton:create(pScal9Normal)
    pRetButton:setPreferredSize(CCSizeMake(nWidth,nHeight))
    pRetButton:setTag(tag)
    --设置其他状态
    local pScal9Press=CCScale9Sprite:create(szFile,CCRectMake(0,0,nWidth,nHeight))
    pRetButton:setBackgroundSpriteForState(pScal9Press, CCControlStateHighlighted)

    --CCSpriteFrame* pFrameDisable=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(szDisableFrameName)
    local pScal9Disable=CCScale9Sprite:create(szFile,CCRectMake(nWidth,0,nWidth,nHeight))
    pRetButton:setBackgroundSpriteForState(pScal9Disable, CCControlStateDisabled)

    pRetButton:setTouchPriority(kCCMenuHandlerPriority)

    --设置监听事件
    if (action ~= nil) then
        pRetButton:addHandleOfControlEvent(action, CCControlEventTouchUpInside)
    end
    return pRetButton
end

Resources.createButtonTwoStatusWithOneFilePath = function(path,tag,action)
    tag = tag or 0

    local tmp=CCSprite:create(path)
    local l_buttonScale9=CCScale9Sprite:create(path)
    l_buttonScale9:setPreferredSize(tmp:getContentSize())
    local l_button=CCControlButton:create(l_buttonScale9)
    l_button:setPreferredSize(tmp:getContentSize())
    l_button:setTouchPriority(kCCMenuHandlerPriority)

    local l_buttonScale9_press=CCScale9Sprite:create(path)
    l_buttonScale9_press:setPreferredSize(tmp:getContentSize())
    l_buttonScale9_press:setColor(Resources.IMAGE_GRAY_COLOR)
    l_button:setBackgroundSpriteForState(l_buttonScale9_press, CCControlStateHighlighted)
    l_button:setTag(tag)

    local l_buttonScale9_disable=CCScale9Sprite:create(path)
    l_buttonScale9_disable:setPreferredSize(tmp:getContentSize())
    l_buttonScale9_disable:setColor(Resources.IMAGE_GRAY_COLOR)
    l_button:setBackgroundSpriteForState(l_buttonScale9_disable, CCControlStateDisabled)

    l_button:setZoomOnTouchDown(false)

    --设置监听事件
    if action ~= nil then l_button:addHandleOfControlEvent(action,CCControlEventTouchUpInside) end
    return l_button
end

Resources.createCheckboxWithSingleFileNormal = function(szFilePath, nStatus)
    local sprite= CCSprite:create(szFilePath)
    local texture = sprite:getTexture()
    local rect = sprite:getTextureRect()
    local x = rect.origin.x
    local y = rect.origin.y
    local width = rect.size.width / nStatus
    local height = rect.size.height
    local normal = CCSprite:createWithTexture(texture,CCRectMake(x,y,width,height))
    local press = CCSprite:createWithTexture(texture,CCRectMake(x+width,y,width,height))
    local CCCheckbox = require("FFSelftools/CCCheckbox")
    return CCCheckbox.create(normal,press,true)
end

Resources.createButtonTwoStatusWithOneFilePath2 = function(path,tag,action)
    tag = tag or 0
    local sprite= CCSprite:create(path)
    local texture = sprite:getTexture()
    local rect = sprite:getTextureRect()

    local x = rect.origin.x
    local y = rect.origin.y
    local width = rect.size.width / 2
    local height = rect.size.height

    local normal = CCSprite:createWithTexture(texture,CCRectMake(x,y,width,height))
    local rectFrame =CCRectMake(x , y , width, height)

    local l_buttonScale9=CCScale9Sprite:create(path,rectFrame)
    l_buttonScale9:setPreferredSize(CCSize(width, height))

    local l_button=CCControlButton:create(l_buttonScale9)
    l_button:setPreferredSize(CCSize(width, height))
    l_button:setTouchPriority(kCCMenuHandlerPriority)
    
    rectFrame.origin.x = rectFrame.origin.x + width
    local l_buttonScale9_press = CCScale9Sprite:create(path,rectFrame)
    l_buttonScale9_press:setPreferredSize(CCSize(width, height))
    l_button:setBackgroundSpriteForState(l_buttonScale9_press, CCControlStateHighlighted) --CCControlStateHighlighted CCControlStateSelected
    
    -- local l_buttonScale9_disable=CCScale9Sprite:create(path,rectFrame)
    -- l_button:setBackgroundSpriteForState(l_buttonScale9_disable, CCControlStateDisabled)

    local l_buttonScale9_disable=CCScale9Sprite:create(path,CCRectMake(x , y , width, height))
    l_buttonScale9_disable:setPreferredSize(CCSize(width, height))
    l_buttonScale9_disable:setColor(ccc3(100,100,100))
    l_button:setBackgroundSpriteForState(l_buttonScale9_disable, CCControlStateDisabled)

    l_button:setZoomOnTouchDown(false)

    return l_button
end


Resources.cutString = function(str, maxWidth, fontName, fontSize)
    if (str == nil) then
        return nil
    end
    require("GameLib/common/common")
    local strArr = SplitString(str)
    local size = #strArr
    if (size <= 2) then
        return str
    end
    local lenCount = 0
    local returnStr = ""
    local bIsOverMaxWidth = false
    local tLabel = CCLabelTTF:create("…", fontName, fontSize)
    local i = 1
    while(i <= size and bIsOverMaxWidth == false) do
    	local pLabel = CCLabelTTF:create(strArr[i], fontName, fontSize)
    	if (lenCount + pLabel:getContentSize().width + tLabel:getContentSize().width < maxWidth) then
    		lenCount = lenCount + pLabel:getContentSize().width
    		returnStr = returnStr .. strArr[i]
    	else
    		bIsOverMaxWidth = true
    	end
        i = i + 1
    end
    if (bIsOverMaxWidth == true) then
	    returnStr = returnStr .. "…"
	end
    return returnStr
end

-- 传入DrawNode对象，画圆角矩形
function Resources.drawNodeRoundRect(drawSprite, rect, borderWidth, radius, color, fillColor)
    local drawNode = CCDrawNode:create()

	-- segments表示圆角的精细度，值越大越精细
	local segments    = 100
	local origin      = ccp(rect.origin.x, rect.origin.y)
	local destination = ccp(rect.origin.x + rect.size.width, rect.origin.y - rect.size.height)
	local points      = {}

	-- 算出1/4圆
	local coef     = math.pi / 2 / segments
	local vertices = {}

	for i=0, segments do
	local rads = (segments - i) * coef
	local x    = radius * math.sin(rads)
	local y    = radius * math.cos(rads)

	table.insert(vertices, ccp(x, y))
	end

	local tagCenter      = ccp(0, 0)
	local minX           = math.min(origin.x, destination.x)
	local maxX           = math.max(origin.x, destination.x)
	local minY           = math.min(origin.y, destination.y)
	local maxY           = math.max(origin.y, destination.y)
	local dwPolygonPtMax = (segments + 1) * 4
	local pPolygonPtArr  = {}

	-- 左上角
	tagCenter.x = minX + radius;
	tagCenter.y = maxY - radius;

	for i=0, segments do
	local x = tagCenter.x - vertices[i + 1].x
	local y = tagCenter.y + vertices[i + 1].y

	table.insert(pPolygonPtArr, ccp(x, y))
	end

	-- 右上角
	tagCenter.x = maxX - radius;
	tagCenter.y = maxY - radius;

	for i=0, segments do
	local x = tagCenter.x + vertices[#vertices - i].x
	local y = tagCenter.y + vertices[#vertices - i].y

	table.insert(pPolygonPtArr, ccp(x, y))
	end

	-- 右下角
	tagCenter.x = maxX - radius;
	tagCenter.y = minY + radius;

	for i=0, segments do
	local x = tagCenter.x + vertices[i + 1].x
	local y = tagCenter.y - vertices[i + 1].y

	table.insert(pPolygonPtArr, ccp(x, y))
	end

	-- 左下角
	tagCenter.x = minX + radius;
	tagCenter.y = minY + radius;

	for i=0, segments do
		local x = tagCenter.x - vertices[#vertices - i].x
		local y = tagCenter.y - vertices[#vertices - i].y

		table.insert(pPolygonPtArr, ccp(x, y))
	end

	if fillColor == nil then
		fillColor = ccc4f(0, 0, 0, 0)
	end

	local points = CCPointArray:create(#pPolygonPtArr)
    for i=1, #pPolygonPtArr do     
        points:addControlPoint(ccp(pPolygonPtArr[i].x, pPolygonPtArr[i].y))
    end

	drawNode:drawPolygon(points:fetchPoints(), points:count(), fillColor, borderWidth, color)

    local pCliper = CCClippingNode:create()
    pCliper:setStencil(drawNode)
    drawSprite:setAnchorPoint(ccp(0.5,0.5))
    drawSprite:setPosition(ccp(rect.size.width / 2, -rect.size.height / 2))
    pCliper:addChild(drawSprite)
    pCliper:setContentSize(rect.size)

    return pCliper
end

function Resources.getSprites(szUrl)
	local pTexture = CCTextureCache:sharedTextureCache():addImage(szUrl)
	local width = pTexture:getContentSize().width / 2
	local height = pTexture:getContentSize().height
	local pSp1 = CCSprite:createWithTexture(pTexture, CCRectMake(0, 0, width, height))
	local pSp2 = CCSprite:createWithTexture(pTexture, CCRectMake(width, 0, width, height))
	--local pSp3 = CCSprite:createWithTexture(pTexture, CCRectMake(width, 0, width, height))
	return pSp1, pSp2
end

function Resources.getSpritesEx(szUrl)
    local pTexture = CCTextureCache:sharedTextureCache():addImage(szUrl)
    local width = pTexture:getContentSize().width
    local height = pTexture:getContentSize().height
    local pSp1 = CCSprite:createWithTexture(pTexture, CCRectMake(0, 0, width, height))
    local pSp2 = CCSprite:createWithTexture(pTexture, CCRectMake(0, 0, width, height))
    --local pSp3 = CCSprite:createWithTexture(pTexture, CCRectMake(width, 0, width, height))
    return pSp1, pSp2
end

--延时处理
function Resources.delayToDeal(parent, fDelayTime, delayDealFunc)
    if (delayDealFunc == nil or parent == nil) then
        return
    end
    fDelayTime = fDelayTime or 0
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(fDelayTime))
    array:addObject(CCCallFunc:create(delayDealFunc))
    parent:runAction(CCSequence:create(array))
end

function Resources.isWIN32()
    return CCApplication:sharedApplication():getTargetPlatform() == kTargetWindows
end

function Resources.split(inputstr, sep)
	if inputstr == nil then
        return {}
    end
	if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function Resources.stringReplace(szContent, beReplaceStr, replaceStr)
    local szStr = string.gsub(szContent, beReplaceStr, replaceStr) 
    return szStr
end

function Resources.getFormatGold(nGold)
    local szGold = string.format("%d", nGold)
    require("GameLib/common/common")
    local strArr = SplitString(szGold)
    local size = #strArr
    local returnStr = ""
    local nIndex = 0
    for i = size, 1, -1 do
        if ((nIndex % 3 == 0) and nIndex ~= 0) then
            returnStr = returnStr .. ",".. strArr[i]
        else
            returnStr = returnStr .. strArr[i]
        end
        nIndex = nIndex + 1
    end
    local returnStr2 = ""
    local strArr2 = SplitString(returnStr)
    local size2 = #strArr2
    for i = size2, 1, -1 do
        returnStr2 = returnStr2 .. strArr2[i]
    end
    return returnStr2
end

function Resources.sendPayCommand(index)
    local HallControl = require("HallControl"):instance()
    local MallInfo = require("zjh/mall/MallInfo")
    local m_bestChargeInfo = MallInfo.getChargeInfoByIndex(index, Resources.MALL_ITEM_TYPE_DIAMON)
    local function payCallback(result)
        local str =""
        if  result==1  then
            str=("充值成功!")
            local gameLib = require("bull/GameLibSink").m_gameLib
            if (gameLib ~= nil) then
                gameLib:refreshGold()
            end
        else
            str= ("充值失败!")
        end
        local DialogMessage =require("FFSelftools/MessageLayer").create(str)
        CCDirector:sharedDirector():getRunningScene():addChild(DialogMessage)
    end
    HallControl:pay(m_bestChargeInfo, payCallback)
end

function Resources.diamondExchangeGold(nDiamond,onNotEnough,onExchangeOK)
    local HallControl = require("HallControl"):instance()
    local function exchangeCallback(result,nExDiamond,nGold)
        if (result == 1) then
            local GameLibSink = require("bull/GameLibSink")
            local gameLib = GameLibSink.m_gameLib
            local gameUserInfo = gameLib:getUserLogonInfo()
            gameUserInfo.dwGold = nGold
            gameLib:refreshGold()
            require("Resources").ShowToast("兑换成功")
            if onExchangeOK then onExchangeOK() end
            CCNotificationCenter:sharedNotificationCenter():postNotification(Resources.NOTIFICATION_UPDATEMYINFO)
        elseif (result == 11) then
            --Resources.ShowToast(Resources.DESC_BUYPROPERTY_NOTENOUGHDIAMON)
            if onNotEnough then onNotEnough() end
        elseif (result == 12) then
            require("Resources").ShowToast(Resources.DESC_BUYPROPERTY_PRODUCTNOTEXIST)
        end
    end
    HallControl:exchangeGold(nDiamond,exchangeCallback,24)
end

function Resources.getIntPart(x)
    if x <= 0 then
       return math.ceil(x)
    end

    if math.ceil(x) == x then
       x = math.ceil(x)
    else
       x = math.ceil(x) - 1
    end
    return x
end

function Resources.calAbsolutePostion(children)
    local x=0
    local y=0
    local point=ccp(0,0)
    if(children) then
        x=children:boundingBox().origin.x
        y=children:boundingBox().origin.y
        local node=children:getParent()
        while (node) do
             x=x+node:boundingBox().origin.x
             y=y+node:boundingBox().origin.y
             node=node:getParent()
        end 
    end
    point.x=x
    point.y=y
    return point
end

function Resources.getSpriteByMoreImg(imgPath,nNum,bIsOrder,nDelayTime,handlerCallBack,bIsRepeat)
    local spriteTemp= CCSprite:create(imgPath)
    local rect = spriteTemp:getTextureRect()
    local x = rect.origin.x
    local y = rect.origin.y
    local width = rect.size.width / nNum
    local height = rect.size.height

    local sprite = CCSprite:create(imgPath)
    sprite:setTextureRect(CCRect(x, y, width, height))
    local pAnimation = CCAnimation:create()
    local tableList ={}
    for  i=1, nNum do
        local frame = CCSpriteFrame:create(imgPath, CCRect(x+(i-1)*width, y, width, height))
        table.insert(tableList, frame)
    end

    if bIsOrder then
        for  i=1, #tableList do
            pAnimation:addSpriteFrame(tableList[i])
        end
    else
        for  i=#tableList,1,-1 do
            pAnimation:addSpriteFrame(tableList[i])
        end
    end
   
    pAnimation:setDelayPerUnit(nDelayTime)
    local pAnimate=CCAnimate:create(pAnimation)
    local arrayActions = CCArray:create()
    if bIsRepeat then
        arrayActions:addObject(CCRepeat:create(pAnimate, 99999))
    else
        arrayActions:addObject(CCRepeat:create(pAnimate, 1))
    end
    if handlerCallBack~= nil then
        arrayActions:addObject(CCCallFuncN:create(handlerCallBack))
    end
    local seq = CCSequence:create(arrayActions)
    sprite:runAction(seq)

    return sprite
end

function Resources.getOneRandom(nRandomMax)
    math.randomseed(os.time())
    local nRand =math.random(1,100000)
    if(nRand<0) then
        nRand=0
    end
    return nRand%nRandomMax
end

function Resources.getStationByRoomType(roomType)
    local gameLib = require("bull/GameLibSink").m_gameLib
    local stationList = gameLib:getStationList()
    if stationList == nil then return nil end
    --cclog("-----------------size = " .. #stationList)
    for i=1,#stationList do
        --cclog("-----------------stationList[i].dwRuleID == " .. stationList[i].dwRuleID .. " roomType == " .. roomType)
        if stationList[i].dwRuleID == roomType then
            return stationList[i]
        end
    end
    return nil
end

function Resources.getNowTime(IsChangeLine)
    IsChangeLine = IsChangeLine or 1
    if (IsChangeLine == 0) then
        return os.date("%Y-%m-%d %H:%M")
    else
        return os.date("%Y-%m-%d\n%H:%M")
    end
end

function Resources.shareCode(nShareCode,szPlayerName)
    if (require("HallUtils").isWxEnabled() == false or require("HallUtils").isWxLogined() == false) then
        require("Resources").ShowToast("您不是使用微信登录,不能使用微信分享功能")
        return
    end

    local szContent = string.format("回放码为【%d】，【%s】邀请您观看【斗牛】中牌局回放记录", nShareCode, szPlayerName)
    local szTitle = "好友@你(观看牌局)"   
    CJni:shareJni():shareWeixin(0,0,nil,0,"",szTitle,szContent)
end

function Resources.inviteFriends(nRoomNo, nPaijuCount, nType, nUserCount, nChairNum)
    if (require("HallUtils").isWxEnabled() == false or require("HallUtils").isWxLogined() == false) then
        require("Resources").ShowToast("您不是使用微信登录,不能使用微信分享功能")
        return
    end
    local szType = ""
    if nType == 0 then
        szType = "看牌抢庄"
    else
        szType = "斗公牛"
    end
    local szPayType = ""
    local GameLibSink = require("bull/GameLibSink")
    if (GameLibSink.s_nPayType == 1) then
        szPayType = "每人付费"
    else
        szPayType = "房主付费"
    end
    local szContent = string.format("房号【%d】,【%s】,【局数：%d局】,【%s】,快来一起玩吧!", nRoomNo,szType,nPaijuCount,szPayType)
    --cclog("-------------szContent = " .. szContent)
    local szTitle =  string.format("(房间号：%d)斗牛@你 %s %d缺%d", nRoomNo, szType, nUserCount, nChairNum-nUserCount)
    --cclog("-------------szTitle = " .. szTitle)
    CJni:shareJni():shareWeixin(0,2,nil,0,
        string.format("%s?game=%s&roomid=%d",Resources.DOWNLOAD_PATH,"bull",nRoomNo),szTitle,szContent)
end

function Resources.ShowToast(szMsg)
    if (szMsg == nil) then
        return
    end
    local scene = CCDirector:sharedDirector():getRunningScene()
    if (scene ~= nil) then
        local node = scene:getChildByTag(Resources.TOAST_LAYER_TAG)
        if (node ~= nil) then
            node:removeFromParentAndCleanup(true)
            node = nil
        end
        local pToast = require("FFSelftools/CCToast").create()
        if (pToast ~= nil) then
            pToast:showToast(szMsg)
            pToast:setTag(Resources.TOAST_LAYER_TAG)
            scene:addChild(pToast,5)
        end
    end
end

function Resources.getEnterBestRoom(lpszStation)
    local server = nil

    local full = 0xFFFF

    local dwFocusStationID = -1

    local nMinGold = 0
    local GameLibSink = require("bull/GameLibSink")
    local gameLib = GameLibSink.m_gameLib
    local logonInfo = gameLib:getUserLogonInfo()

    if (logonInfo == nil) then
        cclog("----------------------logonInfo = nil")
        return
    end

    local pRoomList = gameLib:getStationList()
    local size = #pRoomList
    --cclog("---------------------size = " .. #pRoomList)
    for i = 1, size do
        local room = pRoomList[i]
        local bContinues = true
        if (dwFocusStationID ~= -1) then
            if (room.dwStationID ~= dwFocusStationID) then
                bContinues = false
            end
        end

        if (bContinues == true) then 
            if (room.dwMinGold ~= 0 and room.dwMinGold > logonInfo.dwGold) then
                bContinues = false
            end

            if (bContinues == true) then 
                if (server == nil) then
                    server = room
                end

                local nTempMinGold = room.dwMinGold
                if (nTempMinGold > nMinGold) then
                    server = room
                end
            end
        end
    end
    return server
end

function Resources.enterBestRoom()
    local GameLibSink = require("bull/GameLibSink")
    local pRoomList = GameLibSink.m_gameLib:getStationList()
    local size = #pRoomList
    if (size == 0) then
        return
    end
    local server = Resources.getEnterBestRoom(nil)

    if (server == nil) then
        local arg = {}
        arg.nType = 0
        require("GameLib/common/EventDispatcher"):instance():dispatchEvent(Resources.NOTIFICATION_SHOWNOTENOUGHGOLDDIALOG,arg)
        return
    end

    GameLibSink.m_gameLib:autoEnterGameRoom(server.szStationName)
    GameLibSink.s_nBackType = GameLibSink.BACKTYPE_PUBLICROOM
    require("Resources").showLoadingLayer()
end

function Resources.formatGold2(gold)
    
    if(gold<1000) then
        return string.format("%d",gold)
        
    elseif(gold<10000) then
         
         if (gold%1000)~=0 then
            return string.format(Resources.str_k_dot_fmt,(gold/1000.0))
         else
            return string.format(Resources.str_k_fmt,(gold/1000))
         end
         
    else
        if((gold%10000)~=0) then
        
            return string.format(Resources.str_w_dot_fmt,gold/10000.0)
        else
            return string.format(Resources.str_w_fmt,gold/10000)
        end
        
    end
end

function Resources.getFriendInfo(nToUserID,handle)
	local szData = string.format("UserID=%d&GameID=%d",nToUserID,0)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then 
			cclog("HallWebRequest.getFriendInfo(...) failed") 
			if handle then handle(nil) end
			return 
		end		
		local root,result,nResult = require("HallWebRequest").getRootAndResult(data)
		local pTask = root and root:FirstChildElement("user") or nil
		local p  = require("GameLib/common/FriendInfo"):new()
		if pTask then
			p.nUserID = SAFEATOI(pTask:QueryInt("userid"))
			p.nFaceID = SAFEATOI(pTask:QueryInt("faceid"))
			p.nGold = SAFEATOI(pTask:QueryInt("Gold"))
			p.nVipLevel = SAFEATOI(pTask:QueryInt("viplevel"))
			p.bMale = SAFEATOI(pTask:QueryInt("Sex")) == 1
			p.cbFaceChangeIndex = SAFEATOI(pTask:QueryInt("Changed"))
			p.szNickName = SAFESTRING(pTask:QueryString("nickname"))
			p.szRoomName = SAFESTRING(pTask:QueryString("roomname"))
			p.nWinRate = SAFEATOI(pTask:QueryInt("WinRate"))
			p.szUserWord = SAFESTRING(pTask:QueryString("UserWord"))
			p.nWeekWinAmount = SAFEATOI(pTask:QueryInt("weekWinAmount"))
			p.nMaxWinAmount = SAFEATOI(pTask:QueryInt("maxWinAmount"))
			p.nGuess = SAFEATOI(pTask:QueryInt("guess"))
			p.nTotalCount = SAFEATOI(pTask:QueryInt("TotalCount"))			
			p.nExps = SAFEATOI(pTask:QueryInt("Exps"))
			p.nGrade = SAFEATOI(pTask:QueryInt("nGrade"))
		end		
		if handle then handle(p) end
	end
	require("bull/GameLibSink").m_gameLib:httpRequest("GetApplyFriendUserInfo.aspx",szData, 0, httpCallback)
end

function Resources.isUseRoomCard()
    return false
end

return Resources