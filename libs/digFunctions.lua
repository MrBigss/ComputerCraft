-- 
-- These are mostly basic function taken from CC Tweaked scripts, with some more stuff added.
-- 
if not turtle then error("Requires a Turtle") end



-- ----------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------
function tryDig()
  while turtle.detect() do
    if turtle.dig() then sleep(0.5) else return false end
  end
  return true
end


-- ----------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------
function tryDigUp()
  while turtle.detectUp() do
    if turtle.digUp() then sleep(0.5) else return false end
  end
  return true
end


-- ----------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------
function tryDigDown()
  while turtle.detectDown() do
    if turtle.digDown() then sleep(0.5) else return false end
  end
  return true
end


-- ----------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------
function refuel()
  fuelLevel = turtle.getFuelLevel()
  if fuelLevel == "unlimited" or fuelLevel > 0 then
    return
  end

  function tryRefuel()
    for n = 6, 16 do -- Don't burn chests, application specific.
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
    print("Resuming.")
  end
end



-- ----------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------
function tryUp()
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


-- ----------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------
function tryDown()
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


-- ----------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------
function tryForward()
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


-- ----------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------
function clearLeft()
  wReturn = false
  turtle.turnLeft()
  wReturn = tryDig()
  turtle.turnRight()
  return wReturn
end


-- ----------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------
function clearRight()
  wReturn = false
  turtle.turnRight()
  wReturn = tryDig()
  turtle.turnLeft()
  return wReturn
end


-- ----------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------------------------------
function clearSides()
  clearLeft()
  clearRight()
end


-- ----------------------------------------------------------------------------------------------------
-- Dig a 3 wide column down. Assumes it's at the top, middle, facing 'forward'.
-- Going down prevents problems with falling blocks. 1 would only clear the sides.
-- 2 makes it 2 tall, counting where the turtle starts as layer 1
-- Doesn't come back, not auto managed.
-- ----------------------------------------------------------------------------------------------------
function dig3WideColumn(height)
  --We are at top, in the middle.
  clearSides()
  for i = 2, height do -- start at 2 because turtle starts on layer 1
    tryDown()
    clearSides()
  end
end









































