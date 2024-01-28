class_name HealthBar
extends ProgressBar

func take_damage(damage_value: int):
	value = max(0, value - damage_value)
