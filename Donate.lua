local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Icon = require(ReplicatedStorage:WaitForChild("Icon"))
local BuyItemEvent = ReplicatedStorage:WaitForChild("BuyItem")

local StarterGui = game:GetService("StarterGui")

script.Parent:WaitForChild("Donate10").MouseButton1Down:Connect(function()
	BuyItemEvent:FireServer("Donate10R")
end)

script.Parent:WaitForChild("Donate100").MouseButton1Down:Connect(function()
	BuyItemEvent:FireServer("Donate100R")
end)

BuyItemEvent.OnClientEvent:Connect(function(Title, Des)
	StarterGui:SetCore("SendNotification", {
		Title = Title,
		Text = Des,
		Duration = 2 
	})
end)
