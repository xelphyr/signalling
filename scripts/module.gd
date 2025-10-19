extends GraphNode
class_name Module

@export var ge : ModuleContainer
var value = null
var should_decay : bool

func _ready() -> void:
	if !ge:
		var p := get_parent()
		if p is GraphEdit:
			ge = p
		else:
			push_error("No GraphEdit set for %s and parent is not a GraphEdit" % name)
			return
	ge.connect("tick_begin", process_signal)
	call_deferred("port_setup")
	
func port_setup() -> void:
	pass

func process_signal() -> void:
	pass
	
func _handle_value(input_port_indices : Array[int], no_input := false) -> void:
	var any_port_disconnected = false
	for i in input_port_indices:
		any_port_disconnected = any_port_disconnected || (ge.get_incoming(name, i).size() == 0)
	if should_decay or (!no_input and any_port_disconnected):
		value = null

func send_signal(out_port: int, out_value, decay = true) -> void:
	ge.propagate_signal(name, out_port, out_value, decay)

func receive_signal(in_port: int, in_value, decay = true) -> void:
	value = in_value
	should_decay = decay
	
