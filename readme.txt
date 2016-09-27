Thank you for purchasing VendR!

please report any issues you might have in the form of a support ticket. if your problem is the result of a configuration
issue, please locate the data folder for the map you are experiencing errors on in the data/vend_data/ folder. Deleting
these folders will remove all vending machines on the map and reset the addon.

These vending machine entities allow you to place several vending machines acrossed the map, with different items for sale
as well as persiting machines on a per map basis

-=SETTING UP THE VENDING MACHINES=-
To see an example, move the data folder to your base gmod directory
and load gm_construct, there will be a vending machine near spawn.

to set up vending machines, you MUST be an owner/superadmin rank
Locate the entity in the entities tab, under VendR, spawn it and you will see a red '-configure-' button on the display

The window you should see pop up should be called 'Vending Machine Configuration Editor' with 3 buttons, and a list box

To change the name of this vending machine, and set its persistance, click 'Settings'
Click 'name: default', this will display a text box, change the name of the vending machine and hit enter.
ALL vending machines must have a unique name, as this is how they are identified in the database.
you can also change the text that appears at the top of the screen, as well as change the colors.

When you are happy with these settings, hit the 'Persist on Reboot' button. This will write your settings to the vending
machine and save it to the server. it will respawn where you originally had it on server reboot until it is disabled.

Hit the settings button again to refresh the menu, you will see 'Persist on Reboot' has changed to 'Disable Persistance'
as well as a new button labeled 'Sync Changes To Server'. This button must be clicked when you wish to update the server
with your changes, and distribute the changes to all other clients

Now we will go over creating categories for items. To create a new category, click the 'new' button in the configuration
editor, this will display a text box where you can enter a name for the category. Hit enter when you are finished

you will see a new entry in the list box below, with the category name, and the number of items. Click on the category
and you will see a new menu displayed on the right. you can change the name by clicking on CatName, change the color
of the category, clear the category of items (this will remove everything in that category) and finally, Create new items.

Click on the 'Create New Item' button, you will see a new entry appear below with several fields. you can click on these
to edit the properies (such as price). the buttons on the upper left can be used to delete the entry, and move it up and
down the list to re-organize entries.

For this example we will create a basic pistol entry.
Click on the name and type 'Pistol', then hit your enter key
ClassID is the class name of the entity we will be spawning, for the pistol we will change ClassID to weapon_pistol
The description is a string of text that appears under the item in the menu, change it to 'Pew Pew'
Price should be pretty obvious, change this to the price you want the item to be (numbers only)

CLua is a feature intended for developers only, to create advanced functionality, allowing you to write lua scripts in game
that will be called when someone buys the item. more information can be found in using_lua_and_vshare.txt

once you are happy with your changes, simply return to the settings menu and sync your changes!