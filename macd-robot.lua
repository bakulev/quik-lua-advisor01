-- Флаг работы скрипта
isRun = true
-- Массив с тикерами
dsNameList = {
--    { "TQBR", "GAZP", INTERVAL_M1, 60 },
--    { "TQBR", "LKOH", INTERVAL_M1, 60 },
--    { "TQBR", "SBER", INTERVAL_M1, 60 }
    { "TQBR", "SBER", INTERVAL_H2, 60 * 60 * 2 }
};
-- Настройки
Settings = 
     {
          Name = "MACD-lua",
          period1 = 12, period2 = 26, period3 = 9,
          line=
               {
                    {Name = "Macd", Color = 255, Type = 1, Width = 1},
                    {Name = "Sign", Color = 16711680, Type = 1, Width = 1},
                    {Name = "ZERO", Color = 255, Type = 1, Width = 2}
               }
     }
Settings['Идентификатор графика'] = "sber1";
Settings['Шагов цены вверх'] = 600;

function OnInit()
    path = getScriptPath()
    --message(path)
end

function OnStop()
    isRun = false
    message("stop")
end

function TimeStrToOsTime(V)
    timeStr = tostring(timeStr)
    local osTime = os.date("!*t",os.time())
    local len = string.len(timeStr)
    if len>6 then
        osTime.hour,osTime.min,osTime.sec = string.match(timeStr, "(%d%d)%p(%d%d)%p(%d%d)")
    elseif len==6 then
        osTime.hour,osTime.min,osTime.sec  = string.match(timeStr, "(%d%d)(%d%d)(%d%d)")
    elseif len==5 then
        osTime.hour,osTime.min,osTime.sec  = string.match(timeStr, "(%d)(%d%d)(%d%d)")
    end
    return osTime
end

function DateTimeStrToOsTime(dateStr, timeStr)
    dateStr = tostring(dateStr)
    timeStr = tostring(timeStr)
    local osTime = {} --os.date("!*t",os.time())
    osTime.day, osTime.month, osTime.year = string.match(dateStr, "(%d%d)%p(%d%d)%p(%d%d%d%d)")
    local len = string.len(timeStr)
    if len>6 then
        osTime.hour,osTime.min,osTime.sec = string.match(timeStr, "(%d%d)%p(%d%d)%p(%d%d)")
    elseif len==6 then
        osTime.hour,osTime.min,osTime.sec  = string.match(timeStr, "(%d%d)(%d%d)(%d%d)")
    elseif len==5 then
        osTime.hour,osTime.min,osTime.sec  = string.match(timeStr, "(%d)(%d%d)(%d%d)")
    end
    return osTime
end

function DateTimeTableToDateTimeStr(dt)
   return string.format("%04d-%02d-%02d %02d:%02d:%02d", dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec)
end

function main1()
    while isRun do
        -- Дата и время
        local serverTimeStr = getInfoParam("SERVERTIME")
        local serverDateStr = getInfoParam("TRADEDATE")
        if isConnected() == 1 and serverTimeStr ~= "" then
            message(tostring(os.time(TimeStrToOsTime(serverTimeStr))) .. " " .. tostring(os.time(DateTimeStrToOsTime(serverDateStr, serverTimeStr))))
            -- Перебираем компании: key -порядковый номер, ticker - название тикера
            for key, ticker in pairs(dsNameList) do
                -- Крайняя цена
                sBID=tonumber(getParamEx("TQBR", v, "LAST").param_value);
                message(tostring(k).." "..tostring(v).." "..tostring(sBID))
            end
	end
	sleep(15 * 1000)
    end
end

function main()
    PrintDbgStr("Quik: main test. connecting DSes")
    -- Перебираем компании: key -порядковый номер, ticker - название тикера
    for key, ticker in pairs(dsNameList) do
        DataSource(ticker[1], ticker[2], ticker[3], ticker[4])
    end

    while isRun do
       sleep(100)
    end
end

