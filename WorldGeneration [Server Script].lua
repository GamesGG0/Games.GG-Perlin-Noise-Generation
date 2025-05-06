local Terrain = workspace.Terrain

local SpawnPointPart = game.Workspace:WaitForChild("SpawnLocation")

local Player = game:GetService("Players")

local LoadWorldEvent = game:GetService("ReplicatedStorage"):WaitForChild("Load World")
local WorldLoadedEvent = game:GetService("ReplicatedStorage"):WaitForChild("World Loaded")
local GetWorldDataFunction = game:GetService("ReplicatedStorage"):WaitForChild("GetWorldData")
local HttpService = game:GetService("HttpService")

local DataStore = game:GetService("DataStoreService")
local WorldData = DataStore:GetDataStore("World Data")

local BlockScale = 4

local SpawnPoint

local SeedGlobal

LoadWorldEvent.OnServerEvent:Connect(function(Player, WaterEnabled, Seed, TrrainThreshhold, WorldSize)
	if not tonumber(Seed) or string.find(Seed, " ") or Seed == "" then --Checks if the inputed seed is valid
		Seed = math.random(1, 10000)
		
	end
	Seed = math.abs(Seed) --Makes sure the seed is not a negitive value
	SeedGlobal = Seed
	
	if not tonumber(TrrainThreshhold) or string.find(TrrainThreshhold, " ") or TrrainThreshhold == "" then
		TrrainThreshhold = 0.35	-- I am not going to rename this, don't feel like it.
		
	end
	TrrainThreshhold = tonumber(TrrainThreshhold)
	
	if not tonumber(WorldSize) or string.find(WorldSize, " ") or WorldSize == "" then
		WorldSize = 100
		
	end
	WorldSize = math.abs(WorldSize)
	
	
	for z = 1, WorldSize do  --Generation
		for x = 1, WorldSize do


			local NoiseTrrain = math.noise(x * 0.1, Seed, z * 0.1) * BlockScale --Prlin Noise, my belovid. Prlin Noise is a math algorithum that tries to create realistic terrain. So far Noise dose this pritty well.
			NoiseTrrain = math.clamp(NoiseTrrain, -6, 6) --Clamps it
			NoiseTrrain = (NoiseTrrain > TrrainThreshhold and TrrainThreshhold or NoiseTrrain) / TrrainThreshhold  --A bunch of math and logic to make the trrain look natral
			NoiseTrrain = (1 - NoiseTrrain)
			
			local Vector3Position = Vector3.new(x * BlockScale, NoiseTrrain * BlockScale, z * BlockScale) --Creates positions
			local Position = CFrame.new(Vector3Position) 
			
			local Size = Vector3.new(BlockScale, BlockScale, BlockScale) --Creates the size
			local Material

			if Position.Y >= 17 then --When Rock will generate
				Material = Enum.Material.Rock
				Terrain:FillBlock(Position - Vector3.new(0, BlockScale * 5, 0), Vector3.new(BlockScale, (BlockScale * 12) - NoiseTrrain, BlockScale), Enum.Material.Ground) --Fills the ground

			elseif Position.Y <= 0.5 and WaterEnabled then --When water will generate
				Material = Enum.Material.Water
				Terrain:FillBlock(Position - Vector3.new(0, BlockScale * 5, 0), Size, Enum.Material.Rock) --Adds rock to the bottom of the water
				Terrain:FillBlock(Position - Vector3.new(0, BlockScale * 7, 0), Vector3.new(BlockScale, (BlockScale * 12) - NoiseTrrain, BlockScale), Enum.Material.Ground) --Fills the ground

			else
				Material = Enum.Material.Grass
				Terrain:FillBlock(Position - Vector3.new(0, BlockScale * 5, 0), Vector3.new(BlockScale, (BlockScale * 12) - NoiseTrrain, BlockScale), Enum.Material.Ground) --Fills the ground

			end

			Terrain:FillBlock(Position, Size, Material) --Generate it
			
			
			if x == 50 and z == 50 then
				SpawnPoint = Vector3Position + Vector3.new(0, 30, 0) --Spawns player at the center of the map
				SpawnPointPart.CFrame = CFrame.new(SpawnPoint)
				
			end
		end
	end
	
	local Success, Data = pcall(function()
		return WorldData:GetAsync(Player.UserId)

	end)
	
	if Success and Data[tostring(Seed)] then --Load save system
		Data[tostring(Seed)] = HttpService:JSONDecode(Data[tostring(Seed)])
		
		print(Data)
		for _, v in pairs(Data[tostring(Seed)]) do
			local NewPosition = Vector3.new(v[1][1], v[1][2], v[1][3])
			local NewSize = Vector3.new(v[2], v[2], v[2])
			
			if v[3] == 0 then
				Terrain:FillBlock(CFrame.new(NewPosition), NewSize, Enum.Material.Ground)
				print("Ground")
				
			else
				Terrain:FillBlock(CFrame.new(NewPosition), NewSize, Enum.Material.Air)
				print("air")
				
			end

		end
	end
	
	task.wait(0.5)
	
	WorldLoadedEvent:FireClient(Player, Seed, CFrame.new(SpawnPoint)) --Spawns player in map
	
	while task.wait(15) do --Saving loop
		local NewWorldData = HttpService:JSONEncode(GetWorldDataFunction:InvokeClient(Player))
		local Success, Error = pcall(function()
			WorldData:UpdateAsync(Player.UserId, function(OldData)
				OldData = OldData or {}
				OldData[SeedGlobal] = NewWorldData
				return OldData

			end)
		end)
		
		if Success then
			print("Saved!!!")
			
		else
			warn(Error)
			
		end
	end
end)
