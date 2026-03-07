extends CanvasLayer

@onready var panel: Panel = %Panel
@onready var default_panel := panel.duplicate()

func _on_fade_in_pressed() -> void: Animate.fade_in(panel)

func _on_fade_out_pressed() -> void: Animate.fade_out(panel)

func _on_pop_in_pressed() -> void: Animate.pop_in(panel)

func _on_pop_out_pressed() -> void: Animate.pop_out(panel)

func _on_fade_from_left_pressed() -> void: Animate.fade_from_left(panel)

func _on_fade_from_right_pressed() -> void: Animate.fade_from_right(panel)

func _on_fade_from_up_pressed() -> void: Animate.fade_from_up(panel)

func _on_fade_from_down_pressed() -> void: Animate.fade_from_down(panel)

func _on_fade_to_left_pressed() -> void: Animate.fade_to_left(panel)

func _on_fade_to_right_pressed() -> void: Animate.fade_to_right(panel)

func _on_fade_to_up_pressed() -> void: Animate.fade_to_up(panel)

func _on_fade_to_down_pressed() -> void: Animate.fade_to_down(panel)

func _on_pulse_pressed() -> void: Animate.pulse(panel)

func _on_ping_pressed() -> void: Animate.ping(panel)

func _on_wiggle_pressed() -> void: Animate.wiggle(panel)

func _on_reset_pressed() -> void: _reset_panel()

func _reset_panel() -> void:
	var new_panel := default_panel.duplicate()
	panel.get_parent().add_child(new_panel)
	panel.queue_free()
	panel = new_panel
