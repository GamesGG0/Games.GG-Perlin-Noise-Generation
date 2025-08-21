type DataStoreObject = { 
	new : (Name : string, AutoSaveTime: number, AutoSavingEnabled : boolean, SessionLockExpiration : number) -> (datastoreobject)
}

local DataStoreService = game:GetService("DataStoreService")

local MemoryStoreService = game:GetService("MemoryStoreService")
local MemoryHashMap = MemoryStoreService:GetHashMap("DataStoreKeys")

local RunService = game:GetService("RunService")

local AllActiveDataStores = {}

local Retries = 10

local function CalculateTimeForRetryTotal(Number) --Calculates time for each retry
	return (2 ^ Retries) * Number
end

function Retry(Function, ...) --Retrying
	local InnerSuccess, InnerData
	for i = 1, Retries do
		InnerSuccess, InnerData = pcall(Function, ...)
		
		if InnerSuccess then
			return InnerSuccess, InnerData
		else
			warn(InnerData)
		end

		task.wait(math.min(2^i, 10))
	end
	return InnerSuccess, InnerData

end

local DataStoreClass = { --The class
	Name = "",
	DataStore = nil,
	AutoSaveTime = 15,
	AutoSavingEnabled = false,

	Opened = false,
	Value = {},
}

local DataStoreModule = {
	new = function(Name : string, AutoSavingEnabled : boolean, AutoSaveTime : number)
		local self = table.clone(DataStoreClass)

		self.Name = Name
		self.DataStore = DataStoreService:GetDataStore(Name)
		self.AutoSaveTime = AutoSaveTime
		self.LastAutoSaveTime = os.time()
		self.AutoSavingEnabled = AutoSavingEnabled

		return self :: DataStoreObject
	end,
}

function DataStoreClass:IsLocked()
	local Success, Data = Retry(MemoryHashMap.GetAsync, MemoryHashMap, self.Name)
	print(Data)
	if Success == false or Data then
		return true
	end

	return false
end

function DataStoreClass:Update()
	if self.Opened then
		local Success, Error = Retry(MemoryHashMap.SetAsync, MemoryHashMap, self.Name, true, self.AutoSaveTime + CalculateTimeForRetryTotal(2))
		if not Success then warn(Error) end
		
		local Success, Error = Retry(self.DataStore.SetAsync, self.DataStore, "Data", self.Value)
		if not Success then warn(Error) end

		return Success, Error
	else
		warn("Open the data store first.")

	end
	return false
end

function DataStoreClass:Read() --Reads from data store
	local Success, Data = Retry(self.DataStore.GetAsync, self.DataStore, "Data")
	return Success, Data
end

function DataStoreClass:Open() --Opends the store for editing
	if not self:IsLocked() and not self.Opened then
		self.Opened = true
		Retry(MemoryHashMap.SetAsync, MemoryHashMap, self.Name, true, self.AutoSaveTime + CalculateTimeForRetryTotal(2))

		local Success, Data = self:Read()
		if Success and Data then
			self.Value = Data
		end

		AllActiveDataStores[self.Name] = self

		return true
	else
		warn("Could not open.")
	end

	return false
end

function DataStoreClass:Close() --Save data and close the store
	if self.Opened then
		self.AutoSavingEnabled = false


		self:Update()
		self.Opened = false
		AllActiveDataStores[self.Name] = nil
		Retry(MemoryHashMap.RemoveAsync, MemoryHashMap, self.Name)
	end
end

local Debounce = 0
RunService.Heartbeat:Connect(function(DeltaTime : number) --Auto save
	Debounce += DeltaTime
	if Debounce < 1 then return end
	Debounce = 0

	for _, v in AllActiveDataStores do
		if v.AutoSavingEnabled and os.time() - v.LastAutoSaveTime >= v.AutoSaveTime then
			v.LastAutoSaveTime = os.time()
			v:Update() 
		end
	end
end)

game:BindToClose(function() --Just in case if the server crashes
	for _, v in AllActiveDataStores do
		v:Close()

	end
end)

return DataStoreModule