function DataSource(class, security, interval, shift)
    PrintDbgStr("Quik: DataSource connect " .. class .. " " .. security .. ".")
    -- Подключается к графику цен для входа
    local ds, err = CreateDataSource(class, security, interval)
    -- Ждет, пока данные будут получены с сервера (на случай, если такой график не открыт)  
    while isRun and err == nil and ds:Size() == 0 do
        PrintDbgStr("Quik: DataSource wait connect " .. class .. " " .. security .. ".")
        sleep(100) 
    end
    ds:SetUpdateCallback(function(...) mycallbackforallstocks(class, security, ds, shift, ...) end)
    return ds
end

function mycallbackforallstocks(class, security, DS, shift, idx) 
    -- Теперь в колбеке нам доступны код и класс инструмента
    --if os.time(DS:T(idx)) > os.time() - shift then
    local datetime = { year  = 2018,
                 month = 01,
                 day   = 25,
                 hour  = 18,
                 min   = 49,
                 sec   = 00
               };
    --if os.time(DS:T(idx)) > (os.time(datetime) - shift * 24) then
    if idx >= DS:Size() - 1 and idx < DS:Size() then
        PrintDbgStr("Quik: " .. class .. " " .. security .. " " .. tostring(shift) .. " " .. idx .. " " .. DateTimeTableToDateTimeStr(DS:T(idx)) .. " " .. DS:C(idx))
        AdvisorMacd(class, security, DS, idx, Settings.period1, Settings.period2, Settings.period3)
    end
end


function main2()
    -- Подключается к графику цен для входа
    DS, err = CreateDataSource("TQBR", "SBER", INTERVAL_M1)
    -- Подписывается на обновления
    -- Ждет, пока данные будут получены с сервера (на случай, если такой график не открыт)  
    while isRun and err == nil and DS:Size() == 0 do
        message("wait connect")
        sleep(1000) 
    end
    message("Close = "..tostring(DS:C(DS:Size()-1)))
    if not isRun then return false end
    -- Если произошла ошибка, выводит ее и останавливает скрипт
    if err ~= nil then
        message('Ошибка: '..err)
        OnStop()
        return false
    end
    DS:SetUpdateCallback(Callback)
 
    while isRun do
        --message("isRun sleep")
        sleep(1000)
    end
end
 
OnStop = function()
   isRun = false
end
 
-- функция вызывается при появлении новой свечи, в том числе и после старта приложения
Callback = function(idx)
    -- для отработки только последних актуальных свечей нужно, наверно, текущую дату проверять
    -- и индикатор MACD рассчитывать тут для нужного графика.
    local timeStr = ""
    timeStr = timeStr .. tostring(DS:T(idx).year) .. tostring(DS:T(idx).month) .. tostring(DS:T(idx).day)
    timeStr = timeStr .. tostring(DS:T(idx).hour) .. tostring(DS:T(idx).min) .. tostring(DS:T(idx).sec)
    message("Callback "..tostring(idx) .. " Time=" .. timeStr ..
        " Close=" .. tostring(DS:C(idx)))
    local sum = 0
    local perion = 10
    for i = idx + 1 - period, idx do
        sum = sum + DS:C(i)
    end
    message('MA = '..sum/period)
end

function OnQuote(class_code, sec_code)
    if class_code == "TQBR" and sec_code == "SBER" then
        message("OnQuote: class=" .. class_code .. " sec=" .. sec_code, 1)
        local qt = getQuoteLevel2(class_code, sec_code)
    end
    return
end

function Quot()
    -- получение стакана по указанному классу и бумаге
    local qt = getQuoteLevel2(class_code, sec_code)
    if qt == nil then         --не работает!!!
        return                     -- защита от некорректно заданного инструмента
    end
    message(tostring(qt.bid_count+0) .. " -- " .. tostring(qt.offer_count+0), 2)
    if ((qt.bid_count+0 == 0) or (qt.offer_count+0 == 0)) then
      return                     -- стакан пуст, заявку не ставим
  end
    
  local bid = qt.bid[qt.bid_count+0].price
  local offer = qt.offer[1].price
  local p_spread = (offer - bid) / bid * 100
  local spread_step = math.floor((offer - bid) / PRICE_STEP + 0.01)

  message("bid=" .. tostring(bid) .. " offer=" .. tostring(offer) .. " %=" .. tostring(p_spread) .. " s_step=" .. tostring(spread_step) .. " CURRENT_STATE=" .. CURRENT_STATE, 1)
end

