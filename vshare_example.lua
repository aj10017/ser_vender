

/* this is an example of using VSHARE in the in-game lua editor for vending machines. This is not a functional script, only an example.
the following code will show you how to set the owner of an entity to be the player who purchased it (using CPPI)
*/
if IsValid(VSHARE.item) then
VSHARE.item:CPPISetOwner(VSHARE.ply)
print("set owner of entity to "..VSHARE.ply:Nick())
end
return

/* something a little more complex might be restricting players from purchasing items if they are the incorrect rank if you have ULX this is pretty straight forward. */
local ply = VSHARE.ply -- we are making a local reference to save keystrokes.
local group = ply:GetUserGroup() -- get the name of the user group (rank)
if group ~= "VIP" then ply:addMoney(VSHARE.item.Price) return false else return end -- if the player is not the VIP rank, refund the purchase and disallow them from spawning the item, else let them purchase it
