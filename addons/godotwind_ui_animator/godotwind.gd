
extends Node

var default_duration: float = 0.3
var default_distance: float = 100.0

#region Transitions

func fade_in(node: CanvasItem, duration := default_duration, from := 0.0, to := 1.0, transition := Tween.TRANS_CUBIC, easing := Tween.EASE_OUT) -> Signal:
	var tween := new_tween(node,transition,easing)
	tween.tween_property(node, "modulate:a", to, duration).from(from)
	return tween.finished

func fade_out(node: CanvasItem, duration := default_duration, from := 1.0, to := 0.0, transition := Tween.TRANS_CUBIC, easing := Tween.EASE_IN) -> Signal:
	var tween := new_tween(node,transition,easing)
	tween.tween_property(node, "modulate:a", to, duration).from(from)
	return tween.finished

func pop_in(node: CanvasItem, duration := default_duration, to := Vector2.ONE, from := Vector2.ZERO, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal:
	var fade_duration := duration
	fade_in(node,fade_duration)
	var prev_pivot_offset_ratio: Vector2 = node.get("pivot_offset_ratio")
	node.set("pivot_offset_ratio",Vector2.ONE * 0.5)
	var tween := new_tween(node,transition,easing)
	tween.tween_property(node, "scale", to, duration)
	tween.finished.connect(func(): if is_instance_valid(node): node.set("pivot_offset_ratio",prev_pivot_offset_ratio))
	return tween.finished

func pop_out(node: CanvasItem, duration := default_duration, from: Vector2 = node.get("scale"), to := Vector2.ZERO, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal:
	var prev_scale: Vector2 = node.get("scale")
	var prev_pivot_offset_ratio: Vector2 = node.get("pivot_offset_ratio")
	node.set("pivot_offset_ratio",Vector2.ONE * 0.5)
	var tween := new_tween(node,transition,easing)
	tween.tween_property(node, "scale", to, duration).from(from)
	tween.finished.connect(func(): if is_instance_valid(node): node.set("pivot_offset_ratio",prev_pivot_offset_ratio); node.set("scale",prev_scale))
	var duration_scale := duration/default_duration
	get_tree().create_timer(0.1 * duration_scale).timeout.connect(func(): fade_out(node,0.2 * duration_scale))
	return tween.finished

func fade_from_left(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal: return _fade_slide(node, duration, -distance * Vector2.LEFT, fade_from, fade_to, transition, easing)
func fade_from_right(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal: return _fade_slide(node, duration, -distance * Vector2.RIGHT, fade_from, fade_to, transition, easing)
func fade_from_up(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal: return _fade_slide(node, duration, -distance * Vector2.UP, fade_from, fade_to, transition, easing)
func fade_from_down(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal: return _fade_slide(node, duration, -distance * Vector2.DOWN, fade_from, fade_to, transition, easing)

func fade_to_left(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 1.0, fade_to := 0.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal: return _fade_slide(node, duration, distance * Vector2.LEFT, fade_from, fade_to, transition, easing)
func fade_to_right(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 1.0, fade_to := 0.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal: return _fade_slide(node, duration, distance * Vector2.RIGHT, fade_from, fade_to, transition, easing)
func fade_to_up(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 1.0, fade_to := 0.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal: return _fade_slide(node, duration, distance * Vector2.UP, fade_from, fade_to, transition, easing)
func fade_to_down(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 1.0, fade_to := 0.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal: return _fade_slide(node, duration, distance * Vector2.DOWN, fade_from, fade_to, transition, easing)

#endregion

#region Other Animations

var _pinging: Dictionary[Node,Tween]
var _pulsing: Dictionary[Node,Tween]

func pulse(node: CanvasItem, amount := 2, duration: float = default_duration, target_opacity_ratio := 0.5, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Tween:
	if _pulsing.has(node): _stop_pulse(node)
	if amount < 0: return null
	var base_modulate := node.modulate.a
	var opacity_off := base_modulate * target_opacity_ratio
	var tween := new_tween(node,Tween.TRANS_SINE)
	var pulse_duration := duration/2
	tween.set_loops(amount)
	tween.tween_callback(func(): _pulsing[node] = tween)
	tween.tween_property(node, "modulate:a", opacity_off, pulse_duration)
	tween.tween_callback(func(): _pulsing[node] = tween)
	tween.tween_property(node, "modulate:a", opacity_off * 2, pulse_duration)
	tween.finished.connect(func(): _pulsing.erase(node); node.modulate.a = base_modulate)
	return tween

func ping(node: CanvasItem, duration := default_duration, scale_amount := Vector2(0.1,0.1), target_modulate := Color.WHITE, transition := Tween.TRANS_CIRC, easing := Tween.EASE_IN) -> Tween:
	if _pinging.has(node): return
	var prev_pivot_offset_ratio: Vector2 = node.get("pivot_offset_ratio")
	node.set("pivot_offset_ratio",Vector2.ONE * 0.5)
	var start_scale: Vector2 = node.scale
	var start_modulate := node.modulate
	var to := start_scale + scale_amount
	var tween := new_tween(node,transition,easing)
	_pinging[node] = tween
	tween.set_parallel(true)
	tween.tween_property(node, "scale", to, duration * 0.3)
	tween.tween_property(node, "modulate", target_modulate, duration * 0.1)
	await tween.finished
	if not _pinging.has(node): return
	var tween_reset := new_tween(node,transition,easing)
	tween_reset.set_parallel(true)
	tween_reset.tween_property(node, "scale", start_scale, duration * 0.7)
	tween_reset.tween_property(node, "modulate", start_modulate, duration * 0.7)
	tween_reset.finished.connect(func():
		_pinging.erase(node)
	)
	tween_reset.finished.connect(func(): if is_instance_valid(node): node.set("pivot_offset_ratio",prev_pivot_offset_ratio))
	return tween_reset

func wiggle(node: CanvasItem, angle := 2.5, duration := 0.15, amount := 2, transition := Tween.TRANS_SINE, easing := Tween.EASE_IN) -> Signal:
	var prev_pivot_offset_ratio: Vector2 = node.get("pivot_offset_ratio")
	node.set("pivot_offset_ratio",Vector2.ONE * 0.5)
	var tween := new_tween(node,transition, easing).set_loops(amount)
	tween.set_parallel(false)
	var rad := deg_to_rad(angle)
	tween.tween_property(node, "rotation", rad, duration/4.0)
	tween.tween_property(node, "rotation", -rad, duration/2.0)
	tween.tween_property(node, "rotation", 0, duration/4.0)
	tween.finished.connect(func(): if is_instance_valid(node): node.set("pivot_offset_ratio",prev_pivot_offset_ratio))
	return tween.finished

#endregion

#region Helper Functions

func _stop_pulse(node: Node) -> Tween:
	if not _pulsing.has(node): return
	var active_tween := _pulsing[node]
	active_tween.stop()
	active_tween.finished.emit()
	return active_tween

func new_tween(parent_node: Node = self, transition := Tween.TRANS_LINEAR, easing := Tween.EASE_IN) -> Tween:
	var tween := parent_node.create_tween().set_trans(transition).set_ease(easing).set_pause_mode(Tween.TWEEN_PAUSE_BOUND)
	return tween

func _fade_slide(node: Node, duration := default_duration, slide_distance := Vector2.ZERO, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal:
	var fading_in := fade_to >= fade_from
	var fade_func: String = "fade_in" if fading_in else "fade_out"
	call(fade_func,node,duration,fade_from,fade_to)
	var start_pos: Vector2 = node.position
	var final_pos: Vector2 = start_pos
	var tween := new_tween(node,transition,easing)
	if fading_in: start_pos += slide_distance
	else:
		final_pos = node.position + slide_distance
		tween.finished.connect(func(): if is_instance_valid(node): node.position = start_pos)
	tween.tween_property(node, "position", final_pos, duration).from(start_pos)
	return tween.finished

#endregion
