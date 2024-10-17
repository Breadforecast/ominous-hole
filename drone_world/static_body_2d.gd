extends StaticBody2D


func _ready() -> void:
	for i in get_children():
		var col_poly: CollisionPolygon2D = i
		var polygon := Polygon2D.new()
		var shape = col_poly.polygon
		polygon.polygon = shape
		col_poly.add_child(polygon)
