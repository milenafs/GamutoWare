extends "res://principal/cenas/scripts/ToTitle.gd"


const CoverButton = preload("res://principal/cenas/CoverButton.tscn")
const LOCKED_COVER = preload("res://principal/recursos/sprites/capalocked.png")


const MINIGAMES_POS = Vector2(0, 0)
const DETAILS_POS = Vector2(0, -1080)
const LERP_WEIGHT = 0.15

const TOTAL_COVER_COLLUMS = 2


var last_focus
var aim_pos = MINIGAMES_POS


@onready var minigame_data = preload("res://principal/recursos/data/Minigames.gd").new().minigame_data
@onready var credits = $Credits
@onready var minigames_container = $Credits/Minigames/VBoxContainer/Minigames/GridContainer
@onready var menu_button = $Credits/Minigames/VBoxContainer/Menu

@onready var credits_info = $Credits/CreditosInfo


func _ready():
	for minigame in minigame_data:
		var new_cover_button = CoverButton.instantiate()
		var active = Global.check_minigame(minigame)
		new_cover_button.load_button(active, minigame, self)
		
		if active:
			new_cover_button.load_cover(load(minigame_data[minigame]["cover"]))
		else: 
			new_cover_button.load_cover(LOCKED_COVER)
		
		minigames_container.add_child(new_cover_button)
	
	var cover_buttons = minigames_container.get_children()
	for i in range(len(cover_buttons)):
		var top = cover_buttons[i].button.get_path_to(menu_button)
		if i >= TOTAL_COVER_COLLUMS:
			top = cover_buttons[i].button.get_path_to(cover_buttons[i - TOTAL_COVER_COLLUMS].button)
		
		var right = cover_buttons[i].button.get_path_to(cover_buttons[i - i % TOTAL_COVER_COLLUMS].button)
		if i % TOTAL_COVER_COLLUMS != TOTAL_COVER_COLLUMS - 1 and i + 1 < len(cover_buttons):
			right = cover_buttons[i].button.get_path_to(cover_buttons[i + 1].button)
		
		var bottom = cover_buttons[i].button.get_path_to(menu_button)
		if i < len(cover_buttons) - len(cover_buttons) % TOTAL_COVER_COLLUMS:
			bottom = cover_buttons[i].button.get_path_to(cover_buttons[min(len(cover_buttons) - 1, i + TOTAL_COVER_COLLUMS)].button)
		
		var left = cover_buttons[i].button.get_path_to(cover_buttons[min(i + TOTAL_COVER_COLLUMS - i % TOTAL_COVER_COLLUMS - 1, len(cover_buttons) - 1)].button)
		if i % TOTAL_COVER_COLLUMS != 0 and i - 1 >= 0:
			left = cover_buttons[i].button.get_path_to(cover_buttons[i - 1].button)
		
		cover_buttons[i].set_focuses(top, right, bottom, left)
	
	menu_button.focus_neighbor_top = menu_button.get_path_to(cover_buttons[len(cover_buttons) - 1].button)
	menu_button.focus_neighbor_bottom = menu_button.get_path_to(cover_buttons[0].button)
	
	menu_button.grab_focus()


func _input(event):
	if Input.is_action_just_pressed("sair") and block_menu:
		call_deferred("back_to_covers")


func _process(delta):
	credits.position = credits.position.lerp(aim_pos, LERP_WEIGHT)


func detail(path, button):
	SoundController.play_sfx("click")
	
	var credits_data = load(minigame_data[path]["credits"]).new()
	
	var title
	var body
	match Global.language:
		Global.LANGUAGE.PT:
			title = credits_data.title_pt
			body = credits_data.credits_pt
		Global.LANGUAGE.EN:
			title = credits_data.title_en
			body = credits_data.credits_en
	
	credits_info.display(title, body)

func fail_detail():
	SoundController.play_sfx("damage")


func back_to_covers():
	block_menu = false
	
	SoundController.play_sfx("click")
	
	if last_focus != null:
		last_focus.grab_focus()
	else:
		menu_button.grab_focus()
	
	aim_pos = MINIGAMES_POS
