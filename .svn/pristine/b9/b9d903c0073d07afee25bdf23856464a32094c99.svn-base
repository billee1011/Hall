local updater = {}

updater.__index = updater


updater.STATES = {
    kDownStart = "downloadStart",
    kDownDone = "downloadDone",
    kUncompressStart = "uncompressStart",
    kUncompressDone = "uncompressDone",
    unknown = "stateUnknown",
}

updater.ERRORS = {
    kCreateFile = "errorCreateFile",
    kNetwork = "errorNetwork",
    kNoNewVersion = "errorNoNewVersion",
    kUncompress = "errorUncompress",
    unknown = "errorUnknown",
}


local utmp = require("Domain").RootFile .. "update_temp/"

function updater:new(...)
    local instance = setmetatable({}, updater)
    instance.class = updater
    instance:ctor(...)
    return instance
end

function updater:ctor(appName, packageRoot)
    self.name = appName or "GameLib.updater"
    self.packageRoot = packageRoot or self.name
    -- set global app
    _G[self.name] = self

    self._updater = Updater:new()
end

function updater._updateHandler(event, value)
    print("updateHandler :" .. event)
end


function updater:updateZipFile(url,toSaveFile,toUnCompressPath,handler)
    self._updater:registerScriptHandler(handler or updater._updateHandler)
    local FileUtils = require("GameLib/common/FileUtils")
    FileUtils.recursiveMkdir(toSaveFile)
    FileUtils.recursiveMkdir(toUnCompressPath)
    self._updater:update(url,toSaveFile,toUnCompressPath,true)
end


function updater:updateFile(url,localPath)
    --if handler then
        self._updater:registerScriptHandler(updater._updateHandler)
    --end
    -- 删除临时目录
    updater.rmdir(utmp)
    --updater.mkdir(utemp .. "test")
    --self.recursiveMkdir(utmp .. localPath)
    self._updater:update(url, utmp .. localPath)
end

function updater:getDownloadFileLength(url)
    return self._updater:getDownloadFileLength(url)
end

return updater