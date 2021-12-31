extends KinematicBody

# Player Movement Varibales  
export var speed = 15
export var gravity = 20
export var jumpforce = 10
var acceleration = 5

# camera variables
var cam_accel = 40
var mouse_sense = 0.1
var snap
var cam_offset

# ???
var angular_velocity = 30

# actual movement variables
var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var lastFramesVel:Vector3 = Vector3()

# get children
onready var camera_point = $Camera_Point

# other variables
var capturingMouse = true

# Node which we may interact with
var interactable:Node = null

# Input Mode variables
var MainLevel:Node
var InputMode # {PlayerMode, BuildMode, ShipMode} # get from parent "Level"
var isCapturingInput:bool = true
var currentInputMode

# Build Mode Variables
var buildable:Node = null
var buildableToInstance = null
var buildMenu:Node = null


# enum testing - keep for reference
# enum testEnum {One, Two}
#		print(typeof(testEnum)) -- from inside the function
#		print(0 in testEnum.values())
#		print(testEnum.One == 0)

# Test Variables remove after
#var printDelta = 0

func _ready():
	# setup Input
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# seetup camera
	$Camera_Point/Camera.current = true
	
	# InputMode setups
	MainLevel = get_parent()
	InputMode = MainLevel.InputMode
	currentInputMode = MainLevel.currentInputMode
	
	MainLevel.trackInputMode(self)
	
	# Find the build menu
	buildMenu = get_parent().get_node("BuildMenu")
	if(buildMenu == null):
		print("Error, BuilMenu is null")
	
# Handles the mouse rotations, needs some work
func _input(event):
	if(isCapturingInput):
		if(event is InputEventMouseMotion && capturingMouse ):
			rotate_y(deg2rad(-event.relative.x * mouse_sense))
			camera_point.rotate_z(deg2rad(event.relative.y * mouse_sense))
			camera_point.rotation.x = clamp(camera_point.rotation.x, deg2rad(-80), deg2rad(30))
		else:
			return
		
func _physics_process(delta: float):
	# Escape mouse capture - hould always be enabled
	if(Input.is_action_just_pressed("ui_cancel")):
		flipMouseCapture()
		
	direction = Vector3.ZERO
	
	# **********************
	# Movement - direction, gravity, and jump applied
	# **********************
	if(isCapturingInput):
		if(Input.is_action_pressed("forward")):
			# print("moving forwards")
			direction -= transform.basis.x
		if(Input.is_action_pressed("backward")):
			# print("moving backward")
			direction += transform.basis.x
		if(Input.is_action_pressed("leftward")):
			# print("moving leftward")
			direction += transform.basis.z
		if(Input.is_action_pressed("rightward")):
			# print("moving rightward")
			direction -= transform.basis.z
		
	# Apply Gravity, check for jump and if on floor
	var snapDist = 100
	snap = Vector3.DOWN * snapDist#if is_on_floor() else Vector3.ZERO
	
	if(!is_on_floor()): #if not on floor apply gravity, disable snapping
		gravity_vec += Vector3.DOWN * gravity * delta
		snap = Vector3.ZERO
	else: # Player is on floor, turn off gavity
		gravity_vec = Vector3.ZERO
		snap = Vector3.DOWN * snapDist
	if(Input.is_action_pressed("jump") and is_on_floor()):
		gravity_vec = Vector3.UP * jumpforce
		snap = Vector3.ZERO
#	else:
#		snap = Vector3.DOWN 
		
	# Get direction and apply the inputs to its urrently facing position
	direction = direction.normalized()
	velocity = direction * speed
	#velocity.linear_interpolate(velocity, acceleration * delta)
	velocity = velocity + gravity_vec
	#move_and_slide(velocity, Vector3.UP) # Old Movement 
	#var snap = Vector3.DOWN if is_on_floor() else Vector3.ZERO
	velocity += lastFramesVel
	lastFramesVel = move_and_slide_with_snap(velocity, snap, Vector3.UP) # Stick to moving platform
	lastFramesVel -= velocity
	
#	printDelta += delta
#	if(printDelta >= 1):
#		print("Still Moving and Sliding: " + str(lastFramesVel))
#		print("Is On Floor: " + str(is_on_floor()))
#		print("Snap: " + str(snap))
#		printDelta = 0
	
	# **********************
	# Interactions system
	# **********************
	# Interact with the last interactable object that was entered
	if(Input.is_action_just_pressed("interact") && isCapturingInput):
		print("WARNING FROM SELF: Should check if the item is interactable and only store it if it is interactable")
		if(interactable == null):
			return
		interactable.interact(self)
		
	# **********************
	# Testing Function
	# **********************