SimpleMovingAverage = function(values, idx, period)
    local sum = 0;
    for i = idx - (period - 1), idx do
        sum = sum + values[i]
    end
    return sum / period
end

function average(_start, _end)
    local sum=0
    for i = _start, _end do
        sum=sum+C(i)
    end
    return sum/(_end-_start+1)
end

CalcEmaClose = function (DS, idx, period)
    local k = 2 / (period + 1)
    local prev = 0
    local curr = 0
    for index = 1, idx do
        prev = curr
        if index < period then
            prev = 0
            for i = 1, index do
                prev = prev + DS:C(i)
            end
            prev = prev / (index - 1 + 1)
        end
        curr = k * DS:C(index) + (1 - k) * prev
    end
    return curr
end

MacdCached = function (DS, idx, period_short, period_long, period_sign, len)
    --PrintDbgStr("Quik: MacdCached idx " .. tostring(idx) .. " period_short " .. tostring(period_short) .. " period_long " .. tostring(period_long))
    --PrintDbgStr("Quik: MacdCached DS:C(idx) " .. tostring(DS:C(idx)))
    local macd_arr = {}
    local signal_arr = {}

    local k_short = 2 / (period_short+1)
    local k_long = 2 / (period_long+1)
    local k_sign = 2 / (period_sign+1)

    local ema_long_prev = 0
    local ema_long = 0
    local ema_short_prev = 0
    local ema_short = 0
    for index = 1, idx do

        -- Calculate EMA short period
        ema_long_prev = ema_long
        if index < period_long then
            for i = 1, index do
                ema_long_prev = ema_long_prev + DS:C(i)
            end
            ema_long_prev = ema_long_prev / (index - 1 + 1)
        end
        ema_long = k_long * DS:C(index) + (1 - k_long) * ema_long_prev

        -- Calculate EMA short period
        ema_short_prev = ema_short
        if index < period_short then
            for i = 1, index do
                ema_short_prev = ema_short_prev + DS:C(i)
            end
            ema_short_prev = ema_short_prev / (index - 1 + 1)
        end
        ema_short = k_short * DS:C(index) + (1 - k_short) * ema_short_prev

        local macd = 100 * (ema_short - ema_long) / DS:C(index)
        if index > (idx - period_sign - len + 1) then
            macd_arr[idx - index + 1] = macd
            --PrintDbgStr("Quik: macd " .. tostring(index) .. " idx " .. tostring(idx) .. " " .. tostring(idx - index + 1) .. " macd " .. tostring(macd))
        end
        -- Calculate average of signal line
        if index > (idx - period_sign - 1) then
            local signal = 0
            for i = idx - index + period_sign, idx - index + 1, -1 do
                --PrintDbgStr("Quik: i" .. tostring(i))
                signal = signal + macd_arr[i]
            end
            signal = signal / period_sign
            signal_arr[idx - index + 1] = signal
            --PrintDbgStr("Quik: sign " .. tostring(index) .. " idx " .. tostring(idx) .. " " .. tostring(idx - index + 1) .. " sign " .. tostring(signal))
        end
        
    end
    --PrintDbgStr("Quik: Result idx " .. tostring(idx) .. " macd " .. tostring(macd) .. " signal " .. tostring(signal))

    return macd_arr, signal_arr
end

AdvisorMacd = function(class, security, DS, idx, period_short, period_long, period_sign)
    --PrintDbgStr("Quik: AdvisorMacd S idx " .. tostring(idx) .. " period_short " .. tostring(period_short) .. " period_long " .. tostring(period_long))
    local macd, sign = MacdCached(DS, idx, period_short, period_long, period_sign, 10)
    for i = 1, 10 do
        PrintDbgStr("Quik: AdvisorMacd idx " .. tostring(idx - i + 1) .. " macd " .. tostring(macd[i]) .. " sign " .. tostring(sign[i]))
    end
    if macd ~= nil and sign ~= nil and macd[1] > sign[1] then
        PrintDbgStr("Quik: Attention to " .. class .. " " .. security .. " MACD advisor: " .. tostring(idx) .. " up")
        message("Attention to " .. class .. " " .. security .. " MACD advisor: " .. tostring(idx) .. " up")
    end
end
