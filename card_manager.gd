extends Node2D

const colmision_mask_card = 1
const colmision_mask_card_slot = 2
var screen_size
var card_being_dragged

var is_hovering_on_card

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
				start_drag(card)
		else:
			if card_being_dragged:
				finish_drag()

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1.0,1.0)
	
func finish_drag():
	card_being_dragged.scale = Vector2(1.10,1.10)
	var card_slot_found = raycast_check_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		#card drop in a empty card slot
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot_found.card_in_slot = true
	card_being_dragged = null

func connect_card_signels(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	
func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

func on_hovered_off_card(card):
	if !card_being_dragged:
		#if not dragging
		highlight_card(card, false)
		#Check if hovered off is on top off another card
		var new_card_cover = raycast_check()
		if new_card_cover:
			highlight_card(new_card_cover, true)
		else:
			is_hovering_on_card = false

func highlight_card(card,hovered):
	if hovered:
		card.scale = Vector2(1.10,1.10)
		card.z_index = 2
	else:
		card.scale = Vector2(1.0,1.0)
		card.z_index = 1

func raycast_check_slot():
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = colmision_mask_card_slot
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func raycast_check():
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = colmision_mask_card
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		#return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards):
	#Assume that the first card in cards array have the highest z index
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	#Loop in all cards and check for the highest z index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
