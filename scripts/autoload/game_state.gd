extends Node

## GameState
## The single source of truth for player data, world state, and current session.
## Full player stats, resources, inventory, and progression are implemented in Phase 1 & 2.

signal player_data_changed
signal time_advanced(day: int, time_block: String)

func _ready() -> void:
	print("[GameState] Autoload initialized.")
