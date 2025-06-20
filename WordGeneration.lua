local Terrain = workspace.Terrain

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local SpawnPointPart = game.Workspace:WaitForChild("SpawnLocation")

local Player = game:GetService("Players")


local WorldLoad = ReplicatedStorage:WaitForChild("WorldLoad")
local BuildFunction = ReplicatedStorage:WaitForChild("Build")

local DataStore = require(script:WaitForChild("DataStore"))
local DistanceComparison = require(script:WaitForChild("DistanceComparison"))

local TreeModel = ReplicatedStorage.Tree


local BlockScale = 4

local SpawnPoint

local SeedGlobal

------------------------------------------


local BlockSize = Vector3.new(4,4,4)
function LoadWorld(Player : Player, WaterEnabled : boolean, Seed : number, TrrainThreshhold : number, WorldSize : number)
	if not tonumber(Seed) or Seed == "" then --Checks if the inputed seed is valid
		Seed = math.random(1, 10000)
		
	end
	Seed = math.abs(tonumber(Seed)) --Makes sure the seed is not a negitive value
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
	
	local NewDataStore = DataStore.new("AllWorlds4", 15, true, 14)
	
	NewDataStore:Open() --Loads the data
	print(NewDataStore)
	Players.PlayerRemoving:Connect(function(LeavingPlayer)
		if LeavingPlayer == Player then
			NewDataStore:Close()
			
		end
	end)
	
	--Errorless code (This is so scuffed)
	if not NewDataStore.Value then 
		NewDataStore.Value = {}
	end

	if not NewDataStore.Value["Data"] then
		NewDataStore.Value["Data"] = {}
	end

	if not NewDataStore.Value["Data"] then
		NewDataStore.Value["Data"] = {} 
	end

	if not NewDataStore.Value["Data"][tostring(Player.UserId)] then
		NewDataStore.Value["Data"][tostring(Player.UserId)] = {} 
	end

	if not NewDataStore.Value["Data"][tostring(Player.UserId)][tostring(SeedGlobal)] then
		NewDataStore.Value["Data"][tostring(Player.UserId)][tostring(SeedGlobal)] = {} 
	end
	--Errorless code
	
	for _, v in pairs(NewDataStore.Value["Data"][tostring(Player.UserId)][tostring(SeedGlobal)]) do --Load from data store
		local NewPosition = Vector3.new(v[1][1], v[1][2], v[1][3])
		if v[2] == 1 then
			Terrain:FillBlock(CFrame.new(NewPosition), BlockSize, Enum.Material.Ground)
			print("Ground")
						
		else
			Terrain:FillBlock(CFrame.new(NewPosition), BlockSize, Enum.Material.Air)
			print("air") 
						
		end
	end

	
	BuildFunction.OnServerEvent:Connect(function(Player : Player, Position : Vector3, Mat : Enum.Material)
		Terrain:FillBlock(Position, BlockSize, Mat)
		if Mat == Enum.Material.Air then
			Mat = 0
		else
			Mat = 1
		end
		
		table.insert(NewDataStore.Value["Data"][tostring(Player.UserId)][tostring(SeedGlobal)], {{Position.X, Position.Y, Position.Z}, Mat}) --Save world change
		print(NewDataStore.Value)
	end)
	
	return Seed
end

WorldLoad.OnServerInvoke = LoadWorld
