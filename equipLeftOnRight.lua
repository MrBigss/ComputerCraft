-- Take whatever is on the left hand, and put it on the right hand.
-- Say no to lefty turtle. (Can't see well in inventory.)

-- Find and empty slot
-- Try unequip from right (just to make sure)
-- Find a new empty slot
-- Unequip from left
-- Equip on right

function selectEmptyInventory()
  local emptySlot = nil
  for i=1,16 do
    if turtle.getItemCount(i) == 0 then
      emptySlot = i
    end
  end
  if not emptySlot then error("No empty slot, cannot proceede, abort") end
  turtle.select(emptySlot)
end

selectEmptyInventory()
turtle.equipRight() -- Remove from right, if there's something.
-- Find another empty slot, to not equip whatever we unequiped.
selectEmptyInventory()
assert(turtle.equipLeft(), "Problem, could not unequip whatever is on the left side.")
assert(turtle.equipRight(), "Problem, could not re-equip tool on the right.")
