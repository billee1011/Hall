--[[
lua 数据 table 的保存，读取，打印等功能
以方便人阅读为主要考虑，性能不重要。仅用于开发调试过程。
table 只支持基础类型 nil 、boolean 、number 、string 、 table,
不支持 lightuserdata 、function 、 userdata 和 thread。
-- 使用:
-- 将表格数据导出为 string list(因为有时候导出的字符串太长，print等函数无法处理。所以导出成字符串列表。)
list = table.toStringList(t1)
str = table.toString(t1)    -- table 变成 str
tbl = table.fromString(str) -- str 变成 table
table.save(filename, tbl)   -- 将表格保存到文件
tbl = table.load(filename)  -- 从文件中读取表格
table.print(tbl)            -- 打印表格
table.logDebug(tbl)         -- 表格输出到日志
]]
-- t 需要转换成 string 的 table
enumTable = {}
--[[
enumTable['monster'] = { -- 如果表格  t 有属性 t.type == 'monster'，则使用下面的属性判断
camp = CAMPS, 如果属性名是 camp，则使用 CAMPS 枚举表格转换输出值
class = CLASS,
}
]]
-- 把枚举值转换为枚举名
-- 比如  LEVEL_TYPE.MAIN == 2,  table.enumString(LEVEL_TYPE, 2) ---> MAIN
function table.enumString(enum, value)
    for k,v in pairs(enum) do
        if v == value then
            return k
        end
    end
    return nil
end
-- 将表格内容转换为 string list.新版，支持枚举。
local function tableToStringList(t)
    local done = {} -- 保存已经处理过的 table， 避免循环引用
    -- strTable 内部使用，嵌套调用时传递当前转换成果
    -- indent 内部使用，嵌套调用时传递缩进
    function _tostr(t, strTable, indent)
        if (t == nil) or done[t] then return end -- 避免重复处理嵌套 table
        done[t] = true
        -- 比较键值顺序的函数
        function less_(a, b)
            local ta, tb = type(a), type(b)
            -- 0:0
            if ta == "number" and tb == "number" then
                return (a < b)
            end
            -- 0:a
            if ta == "number" then
                return false
            end
            -- a:0
            if tb == "number" then
                return true
            end
            -- a:a
            return(tostring(a) < tostring(b))
        end
        -- 为方便阅读查找，对 table 的 key 排序
        local keys = {}
        for k,v in pairs(t) do
            table.insert(keys, k)
        end
        table.sort(keys, less_)
        -- 先看看表格 t 有没有 t.type 属性，并且  t.type 对应有 enumTalbe
        local _enum = t.type and enumTable[t.type] or nil
        -- 开始遍历 table
        for i, k in ipairs(keys) do
            local v = t[k]
            -- 生成 key
            local key
            if type(k) == 'number' then
                key = string.format('[%d]', k)
            else
                key = k
            end
            -- 生成 value
            local type_ = type(v)
            -- 先判断是不是枚举类型, 比如 enumName = enum['camp'] = "CAMPS"
            local enumName = _enum and _enum[k] or nil
            if enumName then
                local str = table.enumString(_G[enumName], t[k])
                table.insert(strTable, string.format("%s%s = %s.%s,", indent, key, enumName, str))
            else
                if type_ == "string" then
                    table.insert(strTable, string.format("%s%s = %q,", indent, key, v))
                elseif type_ == "table" then
                    table.insert(strTable, string.format("%s%s = {", indent, key))
                    _tostr(v, strTable, indent .. "    ")
                    table.insert(strTable, string.format("%s},", indent, key))
                elseif type_ == "nil" or type_ == "boolean" or type_ == "number" then
                    table.insert(strTable, string.format("%s%s = %s,", indent, key, tostring(v)))
                else
                    table.insert(strTable, string.format("%s--%s = %s,", indent, key, tostring(v)))
                end
            end            
        end
    end
    local strTable = {"return {"}
    indent = "    "
    _tostr(t, strTable, indent)
    table.insert(strTable, "}")
    return(strTable)
end
function table.toString(tbl)
    local strList = tableToStringList(tbl)
    return table.concat(strList, "\n")
end
tableToString = table.toString
function tableFromString(str)
     return assert(loadstring(str))()
end
function tableLoad(filename)
    return( require(filename) )
end
function table.save(fileName, t)
    local strList = tableToStringList(t)
    local f, err = io.open(fileName, "wb")
    if f then
        for i,str in ipairs(strList) do
            f:write(str..'\n')
        end
        f:close()
    else
        cclog('table.save: ' .. err)
    end
end
function tableBind(t, obj)
    for k,v in pairs(t) do
        obj[k] = v
    end
end
function tablePrint(tbl)
    local strList = tableToStringList(tbl)
    for i,str in ipairs(strList) do
        cclog(str)
    end
end
table.print = tablePrint
function tableLogDebug(tbl)
    local strList = tableToStringList(tbl)
    for i,str in ipairs(strList) do
        logDebug(str..'\n')
    end
end
-- 删除 table 数组部分
function table.removeArray(t)
    local count = #t
    for i=1,count do
        t[i] = nil
    end
end
-- 计算 key=value 表格有多少项
table.count = function(_tbl)
    local count = 0;
    if (_tbl) then
        for i,v in pairs(_tbl) do
            count = count+1;
        end
    end
    return count;
end
-- 从一个 list 类型 table 中删除一个 item。
-- lua 语言自身的 table.remove(t, index) 是按照 index 来的。
table.removeItem = function(t, item)
    for i,v in ipairs(tbl) do
        if (v == item) then
            table.remove(tbl, i);
        end
    end
end
-- 判断一个 item 是否在 table 中
table.contains = function(t, item)
    for i,v in ipairs(t) do
        if (v == item) then
            return true;
        end
    end
    return false;
end
-- 插入 item 到表格中，如果已经存在，不重复插入
table.insertUniq = function(t, item)
    local inside = false;
    for i,v in ipairs(t) do
        if (v == item) then
            inside = true;
            break;
        end
    end
    if (not inside) then
        table.insert(t, item);
    end
end