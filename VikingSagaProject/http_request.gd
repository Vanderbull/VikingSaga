extends HTTPRequest

@onready var globals = get_node("/root/Globals")

func _ready():
	print("HTTPRequest _ready()...")
	request_completed.connect(_on_request_completed)
	request("https://api.github.com/repos/godotengine/godot/releases/latest")
	

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json["name"])
	globals.godot_version = json["name"]
