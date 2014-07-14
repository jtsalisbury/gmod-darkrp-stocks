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