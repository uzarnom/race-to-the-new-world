extends Control

const ItemPreLoad = preload("res://Scripts/Classes/Part.gd")
var scanDirectory = "res://assets/Items"
var partsDirectory = "res://assets/Ship Parts/"

var currentFolder = scanDirectory


# InputMode variables
var MainLevel:Node
var InputMode # {PlayerMode, BuildMode, ShipMode} # get from parent "Level"
var isCapturingInputs:bool = false
var currentInputMode


func _ready():
	
	setPosition() # set the UI's position
	
	var files = scanFilesForBuildMenu(scanDirectory) # scan the directoy for an array of items
	
	displayCurrentMenuItems(files) # displays the array of items
	
	# print(files) # Testing - prints the array of items

	# functions
	MainLevel = get_parent() # get node which stores InputMode
	InputMode = MainLevel.InputMode # Get Enum of InputModes
	currentInputMode = MainLevel.currentInputMode

	MainLevel.trackInputMode(self) #Subscribe to inputMode changes

	
func _process(delta):
	
	# Can always open build menu
	if(Input.is_action_just_pressed("openbuildmenu") and currentInputMode == InputMode.PlayerMode):
		MainLevel.changeInputMode(InputMode.BuildMode)
	elif(Input.is_action_just_pressed("openbuildmenu") and currentInputMode == InputMode.BuildMode):
		MainLevel.changeInputMode(InputMode.PlayerMode)
		
	if(Input.is_action_just_pressed("testingTrigger")):
		scanAndBuildMenuItems(partsDirectory)
		pass
		
# Receive a number from the player and return the selected menu or null if menu switching
func receiveInput(menuNumber:int):
	print("Need to implement the menu system once the dynamic items for the ship has been finished")
	return preload("res://assets/Ship Parts/weight.tscn").instance()
	
# Based on the screens resolution, set the location of thebuild menu
func setPosition():
	var resolution = get_viewport().size
	rect_position.x = resolution.x / 2 # middle of screen - no idea why the middle is 256 on a 1024 rather than 512
	rect_position.y = resolution.y - ($MenuBackground.rect_size.y / 2)
	
	print("Full resolution = " + str(get_viewport().size))
	print("Res Position = " + str(resolution))
	print("Rect Position = " + str(rect_position))

# **********************
# Old file scan method and display
# **********************
# the curren method to get the list of buildables 
func scanFilesForBuildMenu(toScan:String):
	var dir = Directory.new()
	dir.open(toScan)
	dir.list_dir_begin()
	
	var files = []
	
	var maxItemScan = 20
	var itemsScanned = 0
	while true:
		
		var file = dir.get_next()
		if(file == ""):
			break
		elif(file.ends_with(".png")):
			files.append(file)
		
		# Break out of loop if max number of scanned Items exceeded
		itemsScanned = itemsScanned + 1
		if(itemsScanned > maxItemScan):
			break
	
	return files

func displayCurrentMenuItems(files:Array):
	
	var position = 0
	var lengthInterval = 64
	
	for f in files:
		var newRect = TextureRect.new()
		var image = Image.new()
		var texture = ImageTexture.new()
		
		image.load(scanDirectory + "/" + f)
		texture.create_from_image(image)
		
		newRect.texture = texture
		newRect.rect_scale.x = 0.5
		newRect.rect_scale.y = 0.5
		
		# Set the position of the item, its length by the position number
		newRect.rect_position.x = position * lengthInterval
		position = position + 1
		
		$MenuBackground.add_child(newRect)
		# $TextureRect.add_child()
	
	pass

# **********************
# New Item scan and display methods
# **********************
func scanAndBuildMenuItems(toScan:String):
#	var dir = Directory.new()
#	dir.open(toScan)
#	dir.list_dir_begin()
	print("Building Menu - startign at: " + toScan)
	var tempList = recursiveScan(toScan)
	print(tempList)

func recursiveScan(scanDir:String):
	var retArr = []
	
	var dir = Directory.new()
	dir.open(scanDir)
	dir.list_dir_begin(true,true)
	
	print("New Recurse - scanning: " + scanDir)
	
	var file = dir.get_next()
	while file != "":
		if(dir.current_is_dir()):
			var nextScan = scanDir + '/' + file
			# file is the name of the folder
			
			# check folder has an image
			var temp_file = File.new()
			if(temp_file.file_exists(nextScan + ".png")):
				retArr.append({nextScan: recursiveScan(nextScan) })
			else:
				print(str(file) + " Does not have an accompanying .png")
		else:
			if(file.ends_with(".tscn")):
				# create the menu Item resource
				var newItem = ItemPreLoad.new()
				newItem.folder = scanDir
				newItem.fileName = file
				newItem.ItemImage = file.substr(0, file.length()-5) + '.png'
				
				# Verify we have an image for the resrouce, and append if we have both
				var temp_file = File.new()
				if(temp_file.file_exists(newItem.ItemImage)):
					retArr.append(newItem)
				else:
					print(str(file) + " Does not have an accompanying .png")
				# Append the file 
				#retArr.append(file)
		file = dir.get_next()
	# return the file and folder array
	return retArr




func toggleVisibility():
	visible = !visible
# function which responds to the InputmodeChange
func InputModeChanged():
	print("Currently in Build Menu, receiving new inputMode")
	
	currentInputMode = MainLevel.currentInputMode

	if(currentInputMode == InputMode.BuildMode):
		visible = true
	else:
		visible = false
