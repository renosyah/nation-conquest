extends BaseResources

func _on_VisibilityNotifier_camera_entered(camera):
	visible = true
	
func _on_VisibilityNotifier_camera_exited(camera):
	visible = false
