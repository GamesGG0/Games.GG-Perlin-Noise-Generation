local BuildModual = {}
	
local function AlignToVoxelGrid(Position) --https://devforum.roblox.com/t/terrain-fillblock-inaccuracy/1830925 Because I found this issue I just added a solution
		return CFrame.new(Vector3.new(
			math.floor(Position.X / 4 + 0.5) * 4,
			math.floor(Position.Y / 4 + 0.5) * 4,
			math.floor(Position.Z / 4 + 0.5) * 4
			
		))
	end

	BuildModual.WorldEdits = {}
	
	local Trrain = game.Workspace:WaitForChild("Terrain")
	
	function BuildModual.Build(Position, Size)
		Position = AlignToVoxelGrid(Position)
		Trrain:FillBlock(Position, Vector3.new(Size, Size, Size), Enum.Material.Ground)
		
		Position = {Position.X, Position.Y, Position.Z}
		table.insert(BuildModual.WorldEdits, {Position, Size, 0}) --Add trrain to save
		
	end
	
	function BuildModual.Remove(Position, Size)
		Position = AlignToVoxelGrid(Position)
		Trrain:FillBlock(Position, Vector3.new(Size, Size, Size), Enum.Material.Air)
	
		Position = {Position.X, Position.Y, Position.Z}
		table.insert(BuildModual.WorldEdits, {Position, Size, 1}) --Removes trrain to save
		
	end

return BuildModual