extends BaseCustomParticle
class_name CustomMeshParticle

func on_pre_emmit():
	.on_pre_emmit()
	_emmit_timer.wait_time = 2.1
	amount = int(rand_range(4, 8))
