const (
	gravity = Vec{0,-40.8}
	delta = 1.0/60.0
)

fn (mut v Vertex) prepare() {
	v.force = svec(0)
	v.calculated = false
}

fn (mut v Vertex) integrate() {
	if !v.fixed {
		assert v.calculated
	} else {return}

	v.velocity += v.force * svec(delta) / svec(v.mass)
	v.position += v.velocity * svec(delta)
}

fn (mut v Vertex) gravity() {
	if v.fixed {return}
	v.force += gravity * svec(v.mass)
	v.calculated = true
}

fn (mut s Spring) calculate_hookes() {
	difference := s.a.position.distance(s.b.position) - s.length
	mut force := difference * s.stiffness

	a_dir := (s.a.position - s.b.position).normalize()
	vel_diff := s.a.velocity - s.b.velocity
	dot := a_dir.dot(vel_diff)

	force += dot * s.damping

	if !s.a.fixed {
		s.a.force += (s.b.position - s.a.position).normalize() * svec(force)
		s.a.calculated = true
	}
	if !s.b.fixed {
		s.b.force += a_dir * svec(force)
		s.b.calculated = true
	}
	s.factor = difference / s.length
}