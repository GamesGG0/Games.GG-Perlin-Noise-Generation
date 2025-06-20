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

local BuildFunction = game:GetService("ReplicatedStorage"):WaitForChild("Build")

local function AlignToVoxelGrid(Position) --https://devforum.roblox.com/t/terrain-fillblock-inaccuracy/1830925 Because I found this issue I just added a solution
	return CFrame.new(Vector3.new(
		math.floor(Position.X / 4 + 0.5) * 4,
		math.floor(Position.Y / 4 + 0.5) * 4,
		math.floor(Position.Z / 4 + 0.5) * 4

		))
	
end


BuildTool.Activated:Connect(function() --Build
	Mouse3DPos = Mouse.Hit
	
	if Mouse.Target then
		local Position = AlignToVoxelGrid(Mouse3DPos)
		BuildFunction:FireServer(Position, Enum.Material.Ground)
		
	end
end)

RemoveTool.Activated:Connect(function() --Remove
	Mouse3DPos = Mouse.Hit
	
	if Mouse.Target then
		local Position = AlignToVoxelGrid(Mouse3DPos)
		BuildFunction:FireServer(Position, Enum.Material.Air)
		
	end
end)
