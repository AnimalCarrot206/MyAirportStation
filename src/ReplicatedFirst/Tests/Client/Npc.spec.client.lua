--!nonstrict
if not game:IsLoaded() then
	game.Loaded:Wait()
end
------------------------------------------------------
local Npc = require(game.ReplicatedStorage.Client.Npc)
------------------------------------------------------
local createdNpc = Npc.new()
------------------------------------------------------
assert(createdNpc)
------------------------------------------------------
assert(createdNpc.Character)
assert(createdNpc.Character:IsA("Model"))
------------------------------------------------------
createdNpc:Destroy()
------------------------------------------------------
print(createdNpc)
