--All GUI buttons are controlled here

local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")
local GameGUI = script.Parent.Parent.Parent
local SeedUI = LocalPlayer.PlayerGui:WaitForChild("GameGUI")

GameGUI.Parent = LocalPlayer.PlayerGui
GameGUI.Parent = LocalPlayer.PlayerGui

local LoadWorld = script.Parent
local WaterToggle = script.Parent.Parent["Water Toggle"]
local Seed = script.Parent.Parent.Seed
local GenFlat = script.Parent.Parent["Generation Flatness"]
local WorldSize = script.Parent.Parent["World Size"]
local GUI = script.Parent.Parent.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldLoad = ReplicatedStorage:WaitForChild("WorldLoad")

local WaterEnabled = true


local SpawnPoint = game.Workspace:WaitForChild("SpawnLocation")


HRP.Anchored = true --Player Can't move until world is generated

WaterToggle.MouseButton1Down:Connect(function()
	WaterEnabled = not WaterEnabled

	if WaterEnabled then
		WaterToggle.BackgroundColor3 = Color3.new(0, 1, 0)

	else
		WaterToggle.BackgroundColor3 = Color3.new(1, 0, 0)

	end
end)

LoadWorld.MouseButton1Down:Connect(function()
	GUI.Enabled = false

	local AccualSeed = WorldLoad:InvokeServer(WaterEnabled, Seed.Text, GenFlat.Text, WorldSize.Text)

	print("Whyyyyyyyyy")
	if AccualSeed then
		SeedUI.Seed.Text = "Seed: " .. AccualSeed
		HRP.CFrame = SpawnPoint.CFrame
		HRP.Anchored = false
		
	end
	
	
end)
