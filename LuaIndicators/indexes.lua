Settings={}
Settings.Name = "Labels";
Settings['�������������'] = "sber1";
Settings['������'] = 5;
Settings['����� ���� �����'] = 600;
 
function Init()
   return 1
end

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

function getCandleProp(index)
	--if CandleExist(index) then	
		local datetimeL = toYYYYMMDDHHMMSS(T(index))		
		return tonumber(string.sub(datetimeL, 1, 8)), tonumber(string.sub(datetimeL, 9)) 
	--end
end 

function Label(index)
   local Date = tonumber(T(index).year);
   local month = tostring(T(index).month);
   if #month == 1 then Date = Date.."0"..month; else Date = Date..month; end;
   local day = tostring(T(index).day);
   if #day == 1 then Date = Date.."0"..day; else Date = Date..day; end;
   Date = tonumber(Date);
   local Time = "";
   local hour = tostring(T(index).hour);
   if #hour == 1 then Time = Time.."0"..hour; else Time = Time..hour; end;
   local minute = tostring(T(index).min);
   if #minute == 1 then Time = Time.."0"..minute; else Time = Time..minute; end;
   local sec = tostring(T(index).sec);
   if #sec == 1 then Time = Time.."0"..sec; else Time = Time..sec; end;
   Time = tonumber(Time);
   --local Date, Time = getCandleProp(index) 
   local label_params = {
      ['TEXT'] = tostring(index), -- STRING ������� ����� (���� ������� �� ���������, �� ������ ������)  
      ['IMAGE_PATH'] = 'C:\\QuikFinam\\LuaIndicators\\icon_arrow_up_4.bmp', -- STRING ���� � ��������, ������� ����� ������������ � �������� ����� (������ ������, ���� �������� �� ���������)  
      ['ALIGNMENT'] = 'BOTTOM', -- STRING ������������ �������� ������������ ������ (�������� 4 ��������: LEFT, RIGHT, TOP, BOTTOM)  
      ['YVALUE'] = H(index) + price_step*Settings['����� ���� �����'], -- DOUBLE �������� ��������� �� ��� Y, � �������� ����� ��������� �����  
      ['DATE'] = Date, -- DOUBLE ���� � ������� ��������Ļ, � ������� ��������� �����  
      ['TIME'] = Time, -- DOUBLE ����� � ������� ������ѻ, � �������� ����� ��������� �����  
      ['R'] = 0, -- DOUBLE ������� ���������� ����� � ������� RGB. ����� � ��������� [0;255]  
      ['G'] = 0, -- DOUBLE ������� ���������� ����� � ������� RGB. ����� � ��������� [0;255]  
      ['B'] = 0, -- DOUBLE ����� ���������� ����� � ������� RGB. ����� � ��������� [0;255]  
      ['TRANSPARENCY'] = 0, -- DOUBLE ������������ ����� � ���������. �������� ������ ���� � ���������� [0; 100]  
      ['TRANSPARENT_BACKGROUND'] = 1, -- DOUBLE ������������ �����. ��������� ��������: �0� � ������������ ���������, �1� � ������������ ��������  
      ['FONT_FACE_NAME'] = 'Verdana', -- STRING �������� ������ (�������� �Arial�)  
      ['FONT_HEIGHT'] = 8, -- DOUBLE ������ ������  
      ['HINT'] = '���������' -- STRING ����� ���������  
   }
   local label_id = AddLabel(Settings['�������������'], label_params);
   --message(tostring(index) .. " Date " .. Date .. " " .. Time .. " " .. tostring(H(index)) .. " Label " .. tostring(label_id) .. " " .. tostring(label_params), 1);
end

function OnCalculate(index)
   if index == 1.0 then
      LastIndex = 1
      DelAllLabels(Settings['�������������'])
      info = getDataSourceInfo()
      price_step = getParamEx(info.class_code, info.sec_code, 'SEC_PRICE_STEP').param_value
   end
   if index - LastIndex < Settings['������'] then return; else LastIndex = index; end;
   Label(index)
end
 
function OnDestroy()
   DelAllLabels(Settings['�������������']);
end;
