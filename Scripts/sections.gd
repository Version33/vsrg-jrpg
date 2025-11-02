extends HBoxContainer

signal mouse_entered_section(index: int)
signal mouse_exited_section(index: int)

func _on_mouse_entered(index: int) -> void:
	mouse_entered_section.emit(index)

func _on_mouse_exited(index: int) -> void:
	mouse_exited_section.emit(index)
