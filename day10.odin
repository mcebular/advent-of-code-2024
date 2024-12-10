package day10

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	content, ok := os.read_entire_file("input/day10.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))
	area_arr := make([]int, len(strings.join(lines, "")))
	for line, i in lines {
		for char, j in line {
			area_arr[i * len(lines) + j] = strconv.atoi(fmt.aprint(char))
		}
	}

	area := Area{area_arr, len(lines[0]), len(lines)}

	trailheads := make(map[Pos]int)
	for y in 0..<area.height {
		for x in 0..<area.width {
			p := get(area, x, y) or_else -1
			if p == 0 {
				trailheads[Pos{x, y}] = 0
			}
		}
	}

	total_score := 0
	total_rating := 0
	for trailhead in slice.map_keys(trailheads) or_else nil {
		score, rating := find_trails(area, trailhead)
		total_score += score
		total_rating += rating
	}

	// Part 1
	fmt.println(total_score)

	// Part 2
	fmt.println(total_rating)
}


Area :: struct {
	arr:    []int,
	width:  int,
	height: int,
}

Pos :: struct {
	x: int,
	y: int,
}

get :: proc(area: Area, x: int, y: int) -> (int, bool) {
	if x < 0 || x >= area.width || y < 0 || y >= area.height {
		return ' ', false
	}
	return area.arr[y * area.width + x], true
}

neighbours :: proc(pos: Pos) -> [4]Pos {
	return [4]Pos{
		Pos{pos.x, pos.y - 1},
		Pos{pos.x + 1, pos.y},
		Pos{pos.x, pos.y + 1},
		Pos{pos.x - 1, pos.y},
	}
}

find_trails :: proc(area: Area, trailhead: Pos) -> (int, int) {
	frontier := make([dynamic]Pos)
	append(&frontier, trailhead)

	reached := make(map[Pos]int)
	reached[trailhead] = 0
	
	trailtops := make(map[Pos]bool)
	for len(frontier) > 0 {
		current := pop(&frontier)
		current_value, current_ok := get(area, current.x, current.y)

		if current_value == 9 {
			trailtops[current] = true
			continue
		}

		for next in neighbours(current) {
			next_value, next_ok := get(area, next.x, next.y)
			if next_ok && next_value == current_value + 1 {
				if !(next in reached) {
					reached[next] = 0
				}
				append(&frontier, next)
				reached[next] += 1
			}
		}
	}

	result := 0
	for trailtop in slice.map_keys(trailtops) or_else nil {
		result += reached[trailtop]
	}

	return len(trailtops), result
}
