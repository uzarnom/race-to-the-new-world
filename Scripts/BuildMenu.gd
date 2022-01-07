extends Control

const ItemPreLoad = preload("res://Scripts/Classes/Part.gd")
var scanDirectory = "res://assets/Items"
var partsDirectory = "res://assets/Ship Parts/"

var currentFolder = partsDirectory

var filesAndFolders = []


# InputMode variables
var MainLevel:Node
var InputMode # {PlayerMode, BuildMode, ShipMode} # get from parent "Level"
var isCapturingInputs:bool = false
var currentInputMode


func _ready():
	
	
	setPosition() # set the UI's position
	
	# scan and display menu items
#	var files = scanFilesForBuildMenu(scanDirectory) # scan the directoy for an array of items
#	displayCurrentMenuItems(files) # displays the array of items
	ReBuildMenu(currentFolder)
	
	# the new scan and display menu items
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

		# This is how we scan the directory and display it
#		var directoryList = ScanDirectory(partsDirectory)
#		filesAndFolders = directoryList
#		DisplayScannedDirectory(directoryList)
		
		# This next one is testing the get parent folder thing
		print(GetParentFolder())
		
		pass
		
# Receive a number from the player and return the selected menu or null if menu switching
func receiveInput(menuNumber:int):
	
	#return preload("res://assets/Ship Parts/weight.tscn").instance()
	
	menuNumber -= 1
	
	# if the menu selection is outside the selection, return null to show no change or 
	if(menuNumber < 0 || menuNumber > filesAndFolders.size()-1):
		return null
		
	var file = filesAndFolders[menuNumber]
	if(IsFile(file)):
		# return the instance things
		print("Loading: " + file.folder + file.filename)
		return ResourceLoader.load(file.folder + file.fileName)
		pass
	else:
		# a folder, navigate and rebuild menu
		if(file == ".."):
			currentFolder = GetParentFolder()
			ReBuildMenu(currentFolder)
		else:
			print("Current Folder: " + currentFolder)
			print("file: " + file)
			currentFolder = currentFolder + file + "/"
			ReBuildMenu(currentFolder)
		
		return null
		pass
	
	# Need to change to allow for changing directory, s
	# store current directory so we can use current directory + file name
	# store current directory list
	
# Based on the screens resolution, set the location of thebuild menu
func setPosition():
	var resolution = get_viewport().size
	rect_position.x = resolution.x / 2 # middle of screen - no idea why the middle is 256 on a 1024 rather than 512
	rect_position.y = resolution.y - ($MenuBackground.rect_size.y / 2)
	
	print("Full resolution = " + str(get_viewport().size))
	print("Res Position = " + str(resolution))
	print("Rect Position = " + str(rect_position))

# **********************
# Old file scan method and display - becoming obsolete 
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
# Recersive scan - obsolete 
# **********************
func ScanAndBuildMenuItems(toScan:String):
	var tempList = RecursiveScan(toScan)
	return tempList

func RecursiveScan(scanDir:String):
	var retArr = []
	
	var dir = Directory.new()
	dir.open(scanDir)
	dir.list_dir_begin(true,true)
	
	var file = dir.get_next()
	while file != "":
		if(dir.current_is_dir()):
			var nextScan = scanDir + '/' + file
			# file is the name of the folder
			
			# check folder has an image
			var temp_file = File.new()
			if(temp_file.file_exists(nextScan + ".png")):
				retArr.append({nextScan: RecursiveScan(nextScan) })
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

# requries a position and level
func DisplayMenuItems(files):
	
	# Steps
	# clear current Menu items
	ClearChildren()
	# Loop the files 
	
	# for now store the position and files globally
	#
	
	pass

# **********************
# Scan This directory only  
# **********************

