@tool
extends Node

const META_FILE := "res://build_meta.json"
var _has_updated := false
func _ready():
	# Only run when testing in the editor
	if OS.has_feature("editor") and !_has_updated:
		_has_updated = true
		update_build_meta()

func update_build_meta():
	var data := {
		"build": 1,
		"commit": "",
		"date": Time.get_datetime_string_from_system()
	}

	# Read existing data
	if FileAccess.file_exists(META_FILE):
		var file = FileAccess.open(META_FILE, FileAccess.READ)
		var text = file.get_as_text()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has("build"):
			data = parsed
			data["build"] += 1

	data["date"] = Time.get_datetime_string_from_system()

	# Save back to file
	var out_file = FileAccess.open(META_FILE, FileAccess.WRITE)
	out_file.store_string(JSON.stringify(data, "\t"))
	print("✅ Build updated:", data)
