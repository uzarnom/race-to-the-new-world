extends Spatial

func _ready():
	pass
	
func PlayGrowAnimation():
	$AnimationPlayer.play("growAnimation")
	
func ResetColourAndAnimation():
	$AnimationPlayer.play("RESET")
	
