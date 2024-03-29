extends Node2D

@onready var player = $Player
@onready var main_camera = $Camera2D
var player_dir = preload("res://Assets/Scenes/Player/player.tscn")

@onready var start_menu = $UI/start_menu
@onready var death_report = $UI/DeathReport
@onready var quests_box = $UI/QuestsBox

enum {NORMAL, DEATH_REPORT}
var state = NORMAL

var player_name:String = "Lolmaniaco"
var last_character_spoken:String = ""
var checkpoint_pos:Vector2 = Vector2.ZERO

func _ready():
	player.connect_camera(main_camera)
	Events.player_dead.connect(_on_player_dead)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(_delta):
	match state:
		NORMAL: normal_state()
		DEATH_REPORT: death_report_state()

func normal_state():
	if Input.is_action_just_pressed("Menú"):
		if get_tree().paused == true:
			start_menu.resume_game()
		else:
			start_menu.pause_game()

func death_report_state():
	if Input.is_action_just_pressed("ChangeGravity"):
		var new_player = player_dir.instantiate()
		add_child(new_player)
		new_player.global_position = checkpoint_pos
		player = new_player
		player.connect_camera(main_camera)
		
		death_report.visible = false
		quests_box.visible = true
		state = NORMAL

func _on_dialogue_ended(_resource:DialogueResource):
	last_character_spoken = Events.get_last_character_spoken_to()

func _on_player_dead(death_cause:String):
	checkpoint_pos = Journal.get_checkpoint_pos()
	var memories = ""
	match last_character_spoken:
		"Berta": memories = "I kept studying those dark flashes until darkness came for me. Now, I write these memories with my last remains knowing that we won't see each other again, nor our beloved Earth..."
		"Guturu": memories = "Dofus was my only world, my single obsession and I played til millenia reached my last breath. Only then, I could take my sight out of the screen, watching as the world had been devoured by darkness..."
		_: memories = "From ashes you were born and in ashes you'll go back. Embrace your new form, for after your death you will become the herald of the forthcoming dark empire..."
	
	death_cause = death_cause.to_upper()
	var description = ""
	match death_cause:
		"SPIKES": description = "The victim steped into poisoned spikes. Slight cuts injected venom through the blood vessels reaching in a couple of second to the brain, causing instant paralysis and death"
		"FLAMES": description = "Chemical fire caused an instant shock of pain into the body. The victim fell unconscious dying moments later due to repetitive burns."
		"FISSURE": description = "After revising the station's black box, we found out that the victim was sucked into outer space. The oxygen tank lasted for about 8 hours, but the slow and peaceful death was known from the beginning."
		"VOIDLING": description = "Several bodies were found merged inside the aggresive ameba. Muscles, tenders and bones were deformed to be the vessel of a horrific brand new being."
		_: description = "Fatal Error. Player killed by unknown danger."

	death_report.set_death_report_data(player_name, Time.get_date_dict_from_system(), memories, description)
	death_report.visible = true
	quests_box.visible = false
	state = DEATH_REPORT
