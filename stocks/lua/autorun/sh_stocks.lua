stock = {};

stock.Stocklist = "GOOG,INTC,VZ,MSFT,KO,DIS,BA,MCD,V,WMT,NKE,T" //Google, Intel, Verizon, Microsoft, Coca-Cola, Disney

stock.RealNameList = {} //because yahoo fucks up stock names

stock.RealNameList["GOOG"] = "Google Inc."
stock.RealNameList["INTC"] = "Intel Corporation"
stock.RealNameList["VZ"] = "Verizon Communications"
stock.RealNameList["MSFT"] = "Microsoft Corporation"
stock.RealNameList["KO"] = "Coca-Cola Company"
stock.RealNameList["DIS"] = "Walt Disney Company"
stock.RealNameList["BA"] = "Boeing Company"
stock.RealNameList["MCD"] = "McDonald's Corporation"
stock.RealNameList["V"] = "Visa Company"
stock.RealNameList["WMT"] = "Wal-Mart Stores Inc."
stock.RealNameList["NKE"] = "Nike Inc."
stock.RealNameList["T"] = "AT&T Inc."

stock.StockPullInterval = 60 //pull stock data and update tables every 60 seconds.
stock.SharesPerStock = 1000 //max number of shares a player can have per stock.

//put this in a shared file: TODO;
local Player = FindMetaTable("Player");

function Player:GetShares(stock) //Note: Usage on clientside MUST require the stock arg.
	/* self.Shares structure: [stockSymbol] = stucksPurchased */
	if (CLIENT) then
		if (!stock) then return 0; end
		
		return self:GetNWInt("Share_"..stock, 0);
	else
		if (!stock) then return self.Shares or {}; end
		
		for k,v in pairs(self.Shares) do
			if (k == stock) then return v; end
		end
	end
end