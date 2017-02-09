# DeconstructNearbyLoot
This is a mod for Factorio that automatically marks loot in logistic construction range of the player for deconstruction.

Loot in this context means items that would be picked up by the players automatically when walking over them - in Vanilla game, this is Alien artifacts and rocks broken into stone resources. Additionally, items laid directly onto the ground (not on transport belts) by inserters are marked as well.

To effectively use this mod, have some personal roboport in your armor and a few construction bots in inventory, then you can just walk around and have the bots collect loot around yourself.

# Notes
If you used the old versions without GUI, you may need to execute the following console command to enable the GUI in your savegame:
```
/c remote.call("DeconstructNearbyLoot", "updateGui", game.player)
```
