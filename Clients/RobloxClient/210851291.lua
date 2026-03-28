--[[ information:
  * Game name: Build A Boat For Treasure
  * Game Id: 537413528
  * Game UniverseId: 210851291
  * Game link: https://www.roblox.com/games/537413528/Build-A-Boat-For-Treasure
]]


if not rbxcli then return end
if not (tonumber(game.UniverseId) == 210851291) then return end

_G.AutofarmEnabled = true

--#region     -- TweenService Implementation
local TweenService = {}

TweenService._UpdateLoopRunning = false
TweenService._LastUpdateTime = 0
TweenService._UpdateFrequency = 144



local EasingFunctions = {
  Linear = function(t) return t end,

  Sine = {
    In = function(t) return 1 - math.cos((t * math.pi) / 2) end,
    Out = function(t) return math.sin((t * math.pi) / 2) end,
    InOut = function(t) return -(math.cos(math.pi * t) - 1) / 2 end
  },

  Quad = {
    In = function(t) return t * t end,
    Out = function(t) return 1 - (1 - t) * (1 - t) end,
    InOut = function(t) return t < 0.5 and 2 * t * t or 1 - (-2 * t + 2) ^ 2 / 2 end
  },

  Cubic = {
    In = function(t) return t * t * t end,
    Out = function(t) return 1 - (1 - t) ^ 3 end,
    InOut = function(t) return t < 0.5 and 4 * t * t * t or 1 - (-2 * t + 2) ^ 3 / 2 end
  }
}

local function IsVector3(obj)
  local t = type(obj)
  if t == "userdata" then
    return pcall(function() return obj.X and obj.Y and obj.Z end)
  elseif t == "table" then
    return obj.x ~= nil and obj.y ~= nil and obj.z ~= nil or (obj.X ~= nil and obj.Y ~= nil and obj.Z ~= nil)
  end
  return false
end

local function CreateVector3(x, y, z)
  local ok, vec = pcall(function() return Vector3.new(x, y, z) end)
  if ok then return vec end

  return { x = x, y = y, z = z }
end

local function GetEasingFunction(easingStyle, easingDirection)
  if easingStyle == "Linear" then
    return EasingFunctions.Linear
  end
  local style = EasingFunctions[easingStyle]
  if style then
    if easingDirection == "In" then return style.In end
    if easingDirection == "Out" then return style.Out end
    return style.InOut
  end
  return EasingFunctions.Linear
end


-- TweenInfo class
local TweenInfo = {}
TweenInfo.__index = TweenInfo

function TweenInfo.new(time, easingStyle, easingDirection, repeatCount, reverses, delayTime)
  local self = setmetatable({}, TweenInfo)
  self.Time = time or 1
  self.EasingStyle = easingStyle or "Quad"
  self.EasingDirection = easingDirection or "Out"
  self.RepeatCount = repeatCount or 0
  self.Reverses = reverses or false
  self.DelayTime = delayTime or 0
  return self
end

-- Tween class
local Tween = {}
Tween.__index = Tween

function Tween.new(instance, tweenInfo, properties)
  local self = setmetatable({}, Tween)
  self.Instance = instance
  if type(tweenInfo) == "table" and getmetatable(tweenInfo) ~= TweenInfo then
    self.TweenInfo = TweenInfo.new(
      tweenInfo.Time or 1,
      tweenInfo.EasingStyle or "Quad",
      tweenInfo.EasingDirection or "Out",
      tweenInfo.RepeatCount or 0,
      tweenInfo.Reverses or false,
      tweenInfo.DelayTime or 0
    )
  else
    self.TweenInfo = tweenInfo
  end

  self.Properties = properties or {}
  self.InitialProperties = {}
  self.IsPlaying = false
  self.StartTime = 0
  self.CurrentTime = 0
  self.CompletedLoops = 0
  self.CurrentDirection = 1

for prop, targetValue in pairs(self.Properties) do
  if instance[prop] ~= nil then
    local initialValue = instance[prop]

    if typeof(initialValue) == "CFrame" then
      self.InitialProperties[prop] = initialValue

    elseif IsVector3(initialValue) then
      local ok, x, y, z = pcall(function()
        return initialValue.X or initialValue.x, initialValue.Y or initialValue.y, initialValue.Z or initialValue.z
      end)
      if ok then
        self.InitialProperties[prop] = { type = "Vector3", x = x, y = y, z = z }
      else
        self.InitialProperties[prop] = initialValue
      end

    elseif type(initialValue) == "table" then
      local copy = {}
      for k, v in pairs(initialValue) do copy[k] = v end
      self.InitialProperties[prop] = copy

    else
      self.InitialProperties[prop] = initialValue
    end
  end
