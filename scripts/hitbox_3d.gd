extends Area3D
class_name HitBox3D

@export var _health_component: HealthComponent
@export var _damage_multiplier: float = 1.0

signal hit(damage: int)

### Damages the hitbox
#   offset: The damage offset to add to the health. If you
func damage(offset: int) -> void:
    assert(_health_component, "%s has no HealthComponent assigned!" % name)

    if offset > 0:
        _health_component.remove_health(int(offset * _damage_multiplier))
        hit.emit(offset * _damage_multiplier)
    elif offset < 0:
        _health_component.add_health(-offset)   # Healing