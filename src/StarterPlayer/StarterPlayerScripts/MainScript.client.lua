--!strict
if not game:IsLoaded() then
	game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local BindableEvents = ReplicatedStorage.BindableEvents
local RemoteEvents = ReplicatedStorage.RemoteEvents
local SharedClasses = ReplicatedStorage.Shared
local ClientClasses = ReplicatedStorage.Client

-- Отображение кол-ва денег на UI
-- При помощи Аттрибутов у игрока
do 
	local Roact = require(ClientClasses.Roact)
	local moneyUI = require(ClientClasses.MoneyValueUI)

	local tree = Roact.mount(moneyUI, LocalPlayer.PlayerGui, "Money")
	
end

-- Небольшой тест работоспособности Предметов 
do
	
end

-- Небольшой набросок NPC для клиент-сервера
do
	local npc = require(ClientClasses.Npc)
	local npcBehaviour = require(ClientClasses.NpcBehaviour)
	
	local createNpc = RemoteEvents.CreateNPC
	local removeNpc = RemoteEvents.RemoveNPC
	
	createNpc.OnClientEvent:Connect(function(config)
		local createdNpc = npc.new()
		
		if config.Type == "Visitor" then
			npcBehaviour:SimulateVisitor(createdNpc, config)
		end
	end)
	
	
end