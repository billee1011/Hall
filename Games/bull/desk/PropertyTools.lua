
local Resources = require("bull/Resources")

st_Property_Item = {}
st_Property_Item.__index = st_Property_Item

function st_Property_Item.new()
	local self = {
		nDiamondAmount = 0,
		nToolNum = 0,
		nToolID = 0,
		nToolType = 0,
		szProductName = "szProductName",
		nProduceID = 0
	}

	setmetatable(self, st_Property_Item)
	return self
end

function st_Property_Item:create(buffer)
	local self = st_Property_Item.new()

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.nDiamondAmount = ba:readInt()
	self.nToolNum = ba:readInt()
	self.nToolID = ba:readInt()
	self.nToolType = ba:readInt()
	self.szProductName = ba:readString(32)
	self.nProduceID = ba:readInt()

	return self
end

function st_Property_Item:getLen()
	return 4 + 4 + 4 + 4 + 32 + 4
end

-- struct st_PropertyInfo
-- {
-- 	//	<ToolCard ImageID="1" Memo="使用踢人卡可以踢掉你不喜欢的玩家，踢不同级别的VIP玩家需要不同数量的踢人卡" CardName="踢人卡" CardID="401"/>
-- 	int nImageID
-- 	char szMemo[256]
-- 	char szCardName[32]
-- 	int nCardID
-- 	st_PropertyInfo()
-- 	{
-- 		memset(this, 0, sizeof(st_PropertyInfo))
-- 	}
-- }
st_PropertyInfo = {}
st_PropertyInfo.__index = st_PropertyInfo

function st_PropertyInfo:new()
	local self = {
		nImageID = 0,
		szMemo = "szMemo0",
		szCardName = "szCardName",
		nCardID = 0
	}

	setmetatable(self, st_PropertyInfo)
	return self
end

function st_PropertyInfo:create(buffer)
	local self = st_PropertyInfo.new()

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.nImageID = ba:readInt()
	self.szMemo = ba:readString(256)
	self.szCardName = ba:readString(32)
	self.nCardID = ba:readInt()

	return self
end

function st_PropertyInfo:getLen()
	return 4 + 256 + 32 + 4
end

-- struct st_PropertyInfo_Time
-- {
-- 	//	<Emote ImageID="1" Memo="购买后能够使用7天可爱猫表情" ExpireDays="7" EmoteName="可爱猫" EmoteID="601"/>
-- 	int nImageID
-- 	char szMemo[256]
-- 	int nExpireDays
-- 	char szEmoteName[32]
-- 	int nEmoteID
-- 	st_PropertyInfo_Time()
-- 	{
-- 		memset(this, 0, sizeof(st_PropertyInfo_Time))
-- 	}
-- }
st_PropertyInfo_Time = {}
st_PropertyInfo_Time.__index = st_PropertyInfo_Time

function st_PropertyInfo_Time:new()
	local self = {
		nImageID = 0,
		szMemo = "szMemo0",
		nExpireDays = 0,
		szEmoteName = "szEmoteName",
		nEmoteID = 0
	}

	setmetatable(self, st_PropertyInfo_Time)
	return self
end

function st_PropertyInfo_Time:create(buffer)
	local self = st_PropertyInfo_Time.new()

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.nImageID = ba:readInt()
	self.szMemo = ba:readString(256)
	self.nExpireDays = ba:readInt()
	self.szEmoteName = ba:readString(32)
	self.nEmoteID = ba:readInt()

	return self
end

function st_PropertyInfo_Time:getLen()
	return 4 + 256 + 4 + 32 + 4
end

-- //道具拥有信息
-- struct st_PropertyOwer_Info
-- {
-- 	int nToolCardID
-- 	int nCount
-- 	st_PropertyOwer_Info()
-- 	{
-- 		memset(this, 0, sizeof(st_PropertyOwer_Info))
-- 	}
-- }
st_PropertyOwer_Info = {}
st_PropertyOwer_Info.__index = st_PropertyInfo_Time

function st_PropertyOwer_Info:new()
	local self = {
		nToolCardID = 0,
		nCount = 0
	}

	setmetatable(self, st_PropertyOwer_Info)
	return self
end

function st_PropertyOwer_Info:create(buffer)
	local self = st_PropertyOwer_Info.new()

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.nToolCardID = ba:readInt()
	self.nCount = ba:readInt()

	return self
end

function st_PropertyOwer_Info:getLen()
	return 4 + 4
end

