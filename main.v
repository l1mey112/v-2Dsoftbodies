import term.ui as tui
import term

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

//todo draw vector from center of screen to mouse position capped a little more than the cirle radius
//todo basic scanline rendering for circles?
//todo for that you would need to hijack bresenham's algorithm and use it to fill in scanlines

//todo procedural circles
//todo 		get radius and amount of test points
//todo 		then move initial test point to raidus and then move it to the next point

//todo conceptualise a 2D camera,
//todo		2D cameras have a view bounds and a position
//todo		use a function to convert world space to 2D camera space
//todo		i already have app.zero and other conversions

//todo use procedural circles as a sort of LOD?
//todo 		replacing simulated circles for others

//todo create own line drawing algorithm for complete control
//? /home/liaml/tools/v/vlib/term/ui/ui.v outlined here

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

	app.tui.draw_text(new.x,new.y, pchar)
	app.tui.draw_text(new.x+1,new.y, pchar)
}

__global (
	v1 = Vertex{ 
		position: vec(0,5),
		mass: 1.0,
		fixed: true
	}
	v2 = Vertex{ 
		position: vec(5,5),
		mass: 2.0,
	}
	v3 = Vertex{ 
		position: vec(5,0),
		mass: 2.0,
	}
	spring = Spring{
		a: &v1,
		b: &v2,

		length: 3.0,
		stiffness: 20.0,
		damping: 1.0
	}
	spring1 = Spring{
		a: &v2,
		b: &v3,

		length: 3.0,
		stiffness: 20.0,
		damping: 1.0
	}
)

fn frame(a voidptr) {
	mut app := &App(a)
	sx, sy := term.get_terminal_size()
	app.zero = (vec((f64(sx)/4.0),(f64(sy)/2.0))).int()
	center := svec(0).screen(a).int()

	app.tui.clear()

	v1.prepare()
	v2.prepare()
	v3.prepare()

	v1.gravity()
	v2.gravity()
	v3.gravity()

	spring.calculate_hookes()
	spring1.calculate_hookes()

	v1.integrate()
	v2.integrate()
	v3.integrate()

	spring.render(a)
	spring1.render(a)

	spring.info(a)
	spring1.info(a)

	v1.info(a)
	v2.info(a)
	v3.info(a)

	app.tui.flush()
}

fn main(){
	println("Hello, world!")

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

	app.tui.clear()
	app.tui.run() ?
}