package day06

import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"


main :: proc() {
	content, ok := os.read_entire_file("input/day06.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))
	area_arr := make([]rune, len(content))
	for line, i in lines {
		copy(area_arr[len(line) * i:len(line) * (i + 1)], utf8.string_to_runes(line)[:])
	}

	area := Area{area_arr, len(lines[0]), len(lines)}
	// Assuming input will always contain '^' as start position.
	start_x, start_y := find(area, '^') or_else os.exit(-1)
	set(area, start_x, start_y, '.')
	guard := Guard{start_x, start_y, Dir.N}

	visited := walk_area_1(area, guard)

	// Part 1
	fmt.println(len(visited))

	loop_areas_count := 0
	for pos in slice.map_keys(visited) or_else os.exit(-1) {
		ok := walk_area_2(area, guard, pos)
		if ok {
			loop_areas_count += 1
		}
	}

	// Part 2
	fmt.println(loop_areas_count)
}

Area :: struct {
	arr:    []rune,
	width:  int,
	height: int,
}

Pos :: struct {
	x: int,
	y: int,
}

get :: proc(area: Area, x: int, y: int) -> (rune, bool) {
	if x < 0 || x >= area.width || y < 0 || y >= area.height {
		return ' ', false
	}
	return area.arr[y * area.width + x], true
}

set :: proc(area: Area, x: int, y: int, r: rune) -> bool {
	if x < 0 || x >= area.width || y < 0 || y >= area.height {
		return false
	}
	area.arr[y * area.width + x] = r
	return true
}

find :: proc(area: Area, r: rune) -> (int, int, bool) {
	for ar, i in area.arr {
		if ar == r {
			return i % area.width, i / area.width, true
		}
	}

	return -1, -1, false
}

Dir :: enum {
	N,
	E,
	S,
	W,
}

Guard :: struct {
	x: int,
	y: int,
	d: Dir,
}

next_pos :: proc(g: Guard) -> Guard {
	switch g.d {
	case Dir.N:
		return Guard{g.x, g.y - 1, g.d}
	case Dir.E:
		return Guard{g.x + 1, g.y, g.d}
	case Dir.S:
		return Guard{g.x, g.y + 1, g.d}
	case Dir.W:
		return Guard{g.x - 1, g.y, g.d}
	case:
		os.exit(-1)
	}
}

walk_area_1 :: proc(area: Area, guard: Guard) -> map[Pos]bool {
	visits := make(map[Pos]bool)
	curr := Guard(guard)
	for true {
		visits[Pos{curr.x, curr.y}] = true
		next := next_pos(curr)
		place, in_bounds := get(area, next.x, next.y)
		if !in_bounds {
			break
		}

		if place == '#' {
			curr = Guard{curr.x, curr.y, Dir((int(curr.d) + 1) % 4)}
		} else {
			curr = next
		}
	}

	return visits
}

walk_area_2 :: proc(area: Area, guard: Guard, obstruction: Pos) -> bool {
	visits := make(map[string]bool)
	curr := Guard(guard)
	for true {
		next := next_pos(curr)
		place, in_bounds := get(area, next.x, next.y)
		if !in_bounds {
			return false
		}

		if fmt.aprint(curr.x, curr.y, curr.d) in visits {
			// loop detected
			return true
		}
		visits[fmt.aprint(curr.x, curr.y, curr.d)] = true

		if place == '#' || (Pos{next.x, next.y} == obstruction) {
			curr = Guard{curr.x, curr.y, Dir((int(curr.d) + 1) % 4)}
		} else {
			curr = next
		}
	}

	return false
}
