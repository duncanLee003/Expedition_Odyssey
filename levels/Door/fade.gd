extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

func _ready():
	rect.color.a = 0.0
	rect.visible = true

func fade_out(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(rect, "color:a", 1.0, duration)
	await tween.finished

func fade_in(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(rect, "color:a", 0.0, duration)
	await tween.finished
