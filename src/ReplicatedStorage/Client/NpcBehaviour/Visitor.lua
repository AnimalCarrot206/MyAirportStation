local Visitor = {}

local StateMachine = require(game.ReplicatedStorage.Client.NpcBehaviour.StateMachine)

function Visitor:Start()
    local idle = "idle"
	local finding = "finding"
	local reaching = "reaching"
	local acting = "acting"
	local buying = "buying"
	
	local stateTree = StateMachine:Create({idle, finding, reaching, acting, buying})
	
	return stateTree
end

return Visitor