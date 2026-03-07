extends Node

var default_duration: float = 0.3
var default_distance: float = 100.0

#region Transitions

func fade_in(node: CanvasItem, duration := default_duration, from := 0.0, to := 1.0, transition := Tween.TRANS_CUBIC, easing := Tween.EASE_OUT) -> Signal:
	await _check_active_animations(node)
	if node: node.tree_exiting.connect(func(): _faded_nodes.erase(node))
	_faded_nodes[node] = to
	var tween := new_tween(node,transition,easing)
	tween.tween_property(node, "modulate:a", to, duration).from(from)
	return tween.finished

func fade_out(node: CanvasItem, duration := default_duration, from := 1.0, to := 0.0, transition := Tween.TRANS_CUBIC, easing := Tween.EASE_IN) -> Signal:
	await _check_active_animations(node)
	_faded_nodes[node] = from
	if node: node.tree_exiting.connect(func(): _faded_nodes.erase(node))
	var tween := new_tween(node,transition,easing)
	tween.tween_property(node, "modulate:a", to, duration).from(from)
	return tween.finished

func pop_in(node: CanvasItem, duration := default_duration, to := Vector2.ONE, from := Vector2.ZERO, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal:
	await _check_active_animations(node)
	var duration_scale := duration/default_duration
	fade_in(node,0.3 * duration_scale)
	var prev_pivot_offset_ratio: Vector2 = node.get("pivot_offset_ratio")
	node.set("pivot_offset_ratio",Vector2.ONE * 0.5)
	var tween := new_tween(node,transition,easing)
	tween.tween_property(node, "scale", to, duration).from(from)
	tween.finished.connect(func(): if is_instance_valid(node): node.set("pivot_offset_ratio",prev_pivot_offset_ratio))
	return tween.finished

func pop_out(node: CanvasItem, duration := default_duration, to := Vector2.ZERO, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal:
	await _check_active_animations(node)
	var duration_scale := duration/default_duration
	fade_out(node,0.25 * duration_scale)
	var prev_pivot_offset_ratio: Vector2 = node.get("pivot_offset_ratio")
	var prev_scale: Vector2 = node.get("scale")
	node.set("pivot_offset_ratio",Vector2.ONE * 0.5)
	var tween := new_tween(node,transition,easing)
	tween.tween_property(node, "scale", to, duration)
	tween.finished.connect(func(): if is_instance_valid(node): node.set("pivot_offset_ratio",prev_pivot_offset_ratio); node.set("scale",prev_scale))
	return tween.finished

func fade_from_left(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal: return fade_slide(node, duration, -distance * Vector2.LEFT, fade_from, fade_to, transition, easing)
func fade_from_right(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal: return fade_slide(node, duration, -distance * Vector2.RIGHT, fade_from, fade_to, transition, easing)
func fade_from_up(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal: return fade_slide(node, duration, -distance * Vector2.UP, fade_from, fade_to, transition, easing)
func fade_from_down(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal: return fade_slide(node, duration, -distance * Vector2.DOWN, fade_from, fade_to, transition, easing)

func fade_to_left(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 1.0, fade_to := 0.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal: return fade_slide(node, duration, distance * Vector2.LEFT, fade_from, fade_to, transition, easing)
func fade_to_right(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 1.0, fade_to := 0.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal: return fade_slide(node, duration, distance * Vector2.RIGHT, fade_from, fade_to, transition, easing)
func fade_to_up(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 1.0, fade_to := 0.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal: return fade_slide(node, duration, distance * Vector2.UP, fade_from, fade_to, transition, easing)
func fade_to_down(node: CanvasItem, duration := default_duration, distance := default_distance, fade_from := 1.0, fade_to := 0.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal: return fade_slide(node, duration, distance * Vector2.DOWN, fade_from, fade_to, transition, easing)

func fade_slide(node: Node, duration := default_duration, slide_distance := Vector2.ZERO, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal:
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

#region Other Animations

var _active_animations: Dictionary[Node,Tween]
var _faded_nodes: Dictionary[Node,float]

func pulse(node: CanvasItem, amount := 2, duration: float = default_duration, opacity_off := 0.5, opacity_in := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Tween:
	await _check_active_animations(node)
	if amount < 0: return null
	var base_modulate := node.modulate.a
	var tween := new_tween(node,Tween.TRANS_SINE)
	var pulse_duration := duration/2
	tween.set_loops(amount)
	tween.tween_callback(func(): _active_animations[node] = tween)
	tween.tween_property(node, "modulate:a", opacity_off, pulse_duration)
	tween.tween_callback(func(): _active_animations[node] = tween)
	tween.tween_property(node, "modulate:a", opacity_in, pulse_duration)
	tween.finished.connect(func(): node.modulate.a = base_modulate)
	return tween

func ping(node: CanvasItem, target_modulate: Color = Color(3.294, 0.0, 0.0, 1.0), duration := default_duration, scale_amount := Vector2(0.1,0.1), transition := Tween.TRANS_CIRC, easing := Tween.EASE_IN) -> Tween:
	await _check_active_animations(node)

	node.set("pivot_offset_ratio",Vector2.ONE * 0.5)
	var start_scale: Vector2 = node.scale
	var start_modulate := node.modulate
	var to := start_scale + scale_amount
	var tween := new_tween(node,transition,easing)
	var ping_in_duration := duration * 0.3
	var reset_duration := duration - ping_in_duration
	_active_animations[node] = tween
	tween.set_parallel(true)
	tween.tween_property(node, "modulate", target_modulate, ping_in_duration/3.0)
	tween.tween_property(node, "scale", to, ping_in_duration)
	tween.set_parallel(false)
	tween.finished.connect(func(): node.scale = start_scale; node.modulate = start_modulate;  if tween: tween.stop())
	tween.tween_property(node, "scale", start_scale, reset_duration)
	tween.tween_property(node, "modulate", start_modulate, reset_duration)
	tween.tween_callback(func(): _active_animations[node] = tween)
	return tween

func wiggle(node: CanvasItem, degrees := 2.5, duration := 0.15, amount := 2, transition := Tween.TRANS_SINE, easing := Tween.EASE_IN) -> Tween:
	await _check_active_animations(node)
	var start_rotation_degrees: float = node.rotation_degrees
	var prev_pivot_offset_ratio: Vector2 = node.get("pivot_offset_ratio")
	node.set("pivot_offset_ratio",Vector2.ONE * 0.5)
	var tween := new_tween(node,transition, easing).set_loops(amount)
	tween.set_parallel(false)
	tween.tween_property(node, "rotation_degrees", degrees, duration/4.0)
	tween.tween_property(node, "rotation_degrees", -degrees, duration/2.0)
	tween.tween_property(node, "rotation_degrees", 0, duration/4.0)
	tween.finished.connect(func(): if is_instance_valid(node): node.set("rotation_degrees",start_rotation_degrees); node.set("pivot_offset_ratio",prev_pivot_offset_ratio))
	return tween

#endregion

#region Helper Functions

func _check_active_animations(node: Node) -> void:
	var should_await := false
	if _faded_nodes.has(node):
		node.modulate.a = _faded_nodes[node]
		_faded_nodes.erase(node)
		should_await = true
	if _active_animations.has(node):
		var active_tween := _active_animations[node]
		active_tween.stop()
		active_tween.finished.emit()
		_active_animations.erase(node)
		should_await = true
	if should_await: await get_tree().process_frame
		
	return

func new_tween(parent_node: Node = self, transition := Tween.TRANS_LINEAR, easing := Tween.EASE_IN) -> Tween:
	var tween := parent_node.create_tween().set_trans(transition).set_ease(easing).set_pause_mode(Tween.TWEEN_PAUSE_BOUND)
	_active_animations[parent_node] = tween
	tween.finished.connect(func(): if _active_animations.get(parent_node) and _active_animations.get(parent_node) == tween: _active_animations.erase(parent_node))
	return tween



#endregion
