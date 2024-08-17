extends Label

func update_text(current_warmth, max_warmth):
		text = """%s / %s""" % [current_warmth, max_warmth]
