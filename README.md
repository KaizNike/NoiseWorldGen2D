# NoiseWorldGen2D - Godot Tilemap Tool (4.4.1)
![Banner Worldgen W/ an Eevee](.//worldgenbanner2.png)

## Made for:
#### [CS50](https://www.edx.org/course/introduction-computer-science-harvardx-cs50x)

## Credits:
### [Grayscale Eevee](https://twitter.com/koriArredondo/status/1449412238385762309)
[@koriArredondo](https://twitter.com/koriArredondo)

### Westeros Heightmap
[Tophloaf](https://forums.nexusmods.com/index.php?/topic/464977-the-westeros-project/page-7)

### Shefalitayal
Kudos to whoever made it!

## Installation:
Copy the addons folder to your project and instance the NoiseWorldGen2D Node. Made for 2D. Change the exported variables to customize.

## Personalizing:
![Terrains](.//addons/NoiseWorldGen2D/assets/Terrains.png)
Included are 24 tiles that make up the world. For simplicity, you may replace "Terrains.png" with different tiles. If you change the size of the tiles, or add new tiles you will need to redefine the atlas. Adding new world types can be done by editing the "NoiseWorldGen2D.gd"'s ```genWorld()``` function. The section - ```elif type == "hellplanet":``` is where custom planet types are meant to go. Reference ```if type == "overworld":``` for example on how to build.

## Updates (7/4/2025):
Now for Godot 4.4.1! (To support a new game I'm working on.)