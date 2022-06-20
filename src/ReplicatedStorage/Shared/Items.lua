--!strict
local Items = {}

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local itemPlace = game.ReplicatedStorage.RemoteEvents.ItemPlace
local itemContainer = game.ReplicatedStorage.Buildings

local function _findItem(itemName: string)
	return itemContainer:FindFirstChild(itemName, true) or error(string.format("Item with name %s, doesn't exists!", itemName))
end

function Items:GetItem(itemName: string): Model
	local foundItem = _findItem(itemName)
	
	if not CollectionService:HasTag(foundItem, "Item") then
		error(string.format("Item %s doesn't have tag 'Item'", itemName))
	end
	
	if not foundItem:GetAttribute("Cost") then
		error(string.format("Item %s doesn't have attribute 'Cost'", itemName))
	end
	
	if CollectionService:HasTag(foundItem, "Actable") then
		local moduleScript = foundItem:FindFirstChildOfClass("ModuleScript")
		
		if moduleScript == nil then
			error(string.format("Actable item '%s' must have a ModuleScript", itemName))
		end
		
		if type(require(moduleScript)) ~= "function" then
			error(string.format("Actable item '%s' must have a ModuleScript that returning a function", itemName))
		end
		
	end
	
	if CollectionService:HasTag(foundItem, "Buyable") and foundItem:GetAttribute("Price") == nil then
		error(string.format("Buyable item %s doesn't have attribute 'Price'!", itemName))
	end
	
	return foundItem :: Model
end

function Items:IsActable(itemName: string): boolean
	local foundItem = self:GetItem(itemName)
	return CollectionService:HasTag(foundItem, "Actable")
end

function Items:IsPathfindable(itemName: string): boolean
	local foundItem = self:GetItem(itemName)
	return CollectionService:HasTag(foundItem, "Pathfindable")
end

function Items:IsBuyable(itemName: string): boolean
	local foundItem = self:GetItem(itemName)
	return CollectionService:HasTag(foundItem, "Buyable")
end

function Items:GetCost(itemName: string): number
	local foundItem = self:GetItem(itemName)
	return foundItem:GetAttribute("Cost") :: number
end

function Items:GetBuyableItemPrice(itemName: string): number
	local foundItem = self:GetItem(itemName)
	return foundItem:GetAttribute("Price") :: number
end

function Items:GetActingFunction(itemModel: Model): (npc: any) -> ()
	assert(itemModel, "")
	local moduleScript = itemModel:FindFirstChildOfClass("ModuleScript")
	return require(moduleScript)
end

function Items:Place(itemName: string, cframeToPlace: CFrame, player: Player?)
	if RunService:IsClient() then
		itemPlace:FireServer(itemName, cframeToPlace)
		return
	end
	
	if RunService:IsServer() then
		assert(player, "Player must be provided for server Place function")
		
		local playerItemContainer = workspace.ItemContainer:FindFirstChild(player.Name)
		assert(playerItemContainer, string.format("%s doesn't have ItemContainer folder", player.Name))
		
		local itemModel = self:GetItem(itemName):Clone() :: Model
		itemModel:SetPrimaryPartCFrame(cframeToPlace)
		
		if self:IsActable(itemName) then
			itemModel.Parent = playerItemContainer.Actable
			return
		end

		if self:IsBuyable(itemName) then
			itemModel.Parent = playerItemContainer.Buyable
			return
		end

		if self:IsPathfindable(itemName) then
			itemModel.Parent = playerItemContainer.Pathfindable
			return
		end

		itemModel.Parent = playerItemContainer.Item
		return
	end
end

return Items
