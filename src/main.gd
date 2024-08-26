extends Control

@onready var startvanguard_button := $action_buttons/startbutton
@onready var stopvanguard_button := $action_buttons/stopbutton

@onready var closewindow_button := $window_buttons/closebutton
@onready var minimizewindow_button := $window_buttons/minimizebutton

@onready var statuslabel := $statuslabel
@onready var service_timer := $Timer

var vanguardexe = "vgtray.exe"
var vgc_service = "vgc"

var statuslabeltext = "STATUS: "

var dragging = false
var drag_offset = Vector2()

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = event.position
		else:
			dragging = false

	if event is InputEventMouseMotion and dragging:
		var window_position = Vector2(DisplayServer.window_get_position().x, DisplayServer.window_get_position().y)
		var new_position = window_position + event.position - drag_offset
		DisplayServer.window_set_position(new_position)

func _ready():
	startvanguard_button.pressed.connect(_on_startvanguard_button_pressed)
	stopvanguard_button.pressed.connect(_on_stopvanguard_button_pressed)    
	closewindow_button.pressed.connect(_on_closewindow_button_pressed)
	minimizewindow_button.pressed.connect(_on_minimizedwindow_button_pressed)
	service_timer.timeout.connect(_on_ServiceTimer_timeout)
	
	service_timer.wait_time = 1.5
	service_timer.start()

func _on_ServiceTimer_timeout():
	var output = []
	var result = OS.execute("CMD.exe", ["/c", "sc query " + vgc_service], output)
	if result == 0:
		for line in output:
			if line.find("RUNNING") != -1:
				statuslabel.text = ("STATUS: RUNNING")
				statuslabel.modulate = Color(0, 1, 0)
				return
	statuslabel.text = statuslabeltext + "STOPPED"
	statuslabel.modulate = Color(1, 0, 0)
	
func _on_startvanguard_button_pressed():
	OS.execute("cmd.exe", ["/c", "sc start " + vgc_service], [], false)
	await get_tree().create_timer(3.5).timeout
	
	var thread = Thread.new()
	thread.start(Callable(self, "_execute_vgtray_in_thread"))

func _execute_vgtray_in_thread():
	var config_file_read = FileAccess.open("res://config.txt", FileAccess.READ)
	var config_data = config_file_read.get_as_text()
	config_file_read.close()
	
	var full_path = config_data + "\\" + vanguardexe
	var commands = '@echo off && start "" "%s" && exit' % full_path
	OS.execute("cmd.exe", ["/c", commands], [], false)
	
func _on_stopvanguard_button_pressed():
	OS.execute("CMD.exe", ["/c", "sc stop " + vgc_service], [], false)
	OS.execute("CMD.exe", ["/c", "taskkill /F /IM vgtray.exe"], [], false)
	
func _on_closewindow_button_pressed():
	get_tree().quit()

func _on_minimizedwindow_button_pressed():
	get_tree().root.mode = Window.MODE_MINIMIZED
