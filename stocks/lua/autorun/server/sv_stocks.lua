util.AddNetworkString("StockMenu_Open");
util.AddNetworkString("NewStockDataReceived");
util.AddNetworkString("Player_ShareActions");
util.AddNetworkString("ChatMsg_CL");


stockdata = {};

local function ChatMsgCL(ply, msg)
	net.Start("ChatMsg_CL");
		net.WriteString(msg);
	net.Send(ply);
end

//this reloads the layout of the menu if it's open.
local function UpdateLayoutCL()
	net.Start("NewStockDataReceived");
		net.WriteTable(stockdata);
	net.Broadcast();
end

//this however reloads the clients networked shares.
local function ReloadShares_CL(ply)
	local shares = ply.Shares or {};

	for k,v in pairs(shares) do
		ply:SetNWInt("Share_"..k, v);
	end
end

local function PricePerStock(symb)
	local li = stockdata["query"]["results"]["quote"]; //client table

	for k,v in pairs(li) do
		if (v["Symbol"] == symb) then return v["LastTradePriceOnly"]; end
	end
	return 0;
end

//local url = stock.Host.."?q=select * from yahoo.finance.stocks where symbol='"..stock.Stocklist.."'&format=json"
local url = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20('"..stock.Stocklist.."')&env=http://datatables.org/alltables.env&format=json"
hook.Add("Initialize", "PrintStockData", function()
	print("Stock - About to pull stock info from Yahoo Finance!");
	http.Fetch( url,
		function( body, len, headers, code )
			if (body) then
				stockdata = util.JSONToTable(body);
			end
		end,
		function( error )
			print(error)
		end
	);


	timer.Create("UpdateStockInfo", stock.StockPullInterval, 0, function()
		print("Stock - About to pull stock info from Yahoo Finance!");
		http.Fetch( url,
			function( body, len, headers, code )
				if (body) then
					stockdata = util.JSONToTable(body);
					UpdateLayoutCL();
				end
			end,
			function( error )
				print(error)
			end
		 );
			PrintTable(stockdata);

	end)
end)

hook.Add("PlayerSay", "OpenStockMenu", function(ply, text)
	if (text == "!s") then
		net.Start("StockMenu_Open");
			net.WriteTable(stockdata);
		net.Send(ply);
	end
end)

hook.Add("PlayerSpawn", "LoadShares", function(ply)
	local shares = {};

	local fil = file.Read("stocks/shares_"..ply:UniqueID()..".txt", "DATA");
	if (fil) then
		local tbl = util.JSONToTable(fil);
		ply.Shares = tbl;
		ReloadShares_CL(ply);
	else
		for k,v in pairs(stock.RealNameList) do
			shares[k] = 0;
			ply.Shares = shares;
		end
		ReloadShares_CL(ply);
	end
end)

local function SaveShares(caller)
	local shares = caller.Shares or {};
	local shares = util.TableToJSON(shares);
	if (!file.IsDir("stocks", "DATA")) then file.CreateDir("stocks"); end
	local fil = file.Write("stocks/shares_"..caller:UniqueID()..".txt", shares);
	if (fil) then ChatMsgCL(caller, "Shares saved!"); end
end
	

local function BuyShare(num, sto, caller)
	if (!num or !sto) then ChatMsgCL(caller, "No number or stock supplied!"); return; end
	
	local num = tonumber(num);
	if (!num) then ChatMsgCL(caller, "Improper number of shares sent to the server! Was there a non-numerical character in yours?"); return; end
	
	local sto = table.KeyFromValue(stock.RealNameList, sto);
	local cur_shares = caller:GetShares(sto);
	if (cur_shares == stock.SharesPerStock) then ChatMsgCL(caller, "You have the max amount of shares for this stock allowed!"); return; end
	if (cur_shares + num > stock.SharesPerStock) then num = stock.SharesPerStock - cur_shares; end //will be too many; just give them enough until they reach max, not go over.

	local pps = PricePerStock(sto);
	local price = num * pps;
	if (!caller:canAfford(price)) then ChatMsgCL(caller, "You can't afford this many stocks! Make sure you view the preview price on the GUI!"); return; end
	
	caller:addMoney(price * -1);
	caller:SetNWInt("Share_"..sto, cur_shares + num);
	caller.Shares[sto] = cur_shares + num;
	ChatMsgCL(caller, "Thanks for your purchase of "..num.." shares!");
	SaveShares(caller);
end

local function SellShare(num, sto, caller)
	if (!num or !sto) then ChatMsgCL(caller, "No number or stock supplied!"); return; end
	
	local num = tonumber(num);
	if (!num) then ChatMsgCL(caller, "Improper number of shares sent to the server! Was there a non-numerical character in yours?"); return; end
	
	local sto = table.KeyFromValue(stock.RealNameList, sto);
	local cur_shares = caller:GetShares(sto);
	if (cur_shares == 0) then ChatMsgCL(caller, "You don't own any shares! Therefore you can't sell any!"); return; end
	if (cur_shares - num < 0) then 
		local dif = num - cur_shares; //get how many are left over
		num = num - dif;
	end //will be too many; just give them enough until they reach max, not go over.

	local pps = PricePerStock(sto);
	local price = num * pps;
	
	caller:addMoney(price);
	caller:SetNWInt("Share_"..sto, cur_shares - num);
	caller.Shares[sto] = cur_shares - num;
	ChatMsgCL(caller, "You have made "..price.." from "..num.." shares!");
	SaveShares(caller);
end

net.Receive("Player_ShareActions", function(len, caller)
	local num = net.ReadString();
	local stock = net.ReadString();
	local act = net.ReadString();

	if (act == "Buy") then
		BuyShare(num, stock, caller);
	else
		SellShare(num, stock, caller);
	end
end)

hook.Add("PlayerDisconnect", "SaveShares", function(ply)
	SaveShares(ply);
end)