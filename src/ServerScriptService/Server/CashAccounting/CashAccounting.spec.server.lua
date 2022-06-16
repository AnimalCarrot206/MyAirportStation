--!nonstrict
local Players = game:GetService("Players")
---------------------------------------------
local CashAccounting = require(script.Parent)

local function commonTests(player: Player, balance: any?)
	local createdBalance = balance or CashAccounting:StartAccounting(player)
	----------------------------------------
	createdBalance:AddCapital(-createdBalance:GetCapital())
	assert(createdBalance:GetCapital() == 0)
	----------------------------------------
	createdBalance:AddCapital(100)
	----------------------------------------
	assert(createdBalance:GetCapital() == 100)
	assert(createdBalance:IsCanAfford(50))
	assert(createdBalance:IsCanAfford(100))
	----------------------------------------
	assert(not createdBalance:IsCanAfford(1000))
	----------------------------------------
	assert(CashAccounting:GetPlayerBalance(player) == createdBalance)
	CashAccounting:StopAccouting(player)
	----------------------------------------
	print(createdBalance)
	print(CashAccounting:GetPlayerBalance(player))
	----------------------------------------
	createdBalance = nil
end

---------------------------------------------
Players.PlayerAdded:Connect(function(player)
	----------------------------------------
	commonTests(player)
	----------------------------------------
	local loadedBalance = CashAccounting:LoadCurrency(player)
	----------------------------------------
	commonTests(player, loadedBalance)
	----------------------------------------
end)

Players.PlayerRemoving:Connect(function(player)
	CashAccounting:SaveCurrency(player)
end)