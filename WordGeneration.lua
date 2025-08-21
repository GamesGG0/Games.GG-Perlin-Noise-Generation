local Terrain = game.workspace:WaitForChild("Terrain")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local SpawnPointPart = game.Workspace:WaitForChild("SpawnLocation")

local Player = game:GetService("Players")


local WorldLoadedFunction = ReplicatedStorage:WaitForChild("WorldLoaded")
local LoadWorldFunction = ReplicatedStorage:WaitForChild("LoadWorld")
local BuildFunction = ReplicatedStorage:WaitForChild("Build")
local AxeFunction = ReplicatedStorage:WaitForChild("Axe")

local DataStore = require(script:WaitForChild("DataStore"))

local Actor = game.ServerScriptService:WaitForChild("Actor")

local BlockScale = 4

local ChunkCompleted = ReplicatedStorage:WaitForChild("ChuckCompleted")

------------------------------------------
local BlockSize = Vector3.new(4,4,4)

function RemoveTree(TreePiv, Seed, NewDataStore)
	print(NewDataStore.Value[tostring(Seed)]["Trees"])
	print(Seed)
	for i, Tree in ipairs(NewDataStore.Value[tostring(Seed)]["Trees"]) do
		if Tree[1] == TreePiv.X and Tree[2] == TreePiv.Y and Tree[3] == TreePiv.Z then
			table.remove(NewDataStore.Value[tostring(Seed)]["Trees"], i)		
		end
	end
end

function LoadWorld(Player : Player, WaterEnabled : boolean, Seed : number, TrrainThreshhold : number, WorldSize : number)
	if typeof(WaterEnabled) ~= "boolean" then return end
	
	if not tonumber(Seed) or Seed == "" then --Checks if the inputed seed is valid
		Seed = math.random(1, 10000)

	end
	
	local NewDataStore = DataStore.new(Player.UserId, true, 30)
	NewDataStore:Open() --Loads the data
	print(NewDataStore)
	Players.PlayerRemoving:Connect(function(LeavingPlayer)
		if LeavingPlayer ~= Player then return end
		NewDataStore:Close()
		print("Close")
	end)
	

	Seed = math.abs(tonumber(Seed)) --Makes sure the seed is not a negitive value
	
	if not tonumber(TrrainThreshhold) or string.find(TrrainThreshhold, " ") or TrrainThreshhold == "" then
		TrrainThreshhold = 0.35	-- I am not going to rename this, don't feel like it.
	end
	
	TrrainThreshhold = tonumber(TrrainThreshhold)
	
	if not tonumber(WorldSize) or string.find(WorldSize, " ") or WorldSize == "" then
		WorldSize = 100
	end
	
	WorldSize = math.abs(WorldSize)
	
	local ChunksFinished = 0
	
	local Chunks = 11
	local ChunkSize = WorldSize / Chunks
	
	local GenTimeout
	ChunkCompleted.Event:Connect(function(Trees) --Because the function LoadWord function is called once, i don't need to do any memory managment wombo jumbo.
		if not GenTimeout then
			GenTimeout = task.delay(15, function()
				Player:Kick("World Generation Timeout")
			end)
		end
	
		ChunksFinished += 1
		
		if Trees then
			NewDataStore.Value[tostring(Seed)]["Trees"] = Trees
		end
		
		if ChunksFinished ~= Chunks + 1 then return end
		task.cancel(GenTimeout)
		GenTimeout = nil
		
		BuildFunction.OnServerEvent:Connect(function(Player : Player, Position : Vector3, Mat : Enum.Material)
			Terrain:FillBlock(Position, BlockSize, Mat)

			if Mat == Enum.Material.Air then
				Mat = 0
			else
				Mat = 1
			end

			table.insert(NewDataStore.Value[tostring(Seed)]["Terrain"], {{Position.X, Position.Y, Position.Z}, Mat}) --Save world change
		end)


		AxeFunction.OnServerEvent:Connect(function(Player : Player, TreeModel : Model, TreeRoot : Part)
			if not TreeModel:IsA("Model") then return end
			if not TreeRoot:IsA("BasePart") then return end
			if not TreeRoot:IsDescendantOf(TreeModel) then return end
			
			task.spawn(function()
				local Pivot = TreeModel:GetPivot().Position
				RemoveTree(Pivot, Seed, NewDataStore) --Finds the tree then removes it from the data store
				TreeRoot:Destroy()
				task.wait(2.5)
				
				for _, v in TreeModel:GetChildren() do
					v:Destroy()
				end
				
				TreeModel:Destroy()
			end)
		end)
		
		
		for _, v in NewDataStore.Value[tostring(Seed)]["Terrain"] do --Load from data store
			local NewPosition = Vector3.new(v[1][1], v[1][2], v[1][3])
			if v[2] == 1 then
				Terrain:FillBlock(CFrame.new(NewPosition), BlockSize, Enum.Material.Ground)

			elseif v[2] == 0 then
				Terrain:FillBlock(CFrame.new(NewPosition), BlockSize, Enum.Material.Air)
 
			end

		end
		WorldLoadedFunction:FireClient(Player, Seed)
	end)
	
	if not NewDataStore.Value[tostring(Seed)] then
		NewDataStore.Value[tostring(Seed)] = {["Terrain"] = {}, ["Trees"] = {}} 
	end
	
	local NewActor = Actor:Clone()
	NewActor.Parent = game.Workspace.Actors

	task.wait(0.1)
	NewActor:SendMessage("Trees", {WorldSize, BlockScale, TrrainThreshhold, Seed, WaterEnabled, NewDataStore})

	
	for ChunkIndex = 1, Chunks do
		local Start = math.round((ChunkIndex - 1) * ChunkSize + 1)
		local End = math.round(ChunkIndex * ChunkSize)
		
		NewActor = Actor:Clone()
		NewActor.Parent = game.Workspace.Actors

		task.wait(0.1)
		NewActor:SendMessage("Generation", {Start, End, BlockScale, TrrainThreshhold, WaterEnabled, WorldSize, Seed, NewDataStore})
	end
end

LoadWorldFunction.OnServerEvent:Connect(LoadWorld)

