gamelibcommon = {}
-- 平台类型
gamelibcommon.PLATFORM_CHINAGAMES = 0	-- 中游
gamelibcommon.PLATFORM_ZHONGCHUAN = 1	-- 中传
gamelibcommon.PLATFORM_YUEDONG = 2	-- 悦动
gamelibcommon.NAME_LEN = 32
gamelibcommon.PASS_LEN				 = 16
gamelibcommon.EMAIL_LEN				 = 32				--閭欢缂撳啿闀垮害
gamelibcommon.PROVINCE_LEN			 = 16				--鐪佷唤缂撳啿闀垮害
gamelibcommon.CITY_LEN				 = 16				--鍩庡競缂撳啿闀垮害
gamelibcommon.AREA_LEN				 = 16				--鍦板尯缂撳啿闀垮害
gamelibcommon.EMAIL_LEN				 = 32				--閭欢缂撳啿闀垮害
gamelibcommon.GAME_STATION_LEN		 = 32
gamelibcommon.URL_LEN					 = 256
gamelibcommon.RESERVE_LEN				 = 32

gamelibcommon.GAME_ROOT_LEN			 = 32				--锟斤拷诘慊猴拷宄わ拷锟?
gamelibcommon.GAME_TYPE_LEN			 = 16				--锟斤拷锟酵伙拷锟藉长锟斤拷
gamelibcommon.GAME_KIND_LEN			 = 16				--锟斤拷戏锟斤拷锟藉长锟斤拷
gamelibcommon.GAME_STATION_LEN		 = 32				--站锟姐缓锟藉长锟斤拷
gamelibcommon.GAME_SUBSTATION_LEN		 = 64				--锟斤拷站锟斤拷锟藉长锟斤拷
gamelibcommon.GAME_ROOM_LEN			 = 32				--锟斤拷锟戒缓锟藉长锟斤拷
gamelibcommon.GAME_MODULE_LEN			 = 16				--锟斤拷袒锟斤拷宄わ拷锟?
gamelibcommon.URL_LEN					 = 256				--锟斤拷址锟斤拷锟藉长锟斤拷
gamelibcommon.SERVER_LEN				 = 256				--锟斤拷锟斤拷锟斤拷锟斤拷址锟斤拷锟斤拷
gamelibcommon.AVATAR_URL				 = 128				--头锟斤拷锟街凤拷锟斤拷锟?
gamelibcommon.FIELE_NAME				 = 16				--锟斤拷锟斤拷锟斤拷锟?
gamelibcommon.SCORE_BUF				 = 64				--锟矫伙拷锟斤拷锟斤拷
gamelibcommon.ORDER_LEN				 = 16				--锟饺硷拷锟斤拷锟斤拷
gamelibcommon.RESERVE_LEN				 = 32				--锟斤拷锟斤拷锟斤拷锟藉长锟斤拷
gamelibcommon.PHONE_LEN				 = 16				--全锟斤拷锟侥猴拷锟斤拷
gamelibcommon.PROP_LEAVEWORD_LEN		 = 50				--锟斤拷锟斤拷锟斤拷锟皆筹拷锟斤拷
gamelibcommon.ACADEMY_GRADE_NAME_LEN	 = 16				--锟斤拷锟斤拷锟斤拷院锟饺硷拷锟斤拷瞥锟斤拷锟?
gamelibcommon.CLOSE_GAME_CLIENT_MSG_LEN = 256				--锟截憋拷锟斤拷戏锟酵伙拷锟斤拷时锟斤拷示锟矫伙拷锟斤拷锟斤拷息锟斤拷锟斤拷	--add by mxs
gamelibcommon.REG_RESULT_LEN			 = 256				--注锟结返锟截碉拷锟斤拷息锟斤拷锟斤拷					--add by mxs nplaza
gamelibcommon.VNET_LEN				 = 128				--锟斤拷锟街伙拷锟藉长锟斤拷
gamelibcommon.VNET_VALIDATE_URL_LEN	 = 1024			--Vnet锟斤拷证Url锟斤拷锟斤拷		add by mxs 2006-3 vnet
gamelibcommon.VNET_VALIDATE_URL_KEYWORD = 64				--通锟斤拷锟斤拷锟斤拷址锟饺凤拷锟斤拷锟絍net锟斤拷锟截碉拷锟斤拷证Url
gamelibcommon.VNET_CMD_LEN			 = 256				--Vnet锟斤拷锟斤拷锟叫碉拷陆锟斤拷锟斤拷	add by mxs e8
gamelibcommon.ENCRYPT_PASS_LEN		 = 64				--锟斤拷锟杰碉拷锟斤拷锟诫长锟斤拷	--add by mxs vnetpass 2007-2-27

