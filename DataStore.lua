type DataStoreObject = { 
	new : (Name : string, AutoSaveTime: number, AutoSavingEnabled : boolean, SessionLockExpiration : number) -> (datastoreobject)

}


local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local Retries = 5

local AllActiveDataStores = {}
function Retry(Function, ...)
	local InnerSuccess, InnerData
	for i = 1, Retries do
		InnerSuccess, InnerData = pcall(Function, ...)

		if InnerSuccess then
			return InnerSuccess, InnerData
		end

		task.wait(math.min(2^i), 10)
	end
	return InnerSuccess, InnerData

end


local DataStoreClass = {
	DataStore = nil,
	Value = {},

	AutoSaveTime = 15,
	SessionLockExpiration = 17,

	AutoSavingEnabled = false,

	SessionTime = 0,
	SessionId = 0,

	Update = function(self : DataStoreObject) --Save data
		local Success, Error = pcall(function()
			if os.time() - self.SessionTime > self.SessionLockExpiration then --Session Lock Expiration
				self.SessionId = game.JobId

			end

			if self.SessionId == game.JobId then --Session Lock
				self.SessionTime = os.time()

				local Success, Error = Retry(self.DataStore.SetAsync, self.DataStore, "Data", self.Value)
				return Success, Error

			else
				return false, "Session Lock"

			end
		end)
		return Success, Error

	end,

	Read = function(self : DataStoreObject) --Read from data store
		local Success, Data = Retry(self.DataStore.GetAsync, self.DataStore, "Data")
		return Success, Data

	end,

	Open = function(self : DataStoreObject)
		if self.SessionId == nil then
			self.SessionId = game.JobId
			
		end

		local OuterSuccess, OuterData = self:Read(self)
		if OuterSuccess then
			self.Value = OuterData

		else
			self.Value = {}

		end
	end,

	Close = function(self : DataStoreObject) --Closes the data store
		self.SessionId = nil
		self:Update(self)
		table.remove(AllActiveDataStores, table.find(AllActiveDataStores, self))
		table.freeze(self)

		return true
	end,
}

local DataStoreModule = {
	new = function(Name : string, AutoSaveTime : number, AutoSavingEnabled : boolean, SessionLockExpiration : number)
		local self = table.clone(DataStoreClass)

		self.DataStore = DataStoreService:GetDataStore(Name)
		self.AutoSaveTime = AutoSaveTime
		self.AutoSavingEnabled = AutoSavingEnabled
		self.SessionLockExpiration = SessionLockExpiration

		table.insert(AllActiveDataStores, self)
		return self :: DataStoreObject
	end,
}

local Debounce = 0
RunService.Heartbeat:Connect(function(DeltaTime : number) --Auto save
	Debounce += DeltaTime
	if Debounce < 1 then return end
	Debounce = 0

	for _, self in AllActiveDataStores do 
		if os.time() - self.SessionTime >= self.AutoSaveTime then
			self:Update() 

		end
	end
end)

game:BindToClose(function() --Just in case if the server crashes
	for _, v in AllActiveDataStores do
		v:Close()

	end
end)

return DataStoreModule