end

  -- Normalize target Vector3 values
  for prop, targetValue in pairs(self.Properties) do
    if IsVector3(targetValue) then
      local tx = targetValue.X or targetValue.x or targetValue[1]
      local ty = targetValue.Y or targetValue.y or targetValue[2]
      local tz = targetValue.Z or targetValue.z or targetValue[3]
      self.Properties[prop] = { type = "Vector3", x = tx, y = ty, z = tz }
    end
  end

  self.Completed = {
    Connect = function(_, callback)
      self._completedCallback = callback
      return {
        Disconnect = function() self._completedCallback = nil end
      }
    end
  }

  return self
end

function Tween:Play()
  if self.IsPlaying then return end
  self.IsPlaying = true
  self.StartTime = os.clock()
  self.CurrentTime = 0
  self.CompletedLoops = 0
  self.CurrentDirection = 1
  TweenService._AddActiveTween(self)
  self:Update(0.001)
end

function Tween:Stop()
  if not self.IsPlaying then return end
  self.IsPlaying = false
  TweenService._RemoveActiveTween(self)
end

function Tween:Update(deltaTime)
  if not self.IsPlaying then return false end
  self.CurrentTime = self.CurrentTime + deltaTime
  local tweenInfo = self.TweenInfo
  if not tweenInfo then return false end

  if self.CurrentTime < tweenInfo.DelayTime then return true end

  local easingFunc = GetEasingFunction(tweenInfo.EasingStyle, tweenInfo.EasingDirection)
  local totalDuration = tweenInfo.Time or 1
  local adjustedTime = self.CurrentTime - tweenInfo.DelayTime
  local runsNeeded = (tweenInfo.RepeatCount == 0) and 1 or tweenInfo.RepeatCount
  local totalTimeNeeded = tweenInfo.DelayTime + totalDuration * runsNeeded

  if self.CurrentTime >= totalTimeNeeded then
    pcall(function()
      for prop, targetValue in pairs(self.Properties) do
        self.Instance[prop] = targetValue
      end
    end)
    self:Stop()
    if self._completedCallback then pcall(self._completedCallback) end
    return false
  end

  local loopProgress = (adjustedTime % totalDuration) / totalDuration
  if self.CurrentDirection == -1 then loopProgress = 1 - loopProgress end
  local alpha = easingFunc(loopProgress)

  for prop, targetValue in pairs(self.Properties) do
    if self.Instance[prop] ~= nil and self.InitialProperties[prop] ~= nil then
      local initialValue = self.InitialProperties[prop]

      if typeof(initialValue) == "CFrame" and typeof(targetValue) == "CFrame" then
        local cf = initialValue:Lerp(targetValue, alpha)
        pcall(function()
          self.Instance[prop] = cf
        end)

      -- Existing Vector3 handling
      elseif type(initialValue) == "table" and initialValue.type == "Vector3"
        and type(targetValue) == "table"
        and (targetValue.type == "Vector3" or (targetValue.x and targetValue.y and targetValue.z)) then

        local tx, ty, tz = targetValue.x, targetValue.y, targetValue.z
        local nx = initialValue.x + (tx - initialValue.x) * alpha
        local ny = initialValue.y + (ty - initialValue.y) * alpha
        local nz = initialValue.z + (tz - initialValue.z) * alpha

        pcall(function()
          self.Instance[prop] = CreateVector3(nx, ny, nz)
        end)

      -- Table handling
      elseif type(targetValue) == "table" and type(initialValue) == "table" and initialValue.type == nil then
        local newValue = {}
        for k, v in pairs(initialValue) do
          if targetValue[k] ~= nil then
            if type(v) == "number" and type(targetValue[k]) == "number" then
              newValue[k] = v + (targetValue[k] - v) * alpha
            else
              newValue[k] = targetValue[k]
            end
          else
            newValue[k] = v
          end
        end

        pcall(function()
          self.Instance[prop] = newValue
        end)

      -- Number fallback
      else
        if type(initialValue) == "number" and type(targetValue) == "number" then
          pcall(function()
            self.Instance[prop] = initialValue + (targetValue - initialValue) * alpha
          end)
        else
          pcall(function()
            self.Instance[prop] = targetValue
          end)
        end
      end
    end
  end

  return true
end


-- Active tweens list and management
local ActiveTweens = {}

function TweenService._StartUpdateLoop()
  TweenService._UpdateLoopRunning = true
  TweenService._LastUpdateTime = os.clock()
end

function TweenService._StopUpdateLoop()
  TweenService._UpdateLoopRunning = false
end

function TweenService._AddActiveTween(tween)
  table.insert(ActiveTweens, tween)
  if not TweenService._UpdateLoopRunning then TweenService._StartUpdateLoop() end
end

function TweenService._RemoveActiveTween(tween)
  for i, t in ipairs(ActiveTweens) do
    if t == tween then
      table.remove(ActiveTweens, i)
      break
    end
  end
  if #ActiveTweens == 0 then TweenService._StopUpdateLoop() end
end

local OriginalWait = task.wait
TweenService._LastUpdateTime = os.clock()
TweenService._UpdateFrequency = 144

