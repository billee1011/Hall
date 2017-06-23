require("CocosExtern")

local Resources = require("bull/Resources")

local VipIconTypeButton = class("VipIconTypeButton",function()
        return CCControlButton:create()
    end)

function VipIconTypeButton:init(nVipLevel)
    self.m_nVipLevel = nVipLevel;
    self.m_pVipIcon = CCSprite:create(Resources.Resources_Head_Url .. "public/VIP.png")
    self.m_pLevelSprite = CCLabelAtlas:create("" .. nVipLevel, Resources.Resources_Head_Url .. "public/VipNum.png", 25, 34, 45)
    local width = self.m_pVipIcon:getContentSize().width + self.m_pLevelSprite:getContentSize().width
    local x = 0
    self:setPreferredSize(CCSizeMake(width, self.m_pVipIcon:getContentSize().height))
	self:setContentSize(CCSizeMake(width, self.m_pVipIcon:getContentSize().height))
    self.m_pVipIcon:setPosition(ccp(x , 0))
	x = x + self.m_pVipIcon:getContentSize().width * 0.5
    self.m_pLevelSprite:setPosition(ccp(x, -self.m_pLevelSprite:getContentSize().height / 2))
    self:addChild(self.m_pVipIcon)
	self:addChild(self.m_pLevelSprite)
end

function VipIconTypeButton:setLevel(nVipLevel)
	self.m_nVipLevel = nVipLevel

    self.m_pLevelSprite:setString(nVipLevel)
    local width = self.m_pVipIcon:getContentSize().width + self.m_pLevelSprite:getContentSize().width
    local x = 0
    self:setPreferredSize(CCSizeMake(width, self.m_pVipIcon:getContentSize().height))
	self:setContentSize(CCSizeMake(width, self.m_pVipIcon:getContentSize().height))
    self.m_pVipIcon:setPosition(ccp(x , 0))
	x = x + self.m_pVipIcon:getContentSize().width * 0.5
    self.m_pLevelSprite:setPosition(ccp(x, -self.m_pLevelSprite:getContentSize().height / 2))
end

function VipIconTypeButton.create(nVipLevel)
    local button = VipIconTypeButton.new()
    if (button == nil) then
        return nil
    end
    button:init(nVipLevel)
    return button
end

return VipIconTypeButton