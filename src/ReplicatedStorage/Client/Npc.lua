--!strict
local PathfindingService = game:GetService("PathfindingService")

local Npc = {}
Npc.__index = Npc

local npcFolder = game.ReplicatedStorage.NPC

--[[
	PRIVATE METHODS
]]
local function _getRandomNpc() : Model
	local npcList = npcFolder:GetChildren()
	local character = npcList[math.random(1, #npcList)]:Clone()
	character.Parent = workspace
	return character
end

local function _walkToWaypoints(character: Model, tableWaypoints: {PathWaypoint})
	local humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid
	
	for _, waypoint in pairs(tableWaypoints) do
		humanoid:MoveTo(waypoint.Position)
		
		if waypoint.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		end
		humanoid.MoveToFinished:Wait()
	end
end

local function _createPath(character: Model, destination: Vector3 | BasePart): Path
	local path = PathfindingService:CreatePath()
	
	if typeof(destination) == "Instance" and destination:IsA("BasePart") then
		destination = destination.Position
	end
	
	pcall(function()
		path:ComputeAsync(character:GetPrimaryPartCFrame().Position, destination)
	end)
	return path
end

local function _walk(character: Model, destination: Vector3 | BasePart)
	local path = _createPath(character, destination)
	
	if path.Status == Enum.PathStatus.Success then	
		_walkToWaypoints(character, path:GetWaypoints())	
	end
	
end
--[[
	CONSTRUCTOR
]]
function Npc.new(specialCharacter: Model?)
	local newNpc = setmetatable({}, Npc)
	
	local character: Model = specialCharacter or _getRandomNpc()
	-- Проверки на все подряд
	local humanoid = character:FindFirstAncestorOfClass("Humanoid")
	assert(humanoid, string.format("Humanoid must be provided in npc %s", character.Name))
	local animator = humanoid:FindFirstAncestorOfClass("Animator")
	assert(animator, string.format("Animator must be provided in npc %s, and parented to it's Humanoid", character.Name))
	local walkingAnimation = character:FindFirstChild("Walking")
	assert(walkingAnimation, string.format("Animation of walking must be provided in npc %s", character.Name))

	local animationTrack = animator:LoadAnimation(walkingAnimation)

	humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Running then
			animationTrack:Play()
			return
		end
		animationTrack:Stop()
	end)

	newNpc.Character = character
	
	return newNpc
end
--[[
	PUBLIC METHODS
]]
function Npc:Animate(animationName:string, animation:Animation?): AnimationTrack
	assert(animationName or type(animationName) ~= "string", string.format("animationName string expected, got %s", type(animationName)))
	if animation ~= nil then
		assert(typeof(animation) == "Instance", string.format("animation Animation expected got %s", typeof(animation)))
		assert(animation:IsA("Animation"), string.format("animation Animation expected got %s", animation.ClassName))
	end

	local animation = animation or self.Character:FindFirstChild(animationName):: Animation
	local animator = self.Character.Humanoid.Animator:: Animator
	-- Эта проверка не пройдет, в случае когда нам дан только один аргумент
	-- animationName, и такой анимации у нпс не будет существовать
	assert(animation, string.format("Animation with name %s doesn't exists", animationName))

	return animator:LoadAnimation(animation)
end

function Npc:Move(destination: Vector3 | BasePart)
	assert(typeof(destination) == "Vector3" or destination:IsA("BasePart"), "")
	_walk(self.Character, destination)
end

function Npc:Destroy()
	if self.Character then
		self.Character:Destroy()
	end
	table.clear(self)
	self = nil
end

return Npc
