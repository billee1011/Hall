local Configger = require("GameLib/common/Configger")
local FileUtils = require("GameLib/common/FileUtils")
-- 初始化工作路径
GameConfig = {}

--local GameConfig.f = CCFileUtils:sharedFileUtils()
local uroot = require("Domain").HallFile
local GameConfigFileName = "GameConfig.json"

local ConfigTable 	-- GameConfig内容

function GameConfig.init()
	-- 先初始化工作路径，并读取配置内容
	GameConfig.initWorkingPath()
end

function GameConfig.initWorkingPath()
	-- 只有首次启动或者用户清理过数据，才进行工作路径的初始化操作
	local gameConfig = uroot .. GameConfigFileName
	if FileUtils.exists(gameConfig) then
		-- 如果可以读取大厅版本
		ConfigTable = Configger.readConfig(gameConfig)
		if ConfigTable.hall ~= nil then
			if ConfigTable.hall.version ~= nil then
				return
			end
		end
	end
	-- 读取安装包的GameConfig
	cclog("初始化工作路径")

	local resGameConfig = FileUtils.readFile(GameConfigFileName)
	local ConfigTable = require("cjson").decode(resGameConfig)

	Configger.writeConfig(gameConfig, ConfigTable)
end

function GameConfig.getHallVerName()
	if ConfigTable == nil or ConfigTable.hall == nil then
		GameConfig.initWorkingPath()
	end
	if ConfigTable == nil or ConfigTable.hall == nil then
		cclog("无法初始化工作路径")
		return "0.0.0"
	end

	return ConfigTable.hall.version or "0.0.0"
end

function GameConfig.getHallVer()
	if ConfigTable == nil or ConfigTable.hall == nil then
		GameConfig.initWorkingPath()
	end
	if ConfigTable == nil or ConfigTable.hall == nil then
		cclog("无法初始化工作路径")
		return "0.0.0"
	end

	local version = ConfigTable.hall.version or "0.0.0"

	return require("GameLib/common/VersionUtils").getVersionInt(version)
end

function GameConfig.getGameVer(gameName)
	local ok,  ge = pcall(function()
                return require(gameName .. "/GameVersion")
            end)
    if not ok then 
		local gameConfig = GameConfig.getGameConfig(gameName)
		if gameConfig == nil then return 0 end
		local v = gameConfig.version or "0.0.0"
		return require("GameLib/common/VersionUtils").getVersionInt(v)
	else
		return require("GameLib/common/VersionUtils").getVersionInt(ge.new().version)
	end	
end

-- 获取某个游戏的配置信息
function GameConfig.getGameConfig(gameName)
	if ConfigTable == nil then
		GameConfig.initWorkingPath()
	end
	if ConfigTable == nil then
		cclog("无法初始化工作路径")
		return nil
	end
	return ConfigTable[gameName]
end

-- 刷新配置文件
function GameConfig.flush()
	Configger.writeConfig(uroot .. GameConfigFileName, ConfigTable)
end

-- 如果安装包的配置及资源信息比工作路径的要新，则需要更新配置和文件
function GameConfig.renewConfigAndResource(gameName)
	-- 无法读取本地的版本
	if true then return false end
    local flush = false

    local str = FileUtils.readFile(gameName .. "/GameVersion.lua")
    local gameVersion = loadfile(gameName .. "/GameVersion.lua")	

	local curConfig = GameConfig.getGameConfig(gameName)

	if curConfig == nil then 
		GameConfig.renewModule(gameName)
		ConfigTable[gameName] = config
        flush = true
	end

	if require("GameLib/common/VersionUtils").isNew(gameVersion,curConfig["version"]) then 
		GameConfig.renewModule(gameName) 
		ConfigTable[gameName] = config
        flush = true
	end
    if flush then GameConfig.flush() end

    return flush
end

