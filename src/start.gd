extends Control

@onready var browser_button := $browserbutton
@onready var filedialog := $FileDialog

@onready var closewindow_button := $window_buttons/closebutton
@onready var minimizewindow_button := $window_buttons/minimizebutton

@onready var errorlabel_Text := $errorlabel

var dragging = false
var drag_offset = Vector2()

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("test")
			dragging = true
			drag_offset = event.position
		else:
			dragging = false

	if event is InputEventMouseMotion and dragging:
		# Converte manualmente Vector2i para Vector2
		var window_position = Vector2(DisplayServer.window_get_position().x, DisplayServer.window_get_position().y)
		var new_position = window_position + event.position - drag_offset
		DisplayServer.window_set_position(new_position)

func _ready():
	
	var config_file = "res://config.txt"
	if FileAccess.file_exists(config_file):
		get_tree().change_scene_to_file("res://main.tscn")
	
	errorlabel_Text.visible = false
	
	closewindow_button.pressed.connect(Callable(self, "_on_closewindow_button_pressed"))
	minimizewindow_button.pressed.connect(Callable(self, "_on_minimizedwindow_button_pressed"))
	
	filedialog.set_size(Vector2(600, 460))
	filedialog.current_dir = "C:/"
	
	browser_button.pressed.connect(Callable(self, "_on_browser_button_pressed"))
	filedialog.connect("dir_selected", Callable(self, "_on_filedialog_dir_selected"))

func _on_browser_button_pressed():
	filedialog.popup()

func _on_filedialog_dir_selected(dir_path):
	Globalfunc.send_message(dir_path)
	if dir_path.ends_with("Riot Vanguard/") or dir_path.ends_with("Riot Vanguard"):
		get_tree().change_scene_to_file("res://main.tscn")
		var config_file = FileAccess.open("res://config.txt", FileAccess.WRITE)
		config_file.store_string(dir_path)
		config_file.close()
	else:
		errorlabel_Text.visible = true

func _on_closewindow_button_pressed():
	get_tree().quit()

func _on_minimizedwindow_button_pressed():
	get_tree().root.mode = Window.MODE_MINIMIZED
