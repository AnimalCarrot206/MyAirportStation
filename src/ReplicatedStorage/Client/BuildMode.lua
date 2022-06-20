local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local Canvas = require(game.ReplicatedStorage.Client.Canvas)

local BuildMode = {}

local LocalPlayer = game.Players.LocalPlayer

local isStarted: boolean = false

local currentModel: Model?

local cellsContainer: Instance
local cells: {[number]: BasePart}

local _connectMouse
local _disconnectMouse
do
    local camera = workspace.CurrentCamera
    local mouse = LocalPlayer:GetMouse()
    local mouseMoveConnection: RBXScriptConnection
    local mouseButton1UpConnection: RBXScriptConnection

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    

	_connectMouse = function()
		raycastParams.FilterDescendantsInstances = {cellsContainer}
		
        mouseMoveConnection = mouse.Move:Connect(function()
            local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction.Unit * 500 ,raycastParams)

            if not raycastResult then
                return
            end
            
            Canvas:Move(currentModel, raycastResult.Position)
        end)

        mouseButton1UpConnection = mouse.Button1Up:Connect(function()
            local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction.Unit * 500 ,raycastParams)

            if not raycastResult then
                return
            end
            Canvas:Place(currentModel, raycastResult.Position)
        end)
    end

    _disconnectMouse = function()
        if mouseMoveConnection then
            mouseMoveConnection:Disconnect()
        end
        if mouseButton1UpConnection then
            mouseButton1UpConnection:Disconnect()
        end
    end
end

local _connectRotation
local _disconnectRotation
do
    local actionName = "Rotate"

    local function rotateItem(actionName, inputState, inputObject)
        if inputState ~= Enum.UserInputState.Begin then
            return
        end

        if actionName ~= "Rotate" then
            return
        end

        local cframe = currentModel:GetPrimaryPartCFrame()
        currentModel:SetPrimaryPartCFrame(cframe * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)))
    end

    _connectRotation = function()
        ContextActionService:BindAction(actionName, rotateItem, false, Enum.KeyCode.R)
    end

    _disconnectRotation = function()
        ContextActionService:UnbindAction(actionName)
    end
end

local function _tagCells()
    for index, part in ipairs(cells) do
        CollectionService:AddTag(part, "Cell")
    end
end

function BuildMode:Start(cellsDirectory: Instance)
    if isStarted == true then
        return
    end
    assert(#cellsDirectory:GetChildren() > 1)

    cellsContainer = cellsDirectory

    local children = cellsDirectory:GetChildren() :: {[number]: BasePart}
    Canvas:Assign(children)
    cells = children

    _tagCells()

    isStarted = true
end

function BuildMode:Stop()
    if isStarted == false then
        return
    end

    _disconnectMouse()
    _connectRotation()
    Canvas:Unassign()

    isStarted = false
end

function BuildMode:IsStarted(): boolean
    return isStarted
end

function BuildMode:SetItemModel(itemModel: Model?)
    if not itemModel then
        _disconnectMouse()
        currentModel = nil
        return
    end
    currentModel = itemModel
    _connectMouse()
    _connectRotation()
end

return BuildMode