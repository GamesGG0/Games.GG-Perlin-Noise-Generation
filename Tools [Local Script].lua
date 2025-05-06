local Build = require(game:GetService("ReplicatedStorage").Build)
local GetWorldDataFunction = game:GetService("ReplicatedStorage"):WaitForChild("GetWorldData")

local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer
local LocalBackpack = LocalPlayer:WaitForChild("Backpack")

local BuildTool = Instance.new("Tool")
BuildTool.Name = "Build"
BuildTool.Parent = LocalBackpack
BuildTool.ToolTip = "Add trrain to the map."
BuildTool.RequiresHandle = false

local RemoveTool = Instance.new("Tool")
RemoveTool.Name = "Remove"
RemoveTool.Parent = LocalBackpack
RemoveTool.ToolTip = "Remove trrain from the map."
RemoveTool.RequiresHandle = false

local Mouse = LocalPlayer:GetMouse()
local Mouse3DPos

BuildTool.Activated:Connect(function()
	Mouse3DPos = Mouse.Hit
	
	if Mouse.Target then
		Build.Build(Mouse3DPos, 4) --Build tool
		
	end
end)

RemoveTool.Activated:Connect(function()
	Mouse3DPos = Mouse.Hit
	
	if Mouse.Target then
		Build.Remove(Mouse3DPos, 8) --Remove tool
		
	end
end)

function GetYourData()
	return Build.WorldEdits
	
end

GetWorldDataFunction.OnClientInvoke = GetYourData --Once I learned the usfullness of RemoteFunctions I used it.

--Script for build and remove tools