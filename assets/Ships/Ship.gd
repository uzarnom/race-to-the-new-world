extends RigidBody

# Variables for other things to verify what this is
var type = "Ship" # should use an enum


# Variables based on the attached parts
export var maxSpeed = 3
export var lift = 9.8
export var speed = 5
export var acceleration = 0.5

# height bobbing velocity
var yVel = Vector3()
var targetAlt
var liftIncr = 0.2

# Input Mode variables
var MainLevel:Node
var InputMode # {PlayerMode, BuildMode, ShipMode} # get from parent "Level"
var isCapturingInput:bool = false
var currentInputMode

func _ready():
	# store the target height for the ship
	targetAlt = global_transform.origin.y
	
	# Input Mode setup and registeration
	MainLevel = get_parent()
	InputMode = MainLevel.InputMode
	currentInputMode = MainLevel.currentInputMode
	
	MainLevel.trackInputMode(self)
	# Task List
	print("Ship: need to calculate the acceleration")
	
func _physics_process(delta):
	var deltaAccel = acceleration * delta
	
	var forward_dir = -global_transform.basis.x * deltaAccel
	if(Input.is_action_pressed("alt_forward")):
		if(linear_velocity.x < maxSpeed ):
			apply_central_impulse(forward_dir)
		
		
	if(Input.is_action_just_pressed("testingTrigger")):
#		print("Mass: " + str(weight))
		lift += liftIncr
		print("lift: " + str(lift))
		

	var riseOrFall = (liftIncr * mass * delta) * Vector3.UP
	if(global_transform.origin.y < targetAlt):
#		yVel += riseOrFall
		yVel = riseOrFall
	else:
#		yVel -= riseOrFall
		yVel = riseOrFall * -1
		
	
	apply_central_impulse(yVel)
#	if(global_transform.origin.y < targetAlt):
#		apply_central_impulse(upward_dir)
	

# ***********************
# Input Return Method
# ***********************
func InputModeChanged():
	print("Ship: detected Input Mode Change")
	currentInputMode = MainLevel.currentInputMode
	
	if(currentInputMode == InputMode.PlayerMode):
		isCapturingInput = false
	elif(currentInputMode == InputMode.BuildMode):
		isCapturingInput = false
	elif(currentInputMode == InputMode.ShipMode):
		isCapturingInput = true
		$Camera.current = true
	else:
		print("Ship: Warning inputmode not handled by the ship script")
