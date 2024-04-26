tool

extends Control

export(DynamicFont) var default_font: DynamicFont

export var color := Color.black setget set_color

export var xmin := 0.0 setget set_xmin
export var xmax := 10.0 setget set_xmax
export var ymin := 0.0 setget set_ymin
export var ymax := 10.0 setget set_ymax
export var xlabel := "x axis" setget set_xlabel
export var ylabel := "y axis" setget set_ylabel

export var data = PoolVector2Array([
#	Vector2(1, 1),
#	Vector2(4, 6),
#	Vector2(7, 6),
#	Vector2(9, 9),
]) setget set_data

func draw_standard_string(position: Vector2, text: String, center_x=true, center_y=true):
	var offset := Vector2.ZERO
	if center_x:
		offset.x -= default_font.get_string_size(text).x / 2
	if center_y:
		offset.y += default_font.get_ascent() / 2
	draw_string(default_font, position + offset, text, color)

func _draw():
	var remapped_data = normalize_data(data)

	var xticks = 5
	var yticks = 6

	var axis_insets = 30

	var x_axis = Vector2(rect_size.x - axis_insets, 0)
	var y_axis = Vector2(0, -(rect_size.y - axis_insets))
	
	var x_axis_y_position = rect_size.y - axis_insets
	var y_axis_x_position = axis_insets
	
	var graph_origin = Vector2(y_axis_x_position, x_axis_y_position)
	
	
	# draw x ticks
	var xtick_increment = x_axis / (xticks - 1)
	for i in range(xticks):
		var xtick_base = graph_origin + i * xtick_increment
		draw_line(xtick_base, xtick_base + Vector2(0, 5), color)
		var value = i * (xmax - xmin) / (xticks - 1) + xmin
#		draw_string(default_font, xtick_base + Vector2(-4, 20), str(value), color)
		draw_standard_string(xtick_base + Vector2(0, 10), str(value))
	
	# draw y ticks
	var ytick_increment = y_axis / (yticks - 1)
	for i in range(yticks):
		var ytick_base = graph_origin + i * ytick_increment
		draw_line(ytick_base, ytick_base - Vector2(5, 0), color)
		var value = i * (ymax - ymin) / (yticks - 1) + ymin
#		draw_string(default_font, ytick_base + Vector2(-20, 6), str(value), color)
		draw_standard_string(ytick_base + Vector2(-10, 0), str(value))
	
	var temp_transform := get_canvas_transform()
	draw_set_transform(Vector2.ZERO, -PI / 2, Vector2.ONE)
	draw_standard_string(Vector2(y_axis.y / 2, 6), ylabel)
	draw_set_transform_matrix(temp_transform)
	
	draw_standard_string(graph_origin + x_axis / 2 + Vector2(0, axis_insets - 6), xlabel)
	
	# draw x-axis
	draw_line(graph_origin, graph_origin + x_axis, color)
	
	# draw y-axis
	draw_line(graph_origin, graph_origin + y_axis, color)
	
	# draw scatter plot
	for point in remapped_data:
		if point.x < 0.0 or point.x > 1.0 or point.y < 0.0 or point.y > 1.0:
			continue
		var screen_position = graph_origin + (point * (x_axis + y_axis))
		draw_circle(screen_position, 1.0, Color.blue)
	
	

func normalize_data(_data: PoolVector2Array) -> PoolVector2Array:
	var result = PoolVector2Array()
	result.resize(len(_data))
	for i in range(len(_data)):
		result[i] = Vector2(
			range_lerp(_data[i].x, xmin, xmax, 0.0, 1.0),
			range_lerp(_data[i].y, ymin, ymax, 0.0, 1.0)
		)
	return result


func set_color(_color: Color) -> void:
	color = _color
	update()

func set_xmin(_xmin: float) -> void:
	xmin = _xmin
	update()

func set_xmax(_xmax: float) -> void:
	xmax = _xmax
	update()

func set_ymin(_ymin: float) -> void:
	ymin = _ymin
	update()

func set_ymax(_ymax: float) -> void:
	ymax = _ymax
	update()

func set_xlabel(_xlabel: String) -> void:
	xlabel = _xlabel
	update()

func set_ylabel(_ylabel: String) -> void:
	ylabel = _ylabel
	update()

func set_data(_data: PoolVector2Array) -> void:
	data = _data
	update()

#func remap_data(data_input: Array, in_min: Vector2, in_max: Vector2,
#		out_min: Vector2, out_max: Vector2) -> Array:
#	var result = []
#	for point in data_input:
#		result.append(Vector2(
#			range_lerp(point.x, in_min.x, in_max.x, out_min.x, out_max.x),
#			range_lerp(point.y, in_min.y, in_max.y, out_min.y, out_max.y)
#		))
#	return result