-- struct st_Property_Use_Status_Info
-- {
-- //	<Emote Enabled="1" EmoteID="601"/>
-- 	int nEnabled
-- 	int nEmoteID

-- 	st_Property_Use_Status_Info()
-- 	{
-- 		memset(this, 0, sizeof(st_Property_Use_Status_Info))
-- 	}
-- }
st_Property_Use_Status_Info = {}
st_Property_Use_Status_Info.__index = st_Property_Use_Status_Info

function st_Property_Use_Status_Info:new()
	local self = {
		nEnabled = 0,
		nEmoteID = 0
	}

	setmetatable(self, st_Property_Use_Status_Info)
	return self
end

function st_Property_Use_Status_Info:create(buffer)
	local self = st_Property_Use_Status_Info.new()

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.nEnabled = ba:readInt()
	self.nEmoteID = ba:readInt()

	return self
end

function st_Property_Use_Status_Info:getLen()
	return 4 + 4
end

PropertyTools = class("PropertyTools")
--PropertyTools.__index = PropertyTools

function PropertyTools:getRootAndResult(data)
    local xml = tinyxml:new()
	xml:LoadMemory(data)
	local root = xml:FirstChildElement("root")
	local result = root:FirstChildElement("result")
    return root,result,nResult
end

function PropertyTools:requestPropertyList()
	local function onRequestPropertyListFinish(isSucceed,tag,data)
		if (isSucceed == true) then
			--访问成功
			local size = #self.m_vPropertyList
			if (size > 0) then
				self.m_vPropertyList = {}
			end

			local root,result,nResult = self:getRootAndResult(data)
			cclog("requestPropertyList")
			local pTask = root and root:FirstChildElement("Product") or nil	

			while pTask do
				--<Product DiamondAmount="2" ToolNum="10" ToolID="401" ToolType="4" ProductName="踢人卡" ProductID="1"/>
				local item = st_Property_Item:new()
				item.nDiamondAmount = tonumber(pTask:QueryInt("DiamondAmount") , 10)
				item.nToolNum = tonumber(pTask:QueryInt("ToolNum") , 10)
				item.nToolID = tonumber(pTask:QueryInt("ToolID") , 10)
				item.nToolType = tonumber(pTask:QueryInt("ToolType") , 10)
				item.szProductName = pTask:QueryString("ProductName")
				item.nProduceID = tonumber(pTask:QueryInt("ProductID") , 10)

				table.insert(self.m_vPropertyList, item)

				pTask = pTask:NextSiblingElement()
			end
		end
	end

    self.gameLib:httpRequest("DiamondProductList.aspx", nil, 0, onRequestPropertyListFinish)
end

function PropertyTools:requestPropertyInfoList()  --请求道具信息列表
	local function onRequestPropertyInfoListFinish(isSucceed,tag,data)
		if (isSucceed == true) then
			local size = #self.m_vPropertyInfoList
			if (size > 0) then
				self.m_vPropertyInfoList = {}
			end

			local root,result,nResult = self:getRootAndResult(data)
			cclog("requestPropertyInfoList")
			local pTask = root and root:FirstChildElement("ToolCard") or nil

			while (pTask ~= nil) do
				local item = st_PropertyInfo:new()
				item.nImageID = tonumber(pTask:QueryInt("ImageID") , 10)
				item.szMemo = pTask:QueryString("Memo")
				item.szCardName = pTask:QueryString("CardName")
				item.nCardID = tonumber(pTask:QueryInt("CardID") , 10)
				table.insert(self.m_vPropertyInfoList , item)

				pTask = pTask:NextSiblingElement()
			end
		end
	end

    self.gameLib:httpRequest("ToolCardSysList.aspx", nil, 0, onRequestPropertyInfoListFinish)
end

function PropertyTools:requestPropertyInfoTimeList()  --//请求限时道具信息列表
	local function onRequestPropertyInfoTimeListFinish(isSucceed,tag,data)
		if (isSucceed == true) then
			local size = #self.m_vPropertyInfoTimeList
			if (size > 0) then
				self.m_vPropertyInfoTimeList = {}
			end

			local root,result,nResult = self:getRootAndResult(data)
			cclog("requestPropertyInfoTimeList")
			local pTask = root and root:FirstChildElement("Emote") or nil

			while (pTask ~= nil) do
				local item = st_PropertyInfo_Time:new()
				item.nImageID = tonumber(pTask:QueryInt("ImageID") , 10)
				item.szMemo = pTask:QueryString("Memo")
				item.nExpireDays = tonumber(pTask:QueryInt("ExpireDays") , 10)
				item.EmoteName = pTask:QueryString("EmoteName")
				item.nEmoteID = tonumber(pTask:QueryInt("EmoteID") , 10)

				table.insert(self.m_vPropertyInfoTimeList , item)

				pTask = pTask:NextSiblingElement()
			end
		end
	end

    self.gameLib:httpRequest("EmoteSysList.aspx", nil, 0, onRequestPropertyInfoTimeListFinish)
