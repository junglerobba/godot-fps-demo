extends RayCast

onready var interaction_label: Label = $"../../../HUD/InteractionLabel"

var current_collider: Object

func _ready() -> void:
	set_interaction_text("")

func _process(_delta: float) -> void:
	var collider: Object = get_collider()
	
	if is_colliding() && collider is Interactable:
		if current_collider != collider:
			set_interaction_text(collider.get_interaction_text())
			current_collider = collider
		
		if Input.is_action_just_pressed("interact"):
			collider.interact()
			set_interaction_text(collider.get_interaction_text())
	
	elif current_collider:
		current_collider = null
		set_interaction_text("")

func set_interaction_text(text: String) -> void:
	if !text:
		interaction_label.set_text("")
		interaction_label.set_visible(false)
		return
	var interact_key: = OS.get_scancode_string(InputMap.get_action_list("interact")[0].scancode)
	interaction_label.set_text("Press %s to %s" % [interact_key, text])
	interaction_label.set_visible(true)
