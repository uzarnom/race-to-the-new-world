extends "res://Scripts/Classes/Part.gd"

func _ready():
	itemImage = "res://assets/Ship Parts/Cargo/Crate.png"
	itemName = "Crate"
	folder = "res://assets/Ship Parts/Cargo/"
	fileName = "Crate.tscn"
	pass

func _process(delta: float):
	if(Input.is_action_just_pressed("testingTrigger")):
		print("New Trigger")
		ValidPlacement()

# **********************
# Placement and stuff variables
# **********************

# returns true if the object can be placed
func ValidPlacement() -> bool:
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
	print("Done")
	
	
# If the placement is valid, this will show a green outline, else red 
func DisplayValidPlacement(canPlace: bool):
	$Invalid.visible = !canPlace


# **********************
# Node Signals - Area Signals
# **********************
#func _on_PlacementCollision_body_entered(body: Node):
#	if(body.get(type) != null):
#		print("type found")
#		if(body.type =="Ship Part"):
##			collidedParts[body.get_instance_id()] = body
#			pass
#
#	pass # Replace with function body.
	

