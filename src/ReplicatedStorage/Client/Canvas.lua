local CollectionService = game:GetService("CollectionService")

local Items = require(game.ReplicatedStorage.Shared.Items)

local Canvas = {}

local CellsArray: {[number]: BasePart} = {}

local CurrentCell: BasePart

local _isCanPlace
    
do
    local function isCanPlaceConstruction(itemModel: Model)
        local orientation = itemModel:GetAttribute("Orientation")

        if not orientation then
            print(string.format("Item %s is undefined with orientation attribute", itemModel.Name))
            return false
        end

        local objectValueBasedOnOrientation = CurrentCell:FindFirstChild(orientation) :: ObjectValue

        return objectValueBasedOnOrientation.Value == nil
    end

    _isCanPlace = function(itemModel: Model)
        if CollectionService:HasTag(itemModel, "Construction") then
            return isCanPlaceConstruction(itemModel)
        end

        local center = CurrentCell:FindFirstChild("Center") :: ObjectValue
        
        return center.Value == nil
    end
end

local _highlightingCellHandler

do
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.LineThickness = 0.075
    selectionBox.SurfaceTransparency = 0.75
    selectionBox.Transparency = 0.15
    selectionBox.Parent = workspace

    local WRONG_PLACE_COLOR = Color3.fromRGB(255, 28, 28)
    local RIGHT_PLACE_COLOR = Color3.fromRGB(67, 255, 64)

    _highlightingCellHandler = function(itemModel: Model)
        local isCanPlace = _isCanPlace(itemModel)

        if isCanPlace == true then
            selectionBox.SurfaceColor3 = RIGHT_PLACE_COLOR
            selectionBox.Color3 = RIGHT_PLACE_COLOR
            
        end

        if isCanPlace == false then
            selectionBox.SurfaceColor3 = WRONG_PLACE_COLOR
            selectionBox.Color3 = WRONG_PLACE_COLOR
            
        end

        selectionBox.Adornee = CurrentCell
    end
end

function Canvas:Assign(cells: {[number]: BasePart})
   CellsArray = cells
end

function Canvas:Unassign()
    CellsArray = nil
    CurrentCell = nil
end


function Canvas:Move(itemModel: Model, cell: BasePart)
    assert(itemModel)
    assert(cell)
    assert(table.find(CellsArray, cell))

    local itemCFrame = itemModel:GetPrimaryPartCFrame()
    local cellSurfacePosition = cell.Position + Vector3.new(0, cell.Size.Y / 2, 0)
    itemModel:SetPrimaryPartCFrame(itemCFrame.Rotation + cellSurfacePosition)

    CurrentCell = cell

    _highlightingCellHandler(itemModel)
end

function Canvas:Rotate(itemModel: Model,cell: BasePart, degrees: number?)
    assert(itemModel)
    degrees = degrees or 90

    local cframe = itemModel:GetPrimaryPartCFrame()
    itemModel:SetPrimaryPartCFrame(cframe * CFrame.Angles(math.rad(0), math.rad(degrees), math.rad(0)))
    

    local orientation = itemModel.PrimaryPart.Orientation.Y
    print(orientation)

    if not CollectionService:HasTag(itemModel, "Construction") then
        return
    end

    local result
    if orientation == 0 then
        result = "Back"
    elseif orientation == 90 then
        result = "Right"
    elseif orientation == -180 then
        result = "Forward"
    elseif orientation == -90 then
        result = "Left"
    end

    itemModel:SetAttribute("Orientation", result)
    _highlightingCellHandler(itemModel)
end

function Canvas:Place(itemModel: Model, positionToPlace: Vector3)
    if not _isCanPlace(itemModel) then
        return
    end


    if CollectionService:HasTag(itemModel, "Construction") then
        local orientation = itemModel:GetAttribute("Orientation")

        if not orientation then
            warn()
            return
        end

        local objectValueBasedOnOrientation = CurrentCell:FindFirstChild(orientation) :: ObjectValue
        
        if objectValueBasedOnOrientation.Value ~= nil then
            return
        end

        objectValueBasedOnOrientation.Value = itemModel
    else
        local centerObjectValue = CurrentCell:FindFirstChild("Center") :: ObjectValue

        if centerObjectValue.Value ~= nil then
            return
        end

        centerObjectValue.Value = itemModel
    end

    Items:Place(itemModel.Name, itemModel:GetPrimaryPartCFrame())
end

return Canvas