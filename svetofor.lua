-- Обьявляем переменные
sIsRun=true;
sDate=0;
sDno=0;
sDistance=0;

--Инфляция 2009-2016
sInflation=88.77; 

-- Массив с названием компаний
aTickerName= {"Сбербанк", "Газпром", "Лукойл", 
		"ГМКНорНик", "Система", 
		"Аэрофлот", "Роснефть", "Транснф",
		"ФСК ЕС", "РусГидро", "СеверСталь", 
		"Новатек", "Магнит", "Татнефть",
		"Сургнфтз-п", "М.видео", "ИнтерРАО",
		"НЛМК", "ММК", "Россети", 
		"Ростел", "МТС", "Уркалий"}

-- Массив с тикерами
aTickerList = {"SBER", "GAZP", "LKOH",
	    "GMKN", "AFKS",
	    "AFLT", "ROSN", "TRNFP",
	    "FEES", "HYDR", "CHMF",
	    "NVTK", "MGNT", "TATN",
	    "SNGSP", "MVID", "IRAO",
	    "NLMK", "MAGN", "RSTI", 
	    "RTKM", "MTSS", "URKA"};

-- Массив с лоями 2008 года
aTickerLow2008={14, 86, 740,
	    1228, 4.5,
	    20, 94, 6728,
	     0.054, 0.4, 80,
	    50, 312, 32.63,
	     5.16, 24, 0.54,
	     20, 4.5, 0.6,
	    14, 100, 25};

function main()
 	-- Создает таблицу
 	CreateTable();

 	-- Основной цикл
	while sIsRun do
		-- Дата и время
		sDate=getInfoParam('TRADEDATE').." "..getInfoParam('SERVERTIME');
		-- Перебираем компании: k -порядковый номер, v - название тикера
		for k,v in pairs(aTickerList) do

		   -- Крайняя цена
		   sBID=tonumber(getParamEx("TQBR", v, "LAST").param_value);
		   -- Расчетное дно
		   sDno=math.floor(((aTickerLow2008[k]*(sInflation+100))/100)*100)/100;
		   -- Сколько до дна %
		   sDistance=math.floor((100-((sDno*100)/sBID))*100)/100;

		   -- Вставляем данные в табличку
    		   SetCell(t_id, k, 0, tostring(sDate));
		   SetCell(t_id, k, 1, tostring(aTickerName[k]));
		   SetCell(t_id, k, 2, tostring(v));
		   SetCell(t_id, k, 3, tostring(sBID));
		   SetCell(t_id, k, 4, tostring(sDno));
		   SetCell(t_id, k, 5, tostring(sDistance));

		  -- Раскрашиваем желтым
   		   if sDistance<50 then 
			Yellow(k);
		   end;
		  -- Раскрашиваем красным
   		   if sDistance>80 then 
			Red(k);
		   end;
		  -- Раскрашиваем зеленым
   		   if sDistance<0 then 
			Green(k);
		   end;


		end;

		-- Спим
		sleep(50000);
   	end;
end;


--- Функция создает таблицу
function CreateTable()
	-- Получает доступный id для создания
	t_id = AllocTable();	
	-- Добавляет 6 колонок
	AddColumn(t_id, 0, "Дата", true, QTABLE_INT_TYPE, 15);
	AddColumn(t_id, 1, "Название", true, QTABLE_INT_TYPE, 15);
 	AddColumn(t_id, 2, "Ticker", true, QTABLE_INT_TYPE, 15);
 	AddColumn(t_id, 3, "BID", true, QTABLE_INT_TYPE, 15);
 	AddColumn(t_id, 4, "Расчетное дно", true, QTABLE_INT_TYPE, 15);
 	AddColumn(t_id, 5, "Сколько до дна (%)", true, QTABLE_INT_TYPE, 15);
	-- Создаем
	t = CreateWindow(t_id);
	-- Даем заголовок	
	SetWindowCaption(t_id, "Компании");
   -- Добавляет строку
      for k,v in pairs(aTickerList) do
	InsertRow(t_id, k);
      end
end;

--- Функции по раскраске ячеек таблицы
function Red(col)
 for i=0, 5 do
	SetColor(t_id, col, i, RGB(255,168,164), RGB(0,0,0), RGB(255,168,164), RGB(0,0,0));
 end;
end;
function Green(col)
 for i=0, 5 do
	SetColor(t_id, col, i, RGB(157,241,163), RGB(0,0,0), RGB(157,241,163), RGB(0,0,0));
 end;
end;
function Yellow(col)
 for i=0, 5 do
	SetColor(t_id, col, i, RGB(249,247,172), RGB(0,0,0), RGB(249,247,172), RGB(0,0,0));
 end;
end;

-- Функция вызывается когда пользователь останавливает скрипт
function OnStop()
   sIsRun = false;
end;