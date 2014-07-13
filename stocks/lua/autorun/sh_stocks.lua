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
stock.RealNameList["MCD"] = "McDonalds Corporation"
stock.RealNameList["V"] = "Visa Company"
stock.RealNameList["WMT"] = "Wal-Mart Stores Inc."
stock.RealNameList["NKE"] = "Nike Inc."
stock.RealNameList["T"] = "AT&T Inc."

stock.StockPullInterval = 45 //pull stock data and update tables every 45 seconds.
stock.SharesPerStock = 1500 //max number of shares a player can have per stock.

stock.BracketColor = Color(0, 0, 0, 255)
stock.StockTextColor = Color(255, 25, 25, 255)
stock.MsgColor = Color(255, 255, 255, 255)

stock.Version = "7-12-14"; //dont edit

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