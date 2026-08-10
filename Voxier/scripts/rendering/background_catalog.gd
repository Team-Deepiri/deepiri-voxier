extends RefCounted
class_name BackgroundCatalog

const PROFILES := [
	"res://resources/backgrounds/sector_space.tres",
	"res://resources/backgrounds/sector_city.tres",
	"res://resources/backgrounds/sector_desert.tres",
	"res://resources/backgrounds/sector_forest.tres",
	"res://resources/backgrounds/sector_stratus.tres",
	"res://resources/backgrounds/sector_deep.tres",
]

const THEME_PROFILES := {
	&"courier": "res://resources/backgrounds/sector_space.tres",
	&"stratus": "res://resources/backgrounds/sector_stratus.tres",
	&"ceramic": "res://resources/backgrounds/sector_desert.tres",
	&"deep": "res://resources/backgrounds/sector_deep.tres",
	&"final": "res://resources/backgrounds/sector_forest.tres",
}


static func profile_for_theme(theme: StringName) -> BackgroundProfile:
	var path: String = THEME_PROFILES.get(theme, &"res://resources/backgrounds/sector_space.tres")
	var p := load(path) as BackgroundProfile
	if p:
		return p
	return profile_at(0)

static func profile_count() -> int:
	return PROFILES.size()


static func profile_at(index: int) -> BackgroundProfile:
	var i := posmod(index, PROFILES.size())
	var res := load(PROFILES[i]) as BackgroundProfile
	if res:
		return res
	return BackgroundProfile.new()


static func profile_for_biome(biome_id: int) -> BackgroundProfile:
	for path in PROFILES:
		var p := load(path) as BackgroundProfile
		if p and p.biome_id == biome_id:
			return p
	return profile_at(0)
