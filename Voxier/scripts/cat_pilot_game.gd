extends Node2D

const _Scenes := preload("res://scripts/ui/scene_registry.gd")

var levels = {
	1: {"name": "Nebula Drift", "chance": 0.25, "types": ["asteroid"]},
	2: {"name": "Asteroid Belt", "chance": 0.35, "types": ["asteroid"]},
	3: {"name": "Alien Swarm", "chance": 0.45, "types": ["asteroid", "alien"]},
	4: {"name": "Meteor Storm", "chance": 0.55, "types": ["asteroid", "alien", "star"]},
	5: {"name": "VOID ZONE", "chance": 0.7, "types": ["asteroid", "alien", "star", "boss"]},
}

var current_level = 1
var score = 0
var turn = 0
var max_turns = 30
var px = 25
var objects = []
var game_active = false
var waiting_for_input = false

@onready var ui_label = $CanvasLayer/Control/RichTextLabel
@onready var game_timer = $GameTimer

func _ready():
	start_mission(current_level)

func start_mission(level_num):
	EventBus.sfx_requested.emit(&"game_start")
	current_level = level_num
	score = 0
	turn = 0
	px = 25
	objects = []
	game_active = true
	game_timer.start()
	draw_game()

func _on_game_timer_timeout():
	if not game_active: return
	
	turn += 1
	if turn > max_turns:
		complete_mission()
		return
	
	# Spawn objects
	var lvl = levels[current_level]
	if randf() < lvl["chance"]:
		var otype = lvl["types"].pick_random()
		var ox = randi_range(2, 52)
		objects.append({"x": ox, "y": 0, "type": otype})
	
	# Move objects
	for obj in objects:
		obj["y"] += 1
	
	# Check collisions 
	var hit = false
	for obj in objects:
		if obj["y"] >= 13 and abs(obj["x"] - px) < 3: #make the final int larger for a bigger hitbox
			hit = true
			break
	
	if hit:
		EventBus.sfx_requested.emit(&"hurt")
		game_over()
		return
	
	# Score for escaped objects
	var new_objects = []
	for obj in objects:
		if obj["y"] > 14:
			score += 10
		else:
			new_objects.append(obj)
	objects = new_objects
	
	draw_game()	

#adding a function to create padding, as .center() is not a gdscript func
func center_text(text: String, width: int) -> String:
	var padding := width - text.length()
	var left_pad := padding / 2
	var right_pad := padding - left_pad
	return " ".repeat(left_pad) + text + " ".repeat(right_pad)

func draw_game():
	var lvl = levels[current_level]
	var output = "╔" + "═".repeat(58) + "╗\n"
	output += "║★ C.A.T. PILOT ★"  + center_text(lvl["name"], 71) + " SCORE:%4d ║\n" % score
	output += "╠" + "═".repeat(58) + "╣\n"
	
	for y in range(15):
		var line = "║ "
		if y == 13:
			var lr = "< " if px < 25 else "> "
			line += " " + lr + "🐱 "
			line += "─".repeat(px) + "🚀"
		else:
			#add space for formatting ************************************
			line += " ".repeat(10)
			for x in range(56):
				var hit = false
				for obj in objects:
					if obj["x"] == x and obj["y"] == y:
						match obj["type"]:
							"asteroid": line += "●"
							"alien": line += "✖"
							"star": line += "✦"
							"boss": line += "§"
							_: line += "o"
						hit = true
						break
				if not hit:
					line += "·"
		line += " ".repeat(15)
		line = line.left(106)+ " ║\n"
		output += line
	
	output += "╠" + "═".repeat(58) + "╣\n"
	output += "║ [L] LEFT | [R] RIGHT | [Q] ABORT | [Space] CONTINUE " +" ".repeat(35) + "║\n"
	output += "╚" + "═".repeat(58) + "╝\n"
	
	var progress = "█".repeat(turn * 5) + "░".repeat(100 - turn * 5)
	output += " TURN:%d/%d | POS:%d | PROGRESS:%s\n" % [turn,max_turns, px, progress.left(20)]
	
	ui_label.text = output

func _input(event):
	if not game_active: return
	
	if event.is_action_pressed("move_left") or (event is InputEventKey and event.keycode == KEY_L):
		px = max(2, px - 4)
		draw_game()
	elif event.is_action_pressed("move_right") or (event is InputEventKey and event.keycode == KEY_R):
		px = min(52, px + 4)
		draw_game()
	elif event is InputEventKey and event.keycode == KEY_Q:
		game_active = false
		current_level = 1
		EventBus.sfx_requested.emit(&"ui_back")
		get_tree().change_scene_to_file(_Scenes.MAIN)

	

func game_over():
	game_active = false
	EventBus.sfx_requested.emit(&"game_over")
	ui_label.text += "\nCRITICAL FAILURE! COLLISION DETECTED!\nFinal Score: %d" % score
	current_level = 1 # REMOVE IF NOT WANTED, RESETS PLAYER BACK TO LVL 1 ON GAME OVER	
	game_timer.stop()
	waiting_for_input = true

func complete_mission():
	game_active = false
	EventBus.sfx_requested.emit(&"pickup")
	score += 100
	ui_label.text += "\n★ MISSION COMPLETE! ★\nFinal Score: %d \n Press [SPACE] to continue!" % score
	current_level += 1
	game_timer.stop()
	waiting_for_input = true

#Creates a different input method to end or restart game
func _unhandled_input(event: InputEvent) -> void:
	if not waiting_for_input:
		return
	if event.is_action_pressed("fire"):
		_ready()
	elif event is InputEventKey and event.keycode == KEY_Q:
		EventBus.sfx_requested.emit(&"ui_back")
		get_tree().change_scene_to_file(_Scenes.MAIN)
	
