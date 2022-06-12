--!strict
local GoodSignal = require(game.ReplicatedStorage.Shared.GoodSignal)

local State = {}
State.__index = State

function State.new(name: string)
	local newState = setmetatable({}, State)
	newState._name = name
	
	newState.OnBeginState = GoodSignal.new()
	newState.OnEndState = GoodSignal.new()
	
	return newState
end

function State:Activate()
	self.OnBeginState:Fire()
end

function State:Deactivate()
	self.OnEndState:Fire()
end

function State:Destroy()
	self.OnBeginState:Destroy()
	self.OnEndState:Destroy()
	table.clear(self)
	self = nil
end

return State
