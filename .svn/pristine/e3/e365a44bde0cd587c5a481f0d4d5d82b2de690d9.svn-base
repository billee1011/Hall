-- struct PropertyInfo
-- {
-- 	int nPropertyID;
-- 	int nGroup;
-- 	int nPrice;	// 购买价格，人民币计价
-- 	char szName[32];
-- 	char szDesc[64];

-- 	PropertyInfo()
-- 	{
-- 		memset(this,0,sizeof(PropertyInfo));
-- 	}
-- };
PropertyInfo = {}
PropertyInfo.__index = PropertyInfo

function PropertyInfo:new()

	local self = {
		nPropertyID = 0,
		nGroup = 0,
		nPrice = 0,
		szName = "szName",
		szDesc = "szDesc"
	}

	setmetatable(self, PropertyInfo)
	return self
end

-- struct UserProperty
-- {
-- 	int nPropertyID;	// 道具ID
-- 	int nCount;			// 数量
-- 	int nFlag;			// 启用标志
-- 	UserProperty()
-- 	{
-- 		memset(this,0,sizeof(UserProperty));
-- 	}
-- };
UserProperty = {nPropertyID , nCount , nFlag}
UserProperty__index = UserProperty

function UserProperty:new()
	
	local self = {
		nPropertyID = 0,
		nCount = 0,
		nFlag = 0
	}

	setmetatable(self, UserProperty)
	return self
end
