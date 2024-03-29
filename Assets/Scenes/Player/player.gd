extends CharacterBody2D
class_name Player

enum grav{UP, DOWN}
@export var gravity_dir = grav.DOWN

@onready var remoteTransform = $RemoteTransform2D
@onready var FSM = $FiniteStateMachine as FiniteStateMachine
@onready var player_idle_state = $FiniteStateMachine/PlayerIdleState as PlayerIdleState
@onready var player_moving_state = $FiniteStateMachine/PlayerMovingState as PlayerMovingState
@onready var player_gravity_state = $FiniteStateMachine/PlayerGravityState as PlayerGravityState
@onready var player_speaking_state = $FiniteStateMachine/PlayerSpeakingState as PlayerSpeakingState
@onready var player_hiding_state = $FiniteStateMachine/PlayerHidingState as PlayerHidingState
@onready var player_waiting_state = $FiniteStateMachine/PlayerWaitingState as PlayerWaitingState

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	player_idle_state.player_moving.connect(FSM.change_state.bind(player_moving_state))
	player_idle_state.change_gravity.connect(FSM.change_state.bind(player_gravity_state))
	player_idle_state.player_speaking.connect(FSM.change_state.bind(player_speaking_state))
	player_idle_state.player_hiding.connect(FSM.change_state.bind(player_hiding_state))
	
	player_moving_state.change_gravity.connect(FSM.change_state.bind(player_gravity_state))
	player_moving_state.player_stopped.connect(FSM.change_state.bind(player_idle_state))
	player_moving_state.player_speaking.connect(FSM.change_state.bind(player_speaking_state))
	player_moving_state.player_hiding.connect(FSM.change_state.bind(player_hiding_state))
	
	player_hiding_state.player_moving.connect(FSM.change_state.bind(player_moving_state))
	
	player_gravity_state.gravity_changed.connect(FSM.change_state.bind(player_idle_state))
	
	player_speaking_state.dialogue_finished.connect(FSM.change_state.bind(player_idle_state))
	
	if gravity_dir == grav.UP:
		FSM.change_state(player_gravity_state)

func _physics_process(delta) -> void:
	apply_gravity(delta)
	move_and_slide()

func apply_gravity(delta) -> void:
	velocity.y += gravity * delta

func player_is_waiting():
	FSM.change_state(player_waiting_state)

func player_finished_waiting():
	FSM.change_state(player_idle_state)

func connect_camera(camera) -> void:
	var camera_path = camera.get_path()
	remoteTransform.remote_path = camera_path
	remoteTransform.rotation = camera.rotation
