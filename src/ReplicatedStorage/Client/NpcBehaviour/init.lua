--!nonstrict
local NpcBehaviour = {}

local StateMachine = require(script.StateMachine)
local Items = require(game.ReplicatedStorage.Shared.Items)

local ItemContainer = game.Workspace.ItemContainer:WaitForChild(game.Players.LocalPlayer.Name)

local Visitor = require(script.Visitor)
local Janitor
local Pilot

local removeNpc = game.ReplicatedStorage.RemoteEvents.RemoveNPC
local buy = game.ReplicatedStorage.RemoteEvents.NPC_Buy

local activeNpcList = {}

local function _buy(id: string, item: Model)
	buy:FireServer(id, item.Name)
end

local function _act(npc, item)
	local actingFunction = Items:GetActingFunction(item)
	actingFunction(npc)
end

local function _reach(npc, goal: Model)
	local goalCFrame = goal:GetPrimaryPartCFrame()
	
	npc:Move(goalCFrame.Position)
end

local function _destroy(id)
	local foundTable = activeNpcList[id]
	if not foundTable then
		return
	end
	for key, state in pairs(foundTable.States) do
		state:Destroy()
	end
	table.clear(foundTable)
	foundTable = nil
end

function _stopSimulating(npc, id)
	removeNpc:FireServer(id)
	npc:Destroy()
	_destroy(id)
end

function NpcBehaviour:SimulateVisitor(npc, config)
	
	local stateTree

	local repeats = math.random(1, 7) 
	local currentRepeat = 0
	
	local currentGoal
	
	stateTree.States["idle"].OnBeginState:Connect(function()
		currentRepeat += 1
		
		if currentRepeat > repeats then
			_stopSimulating(npc, config.Id)
			return
		end
		
		if not stateTree.previous or stateTree.previous == "acting" or stateTree.previous == "buying" then
			StateMachine:SetState(stateTree, "finding")
			return
		end
		StateMachine:SetState(stateTree, "finding")
	end)
	
	
	stateTree.States["finding"].OnBeginState:Connect(function()
		local container = {ItemContainer.Buyable,} --ItemContainer.Actable} :: {Instance}
		local randomItemsType = container[math.random(1, #container)] :: Instance
		
		randomItemsType = randomItemsType:GetChildren()
		
		local randomItem = randomItemsType[math.random(1, #randomItemsType > 1 and #randomItemsType or 1)] :: Model
		currentGoal = randomItem
		
		if not currentGoal then
			StateMachine:SetState(stateTree, "idle")
			return
		end
		
		StateMachine:SetState(stateTree, "reaching")
		
	end)
	
	
	stateTree.States["reaching"].OnBeginState:Connect(function()
		_reach(npc, currentGoal)
		
		if Items:IsActable(currentGoal.Name) then
			StateMachine:SetState(stateTree, "acting")
			return
		end

		if Items:IsBuyable(currentGoal.Name) then
			StateMachine:SetState(stateTree, "buying")
			return
		end
	end)
	
	
	stateTree.States["acting"].OnBeginState:Connect(function()
		_act(npc, currentGoal)

		StateMachine:SetState(stateTree, "idle")
	end)
	
	stateTree.States["buying"].OnBeginState:Connect(function()
		_buy(config.Id, currentGoal)
		StateMachine:SetState(stateTree, "idle")
	end)

	StateMachine:SetState(stateTree, "idle")
	
	activeNpcList[config.Id] = stateTree
end

return NpcBehaviour
