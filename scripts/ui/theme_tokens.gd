class_name ThemeTokens
extends RefCounted

## ThemeTokens
## Centralized design tokens for Oshodimushin RPG per docs/07_UI_UX_GUIDE.md.
## Option A: "Danfo Poster" Art Direction (LOCKED)

# --- Palette: Option A "Danfo Poster" ---
const DANFO_YELLOW: Color = Color("#F7B500")   # Primary / Branding / Highlights
const ASPHALT_BLACK: Color = Color("#1B1B1F")  # Surface / Dark Panels / Outlines
const CHALK_WHITE: Color = Color("#F5F1E8")    # Text / Light Canvas
const NAIJA_GREEN: Color = Color("#1E8E4E")    # Money / Success / Prosperity
const SIGNAL_RED: Color = Color("#D8402F")     # Danger / Penalties / High Heat
const SKY_TEAL: Color = Color("#2BA6A0")       # Accent / Energy / Transit
const MUD_BROWN: Color = Color("#6B4A2F")      # Border / Wood / Warm Neutral

# Functional semantic aliases
const COLOR_PRIMARY: Color = DANFO_YELLOW
const COLOR_SURFACE: Color = ASPHALT_BLACK
const COLOR_SURFACE_LIGHT: Color = CHALK_WHITE
const COLOR_TEXT: Color = CHALK_WHITE
const COLOR_TEXT_DARK: Color = ASPHALT_BLACK
const COLOR_MONEY: Color = NAIJA_GREEN
const COLOR_DANGER: Color = SIGNAL_RED
const COLOR_ENERGY: Color = SKY_TEAL
const COLOR_BORDER: Color = MUD_BROWN

# --- Spacing: 8px Grid ---
const SPACE_XS: int = 8
const SPACE_S: int = 16
const SPACE_M: int = 24
const SPACE_L: int = 32
const SPACE_XL: int = 48

# --- Typography Scale ---
const FONT_BODY_SM: int = 14
const FONT_BODY: int = 16      # Body text never below 16
const FONT_LABEL: int = 18
const FONT_SUBTITLE: int = 24
const FONT_TITLE: int = 32
const FONT_HERO: int = 48

# --- Shape Language ---
const CORNER_RADIUS: int = 8
const BORDER_WIDTH_THICK: int = 3
const BORDER_WIDTH_NORMAL: int = 2
const MIN_TOUCH_TARGET: Vector2 = Vector2(48, 48)

# --- Formatting Helpers ---
static func get_palette_dictionary() -> Dictionary:
	return {
		"danfo_yellow": DANFO_YELLOW,
		"asphalt_black": ASPHALT_BLACK,
		"chalk_white": CHALK_WHITE,
		"naija_green": NAIJA_GREEN,
		"signal_red": SIGNAL_RED,
		"sky_teal": SKY_TEAL,
		"mud_brown": MUD_BROWN
	}
