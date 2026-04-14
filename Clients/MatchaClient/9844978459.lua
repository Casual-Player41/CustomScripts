--[[ information:
  * Game name: Fish.OS
  * Game Id: 9844978459
  * Game UniverseId: 9844978459
  * Game link: https://www.roblox.com/games/123368132872113/FISH-OS-IDLE-FISHING-SIMULATOR

  * Script version: 1.0.0
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui"); if not PlayerGui then error("No playergui?", 2); return end

local FishOsScreenGui = PlayerGui:FindFirstChild("FishOS"); if not FishOsScreenGui then error("No Fish Os?", 2); return end
local DesktopBtn = FishOsScreenGui:FindFirstChild("Desktop"); if not DesktopBtn then error("No desktop button?", 2); return end



--#region -- Start of "MyVariables"



local MyVariables = {
  DebugMode = true,
  ScriptTitle = "Kitty - Fish OS",

  State = "WaitBobber", -- Minigame, FoundBobber, ClickBobber, WaitBobber
  FarmPos = Vector2.new(0, 440),
}

--#endregion -- End of "MyVariables"


--#region -- Start of "MyFunctions"
local MyFunctions = {}

MyFunctions.DebugPrint = function(Type: string, ...)
  if not MyVariables.DebugMode then return end

  local args = { ... }
  local message = table.concat(args, " ")

  local t = os.date("*t")
  local timeStr = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)

  Type = string.lower(Type)

  if Type == "print" then
    print(string.format("[ %s ] (%s): %s", MyVariables.ScriptTitle, timeStr, message))

  elseif Type == "warn" then
    warn(string.format("[ %s ] (%s): %s", MyVariables.ScriptTitle, timeStr, message))

  elseif Type == "debug" then
    print(string.format("[ %s ] [DEBUG] (%s): %s", MyVariables.ScriptTitle, timeStr, message))

  elseif Type == "info" then
    print(string.format("[ %s ] (%s): %s", MyVariables.ScriptTitle, timeStr, message))

  else
    print(string.format("[ %s ] (%s): %s", MyVariables.ScriptTitle, timeStr, message))
  end
end

MyFunctions.AutoFish = function()
  if MyVariables.State ~= "WaitBobber" then return end

  local Mouse = LocalPlayer:GetMouse()
  if Mouse.X ~= MyVariables.FarmPos.X or Mouse.Y ~= MyVariables.FarmPos.Y then
    mousemoveabs(MyVariables.FarmPos.X, MyVariables.FarmPos.Y)
    task.wait(0.1)
    mouse1click()
  else
    mouse1click()
  end
end

MyFunctions.WaitForBobber = function()
  if MyVariables.State ~= "WaitBobber" then return end
  local Bobber = DesktopBtn:FindFirstChild("Bobber"); if not Bobber then return end


  if Bobber then
    MyFunctions.DebugPrint("debug", "Bobber detected")
    MyVariables.State = "FoundBobber"
  end
end

MyFunctions.ClickBobber = function()
    if MyVariables.State ~= "FoundBobber" then return end

    local startTime = tick()
    
    repeat
        local Bobber = DesktopBtn:FindFirstChild("Bobber")
        
        if not Bobber then break end 

        local x = Bobber.AbsolutePosition.X + (Bobber.AbsoluteSize.X / 2)
        local y = Bobber.AbsolutePosition.Y + (Bobber.AbsoluteSize.Y / 2)

        mousemoveabs(x, y)
        mouse1click()
        
        task.wait(0.05)
        
        if tick() - startTime > 5 then 
            MyVariables.State = "WaitBobber"
            return 
        end
    until FishOsScreenGui:FindFirstChild("MinigameOverlay")

    MyFunctions.DebugPrint("debug", "Clicked bobber.")
    MyVariables.State = "Minigame"
end

MyFunctions.AutoMinigame = function()
  if MyVariables.State ~= "Minigame" then return end
 
  local MinigameOverlay = FishOsScreenGui:FindFirstChild("MinigameOverlay"); if not MinigameOverlay then MyVariables.State = "WaitBobber"; return end
  local BarOuter = MinigameOverlay:FindFirstChild("BarOuter"); if not BarOuter then MyVariables.State = "WaitBobber"; return end
  local FishingBar = BarOuter:FindFirstChild("FishingBar"); if not FishingBar then MyVariables.State = "WaitBobber"; return end
  local CatchZone = FishingBar:FindFirstChild("CatchZone"); if not CatchZone then MyVariables.State = "WaitBobber"; return end
  local FishIcon = FishingBar:FindFirstChild("FishIcon"); if not FishIcon then MyVariables.State = "WaitBobber"; return end


  while true do
    if not FishOsScreenGui:FindFirstChild("MinigameOverlay") then MyVariables.State = "WaitBobber"; return end

    if CatchZone.AbsolutePosition.Y - FishIcon.AbsolutePosition.Y > 0 then
      mouse1press()
      task.wait(0.1)
      mouse1release()
    elseif CatchZone.AbsolutePosition.Y - FishIcon.AbsolutePosition.Y < 0 then
      task.wait(0.1)
    end
    task.wait()
  end
  MyFunctions.DebugPrint("debug", "Fish caught!")
  MyVariables.State = "WaitBobber"
  return
end

MyFunctions.Run = function()
    local State = MyVariables.State
    
    if State == "WaitBobber" then
        local Bobber = DesktopBtn:FindFirstChild("Bobber")
        if Bobber then
            MyVariables.State = "FoundBobber"
        else
            MyFunctions.AutoFish() 
        end
        
    elseif State == "FoundBobber" then
        MyFunctions.ClickBobber()
        
    elseif State == "Minigame" then
        MyFunctions.AutoMinigame()
    end
end
--#endregion -- End of "MyFunctions"



task.spawn(function()
  while true do
    MyFunctions.Run()
    task.wait()
  end
end)