-- 数据范围
gamelibcommon.MAX_MSG_LEN = 256
gamelibcommon.MAX_NAME_LEN = 32
gamelibcommon.MAX_PASSWORD_LEN = 16
gamelibcommon.MAX_USER_ID = 2000		-- 每个房间最多可容纳的用户数，用户ID也不应超出此范围
gamelibcommon.MAX_CHAIR = 6	-- 最大椅子数
gamelibcommon.MAX_SCORE_BUF_LEN = 20	-- 用户成绩的最大长度
gamelibcommon.MAX_RESERVE_LEN = 32		-- 何留字节最大长度
gamelibcommon.GLORY_NAME_LEN = 32
-- 游戏种类ID
gamelibcommon.GAMEID_TENTRIX = 0	-- 俄罗斯方块
gamelibcommon.GAMEID_24POINTS = 1	-- 24点
gamelibcommon.GAMEID_I_GO = 2	-- 围棋
gamelibcommon.GAMEID_CCHESS = 3	-- 中国象棋
gamelibcommon.GAMEID_GOBANG = 4	-- 五子棋
gamelibcommon.GAMEID_JUNQI = 5	-- 四国军棋
gamelibcommon.GAMEID_CHESS = 6	-- 国际象棋
gamelibcommon.GAMEID_ANQI = 7	-- 暗棋
gamelibcommon.GAMEID_UPGRADE = 8	-- 升级
gamelibcommon.GAMEID_RED_HEARTS = 9	-- 红心大战
gamelibcommon.GAMEID_RUNOUT = 10	-- 跑得快
gamelibcommon.GAMEID_BRIDGE = 11	-- 桥牌
gamelibcommon.GAMEID_MJ = 12	-- 麻将
gamelibcommon.GAMEID_DIG = 13	-- 锄大D

gamelibcommon.GAMEID_DOUBLE = 14	-- 双扣
gamelibcommon.GAMEID_LANDLORD = 15	-- 斗地主
gamelibcommon.GAMEID_SHOWHAND = 16	-- 梭哈
gamelibcommon.GAMEID_21P = 17	-- 21点
gamelibcommon.GAMEID_DRAGON = 18	-- 接龙
gamelibcommon.GAMDID_CLAMP = 19	-- 奥塞罗

gamelibcommon.GAMEID_TESTGAME = 20	-- 测试游戏

gamelibcommon.GAMEID_LANLORD2P = 21	-- 斗地主两副牌
gamelibcommon.GAMEID_DALU = 22	-- 大怪路子
gamelibcommon.GAMEID_FRIEND = 23	-- 找朋友
gamelibcommon.GAMEID_CATTLE = 24	-- 吹牛
gamelibcommon.GAMEID_BOULT = 25	-- 筛钟
gamelibcommon.GAMEID_ANIMAL = 26	-- 斗兽棋
gamelibcommon.GAMEID_GOJI = 27	-- 够级
gamelibcommon.GAMEID_TESTGAME2 = 28	-- 测试游戏2
gamelibcommon.GAMEID_TESTGAME3 = 29	-- 测试游戏3
gamelibcommon.GAMEID_TESTGAME4 = 30	-- 测试游戏4
gamelibcommon.GAMEID_TESTGAME5 = 31	-- 测试游戏5
gamelibcommon.GAMEID_TANK = 32	-- 坦克大战
gamelibcommon.GAMEID_BILLIARDS = 33	-- 网络台球
gamelibcommon.GAMEID_BC_MJ = 34	-- 博彩麻将
gamelibcommon.GAMEID_SANDAHA = 35	-- 三打哈
gamelibcommon.GAMEID_CASINOSDH = 36	-- 金币三打哈
gamelibcommon.GAMEID_BCLANDLORD = 37	-- 金币斗地主
gamelibcommon.GAMEID_BCDIG = 38	-- 金币锄大地
gamelibcommon.GAMEID_BJL = 39