end

function PropertyTools:requestPropertyOwerInfoList()  --//请求道具拥有信息列表
	local pLogonInfo = require("HallControl"):instance():getPublicUserInfo()
	if (pLogonInfo == nil) then
		return
	end
	local szData = string.format("UserID=%d", pLogonInfo.userDBID)

	local function onRequestPropertyOwerInfoListFinish(isSucceed,tag,data)
		if (isSucceed == true) then
			local size = #self.m_vPropertyOwerInfoList
			if (size > 0) then
				self.m_vPropertyOwerInfoList = {}
			end

			local root,result,nResult = self:getRootAndResult(data)
			cclog("requestPropertyOwerInfoList")
			local pTask = root and root:FirstChildElement("ToolCard") or nil

			while (pTask ~= nil) do
				local item = st_PropertyOwer_Info:new()
				item.nCount = tonumber(pTask:QueryInt("CardNum") , 10)
				item.nToolCardID = tonumber(pTask:QueryInt("CardID") , 10)

				table.insert(self.m_vPropertyOwerInfoList , item)

				pTask = pTask:NextSiblingElement()
			end

            CCNotificationCenter:sharedNotificationCenter():postNotification(Resources.NOTIFICATION_REFRESHPROPERTYNUM)
		end
	end

    self.gameLib:httpRequest("ToolCardList.aspx", szData, 0, onRequestPropertyOwerInfoListFinish)
end

function PropertyTools:requestPropertyUseStatusInfoList()  --//请求使用道具状态列表
	local pLogonInfo = require("HallControl"):instance():getPublicUserInfo()
	if (pLogonInfo == nil) then
		return
	end
	local szData = string.format("UserID=%d", pLogonInfo.userDBID)

	local function onRequestPropertyUseStatusInfoListFinish(isSucceed,tag,data)
		if (isSucceed == true) then
			local size = #self.m_vPropertyUserStatusInfoList
			if (size > 0) then
				self.m_vPropertyUserStatusInfoList = {}
			end

			local root,result,nResult = self:getRootAndResult(data)
			cclog("requestPropertyUseStatusInfoList")
			local pTask = root and root:FirstChildElement("Emote") or nil

			while (pTask ~= nil) do
				local item = st_Property_Use_Status_Info:new()
				item.nEnabled = tonumber(pTask:QueryInt("Enabled") , 10)
				item.nEmoteID = tonumber(pTask:QueryInt("EmoteID") , 10)

				table.insert(self.m_vPropertyUserStatusInfoList , item)

				pTask = pTask:NextSiblingElement()
			end
		end
	end

    self.gameLib:httpRequest("EmoteList.aspx", szData, 0, onRequestPropertyUseStatusInfoListFinish)
end

function PropertyTools:requestBuyProperty(nProductID,handle,nCost) --//请求购买道具
	Resources.ShowLoadingLayer()
	local pLogonInfo = require("HallControl"):instance():getPublicUserInfo()
	if (pLogonInfo == nil) then
		return
	end
	local szData = string.format("UserID=%d&ProductID=%d", pLogonInfo.userDBID, nProductID)
	local function onRequestBuyPropertyFinish(isSucceed,tag,data)
        Resources.HideLoadingLayer()
		if (isSucceed == true) then
			local size = #self.m_vPropertyUserStatusInfoList
			if (size > 0) then
				self.m_vPropertyUserStatusInfoList = {}
			end

            local xml = tinyxml:new()
	        xml:LoadMemory(data)
	        --cclog("xml new tag = " .. string.sub(data,1,100))
	        local root = xml:FirstChildElement("root")
	        local result = root:QueryInt("result")

			if (result == 1) then
				self:requestPropertyOwerInfoList()
                self:requestPropertyUseStatusInfoList()
                
				self.gameLib:refreshGold()
				Resources.ShowToast(Resources.DESC_BUYPROPERTY_SUCCESS)
				if handle then 
					if nCost then 
						pLogonInfo.nDiamond = pLogonInfo.nDiamond - nCost
					end
					handle() 
				end
			elseif (result == 11) then
				Resources.ShowToast(Resources.DESC_BUYPROPERTY_PRODUCTNOTEXIST)
			elseif (result == 12) then
				Resources.ShowToast(Resources.DESC_BUYPROPERTY_NOTENOUGHDIAMON)
			end
		else
			--请求失败，生成虚拟数据
			Resources.ShowMessage(Resources.DESC_LOGON_AD_FAIL)
		end
	end

    self.gameLib:httpRequest("BuyDiamondProduct.aspx", szData, 0, onRequestBuyPropertyFinish)
