class_name FoxTextureBuilder
extends RefCounted
## One-shot procedural fox albedo (no external art). Called once at runtime.

const W := 256
const H := 288


static func create_texture() -> ImageTexture:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_body_and_belly(img)
	_shirt_backpack(img)
	_head_ears(img)
	_eyes_nose(img)
	_fur_noise(img)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func absi(v: int) -> int:
	return abs(v)


static func _in_ellipse(ix: int, iy: int, cx: float, cy: float, rx: float, ry: float) -> bool:
	var dx := (float(ix) - cx) / rx
	var dy := (float(iy) - cy) / ry
	return dx * dx + dy * dy <= 1.0


static func _body_and_belly(img: Image) -> void:
	var cx := W * 0.5
	for y in range(H):
		for x in range(W):
			if _in_ellipse(x, y, cx, 168.0, 52.0, 44.0):
				var t := (float(y) - 130.0) / 80.0
				t = clampf(t, 0.0, 1.0)
				var deep := Color(0.52, 0.22, 0.06, 1.0)
				var mid := Color(0.95, 0.48, 0.14, 1.0)
				var lit := Color(1.0, 0.62, 0.28, 1.0)
				var c := deep.lerp(mid, smoothstep(0.0, 0.55, t)).lerp(lit, smoothstep(0.45, 1.0, t))
				img.set_pixel(x, y, c)
			elif _in_ellipse(x, y, cx, 178.0, 34.0, 28.0):
				var h := float(absi(hash(Vector2i(x, y))) % 997) / 997.0
				var c2 := Color(0.98, 0.88, 0.72, 1.0).lerp(Color(0.85, 0.72, 0.55, 1.0), h * 0.35)
				img.set_pixel(x, y, c2)


static func _shirt_backpack(img: Image) -> void:
	for y in range(150, 210):
		for x in range(88, 168):
			if x >= 108 and x <= 148:
				var g := smoothstep(150.0, 205.0, float(y))
				img.set_pixel(x, y, Color(0.12, 0.48, 0.32, 1.0).lerp(Color(0.22, 0.62, 0.4, 1.0), g))
	for y in range(155, 205):
		for x in range(72, 102):
			if x + y * 0.12 < 118.0:
				img.set_pixel(x, y, Color(0.38, 0.2, 0.1, 1.0))


static func _head_ears(img: Image) -> void:
	var cx := W * 0.5
	for y in range(40, 140):
		for x in range(W):
			if _in_ellipse(x, y, cx, 102.0, 46.0, 44.0):
				var shade := smoothstep(40.0, 120.0, float(y))
				var c := Color(0.55, 0.24, 0.08, 1.0).lerp(Color(1.0, 0.55, 0.2, 1.0), shade * 0.85)
				img.set_pixel(x, y, c)
	_ear_tri(img, cx - 52.0, 72.0, -1.0)
	_ear_tri(img, cx + 52.0, 72.0, 1.0)


static func _ear_tri(img: Image, tip_x: float, tip_y: float, side: float) -> void:
	for y in range(28, 92):
		for x in range(W):
			var base_x := tip_x + side * 22.0
			var t := float(y - 28) / 64.0
			if t < 0.0 or t > 1.0:
				continue
			var half_w := lerpf(28.0, 6.0, t)
			if absf(float(x) - lerpf(base_x, tip_x, t)) < half_w:
				var c := Color(0.98, 0.98, 1.0, 1.0).lerp(Color(0.92, 0.5, 0.18, 1.0), t * 0.55)
				var p := img.get_pixel(x, y)
				if p.a < 0.5:
					img.set_pixel(x, y, c)


static func _eyes_nose(img: Image) -> void:
	var cx := W * 0.5
	for y in range(86, 108):
		for x in range(W):
			if _in_ellipse(x, y, cx - 22.0, 96.0, 14.0, 10.0) or _in_ellipse(x, y, cx + 22.0, 96.0, 14.0, 10.0):
				img.set_pixel(x, y, Color(0.96, 0.96, 1.0, 1.0))
			elif _in_ellipse(x, y, cx - 20.0, 98.0, 5.0, 5.0) or _in_ellipse(x, y, cx + 24.0, 98.0, 5.0, 5.0):
				img.set_pixel(x, y, Color(0.06, 0.06, 0.1, 1.0))
	for y in range(104, 122):
		for x in range(int(cx) - 14, int(cx) + 14):
			if float(y) > 104.0 + absf(float(x) - cx) * 0.55:
				img.set_pixel(x, y, Color(0.1, 0.07, 0.06, 1.0))


static func _fur_noise(img: Image) -> void:
	for y in range(H):
		for x in range(W):
			var p := img.get_pixel(x, y)
			if p.a < 0.2:
				continue
			var n := randf_range(-0.045, 0.045)
			p.r = clampf(p.r + n, 0.0, 1.0)
			p.g = clampf(p.g + n * 0.9, 0.0, 1.0)
			p.b = clampf(p.b + n * 0.75, 0.0, 1.0)
			img.set_pixel(x, y, p)


static func _outline(img: Image) -> void:
	var copy := img.duplicate()
	for y in range(1, H - 1):
		for x in range(1, W - 1):
			var c = copy.get_pixel(x, y)
			if c.a < 0.25:
				continue
			var nbr := 0
			for o in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				if copy.get_pixel(x + o.x, y + o.y).a < 0.2:
					nbr += 1
			if nbr > 0:
				img.set_pixel(x, y, Color(0.18, 0.08, 0.04, 1.0).lerp(c, 0.35))

