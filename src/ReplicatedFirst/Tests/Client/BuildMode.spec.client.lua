if not game:IsLoaded() then
    game.Loaded:Wait()
end

local BuildMode = require(game.ReplicatedStorage.Client.BuildMode)

BuildMode:Start(workspace.cells)
local itemModel = game.ReplicatedStorage.Buildings.Construction.Wall:Clone()
itemModel.Parent = workspace
BuildMode:SetItemModel(itemModel)