end

function PropertyTools:getLeastMontyPropertyItemByToolID(nToolID)
	local size = #self.m_vPropertyList
	local money = 0
	local index = -1
	for i = 1, size do
		local tItem = self.m_vPropertyList[i]
		if (tItem.nToolID == nToolID) then
			if (money == 0) then
				money = tItem.nDiamondAmount
				index = i
			elseif (money > tItem.nDiamondAmount) then
				money = tItem.nDiamondAmount
				index = i
			end
		end
	end
	if (index ~= -1) then
		return self.m_vPropertyList[index]
	end
	return nil
end

function PropertyTools:getPropertyList()
	return self.m_vPropertyList
end

function PropertyTools:getPropertyInfoList()
	return self.m_vPropertyInfoList
end

function PropertyTools:getPropertyInfoTimeList()
	return self.m_vPropertyInfoTimeList
end

function PropertyTools:getPropertyOwerInfoList()
	return self.m_vPropertyOwerInfoList
end

function PropertyTools:getPropertyUseStatusInfoList()
	return self.m_vPropertyUserStatusInfoList
end

function PropertyTools:getImageIDByToolType(nToolType, nID)
	if (nToolType == Resources.TOOLTYPE_TOOLCARD) then
		local size = #self.m_vPropertyInfoList
		if (size < 1) then
			return 1
		end
		for i = 1, size do
			local info = self.m_vPropertyInfoList[i]
			if (info.nCardID == nID) then
				return info.nImageID
			end
		end
	elseif (nToolType == Resources.TOOLTYPE_PAYFACE) then
		local size = #self.m_vPropertyInfoTimeList
		if (size < 1) then
			return 1
		end
		for i = 1, size do
			local info = self.m_vPropertyInfoTimeList[i]
			if (info.nEmoteID == nID) then
				return info.nImageID
			end
		end
	end

	return 1
end

function PropertyTools:getPropertyItemByProductID(nProductID)
	local size = #self.m_vPropertyList
	for i = 1, size do
		local info = self.m_vPropertyList[i]
		if (info.nProduceID == nProductID) then
			return info
		end
	end
	return nil
end

function PropertyTools:getPropertyInfoByToolID(nToolID)
	local size = #self.m_vPropertyInfoList
	for i = 1, size do
		local info = self.m_vPropertyInfoList[i]
		if (info.nCardID == nToolID) then
			return info
		end
	end
    return nil
end

function PropertyTools:getPropertyItemByToolID(nToolID) --通过产品ID获取道具信息
	local size = #self.m_vPropertyList
	for i = 1, size do
		local info = self.m_vPropertyList[i]
		if (info.nToolID == nToolID) then
			return info
		end
	end
end

function PropertyTools:request()
	self:requestPropertyList()
	self:requestPropertyInfoList()
	self:requestPropertyInfoTimeList()
	self:requestPropertyOwerInfoList()
	self:requestPropertyUseStatusInfoList()
end

function PropertyTools:getVipFaceUserStatus()
	local size = #self.m_vPropertyUserStatusInfoList
	if (size < 1) then
		return false
	end
	for i = 1 ,size do
		local info = self.m_vPropertyUserStatusInfoList[i]
		if (info.nEmoteID == Resources.VIPFACE_PROPERTY_PRODUCT_ID) then
			if (info.nEnabled == 1) then
				return true
			end
		end
	end
	return false
end

function PropertyTools:getPropertyOwerNum(nPropertyID)
	local size = #self.m_vPropertyOwerInfoList
	if (size < 1) then
		return 0
	end
	for i = 1 ,size do
		local info = self.m_vPropertyOwerInfoList[i]
		if (info.nToolCardID == nPropertyID) then
			return info.nCount
		end
	end
	return 0
end

function PropertyTools:new()
    local store = nil

    return function(self)
        if store then return store end
        local o =  {}
        setmetatable(o, PropertyTools)
        PropertyTools.__index = PropertyTools

        o.m_vPropertyList = {} --//商城道具信息列表
		o.m_vPropertyInfoList = {}  --//消费道具信息列表
		o.m_vPropertyInfoTimeList = {}  --//限时道具信息列表
		o.m_vPropertyOwerInfoList = {}  --//玩家拥有的道具列表
		o.m_vPropertyUserStatusInfoList = {}  --//道具使用状态信息列表
		o.gameLib = require("bull/GameLibSink").m_gameLib

        store = o
        return o
    end
end

PropertyTools.instance = PropertyTools:new() 

return PropertyTools