gamelibcommon.GAMEID_3DBILLIARDS = 40	-- 3D台球
gamelibcommon.GAMEID_NEW_BILLIARDS = 41	-- 新台球
gamelibcommon.GAMEID_NEWSHOWHAND = 42	-- 梭哈
gamelibcommon.GAMEID_WAKENG = 43	-- 挖坑
gamelibcommon.GAMEID_BAOHUANG = 44	-- 保皇
gamelibcommon.GAMEID_MJGUANGDONG = 45	-- 广东麻将
gamelibcommon.GAMEID_BCMJGUANGDONG = 46	-- 金币广东麻将
gamelibcommon.GAMEID_NCMJ = 47	-- 南昌麻将
gamelibcommon.GAMEID_MJCHANGSHA = 48	-- 长沙麻将
gamelibcommon.GAMEID_NEW21P = 49	-- 新21点
gamelibcommon.GAMEID_CQLANDLORD = 50	-- 重庆斗地主
gamelibcommon.GAMEID_BIGPOOL = 51	-- 大台球
gamelibcommon.GAMEID_POOL3D16 = 52	-- 3d16球
gamelibcommon.GAMEID_CHAODIPI = 53	-- 抄地皮
gamelibcommon.GAMEID_GOLDFLOWER = 54	-- 扎金花
gamelibcommon.GAMEID_BOMBERMAN = 55	-- 炸弹人
gamelibcommon.GAMEID_BULLETIN = 56	-- 色盅公告
gamelibcommon.GAMEID_BULLETIN1 = 57	-- 21点公告
gamelibcommon.GAMEID_FIVECARDS = 58	-- 港式五张,梭哈
gamelibcommon.GAMEID_PLANE = 59	-- 飞行棋
gamelibcommon.GAMEID_ACADEMY_CCHESS = 60	-- 网络棋院中国象棋
gamelibcommon.GAMEID_ACADEMY_CHESS = 61	-- 网络棋院国际象棋
gamelibcommon.GAMEID_ACADEMY_GO = 62	-- 网络棋院围棋
gamelibcommon.GAMEID_ACADEMY_GOBANG = 63	-- 网络棋院五子棋
gamelibcommon.GAMEID_BULLETIN2 = 64	-- 梭哈公告
gamelibcommon.GAMEID_NEWMJGUANGDONG = 65	-- 新广东麻将
gamelibcommon.GAMEID_CHUZZLE = 66	-- 鸡鸡碰
gamelibcommon.GAMEID_BALLOON = 67	-- 气球
gamelibcommon.GAMEID_GDMJTDH = 68	-- 广东麻将推倒胡
gamelibcommon.GAMEID_NEWGOBANG = 69	-- 新五子棋
gamelibcommon.GAMEID_SCORE240 = 70	-- 240
gamelibcommon.GAMEID_SUPER_LANDLORD = 71	-- 超级斗地主
gamelibcommon.GAMEID_SUPER_MAHJONG = 72	-- 超级麻将
gamelibcommon.GAMEID_MATCH_LANLORD = 73	-- 斗地主比赛
gamelibcommon.GAMEID_MATCH_UPGRADE = 74	-- 升级比赛
gamelibcommon.GAMEID_MATCH_CCHESS = 75	-- 中国象棋比赛
gamelibcommon.GAMEID_MATCH_JUNQI = 76	-- 军棋比赛
gamelibcommon.GAMEID_ONESANDAHA = 77	-- 三打哈一副
gamelibcommon.GAMEID_NEWJUNQI = 78	-- 新军旗
gamelibcommon.GAMEID_BJWAKENG = 79	-- 宝鸡挖坑
gamelibcommon.GAMEID_phz = 15	-- 跑胡子
gamelibcommon.GAMEID_SANGEN = 81	-- 三跟
gamelibcommon.GAMEID_NEWUPGRADE = 82	-- 新升级
gamelibcommon.GAMEID_LORDEXP = 83	-- 超级斗地主表情版
gamelibcommon.GAMEID_SUPGRADE = 84	-- 超级升级
gamelibcommon.GAMEID_SGDMJ = 85	-- 超级广东麻将
gamelibcommon.GAMEID_SUPERDIG = 86	-- 超级锄大地
gamelibcommon.GAMEID_DARKCHESS = 87	-- 暗棋
gamelibcommon.TOTAL_GAME_KIND_NUM = 88  -- 目前游戏种类数，目前就这些游戏了，玩死你


