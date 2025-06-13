local DataStoreModule = {
	DataStore = nil,
		
	Retrys = 10,

	AutoSaveTime = 15,
	SessionLockExpiration = 17,

	AutoSavingEnabled = false,
		
	SessionTime = 0,
	SessionId = 0,
		
	AutoSaveTask = nil,
		
	AllPlayerData = nil
	
}

local DataStoreService = game:GetService("DataStoreService")
local JobId = game.JobId

local RunService = game:GetService("RunService")

local AllActiveDataStores = {}


RunService.Heartbeat:Connect(function(DeltaTime)
	for _, Self in ipairs(AllActiveDataStores) do
		Self.Debounce += DeltaTime
		if Self.Debounce >= 1 then
			Self.Debounce = 0
			
			if Self.AutoSavingEnabled and not Self.DelayTask then
				print("AutoSaveTimer")
				Self.DelayTask = task.delay(Self.AutoSaveTime, function()
					Self.DelayTask = nil
					
					for i = 1, Self.Retrys do
						local Success, Error = pcall(function()
							if os.time() - Self.SessionTime > Self.SessionLockExpiration  then
								Self.SessionId = nil

							end

							if Self.SessionId == nil or Self.SessionId == JobId then
								Self.SessionTime = os.time()
								Self.SessionId = JobId

								local Success, Error = Self.DataStore:UpdateAsync("Data", function()
									Self.SessionTime = os.time()
									print(Self.AllPlayerData)
									return Self.AllPlayerData

								end)
								return Success, Error

							else
								return false, "Session Lock"

							end


						end)

						if Success then break end

					end
				end)
			end
			
		end
	end
end)

function DataStoreModule.new(DataStoreName, Retrys, AutoSaveTime, SessionLockExpiration, AutoSavingEnabled)
	local Self = table.clone(DataStoreModule)
	
	if type(DataStoreName) == "string" then
		Self.DataStore = DataStoreService:GetDataStore(DataStoreName)
		Self.Retrys = Retrys or 5
		Self.AutoSaveTime = AutoSaveTime or 15
		Self.SessionLockExpiration = SessionLockExpiration or 17
		Self.AutoSavingEnabled = AutoSavingEnabled or false
		Self.JobId = game.JobId
		Self.SessionId = nil
		Self.AllPlayerData = {}
		Self.Debounce = 0
		Self.DelayTask = nil
		
		table.insert(AllActiveDataStores, Self)
		return Self
			
	else
		return nil
		
	end
end


function DataStoreModule:Open()
	local StartTime = os.time()
	self.AllPlayerData = {}
	for i = 1, self.Retrys do
		local Success, Data = pcall(function()
			return self.DataStore:GetAsync("Data")
			
		end)
		 
		print(Data)
		if Success then
			self.AllPlayerData = Data or {}
			self.SessionId = JobId
			break
			
		end
	end
end

function DataStoreModule:Close()
	table.remove(AllActiveDataStores, table.find(AllActiveDataStores, self))
	
	task.cancel(self.AutoSaveTask)
	self.AutoSaveTask = nil

	for i = 1, self.Retrys do
		local Success, Error = pcall(function()
			if os.time() - self.SessionTime > self.SessionLockExpiration  then
				self.SessionId = nil

			end

			if self.SessionId == nil or self.SessionId == JobId then
				self.SessionTime = os.time()
				self.SessionId = JobId

				local Success, Error = self.DataStore:UpdateAsync("Data", function()
					self.SessionTime = os.time()
					return self.AllPlayerData
					
				end)
				return Success, Error

			else
				return false, "Session Lock"

			end


		end)

		if Success then break end
		
	end
	self.SessionId = nil
	table.freeze(self.AllPlayerData)
	
end

return DataStoreModule