#	if(Input.is_action_just_pressed("testingTrigger")):
#		var castResult = castRayFromCamera()
#		print(castResult.get_collider())
#		print("Collision Point " + str(castResult.get_collision_point()))
#		print("Collision Normals " + str(castResult.get_collision_normal()))
#
#		if(buildable != null):
#			print("Translation: " + str(buildable.translation))

	# Build Menu Things - will need to do this later
	# **********************
	# Build Menu Functions
	# **********************
	if(currentInputMode == InputMode.BuildMode):
		var tempBuildable:PackedScene = null
		if(Input.is_action_just_pressed("builditem1")):
			print("Send Signal build Item 1 to player?")
			tempBuildable = buildMenu.receiveInput(1)
		if(Input.is_action_just_pressed("builditem2")):
			print("Send Signal build Item 2 to player?")
			tempBuildable = buildMenu.receiveInput(2)
		if(Input.is_action_just_pressed("builditem3")):
			print("Send Signal build Item 3 to player?")
			tempBuildable = buildMenu.receiveInput(3)
		if(Input.is_action_just_pressed("builditem4")):
			tempBuildable = buildMenu.receiveInput(4)
		if(Input.is_action_just_pressed("builditem5")):
			tempBuildable = buildMenu.receiveInput(5)
		if(Input.is_action_just_pressed("builditem6")):
			tempBuildable = buildMenu.receiveInput(6)
		if(Input.is_action_just_pressed("builditem7")):
			tempBuildable = buildMenu.receiveInput(7)
		if(Input.is_action_just_pressed("builditem8")):
			tempBuildable = buildMenu.receiveInput(8)
			
		if(tempBuildable != null):
			if(buildable != null):
				buildable.queue_free()
			buildable = tempBuildable.instance()
			buildableToInstance = tempBuildable
			add_child(buildable)
			
		# If there is a selected buildable, show it at the correect position
		if(buildable != null):
			showBuildable()
	elif (buildable != null):
		buildable.queue_free()
		buildable = null
		
			
			# Another if statement for placement trigger
	

func flipMouseCapture():
	if(capturingMouse):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	capturingMouse = !capturingMouse

# Attempting interaction system
func enteredInteractable(interactableEventObject: Node):
	# print("New Interactable Entered: " + str(interactableEventObject.name))
	print("WARNING FROM SELF: the interaction system needs to be properly tested, we only check for a name when exiting, so if multiple things are named the same it will cause issues")
	interactable = interactableEventObject
	get_parent().get_node("Interactable_Label").visible = true
	
func exitedInteractable(interactableEventObject: Node):
	# print("Interactable Exited: " + str(interactableEventObject.name))
	# print("Existing Interactable is : " + str(interactable.name))
	if(interactable == interactableEventObject):
		print("We have left the currently heald interactable object")
		interactable = null
		get_parent().get_node("Interactable_Label").visible = false
		
# set the player inputs on or off depending on wheather we want the player moving
func setInput(captureInput:bool):
	isCapturingInput = captureInput
	
# Build mode stuff for placing the different types of things on your ship
func showBuildable():
	# Ray Cast onto a ship
	# var castResult = castRay()
	var castResult = castRayFromCamera()
	
	if(castResult == null):
		print("Raycast: no object under the ray cast")
	else:
		#print("Collision Point " + str(castResult.get_collision_point()))
		#print("Collision Normals " + str(castResult.get_collision_normal()))
		#add_child(buildable)
		#buildable.translation = castResult.get_collision_point()
		buildable.global_transform.origin = castResult.get_collision_point()

		if(Input.is_action_just_pressed("fire")):
			
			var ship = castResult.get_collider().get_parent()
			
			if("type" in ship):
				if(ship.type == "Ship"):
					print("call Build function")
					build(ship, castResult)
				else:
					return
			else:
				print("no type on object")
			return
			
			

	
	pass
	
func build(ship:Node, castResult):
	
	remove_child(buildable)
	var _tempRotation = rotation
	#var ship = get_parent().get_node("Mainhull")
	ship.get_node("Parts").add_child(buildable)
	buildable.global_transform.origin = castResult.get_collision_point()
	buildable.rotation = _tempRotation
#	buildable.scale.x = 0.25
#	buildable.scale.y = 0.25
#	buildable.scale.z = 0.25
#			print("Buildable location: " + str(buildable.global_transform))
#			print("Intended Location: " + str(castResult.get_collision_point()))
	buildable = null
	buildable = buildableToInstance.instance()
	add_child(buildable)
	#ship.triggerRecalc()
	pass

func castRay():
	var startPos = translation
	
	#print("start Position:" + str(startPos))
	#print("Basis" + str(transform.basis))
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(translation, transform.basis.x, [self])
	# print(result.collider.name)
	return result
	
func castRayFromCamera():
	# Using ray Cast node on camera
	var rayCast = $Camera_Point/Camera/RayCast
	if(rayCast == null): 
		print("Error, Camera is not a child of player")
		return rayCast
	
	rayCast.add_exception(self) # disble interaction with Player
	# rayCast.add_exception($Camera_Point) # Disable interaciton with Camera point (not needed as not part of the collision layer)
	# rayCast.add_exception($Camera_Point/Camera) # Disable interaciton with - see above
	
	var collider = rayCast.get_collider() # ??? never seems to collide
	
	#if(collider == null):
	#	print("No collidable object")
	#else:
	#	print("ObjectName: " + collider)
		
	return rayCast
	
	# *********************************
	# Old Method Incomplete
	#var cam = $Camera_Point/Camera
	#var camPos = cam.global_transform.origin
	# var collisionMask = 2 # Disabled for now, should set for better efficiency
	
	# Actual RayCast
	#var space_state = get_world().direct_space_state
	# var result = space_state.intersect_ray(camPos, )
	pass
# ***********************
# Input Return Method
# ***********************
func InputModeChanged():
	print("Player: detected inputmode change")
	
	currentInputMode = MainLevel.currentInputMode
	
	if(currentInputMode == InputMode.PlayerMode):
		isCapturingInput = true
		$Camera_Point/Camera.current = true
	elif(currentInputMode == InputMode.BuildMode):
		isCapturingInput = true
	elif(currentInputMode == InputMode.ShipMode):
		isCapturingInput = false
	else:
		print("Player: WARNING unaccountaed input mode found, enabling player controls")
		isCapturingInput = true
	
# ***********************
# Helper Methods
# ***********************