gamelibcommon.MAX_GAME_KIND_NUM = 256	-- GAMEID的最大值
gamelibcommon.INVALID_USER_ID = 0xFFFF	-- 无效用户索引ID

gamelibcommon.NAME_LEN = 32
gamelibcommon.DESCRIBE_LEN = 128
gamelibcommon.GROUP_LEN = 32
gamelibcommon.AVATAR_URL = 128
gamelibcommon.AREA_LEN = 16
gamelibcommon.CITY_LEN = 16
gamelibcommon.PROVINCE_LEN = 16
gamelibcommon.PHONE_LEN = 16
gamelibcommon.SCORE_BUF = 64
gamelibcommon.SX_BOY = 1
gamelibcommon.SX_GIRL = 0

gamelibcommon.INVALI_OFF = 0XFFFF
gamelibcommon.INVALI_TABLE_ID = 0XFFFF
gamelibcommon.INVALI_CHAIR_ID = 0XFF
gamelibcommon.INVALI_USER_INDEX = 0XFFFF

--友好关系
gamelibcommon.FC_NORMAL = 0				--普通关系
gamelibcommon.FC_FRIEND = 1				--朋友关系
gamelibcommon.FC_DETEST = 2				--厌恶关系

--用户状态定义
gamelibcommon.USER_NO_STATUS = 0					--没有状态
gamelibcommon.USER_FREE_STATUS = 1					--在房间站
gamelibcommon.USER_WAIT_SIT = 2					--等待坐下
gamelibcommon.USER_SIT_TABLE = 3					--坐到座位
gamelibcommon.USER_READY_STATUS = 4				--同意状态
gamelibcommon.USER_PLAY_GAME = 5					--正在游戏
gamelibcommon.USER_OFF_LINE = 6					--用户断线
gamelibcommon.USER_WATCH_GAME = 7					--旁观游戏

function gamelibcommon.isSitTable(status)
    return status >= gamelibcommon.USER_SIT_TABLE and 
        status < gamelibcommon.USER_WATCH_GAME
end


gamelibcommon.LOOKON_ENABLE_FRIEND = 0x0001		-- 对朋友
gamelibcommon.LOOKON_ENABLE_ENEMY = 0x0002         -- 对敌人
gamelibcommon.LOOKON_ENABLE_GROUP = 0x0004         -- 对社团
gamelibcommon.LOOKON_ENABLE_BBRFRIEND = 0x0008		-- bbring好友
gamelibcommon.LOOKON_ENABLE_SAMEAREA = 0x0010      -- 同地区
gamelibcommon.LOOKON_ENABLE_SAMESEX = 0x0020       -- 同性
gamelibcommon.LOOKON_ENABLE_OPPOSITESEX = 0x0040	-- 异性
gamelibcommon.LOOKON_ENABLE_ALL = 0x0080           -- 对所有人开放
-- 拒绝
gamelibcommon.LOOKON_DISABLE_FRIEND = 0x0100		-- 对朋友
gamelibcommon.LOOKON_DISABLE_ENEMY = 0x0200		-- 对敌人
gamelibcommon.LOOKON_DISABLE_GROUP = 0x0400		-- 对社团
gamelibcommon.LOOKON_DISABLE_BBRFRIEND = 0x0800	-- bbring好友
gamelibcommon.LOOKON_DISABLE_SAMEAREA = 0x1000		-- 同地区
gamelibcommon.LOOKON_DISABLE_SAMESEX = 0x2000		-- 同性
gamelibcommon.LOOKON_DISABLE_OPPOSITESEX = 0x4000		-- 异性
gamelibcommon.LOOKON_DISABLE_ALL = 0x8000			-- 对所有人开放

