extends Container

signal mouse_entered_section(index: int)
signal mouse_exited_section(index: int)

# assumes name is the index of the section, breaks otherwise
func _on_mouse_entered() -> void:
	mouse_entered_section.emit(int(name))

# assumes name is the index of the section, breaks otherwise
func _on_mouse_exited() -> void:
	mouse_exited_section.emit(int(name))
