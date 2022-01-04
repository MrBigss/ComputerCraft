--
-- Make huge shaft.
-- This is made to be used by an automated system.
-- Not ran by hand.
-- Version 2. Goes from top to bottom to fix a bug
-- were gravel on top of top block would fall in the
-- shaft when it got removed.
-- 

-- Adding parameter for length
local tArgs = { ... }
if #tArgs ~= 1 then
	local programName = arg[0] or fs.getName(shell.getRunningProgram())
	print("Usage: " .. programName .. " <length>")
	return
end

local length = tonumber(tArgs[1])
if length < 1 then
  error("Length must be more than 0")
end

-- ==================================================
-- Function : general wait sleep
-- ==================================================
local function wait()
  os.sleep(0.25)
end

-- ==================================================
-- Function : wait gravel fall inteval
-- ==================================================
local function waitGravel()
  os.sleep(0.5)
end

-- ==================================================
-- Dig everything in front, and redo it if gravel/sand
-- falls down into the spot.
-- ==================================================
local function clearFront()
  while turtle.detect() do
    turtle.dig()
    waitGravel()
  end
end

-- ==================================================
-- Dig everything up, and redo it if gravel/sand
-- falls down into the spot.
-- ==================================================
local function clearUp()
  while turtle.detectUp() do
    turtle.digUp()
    waitGravel()
  end
end

-- ==================================================
-- Couldn't see why it would be needed, but for completeness.
-- ==================================================
local function clearDown()
  while turtle.detectDown() do
    turtle.digDown()
    waitGravel()
  end
end

-- ==================================================
-- Dig one 3x3 area. Repeat this to get a tunnel.
-- Requires 5 fuel.
-- From top to bottom.
-- ==================================================
local function digStep()
  clearFront() turtle.forward() wait()
  turtle.turnLeft() clearFront() turtle.turnRight() turtle.turnRight() clearFront() turtle.turnLeft()
  clearDown() turtle.down() wait()
  turtle.turnLeft() clearFront() turtle.turnRight() turtle.turnRight() clearFront() turtle.turnLeft()
  clearDown() turtle.down() wait()
  turtle.turnLeft() clearFront() turtle.turnRight() turtle.turnRight() clearFront() turtle.turnLeft()
  turtle.up() wait() turtle.up() wait()
end

-- ==================================================
-- Make a tunnel
-- Requires 6*iLen fuel.
-- ==================================================
local function makeTunnel(iLen)
  iLen = tonumber(iLen)
  if iLen == nil then iLen = 1 end
  
  -- Position at top of tunel.
  clearUp() turtle.up() wait()
  clearUp() turtle.up() wait()
  
  -- Dig a long tunnel.
  for i=1,iLen do
    digStep()
  end
  -- Back up.
  for i=1,iLen do
    turtle.back() wait()
  end
  --Position at start.
  turtle.down() wait()
  turtle.down() wait()
end

-- ==================================================
-- This kills the server.
-- ==================================================
local function main()
  if(os.getComputerLabel() == nil) or os.getComputerLabel() == "" then print("Put a label on your computer, fool!") return end
  term.clear() term.setCursorPos(1,1)
  print(os.getComputerLabel() .. " starting up")
  --Fuel usage, 10+ length*8
  local requiredFuel = (length*8)+10
  if turtle.getFuelLevel() < requiredFuel  then print("[FAIL] Fuel less than " .. requiredFuel ) return end
  print("[ OK ] Fuel level " .. turtle.getFuelLevel())
  print("Making a " .. length .. " long shaft")
  makeTunnel(length) -- Requires 192 fuel
  print("Done making shaft")
  print("Now idle")
end

--Run it!
main()
