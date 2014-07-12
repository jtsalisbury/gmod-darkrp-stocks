util.AddNetworkString("StockMenu_Open");
util.AddNetworkString("NewStockDataReceived");


stockdata = {};

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