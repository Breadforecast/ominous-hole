extends Area3D


signal materials_updated(new_materials: Dictionary)

const CRAFT_SPREAD := 0.5

@export var recipe_list: PackedScene
@export var panel_3d: Panel3D

var available_materials := {}
var current_recipe: CraftingRecipe


func _ready() -> void:
	var rl_scene := recipe_list.instantiate()
	rl_scene.craft.connect(_on_craft_ui_craft)
	rl_scene.rov_extract.connect(_on_craft_ui_rov_extract)
	rl_scene.new_recipe.connect(
		func(new_recipe: CraftingRecipe):
			current_recipe = new_recipe
	)
	panel_3d.set_viewport_scene(rl_scene)
	current_recipe = rl_scene.current_recipe


func extract_rov_materials() -> void:
	var drone_available := false
	for i in available_materials:
		if available_materials[i] == 1:
			drone_available = true
	if not drone_available:
		return
	for i in Global.rov_inventory:
		create_item(i)
		Global.rov_inventory.erase(i)


func create_item(item: PackedScene) -> void:
	var o := item.instantiate()
	add_sibling(o)
	o.global_position = global_position + Vector3(
			randf_range(-CRAFT_SPREAD, CRAFT_SPREAD),
			randf_range(-CRAFT_SPREAD, CRAFT_SPREAD), 0.0)


func craft() -> void:
	var recipe_ids := current_recipe.material_ids
	var matching_elements: Array[int]
	for i in available_materials:
		if recipe_ids.has(available_materials[i]):
			matching_elements.append(available_materials[i])
	recipe_ids.sort()
	matching_elements.sort()
	if matching_elements != recipe_ids:
		return
	while not matching_elements.is_empty():
		for i in available_materials:
			if available_materials[i] in matching_elements:
				owner.get_node(i).queue_free()
				matching_elements.erase(available_materials[i])
				available_materials.erase(i)
	create_item(current_recipe.output)
	print("Materials after craft: %s" % available_materials)


func _on_craft_ui_craft() -> void:
	craft()


func _on_craft_ui_rov_extract() -> void:
	extract_rov_materials()


func _on_body_entered(body: Node3D) -> void:
	if body is Pickup:
		available_materials[body.name] = body.id
		materials_updated.emit(available_materials)
		print("Entered: %s" % body.fancy_name)


func _on_body_exited(body: Node3D) -> void:
	if body is Pickup and available_materials.has(body.name):
		available_materials.erase(body.name)
		materials_updated.emit(available_materials)
		print("Exited: %s" % body.fancy_name)
