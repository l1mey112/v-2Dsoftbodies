import math
import term.ui as tui
import term

struct ProceduralCircle {
	mut:
		pos Vec
		radius f64
		samples int
}

fn (c ProceduralCircle) sample_point(index int)Vec{
	assert index < c.samples
	angle := f64(index) / f64(c.samples) * 2.0 * math.pi

	return Vec{
		c.radius * math.cos(angle),
		c.radius * math.sin(angle)
	}
}

fn (c ProceduralCircle) render(a voidptr) {
	intpos := c.pos.screen(a).int()

	for i in 0..c.samples { 
		put_pixel(c.sample_point(i), a)
	}
}

//struct Circle {
//	radius f64
//	mut:
//		pos Vec
//		
//}


// https://www.youtube.com/watch?v=kyQP4t_wOGI

// bresenham's line algorithm taken from term.ui but modified to work with Vec + board
fn draw_line(vec1 Vec, vec2 Vec, a voidptr) {
	mut ctx := &App(a)

	x := vec1.int().x
	y := vec1.int().y
	x2 := vec2.int().x
	y2 := vec2.int().y

	min_x, min_y := if x < x2 { x } else { x2 }, if y < y2 { y } else { y2 }
	max_x, _ := if x > x2 { x } else { x2 }, if y > y2 { y } else { y2 }

	// Draw the various points with Bresenham's line algorithm:
	mut x0, x1 := x, x2
	mut y0, y1 := y, y2
	sx := if x0 < x1 { 1 } else { -1 }
	sy := if y0 < y1 { 1 } else { -1 }
	dx := if x0 < x1 { x1 - x0 } else { x0 - x1 }
	dy := if y0 < y1 { y0 - y1 } else { y1 - y0 } // reversed
	mut err := dx + dy
	for {
		// res << Segment{ x0, y0 }

		new := IVec{x0, y0}.screen(a)
		ctx.tui.draw_text(new.x,new.y, pchar)
		ctx.tui.draw_text(new.x+1,new.y, pchar)

		if x0 == x1 && y0 == y1 {
			break
		}
		e2 := 2 * err
		if e2 >= dy {
			err += dy
			x0 += sx
		}
		if e2 <= dx {
			err += dx
			y0 += sy
		}
	}
}

struct Vertex {
	mut:
		position Vec = Vec{0, 0}

		velocity Vec
		force Vec
		mass f64	 = 1.0

		fixed bool
		calculated bool
	//? juuuust making sure for debugging
}

fn (v Vertex) render(a voidptr) {
	put_pixel(v.position, a)
}

fn (v Vertex) info(a voidptr) {
	mut app := &App(a)
	text := "mass: ${v.mass}, force: ${math.round(v.force.length())}"

	point := (v.position + vec(2,0)).int().screen(a)
	app.tui.draw_text(point.x, point.y, term.magenta(text))
}

struct Spring {
	mut:
		a &Vertex
		b &Vertex

		length f64
		stiffness f64
		damping f64

	// used for rendering spring forces
		factor f64
}

//todo	render as points + render as lines
//todo		when rendering as lines draw red or green based on spring

fn (s Spring) render_points(a voidptr) {
	s.a.render(a)
	s.b.render(a)
}

fn (s Spring) info(a voidptr) {
	mut app := &App(a)
	text := "rest: ${s.length},stiffness: ${s.stiffness}"

	point := (s.a.position.midpoint(s.b.position) - vec(text.len/2 + 2,0)).int().screen(a)
	app.tui.draw_text(point.x, point.y, term.yellow(text))
}

fn (s Spring) render(a voidptr) {
	mut app := &App(a)
	app.tui.set_bg_color(lerp_colour(s.factor,tui.Color{
		0,
		200,
		0
	},tui.Color{
		255,
		0,
		0
	}))
	draw_line(s.a.position, s.b.position, a)
	app.tui.reset_bg_color()
}