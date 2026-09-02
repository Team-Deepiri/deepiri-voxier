class_name Steering3D
extends RefCounted
## Force-based steering helpers for the 3D horde (XZ play plane, +Y up).
## All functions return desired velocities or forces; callers integrate them
## with capped acceleration so nothing teleports or jitters.

## Boundary ramp band: the soft push reaches full strength this far past the
## margin line, then saturates.
const BOUNDARY_RAMP := 1.5


static func seek(pos: Vector3, target: Vector3, max_speed: float) -> Vector3:
	var dir := target - pos
	if dir.length_squared() < 0.0001:
		return Vector3.ZERO
	return dir.normalized() * max_speed


## Eased approach: full speed far away, slows to a crawl inside slow_radius.
static func arrive(pos: Vector3, target: Vector3, max_speed: float, slow_radius: float) -> Vector3:
	var dir := target - pos
	var dist := dir.length()
	if dist < 0.0001:
		return Vector3.ZERO
	var speed := max_speed * clampf(dist / slow_radius, 0.12, 1.0)
	return (dir / dist) * speed


## Circular strafe around target at `radius`. Tangent sign picks orbit
## direction; a soft radial spring corrects back to the ring distance.
static func orbit(pos: Vector3, target: Vector3, radius: float, tangent_dir: int, max_speed: float) -> Vector3:
	var offset := pos - target
	offset.y = 0.0
	var dist := offset.length()
	if dist < 0.0001:
		return seek(pos, target + Vector3(radius, 0, 0), max_speed)
	var radial := offset / dist
	var tangent := Vector3(-radial.z * tangent_dir, 0.0, radial.x * tangent_dir)
	var radial_fix := (radius - dist) * 0.65
	return tangent * max_speed + radial * radial_fix


## Push away from overlapping neighbors; closer neighbors push harder.
## Uses squared distances and allocates nothing. Skips null/freed entries.
static func separation(pos: Vector3, others: Array, sep_radius_sq: float, max_speed: float, ignore: Node3D = null) -> Vector3:
	var push := Vector3.ZERO
	for o in others:
		var n := o as Node3D
		if n == null or n == ignore or not is_instance_valid(n):
			continue
		var d := pos - n.global_position
		d.y = 0.0
		var dsq := d.length_squared()
		if dsq < sep_radius_sq and dsq > 0.000001:
			push += d / dsq
	if push.length_squared() < 0.000001:
		return Vector3.ZERO
	return push.normalized() * minf(push.length(), max_speed)


## Soft force pushing back inside the arena rectangle when within margin of
## an edge; ramps up linearly across the margin band.
static func boundary_force(pos: Vector3, x_min: float, x_max: float, z_min: float, z_max: float, margin: float, strength: float) -> Vector3:
	return Vector3(
		_axis_push(pos.x, x_min + margin, x_max - margin, strength),
		0.0,
		_axis_push(pos.z, z_min + margin, z_max - margin, strength)
	)


static func _axis_push(v: float, lo: float, hi: float, strength: float) -> float:
	if v < lo:
		return strength * minf(1.0, (lo - v) / BOUNDARY_RAMP)
	if v > hi:
		return -strength * minf(1.0, (v - hi) / BOUNDARY_RAMP)
	return 0.0


## Average position of nearby allies (for light flock cohesion). Returns
## ZERO when nobody is close enough.
static func cohesion_point(pos: Vector3, others: Array, radius_sq: float, ignore: Node3D = null) -> Vector3:
	var sum := Vector3.ZERO
	var count := 0
	for o in others:
		var n := o as Node3D
		if n == null or n == ignore or not is_instance_valid(n):
			continue
		var d := pos - n.global_position
		d.y = 0.0
		if d.length_squared() < radius_sq:
			sum += n.global_position
			count += 1
	if count == 0:
		return Vector3.ZERO
	return sum / float(count)
