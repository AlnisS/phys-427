tool

extends Control

export(DynamicFont) var default_font

func _draw():
	var color = Color.black

	var xmin = 0.0
	var xmax = 7.0
	var ymin = 20.0
	var ymax = 36.0

	var data = [
		Vector2(0.0, 20.0),
		Vector2(1.0, 21.0),
		Vector2(2.0, 23.0),
		Vector2(3.0, 26.0),
		Vector2(4.0, 30.0),
		Vector2(5.0, 33.0),
		Vector2(6.0, 35.0),
		Vector2(7.0, 36.0),
	]
	
	var remapped_data = remap_data(data, Vector2(xmin, ymin), Vector2(xmax, ymax), Vector2.ZERO, Vector2.ONE)

	var xticks = 5
	var yticks = 5

	var x_axis = Vector2(rect_size.x - 20, 0)
	var y_axis = Vector2(0, -(rect_size.y - 20))
	
	var x_axis_y_position = rect_size.y - 20
	var y_axis_x_position = 20
	
	var graph_origin = Vector2(y_axis_x_position, x_axis_y_position)
	
	
	# draw x ticks
	var xtick_increment = x_axis / (xticks - 1)
	for i in range(xticks):
		var xtick_base = graph_origin + i * xtick_increment
		draw_line(xtick_base, xtick_base + Vector2(0, 5), color)
		var value = i * (xmax - xmin) / (xticks - 1) + xmin
		draw_string(default_font, xtick_base + Vector2(-4, 20), str(value), Color.black)
	
	# draw y ticks
	var ytick_increment = y_axis / (yticks - 1)
	for i in range(yticks):
		var ytick_base = graph_origin + i * ytick_increment
		draw_line(ytick_base, ytick_base - Vector2(5, 0), color)
		var value = i * (ymax - ymin) / (yticks - 1) + ymin
		draw_string(default_font, ytick_base + Vector2(-20, 6), str(value), Color.black)
	
	# draw x-axis
	draw_line(graph_origin, graph_origin + x_axis, color)
	
	# draw y-axis
	draw_line(graph_origin, graph_origin + y_axis, color)
	
	# draw scatter plot
	for point in remapped_data:
		var screen_position = graph_origin + (point * (x_axis + y_axis))
		draw_circle(screen_position, 1.0, Color.blue)
	
	


func remap_data(data_input: Array, in_min: Vector2, in_max: Vector2,
		out_min: Vector2, out_max: Vector2) -> Array:
	var result = []
	for point in data_input:
		result.append(Vector2(
			range_lerp(point.x, in_min.x, in_max.x, out_min.x, out_max.x),
			range_lerp(point.y, in_min.y, in_max.y, out_min.y, out_max.y)
		))
	return result
