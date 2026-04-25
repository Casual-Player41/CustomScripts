local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer



--#region -- Tween Service implementetion
local TweenService = {}
TweenService._Connection = nil

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
    InOut = function(t)
      return t < 0.5 and 2 * t * t or 1 - (-2 * t + 2)^2 / 2
    end
  },

  Cubic = {
    In = function(t) return t^3 end,
    Out = function(t) return 1 - (1 - t)^3 end,
    InOut = function(t)
      return t < 0.5 and 4 * t^3 or 1 - (-2 * t + 2)^3 / 2
    end
  },

  Quart = {
    In = function(t) return t^4 end,
    Out = function(t) return 1 - (1 - t)^4 end,
    InOut = function(t)
      return t < 0.5 and 8 * t^4 or 1 - (-2 * t + 2)^4 / 2
    end
  },

  Quint = {
    In = function(t) return t^5 end,
    Out = function(t) return 1 - (1 - t)^5 end,
    InOut = function(t)
      return t < 0.5 and 16 * t^5 or 1 - (-2 * t + 2)^5 / 2
    end
  },

  Exponential = {
    In = function(t)
      return t == 0 and 0 or 2^(10 * t - 10)
    end,
    Out = function(t)
      return t == 1 and 1 or 1 - 2^(-10 * t)
    end,
    InOut = function(t)
      if t == 0 then return 0 end
      if t == 1 then return 1 end
      return t < 0.5
        and (2^(20 * t - 10)) / 2
        or (2 - 2^(-20 * t + 10)) / 2
    end
  },

  Circular = {
    In = function(t)
      return 1 - math.sqrt(1 - t * t)
    end,
    Out = function(t)
      return math.sqrt(1 - (t - 1)^2)
    end,
    InOut = function(t)
      return t < 0.5
        and (1 - math.sqrt(1 - (2 * t)^2)) / 2
        or (math.sqrt(1 - (-2 * t + 2)^2) + 1) / 2
    end
  },

  Back = {
    In = function(t)
      local c1 = 1.70158
      local c3 = c1 + 1
      return c3 * t^3 - c1 * t^2
    end,
    Out = function(t)
      local c1 = 1.70158
      local c3 = c1 + 1
      return 1 + c3 * (t - 1)^3 + c1 * (t - 1)^2
    end,
    InOut = function(t)
      local c1 = 1.70158
      local c2 = c1 * 1.525
      return t < 0.5
        and ((2 * t)^2 * ((c2 + 1) * 2 * t - c2)) / 2
        or ((2 * t - 2)^2 * ((c2 + 1) * (2 * t - 2) + c2) + 2) / 2
    end
  },

  Bounce = {
    Out = function(t)
      local n1 = 7.5625
      local d1 = 2.75

      if t < 1 / d1 then
        return n1 * t * t
      elseif t < 2 / d1 then
        t = t - 1.5 / d1
        return n1 * t * t + 0.75
      elseif t < 2.5 / d1 then
        t = t - 2.25 / d1
        return n1 * t * t + 0.9375
      else
        t = t - 2.625 / d1
        return n1 * t * t + 0.984375
      end
    end,

    In = function(t)
      local n1 = 7.5625
      local d1 = 2.75

      local function bounceOut(x)
        if x < 1 / d1 then
          return n1 * x * x
        elseif x < 2 / d1 then
          x = x - 1.5 / d1
          return n1 * x * x + 0.75
        elseif x < 2.5 / d1 then
          x = x - 2.25 / d1
          return n1 * x * x + 0.9375
        else
          x = x - 2.625 / d1
          return n1 * x * x + 0.984375
        end
      end

      return 1 - bounceOut(1 - t)
    end,

    InOut = function(t)
      local n1 = 7.5625
      local d1 = 2.75

      local function bounceOut(x)
        if x < 1 / d1 then
          return n1 * x * x
        elseif x < 2 / d1 then
          x = x - 1.5 / d1
          return n1 * x * x + 0.75
        elseif x < 2.5 / d1 then
          x = x - 2.25 / d1
          return n1 * x * x + 0.9375
        else
          x = x - 2.625 / d1
          return n1 * x * x + 0.984375
        end
      end

      if t < 0.5 then
        return (1 - bounceOut(1 - 2 * t)) / 2
      else
        return (1 + bounceOut(2 * t - 1)) / 2
      end
    end
  },

  Elastic = {
    In = function(t)
      if t == 0 then return 0 end
      if t == 1 then return 1 end
      return -2^(10 * t - 10) * math.sin((t * 10 - 10.75) * ((2 * math.pi) / 3))
    end,

    Out = function(t)
      if t == 0 then return 0 end
      if t == 1 then return 1 end
      return 2^(-10 * t) * math.sin((t * 10 - 0.75) * ((2 * math.pi) / 3)) + 1
    end,

    InOut = function(t)
      if t == 0 then return 0 end
      if t == 1 then return 1 end

      local c = (2 * math.pi) / 4.5

      if t < 0.5 then
        return -(2^(20 * t - 10) * math.sin((20 * t - 11.125) * c)) / 2
      else
        return (2^(-20 * t + 10) * math.sin((20 * t - 11.125) * c)) / 2 + 1
      end
    end
  }
}



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
  self.CurrentTime = 0
  self.CompletedLoops = 0
  self.CurrentDirection = 1

