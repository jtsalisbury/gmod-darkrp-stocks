hook.Add("Initialize", "CheckStockVersion", function()
	local url = "https://github.com/crazyscouter/DarkRP-Stocks/tree/master/stocks/version.txt";

	http.Fetch( url,
		function( body, len, headers, code )
			if (body == stock.Version) then return; end
			
			print("------------STOCK------------");
			print("Your local version is OUT OF DATE! Download a new version here: ");
			print("https://github.com/crazyscouter/DarkRP-Stocks");
			print("---------STOCK END----------");
		end,
		function( error )
			print(error)
		end
	);
end)