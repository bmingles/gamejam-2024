class_name HurtBox
extends Area2D

func _init():
	collision_layer = 0
	collision_mask = 2

func _ready():
	connect("area_entered", _on_area_entered)
	
func _on_area_entered(hitbox: HitBox):
	if hitbox == null or hitbox.owner == owner:
		return
		
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
