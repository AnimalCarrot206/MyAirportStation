--!nonstrict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SharedClasses = ReplicatedStorage.Shared
local ServerClasses = ServerScriptService.Server

local RemoteEvents = ReplicatedStorage.RemoteEvents

-- Money Server -> Client
do
	local CashAccounting  = require(ServerClasses.CashAccounting)
	
	local START_CAPITAL = 100
	
	Players.PlayerAdded:Connect(function(player: Player)
		-- Загружаем баланс или создаем его,
		-- если он отсутствует в ДатаСторе
		local balance = CashAccounting:LoadCurrency(player) or CashAccounting:StartAccounting(player, START_CAPITAL)
	end)
	
	Players.PlayerRemoving:Connect(function(player: Player)
		CashAccounting:SaveCurrency(player)
		CashAccounting:StopAccouting(player)
	end)
end
-- ItemFolders
do
	local exampleFolders = game.ReplicatedStorage.ItemFoldersContainer
	
	Players.PlayerAdded:Connect(function(player: Player)
		local folder = exampleFolders:Clone()
		folder.Name = player.Name
		folder.Parent = workspace.ItemContainer
	end)
	
	Players.PlayerRemoving:Connect(function(player: Player)
		local folder = workspace.ItemContainer:FindFirstChild(player.Name)
		if folder then
			folder:Destroy()
		end
	end)
end

do
	local CashAccounting  = require(ServerClasses.CashAccounting)
	local Items = require(SharedClasses.Items)
	
	local placeItem = RemoteEvents.ItemPlace
	
	-- Функция покупающая предмет
	-- !При этом сразу проверяющая хватает ли денег игроку!
	-- Возвращает буленово значение как результат
	-- Если у игрока по какой либо причине нет баланса
	-- (что по идее не может произойти), то выдает ошибку
	local function buyItem(player:Player, itemCost): boolean
		local balance = CashAccounting:GetPlayerBalance(player)
		assert(balance ~= nil, "No balance for the player: " .. player.Name.. "?")
		-- Если кол-во денег больше или равно стоимости
		-- Тогда покупаем
		if balance:IsCanAfford(itemCost) then
			balance:AddCapital(-itemCost)
			return true
		end
		return false
	end
	-- Срабатывает когда игрок нажимает левую кнопку с экипированный предметом
	placeItem.OnServerEvent:Connect(function(player: Player, name: string, cframeToPlace: CFrame)
		local success, errorMessage = pcall(function()
			return Items:GetItem(name)
		end)
		-- Если внутри pcall будет ошибка, то model станет 
		-- сообщением об ошибке, его мы и посылаем на клиент
		if not success then
			placeItem:FireClient(player, errorMessage)
			return
		end
		
		-- !ВАЖНО!
		-- У ЛЮБОЙ МОДЕЛИ-ПРЕДМЕТА ДОЛЖЕН БЫТЬ АТТРИБУТ "Cost"
		local cost = Items:GetCost(name)
		-- Пытаемся купить предмет, если не удалось
		-- отправляем сообщение на сервер
		local success = buyItem(player, cost)
		if not success then
			placeItem:FireClient(player, "Don't enough money!")
			return
		end
		
		Items:Place(name, cframeToPlace, player)
	end)
end
