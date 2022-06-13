
if not game:IsLoaded() then
    game.Loaded:Wait()
end
local LocalPlayer = game.Players.LocalPlayer

local Roact = require(game.ReplicatedStorage.Roact)
local moneyUI = require(game.ReplicatedStorage.Client.MoneyValueUI)

local tree = Roact.mount(moneyUI, LocalPlayer.PlayerGui, "Money")




