extends PanelContainer


signal rov_extract
signal craft
signal new_recipe(recipe: CraftingRecipe)

@export var recipes: Array[CraftingRecipe]

var index := 0

@onready var current_recipe: CraftingRecipe: set = set_current_recipe


func _enter_tree() -> void:
	current_recipe = recipes[index]


func set_current_recipe(value: CraftingRecipe) -> void:
	current_recipe = value
	if not is_node_ready():
		await ready
	var o: Pickup = current_recipe.output.instantiate()
	%RecipeNameLabel.text = o.fancy_name
	for i in %ListContainer.get_children():
		i.queue_free()
	for i in current_recipe.material_list_friendly:
		_create_material_label(i)


func _create_material_label(text: String) -> void:
	var label := Label.new()
	label.text = "* %s" % text
	label.theme_type_variation = "MaterialLabel"
	%ListContainer.add_child(label)


func _change_index(value: int) -> void:
	index += value
	var wrap := wrapi(index, 0, recipes.size())
	current_recipe = recipes[wrap]
	new_recipe.emit(recipes[wrap])


func _on_left_button_pressed() -> void:
	_change_index(-1)


func _on_right_button_pressed() -> void:
	_change_index(1)


func _on_craft_button_pressed() -> void:
	print("craft")
	craft.emit()


func _on_materials_button_pressed() -> void:
	print("extract")
	rov_extract.emit()