function GameConfig.renewModule(modName)
	-- 删除老资源
	local iconPath = uroot .. modName .. "/IconB.png"
	local icon = FileUtils.readFile(iconPath)
	FileUtils.rmdir(uroot .. modName)
	FileUtils.mkdir(uroot .. modName)
	if icon ~= nil then FileUtils.writeFile(iconPath,icon) end
	--FileUtils.rmdir(uroot .. modName)
	-- 删除后，程序运行自然会找到本地安装包中的资源
end

-- 强制更新或者新安装完整包
-- url：下载目录，如http://www.ss2007.com/download/wakeng/
-- modName: 模块名称，如 wakeng
-- handle 下载事件回调
-- newVersion　下载的版本号，用于更新配置文件，如"1.2.2"
function GameConfig.fullDownload(url,modName,handle,newVersion)
	local fullUrl = url .. newVersion.. modName .. "_full.zip"
	GameConfig.updateModule(fullUrl,modName,handle,true,newVersion)
	return fullUrl
end

-- 提示更新
function GameConfig.upgradeDownload(url,modName,handle,newVersion)
	local fullUrl = url .. newVersion.. modName .. "_upgrade.zip"
	GameConfig.updateModule(fullUrl,modName,handle,false,newVersion)
	return fullUrl	
end

-- 补丁升级
function GameConfig.fixDownload(url,modName,handle,newVersion)
	local fullUrl = url .. newVersion.. modName .. "_fix.zip"
	GameConfig.updateModule(fullUrl,modName,handle,false,newVersion)
	return fullUrl	
end

function GameConfig.deltaDownload(url,modName,handle,newVersion)
	local fullUrl = url .. newVersion.. modName .. "_delta.zip"
	GameConfig.updateModule(fullUrl,modName,handle,false,newVersion)
	return fullUrl	
end

function GameConfig.updateModule(url,modName,handle,removeOld,newVersion)
    
    local temZip = require("Domain").RootFile .. "download_tmp/" .. modName .. ".zip"
    local uncompressPath = require("Domain").RootFile .. "download_tmp/" .. modName
    if removedOld then FileUtils.rmdir(uncompressPath) end
    local curProgress = 0
    local function updateHandler(event, value)
    	local v
    	if event == "state" then
    		v = value:getCString()
    	end

    	if event == "progress" then
    		v = value:getValue()
    		--if curProgress == v then return end
    		curProgress = v
    	end    	
        if event == "success" then
 			-- 解压完成，拷贝至指定目录
 			if modName ~= "hall" then
 				FileUtils.copyDirectory(uncompressPath .. "/",uroot .. modName .. "/")
 			else
 				FileUtils.copyDirectory(uncompressPath .. "/",uroot )
 			end
 			-- 删除zip和已下载目录
 			os.remove(temZip)
 			FileUtils.rmdir(uncompressPath)
 			-- 更新版本信息
 			if newVersion ~= nil then
 				ConfigTable[modName].version = newVersion
 				GameConfig.flush()
 			end
 			--if handle then handle("finish",v or "") end
 			--cclog("GameConfig.updateModule success " .. modName)
        end
        if handle then handle(event,v or "") end
    end
    local u = require("GameLib/common/Updater"):new()
    
    u:updateZipFile(url,
        temZip,
        uncompressPath,
        updateHandler)
end

-- 发现新游戏
-- gameName: wakeng
-- url: http://www.ss2007.com/download/wakeng/
-- iconVersion: 1
function GameConfig.addGame(gameName,url,iconVersion,handle)
	-- 如果配置已存在
	if ConfigTable[gameName] ~= nil then
		if tonumber(ConfigTable[gameName].iconversion or "0") < tonumber(iconVersion or "0") then
			--GameConfig.addDefaultIcon(gameName)
			GameConfig.upgradeIcon(gameName,url,iconVersion,handle)
        else
            if handle then handle("success",gameName) end
		end
		return
	end
	ConfigTable[gameName] = {}
	ConfigTable[gameName].version = "0.0.0"
	-- 先放一个默认的icon
	--GameConfig.addDefaultIcon(gameName)
	GameConfig.upgradeIcon(gameName,url,iconVersion,handle)
	GameConfig.flush()
