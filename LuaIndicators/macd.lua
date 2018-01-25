------------------------------------------------------------------------
-- Macd.lua, � hismatullin.h@gmail.com, 23.11.2014
-- �������� ������: period1
-- ������� ������: period2
-- ���������� �������� ���������� ���������� �������: period3
-- ����� ���������� �����: Exponential
------------------------------------------------------------------------
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
Settings['������������� �������'] = "sber1";
Settings['����� ���� �����'] = 600;
-------------------------------
function Init()
     Macd = cached_Macd()
     path = getScriptPath()
     return 3
end
-------------------------------
function OnCalculate(index)
    if index == 1.0 then
        LastIndex = 1
        DelAllLabels(Settings['�������������'])
        info = getDataSourceInfo()
        price_step = getParamEx(info.class_code, info.sec_code, 'SEC_PRICE_STEP').param_value
     	label_count = 0
     end
     return Macd(index, Settings.period1, Settings.period2, Settings.period3)
end
-------------------------------
function average(_start, _end)
     local sum=0
     for i = _start, _end do
          sum=sum+C(i)
     end
     return sum/(_end-_start+1)
end
-------------------------------
function toYYYYMMDDHHMMSS(datetime)
   if type(datetime) ~= "table" then
      --message("� ������� toYYYYMMDDHHMMSS ������� ����� ��������: datetime="..tostring(datetime))
      return ""
   else
      local Res = tostring(datetime.year)
      if #Res == 1 then Res = "000"..Res end
      local month = tostring(datetime.month)
      if #month == 1 then Res = Res.."0"..month; else Res = Res..month; end
      local day = tostring(datetime.day)
      if #day == 1 then Res = Res.."0"..day; else Res = Res..day; end
      local hour = tostring(datetime.hour)
      if #hour == 1 then Res = Res.."0"..hour; else Res = Res..hour; end
      local minute = tostring(datetime.min)
      if #minute == 1 then Res = Res.."0"..minute; else Res = Res..minute; end
      local sec = tostring(datetime.sec);
      if #sec == 1 then Res = Res.."0"..sec; else Res = Res..sec; end;
      return Res
   end
end --toYYYYMMDDHHMMSS
-------------------------------
function getCandleProp(index)
	--if CandleExist(index) then	
		local datetimeL = toYYYYMMDDHHMMSS(T(index))		
		return tonumber(string.sub(datetimeL, 1, 8)), tonumber(string.sub(datetimeL, 9)) 
	--end
end
-------------------------------
function Label(index, updown)
    local Date, Time = getCandleProp(index) 
   local label_params = {
      ['TEXT'] = tostring(index), -- STRING ������� ����� (���� ������� �� ���������, �� ������ ������)  
      ['IMAGE_PATH'] = 'C:\\QuikFinam\\LuaIndicators\\icon_arrow_up_4.bmp', -- STRING ���� � ��������, ������� ����� ������������ � �������� ����� (������ ������, ���� �������� �� ���������)  
      ['ALIGNMENT'] = 'BOTTOM', -- STRING ������������ �������� ������������ ������ (�������� 4 ��������: LEFT, RIGHT, TOP, BOTTOM)  
      ['YVALUE'] = H(index) + price_step * Settings['����� ���� �����'], -- DOUBLE �������� ��������� �� ��� Y, � �������� ����� ��������� �����  
      ['DATE'] = Date, -- DOUBLE ���� � ������� "��������", � ������� ��������� �����  
      ['TIME'] = Time, -- DOUBLE ����� � ������� "������", � �������� ����� ��������� �����  
      ['R'] = 0, -- DOUBLE ������� ���������� ����� � ������� RGB. ����� � ��������� [0;255]  
      ['G'] = 0, -- DOUBLE ������� ���������� ����� � ������� RGB. ����� � ��������� [0;255]  
      ['B'] = 0, -- DOUBLE ����� ���������� ����� � ������� RGB. ����� � ��������� [0;255]  
      ['TRANSPARENCY'] = 0, -- DOUBLE ������������ ����� � ���������. �������� ������ ���� � ���������� [0; 100]  
      ['TRANSPARENT_BACKGROUND'] = 1, -- DOUBLE ������������ �����. ��������� ��������: �0� � ������������ ���������, "1" � ������������ ��������  
      ['FONT_FACE_NAME'] = 'Verdana', -- STRING �������� ������ (�������� �Arial�)  
      ['FONT_HEIGHT'] = 8, -- DOUBLE ������ ������  
      ['HINT'] = '���������' -- STRING ����� ���������  
   }
   --label_params['TEXT'] = tostring(label_count)  
   if updown == 1 then
	label_params['IMAGE_PATH'] = 'C:\\QuikFinam\\LuaIndicators\\icon_arrow_down_4.bmp'
	label_params['YVALUE'] = L(index) - price_step
	label_params['HINT'] = '���������'
   end
   local label_id = AddLabel(Settings['������������� �������'], label_params);
   --message(tostring(index) .. " Date " .. Date .. " " .. Time .. " " .. tostring(H(index)) .. " Label " .. tostring(label_id) .. " " .. tostring(label_params), 1);	
