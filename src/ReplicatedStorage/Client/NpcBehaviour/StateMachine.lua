--!strict
local State = require(script.Parent.State)

local StateMachine = {}

function StateMachine:Create(args: {[number]: string})
	local stateTree = {}
	stateTree.current = nil
	stateTree.previous = nil
	
	stateTree.States = {}
	
	for index, stateName in ipairs(args) do
		stateTree.States[stateName] = State.new(stateName)
	end
	return stateTree
end

function _findState(stateTree, stateName: string) : any
	for key, state in pairs(stateTree.States) do
		if state._name == stateName then
			return state
		end
	end
	return
end


function StateMachine:SetState(stateTree, stateName: string)
	local foundState = _findState(stateTree, stateName)
	assert(foundState, "State: "..stateName.." is not valid")
	
	stateTree.previous = stateTree.current
	stateTree.current = foundState
	
	if stateTree.previous then
		stateTree.previous:Deactivate()
	end
	stateTree.current:Activate()
end

return StateMachine
