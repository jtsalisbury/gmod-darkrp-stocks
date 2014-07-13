local colors = {
	head = Color(192, 57, 43, 255),
	back = Color(236, 240, 241, 255),
	text = Color(255, 255, 255, 255),
	text_blue = Color(52, 152, 219, 255),
	btn = Color(52, 73, 94, 255),
	btn_hover = Color(44, 62, 80, 255),
	btn_disabled = Color(52, 73, 94, 150),
	open = Color(46, 204, 113, 255),
	open_hover = Color(39, 174, 96, 255),
	open_disabled = Color(46, 2014, 113, 150),
	cancel = Color(231, 76, 60, 255),
	cancel_hover = Color(192, 57, 43, 255),
	bar = Color(189, 195, 199, 255),
	barup = Color(127, 140, 141, 255),
	closed = Color(230, 126, 34, 255),
	closed_hover = Color(211, 84, 0, 255),
	info_back = Color(189, 195, 199, 255),
	gray = Color(189, 195, 199, 255),
	gray_hover = Color(127, 140, 141, 255),
}
--[[asdf]]--
surface.CreateFont("stockHead", {font = "OpenSans-Bold", size = 60, weight = 500})
surface.CreateFont("stockBtn", {font = "OpenSans-Regular", size = 30, weight = 500})
surface.CreateFont("stockBtnSmall", {font = "OpenSans-Light", size = 15, weight = 500})

local c = nil;
local frame = nil;



local function CreateChartMenu(link, name)
	if (c) then c:Close(); end
	if (frame) then frame:SetVisible(false); end

	local f = vgui.Create("DFrame");
	f:SetPos(100, 100);
	f:SetSize(837, 545);
	f:SetTitle(" ");
	f:SetVisible(true);
	f:MakePopup();
	f:Center();
	f.ChartName = name;
	f:ShowCloseButton(false);
	f.Paint = function()
		draw.RoundedBox(0, 0, 0, f:GetWide(), f:GetTall(), colors.back);
		draw.RoundedBox(0, 0, 0, f:GetWide(), 100, colors.head);
		draw.SimpleText("Chart for "..name, "stockHead", f:GetWide() / 2, 25, colors.text, TEXT_ALIGN_CENTER);
	end

	c = f;

	local ht = vgui.Create("DHTML", f);
	ht:SetSize(f:GetWide() - 20, f:GetTall() - 180);
	ht:SetPos(10, 110);
	ht:OpenURL(link);

	local close = vgui.Create("DButton", f);
	close:SetText("");
	close:SetSize(f:GetWide() - 20, 50);
	close:SetPos(10, f:GetTall() - 60);
	close.DoClick = function()
		c = nil;
		frame:SetVisible(true);
		f:Close();
	end
	local ca = false; 
	function close:OnCursorEntered() ca = true; end
	function close:OnCursorExited() ca = false; end
	close.Paint = function()
		if (ca) then
			draw.RoundedBox(0, 0, 0, close:GetWide(), close:GetTall(), colors.cancel_hover);
		else
			draw.RoundedBox(0, 0, 0, close:GetWide(), close:GetTall(), colors.cancel);
		end
		draw.SimpleText("Close", "stockBtn", close:GetWide() / 2, 10, colors.text, TEXT_ALIGN_CENTER);
	end
end


