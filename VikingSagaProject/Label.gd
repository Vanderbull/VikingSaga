extends Label


func update_text(level, experience, required_experience):
		text = """Level: %s
				Experience: %s
				Next level: %s
				""" % [level,experience,required_experience]
