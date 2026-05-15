extends Label

var showing := false

func show_update():

	if showing:
		return

	showing = true

	visible = true
	modulate.a = 1.0

	await get_tree().create_timer(2.0).timeout

	visible = false

	showing = false
