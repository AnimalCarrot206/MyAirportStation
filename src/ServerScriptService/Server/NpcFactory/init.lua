--!strict
local NPCFactory = {}

local HttpService = game:GetService("HttpService")

local CashAccounting = require(game.ServerScriptService.Server.CashAccounting)

local balance = require(game.ServerScriptService.Server.Balance)
local items = require(game.ReplicatedStorage.Shared.Items)

local createNpc = game.ReplicatedStorage.RemoteEvents.CreateNPC
local removeNpc = game.ReplicatedStorage.RemoteEvents.RemoveNPC

local buying = game.ReplicatedStorage.RemoteEvents.NPC_Buy
local npcBuyed = game.ServerStorage.BindableEvents.NpcBuyedItem
local npcList = {}

local function _findNpc(player: Player, id: string)
	local foundTable = npcList[player.Name]
	for index, serverNpc in ipairs(foundTable) do
		if serverNpc.id == id then
			return serverNpc, index

		end
	end
end

game.Players.PlayerAdded:Connect(function(player: Player)
	npcList[player.Name] = {}
end)

game.Players.PlayerRemoving:Connect(function(player: Player)
	local foundTable = npcList[player.Name]
	
	for index, severNpc in pairs(foundTable) do
		severNpc.balance:Destroy()
		table.clear(severNpc)
		table.remove(foundTable, index)
	end
end)

buying.OnServerEvent:Connect(function(player, id: string, itemName: string)
	assert(itemName, "Name of the item wasn't provided")
	assert(id, "Id wasn't provided")
	local foundNpc = _findNpc(player, id)
	local foundItem = items:GetItem(itemName)
	
	if not foundItem then
		error(string.format("There is no item with that name '%s' ", itemName))
	end
	
	if not foundNpc then
		error(string.format("NPC with this id '%s' was not found", id))
	end
	
	local itemPrice = items:GetBuyableItemPrice(itemName)
	local npcBalance = foundNpc.balance
	
	if npcBalance:GetCapital() < itemPrice then
		return
	end
	
	npcBalance:AddMoney(-itemPrice)
	npcBuyed:Fire(player, itemPrice)
end)

removeNpc.OnServerEvent:Connect(function(player:Player, id: string?)
	assert(id, "Npc id must be provided!")

	local foundNpc, index = _findNpc(player, id)
	table.remove(npcList[player.Name], index)
	
	foundNpc.balance:Destroy()
	table.clear(foundNpc)
	foundNpc = nil
end)

function NPCFactory:Create(player: Player, type: string)
	local id = HttpService:GenerateGUID(false)
	-- Логика изменения баланса NPC в начале
	local startCapital = math.random(0, 1000)
	local npcBalance = balance.new(startCapital)
	
	local config = {
		["Capital"] = startCapital,
		["Id"] = id,
		["Type"] = type
	}
	local serverNpc = {id = id, type = type, balance = npcBalance}
	if not npcList[player.Name] then
		npcList[player.Name] = {}
	end
	table.insert(npcList[player.Name], serverNpc)
	
	createNpc:FireClient(player, config)

	return serverNpc
end

return NPCFactory
