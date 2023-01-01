extends Node
class_name NoiseMaker

var _noises :Array = []
var _rng_noise_seed :int = 0

func make_noise(noise_seed, noise_count :int):
	_rng_noise_seed = noise_seed + noise_count
	var _rng = RandomNumberGenerator.new()
	_rng.seed = _rng_noise_seed
	
	for i in range(noise_count):
		var noise = OpenSimplexNoise.new()
		noise.seed = noise_seed + i
		noise.octaves = _rng.randi_range(6,8)
		noise.period = float(_rng.randi_range(70,80))
		_noises.append(noise)
		
func get_noise(_at :Vector3):
	var value :float = 0.0
	
	for _noise in _noises:
		var val = _noise.get_noise_3d(
			_at.x ,_at.y ,_at.z 
		)
		value += (value + val) / 2
		value = clamp(value, 0.2, 1.0)
		
	return value
