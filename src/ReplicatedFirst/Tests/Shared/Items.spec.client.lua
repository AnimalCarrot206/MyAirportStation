--!strict
if not game:IsLoaded() then
	game.Loaded:Wait()
end
--------------------------------------
local Items = require(game.ReplicatedStorage.Shared.Items)
--------------------------------------
local swordName = "ClassicSword"
local actableSword = Items:GetItem("ClassicSword")
--------------------------------------
assert(actableSword)
--------------------------------------
assert(Items:GetActingFunction(actableSword))
assert(Items:GetCost(swordName))
assert(not Items:GetBuyableItemPrice(swordName))
--------------------------------------
assert(Items:IsActable(swordName))
assert(not Items:IsBuyable(swordName))
assert(not Items:IsPathfindable(swordName))
--------------------------------------

