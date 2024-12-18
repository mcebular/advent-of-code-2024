package day18

import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	content, ok := os.read_entire_file("input/day18.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))

	memory_size := 71
	memory := MemorySpace{new(map[Vec3]rune), '.', memory_size, memory_size, len(lines) + 1}

	for line, i in lines {
		byte_pos := strings.split(line, ",")
		for j in i ..< len(lines) {
			set(memory, Vec3{strconv.atoi(byte_pos[0]), strconv.atoi(byte_pos[1]), j + 1}, '#')
		}
	}

	// Part 1
	fmt.println(shortest_path(memory, 1024) or_else -1)

	for i in 0 ..< len(lines) {
		_, end_reached := shortest_path(memory, i)
		if !end_reached {
			// Part 2
			fmt.println(lines[i - 1])
			break
		}
	}
}

Vec3 :: struct {
	x: int,
	y: int,
	z: int,
}

MemorySpace :: struct {
	values:  ^map[Vec3]rune,
	default: rune,
	width:   int,
	height:  int,
	depth:   int,
}

get :: proc(mem: MemorySpace, pos: Vec3) -> (rune, bool) {
	if pos.x < 0 || pos.x >= mem.width || pos.y < 0 || pos.y >= mem.height {
		return '?', false
	}
	cz := math.min(mem.depth - 1, pos.z)
	if (Vec3{pos.x, pos.y, cz}) in mem.values {
		return mem.values[Vec3{pos.x, pos.y, cz}], true
	} else {
		return mem.default, true
	}
}

set :: proc(mem: MemorySpace, pos: Vec3, v: rune) -> bool {
	if pos.x < 0 ||
	   pos.x >= mem.width ||
	   pos.y < 0 ||
	   pos.y >= mem.height ||
	   pos.z < 0 ||
	   pos.z >= mem.depth {
		return false
	}
	mem.values[pos] = v
	return true
}

print :: proc(mem: MemorySpace, z: int) {
	for y in 0 ..< mem.height {
		for x in 0 ..< mem.width {
			fmt.print(get(mem, Vec3{x, y, z}) or_else '?')
		}
		fmt.println()
	}
}

neighbours :: proc(mem: MemorySpace, pos: Vec3) -> [4]Vec3 {
	return [4]Vec3 {
		Vec3{pos.x, pos.y - 1, pos.z},
		Vec3{pos.x + 1, pos.y, pos.z},
		Vec3{pos.x, pos.y + 1, pos.z},
		Vec3{pos.x - 1, pos.y, pos.z},
	}
}

shortest_path :: proc(mem: MemorySpace, z: int) -> (int, bool) {
	frontier := make([dynamic]Vec3)
	append(&frontier, Vec3{0, 0, z})

	came_from := make(map[Vec3]Vec3)

	reached := make(map[Vec3]int)
	reached[Vec3{0, 0, z}] = 0

	for len(frontier) > 0 {
		current := pop(&frontier)
		current_value, current_ok := get(mem, current)
		for next in neighbours(mem, current) {
			next_value, next_ok := get(mem, next)
			if next_value == '.' && next_ok && !(next in reached) {
				inject_at(&frontier, 0, next)
				came_from[next] = current
				reached[next] = reached[current] + 1
			}
		}
	}

	if !(Vec3{mem.width - 1, mem.height - 1, z} in reached) {
		return -1, false
	}

	path := make([dynamic]Vec3)
	current := Vec3{mem.width - 1, mem.height - 1, z}
	goal := Vec3{0, 0, z}
	for current != goal {
		append(&path, current)
		current = came_from[current]
	}

	return len(path), true
}
