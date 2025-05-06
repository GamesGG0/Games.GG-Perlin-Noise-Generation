local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")
local GameGUI = LocalPlayer.PlayerGui:WaitForChild("GameGUI")
local MenuGUI = LocalPlayer.PlayerGui:WaitForChild("MainMenu")

local LoadWorldEvent = game:GetService("ReplicatedStorage"):WaitForChild("Load World")
local WorldLoadedEvent = game:GetService("ReplicatedStorage"):WaitForChild("World Loaded")

local SpawnPoint = game.Workspace:WaitForChild("SpawnLocation")

WorldLoadedEvent.OnClientEvent:Connect(function(Seed, SpawnPoint)
	SpawnPoint = SpawnPoint
	GameGUI.Seed.Text = "Seed: " .. Seed
	HRP.CFrame = SpawnPoint
	HRP.Anchored = false

	while task.wait() do
		pcall(function()
			MenuGUI = LocalPlayer.PlayerGui.MainMenu
			
		end)
		
		if MenuGUI then
			MenuGUI:Destroy()
			
		end
	end
end)

HRP.Anchored = true --Player Can't move until world is generated

