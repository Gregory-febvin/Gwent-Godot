extends Node2D

const colmision_mask_card = 1
var screen_size
var card_being_dragged

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))
		

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT: 
		if event.pressed:
			#print("Click")
			var card = raycast_check()
			if card:
				card_being_dragged = card
				
		else:
			card_being_dragged = null

func connect_card_signels(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	
func on_hovered_over_card(card):
	highlight_card(card, true)

func on_hovered_off_card(card):
	highlight_card(card, false)

func highlight_card(card,hovered):
	if hovered:
		card.scale = Vector2(1.05,1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1.0,1.0)
		card.z_index = 1

func raycast_check():
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = colmision_mask_card
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
