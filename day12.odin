package day12

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	content, ok := os.read_entire_file("input/day12.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))

	arr := make([]rune, len(strings.join(lines, "")))
	for line, y in lines {
		for char, x in line {
			arr[y * len(lines[0]) + x] = char
		}
	}

	gardens := Array2D(rune){arr, len(lines[0]), len(lines)}
	plot_ids := Array2D(int){make([]int, len(gardens.arr)), gardens.width, gardens.height}
	plot_id := 1
	for y in 0 ..< gardens.height {
		for x in 0 ..< gardens.width {
			c := get(gardens, x, y) or_else os.exit(1)
			if c == '.' {
				continue
			}

			// flood-fill to identify the full plot
			stack := make([dynamic]Pos)
			append(&stack, Pos{x, y})
			for len(stack) > 0 {
				pos := pop(&stack)
				set(gardens, pos.x, pos.y, '.')
				set(plot_ids, pos.x, pos.y, plot_id)
				for n in neighbours(pos) {
					if (get(gardens, n.x, n.y) or_else '?') == c {
						append(&stack, n)
					}
				}
			}

			plot_id += 1
		}
	}

	areas := make(map[int]int)
	edges := make(map[int]int)
	sides := make(map[int]int)
	for y in 0 ..< plot_ids.height {
		for x in 0 ..< plot_ids.width {
			id := get(plot_ids, x, y) or_else -1
			if id in areas {
				continue
			}

			areas[id] = area(plot_ids, x, y)
			edges[id], sides[id] = perimeter(plot_ids, x, y)
		}
	}

	total_price_1 := 0
	for id in slice.map_keys(areas) or_else nil {
		total_price_1 += areas[id] * edges[id]
	}
	// Part 1
	fmt.println(total_price_1)

	total_price_2 := 0
	for id in slice.map_keys(areas) or_else nil {
		total_price_2 += areas[id] * sides[id]
	}
	// Part 2
	fmt.println(total_price_2)
}

Array2D :: struct($T: typeid) {
	arr:    []T,
	width:  int,
	height: int,
}

Pos :: struct {
	x: int,
	y: int,
}

EdgePos :: struct {
	p: Pos,
	d: int,
}

get :: proc(arr: Array2D($T), x, y: int) -> (T, bool) {
	if x < 0 || x >= arr.width || y < 0 || y >= arr.height {
		return ' ', false
	}
	return arr.arr[y * arr.width + x], true
}

set :: proc(arr: Array2D($T), x, y: int, r: T) -> bool {
	if x < 0 || x >= arr.width || y < 0 || y >= arr.height {
		return false
	}
	arr.arr[y * arr.width + x] = r
	return true
}

neighbours :: proc(pos: Pos) -> [4]Pos {
	return [4]Pos {
		Pos{pos.x, pos.y - 1},
		Pos{pos.x + 1, pos.y},
		Pos{pos.x, pos.y + 1},
		Pos{pos.x - 1, pos.y},
	}
}

perimeter :: proc(arr: Array2D($T), x, y: int) -> (int, int) {
	// flood-fill to identify the plot perimeter
	id, ok := get(arr, x, y)
	if !ok {
		return -1, -1
	}

	visited := make(map[Pos]bool)
	edges := make(map[EdgePos]bool)

	edge_count := 0
	segment_count := 0

	stack := make([dynamic]Pos)
	append(&stack, Pos{x, y})
	for len(stack) > 0 {
		pos := pop(&stack)
		if pos in visited {
			continue
		}
		visited[pos] = true

		for n, ni in neighbours(pos) {
			if (get(arr, n.x, n.y) or_else '?') == id {
				inject_at(&stack, 0, n)

			} else {
				edges[EdgePos{n, ni}] = true
				existing_segments := 0
				for en, eni in neighbours(n) {
					if (EdgePos{en, ni}) in edges {
						existing_segments += 1
					}
				}

				if existing_segments == 0 {
					// this is a new segment
					segment_count += 1
				} else if existing_segments == 2 {
					// oops! this edge just combined two segments
					segment_count -= 1
				}
				edge_count += 1
			}
		}
	}

	return edge_count, segment_count
}

area :: proc(arr: Array2D($T), x, y: int) -> int {
	// flood-fill to identify the plot area
	id, ok := get(arr, x, y)
	if !ok {
		return -1
	}

	stack := make([dynamic]Pos)
	visited := make(map[Pos]bool)
	append(&stack, Pos{x, y})
	for len(stack) > 0 {
		pos := pop(&stack)
		visited[pos] = true
		for n in neighbours(pos) {
			if (get(arr, n.x, n.y) or_else '?') == id && !(n in visited) {
				append(&stack, n)
			}
		}
	}

	return len(visited)
}
