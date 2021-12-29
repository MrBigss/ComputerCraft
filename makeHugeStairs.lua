gFillerSlots    = {1,2,3,4}
gChestSlots     = {5}
gStairSlots     = {6,7,8}
gInventorySlots = {9,10,11,12,13,14,15,16}

require "libs.filler"
require "libs.inventorymanager"
require "libs.digFunctions"


filler.checkPrerequisites()
inventorymanager.checkPrerequisites()
if turtle.getFuelLevel() < 2000 then error("Not enough fuel, need about XXXX fuel") end
print("Ok, everything seems to be in order")


-- ----------------------------------------------------------------------------------------------------
-- Make a 3 wide roof with filler material. Assumes everything has already been cleared on both sides.
-- ----------------------------------------------------------------------------------------------------
function makeRoof3Wide()
  tryDigUp()
  filler.fillUp()
  
  turtle.turnLeft()
  tryForward()
  tryDigUp()
  filler.fillUp()
  
  turtle.turnLeft() turtle.turnLeft()
  tryForward()
  tryForward()
  tryDigUp()
  filler.fillUp()

  turtle.turnLeft() turtle.turnLeft()
  tryForward()
  turtle.turnRight()
end

-- ----------------------------------------------------------------------------------------------------
-- Make a 3 wide floor with filler material. Assumes everything has already been cleared on both sides.
-- ----------------------------------------------------------------------------------------------------
function makeFloor3Wide()
  tryDigDown()
  filler.fillDown()
  
  turtle.turnLeft()
  tryForward()
  tryDigDown()
  filler.fillDown()
  
  turtle.turnLeft() turtle.turnLeft()
  tryForward()
  tryForward()
  tryDigDown()
  filler.fillDown()

  turtle.turnLeft() turtle.turnLeft()
  tryForward()
  turtle.turnRight()
end


-- ----------------------------------------------------------------------------------------------------
-- Place Stairs underneath turtle. Make sure it's facing the right way before doing this.
-- Stairs will all be looking the same direction.
-- The "right" direction seems to be facing "upwards" to the stairs.
-- Only works correctly if there it a block underneath the stairs to be placed, otherwise stairs placed
-- "on top" and will be inverted.
-- ----------------------------------------------------------------------------------------------------
function placeStairs3Wide()
  placeStairsUnder()
  turtle.turnLeft() tryForward() turtle.turnRight()
  placeStairsUnder()
  turtle.turnRight() tryForward() tryForward() turtle.turnLeft()
  placeStairsUnder()
  turtle.turnLeft() tryForward() turtle.turnRight()
end


-- ----------------------------------------------------------------------------------------------------
-- Dig a three wide tunnel, starting from the top, and going down. Also, place a roof, and a floor.
-- Assumes we are starting at the top, in the middle.
-- Final position is top of tunnel, at length.
-- ----------------------------------------------------------------------------------------------------
function dig3WideTunnel(length, height)
  dig3WideColumn(height)
  makeFloor3Wide()
  for h=2,height do tryUp() end
  makeRoof3Wide()
  inventorymanager.checkInventoryAndEmptyIfFull()
  
  -- Make all other
  for i = 2, length do
    tryForward()
    dig3WideColumn(height)
    makeFloor3Wide()
    for h=2,height do tryUp() end
    makeRoof3Wide()
    inventorymanager.checkInventoryAndEmptyIfFull()
  end
end


-- ----------------------------------------------------------------------------------------------------
-- Position and place the stairs, in the stair shaft.
-- ----------------------------------------------------------------------------------------------------
function makeStairsForStairs()
  tryUp()
  turtle.turnRight() turtle.turnRight()
  placeStairs3Wide()
  turtle.turnRight() turtle.turnRight()
end


-- ----------------------------------------------------------------------------------------------------
-- Dig a three wide stair, starting from the top, and going down. Also, place a roof, and a floor, and stairs.
-- Assumes we are starting at the top, in the middle.
-- This of course means it needs to be at least 3 high, ish.
-- ----------------------------------------------------------------------------------------------------
function dig3WideStair(length, height)
  if height < 3 then error("Yeah, bro, this won't work") end
  
  dig3WideColumn(height)
  makeFloor3Wide()
  makeStairsForStairs()
  for h=2,height do tryUp() end -- We actually want them "one higher" to work with a same height tunnel.
  makeRoof3Wide()
  inventorymanager.checkInventoryAndEmptyIfFull()
  
  -- Make all other
  for i = 2, length do
    tryDown() -- This makes the stairs "go down"
    tryDown() -- This makes the stairs "go down" (needed twice, because we are doing the stairs 1 more height)
    tryForward()
    dig3WideColumn(height)
    makeFloor3Wide()
    makeStairsForStairs()
    for h=2,height do tryUp() end  -- We actually want them "one higher" to work with a same height tunnel.
    makeRoof3Wide()
    inventorymanager.checkInventoryAndEmptyIfFull()
  end
end


-- ----------------------------------------------------------------------------------------------------
-- Make a segment of stairs with "landings" at the top and bottom.
-- Starting position is top middle of first landing, ending is top middle of bottom landing.
-- ----------------------------------------------------------------------------------------------------
function makeStairsWithLandings3Wide(landingLen, stairLen, height)
  if (height<3 or landingLen<1 or stairLen<1) then error("Yeah, bro, this won't work") end
  dig3WideTunnel(landingLen, height)
  tryDown()
  tryForward()
  dig3WideStair(stairLen, height)
  tryDown()
  tryForward()
  dig3WideTunnel(landingLen, height)
end


-- ----------------------------------------------------------------------------------------------------
-- Make a left turning corner, specifically for this application. Makes a "3x3 corner" when half
-- already inside it. Made to got at the end of "landing", from the end of landing position.
-- Yeah, it undos and redos the floor and ceiling after turning, yeah yeah, but way simpler like this.
-- ----------------------------------------------------------------------------------------------------
function make3WideLeftCorner(height)
  tryForward() -- Move from the landing into the corner.
  dig3WideTunnel(2, height)
  turtle.back()
  turtle.turnLeft()
  tryForward() -- Position at top of new landing.
  --dig3WideTunnel(1, height)
  --tryForward() -- Position at top of new landing.
end


-- ----------------------------------------------------------------------------------------------------
-- Make a landing, stairs down, a left corner, a landing, stairs down, a landing.
-- Starting at the position in front, on the ground, of where we want the landing to start.
-- ----------------------------------------------------------------------------------------------------
function make3WideStairsDownLeft(landingLen, stairLen, height)
  if (height<3 or landingLen<1 or stairLen<1) then error("Yeah, bro, this won't work") end

  --Position at top of first landing before doing it.
  for i=2,height do tryUp() end
  tryForward()
  --Make landing and stairs, and landing.
  makeStairsWithLandings3Wide(landingLen, stairLen, height)
  -- Make the left corner.
  make3WideLeftCorner(height)
  --Make landing and stairs, and landing
  makeStairsWithLandings3Wide(landingLen, stairLen, height)
  for i=2,height do tryDown() end
  --Go back to bottom of landing.
  
end


-- ----------------------------------------------------------------------------------------------------
-- void main void bro. everything is in a function at this point, ez.
-- ----------------------------------------------------------------------------------------------------
function main()
  -- Do some left turn stairs, parameters are landing length, stair length, and tunnel height.
  make3WideStairsDownLeft(2, 18, 5)
end


main()