func ScanDirectory(toScan:String):
	var retArr = []
	
	var dir = Directory.new()
	dir.open(toScan)
	dir.list_dir_begin(true, true)
	
	if(toScan != partsDirectory):
		retArr.append("..")
	
	var file = dir.get_next()
	while file != "": # While Items exist within the directory
			# IF A FOLDER
			if(dir.current_is_dir()):
				# ensure the folder has an image, else don't add it
				var temp_file = File.new()
				if(temp_file.file_exists(partsDirectory + "/" + file + ".png")):
					retArr.append(file)
				else:
					print("BUILD MENU ERROR: the following folder does not have a png, ignoring folder: " + str(file))
					

			# If a File
			else: 
				if(file.ends_with(".tscn")):
					var newItem = ItemPreLoad.new()
					newItem.folder = toScan
					newItem.fileName = file
					newItem.itemImage = toScan + "/" + file.substr(0, file.length()-5) + '.png'
					print("Image Name "+ newItem.itemImage)
					# Verify we have an image for the resrouce, and append if we have both
					var temp_file = File.new()
					if(temp_file.file_exists(newItem.itemImage)):
						retArr.append(newItem)
					else:
						print(str(file) + " Does not have an accompanying .png")
			
			# Before we start the next loop, load next file into file variable
			file = dir.get_next()
	
	return retArr

func DisplayScannedDirectory(directory:Array):
	# Clear current Menu Items
	ClearChildren()
	
	var position = 0
	var lengthInterval = 64
	
	for file in directory:
		
		var newRect = TextureRect.new()
		var texture
		
		#Note Error checking is done before adding the file to this list
		if(typeof(file) == TYPE_STRING && file == ".."):#back folder shit
			texture = ResourceLoader.load(partsDirectory + "/back.png")
		elif(typeof(file) == TYPE_STRING):# if its a string its a folder
			var iconPath = currentFolder + "/" + file + ".png"
			texture = ResourceLoader.load(iconPath)
		else: # is a folder
			print(file.itemImage)
			texture = ResourceLoader.load(file.itemImage)
			
		newRect.texture = texture
		newRect.rect_scale.x = 0.5
		newRect.rect_scale.y = 0.5
		
		newRect.rect_position.x = position * lengthInterval
		position += 1
		
		$MenuBackground.add_child(newRect)
		# load image resource
		# place image resource
		# if file is ".." use special image at set location
		pass
	
	
	pass

func ReBuildMenu(buildFolder:String):
	var directoryList = ScanDirectory(currentFolder)
	filesAndFolders = directoryList
	DisplayScannedDirectory(directoryList)
	
	pass
# **********************
# Helper functions
# **********************
func toggleVisibility():
	visible = !visible
	
func ClearChildren():
	for n in $MenuBackground.get_children():
		$MenuBackground.remove_child(n)
		n.queue_free()
		

func GetParentFolder():
	
#	print(currentFolder.find_last("/"))
#	print(currentFolder.substr(0, 23))
#	var newFol:String = currentFolder.substr(0,23)
#	var remPoint:int = newFol.find_last("/")
#	newFol = newFol.substr(0, remPoint+1)
#	print(currentFolder)
#	print(newFol)

	
	if(currentFolder == partsDirectory):
		return currentFolder
	
	# remove the last folder, keeping the trailing '/'
	var remPoint:int = currentFolder.find_last("/")
	currentFolder = currentFolder.substr(0, remPoint)
	remPoint = currentFolder.find_last("/")
	currentFolder = currentFolder.substr(0, remPoint+1)
	
	return currentFolder
	pass

func IsFile(file):
	if(typeof(file) == TYPE_STRING):
		return false # it is a folder if it is just a string
	else:
		return true # else an object is a file
	
# **********************
# InputMode Change response
# **********************
# function which responds to the InputmodeChange
func InputModeChanged():
	print("Currently in Build Menu, receiving new inputMode")
	
	currentInputMode = MainLevel.currentInputMode

	if(currentInputMode == InputMode.BuildMode):
		visible = true
	else:
		visible = false
