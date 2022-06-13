
local Roact = require(game.ReplicatedStorage.Roact)

local LocalPlayer = game.Players.LocalPlayer

local MoneyDisplay = Roact.Component:extend("MoneyDisplay")

function MoneyDisplay:init()
    self:setState({
        moneyValue = 0
    })
end

function MoneyDisplay:render()
    local currentMoneyValue = self.state.moneyValue :: number

    return Roact.createElement("ScreenGui", {}, {
        Label = Roact.createElement("TextLabel", {
            Position = UDim2.new(0.1, 0, 0.55, 0),
            Size = UDim2.new(0.175, 0, 0.125, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(70, 70, 70),
            Font = Enum.Font.ArialBold,
            TextScaled = true,
            BackgroundTransparency = 0.75,
            Text = tostring(currentMoneyValue)
        }, {
            UICorner = Roact.createElement("UICorner", {CornerRadius = UDim.new(0, 6)}, {}),
    
            UIStroke = Roact.createElement("UIStroke", 
            {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
            Color = Color3.fromRGB(10, 10, 10), 
            Thickness = 2.5,
            Transparency = 0.5,
        }, {}),
    
            UITextStroke = Roact.createElement("UIStroke",
            {ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, 
            Color = Color3.fromRGB(55, 211, 203), 
            Thickness = 1.5,
            Transparency = 0.3,
        }, {}),
            UIPadding = Roact.createElement("UIPadding", {
                PaddingBottom = UDim.new(0.15, 0),
                PaddingLeft = UDim.new(0.15, 0),
                PaddingRight = UDim.new(0.15, 0),
                PaddingTop = UDim.new(0.15, 0),
            }, {})
        })
    })
end

function MoneyDisplay:didMount()
    self.running = true

    local connection
    connection = LocalPlayer.AttributeChanged:Connect(function(attribute)
        if attribute ~= "Money" then
            return
        end
        if self.running == false then
            connection:Disconnect()
            return
        end
        self:setState({
            moneyValue = LocalPlayer:GetAttribute(attribute)
        })
    end)
end

function MoneyDisplay:willUnmount()
    self.running = false
end

local moneyUI = Roact.createElement(MoneyDisplay)

return moneyUI