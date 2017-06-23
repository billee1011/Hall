SqliteHelper = {}
SqliteHelper.__index = SqliteHelper
function SqliteHelper:new() --private method.
    local store = nil

    return function(self)
        if store then return store end
        local o = {
        	m_pHeader = nil,
        	m_nHeaderLen = 0,
        	m_nScoreBufLen = 0,
        	m_bInitalized = false,
        	m_pHeaders = {}
    	}
        setmetatable(o, self)
        self.__index = self
        store = o
        --cclog("SqliteHelper")
   		return o
    end
end

SqliteHelper.instance = SqliteHelper:new() 

-- 常量
SqliteHelper.FACE_DB_FILENAME  =  "ssfaceData.db"
SqliteHelper.CREATE_FACE_TABLE  = "CREATE TABLE tb_facedata (ID INTEGER PRIMARY KEY AUTOINCREMENT, col_userdbid INTEGER UNIQUE,col_faceindex INTEGER,col_facedatalen INTEGER, col_userfacedata BLOB)"
SqliteHelper.SQLITE_OK = 0
SqliteHelper.TB_FACECACHE_NAME    =   "tb_facedata"
SqliteHelper.FACECACHE_COL_ID     =   "ID"
SqliteHelper.FACECACHE_COL_DBID   =   "col_userdbid"
SqliteHelper.FACECACHE_COL_DATA    =  "col_userfacedata"
SqliteHelper.FACECACHE_COL_DATALEN =  "col_facedatalen"
SqliteHelper.FACECACHE_COL_FACEINDEX =  "col_faceindex"


function SqliteHelper:initDBFile()
    cclog("初始化数据库文件，若无文件则创建，若无数据表，也创建！")
    --sqlite3* sqlite3DB=NULL
    local fullPath = require("Domain").RootFile
    local fileame = SqliteHelper.FACE_DB_FILENAME
    local fileAllPath = fullPath .. fileame
    cclog("文件路径：" .. fileAllPath)

    local sqlite3 = require("lsqlite3")
    local db = sqlite3.open(fileAllPath)


    if (db ~= nil) then --sqlite3_open 有打开 没有创建
        --若无数据表，则创建数据表, 创建数据库 表格  id 和 name 和 address 和 tell 和myself  id 名字 地址 手机  自我介绍
        local result = db:exec(SqliteHelper.CREATE_FACE_TABLE)
        if result ~= 1 then
            cclog("执行创建表失败" .. result)
        end
        db:close()  --关闭数据库
    end
end

function SqliteHelper:insertFaceData(data,userdbid,nlen,cbIndex)
    if nlen<=0 or data==nil then return end

    local fullPath = require("Domain").RootFile
    local fileame = SqliteHelper.FACE_DB_FILENAME
    local fileAllPath = fullPath .. fileame
    if not C2dxEx:isFileExist(fileAllPath) then self:initDBFile() end

    local sqlite3 = require("lsqlite3")
    local db = sqlite3.open(fileAllPath)

    if(db == nil) then
        cclog("SqliteHelper:insertFaceData db == nil")
        return
    end
    local result = db:exec(SqliteHelper.CREATE_FACE_TABLE)
    local pStrInsert = 
    string.format("replace into tb_facedata(col_userdbid,col_faceindex, col_facedatalen,col_userfacedata) values(%d,%d,%d,?);"
        ,userdbid,cbIndex,nlen)
    --cclog("执行langUtf8：" .. pStrInsert)
    local stmt = db:prepare(pStrInsert)
    if stmt == nil then
        cclog("db:prepare 失败")
        return
    end
    result = stmt:bind_blob(1,data)
    if result ~= sqlite3.OK then
        cclog("bind_blob失败:" .. result)
        return
    end
     result = stmt:step()
     cclog("stmt:step() = " .. result)
     db:close()
end

function SqliteHelper:getFaceData(userDBID)
    local fullPath = require("Domain").RootFile
    local fileame = SqliteHelper.FACE_DB_FILENAME
    local fileAllPath = fullPath .. fileame
    if not C2dxEx:isFileExist(fileAllPath) then 
        self:initDBFile() 
        return nil,0,0
    end
    local sqlite3 = require("lsqlite3")
    local db = sqlite3.open(fileAllPath)
    if(db == nil) then return end
    local pStrSelect = string.format("select * from tb_facedata where col_userdbid=%d;",userDBID)
    --cclog("执行langUtf8：" .. pStrSelect)
    local stmt = db:prepare(pStrSelect)
    if stmt == nil then
        cclog("db:prepare 失败")
        return nil,0,0
    end
    local nColumn = stmt:columns()
    result = stmt:step()
        --返回取出的数据
    local data,len,index
    if (result == sqlite3.ROW) then 
        for columnIndex=0, nColumn - 1 do
            local columnName = stmt:get_name(columnIndex)
            --cclog("columnName(" .. columnIndex .. "): " .. columnName)
            if (columnName == SqliteHelper.FACECACHE_COL_DATA) then
                --len=sqlite3_column_bytes(stat, columnIndex)
                --data = db:result_blob(stat, columnIndex)
                --memcpy(data, facedata, len)
                data = stmt:get_value(columnIndex)
            end
            if (columnName == SqliteHelper.FACECACHE_COL_DATALEN) then
                --len=sqlite3_column_int(stat, columnIndex)
                len = stmt:get_value(columnIndex)
            end
            if (columnName==SqliteHelper.FACECACHE_COL_FACEINDEX) then
                index = stmt:get_value(columnIndex)
            end
        end
        db:close()
        return data,len,index
    end
    db:close()
    return nil,0,0
end

function SqliteHelper:checkAndClearCache()
    --在face超过600时，删除顶端300个记录。
    local fullPath = require("Domain").RootFile
    local fileame = SqliteHelper.FACE_DB_FILENAME
    local fileAllPath = fullPath .. fileame
    if not C2dxEx:isFileExist(fileAllPath) then 
        self:initDBFile() 
        return
    end
    local sqlite3 = require("lsqlite3")
    local db = sqlite3.open(fileAllPath)
    if(db == nil) then return end
    
    local pStrSelect = string.format("select * from tb_facedata;")
    local stmt = db:prepare(pStrSelect)
    if stmt == nil then
        cclog("db:prepare 失败")
        return
    end
    result = stmt:step()
    local rows = 0
    while (result == sqlite3.ROW) do
        rows = rows + 1
        result = stmt:step()
    end
    
    cclog("总行数 = " .. rows)
    if rows > 600  then
        --删除前面两百个
        local pStrdelete=string.format("delete from tb_facedata where ID in(select ID from tb_facedata limit 200);")
        cclog("操作命令行: " .. pStrdelete)
        db:exec(pStrdelete)
        db:close()
    end

end
