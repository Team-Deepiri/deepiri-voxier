extends Control

const _AsciiReportBuilder := preload("res://scripts/vox/ascii_report_builder.gd")
const _DeepiriConstants := preload("res://scripts/core/deepiri_constants.gd")
const _Scenes := preload("res://scripts/ui/scene_registry.gd")
const _UiAudio := preload("res://scripts/audio/ui_audio.gd")
const _AudioIds := preload("res://scripts/audio/audio_ids.gd")

@onready var rich_text_label = $Panel/VBoxContainer/RichTextLabel
@onready var scan_button = $Panel/VBoxContainer/ScanButton
@onready var back_button = $Panel/VBoxContainer/BackButton

var analyzer := VoxAnalyzer.new()
var _report_builder := _AsciiReportBuilder.new()
var _session := VoxScanSession.new()

func _ready():
	_UiAudio.wire_button(scan_button)
	_UiAudio.wire_button(back_button)
	rich_text_label.text = _report_builder.build_banner(_DeepiriConstants.VOX_TITLE)
	rich_text_label.text += "\n\nREADY TO SCAN..."

func _on_scan_button_pressed():
	EventBus.sfx_requested.emit(_AudioIds.BONUS)
	_session.begin()
	var root_path := DeepiriPaths.workspace_parent_from_project()
	EventBus.vox_scan_started.emit(root_path)
	rich_text_label.text = "SCANNING...\n"
	var repos := analyzer.scan_repos(root_path)
	EventBus.vox_scan_finished.emit(repos.size())
	rich_text_label.text = _report_builder.build_full_report(repos, _DeepiriConstants.VOX_TITLE)
	rich_text_label.text += "\n\n(%d ms)" % _session.elapsed_msec()

func _on_back_button_pressed():
	EventBus.sfx_requested.emit(_AudioIds.UI_BACK)
	get_tree().change_scene_to_file(_Scenes.MAIN)