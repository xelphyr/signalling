extends GraphEdit
class_name ModuleContainer

var dragging = false
signal tick_begin

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if dragging:
		_clamp_all()
		
func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and (e.button_index == MOUSE_BUTTON_MIDDLE \
		or e.button_index == MOUSE_BUTTON_WHEEL_UP \
		or e.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		accept_event()
	elif e is InputEventPanGesture:
		accept_event()


func _on_begin_node_move() -> void:
	dragging = true

func _on_end_node_move() -> void:
	dragging = false
	_clamp_all()

func _on_connection_request(from: StringName, from_port: int, to: StringName, to_port: int) -> void:
	if from == to: 
		return
	
	if port_has_incoming(to, to_port): # does the 2nd node already have an input at that port
		var old := get_incoming(to, to_port)[0]
		disconnect_node(old.from_node, old.from_port, to, to_port)
	
	if port_has_outgoing(from, from_port): # does the 1st node already have an output at that port
		var old:= get_outgoing(from, from_port)[0]
		disconnect_node(from, from_port, old.to_node, old.to_port)
		
	connect_node(from, from_port, to, to_port)

func _on_tick_timeout() -> void:
	emit_signal("tick_begin")

func _clamp_all() -> void:
	var rect = Rect2(scroll_offset, size/zoom)
	for n in get_children():
		if n is GraphNode:
			_clamp_node_to(rect, n)

func _clamp_node_to(area : Rect2, n: GraphNode):
	var max_pos := area.position + area.size - n.size
	n.position_offset = Vector2(
		clamp(n.position_offset.x, area.position.x, max_pos.x),
		clamp(n.position_offset.y, area.position.y, max_pos.y)
	)

#Checks if `to` has a node connect to the input port `to_port`
func port_has_incoming(to: StringName, to_port: int) -> bool:
	for c in get_connection_list():
		if c.to == to and c.to_port == to_port:
			return true
	return false

#Checks if `from` has a node connect to the output port `from_port`
func port_has_outgoing(from: StringName, from_port: int) -> bool:
	for c in get_connection_list():
		if c.from == from and c.from_port == from_port:
			return true
	return false

func get_incoming(to: StringName, to_port: int) -> Array[Dictionary]:
	var out: Array[Dictionary]= []
	for c in get_connection_list(): # each c is a Dictionary: {from, from_port, to, to_port}
		if c.to_node == to and c.to_port == to_port:
			out.append(c)
	return out

func get_outgoing(from: StringName, from_port: int) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for c in get_connection_list():
		if c.from_node == from and c.from_port == from_port:
			out.append(c)
	return out
	
func propagate_signal(from: StringName, from_port: int, value, decay := true) -> void:
	var connection := get_outgoing(from, from_port)
	if connection.size() == 0: 
		print("Nothing connected :<")
		return
	for node in get_children():
		if node.name == connection[0].to_node:
			node.receive_signal(connection[0].to_port, value, decay)