for prop, targetValue in pairs(self.Properties) do
  if instance[prop] ~= nil then
    local initialValue = instance[prop]

    if typeof(initialValue) == "CFrame" then
      self.InitialProperties[prop] = initialValue

    elseif typeof(initialValue) == "Vector3" then
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
    if typeof(targetValue) == "Vector3" then
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



local ActiveTweens = {}

function Tween:Play()
  if self.IsPlaying then return end
  self.IsPlaying = true
  self.StartTime = os.clock()
  self.CurrentTime = 0
  self.CompletedLoops = 0
  self.CurrentDirection = 1
  TweenService._AddActiveTween(self)

end

function Tween:Stop()
  if not self.IsPlaying then return end
  self.IsPlaying = false
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
          self.Instance[prop] = Vector3.new(nx, ny, nz)
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



function TweenService._StartUpdateLoop()
  if TweenService._Connection then return end

  TweenService._Connection = RunService.Heartbeat:Connect(function(deltaTime)
    for i = #ActiveTweens, 1, -1 do
      local tween = ActiveTweens[i]

      if not tween:Update(deltaTime) then
        table.remove(ActiveTweens, i)
      end
    end

    if #ActiveTweens == 0 then
      TweenService._StopUpdateLoop()
    end
  end)
end

function TweenService._StopUpdateLoop()
  if TweenService._Connection then
    TweenService._Connection:Disconnect()
    TweenService._Connection = nil
  end
end



function TweenService._AddActiveTween(tween)
  table.insert(ActiveTweens, tween)
  TweenService._StartUpdateLoop()
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


function TweenService:Create(instance, tweenInfo, properties)
  return Tween.new(instance, tweenInfo, properties)
end

TweenService.TweenInfo = TweenInfo
_G.TweenService = TweenService

--#endregion  -- End of TweenService Implementation 


local GetCharacter = function(model)
  local Character = model.Character; if not Character then return nil end
  return Character
end

local GetHrp = function(character: Model)
  if not character then return nil end
  local Hrp = character:FindFirstChild("HumanoidRootPart"); if not Hrp then return nil end
  return Hrp
end

local GetHumanoid = function(character: Model)
  if not character then return nil end
  local Humanoid = character:FindFirstChildOfClass("Humanoid"); if not Humanoid then return nil end
  return Humanoid
end


local TweenTpTo = function(position: Vector3, speed: number, easingStyle: string?, easingDirection: string?, onComplete: (() -> ())?)
  local Character = GetCharacter(LocalPlayer); if not Character then return end
  local Hrp = GetHrp(Character); if not Hrp then return end
  local Humanoid = GetHumanoid(Character); if not Humanoid or Humanoid.Health <= 0 then return end

  local startPos = Hrp.Position
  local distance = (position - startPos).Magnitude
  local duration = distance / 350

  if duration <= 0 then
    Hrp.Position = position
    Hrp.AssemblyLinearVelocity = Vector3.zero
    return
  end

  local tween = TweenService:Create(Hrp, TweenService.TweenInfo.new(duration, "Linear", "InOut"), {
    Position = position
  }); tween:Play()

  while tween.IsPlaying and Character.Parent do
    if not Humanoid or Humanoid.Health <= 0 then
      tween:Stop()
      break
    end

    Hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    -- Hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    task.wait()
  end

  Hrp.AssemblyLinearVelocity = Vector3.zero
  -- Hrp.AssemblyAngularVelocity = Vector3.zero
end

return TweenTpTo
