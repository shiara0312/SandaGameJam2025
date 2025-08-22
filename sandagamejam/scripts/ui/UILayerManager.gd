#UILayerManager
extends Node

var ui_layer_scene = preload("res://scenes/ui/UILayer.tscn")
var ui_layer_instance: CanvasLayer = null

func init_ui_layer():
	if ui_layer_instance:
		return
	ui_layer_instance = ui_layer_scene.instantiate()
	get_tree().root.call_deferred("add_child", ui_layer_instance)

func show_hud():
	if ui_layer_instance:
		ui_layer_instance.call_deferred("show_hud")
