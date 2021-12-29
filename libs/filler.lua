-- Filling functions
-- This defines a set of slots to be used for filler, and functions to use them.
-- Basically, makes sure it's a bunch of filling material, and how to use them, without emptying the slots.

-- Check prerequisites for module.
if not turtle then error("Filler module requires a Turtle") end

if not gFillerSlots then
  error("The filler module requires an array (gFillerSlots) with slots to be used as filler slots")
end

local mFillerSlots = {}


for key, slot in ipairs(gFillerSlots) do
  mFillerSlots[key] = tonumber(slot)
  if not mFillerSlots[key] then error("This is not a slot number {" .. slot .. "}") end
  if (mFillerSlots[key]<1 or mFillerSlots[key]>16) then error("Slot number must be 1 to 16, what is this? {" .. slot .. "}") end
end


filler = filler or {} -- filler 'namespace'.

-- ----------------------------------------------------------------------------------------------------
-- Returns true if all slots are completely full.
-- ----------------------------------------------------------------------------------------------------
function filler.checkAllFillerSlotsFull()
  for _, slot in ipairs(mFillerSlots) do
    if turtle.getItemSpace(slot) > 1 then
      return false -- Some slots not full.
    end
  end
  return true -- All filler slots are full.
end


-- ----------------------------------------------------------------------------------------------------
-- Selects a non empty (>1) item filler slot.
-- returns true if ok. Returns false if all slot are at 1 item.
-- ----------------------------------------------------------------------------------------------------
function filler.selectNonEmptyFillerSlot()
  for _, slot in ipairs(mFillerSlots) do
    if turtle.getItemCount(slot) > 1 then
      turtle.select(slot)
      return true
    end
  end
  return false
end


-- ----------------------------------------------------------------------------------------------------
-- Wait until all filler slots are filled before continuing.
-- ----------------------------------------------------------------------------------------------------
function filler.waitForAllFillerSlotsToBeFull()
  local wFilled = false
  if not filler.checkAllFillerSlotsFull() then
    print("Not all filler slots are full.")
    print("Fill all slots to continue.")
    while not filler.checkAllFillerSlotsFull() do
      os.pullEvent("turtle_inventory")
    end
  end
end

-- ----------------------------------------------------------------------------------------------------
-- Just do everything to get a filling material.
-- ----------------------------------------------------------------------------------------------------
function filler.getFillerMaterialReady()
  while not filler.selectNonEmptyFillerSlot() do
    filler.waitForAllFillerSlotsToBeFull()  --This sleeps
  end
end


-- ----------------------------------------------------------------------------------------------------
-- Place a filler block up. Hopefully, the person using this has dug the block up first.
-- ----------------------------------------------------------------------------------------------------
function filler.fillUp()
  filler.getFillerMaterialReady()
  return turtle.placeUp()
end


-- ----------------------------------------------------------------------------------------------------
-- Place a filler block down. Hopefully, the person using this has dug the block down first.
-- ----------------------------------------------------------------------------------------------------
function filler.fillDown()
  filler.getFillerMaterialReady()
  return turtle.placeDown()
end

  
-- ----------------------------------------------------------------------------------------------------
-- Place a filler block in front.  Hopefully, the person using this has dug the block in front first.
-- ----------------------------------------------------------------------------------------------------
function filler.fillFront()
  filler.getFillerMaterialReady()
  return turtle.place()
end


-- ----------------------------------------------------------------------------------------------------
-- Check if everything is in place before starting up. If not, wait everything is fixed.
-- ----------------------------------------------------------------------------------------------------
function filler.checkPrerequisites()
  print("Checking filler manager pre-requisites")
  -- Check filler slots are full. Wait if they are not.
  if not filler.checkAllFillerSlotsFull() then
    filler.waitForAllFillerSlotsToBeFull()  --This sleeps
  end
end
