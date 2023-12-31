extends Node
class_name Iso

# ------------------------------------------------------------------------------
# Static Public Methods
# ------------------------------------------------------------------------------
static func from_cartesian(coords : Vector2) -> Vector2:
	var iso : Vector2 = Vector2(
		coords.x - coords.y,
		(coords.x + coords.y) * 0.5
	)
	return iso
