extends Node

## Monetization
## Unified monetization interface. Stubbed until Phase 9.
## Allows the game to remain completely offline, testable, and cleanly decoupled.

signal ad_reward_granted(reward_id: String)
signal purchase_completed(product_id: String)
signal purchases_restored

func _ready() -> void:
	print("[Monetization] Autoload initialized (offline/stub mode).")

func show_rewarded_ad(reward_id: String) -> void:
	print("[Monetization] Stub: ad requested for reward '%s' (monetization stubbed)." % reward_id)

func purchase(product_id: String) -> void:
	print("[Monetization] Stub: purchase requested for '%s' (monetization stubbed)." % product_id)

func restore_purchases() -> void:
	print("[Monetization] Stub: restore purchases requested.")
	purchases_restored.emit()

func is_owned(_product_id: String) -> bool:
	return false

func ads_removed() -> bool:
	return false
