
local Items = require(game.ReplicatedStorage.Shared.Items)

local Canvas = {}

local Cells: {[number]: BasePart} = {}

local selectionBox = Instance.new("SelectionBox")
selectionBox.LineThickness = 0.075
selectionBox.SurfaceTransparency = 0.75
selectionBox.Transparency = 0.15
selectionBox.Parent = workspace

local function _findNearestCell(position: Vector3): BasePart
    local magnitude = math.huge
    local currentPart

    for index, part in ipairs(Cells) do
        local newMagnitude = (part.Position - position).Magnitude

        if newMagnitude < magnitude then
            magnitude = newMagnitude
            currentPart = part
        end
    end

    return currentPart
end

function Canvas:Assign(cells: {[number]: BasePart})
   Cells = cells
end

function Canvas:Unassign()
    Cells = nil
end

function Canvas:GetCellWithPosition(position: Vector3): BasePart
    local nearestCell = _findNearestCell(position)
    return nearestCell
end

function Canvas:Move(itemModel: Model, positionToMove: CFrame | Vector3)
    assert(itemModel)
    assert(positionToMove)

    if typeof(positionToMove) == "CFrame" then
        positionToMove = positionToMove.Position
    end

    local nearestCell = self:GetCellWithPosition(positionToMove)
    Items:Move(itemModel, CFrame.new(nearestCell.Position))

    if nearestCell:GetAttribute("Occupied") == true then
        selectionBox.Color3 = Color3.fromRGB(255, 0, 0)
        selectionBox.SurfaceColor3 = Color3.fromRGB(255, 28, 28)
    else
        selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
        selectionBox.SurfaceColor3 = Color3.fromRGB(67, 255, 64)
    end
    selectionBox.Adornee = nearestCell
end

function Canvas:Place(itemModel: Model, positionToPlace: Vector3)
    local nearestCell = self:GetCellWithPosition(positionToPlace)

    self:Move(itemModel, positionToPlace)

    if nearestCell:GetAttribute("Occupied") == true then
        return
    end
    Items:Place(itemModel.Name, CFrame.new(nearestCell.Position))

    nearestCell:SetAttribute("Occupied", true)
end

return Canvas