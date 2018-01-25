-- ��������� ����������
sIsRun=true;
sDate=0;
sDno=0;
sDistance=0;

--�������� 2009-2016
sInflation=88.77; 

-- ������ � ��������� ��������
aTickerName= {"��������", "�������", "������", 
		"���������", "�������", 
		"��������", "��������", "�������",
		"��� ��", "��������", "����������", 
		"�������", "������", "��������",
		"��������-�", "�.�����", "��������",
		"����", "���", "�������", 
		"������", "���", "�������"}

-- ������ � ��������
aTickerList = {"SBER", "GAZP", "LKOH",
	    "GMKN", "AFKS",
	    "AFLT", "ROSN", "TRNFP",
	    "FEES", "HYDR", "CHMF",
	    "NVTK", "MGNT", "TATN",
	    "SNGSP", "MVID", "IRAO",
	    "NLMK", "MAGN", "RSTI", 
	    "RTKM", "MTSS", "URKA"};

-- ������ � ����� 2008 ����
aTickerLow2008={14, 86, 740,
	    1228, 4.5,
	    20, 94, 6728,
	     0.054, 0.4, 80,
	    50, 312, 32.63,
	     5.16, 24, 0.54,
	     20, 4.5, 0.6,
	    14, 100, 25};

function main()
 	-- ������� �������
 	CreateTable();

 	-- �������� ����
	while sIsRun do
		-- ���� � �����
		sDate=getInfoParam('TRADEDATE').." "..getInfoParam('SERVERTIME');
		-- ���������� ��������: k -���������� �����, v - �������� ������
		for k,v in pairs(aTickerList) do

		   -- ������� ����
		   sBID=tonumber(getParamEx("TQBR", v, "LAST").param_value);
		   -- ��������� ���
		   sDno=math.floor(((aTickerLow2008[k]*(sInflation+100))/100)*100)/100;
		   -- ������� �� ��� %
		   sDistance=math.floor((100-((sDno*100)/sBID))*100)/100;

		   -- ��������� ������ � ��������
    		   SetCell(t_id, k, 0, tostring(sDate));
		   SetCell(t_id, k, 1, tostring(aTickerName[k]));
		   SetCell(t_id, k, 2, tostring(v));
		   SetCell(t_id, k, 3, tostring(sBID));
		   SetCell(t_id, k, 4, tostring(sDno));
		   SetCell(t_id, k, 5, tostring(sDistance));

		  -- ������������ ������
   		   if sDistance<50 then 
			Yellow(k);
		   end;
		  -- ������������ �������
   		   if sDistance>80 then 
			Red(k);
		   end;
		  -- ������������ �������
   		   if sDistance<0 then 
			Green(k);
		   end;


		end;

		-- ����
		sleep(50000);
   	end;
end;


--- ������� ������� �������
function CreateTable()
	-- �������� ��������� id ��� ��������
	t_id = AllocTable();	
	-- ��������� 6 �������
	AddColumn(t_id, 0, "����", true, QTABLE_INT_TYPE, 15);
	AddColumn(t_id, 1, "��������", true, QTABLE_INT_TYPE, 15);
 	AddColumn(t_id, 2, "Ticker", true, QTABLE_INT_TYPE, 15);
 	AddColumn(t_id, 3, "BID", true, QTABLE_INT_TYPE, 15);
 	AddColumn(t_id, 4, "��������� ���", true, QTABLE_INT_TYPE, 15);
 	AddColumn(t_id, 5, "������� �� ��� (%)", true, QTABLE_INT_TYPE, 15);
	-- �������
	t = CreateWindow(t_id);
	-- ���� ���������	
	SetWindowCaption(t_id, "��������");
   -- ��������� ������
      for k,v in pairs(aTickerList) do
	InsertRow(t_id, k);
      end
end;

--- ������� �� ��������� ����� �������
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

-- ������� ���������� ����� ������������ ������������� ������
function OnStop()
   sIsRun = false;
end;