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
	var placementCollision:Area = $PlacementCollision
	
	if(placementCollision == null):
		return true
	
	var bodiesArray = placementCollision.get_overlapping_bodies()
	var thisID = get_instance_id()
	
	for body in bodiesArray:
		# we need to get the parent scene's data
		var bodyID = body.get_parent().get_instance_id()
		var realBody = body.get_parent() 
		
		if("type" in realBody && realBody.type == "Ship"):
			# if the colliding object is a ship, we want to ignore it
			# print("Ship collision detected, ignoring - not that it seems to be happeneing")
			# Ship collision should be ignored
			continue
		elif(bodyID != thisID):
			# if the collision object's ID is different from this ID, 
#			print("colliding with a body")
#			print(realBody)
			# this object is intersecting with something other than the ship and itself
			return false
			
	# placement is valid
	return true 
	
# If the placement is valid, this will show a green outline, else red 
func DisplayValidPlacement(canPlace: bool):
	pass
