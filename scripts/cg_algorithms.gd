extends RefCounted
class_name CGAlgorithms

# CGG lab algorithms: these routines are intentionally explicit for demonstration.
static func dda_points(a: Vector2, b: Vector2) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var dx := b.x - a.x
	var dy := b.y - a.y
	var steps := int(max(abs(dx), abs(dy)))
	if steps == 0:
		result.append(Vector2i(roundi(a.x), roundi(a.y)))
		return result
	var x_inc := dx / float(steps)
	var y_inc := dy / float(steps)
	var x := a.x
	var y := a.y
	for i in range(steps + 1):
		result.append(Vector2i(roundi(x), roundi(y)))
		x += x_inc
		y += y_inc
	return result

static func bresenham_points(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var x := a.x
	var y := a.y
	var dx := absi(b.x - a.x)
	var sx := 1 if a.x < b.x else -1
	var dy := -absi(b.y - a.y)
	var sy := 1 if a.y < b.y else -1
	var err := dx + dy
	while true:
		result.append(Vector2i(x, y))
		if x == b.x and y == b.y:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x += sx
		if e2 <= dx:
			err += dx
			y += sy
	return result

static func midpoint_circle_points(center: Vector2i, radius: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var x := radius
	var y := 0
	var decision := 1 - radius
	while x >= y:
		var pts := [
			Vector2i(center.x + x, center.y + y), Vector2i(center.x + y, center.y + x),
			Vector2i(center.x - y, center.y + x), Vector2i(center.x - x, center.y + y),
			Vector2i(center.x - x, center.y - y), Vector2i(center.x - y, center.y - x),
			Vector2i(center.x + y, center.y - x), Vector2i(center.x + x, center.y - y)
		]
		for p in pts:
			result.append(p)
		y += 1
		if decision <= 0:
			decision += 2 * y + 1
		else:
			x -= 1
			decision += 2 * (y - x) + 1
	return result

# Scan-line polygon fill: returns integer pixels for a simple polygon.
static func scanline_fill_points(vertices: Array[Vector2i]) -> Array[Vector2i]:
	var pixels: Array[Vector2i] = []
	if vertices.size() < 3:
		return pixels
	var min_y := vertices[0].y
	var max_y := vertices[0].y
	for v in vertices:
		min_y = mini(min_y, v.y)
		max_y = maxi(max_y, v.y)
	for y in range(min_y, max_y + 1):
		var intersections: Array[float] = []
		for i in range(vertices.size()):
			var p1: Vector2i = vertices[i]
			var p2: Vector2i = vertices[(i + 1) % vertices.size()]
			if p1.y == p2.y:
				continue
			var low_y := mini(p1.y, p2.y)
			var high_y := maxi(p1.y, p2.y)
			if y >= low_y and y < high_y:
				var x := p1.x + float(y - p1.y) * float(p2.x - p1.x) / float(p2.y - p1.y)
				intersections.append(x)
		intersections.sort()
		var j := 0
		while j + 1 < intersections.size():
			for x in range(ceili(intersections[j]), floori(intersections[j + 1]) + 1):
				pixels.append(Vector2i(x, y))
			j += 2
	return pixels

# Cohen-Sutherland line clipping. Returns [visible, clipped_start, clipped_end].
static func clip_line(a: Vector2, b: Vector2, rect: Rect2) -> Array:
	var x_min := rect.position.x
	var y_min := rect.position.y
	var x_max := rect.position.x + rect.size.x
	var y_max := rect.position.y + rect.size.y
	var x1 := a.x
	var y1 := a.y
	var x2 := b.x
	var y2 := b.y
	var c1 := _outcode(x1, y1, x_min, y_min, x_max, y_max)
	var c2 := _outcode(x2, y2, x_min, y_min, x_max, y_max)
	while true:
		if (c1 | c2) == 0:
			return [true, Vector2(x1, y1), Vector2(x2, y2)]
		if (c1 & c2) != 0:
			return [false, Vector2.ZERO, Vector2.ZERO]
		var out := c1 if c1 != 0 else c2
		var x := 0.0
		var y := 0.0
		if (out & 8) != 0:
			x = x1 + (x2 - x1) * (y_max - y1) / (y2 - y1)
			y = y_max
		elif (out & 4) != 0:
			x = x1 + (x2 - x1) * (y_min - y1) / (y2 - y1)
			y = y_min
		elif (out & 2) != 0:
			y = y1 + (y2 - y1) * (x_max - x1) / (x2 - x1)
			x = x_max
		else:
			y = y1 + (y2 - y1) * (x_min - x1) / (x2 - x1)
			x = x_min
		if out == c1:
			x1 = x
			y1 = y
			c1 = _outcode(x1, y1, x_min, y_min, x_max, y_max)
		else:
			x2 = x
			y2 = y
			c2 = _outcode(x2, y2, x_min, y_min, x_max, y_max)
	return [false, Vector2.ZERO, Vector2.ZERO]

static func _outcode(x: float, y: float, xmin: float, ymin: float, xmax: float, ymax: float) -> int:
	var code := 0
	if x < xmin: code |= 1
	elif x > xmax: code |= 2
	if y < ymin: code |= 4
	elif y > ymax: code |= 8
	return code
