extends RefCounted

const StringExtra := preload("res://scripts/core/string_extra.gd")

var _sep_unit := "─"

func build_banner(title: String, width: int = 67) -> String:
	var inner := width - 2
	var line := _sep_unit.repeat(inner)
	var row := StringExtra.pad_right(" " + title + " ", inner)
	return "╔%s╗\n║%s║\n╚%s╝\n" % [line, row, line]

func format_repo_block(repo: Dictionary, line_width: int) -> String:
	var sep := _sep_unit.repeat(mini(40, line_width))
	var out := ""
	out += "▶ REPO: %s\n" % repo.get("name", "?")
	out += "  TYPE: %s\n" % repo.get("type", "?")
	out += "  SIZE: %.1f KB\n" % float(repo.get("size", 0.0))
	out += "  GIT: %s | DEPS: %s | TESTS: %s\n" % [
		"✓" if repo.get("git", false) else "✗",
		"✓" if repo.get("deps", false) else "✗",
		"✓" if repo.get("tests", false) else "✗",
	]
	out += sep + "\n"
	return out

func build_full_report(repos: Array, title: String) -> String:
	var width := 67
	var output := build_banner(title, width)
	output += "\nFOUND: %d repos\n\n" % repos.size()
	for repo in repos:
		output += format_repo_block(repo, width)
	output += "\nDEEPIRI VOX SCAN COMPLETE"
	return output
