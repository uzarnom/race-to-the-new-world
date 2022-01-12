extends "res://Scripts/Classes/Part.gd"

var Data = load("res://Scripts/Classes/Part.gd").new()

#Input Mode variables
var InputMode
var MainLevel

func _ready():
	itemImage = "res://assets/Ship Parts/Helms/helm.png"
	itemName = "Helm lvl 1"
	folder = "res://assets/Ship Parts/Helms/"
	fileName = "Helm_lvl_1.tscn"
	
	# Input Mode changes
	MainLevel = get_tree().get_root().get_node("Level")
	InputMode = MainLevel.InputMode

func _on_PlayerCollision_body_entered(body: Node):
	if(body.name == "Player"):
		body.enteredInteractable(self)

func _on_PlayerCollision_body_exited(body: Node):
	if(body.name == "Player"):
		body.exitedInteractable(self)

func interact(body:Node):
	
	MainLevel.changeInputMode(InputMode.ShipMode)
	return
	
	#Rename things to make it easier to udnerstand
	var Player = body
	var Ship = get_parent().get_parent()
	
	# disable player's inputs
	body.setInput(false)
	
	# enable ship's inputs
	Ship.setInput(true)
	
	# give ship the Player's object so it can pass things back
	Ship.Player = Player
	
	# Set the camera's position
	var Cam = Player.get_node("Camera_Point").get_node("Camera")
	
	# var toSetCameraTransform = get_parent().get_node("Camera_Point").transform
	# Cam.transform = toSetCameraTransform
	
	# Make Camera a child of the ship's camera point
	var oldParent = Cam.get_parent()
	oldParent.remove_child(Cam)
	Ship.get_node("Camera_Point").add_child(Cam)
	
#	print("New Cam Set")
	Cam.global_transform.origin = Ship.get_node("Camera_Point").global_transform.origin
#	print("Cam Pos " + str(Cam.global_transform.origin))
#	print("Old Cam Point " + str(oldParent.global_transform.origin))
#	print("New Cam Point " + str(Ship.get_node("Camera_Point").global_transform.origin))
	
#	buildable.global_transform.origin = castResult.get_collision_point()

# **********************
# Functions all ship parts will need
# **********************
# sets up the parts internal varaibles 
func ShipPartSetup():
	# place the ready function things here, will need to duplicate across all other ship parts
	pass
# returns whether the placement is valid or not
func ValidPlacement():
	return true
	
# If the placement is valid, this will show a green outline, else red 
#func DisplayValidPlacement():
#	pass
