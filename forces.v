import term

const (
	gravity = Vec{0,-80.8}
	delta = 1.0/fps
)

fn (mut v Vertex) prepare() {
	v.force = svec(0)
	v.calculated = false
	v.integrated = false
}

fn (mut v Vertex) integrate() {
	if !v.fixed {
		assert v.calculated
	} else {return}

	v.velocity += v.force * svec(delta) / svec(v.mass)
	v.position += v.velocity * svec(delta)
	v.integrated = true
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

//? SOFTBODIES

fn (mut c SoftBodyCircle) prepare() {
	for mut v in c.vertices {
		v.prepare()
	} 
}

fn (mut c SoftBodyCircle) integrate() {
	for mut v in c.vertices {
		v.integrate()
	}
}

fn (mut c SoftBodyCircle) gravity() {
	for mut v in c.vertices {
		v.gravity()
	}
}

// const nrt = 0.5 * 8.3144621 * 293.15
	//? defined outside of function!

fn (mut c SoftBodyCircle) simulate(a voidptr) {
	for mut s in c.springs {
		s.calculate_hookes()
	} //? calculate spring forces FIRST

	//* PV = nRT : the ideal gas law
	//?   P = pressure
	//?   V = volume
	//?   n = 1.0        number of moles (particles)
	//?   R = 8.3144621  universal gas constant
	//?   T = 293.15     room temperature in kelvin

	//! nrt constant defined above!

	//* P = F/A
	//? pressure = force / area

	//? combining these to calculate force from pressure
	//* Force = Area * nRT / Volume

	full_area := c.area()
	mut app := &App(a)
	for i, mut s in c.springs {
		//? calculate force
		length := s.a.position.distance(s.b.position) //? "area" (we live in 2d land not 3d)
		force_float := (length * nrt) / full_area

		//? calculate normal vector
		mut nrm_vec := (s.a.position - s.b.position).normalize()
		nrm_vec = Vec{nrm_vec.y, -nrm_vec.x} //? rotate vec by 90 degrees to obtain ONE normal vector

		opposite_s := c.springs[(i + c.springs.len / 2 ) % c.springs.len]
		opposite_midpoint := (opposite_s.a.position + opposite_s.b.position) / svec(2)
			//? use opposite spring to calculate direction to enforce outward normals

		midpoint := (s.a.position + s.b.position) / svec(2)
		outward_vec := (midpoint - opposite_midpoint).normalize()

		final_nrm := if nrm_vec.dot(outward_vec) > 0 {
			nrm_vec
		} else {
			nrm_vec * svec(-1)
		} //? make SURE the normal vector points outwards, if not flip it!

		//app.tui.set_bg_color(r: 120, g: 0, b: 120)
		//draw_line(midpoint,midpoint + final_nrm * svec(5),a)

		//app.tui.set_bg_color(r: 10, g: 10, b: 40)
		//draw_line(opposite_midpoint,midpoint,a)

		//! apply forces!
		s.a.force += final_nrm * svec(force_float)
		s.b.force += final_nrm * svec(force_float)
	}
	app.tui.reset_bg_color()
}

fn (mut c SoftBodyCircle) line_collide(line Line) {
	nrm := line.get_normal()
	
	for mut v in c.vertices {
		assert v.integrated

		if line.is_passing(v.position) {
			
			v.velocity = v.velocity.reflect(nrm)
			v.position = line.get_closest(v.position)
		}
	}
}

//? apply force to the target
fn (mut c SoftBodyCircle) stowards(vec Vec, max_force f64) { // , factor f64
	prop_force := max_force / c.vertices.len
	for mut v in c.vertices {
		//f_factor :=  mapf(0,factor,0,max_force,v.position.distance(vec))
		//v.force += (v.position - vec).normalize() * svec(f_factor)
		//v.calculated = true

		v.force += (vec - v.position).normalize() * svec(prop_force)
		v.calculated = true
	}
}

//? UTIL

fn (c SoftBodyCircle) area()f64{
	mut area := 0.0
	for i in 0..c.vertices.len {
		i_next := (i+1) % c.vertices.len
		area += c.vertices[i].position.y * c.vertices[i_next].position.x - c.vertices[i].position.x * c.vertices[i_next].position.y
	}
	return area * -0.5
}

//? RENDER

fn (c SoftBodyCircle) render(a voidptr) {
	for s in c.springs {
		s.render(a)
	}
}

fn (c SoftBodyCircle) render_points(a voidptr) {
	mut app := &App(a)
	
	app.tui.set_bg_color(r: 255, g: 255, b: 255)
	for v in c.vertices {
		v.render(a)
	}
	app.tui.reset_bg_color()
}

fn (c SoftBodyCircle) info_message(text string,a voidptr) {
	mut app := &App(a)
	
	mut average := svec(0)
	for v in c.vertices {
		average += v.position
	}

	point := (average / svec(c.vertices.len) - vec(text.len/4,0)).int().screen(a)

	ssx, ssy := term.get_terminal_size()

	// do bounds checking for point

	if point.x < 0 {
		return
	}
	if point.y < 0 {
		return
	}
	if point.x > ssx {
		return
	}
	if point.y > ssy {
		return
	}
	app.tui.draw_text(point.x,point.y,text)
}