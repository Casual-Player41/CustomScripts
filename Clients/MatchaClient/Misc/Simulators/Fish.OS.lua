--[[ information:
  * Game name: Fish.OS
  * Game Id: 9844978459
  * Game UniverseId: 9844978459
  * Game link: https://www.roblox.com/games/123368132872113/FISH-OS-IDLE-FISHING-SIMULATOR

  * Script version: 1.0.0
]]

if tonumber(game.GameId) ~= 944978459 then
  error("This script is only for Fish.OS! Game link: https://www.roblox.com/games/123368132872113/FISH-OS-IDLE-FISHING-SIMULATOR")
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui"); if not PlayerGui then error("No playergui?"); return end

local FishOsScreenGui = PlayerGui:FindFirstChild("FishOS"); if not FishOsScreenGui then error("No Fish Os?"); return end
local DesktopBtn = FishOsScreenGui:FindFirstChild("Desktop"); if not DesktopBtn then error("No desktop button?"); return end


local Variables = {
  DebugMode = true,
  ScriptTitle = "Kitty - Fish OS",

  State = "WaitBobber", -- MinigaMme, FoundBobber, ClickBobber, WaitBobber
  FarmPos = Vector2.new(0, 440),
  Autofarm = false,
}



--#region -- Start of "MyFunctions"
local MyFunctions = {}

MyFunctions.DebugPrint = function(Type: string, ...)
  if not Variables.DebugMode then return end

  local args = { ... }
  local message = table.concat(args, " ")

  local t = os.date("*t")
  local timeStr = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)

  Type = string.lower(Type)

  if Type == "print" then
    print(string.format("[ %s ] (%s): %s", Variables.ScriptTitle, timeStr, message))

  elseif Type == "warn" then
    warn(string.format("[ %s ] (%s): %s", Variables.ScriptTitle, timeStr, message))

  elseif Type == "debug" then
    print(string.format("[ %s ] [DEBUG] (%s): %s", Variables.ScriptTitle, timeStr, message))

  elseif Type == "info" then
    print(string.format("[ %s ] (%s): %s", Variables.ScriptTitle, timeStr, message))

  else
    print(string.format("[ %s ] (%s): %s", Variables.ScriptTitle, timeStr, message))
  end
end



MyFunctions.AutoFish = function()
  if Variables.State ~= "WaitBobber" then return end

  local Mouse = LocalPlayer:GetMouse()
  if Mouse.X ~= Variables.FarmPos.X or Mouse.Y ~= Variables.FarmPos.Y then
    mousemoveabs(Variables.FarmPos.X, Variables.FarmPos.Y)
    task.wait(0.08)
    mouse1click()
  else
    mouse1click()
  end
end

MyFunctions.WaitForBobber = function()
  if Variables.State ~= "WaitBobber" then return end
  local Bobber = DesktopBtn:FindFirstChild("Bobber"); if not Bobber then return end


  if Bobber then
    MyFunctions.DebugPrint("debug", "Bobber detected")
    Variables.State = "FoundBobber"
  end
end

MyFunctions.ClickBobber = function()
  if Variables.State ~= "FoundBobber" then return end

  local startTime = os.clock()
    
  repeat
    local Bobber = DesktopBtn:FindFirstChild("Bobber")
        
    if not Bobber then break end 

    local x = Bobber.AbsolutePosition.X + (Bobber.AbsoluteSize.X / 2)
    local y = Bobber.AbsolutePosition.Y + (Bobber.AbsoluteSize.Y / 2)

    mousemoveabs(x, y)
    mouse1click()
        
    task.wait(0.05)
        
    if os.clock() - startTime > 5 then 
      Variables.State = "WaitBobber"
      return 
    end

  until FishOsScreenGui:FindFirstChild("MinigameOverlay")

  MyFunctions.DebugPrint("debug", "Clicked bobber.")
  Variables.State = "Minigame"
end


MyFunctions.AutoMinigame = function()
	if Variables.State ~= "Minigame" then return end

	local MinigameOverlay = FishOsScreenGui:FindFirstChild("MinigameOverlay")
	if not MinigameOverlay then Variables.State = "WaitBobber"; return end
	
	local BarOuter = MinigameOverlay:FindFirstChild("BarOuter")
	local FishingBar = BarOuter and BarOuter:FindFirstChild("FishingBar")
	local CatchZone = FishingBar and FishingBar:FindFirstChild("CatchZone")
	local FishIcon = FishingBar and FishingBar:FindFirstChild("FishIcon")

	if not (BarOuter or FishingBar or CatchZone or FishIcon) then
		Variables.State = "WaitBobber"
		return
	end

	local Holding = false

	while Variables.State == "Minigame" do
		if not FishOsScreenGui:FindFirstChild("MinigameOverlay") then
			Variables.State = "WaitBobber"
			break
		end

		local diff = CatchZone.AbsolutePosition.Y - FishIcon.AbsolutePosition.Y

		if math.abs(diff) < 5 then
			if Holding then
				mouse1release()
				Holding = false
			end

		elseif diff > 0 then
			if not Holding then
				mouse1press()
				Holding = true
			end

		else
			if Holding then
				mouse1release()
				Holding = false
			end
		end

		task.wait()
	end

	if Holding then
		mouse1release()
	end

	Variables.State = "WaitBobber"
end


--#endregion -- End of "MyFunctions"

MyFunctions.Run = function()
  local State = Variables.State
    
  if State == "WaitBobber" then
    local Bobber = DesktopBtn:FindFirstChild("Bobber")
    if Bobber then
      Variables.State = "FoundBobber"
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
