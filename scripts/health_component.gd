extends Node
class_name HealthComponent

@export var max_health: int = 10
@export var init_health: int = 10
var health: int:
    get: return _health

@onready var _health: int = init_health

signal health_changed(new_health: int)
signal health_depleted()


func add_health(damage: int):
    _health_change(damage)


func remove_health(damage: int):
    _health_change(-damage)


func is_health_depleted() -> bool:
    return _health <= 0


func _health_change(change: int) -> void:
    _health += change
    if _health <= 0:
        _health = 0
        health_depleted.emit()
    
    health_changed.emit(_health)