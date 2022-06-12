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

-- Оповещение сервера о том что клиент загрузился
-- Необходимо для синхронизации

-- Отображение кол-ва денег на UI
-- При помощи RemoteEvent CashChanged
do 
	local moneyScreenGui = PlayerGui:WaitForChild("Money")
	local textBox = moneyScreenGui:WaitForChild("TextBox")
	
	LocalPlayer.AttributeChanged:Connect(function(attributeName)
		if not attributeName == "Money" then
			return  
		end
		local moneyValue = LocalPlayer:GetAttribute(attributeName)
		
		textBox.Text = tostring(moneyValue)
	end)
	
	textBox.Text = LocalPlayer:GetAttribute("Money") or "Loading..."
	
end

-- Небольшой тест работоспособности Предметов 
do
	local Items = require(SharedClasses.Items)
	
	local itemModel = Items:GetItem("ClassicSword"):Clone()
	itemModel.Parent = workspace
	
	local mouse = game.Players.LocalPlayer:GetMouse()
	mouse.TargetFilter = itemModel
	
	RunService.RenderStepped:Connect(function()
		local cframeWithoutRotation = CFrame.new(mouse.Hit.Position)
		Items:Move(itemModel, cframeWithoutRotation)
	end)
	
	local function onMouseButton1Down(actionName, inputState, inputObject)
		if inputState ~= Enum.UserInputState.Begin then
			return
		end
		local cframeWithoutRotation = CFrame.new(mouse.Hit.Position)
		Items:Place(itemModel.Name, cframeWithoutRotation)
	end
	ContextActionService:BindAction("Build", onMouseButton1Down, false, Enum.UserInputType.MouseButton1)
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