local BuyItemEvent = game:GetService("ReplicatedStorage"):WaitForChild("BuyItem")
local MarketService = game:GetService("MarketplaceService")

local Players = game:GetService("Players")

BuyItemEvent.OnServerEvent:Connect(function(Player, Item) --Prompts the purchase
	if Item == "Donate10R" then
		MarketService:PromptProductPurchase(Player, 3364812479)
	elseif Item == "Donate100R" then
		MarketService:PromptProductPurchase(Player, 3364812697)
	end
end)

MarketService.PromptProductPurchaseFinished:Connect(function(PlayerId, ProductId, WasPurchased)
	local Player = Players:GetPlayerByUserId(PlayerId)
	if WasPurchased then 
		BuyItemEvent:FireClient(Player, "Success!", "Thank you for donating!!!!")
	else
		BuyItemEvent:FireClient(Player, "Failed...", "Idk what happend...")
	end
end)
