extends Resource
class_name ScoreboardData

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const MAX_ENTRIES_PER_LEVEL : int = 10

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Scoreboard Data")
@export var entries : Array[ScoreboardEntry]:			set = set_entries, get = get_entries

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _elist : Array[ScoreboardEntry] = []
var _edict : Dictionary = {}

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_entries(e : Array[ScoreboardEntry]) -> void:
	_RebuildFrom(e)

func get_entries() -> Array[ScoreboardEntry]:
	return _elist

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if entries.size() > 0 and _edict.is_empty():
		_RebuildFrom(entries)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _RebuildFrom(e : Array[ScoreboardEntry]) -> void:
	_edict.clear()
	_elist.clear()
	for entry : ScoreboardEntry in e:
		add_entry(entry)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func size() -> int:
	return _elist.size()

func level_count() -> int:
	return _edict.keys().size()

func level_entry_count(level_name : String) -> int:
	if not level_name in _edict: return 0
	return _edict[level_name].size()

func add_entry(entry : ScoreboardEntry) -> void:
	if entry.score <= 0 or entry.level_name.is_empty() or entry.player_name.is_empty(): return
	if _elist.find(entry) >= 0: return # Don't add duplicates
	
	if not entry.level_name in _edict:
		_edict[entry.level_name] = []
	
	var llist : Array = _edict[entry.level_name]
	if llist.size() == MAX_ENTRIES_PER_LEVEL:
		var reducer : Callable = func(accum : ScoreboardEntry, item : ScoreboardEntry):
			if accum == null: return item
			if item.score < accum.score:
				return item
			return accum
		var smallest : ScoreboardEntry = llist.reduce(reducer, null)
		if smallest.score < entry.score:
			var idx : int = llist.find(smallest)
			if idx >= 0:
				llist.remove_at(idx)
			idx = _elist.find(smallest)
			if idx >= 0:
				_elist.remove_at(idx)
	
	if llist.size() < MAX_ENTRIES_PER_LEVEL:
		llist.append(entry)
		_elist.append(entry)

func get_levels() -> Array:
	return _edict.keys()

func get_level_entries(level_name : String) -> Array[ScoreboardEntry]:
	if level_name in _edict:
		return _edict[level_name].duplicate()
	return []

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
