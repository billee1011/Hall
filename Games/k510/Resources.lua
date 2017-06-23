--
require("CocosExtern")
require("CocosAudioEngine")
local Resources = {}

Resources.__index =Resources

Resources.TOMORROWAYN_CHANNEL_GOODID_8 ="Ming8"

Resources.FONT_ARIAL = "Arial"
Resources.FONT_BLACK = "黑体"

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
Resources.NOTIFICATION_SHOWENTERPRIVATEROOMCOSTTIPSDIALOG = "showEnterPrivateRoomCostTipsDialog" --显示进入私人房花费金币提示
Resources.NOTIFICATION_SHOWNOTENOUGHGOLDDIALOG = "showNotEnoughGoldDialog" --显示金币不足提示框
Resources.NOTIFICATION_SHOWTIPSDIALOG = "showTipsDialog" --显示提示框
Resources.NOTIFICATION_SHOWFRIENDINFO = "showFriendInfo" --显示好友信息
Resources.NOTIFICATION_REQUESTBINDCODE = "requestBindCode" --请求绑定推荐码信息

Resources.NOTIFYCATION_USERENTER = "userenter"
Resources.NOTIFYCATION_USEREXIT = "userexit"

Resources.NOTIFYCATION_USERCHAT = "userChat"
Resources.NOTIFYCATION_SYSTEMCHAT = "systemChat"

Resources.NOTIFYCATION_DISSOLVEROOM = "dissolveroom"
Resources.NOTIFYCATION_LEAVEROOM = "leaveroom"

--得到了房间规则
Resources.NOTIFYCATION_DESKRULE = "deskrule"
--显示玩家详情
Resources.NOTIFYCATION_SHOWUSERDETAILS = "showuserdetails"
--显示小结算
Resources.NOTIFYCATION_SHOWONEGAMERESULT = "showonegameresult"

--//描述语言集合
Resources.DESC_ENTERPRIVATEROOMCOSTTIPS = "房间号【%d】为4人支付\n模式，进入房间需消耗钻石。\n请选择是否加入？"

Resources.DESC_ENTERPRIVATEROOMFAIL = "房间已满或输入房间号错误，房间号为六位数字，请确认是否该房间已满人或房间号输入错误。"
Resources.DESC_DISSOLVEROOMBYME = "您确定要解散房间吗？"
Resources.DESC_DISSOLVEROOMBYOTHER = "有玩家请求解散房间，您同意吗？"

Resources.Resources_Head_Path = "k510/Resources/"

Resources.Img_Path = "k510/images/"

Resources.BgVolume = 0.5
Resources.EffectVolume = 0.5
--声音文件  end


-- 通用组件TAG
Resources.Tag = { }

--welcomescene
Resources.Tag.WELCOME_SCENE_TAG = 100
Resources.Tag.WELCOME_SCENE_LAYER_TAG = 101

--mainscene
Resources.Tag.MAIN_SCENE_TAG = 102
Resources.Tag.MAIN_SCENE_LAYER_TAG = 103-- 放置在MAIN_SCENE下的主要layer的Tag

--deskscene
Resources.Tag.DESK_SCENE_TAG = 104
Resources.Tag.DESK_SCENE_LAYER_TAG = 105-- 放置在MAIN_SCENE下的主要layer的Tag


--头像
Resources.Tag.USER_HEAD_TAG = 1000

--SetLayer
Resources.Tag.SET_LAYER_TAG = 1001

--TipLayer
Resources.Tag.TIP_LAYER_TAG = 1002

--ShopLayer
Resources.Tag.SHOP_LAYER_TAG = 1003

--LoadingLayer
Resources.Tag.LOADING_LAYER_TAG = 1004

--播放音效
function Resources.playEffect(filename,isLoop)
    require("AudioEngine")
    local set_effsct = CCUserDefault:sharedUserDefault():getStringForKey("set_bgEffct")
    if set_effsct == "true" then
        AudioEngine.playEffect(filename, isLoop)
    end
end

--播放背景音乐
function Resources.playMusic(isInDesk,isMusicOpen)
    if (AudioEngine.isMusicPlaying() == true) then
        AudioEngine.stopMusic(true)
	end
    local musicPath = ""
    if (isInDesk == true) then
        musicPath = "resources/music/gaming.mp3"
    end

    if (isMusicOpen == "true") then
        volumn = Resources.BgVolume
        AudioEngine.setMusicVolume(volumn)    
	    AudioEngine.playMusic(musicPath, true)
    end
end

function Resources.setEffectOpen(isEffectOpen)
    if (isEffectOpen == "false") then
		AudioEngine.pauseAllEffects()
	else
		AudioEngine.resumeAllEffects()
        AudioEngine.setEffectsVolume(Resources.EffectVolume)
	end
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

function Resources.Pub_IsValidChair(cbChair) 
	return (cbChair < require("k510/Game/Common").PLAYER_COUNT and cbChair >= 0)
end

function Resources.ShowMessage (msg)
	--CCLog("ShowMessage %s", msg);
    --进行过滤某些信息
	if (msg == nil) then
        return
    end
    local index, index2 = string.find(msg, "束后您将消耗")
	if (index ~= nil and index>= 0 and index2 ~= nil and index2 >= 0) then
		return
    end

	local pScene = CCDirector:sharedDirector():getRunningScene()

	if (pScene:getChildByTag(1001) ~= nil) then
		pScene:removeChildByTag(1001,true)
	end
    local MessageLayer = require("FFSelftools/MessageLayer")
	local msglayer = MessageLayer.create(msg)
	msglayer:setTag(1001)
	pScene:addChild(msglayer)
end

function Resources.inviteFriends(nRoomNo, nPaijuCount)

    local szPlayType = ""
    local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
    if FriendGameLogic.my_rule[3][2] == 1 then
       szPlayType = "首局先出黑桃三"
    else

    end

    local szContent = string.format("【跑得快】，房号：【%d】，局数：【%d】，【%s】，赶紧来玩吧！", FriendGameLogic.invite_code, FriendGameLogic.my_rule[2][2], szPlayType)
    local Jni = CJni:shareJni()
    -- CJni:shareJni():shareWeixin(0,2,nil,0,string.format("%s?game=%s&roomid=%d", Resources.DOWNLOAD_PATH, "k510", nRoomNo),"好友@你(跑得快)",szContent, function() end)
end

function Resources.shareScreenShot(layer)
    local filePath = getScreenShot(layer)
    if filePath == nil then
        cclog("getScreenShot filePath == nil")
    else
        cclog("getScreenShot filePath %s",filePath)
        -- CJni:shareJni():shareWeixin(0,2,nil,0,filePath,"","", function() end)
    end
end

return Resources
