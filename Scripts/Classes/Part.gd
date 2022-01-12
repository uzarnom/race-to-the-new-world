extends Spatial

class_name Part

var itemImage:String # fill including the trailing name "path/name.png"
var itemName:String # "name"
var folder:String #the folder with a trailing slash
var fileName:String # "name.tscn"

var description:String

var type:String = "Ship Part"
var hp:int = 1

var mass:float = 0
var lift:float = 0
var acceleration:float = 0
var friction:float = 0

# **********************
# Interactable systems and variables
# **********************
# For now, only if the functions exist, od things

# var power:int = 0 # for engines and certain things require power to function

# **********************
# Placement and stuff variables
# **********************

# returns whether the placement is valid or not
func ValidPlacement():
	return true
	
# If the placement is valid, this will show a green outline, else red 
func DisplayValidPlacement(canPlace: bool):
	pass
