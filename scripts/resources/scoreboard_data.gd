extends Resource
class_name ScoreboardData

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal level_added()
signal entry_added(level_name : String)

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
		_AddEntry(entry)
	changed.emit()

func _AddEntry(entry : ScoreboardEntry) -> int:
	if entry.score <= 0 or entry.level_name.is_empty() or entry.player_name.is_empty():
		return ERR_INVALID_DATA
	if _elist.find(entry) >= 0:
		return ERR_ALREADY_IN_USE
	
	if not entry.level_name in _edict:
		_edict[entry.level_name] = []
	
	var llist : Array = _edict[entry.level_name]
	if llist.size() <= 0: # Auto add if there're no current tries
		llist.append(entry)
		_elist.append(entry)
	elif llist[-1].score > entry.score: # Append to the end if the last entry is bigger than the given
		if llist.size() < MAX_ENTRIES_PER_LEVEL: # Assuming max entries are not already reached.
			llist.append(entry)
			_elist.append(entry)
	else: # Otherwise, find where in the list to insert the entry
		for idx : int in range(llist.size()):
			if llist[idx].score >= entry.score: continue
			llist.insert(idx, entry)
			_elist.append(entry)
			break
			
	return OK
	#if llist.size() == MAX_ENTRIES_PER_LEVEL:
		#var reducer : Callable = func(accum : ScoreboardEntry, item : ScoreboardEntry):
			#if accum == null: return item
			#if item.score < accum.score:
				#return item
			#return accum
		#var smallest : ScoreboardEntry = llist.reduce(reducer, null)
		#if smallest.score < entry.score:
			#var idx : int = llist.find(smallest)
			#if idx >= 0:
				#llist.remove_at(idx)
			#idx = _elist.find(smallest)
			#if idx >= 0:
				#_elist.remove_at(idx)
	#
	#if llist.size() < MAX_ENTRIES_PER_LEVEL:
		#llist.append(entry)
		#_elist.append(entry)
		#return OK
	## Technically, we should never get here, but let's be SURE
	#return ERR_SCRIPT_FAILED

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

func create_entry(level_name : String, player_name : String, score : int) -> void:
	if score <= 0 or level_name.is_empty() or player_name.is_empty(): return
	var entry : ScoreboardEntry = ScoreboardEntry.new()
	entry.level_name = level_name
	entry.player_name = player_name
	entry.score = score
	add_entry(entry)

func add_entry(entry : ScoreboardEntry) -> void:
	var lcount : int = _edict.size()
	var res : int = _AddEntry(entry)
	if res == OK:
		if _edict.size() > lcount:
			level_added.emit()
		entry_added.emit(entry.level_name)
		changed.emit()
	elif res == ERR_SCRIPT_FAILED:
		printerr("ERROR: Failed to properly handle scoreboard entry!")

func get_levels() -> Array:
	return _edict.keys()

func get_level_name() -> String:
	var level_names : Array = _edict.keys()
	if level_names.size() > 0:
		return level_names[0]
	return ""

func get_next_level_name(level_name : String) -> String:
	var level_names : Array = _edict.keys()
	var idx : int = level_names.find(level_name)
	if idx < 0: return ""
	idx = 0 if idx + 1 == level_names.size() else idx + 1
	return level_names[idx]

func get_previous_level_name(level_name : String) -> String:
	var level_names : Array = _edict.keys()
	var idx : int = level_names.find(level_name)
	if idx < 0: return ""
	idx = level_names.size() - 1 if idx < 1 else idx - 1
	return level_names[idx]

func has_level_entries(level_name : String) -> bool:
	return level_name in _edict

func get_level_entries(level_name : String) -> Array[ScoreboardEntry]:
	if level_name in _edict:
		return _edict[level_name].duplicate()
	return []

func get_level_entry(level_name : String, index : int) -> ScoreboardEntry:
	if not level_name in _edict : return null
	if index < 0 or _edict[level_name].size() <= index: return null
	return _edict[level_name][index]

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

