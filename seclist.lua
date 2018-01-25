-- seclist_csv.lua, © smart-lab.ru/profile/XXM/
-- список бумаг, транслируемые QUIK-ом

local ver = '0.91'      --      22.12.2016
local scriptPath = getScriptPath()
local Terminal_Version=getInfoParam('VERSION')
local logFile = scriptPath..'\\'..'seclist.csv'
local file = io.open(logFile, "w")
assert(file, "Ошибка открытия "..logFile)

function string.split(str, sep)
    local fields = {}
        str:gsub(string.format("([^%s]+)", sep), function(f_c) fields[#fields + 1] = f_c end)
        return fields
end

function write_log(str)
        file:write(str .. "\n")
end

function Main()
        local local_datetime = os.time(os.date("*t"))
        local dtd = os.date("%d.%m.%Y %H:%M",local_datetime)
        local mes = 'Start seclist_csv '..ver..', QUIK '..Terminal_Version..', '..dtd
        message(mes);
        file:write(mes .. "\n")
        class_list = getClassesList()
        mes = 'class_list =  '..class_list
        message(mes); write_log(mes);
        local class_listT = {}
        class_listT = string.split(class_list, ',')
        for i = 1, #class_listT do
                local fline = class_listT[i]
                if fline == 'TQBR' then
                        -- для примера - только акции!
                        local classInfo = {}
                        classInfo = getClassInfo(fline)
                        -- 3.2.2 getClassInfo
                        -- Функция предназначена для получения информации о классе.
                        local sec_list = getClassSecurities(classInfo.code)
                        local sec_listTable = {}
                        sec_listTable = string.split(sec_list, ',')
                        for i = 1, #sec_listTable do
                                local classCode = classInfo.code
                                local secCode = sec_listTable[i]
                                local securityInfo = getSecurityInfo(classCode, secCode)
                                local name = securityInfo.name
                                local step = securityInfo.min_price_step
                                local secInfo = classInfo.name..';'..classCode..';'..name..';'..secCode..';'..step
                                write_log(secInfo);
                        end
                end
        end
        local mes = 'Готово!'
        message(mes); write_log(mes);
        file:flush()
        file:close()
end

Main()
