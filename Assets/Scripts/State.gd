extends Node
class_name State

@export var SPEED: int = 200
@export var player: Player
@export var animator: AnimationPlayer

var gravity:float = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_talk:bool = false

signal state_finished

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(_delta) -> void:
	pass

func handle_player_crouching():
	if Input.is_action_just_pressed("KeyDown"):
		animator.play("duck_down")
		Events.crouched = true
	if Input.is_action_just_released("KeyDown"):
		animator.play("duck_up")
		Events.crouched = false
