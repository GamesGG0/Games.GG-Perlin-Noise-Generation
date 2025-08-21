--All GUI buttons are controlled here

local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid : Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")
local GameGUI = script.Parent.Parent.Parent
local SeedUI = LocalPlayer.PlayerGui:WaitForChild("GameGUI")

GameGUI.Parent = LocalPlayer.PlayerGui
GameGUI.Parent = LocalPlayer.PlayerGui

local LoadWorld = script.Parent
local WaterToggle = script.Parent.Parent["Water Toggle"]
local SeedInput = script.Parent.Parent.Seed
local GenFlat = script.Parent.Parent["Generation Flatness"]
local WorldSize = script.Parent.Parent["World Size"]
local GUI = script.Parent.Parent.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoadWorldFunction = ReplicatedStorage:WaitForChild("LoadWorld")
local WorldLoadedFunction = ReplicatedStorage:WaitForChild("WorldLoaded")

local WaterEnabled = true

local SpawnPoint = game.Workspace:WaitForChild("SpawnLocation")
local TweenService = game:GetService("TweenService")

HRP.Anchored = true --Player Can't move until world is generated

local Seed = 0 
WaterToggle.MouseButton1Down:Connect(function()
	WaterEnabled = not WaterEnabled

	if WaterEnabled then
		WaterToggle.BackgroundColor3 = Color3.new(0, 1, 0)

	else
		WaterToggle.BackgroundColor3 = Color3.new(1, 0, 0)

	end
end)

local UITweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
LoadWorld.MouseButton1Down:Connect(function()
	TweenService:Create(script.Parent.Parent, UITweenInfo, {Position = UDim2.new(0.5, 0, 2, 0)}):Play()
	
	task.wait(0.7)

	GUI.Enabled = false
	LoadWorldFunction:FireServer(WaterEnabled, SeedInput.Text, GenFlat.Text, WorldSize.Text)
end)

WorldLoadedFunction.OnClientEvent:Connect(function(NewSeed) 
	SeedUI.Seed.Text = "Seed: " .. NewSeed
	HRP.Anchored = false
	HRP.CFrame = SpawnPoint.CFrame
	NewSeed = Seed
end)
