extends Node

## EventBus
## Central event/signal bus decoupling core logic (scripts/core/) from UI (scenes/, scripts/ui/).

signal situation_triggered(situation_id: String)
signal situation_resolved(outcome: Dictionary)
signal quest_updated(quest_id: String, step_id: String)
signal location_changed(new_location_id: String)
signal activity_started(activity_id: String)

func _ready() -> void:
	print("[EventBus] Autoload initialized.")
