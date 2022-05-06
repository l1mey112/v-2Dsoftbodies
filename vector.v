import math
import term.ui as tui

fn rint(v f64)int{return int(math.round(v))}
fn lerp(a f64, b f64, t f64)f64{return a + (b-a) * t}
fn mapf(old_min f64, old_max f64, new_min f64, new_max f64, value f64)f64{
	return new_min + ((new_max-new_min)/(old_max-old_min)) * (math.clamp(value, old_min, old_max))
}


fn lerp_colour(fac f64, c1 tui.Color, c2 tui.Color)tui.Color{
	n := if fac > 1.0 {1.0} else if fac < 0.0 {0.0} else {fac}
	return tui.Color{
		r: u8(math.round(lerp(c1.r,c2.r,n))),
		g: u8(math.round(lerp(c1.g,c2.g,n))),
		b: u8(math.round(lerp(c1.b,c2.b,n))),
	}
}

struct IVec {
	mut:
		x int
		y int
}

struct Vec{
	mut:
		x f64
		y f64
}

// 6x3
// x x x x x x
// x x x x x x
// x x x x x x
//
// actually 3x3
// x x x
// x x x
// x x x

//? screen coords conversion
//? 0,0 is center of screen
fn (vec1 Vec) screen(a voidptr) Vec {
	app := &App(a)
	return ((vec1 * vec(1,-1)) + app.zero.float()) * vec(2,1)
}

fn (vec1 IVec) screen(a voidptr) IVec {
	app := &App(a)
	return ((vec1 * ivec(1,-1)) + app.zero) * ivec(2,1)
}

//? conversion
fn (vec1 Vec) int()IVec{return IVec{rint(vec1.x+0.5),rint(vec1.y+0.5)}}
fn (vec1 IVec) float()Vec{return Vec{f64(vec1.x),f64(vec1.y)}}

fn svec(a f64)Vec{return Vec{x: a, y: a}}
fn vec(a f64, b f64)Vec{return Vec{x: a, y: b}}
fn ivec(a int, b int)IVec{return IVec{x: a, y: b}}
fn sivec(a int)IVec{return IVec{x: a, y: a}}

//? arithmetic operators
fn (a Vec) + (b Vec) Vec {return Vec{a.x + b.x, a.y + b.y}}
fn (a Vec) - (b Vec) Vec {return Vec{a.x - b.x, a.y - b.y}}
fn (a Vec) * (b Vec) Vec {return Vec{a.x * b.x, a.y * b.y}}
fn (a Vec) / (b Vec) Vec {return Vec{a.x / b.x, a.y / b.y}}

//? arithmetic operators for IVec
fn (a IVec) + (b IVec) IVec {return IVec{a.x + b.x, a.y + b.y}}
fn (a IVec) - (b IVec) IVec {return IVec{a.x - b.x, a.y - b.y}}
fn (a IVec) * (b IVec) IVec {return IVec{a.x * b.x, a.y * b.y}}
fn (a IVec) / (b IVec) IVec {return IVec{a.x / b.x, a.y / b.y}}

//? vector operations
fn (vec1 Vec) length() f64 {return math.sqrt(vec1.x*vec1.x + vec1.y*vec1.y)}
fn (vec1 Vec) slength() f64 {return vec1.x*vec1.x + vec1.y*vec1.y}
fn (vec1 Vec) normalize() Vec {length := 1.0/vec1.length() return Vec{vec1.x*length,vec1.y*length}}
fn (vec1 Vec) lerp(vec2 Vec, interp f64) Vec { return Vec{ lerp(vec1.x, vec2.x, interp), lerp(vec1.y, vec2.y, interp)}}
fn (vec1 Vec) dot(vec2 Vec) f64 {return vec1.x*vec2.x + vec1.y*vec2.y}
fn (vec1 Vec) cross(vec2 Vec) f64 {return vec1.x*vec2.y - vec1.y*vec2.x}

// get midpoint between two vectors
fn (vec1 Vec) midpoint(vec2 Vec) Vec {return Vec{(vec1.x+vec2.x)/2,(vec1.y+vec2.y)/2}}

fn (vec1 Vec) distance(vec2 Vec) f64 {
	return math.sqrt(
		(vec1.x - vec2.x)*(vec1.x - vec2.x) +
		(vec1.y - vec2.y)*(vec1.y - vec2.y)
	)
} //? exact same as subtracting two vectors, then taking the resulting length

fn (vec1 Vec) sdistance(vec2 Vec) f64 {
	return (vec1.x - vec2.x)*(vec1.x - vec2.x) +
		(vec1.y - vec2.y)*(vec1.y - vec2.y)
}

fn (vec1 Vec) rotate(angle f64) Vec {
	return Vec{
		x: vec1.x*math.cos(angle) - vec1.y*math.sin(angle),
		y: vec1.x*math.sin(angle) + vec1.y*math.cos(angle)
	}
}