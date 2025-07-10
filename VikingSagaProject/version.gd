# version.gd
# Autoload this as a singleton (Project -> Autoload)

extends Node

const MAJOR := 0
const MINOR := 1
const PATCH := 0
const STAGE := ""  # Can be: "", "alpha", "beta", "rc1", etc.
const BUILD := 42      # Optional build number (for CI, etc.)

func get_version_string() -> String:
	var version = "%d.%d.%d" % [MAJOR, MINOR, PATCH]
	if STAGE != "":
		version += "-%s" % STAGE
	return version

func get_full_version_string() -> String:
	var version = get_version_string()
	version += "+build%d" % BUILD
	return version
