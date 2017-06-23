--[[struct ChargeInfo
{
	int nGoldNum;	// 金豆数量
	int nPrice;		// 价格,分
	int nDefault;	// 是否默认
	char szProductID[32];	// 产品ID
	char szName[32];
	char szDesc[128];
	char szProductMM[32];	// mm产品ID
	int nMMAmount;	// 使用短信获得的金豆数量
	int nMoneyType;	// 0 金豆，1钻石
	ChargeInfo()
	{
		memset(this,0,sizeof(ChargeInfo));
	}
};

ChargeInfo = {}
ChargeInfo.__index = ChargeInfo

function ChargeInfo:new()	
	local self = {
		nGoldNum = 0,
		nPrice = 0,
		nDefault = 0,
		szProductID = "",
		szName = "",
		szDesc = "",
		szProductMM = "",
		nMMAmount = 0,
		nMoneyType = 0
	}
	setmetatable(self, ChargeInfo)
	return self
end]]
