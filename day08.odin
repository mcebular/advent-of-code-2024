package day08

import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strings"
import "core:unicode/utf8"

main :: proc() {
	content, ok := os.read_entire_file("input/day08.txt")
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
	antennas := make(Antennas)
	for y in 0 ..< area.height {
		for x in 0 ..< area.width {
			c := get(area, x, y) or_else '?'
			if (c != '.') {
				if !(c in antennas) {
					antennas[c] = new(map[Pos]int)
				}
				ac := antennas[c]
				ac[Pos{x, y}] = 1
			}
		}
	}

	// Part 1
	fmt.println(count_antinodes(area, antennas, false))

	// Part 2
	fmt.println(count_antinodes(area, antennas, true))
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

Antennas :: map[rune]^map[Pos]int

count_antinodes :: proc(area: Area, antennas: Antennas, repeating: bool) -> int {
	antinodes := make(map[Pos]rune)
	for antenna_type in slice.map_keys(antennas) or_else nil {
		antenna_positions := slice.map_keys(antennas[antenna_type]^) or_else nil
		for a1x in 0 ..< len(antenna_positions) {
			for a2x in (a1x + 1) ..< len(antenna_positions) {
				a1 := antenna_positions[a1x]
				a2 := antenna_positions[a2x]
				diff := Pos{a1.x - a2.x, a1.y - a2.y}

				start := 1
				end := 2
				if repeating {
					start = 0
					end = math.max(area.width, area.height)
				}
				for i in start ..< end {
					an1 := Pos{a1.x + diff.x * i, a1.y + diff.y * i}
					if (an1.x >= 0 && an1.x < area.width && an1.y >= 0 && an1.y < area.height) {
						antinodes[an1] = antenna_type
					}

					an2 := Pos{a2.x - diff.x * i, a2.y - diff.y * i}
					if (an2.x >= 0 && an2.x < area.width && an2.y >= 0 && an2.y < area.height) {
						antinodes[an2] = antenna_type
					}
				}
			}
		}
	}

	return len(antinodes)
}
