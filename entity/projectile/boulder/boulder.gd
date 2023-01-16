extends BaseProjectile

onready var mesh_instance = $MeshInstance
onready var audio_stream_player_3_d_2 = $AudioStreamPlayer3D2
onready var cpu_particles = $CPUParticles

func _ready():
	audio_stream_player_3_d_2.unit_size = Global.sound_amplified
	mesh_instance.visible = false
	
func fire():
	.fire()
	
	mesh_instance.visible = true
	
func _on_hit():
	#._on_hit()
	
	cpu_particles.emitting = true
	
	audio_stream_player_3_d_2.stream = preload("res://assets/sound/explode3.wav")
	audio_stream_player_3_d_2.play()
	
	emit_signal("hit")
	set_process(false)
	mesh_instance.visible = false
	
	_arrow_stick.wait_time = 4
	_arrow_stick.start()
