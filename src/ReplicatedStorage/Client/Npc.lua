--!strict
local PathfindingService = game:GetService("PathfindingService")

local NPC = {}
NPC.__index = NPC

local npcFolder = game.ReplicatedStorage.NPC

local function _getRandomNPC() : Model
	local npcList = npcFolder:GetChildren()
	local character = npcList[math.random(1, #npcList)]:Clone()
	character.Parent = workspace
	return character
end

local function _animate(character: any, animationName:string): AnimationTrack?
	local animation = character:FindFirstChild(animationName):: Animation
	local animator = character.Humanoid.Animator
	if animator and animation then
		return animator:LoadAnimation(animation)
	end
	return nil
end

function NPC.new(specialCharacter: Model?)
	local newNPC = setmetatable({}, NPC)
	
	local character: Model = specialCharacter or _getRandomNPC()
	newNPC.Character = character
	
	return newNPC
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
		local animationTrack = _animate(character, "Walking")
		if animationTrack then
			animationTrack.Looped = true
			animationTrack:Play()
		end
		
		_walkToWaypoints(character, path:GetWaypoints())
		if animationTrack then
			animationTrack:Stop()
			animationTrack:Destroy()
		end
		return true
	end
	return false
end

function NPC:Move(destination: Vector3 | BasePart)
	assert(typeof(destination) == "Vector3" or destination:IsA("BasePart"), "")
	return _walk(self.Character, destination)
end

function NPC:Destroy()
	if self.Character then
		self.Character:Destroy()
	end
	table.clear(self)
	self = nil
end

return NPC
