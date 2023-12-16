extends Node
class_name Terrain

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Terrain")
@export var tilemap : TileMap = null

# ------------------------------------------------------------------------------
# Static Variables
# ------------------------------------------------------------------------------
static var _instance : Terrain = null

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_instance = self

# ------------------------------------------------------------------------------
# Public Static Methods
# ------------------------------------------------------------------------------
static func Get_Tile_Data_At(position : Vector2) -> TileData:
	if _instance == null: return null
	if _instance.tilemap == null: return null
	var map_pos : Vector2i = _instance.tilemap.local_to_map(position)
	return _instance.tilemap.get_cell_tile_data(0, map_pos)

static func Get_Custom_Data_At(position : Vector2, custom_data_name : String, default : Variant = null) -> Variant:
	var data : TileData = Get_Tile_Data_At(position)
	if data == null: return default
	return data.get_custom_data(custom_data_name)

static func Has_Tile_At(position : Vector2) -> bool:
	return Get_Tile_Data_At(position) != null

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------



