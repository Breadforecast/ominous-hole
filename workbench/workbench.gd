extends Area3D


signal materials_updated(new_materials: Dictionary)

@export var screen: MeshInstance3D

var available_materials := {}
var current_recipe: CraftingRecipe


func _ready() -> void:
	current_recipe = preload("res://recipes/super_test_cube.tres")
	screen.get_node("SubViewport/CraftUI").current_recipe = preload("res://recipes/super_test_cube.tres")


func extract_rov_materials() -> void:
	var drone_available := false
	for i in available_materials:
		if available_materials[i] == 1:
			drone_available = true
	if not drone_available:
		return
	for i in Global.rov_inventory:
		var s := i.instantiate()
		s.global_position = global_position + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))


func _on_area_entered(area: Area3D) -> void:
	var area_owner = area.owner
	if area_owner is Pickup:
		available_materials[area_owner.name] = area_owner.id
		materials_updated.emit(available_materials)
		print("Entered: %s" % area_owner.fancy_name)
		print(available_materials)
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
		var o := current_recipe.output.instantiate()
		add_sibling(o)
		o.global_position = global_position + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
		print("Materials after craft: %s" % available_materials)


func _on_area_exited(area: Area3D) -> void:
	var area_owner = area.owner
	if area_owner is not Pickup:
		return
	if available_materials.has(area_owner.name):
		available_materials.erase(area_owner.name)
		materials_updated.emit(available_materials)
		print("Exited: %s" % area_owner.fancy_name)
