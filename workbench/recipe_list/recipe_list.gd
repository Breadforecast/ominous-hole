extends PanelContainer


var current_recipe: CraftingRecipe: set = set_current_recipe


func set_current_recipe(value: CraftingRecipe) -> void:
	current_recipe = value
	if not is_node_ready():
		await ready
	var o: Pickup = current_recipe.output.instantiate()
	%RecipeNameLabel.text = o.fancy_name
	for i in %ListContainer.get_children():
		i.queue_free()
	for i in current_recipe.material_list_friendly:
		create_material_label(i)


func create_material_label(text: String) -> void:
	var label := Label.new()
	label.text = "* %s" % text
	label.theme_type_variation = "MaterialLabel"
	%ListContainer.add_child(label)
