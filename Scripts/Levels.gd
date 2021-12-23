extends Spatial

# ***********************
# Stores the current input mode
# Allows sub scripts to subscribe to listten for notifications of a change in 
# those states
# ***********************
#
#

# Variables
enum InputMode {PlayerMode, BuildMode, ShipMode}
var currentInputMode = InputMode.PlayerMode
var nodesToInform:Array
var callBackFunctionName:String = "InputModeChanged"

# add the node to the list of listening to whe nthe InputMode cahnges
func trackInputMode(body: Node):
	if(body.has_method(callBackFunctionName)):
		nodesToInform.append(body)
	else:
		print("Error On Subscribe to InputModeChanged - no callback function defined")
	pass
	
# Change the Input Type, use the enum
func changeInputMode(newMode:int):
	
	# check if inputMode Valid
	if(newMode > InputMode.size()):
		print("New InputMode enum incorrect")
		return
	
	# Change Input Mode
	currentInputMode = newMode
	
	# Test Functions
	print("Test this function")
	print("Size Check: " + str(InputMode.size()))
	print("New Mode Check - Inputted: " + str(newMode) + " " + str(currentInputMode))
	
	# propogate the InputMode Change
	for n in nodesToInform:
		n.InputModeChanged()
	
	print("Need to find a way to make this dynamic and use the string defined above")
	
	pass

func _ready():
	pass
