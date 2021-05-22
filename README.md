# NoiseWorldGen2D - Customized Godot Tilemap ![Godot v3.2](https://img.shields.io/badge/Godot-v3.2-%23478cbf?logo=godot-engine&logoColor=white) ![Godot v3.3](https://img.shields.io/badge/Godot-v3.3-%23478cbf?logo=godot-engine&logoColor=white)
![Pic]()

## Made for:
#### [CS50](https://www.edx.org/course/introduction-computer-science-harvardx-cs50x)

## Installation:
Copy the addons folder to your project and instance the NoiseWorldGen2D Node. Made for 2D. Change the exported variables to customize.

## Personalizing:
![Terrains](.//addons/NoiseWorldGen2D/assets/Terrains.png)
Included are 24 tiles that make up the world. For simplicity, you may replace "Terrains.png" with different tiles. If you change the size of the tiles, or add new tiles you will need to redefine the atlas. Adding new world types can be done by editing the "NoiseWorldGen2D.gd"'s ```genWorld()``` function. The section - ```elif type == "hellplanet":``` is where custom planet types are meant to go. Reference ```if type == "overworld":``` for example on how to build and read below for more context!