extends Module
class_name TimerModule

@export var bpt := 4 # Beats per tick
@onready var current_beat := bpt

func port_setup() -> void:
	clear_all_slots()
	set_slot(
		0,
		false, 0, Color.WHITE,
		true, 0, Color.WHITE
	)
	

func process_signal() -> void:
	current_beat -= 1
	if current_beat == 0:
		current_beat = bpt
		send_signal(0, true)
	_handle_value([0])
	
