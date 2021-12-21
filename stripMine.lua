if not turtle then
  printError("Requires a Turtle")
  return
end

local torchSlot = 16
local fillerSlot = 1


local tArgs = { ... }
if #tArgs ~= 1 then
  local programName = arg[0] or fs.getName(shell.getRunningProgram())
  print("Usage: " .. programName .. " <length>")
  return
end

-- Mine in a quarry pattern until we hit something we can't dig
local length = tonumber(tArgs[1])
if length < 1 then
  print("Tunnel length must be positive")
  return
end
local collected = 0

local function collect()
  collected = collected + 1
  if math.fmod(collected, 25) == 0 then
    print("Mined " .. collected .. " items.")
  end
end

local function tryDig()
  while turtle.detect() do
    if turtle.dig() then
      collect()
      sleep(0.5)
    else
      return false
    end
  end
  return true
end

local function tryDigUp()
  while turtle.detectUp() do
    if turtle.digUp() then
      collect()
      sleep(0.5)
    else
      return false
    end
  end
  return true
end

local function tryDigDown()
  while turtle.detectDown() do
    if turtle.digDown() then
      collect()
      sleep(0.5)
    else
      return false
    end
  end
  return true
end

local function refuel()
  local fuelLevel = turtle.getFuelLevel()
  if fuelLevel == "unlimited" or fuelLevel > 0 then
    return
  end

  local function tryRefuel()
    for n = 1, 16 do
      if turtle.getItemCount(n) > 0 then
        turtle.select(n)
        if turtle.refuel(1) then
          turtle.select(1)
          return true
        end
      end
    end
    turtle.select(1)
    return false
  end

  if not tryRefuel() then
    print("Add more fuel to continue.")
    while not tryRefuel() do
      os.pullEvent("turtle_inventory")
    end
    print("Resuming Tunnel.")
  end
end

local function tryUp()
  refuel()
  while not turtle.up() do
    if turtle.detectUp() then
      if not tryDigUp() then
        return false
      end
    elseif turtle.attackUp() then
      collect()
    else
      sleep(0.5)
    end
  end
  return true
end

local function tryDown()
  refuel()
  while not turtle.down() do
    if turtle.detectDown() then
      if not tryDigDown() then
        return false
      end
    elseif turtle.attackDown() then
      collect()
    else
      sleep(0.5)
    end
  end
  return true
end

local function tryForward()
  refuel()
  while not turtle.forward() do
    if turtle.detect() then
      if not tryDig() then
        return false
      end
    elseif turtle.attack() then
      collect()
    else
      sleep(0.5)
    end
  end
  return true
end

-- 
local function placeTorch()
  local previousSlot = turtle.getSelectedSlot()
  turtle.turnRight()
  turtle.select(torchSlot)
  turtle.placeUp()
  turtle.turnLeft()
  turtle.select(previousSlot)
end

-- Torch every 13 steps
local function digTunnel(tunnelLength)
  for n = 1, tunnelLength do
    turtle.select(fillerSlot)
    turtle.placeDown()
    tryDigUp()
    if n%11==0 then placeTorch() end

    if n < tunnelLength then
      print("Diggin iteration " .. n .. " out of " .. tunnelLength)
      tryDig()
      if not tryForward() then
        print("Aborting Tunnel.")
        break
      end
    else
      print("Tunnel complete.")
    end
  end  
end


local function main()
  print("Tunnelling...")

  -- Do the first part
  digTunnel(length)
  turtle.turnLeft()
  tryForward()
  tryForward()
  placeTorch()
  tryForward()
  tryForward()
  turtle.turnLeft()
  digTunnel(length)
  print("Tunnel complete.")
  print("Mined " .. collected .. " items total.")
  
end


main()