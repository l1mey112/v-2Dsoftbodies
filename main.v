import term.ui as tui
import term
import math

const (
	fps = 60
	pchar = " "
)

struct App {
mut:
	tui &tui.Context = 0
	zero IVec
	mouse IVec
}

fn event(e &tui.Event, x voidptr) {
	mut app := &App(x)

	if !e.modifiers.is_empty() {
		if e.modifiers.has(.ctrl) {
			if e.typ == .key_down && e.code == .c {
				exit(0)
			}
		}
	}

	if e.typ == .mouse_move {
		app.mouse = IVec{e.x, e.y}
	}
}

fn put_pixel(vec1 Vec, a voidptr){
	mut app := &App(a)

	new := (vec1).int().screen(a)

	ssx, ssy := term.get_terminal_size()
	if new.x >= ssx || new.y >= ssy || new.x < 0 || new.y < 0 {
		return
	}
	if new.x+1 >= ssx || new.y+1 >= ssy {
		return
	}

	app.tui.draw_text(new.x,new.y, pchar)
	app.tui.draw_text(new.x+1,new.y, pchar)
}

__global (
	softbody = SoftBodyCircle{}
	elapsed = 0.0

	line = Line{
		position: Vec{-40,-25},
		direction: Vec{1,0},
		facing: false
	}
)

const nrt = 1 * 8.3144621 * 293.15

fn spin(iterate f64, size f64) Vec {
	return Vec{
		x: math.cos(iterate) * size,
		y: math.sin(iterate) * size
	}
}

fn frame(a voidptr) {
	mut app := &App(a)
	elapsed += delta

	sx, sy := term.get_terminal_size()
	app.zero = (vec((f64(sx)/4.0),(f64(sy)/2.0))).int()
	center := svec(0).screen(a).int()
	app.tui.clear()

	//point := spin(elapsed, 15)

	softbody.prepare()
	softbody.gravity()

	softbody.simulate(a)
	//softbody.stowards(
	//	point,
	//	100,
	//)

	softbody.integrate()
	softbody.line_collide(line)

	softbody.render(a)
	//softbody.render_points(a)

	app.tui.set_bg_color(r: 255, g: 0, b: 200)
	
	// put_pixel(line.get_closest(point), a)
	app.tui.reset_bg_color()

	//softbody.info_message(":)",a)

	app.tui.flush()
}

//* NOTE
//? sometimes the program might end unexpectedly
//? either being a dividing by zero or something else
//? its usually an assert failing with the screen clearing after

fn main(){
	mut app := &App{}

	app.tui = tui.init(
		user_data: app
		frame_fn: frame
		event_fn: event

		window_title: 'V term.ui event viewer'
		hide_cursor: true
		capture_events: true
		frame_rate: fps
		use_alternate_buffer: true
	)

	softbody = ProceduralCircle{
		radius: 10,
		position: vec(0,20),
		samples: 20
	}.make_real( 5, 200.0, 1.0 )
	
	//* mass, stiffness, damping

	app.tui.clear()
	app.tui.run() ?
}