-- 关注类型
gamelibcommon.friendNone = 0
gamelibcommon.friendFriend = 1
gamelibcommon.friendEnemy = 2

-- 创建房间类型
gamelibcommon.PRIVATE_ROOM_NONE = 0	-- 无
gamelibcommon.PRIVATE_ROOM_CREATE = 1	-- 创建
gamelibcommon.PRIVATE_ROOM_ENTER = 2	-- 加入


-- scre filed
gamelibcommon.enScore_Score	= 0	-- 分数
gamelibcommon.enScore_Win = 1				-- 胜局
gamelibcommon.enScore_Loss = 2			-- 负局
gamelibcommon.enScore_Draw =3			-- 和局
gamelibcommon.enScore_Flee = 4			-- 逃跑局数
gamelibcommon.enScore_SetCount = 5			-- 总局数
gamelibcommon.enScore_WeekTopWin =6 			-- 本周最大赢取
gamelibcommon.enScore_TopWin = 7				-- 历史最大赢取
gamelibcommon.enScore_Guess = 8				-- 猜坑记录

gamelibcommon.enScore_Custom		=	16	--...鍓嶉潰鐨勪繚鐣欙紝鍚庨潰鐨勮嚜瀹氫箟
gamelibcommon.enScore_Gold = 17		--閲戝竵
gamelibcommon.enScore_Tax = 18				--绋?
gamelibcommon.enScore_Ranking =19			--绛夌骇鍒?

gamelibcommon.CONNECT_OK_RES = 0
gamelibcommon.CONNECT_ERROR_RES = 1
gamelibcommon.SEND_DATA_OK_RES = 2
gamelibcommon.SEND_DATA_ERROR_RES = 3
gamelibcommon.RECV_DATA_OK_RES = 4
gamelibcommon.RECV_DATA_ERROR_RES = 5
gamelibcommon.DISCONNECT_RES = 6

function convertStringToHex(str)
	cclog("convertStringToHex:" .. str)
	local ba = require("ByteArray").new()
	ba:writeString(str)
	--ba:initBuf(str)
	for i=1,4 - ba:getLen() do
		ba:writeByte(0)
	end
	ba:setPos(1)
	return ba:readInt()
end

function getTickCount()
	return C2dxEx:getTickCount()
end

function CreatEnumTable(tbl, index)
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i 
    end 
    return enumtbl 
end 

function pushTable(t,e)
	t[#t + 1] = e
end

function SplitString( str )
    local len  = #str
    local left = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local t = {}
    local start = 1
    local wordLen = 0
    while len ~= left do
        local tmp = string.byte(str, start)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                break
            end
            i = i - 1
        end
        wordLen = i + wordLen
        local tmpString = string.sub(str, start, wordLen)
        start = start + i
        left = left + i
        t[#t + 1] = tmpString
    end
    return t
end

function changeIP(nIpaddress)
    local ba = require("ByteArray").new()
    ba:writeUInt(nIpaddress)
    ba:setPos(1)
    return string.format("%d.%d.%d.%d",ba:readUByte(),ba:readUByte(),ba:readUByte(),ba:readUByte())
end

--- 获取UTF8中文字符串长度
function length(str)
    return #(str:gsub('[\128-\255][\128-\255][\128-\255]',' '))
end

--- 截取中英文字符串
function subStr(str, s, e)
    local tab, k = {}, 1
    for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do
        if (k >= s and k <= e) then tab[#tab+1] = uchar end k = k + 1
    end
    return table.concat(tab)
end

--- 切分字符串
function split(str, delim, maxNb)
    if string.find(str, delim) == nil then return { str } end
    if maxNb == nil or maxNb < 1 then maxNb = 0 end
    local nb, result, pat, lastPos = 0, {}, "(.-)"..delim.."()", nil
    for part, pos in string.gfind(str, pat) do
        nb=nb+1 result[nb]=part lastPos=pos
        if nb == maxNb then break end
    end
    if nb ~= maxNb then result[nb + 1] = string.sub(str, lastPos) end
    return result
end