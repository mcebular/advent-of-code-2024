package day15

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:text/regex"

main :: proc() {
	content, ok := os.read_entire_file("input/day15.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))

	arr := make([]rune, len(strings.join(lines, "")))
	moves := make([dynamic]rune)

	map_input := true
	map_height := 0
	for line, y in lines {
		if len(line) == 0 {
			map_input = false
		}

		if map_input {
			for char, x in line {
				arr[y * len(lines[0]) + x] = char
			}
			map_height += 1
		} else {
			for char in line {
				append(&moves, char)
			}
		}
	}

	source_warehouse := Array2D(rune){arr, len(lines[0]), map_height}

	// fmt.println(warehouse)
	// fmt.println(moves)

	warehouse1 := copy(source_warehouse)
	for move in moves {
		pos, _ := find(warehouse1, '@')
		ok := false
		switch move {
		case '>':
			ok = attempt_move(warehouse1, pos, Vec2{+1, 0})
		case 'v':
			ok = attempt_move(warehouse1, pos, Vec2{0, +1})
		case '<':
			ok = attempt_move(warehouse1, pos, Vec2{-1, 0})
		case '^':
			ok = attempt_move(warehouse1, pos, Vec2{0, -1})
		}
		// print(warehouse1)
	}

	// Part 1
	fmt.println(box_gps_sum(warehouse1))

	warehouse2 := scale(source_warehouse)
	for move in moves {
		pos, _ := find(warehouse2, '@')
		ok := false
		switch move {
		case '>':
			ok = attempt_move(warehouse2, pos, Vec2{+1, 0})
		case 'v':
			ok = attempt_move(warehouse2, pos, Vec2{0, +1})
		case '<':
			ok = attempt_move(warehouse2, pos, Vec2{-1, 0})
		case '^':
			ok = attempt_move(warehouse2, pos, Vec2{0, -1})
		}
		// print(warehouse2)
	}

	// Part 2
	fmt.println(box_gps_sum(warehouse2))
}

Array2D :: struct($T: typeid) {
	arr:    []T,
	width:  int,
	height: int,
}

Vec2 :: struct {
	x: int,
	y: int,
}

get :: proc(arr: Array2D($T), pos: Vec2) -> (T, bool) {
	if pos.x < 0 || pos.x >= arr.width || pos.y < 0 || pos.y >= arr.height {
		return ' ', false
	}
	return arr.arr[pos.y * arr.width + pos.x], true
}

set :: proc(arr: Array2D($T), pos: Vec2, v: T) -> bool {
	if pos.x < 0 || pos.x >= arr.width || pos.y < 0 || pos.y >= arr.height {
		return false
	}
	arr.arr[pos.y * arr.width + pos.x] = v
	return true
}

find :: proc(arr: Array2D($T), x: T) -> (Vec2, bool) {
	for ax, i in arr.arr {
		if ax == x {
			return Vec2{i % arr.width, i / arr.width}, true
		}
	}

	return Vec2{-1, -1}, false
}

print :: proc(arr: Array2D($T)) {
	for y in 0 ..< arr.height {
		for x in 0 ..< arr.width {
			fmt.print(get(arr, Vec2{x, y}) or_else '?')
		}
		fmt.println()
	}
}

copy :: proc(arr: Array2D($T)) -> Array2D(T) {
	arr_arr_copy := make([]T, len(arr.arr))
	copy_slice(arr_arr_copy[:], arr.arr[:])
	return Array2D(T){arr_arr_copy, arr.width, arr.height}
}

scale :: proc(arr: Array2D($T)) -> Array2D(T) {
	new_arr := make([]T, len(arr.arr) * 2)
	for a, i in arr.arr {
		switch a {
		case '#':
			new_arr[i * 2] = '#'
			new_arr[i * 2 + 1] = '#'
		case '.':
			new_arr[i * 2] = '.'
			new_arr[i * 2 + 1] = '.'
		case 'O':
			new_arr[i * 2] = '['
			new_arr[i * 2 + 1] = ']'
		case '@':
			new_arr[i * 2] = '@'
			new_arr[i * 2 + 1] = '.'
		}
	}

	return Array2D(T){new_arr, arr.width * 2, arr.height}
}

attempt_move :: proc(area: Array2D($T), pos: Vec2, dir: Vec2) -> bool {
	all_positions := make([dynamic]Vec2)
	unchecked_positions := make([dynamic]Vec2)

	append(&unchecked_positions, pos)
	for len(unchecked_positions) > 0 {
		curr := pop(&unchecked_positions)
		next := Vec2{curr.x + dir.x, curr.y + dir.y}

		curr_t := get(area, curr) or_else '?'
		next_t := get(area, next) or_else '?'

		if curr_t == '.' {
			continue
		}

		if next_t == '#' {
			inject_at(&unchecked_positions, 0, next)
			break
		}

		if curr_t == '@' {
			append(&all_positions, curr)
			if dir.y == 0 || next_t == 'O' {
				inject_at(&unchecked_positions, 0, next)
			} else {
				if next_t == '[' {
					inject_at(&unchecked_positions, 0, next)
					inject_at(&unchecked_positions, 0, Vec2{next.x + 1, next.y})
				} else if next_t == ']' {
					inject_at(&unchecked_positions, 0, next)
					inject_at(&unchecked_positions, 0, Vec2{next.x - 1, next.y})
				}
			}
			continue
		}

		if curr_t == ']' && next_t == '[' {
			append(&all_positions, curr)
			if dir.y == 0 {
				inject_at(&unchecked_positions, 0, next)
			} else {
				inject_at(&unchecked_positions, 0, next)
				inject_at(&unchecked_positions, 0, Vec2{next.x + 1, next.y})
			}
			continue
		}

		if curr_t == '[' && next_t == ']' {
			append(&all_positions, curr)
			if dir.y == 0 {
				inject_at(&unchecked_positions, 0, next)
			} else {
				inject_at(&unchecked_positions, 0, next)
				inject_at(&unchecked_positions, 0, Vec2{next.x - 1, next.y})
			}
			continue
		}

		if curr_t == next_t {
			append(&all_positions, curr)
			if dir.y == 0 || curr_t == 'O' {
				inject_at(&unchecked_positions, 0, next)
			} else {
				if curr_t == '[' {
					inject_at(&unchecked_positions, 0, next)
					inject_at(&unchecked_positions, 0, Vec2{next.x + 1, next.y})
				} else if curr_t == ']' {
					inject_at(&unchecked_positions, 0, next)
					inject_at(&unchecked_positions, 0, Vec2{next.x - 1, next.y})
				}
			}
			continue
		}

		if next_t == '.' {
			append(&all_positions, curr)
			inject_at(&unchecked_positions, 0, next)
			continue
		}
	}

	if len(unchecked_positions) == 0 {
		// Move possible.
		slice.reverse(all_positions[:])
		for curr in all_positions {
			next := Vec2{curr.x + dir.x, curr.y + dir.y}

			curr_t := get(area, curr) or_else '?'
			next_t := get(area, next) or_else '?'
			if curr_t == '.' {
				// Nothing to actually move (already moved).
				continue
			}

			set(area, next, curr_t)
			set(area, curr, '.')
		}
		return true
	} else {
		return false
	}
}

box_gps_sum :: proc(warehouse: Array2D($T)) -> int {
	result := 0
	for y in 0 ..< warehouse.height {
		for x in 0 ..< warehouse.width {
			v := get(warehouse, Vec2{x, y}) or_else '?'
			if v == 'O' || v == '[' {
				result += y * 100 + x
			}
		}
	}
	return result
}
