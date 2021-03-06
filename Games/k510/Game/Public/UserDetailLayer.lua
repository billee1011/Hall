require("CocosExtern")
local Resources =require("k510/Resources")
local CCButton = require("FFSelftools/CCButton")

local UserDetailLayer = class("UserDetailLayer",function()
    return CCLayer:create()
end)

UserDetailLayer._StartPos = ccp(0,0)

function UserDetailLayer.create()
    local layer = UserDetailLayer.new()
    layer:init()
	return layer
end

function UserDetailLayer:onTouchBegan(x,y)
   self._StartPos = ccp(x,y) 
end

function UserDetailLayer:onEnded(x,y)
    local enPos = ccp(x,y)
    local delta = 5.0
    if math.abs (enPos.x - self._StartPos.x) > delta or math.abs (enPos.y - self._StartPos.y) > delta then
        --not click
		self._StartPos = ccp(-1,-1)
		return
    end
    
    if (enPos.x < 340 or enPos.x > 940 ) or (enPos.y < 220 or enPos.y > 500) then
        self:hide()
    end

end

function UserDetailLayer:init()
    self.winSize = CCSizeMake(require("k510/GameDefs").CommonInfo.View_Width, require("k510/GameDefs").CommonInfo.View_Height)

    local function onTouch(eventType ,x ,y)
        if eventType=="began" then
            self:onTouchBegan(x,y)
            return true
       elseif eventType=="ended" then
            self:onEnded(x,y)
        end
    end

    --self:setTouchEnabled(true)
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)

    --背景
    bgSize = CCSizeMake(600, 280)
    
    bg = loadSprite("common/popBg.png", true)
    bg:setPosition(self.winSize.width/2,self.winSize.height/2)
    bg:setPreferredSize(bgSize)
    self:addChild(bg)
    
    --头像框
    local headBg = loadSprite("ui/headframe.png", true)
    headBg:setPreferredSize(CCSizeMake(160,160))
    bg:addChild(headBg)
    headBg:setPosition(120,bgSize.height/2)

    self.head = loadSprite("ui/headbig0.png")
    headBg:addChild(self.head)
    self.head:setPosition(headBg:getContentSize().width/2,headBg:getContentSize().height / 2)

    --关闭按钮
    self.closeBtn = CCButton.createWithFrame("common/btnClose.png",false,function()
        self:hide()
    end)
    bg:addChild(self.closeBtn)
    self.closeBtn:setPosition(ccp(bgSize.width - 20,bgSize.height - 20))

    --label
    --昵称
    local nickLabel = CCLabelTTF:create("昵称:","",28,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    nickLabel:setAnchorPoint(0.0,0.0)
    bg:addChild(nickLabel)
    nickLabel:setPosition(ccp(bgSize.width/2 - 72, bgSize.height/2 + 50))
    nickLabel:setColor(ccc3(156,51,47))

     --Id
    local idLabel = CCLabelTTF:create("I  D:","",28,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    idLabel:setAnchorPoint(0.0,0.0)
    bg:addChild(idLabel)
    idLabel:setPosition(ccp(bgSize.width/2 - 72, bgSize.height/2 - 10))
    idLabel:setColor(ccc3(156,51,47))

     --Ip
    local ipLabel = CCLabelTTF:create("I  P:","",28,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    ipLabel:setAnchorPoint(0.0,0.0)
    bg:addChild(ipLabel)
    ipLabel:setPosition(ccp(bgSize.width/2 - 72, bgSize.height/2 - 70))
    ipLabel:setColor(ccc3(156,51,47))

    --玩家 昵称 ID  IP
    self.userNickName = CCLabelTTF:create("","",30,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.userNickName:setAnchorPoint(0.0,0.0)
    bg:addChild(self.userNickName)
    self.userNickName:setPosition(ccp(bgSize.width/2+10, bgSize.height/2 + 50))
    self.userNickName:setColor(ccc3(136,103,73))

    self.userID = CCLabelTTF:create("119120110","",30,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.userID:setAnchorPoint(0.0,0.0)
    bg:addChild(self.userID)
    self.userID:setPosition(ccp(bgSize.width/2+10, bgSize.height/2 - 10))
    self.userID:setColor(ccc3(136,103,73))

    self.userIP = CCLabelTTF:create("未知","",30,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.userIP:setAnchorPoint(0.0,0.0)
    bg:addChild(self.userIP)
    self.userIP:setPosition(ccp(bgSize.width/2+10, bgSize.height/2 - 70 ))
    self.userIP:setColor(ccc3(136,103,73))

end

function UserDetailLayer:show()
	self:setVisible(true)
    self:setTouchEnabled(true)
    self.closeBtn:setTouchEnabled(true)
end

function UserDetailLayer:hide()
	self:setVisible(false)
    self.closeBtn:setTouchEnabled(false)
    self:setTouchEnabled(false)
end

function UserDetailLayer:setUserInfo(userInfo)
    local GameLogic = require("k510/Game/GameLogic")
    local dbId = userInfo:getUserDBID()
    local sp = require("FFSelftools/CCUserFace").create(dbId,CCSizeMake(140,140),userInfo:getSex())
    local t = sp:getTexture()
    local tw, th = t:getContentSize().width, t:getContentSize().height
    self.head:setTexture(t)
    self.head:setTextureRect(CCRectMake(0, 0, tw, th))
    self.head:setScaleX(140 / tw)
    self.head:setScaleY(140 / th)
    
    self.userNickName:setString(userInfo:getUserName())
    self.userID:setString(string.format("%d",dbId))
    self.userIP:setString(userInfo._userIP)
    self:show()
end

return UserDetailLayer