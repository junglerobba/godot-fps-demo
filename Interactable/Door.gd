extends Interactable

export var open: bool = false

onready var anim_player: AnimationPlayer = $"../../AnimationPlayer"

func get_interaction_text() -> String:
	return "Close door" if open else "Open door"

func interact() -> void:
	open = !open
	if open:
		anim_player.play("open")
	else:
		anim_player.play_backwards("open")