end
-------------------------------
function cached_Macd()
     local cache_EMA_long={}
     local cache_EMA_short={}
     local cache_MACD={}
     local cache_Sign={}
     return function(ind, _p01, _p02, _p03)
          local n_ema_short = 0 --������ EMA ��������
          local p_ema_short = 0 --���������� EMA ��������
          local n_sign = 0 --������ sign
          local p_sign = 0 --���������� sign
          local period_short = _p01
          local period_long = _p02
          local period_sign = _p03
          local index = ind
          local k_short = 2/(period_short+1)
          local k_long = 2/(period_long+1)
          local k_sign = 2/(period_sign+1)
          if index == 1 then
               cache_EMA_long = {}
               cache_EMA_short = {}
               cache_MACD = {}
               cache_Sign={}
          end
          -----------------------------------------------
          if index < period_long then
               cache_EMA_long[index] = average(1,index)
               return nil
          end
          p_ema_long = cache_EMA_long[index-1] or C(index)
          n_ema_long = k_long*C(index)+(1-k_long)*p_ema_long
          cache_EMA_long[index] = n_ema_long
          -----------------------------------------------
          if index < period_short then
               cache_EMA_short[index] = average(1,index)
               return nil
          end
          p_ema_short = cache_EMA_short[index-1] or C(index) 
          n_ema_short = k_short*C(index)+(1-k_short)*p_ema_short
          cache_EMA_short[index] = n_ema_short
          -----------------------------------------------
          --������� ����������
	  n_macd = 100 * (n_ema_short-n_ema_long) / C(index)
          cache_MACD[index] = n_macd 
          --p_sign = cache_Sign[index-1] or cache_MACD[index]
          --n_sign = k_sign*cache_MACD[index]+(1-k_sign)*p_sign
          --cache_Sign[index] = n_sign
	  if cache_MACD[index - period_sign + 1] then
	  	local sum = 0
	  	for i = index - period_sign + 1, index do
			sum = sum + cache_MACD[i]
	  	end
	  	n_sign = sum / period_sign --/ 2.33 
	  else
		n_sign = nil
	  end
          cache_Sign[index] = n_sign
          -----------------------------------------------
	  if n_macd ~= nil and n_sign ~= nil and n_macd > n_sign then
		  if label_count >= 0 then
			  label_count = label_count + 1
		  else
			  label_count = 0
		  end
		  if label_count == 1 then
			  Label(index, 0)
		  end
	  else
		  if label_count <= 0 then
			  label_count = label_count - 1
		  else
			  label_count = 0
		  end
		  if label_count == -1 then
			  Label(index, 1)
		  end
	  end
	  --message("index=" .. tostring(index), 1);
          return n_macd, n_sign, 0
     end
end
------------------------------------------------------------------------ 
function OnDestroy()
   DelAllLabels(Settings['������������� �������'])
end
------------------------------------------------------------------------ 