end


-- 更新icon
-- gameName: wakeng
-- url: http://www.ss2007.com/download/wakeng/
-- version:1
function GameConfig.upgradeIcon(gameName,url,version,handle)
	--[[local fullUrl = url .. gameName .. "_iconB.zip"
	local function updateIconHandler(event, value)
		if event == "success" then
			-- 更新icon版本
			ConfigTable[gameName].iconversion = version
 			GameConfig.flush()
 			require("GameLib/common/EventDispatcher"):instance():dispatchEvent("onIconUpdated",gameName)			
		end
        if handle then handle(event,value) end        
        
	end	
	GameConfig.updateModule(fullUrl,gameName,updateIconHandler,false)]]
end

-- 删除游戏
function GameConfig.removeGame(gameName)
	if ConfigTable[gameName] == nil then return end
	-- 删除目录
	local iconPath = uroot .. gameName .. "/IconB.png"
	local icon = FileUtils.readFile(iconPath)
	FileUtils.rmdir(uroot .. gameName)
	FileUtils.mkdir(uroot .. gameName)
	if icon ~= nil then FileUtils.writeFile(iconPath,icon) end
	-- 设置版本
	if ConfigTable[gameName] ~= nil then
		ConfigTable[gameName].version = "0.0.0"
		GameConfig.flush()
	end
end

function GameConfig.removeHall()
	local gameConfigPath = uroot .. "GameConfig.json"
	local gameConfig = FileUtils.readFile(gameConfigPath)
	FileUtils.rmdir(uroot)
	FileUtils.mkdir(uroot)
	if gameConfig ~= nil then FileUtils.writeFile(gameConfigPath,gameConfig) end
end

function GameConfig.clearHall()
	local gameConfigPath = uroot .. "GameConfig.json"
	os.remove(gameConfigPath)

	FileUtils.rmdir(uroot)
	FileUtils.mkdir(uroot)
end

function GameConfig.removeHallOnly()
	local gameConfigPath = uroot .. "GameConfig.json"
	local gameConfig = FileUtils.readFile(gameConfigPath)

	local dirs = {"FFSelftools/", "GameLib/", "Lobby/", "resources/"}
	for i,v in ipairs(dirs) do
		FileUtils.rmdir(uroot..v)
	end

	local files = {"LobbyControl.lua", "HallUtils.lua", "AppConfig.lua", "GameConfig.lua"}
	for i,v in ipairs(files) do
		os.remove(uroot..v)
	end
end

-- 读取本地已安装的游戏版本并更新
function GameConfig.reloadGameVersion(gameName)
	if ConfigTable[gameName] == nil then
		ConfigTable[gameName] = {}
		ConfigTable[gameName].version = "0.0.0"
	else
		if GameConfig.renewConfigAndResource(gameName) then
			return
		end
	end
	--if ConfigTable[gameName].version == nil or ConfigTable[gameName].version == "0.0.0"	then 
	local ok,  ge = pcall(function()
                return require(gameName .. "/GameVersion")
            end)
    if not ok then 
    	ConfigTable[gameName].version = "0.0.0"
    	GameConfig.flush()
    	return 
    end	    
    if require("GameLib/common/VersionUtils").isNew(ge.new().version,ConfigTable[gameName].version) then
    	GameConfig.renewModule(gameName)
		ConfigTable[gameName].version = ge.new().version	
		GameConfig.flush()
	end
	--end
end

-- 游戏是否为下载资源
function GameConfig.isGameDeletable(gameName)
	local gameVersion = uroot .. gameName .. "/GameVersion.lua"
	return FileUtils.exists(gameVersion)
end

function GameConfig.getExistGameSize(gameName)
	return FileUtils.getFolderSize(uroot .. gameName)
end

return GameConfig