function TweenService._ProcessTweens()
  local currentTime = os.clock()
  local deltaTime = currentTime - TweenService._LastUpdateTime
  TweenService._LastUpdateTime = currentTime
  local i = 1
  while i <= #ActiveTweens do
    local tween = ActiveTweens[i]
    local shouldContinue = tween:Update(deltaTime)
    if shouldContinue then
      i = i + 1
    else
      table.remove(ActiveTweens, i)
    end
  end
  if #ActiveTweens == 0 then TweenService._UpdateLoopRunning = false end
end

-- Override wait to keep tweens processing -- Overwriten to TweenService._wait [ was just wait ]
TweenService._wait = function(seconds)
  local startTime = os.clock()
  local endTime = startTime + seconds
  local updateInterval = 1 / TweenService._UpdateFrequency

  if TweenService._UpdateLoopRunning then TweenService._ProcessTweens() end

  while os.clock() < endTime do
    local nextUpdateTime = os.clock() + updateInterval
    local waitTime = math.min(nextUpdateTime - os.clock(), endTime - os.clock())
    if waitTime > 0 then OriginalWait(waitTime) end
    if TweenService._UpdateLoopRunning then TweenService._ProcessTweens() end
  end

  return os.clock() - startTime
end

function TweenService:Create(instance, tweenInfo, properties)
  return Tween.new(instance, tweenInfo, properties)
end

TweenService.TweenInfo = TweenInfo
_G.TweenService = TweenService

--#endregion  -- End of TweenService Implementation 


--== Services && Variables ==--
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Variables = {
  TweenSpeed = 390, -- Studs / s
}


--== Functions ==--
local MyFunctions = {}
local RbxCli = {}
local GameFunctions = {}

-- // My Functions \\ --
MyFunctions.GetCharacter = function()
  return LocalPlayer.Character
end

MyFunctions.GetHrp = function()
  local Character = MyFunctions.GetCharacter(); if not Character then return end
  return Character:FindFirstChild("HumanoidRootPart")
end

MyFunctions.GetHumanoid = function()
  local Character = MyFunctions.GetCharacter(); if not Character then return end
  return Character:FindFirstChildOfClass("Humanoid")
end


MyFunctions.SetCanCollide = function(part: Instance, status: boolean)
  for _, child in pairs(part:GetChildren()) do
    if child:IsA("BasePart") then
      child.CanCollide = status
    end
  end
end

MyFunctions.TweenTpTo = function(position: Vector3)
  local Character = MyFunctions.GetCharacter(); if not Character then return end
  local Hrp = MyFunctions.GetHrp(); if not Hrp then return end

  MyFunctions.SetCanCollide(Character, true)

  local success, CurrentPos = pcall(function() return Hrp.Position end)

  if not success then return end
  
  local Distance = (position - CurrentPos).Magnitude
  local Duration = Distance / Variables.TweenSpeed

  local TargetCFrame = CFrame.lookAt(CurrentPos, position)
  local TweenInfo = TweenService.TweenInfo.new(Duration, "Linear", "InOut")

  local Tween = TweenService:Create(Hrp, TweenInfo, {
    CFrame = CFrame.new(position) * TargetCFrame.Rotation
  })

  Tween:Play()

  -- This loop ensures we stop if the character dies OR the farm is toggled off
  while Tween.IsPlaying and Character.Parent and _G.AutofarmEnabled do
    local Hum = MyFunctions.GetHumanoid()
    if not Hum or Hum.Health <= 0 then 
      Tween:Stop() 
      break 
    end
    TweenService._wait(0.05)
  end

  if not Character.Parent then return end

  Hrp.Velocity = Vector3.new(0,0,0) 
  Hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)

  MyFunctions.SetCanCollide(Character, false)
end


-- // RbxCli functions \\ --
RbxCli.Notify = function(Content: string, Duration: number)
  rbxcli.display_notification(Content, Duration)
end

--
GameFunctions.IsAlive = function()
  local Hum = MyFunctions.GetHumanoid(); return Hum and Hum.Parent and Hum.Health > 0
end


GameFunctions.Autofarm = function()
  MyFunctions.TweenTpTo(Vector3.new(-55, 80, 1210));   if not GameFunctions.IsAlive() then return false end
  MyFunctions.TweenTpTo(Vector3.new(-55, 80, 8718));   if not GameFunctions.IsAlive() then return false end
  MyFunctions.TweenTpTo(Vector3.new(-55, -360, 9496)); if not GameFunctions.IsAlive() then return false end
  
  return true
end

-- // Code \\ --
task.spawn(function()
  while true do
    task.wait(0.3)
    if not _G.AutofarmEnabled then continue end
    local success, completed = pcall(GameFunctions.Autofarm)

    if success and completed == true then
      RbxCli.Notify("Reached the end.. waiting 16 seconds", 16)
      task.wait(16)
    else
      RbxCli.Notify("Player died or something happened. Retrying in 3 seconds.", 3)
      task.wait(3)
    end
  end
end)
