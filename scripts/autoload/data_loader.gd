extends Node

## DataLoader
## Loads and validates JSON game data files at startup per docs/03_DATA_SCHEMAS.md.
## Full validation logic and data stores are implemented in Phase 1.

signal data_loaded(success: bool)

func _ready() -> void:
	print("[DataLoader] Autoload initialized.")
