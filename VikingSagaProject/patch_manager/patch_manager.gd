extends Node

class_name PatchManager

# Function to apply a patch from a JSON file
func apply_patch(patch_file_path: String):
	var patch_file = FileAccess.open(patch_file_path, FileAccess.READ)
	if patch_file:
		var patch_text = patch_file.get_as_text()
		patch_file.close()
		
		var json = JSON.new()
		var json_result = json.parse(patch_text)
		if json_result == OK:
			var patch_data = json.get_data()
			if typeof(patch_data) == TYPE_DICTIONARY:
				_apply_patch_data(patch_data)
			else:
				push_error("Invalid patch data format: Expected a dictionary.")
		else:
			push_error("Failed to parse JSON: %s" % json.get_error_message())
	else:
		push_error("Patch file does not exist: %s" % patch_file_path)

# Internal function to apply patch data
func _apply_patch_data(patch_data: Dictionary):
	for key in patch_data.keys():
		var value = patch_data[key]
		# Apply patch to the corresponding game object or setting
		_apply_patch_to_object(key, value)

# Function to apply patch data to a specific object
func _apply_patch_to_object(key: String, value: Dictionary):
	var obj = get_node_or_null(key)
	
	if obj:
		for property_name in value.keys():
			if obj is Label and property_name == "text":
				obj.text = value[property_name]
			#if obj.has_method(property_name):
				#obj.call(property_name, value[property_name])
			#elif obj.has_property(property_name):
				#obj.set(property_name, value[property_name])
			else:
				push_warning("Property or method '%s' not found on object '%s'" % [property_name, key])
	else:
		push_warning("Object '%s' not found in the scene tree." % key)
