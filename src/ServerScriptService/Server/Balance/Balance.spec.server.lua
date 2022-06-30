--!strict
local Balance = require(script.Parent)

local createdBalance = Balance.new()
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
createdBalance:Destroy()
print(createdBalance)
----------------------------------------
createdBalance = nil