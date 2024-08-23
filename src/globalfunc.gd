extends Control

var message = ""

func send_message(message_content: String):
	message = message_content

func get_message() -> String:
	return message
