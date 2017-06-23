require("CocosExtern")

local CCUserFace = require("FFSelftools/CCUserFace")
local Resources = require("bull/Resources")

local PrivateRoomTotalSettleCellItem = class("PrivateRoomTotalSettleCellItem", function(isMySelf)
	--return CCSprite:create(Resources.Resources_Head_Url .. "DeskScene/totalsettle/di1.png")
	return loadSprite("bull/di.png")
	
end)

function PrivateRoomTotalSettleCellItem:init(stSingleSettle,nHouseDBID,isMySelf)

	local nDBID = stSingleSettle.UserID
	local contentSize = self:getContentSize()

   
	self.mark = nil
	if isMySelf then 
		self.mark = loadSprite("bull/kuang2.png",true)
		self.mark:setAnchorPoint(ccp(0,0))
		self.mark:setPosition(ccp(-3, -3))
		self:addChild(self.mark)
		require("Lobby/Common/AnimationUtil").runFlickerAction(self.mark, true)
	end
    self.m_pUserFace = nil
	self.m_pUserFace = CCUserFace.create(nDBID,CCSizeMake(90,90),stSingleSettle.Sex)
 
	self.m_pUserFace:setPosition(ccp(58, contentSize.height - 67))
	self:addChild(self.m_pUserFace)

    if nDBID == nHouseDBID then
        local fangZhuIconSp = loadSprite("bull/rom_owner.png")
		CCSprite:create(Resources.Resources_Head_Url .. "DeskScene/fangZhu.png")
        fangZhuIconSp:setAnchorPoint(ccp(0,0))
        fangZhuIconSp:setPosition(ccp(8,contentSize.height-120))
        self:addChild(fangZhuIconSp)
    end

	local ccLabelColor1 = ccc3(255,255,255)

	local strName = ""
    if stSingleSettle.UserNickName ~=nil then
        strName = stSingleSettle.UserNickName
    end

    strName = Resources.cutString(strName, 130, Resources.FONT_BLACK, 24)
	local pLabelName = CCLabelTTF:create(strName, Resources.FONT_BLACK, 24)
	pLabelName:setColor(ccLabelColor1)
    pLabelName:setHorizontalAlignment(kCCTextAlignmentLeft)
    pLabelName:setAnchorPoint(ccp(0, 0.5))
    pLabelName:setPosition(ccp(102,415))
    self:addChild(pLabelName)

    local pLabelID = CCLabelTTF:create(string.format("ID:%d", nDBID), Resources.FONT_BLACK, 26)
    pLabelID:setHorizontalAlignment(kCCTextAlignmentLeft)
    pLabelID:setAnchorPoint(ccp(0,0.5))
    pLabelID:setPosition(ccp(102, 385))
    self:addChild(pLabelID)

    if (stSingleSettle.bIsMaxWinner ~= nil) then
    	local pSpMaxWinner = loadSprite("bull/dayingja.png")
    	pSpMaxWinner:setAnchorPoint(ccp(0.5,0))
    	pSpMaxWinner:setPosition(ccp(contentSize.width / 2,90))
    	self:addChild(pSpMaxWinner)
    end

    local nDstY = 30


    local pLabel7 = CCLabelTTF:create(string.format("胜利次数\t%7d", stSingleSettle.RuleScoreInfo.WinCnt), Resources.FONT_BLACK, 27)
    pLabel7:setAnchorPoint(ccp(0,0.5))
	pLabel7:setPosition(ccp(15, 285))
	pLabel7:setHorizontalAlignment(kCCTextAlignmentLeft)
    self:addChild(pLabel7)
    pLabel7:setColor(ccLabelColor1)

    local pLabel8 = CCLabelTTF:create(string.format("通杀次数\t%7d", stSingleSettle.RuleScoreInfo.TsCnt), Resources.FONT_BLACK, 27)
    pLabel8:setAnchorPoint(ccp(0,0.5))
	pLabel8:setPosition(ccp(15, 240))
	pLabel8:setHorizontalAlignment(kCCTextAlignmentLeft)
    self:addChild(pLabel8)
    pLabel8:setColor(ccLabelColor1)

	local nNiuNiuYiShangCount = stSingleSettle.RuleScoreInfo.Type5Min + stSingleSettle.RuleScoreInfo.Type5Jqk +
	stSingleSettle.RuleScoreInfo.TypeBomb + stSingleSettle.RuleScoreInfo.Type10
    local pLabel9 = CCLabelTTF:create(string.format("牛牛以上\t%7d",nNiuNiuYiShangCount), Resources.FONT_BLACK, 27)
    pLabel9:setAnchorPoint(ccp(0,0.5))
	pLabel9:setPosition(ccp(15, 195))
	pLabel9:setHorizontalAlignment(kCCTextAlignmentLeft)
    self:addChild(pLabel9)
    pLabel9:setColor(ccLabelColor1)

    local pTotalScoreSp = loadSprite("bull/text_totalscore.png")
    pTotalScoreSp:setAnchorPoint(ccp(0.5,0.5))
    pTotalScoreSp:setPosition(ccp(contentSize.width / 2,76))
    self:addChild(pTotalScoreSp)

    local pLabelTotalScore = CCLabelTTF:create(stSingleSettle.Score, Resources.FONT_BLACK, 32)
    pLabelTotalScore:setAnchorPoint(ccp(0.5,0.5))
    pLabelTotalScore:setHorizontalAlignment(kCCTextAlignmentCenter)
    pLabelTotalScore:setPosition(ccp(contentSize.width / 2, 30))
    self:addChild(pLabelTotalScore)
    pLabelTotalScore:setColor(ccc3(255, 255, 0))
end

function PrivateRoomTotalSettleCellItem.create(stSingleSettle,nHouseDBID,isMySelf)
	local pItem = PrivateRoomTotalSettleCellItem.new(isMySelf)
	pItem:init(stSingleSettle,nHouseDBID,isMySelf)
	return pItem
end

return PrivateRoomTotalSettleCellItem