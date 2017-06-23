--lua

PublicUserInfo = {}
__index = PublicUserInfo
function PublicUserInfo:new()
	local self = {
		userDBID = 39373906,
		nDiamond = 0,
		nickName = "",
		nFaceID = 0,
		encryptPassword = "e10adc3949ba59abbe56e057f20f883e",
		faceData = nil,
		sex = 1, -- 1:Male other:Female
		nGold = 0,
		vipLevel = 0,
		nFrag = 0,
		bankAmount = 0,
		payAmount = 0
	}

	setmetatable(self, PublicUserInfo)
	return self
end

function PublicUserInfo:getFaceLen()
	return self.faceData and string.len(self.faceData) or 0
end