net.Receive("StockMenu_Open", function()
	local stocklist = net.ReadTable();
	local opt = nil;
	local action = nil;

	local function PricePerStock(symb)
		local li = stocklist["query"]["results"]["quote"]; //client table

		for k,v in pairs(li) do
			if (v["Symbol"] == symb) then return v["LastTradePriceOnly"] or 0; end
		end
	end

	local f = vgui.Create("DFrame");
	f:SetPos(100, 100);
	f:SetSize(ScrW() - 100, ScrH() - 100);
	f:SetTitle(" ");
	f:SetVisible(true);
	f:MakePopup();
	f:Center();
	f:ShowCloseButton(false);
	f.Paint = function()
		draw.RoundedBox(0, 0, 0, f:GetWide(), f:GetTall(), colors.back);
		draw.RoundedBox(0, 0, 0, f:GetWide(), 100, colors.head);
		draw.SimpleText("GStock Market", "stockHead", f:GetWide() / 2, 25, colors.text, TEXT_ALIGN_CENTER)
	end

	frame = f;

	local pan = vgui.Create("DScrollPanel", f);
	pan:SetSize(f:GetWide() - 355, f:GetTall() - 120);
	pan:SetPos(10, 110);
	pan:GetVBar().Paint = function() draw.RoundedBox(0, 0, 0, pan:GetVBar():GetWide(), pan:GetVBar():GetTall(), Color(255, 255, 255, 0)) end
	pan:GetVBar().btnUp.Paint = function() draw.RoundedBox(0, 0, 0, pan:GetVBar().btnUp:GetWide(), pan:GetVBar().btnUp:GetTall(), colors.barup) end
	pan:GetVBar().btnDown.Paint = function() draw.RoundedBox(0, 0, 0, pan:GetVBar().btnDown:GetWide(), pan:GetVBar().btnDown:GetTall(), colors.barup) end
	pan:GetVBar().btnGrip.Paint = function(w, h) draw.RoundedBox(0, 0, 0, pan:GetVBar().btnGrip:GetWide(), pan:GetVBar().btnGrip:GetTall(), colors.bar) end
	
	local slist = vgui.Create("DIconLayout", pan);
	slist:SetSize(pan:GetWide() - 15, pan:GetTall());
	slist:SetPos(0, 0);
	slist:SetSpaceY(5);
	slist:SetSpaceX(5);

	local function UpdateList()
		local lis = stocklist["query"]["results"]["quote"];

		for k,v in pairs(lis) do

			local li = slist:Add("DPanel");
			li:SetSize(400, 200);
			li.Paint = function()
				draw.RoundedBox(0, 0, 0, li:GetWide(), li:GetTall(), colors.btn);
			end

			local lbl = vgui.Create("DLabel", li);
			lbl:SetText(stock.RealNameList[v["Symbol"]]);
			lbl:SetPos(10, 10);
			lbl:SetFont("stockBtn");
			lbl:SetTextColor(colors.text);
			lbl:SizeToContents();

			local per = vgui.Create("DLabel", li);
			per:SetText("Percent Change: "..v["PercentChange"]);
			per:SetPos(10, 45);
			per:SetFont("stockBtn");
			if (string.find(v["PercentChange"], "+")) then
				per:SetTextColor(colors.open);
			else
				per:SetTextColor(colors.cancel);
			end
			per:SizeToContents();

			local pr = vgui.Create("DLabel", li);
			pr:SetText("Price Per Share: $"..v["LastTradePriceOnly"]);
			pr:SetPos(10, 80);
			pr:SetFont("stockBtn");
			pr:SetTextColor(colors.text);
			pr:SizeToContents();

			local mc = vgui.Create("DLabel", li);
			mc:SetText("Company Worth: $"..v["MarketCapitalization"]);
			mc:SetPos(10, 115);
			mc:SetFont("stockBtn");
			mc:SetTextColor(colors.text);
			mc:SizeToContents();

			local oc = vgui.Create("DLabel", li);
			oc:SetText("Last Open/Close: $"..v["Open"].."/$"..v["PreviousClose"]);
			oc:SetPos(10, 150);
			oc:SetFont("stockBtn");
			oc:SetTextColor(colors.text);
			oc:SizeToContents();

			local btn = vgui.Create("DButton", li);
			btn:SetText(" ");
			btn:SetFont("stockBtnSmall");
			btn:SetPos(li:GetWide() - 100, 0);
			btn:SetSize(100, 40);
			btn.ChartURL = "https://chart.finance.yahoo.com/z?s="..v["Symbol"].."&t=1y&q=&l=&z=l&a=v&p=s&lang=en-US&region=US";
			btn.SymName = lbl:GetText();
			btn.DoClick = function()
				CreateChartMenu(btn.ChartURL, btn.SymName);
			end
			local ba = false; 
			function btn:OnCursorEntered() ba = true; end
			function btn:OnCursorExited() ba = false; end
			btn.Paint = function()
				if (ba) then
					draw.RoundedBox(0, 0, 0, btn:GetWide(), btn:GetTall(), colors.gray_hover);
				else
					draw.RoundedBox(0, 0, 0, btn:GetWide(), btn:GetTall(), colors.gray);
				end
				
				draw.SimpleText("Chart", "stockBtn", btn:GetWide() / 2, 5, colors.text, TEXT_ALIGN_CENTER);
			end
		end
	end
	UpdateList();

	local stLbl = vgui.Create("DLabel", f);
	stLbl:SetPos(f:GetWide() - 335, 110);
	stLbl:SetText("Choose a stock:");
	stLbl:SetFont("stockBtn");
	stLbl:SetTextColor(colors.text_blue);
	stLbl:SizeToContents();

	local stBox = vgui.Create("DComboBox", f);
	stBox:SetPos(f:GetWide() - 335, 145)
	stBox:SetSize(325, 40);
	stBox:SetValue("Stock");
	for k,v in pairs(stock.RealNameList) do
		stBox:AddChoice(v);
	end

	local canDo = vgui.Create("DLabel", f);
	canDo:SetPos(f:GetWide() - 335, 175);
	canDo:SetText(" ");
	canDo:SetFont("stockBtnSmall");
	canDo:SetTextColor(colors.text_blue);
	canDo:SizeToContents();

	local numLbl = vgui.Create("DLabel", f);
	numLbl:SetPos(f:GetWide() - 335, 225);
	numLbl:SetText("Number of shares to buy/sell:");
	numLbl:SetFont("stockBtn");
	numLbl:SetTextColor(colors.text_blue);
	numLbl:SizeToContents();

	local num = vgui.Create("DTextEntry", f);
	num:SetPos(f:GetWide() - 335, 260);
	num:SetSize(325, 40);
	num:SetText("0");
	num:SetNumeric(true);
	num.OnTextChanged = function()
		if (string.len(num:GetValue()) > stock.SharesPerStock) then num:SetText("1000"); end
	end

	stBox.OnSelect = function(panel, ind, val)
		opt = val;
		local key = table.KeyFromValue(stock.RealNameList, opt);
		local shares = LocalPlayer():GetShares(key);
		canDo:SetText("Shares "..shares.."/"..stock.SharesPerStock);
		canDo:SetSize(325, 50);
	end

	local actBox = vgui.Create("DComboBox", f);
	actBox:SetPos(f:GetWide() - 335, 310)
	actBox:SetSize(325, 40);
	actBox:SetValue("Buy or Sell");
	actBox:AddChoice("Buy");
	actBox:AddChoice("Sell");
	actBox.OnSelect = function(p, i, val)
		action = val;
	end

	local cost = vgui.Create("DLabel", f);
	cost:SetPos(f:GetWide() - 335, f:GetTall() - 185);
	cost:SetText(" ");
	cost:SetFont("stockBtn");
	cost:SetTextColor(colors.text_blue);
	cost:SizeToContents();

	local doit = vgui.Create("DButton", f);
	doit:SetText("");
	doit:SetSize(325, 50);
	doit:SetPos(f:GetWide() - 335, f:GetTall() - 120);
	doit:SetDisabled(true);
	doit.DoClick = function()
		if (opt && action && num:GetValue()) then
			net.Start("Player_ShareActions")
				net.WriteString(num:GetValue());
				net.WriteString(opt);
				net.WriteString(action);
			net.SendToServer();
		end
	end
	local ba = false; 
	function doit:OnCursorEntered() ba = true; end
	function doit:OnCursorExited() ba = false; end
	doit.Paint = function()
		if (doit:GetDisabled()) then
			draw.RoundedBox(0, 0, 0, doit:GetWide(), doit:GetTall(), colors.open_disabled);
		else
			if (ba) then
				draw.RoundedBox(0, 0, 0, doit:GetWide(), doit:GetTall(), colors.open_hover);
			else
				draw.RoundedBox(0, 0, 0, doit:GetWide(), doit:GetTall(), colors.open);
			end
		end
		draw.SimpleText("Do it!", "stockBtn", doit:GetWide() / 2, 10, colors.text, TEXT_ALIGN_CENTER);
	end

	function f:Think()
		if (!opt or !action or !num:GetValue()) then return; end
		if (doit:GetDisabled()) then doit:SetDisabled(false); end
		local key = table.KeyFromValue(stock.RealNameList, opt);
		local pric = PricePerStock(key);		
		local pric_tot = (tonumber(pric) * tonumber(num:GetValue()));

		if (action == "Buy") then 
			cost:SetText("This will cost you: $"..string.Comma(pric_tot));
			cost:SetSize(320, 70);
		else //selling
			cost:SetText("If you have enough shares, \nyou will get: $"..string.Comma(pric_tot));
			cost:SetSize(320, 70);
			cost:SetPos(f:GetWide() - 335, f:GetTall() - 225)
		end
		
	end

	local cancel = vgui.Create("DButton", f);
	cancel:SetText("");
	cancel:SetSize(325, 50);
	cancel:SetPos(f:GetWide() - 335, f:GetTall() - 60);
	cancel.DoClick = function()
		f:Close();
	end
	local ca = false; 
	function cancel:OnCursorEntered() ca = true; end
	function cancel:OnCursorExited() ca = false; end
	cancel.Paint = function()
		if (ca) then
			draw.RoundedBox(0, 0, 0, cancel:GetWide(), cancel:GetTall(), colors.cancel_hover);
		else
			draw.RoundedBox(0, 0, 0, cancel:GetWide(), cancel:GetTall(), colors.cancel);
		end
		
		draw.SimpleText("Cancel", "stockBtn", cancel:GetWide() / 2, 10, colors.text, TEXT_ALIGN_CENTER);
	end

	net.Receive("NewStockDataReceived", function()
		if (IsValid(f)) then
			MsgN("New stock data received! Updating layout..");
			slist:Clear();
			UpdateList(); //reload the diconlayout
		end
	end)
end)


net.Receive("ChatMsg_CL", function()
	local msg = net.ReadString();
	chat.AddText(stock.BracketColor, "[", stock.StockTextColor, "GStock", stock.BracketColor, "] ", stock.MsgColor, msg);
end)