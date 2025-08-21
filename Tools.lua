local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer
local LocalBackpack = LocalPlayer:WaitForChild("Backpack")
local CollectionService = game:GetService("CollectionService")

local BuildTool = Instance.new("Tool")
BuildTool.Name = "Build"
BuildTool.Parent = LocalBackpack
BuildTool.ToolTip = "Add trrain to the map."
BuildTool.RequiresHandle = false
BuildTool.CanBeDropped = false

local RemoveTool = Instance.new("Tool")
RemoveTool.Name = "Remove"
RemoveTool.Parent = LocalBackpack
RemoveTool.ToolTip = "Remove trrain from the map."
RemoveTool.RequiresHandle = false
RemoveTool.CanBeDropped = false

local AxeTool = Instance.new("Tool")
AxeTool.Name = "Axe"
AxeTool.Parent = LocalBackpack
AxeTool.ToolTip = "Remove trees from the map."
AxeTool.CanBeDropped = false

local NewAxeModel = game:GetService("ReplicatedStorage"):WaitForChild("AxeModel"):Clone()
NewAxeModel.Name = "Handle"
NewAxeModel.Parent = AxeTool

AxeTool.RequiresHandle = true
AxeTool.Grip = CFrame.new(Vector3.new(0, -1, 0))

local Mouse = LocalPlayer:GetMouse()
local LocalChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP : Part = LocalChar:WaitForChild("HumanoidRootPart")

local Mouse3DPos

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuildFunction = ReplicatedStorage:WaitForChild("Build")
local AxeFunction = ReplicatedStorage:WaitForChild("Axe")

local Hitbox = Instance.new("Part")
Hitbox.CanCollide = false
Hitbox.Anchored = true
Hitbox.Size = Vector3.new(5, 3, 3)
Hitbox.Parent = game.Workspace
Hitbox.Transparency = 1
Hitbox.Color = Color3.new(1, 0, 0)

local function AlignToVoxelGrid(Position) --https://devforum.roblox.com/t/terrain-fillblock-inaccuracy/1830925 Because I found this issue I just added a solution
	return CFrame.new(Vector3.new(
		math.floor(Position.X / 4 + 0.5) * 4,
		math.floor(Position.Y / 4 + 0.5) * 4,
		math.floor(Position.Z / 4 + 0.5) * 4

		))
	
end

local NewOverlapParams = OverlapParams.new()
NewOverlapParams.FilterType = Enum.RaycastFilterType.Include

local AxeCooldown = 0
AxeTool.Activated:Connect(function()
	if os.clock() <= AxeCooldown + 0.2 then return end --Axe cooldown
	AxeCooldown = os.clock()
	
	NewOverlapParams.FilterDescendantsInstances = {workspace.Trees:GetChildren()}
	local Data = workspace:GetPartsInPart(Hitbox, NewOverlapParams)
	
	Hitbox.CFrame = CFrame.new(HRP.Position + HRP.CFrame.LookVector * 2, HRP.Position + HRP.CFrame.LookVector)
	Hitbox.Color = Color3.new(1, 0, 0)
	Hitbox.Transparency = 0.7
	
	task.spawn(function() --Rotates the handle
		AxeTool.Grip = CFrame.new(Vector3.new(0, -1, 0)) * CFrame.Angles(math.rad(90), 0, 0)
		task.wait(0.2)
		AxeTool.Grip = CFrame.new(Vector3.new(0, -1, 0)) * CFrame.Angles(0, 0, 0)
	end)
	

	if #Data >= 1 then
		for _, Part in Data do
			if CollectionService:HasTag(Part, "Tree") then
				if not Part.Parent:FindFirstChild("TreeRoot") then return end
				
				Hitbox.Color = Color3.new(0, 1, 0)
				AxeFunction:FireServer(Part.Parent, Part.Parent.TreeRoot)
				break
			end
		end
	else
		Hitbox.Color = Color3.new(1, 0, 0)
	end
	task.wait(0.1)

	Hitbox.Transparency = 1
end)

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


