extends Node

## SaveSystem
## Manages save files (user://saves/slot_N.json), save versions, and schema migration.
## Implemented in Phase 5.

signal save_completed(slot: int, success: bool)
signal load_completed(slot: int, success: bool)

func _ready() -> void:
	print("[SaveSystem] Autoload initialized.")
