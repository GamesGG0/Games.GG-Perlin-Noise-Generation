local Actor = script:GetActor()
local Terrain = game.Workspace:WaitForChild("Terrain")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TreesFolder = game.Workspace:WaitForChild("Trees")

local Tree = ReplicatedStorage:WaitForChild("Tree")
local ChunkCompleted = ReplicatedStorage:WaitForChild("ChuckCompleted")

local CollectionService = game:GetService("CollectionService")

Actor:BindToMessageParallel("Trees", function(Message)
	local WorldSize = Message[1]
	local BlockScale = Message[2]
	local TerrainThreshold = Message[3]
	local Seed = Message[4]
	local WaterEnabled = Message[5]
	local NewDataStore = Message[6]
	
	if #NewDataStore.Value[tostring(Seed)]["Trees"] == 0 then --Generates trees
		task.desynchronize()
		for x = 1, WorldSize do
			for z = 1, WorldSize do
				local NoiseTrrain = math.noise(x * 0.1, Seed, z * 0.1) * BlockScale --Prlin Noise, my belovid. Prlin Noise is a math algorithum that tries to create terrain. So far Noise dose this pritty well.
				NoiseTrrain = math.clamp(NoiseTrrain, -6, 6) --Clamps it
				NoiseTrrain = (NoiseTrrain > TerrainThreshold and TerrainThreshold or NoiseTrrain) / TerrainThreshold  --A bunch of math and logic to make the trrain look natral
				NoiseTrrain = (1 - NoiseTrrain)

				local Vector3Position = Vector3.new(x * BlockScale, NoiseTrrain * BlockScale, z * BlockScale) --Creates positions
				local Position = CFrame.new(Vector3Position) 

				local TreeGen = math.noise(x * 0.6, Seed, z * 0.6) * BlockScale
				if Vector3Position.Y > 0.5 and Vector3Position.Y <= 17 and TreeGen > 1 then
					table.insert(NewDataStore.Value[tostring(Seed)]["Trees"], {Vector3Position.X, Vector3Position.Y, Vector3Position.Z})
				end
			end
		end
	end
	
	task.synchronize()
	for _, Pos in ipairs(NewDataStore.Value[tostring(Seed)]["Trees"]) do --Spawns trees
		local NewTree = Tree:Clone()
		NewTree:PivotTo(CFrame.new(Vector3.new(Pos[1], Pos[2], Pos[3])))
		
		for _, v in NewTree:GetChildren() do
			CollectionService:AddTag(v, "Tree")
		end
		
		NewTree.Parent = workspace.Trees
	end

	ChunkCompleted:Fire(NewDataStore.Value[tostring(Seed)]["Trees"])
	Actor:Destroy()
end)

Actor:BindToMessageParallel("Generation", function(Message)
	task.desynchronize()
	local SpawnPoint = nil
	
	local AllTerrain = {}

	local Start = Message[1]
	local End = Message[2]
	local BlockScale = Message[3]
	local TerrainThreshold = Message[4]
	local WaterEnabled = Message[5]
	local WorldSize = Message[6]
	local Seed = Message[7]
	local NewDataStore = Message[8]
	
	local WorldCenter = math.floor(WorldSize / 2)
	
	for z = Start, End do  --Generation
		for x = 1, WorldSize do
			local NoiseTrrain = math.noise(x * 0.1, Seed, z * 0.1) * BlockScale --Prlin Noise, my belovid. Prlin Noise is a math algorithum that tries to create realistic terrain. So far Noise dose this pritty well.
			NoiseTrrain = math.clamp(NoiseTrrain, -6, 6) --Clamps it
			NoiseTrrain = (NoiseTrrain > TerrainThreshold and TerrainThreshold or NoiseTrrain) / TerrainThreshold  --A bunch of math and logic to make the trrain look natral
			NoiseTrrain = (1 - NoiseTrrain)

			local Vector3Position = Vector3.new(x * BlockScale, NoiseTrrain * BlockScale, z * BlockScale) --Creates positions
			local Position = CFrame.new(Vector3Position) 
			
			if WorldCenter == x and WorldCenter == z then
				SpawnPoint = Vector3Position
			end
			
			local Size = Vector3.new(BlockScale, BlockScale, BlockScale) --Creates the size
			local Material

			if Vector3Position.Y >= 17 then --When Rock will generate
				Material = Enum.Material.Rock
				table.insert(AllTerrain, {Position - Vector3.new(0, BlockScale * 5, 0), Vector3.new(BlockScale, (BlockScale * 12) - NoiseTrrain, BlockScale), Enum.Material.Ground})
				
			elseif Vector3Position.Y <= 0.5 and WaterEnabled then --When water will generate
				Material = Enum.Material.Water
				table.insert(AllTerrain, {Position - Vector3.new(0, BlockScale * 5, 0), Size, Enum.Material.Rock})
				table.insert(AllTerrain, {Position - Vector3.new(0, BlockScale * 7, 0), Vector3.new(BlockScale, (BlockScale * 12) - NoiseTrrain, BlockScale), Enum.Material.Ground})
				
			else --When grass will generate
				Material = Enum.Material.Grass
				table.insert(AllTerrain, {Position - Vector3.new(0, BlockScale * 5, 0), Vector3.new(BlockScale, (BlockScale * 12) - NoiseTrrain, BlockScale), Enum.Material.Ground})

			end
			
			table.insert(AllTerrain, {Position, Size, Material})
		end
	end
	
	task.synchronize()
	
	for _, v in AllTerrain do --Places the terrain
		Terrain:FillBlock(v[1], v[2], v[3])
	end
	
	if SpawnPoint then --Sets the spawn location
		game.Workspace.SpawnLocation.CFrame = CFrame.new(SpawnPoint + Vector3.new(0, 20, 0))
	end
	
	ChunkCompleted:Fire(nil)
	Actor:Destroy()
end)

