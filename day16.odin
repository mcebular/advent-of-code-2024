package day16

import "core:container/priority_queue"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:text/regex"

main :: proc() {
	content, ok := os.read_entire_file("input/day16.txt")
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

	maze := Array2D(rune){arr, len(lines[0]), len(lines)}
	// print(maze)
	p1, p2 := solve(maze)

	// Part 1
	fmt.println(p1)

	// Part 2
	fmt.println(p2)
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

Dir :: enum {
	N,
	E,
	S,
	W,
}

DirVec2 :: struct {
	p: Vec2,
	d: Dir,
}

QueueItem :: struct($T: typeid) {
	item: T,
	cost: int,
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

dir_to_vec :: proc(dir: Dir) -> Vec2 {
	switch dir {
	case Dir.N:
		return Vec2{0, -1}
	case Dir.E:
		return Vec2{+1, 0}
	case Dir.S:
		return Vec2{0, +1}
	case Dir.W:
		return Vec2{-1, 0}
	}
	fmt.println("invalid dir", int(dir), dir)
	os.exit(1)
}

neighbours :: proc(arr: Array2D(rune), pos: DirVec2) -> []DirVec2 {
	result := make([dynamic]DirVec2)

	// check in front of us
	dir_vec := dir_to_vec(pos.d)
	next_front := DirVec2{Vec2{pos.p.x + dir_vec.x, pos.p.y + dir_vec.y}, pos.d}
	next_front_t := get(arr, next_front.p) or_else '?'
	if next_front_t == '.' {
		append(&result, next_front)
	}

	// check if it makes sense to turn left
	dir_left := Dir((int(pos.d) - 1) %% 4)
	dir_vec_left := dir_to_vec(dir_left)
	next_left := DirVec2{Vec2{pos.p.x + dir_vec_left.x, pos.p.y + dir_vec_left.y}, pos.d}
	next_left_t := get(arr, next_left.p) or_else '?'
	if next_left_t == '.' {
		append(&result, DirVec2{pos.p, dir_left})
	}

	// check if it makes sense to turn right
	dir_right := Dir((int(pos.d) + 1) %% 4)
	dir_vec_right := dir_to_vec(dir_right)
	next_right := DirVec2{Vec2{pos.p.x + dir_vec_right.x, pos.p.y + dir_vec_right.y}, pos.d}
	next_right_t := get(arr, next_right.p) or_else '?'
	if next_right_t == '.' {
		append(&result, DirVec2{pos.p, dir_right})
	}

	return result[:]
}

cost :: proc(a, b: DirVec2) -> int {
	if a.d != b.d {
		return 1000
	}
	return 1
}

solve :: proc(arr: Array2D(rune)) -> (int, int) {
	start_pos, _ := find(arr, 'S')
	end_pos, _ := find(arr, 'E')
	set(arr, start_pos, '.')
	set(arr, end_pos, '.')

	start_pos_dir := DirVec2{start_pos, Dir.E}

	frontier: priority_queue.Priority_Queue(QueueItem(DirVec2))
	priority_queue.init(
		&frontier,
		proc(a, b: QueueItem(DirVec2)) -> bool {return a.cost < b.cost},
		proc(q: []QueueItem(DirVec2), i, j: int) {
			oj := q[j]
			q[j] = q[i]
			q[i] = oj
		},
	)
	priority_queue.push(&frontier, QueueItem(DirVec2){start_pos_dir, 0})

	came_from := make(map[DirVec2]^[dynamic]DirVec2)
	cost_so_far := make(map[DirVec2]int)
	// came_from[start_pos_dir] = nil
	cost_so_far[start_pos_dir] = 0

	for priority_queue.len(frontier) > 0 {
		current := priority_queue.pop(&frontier).item

		if current.p.x == end_pos.x && current.p.y == end_pos.y {
			break
		}

		for next in neighbours(arr, current) {
			new_cost := cost_so_far[current] + cost(current, next)
			if !(next in cost_so_far) || new_cost <= cost_so_far[next] {
				cost_so_far[next] = new_cost
				priority_queue.push(&frontier, QueueItem(DirVec2){next, new_cost})
				if !(next in came_from) {
					came_from[next] = new([dynamic]DirVec2)
				}
				append(came_from[next], current)
			}
		}
	}

	for cf in slice.map_keys(came_from) or_else nil {
		if !(cf.p.x == end_pos.x && cf.p.y == end_pos.y) {
			continue
		}

		best_dirvecs := make(map[DirVec2]bool)
		best_vecs := make(map[Vec2]bool)
		currents := make([dynamic]DirVec2)
		append(&currents, cf)

		for len(currents) > 0 {
			current := pop(&currents)
			if current == start_pos_dir {
				continue
			}

			nexts := came_from[current]
			for next in nexts {
				if !(next in best_dirvecs) {
					append(&currents, next)
					best_dirvecs[next] = true
					best_vecs[Vec2{next.p.x, next.p.y}] = true
				}
			}
		}

		return cost_so_far[cf], len(slice.map_keys(best_vecs) or_else nil) + 1
	}

	return -1, -1
}
