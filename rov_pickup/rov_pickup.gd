@tool
class_name ROVPickup
extends Area2D


const ITEM = preload("res://rov_pickup/item.png")
const SUB_ITEM = preload("res://rov_pickup/sub_item.png")

enum ItemImportance {MAIN, SIDE}

@export var item_id: int
@export var importance: ItemImportance: set = set_importance
@export var corresponding_3d_object: PackedScene

@onready var sprite_2d: Sprite2D = %Sprite2D


func set_importance(value: ItemImportance) -> void:
	importance = value
	if not is_node_ready():
		await ready
	match importance:
		ItemImportance.MAIN:
			sprite_2d.texture = ITEM
		ItemImportance.SIDE:
			sprite_2d.texture = SUB_ITEM
