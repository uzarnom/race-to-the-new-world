extends RigidBody

# Movement
var velocity = Vector3(0,0,0)
var myRotation:float = 0.0

export var FRICTION:float = 0.5
const ROTFRICTION = deg2rad(45)

export var  MAXSPEED = 7
const MAXROTSPEED = deg2rad(12)

export var ACCELERATION = 20
const ROTACCELERATION = deg2rad(0.5)

var hasRot:bool = false

# debug values can remove wiht accociated code later
var deltapass:float = 0

# Player's object so we know where to return the camera to
var Player:Node

#Input Handling
var isCapturingInputs:bool = false
var MainLevel:Node
var InputMode # {PlayerMode, BuildMode, ShipMode} # get from parent "Level"
var currentInputMode

func _ready():
	MainLevel = get_parent()
	InputMode = MainLevel.InputMode
	currentInputMode = MainLevel.currentInputMode
	MainLevel.trackInputMode(self)

func _physics_process(delta: float):
	# Escape mouse capture - handled by player script
	var MaxSpeedClamped = MAXSPEED # delta * MAXSPEED
	var TempDirVec = -global_transform.basis.x
	var TempVec:Vector3 = Vector3()
	
	var isAccelerating:bool = false	# If Input is moving the ship, no friction
	var isRotating:bool = false		# If Input is rotating the ship no friction
	
	# New Movement
	if(isCapturingInputs):
		var acelByDelta = ACCELERATION * delta
		if(Input.is_action_pressed("forward")):
			TempVec += TempDirVec
			isAccelerating = true
		if(Input.is_action_pressed("backward")):
			TempVec -=  TempDirVec
			isAccelerating = true
		if(Input.is_action_pressed("leftward")):
			# velocity.z += ACCELERATION * delta
			myRotation += ROTACCELERATION * delta
			hasRot = true
		if(Input.is_action_pressed("rightward")):
			# velocity.z -= ACCELERATION * delta
			myRotation -= ROTACCELERATION * delta
			hasRot = true
		TempVec = TempVec * acelByDelta
		
	if(Input.is_action_just_pressed("testingTrigger")):
		print("Current Input Mode = " + str(currentInputMode))
		
	
	if(Input.is_action_just_pressed("cancelControl") and currentInputMode == InputMode.ShipMode):
		print("Ship: Cancel Control activated")
		returnCameraAndControlTo(Player)
		#velocity = Vector3()
		#myRotation = 0.0
		MainLevel.changeInputMode(InputMode.PlayerMode)
	
	# Apply forward velocity to current velocity
	velocity = velocity + TempVec
	
	# Apply smooth transform friction
	if(!isAccelerating):
		velocity.x = lerp(velocity.x, 0, FRICTION * delta)
		velocity.z = lerp(velocity.z, 0, FRICTION * delta)
	
	# Apply smooth rotational friction
	if(!hasRot): #If has not tried to rotate, apply rotational friction
		myRotation = lerp(myRotation, 0, ROTFRICTION * delta)
	else:
		hasRot = false
		
	# Clamp Values
	velocity = clampVector3(velocity, -MaxSpeedClamped, MaxSpeedClamped)
	#myRotation = clamp(myRotation, -MAXROTSPEED, MAXROTSPEED)
	
	#Apply movement and rotation
	add_force(Vector3(1000,1000,1000), translation)
#	move_and_slide(velocity)
	rotate_y(myRotation)


	
	# Debug outputs
#	deltapass += delta
#	if(deltapass > 1):
#		deltapass -= 1
#		print("velocity: " + str(velocity))
#		print("rotation velocity: " + str(myRotation) + "\n")
	
	# Old Movement 
#		if(Input.is_action_pressed("forward")):
#			velocity.x -= ACCELERATION * delta
#		if(Input.is_action_pressed("backward")):
#			velocity.x += ACCELERATION * delta
#		if(Input.is_action_pressed("leftward")):
#			# velocity.z += ACCELERATION * delta
#			myRotation += ROTACCELERATION * delta
#		if(Input.is_action_pressed("rightward")):
#			# velocity.z -= ACCELERATION * delta
#			myRotation -= ROTACCELERATION * delta
	pass

func clampVector3(Vec: Vector3, m_min: float, m_max: float):
	Vec.x = clamp(Vec.x, m_min, m_max)
	Vec.y = clamp(Vec.y, m_min, m_max)
	Vec.z = clamp(Vec.z, m_min, m_max)
	return(Vec)
# fixed_pos = (position - center).normalized() * radius

# set ship's input
func setInput(captureInput:bool):
	if(captureInput == true):
		MainLevel.changeInputMode(InputMode.ShipMode)
	else:
		print("find why this is being called")
	#isCapturingInputs = captureInput
	
func returnCameraAndControlTo(RetTarget:Node):
	#isCapturingInputs = false
	#Player.isCapturingInputs = true
	MainLevel.changeInputMode(InputMode.PlayerMode)
	return
	# RetTarget #The Player Hopefully
	print("The Return Target: " + RetTarget.name)
	var Cam = get_node("Camera_Point").get_node("Camera")
	
	if(Cam == null):
		print("The Camera is not located under this object: " + name)
		return
		
	# Remove from this and add the camera new parent
	get_node("Camera_Point").remove_child(Cam)
	RetTarget.get_node("Camera_Point").add_child(Cam)
	Cam.global_transform.origin = RetTarget.get_node("Camera_Point").global_transform.origin

# **********************
# Build system
# **********************
func triggerRecalc():
	
	pass
# **********************
# Input Mode System
# **********************
func InputModeChanged():
	print("Ship: Detected InputMode Change")
	
	currentInputMode = MainLevel.currentInputMode
	print("Changed Input mode is " + str(currentInputMode))
	if(currentInputMode == InputMode.ShipMode):
		isCapturingInputs = true
	else:
		isCapturingInputs = false
