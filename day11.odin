package day11

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	content, ok := os.read_entire_file("input/day11.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))
	starting_stones := slice.mapper(
		strings.split(lines[0], " "),
		proc(s: string) -> int {return strconv.atoi(s)},
	)

	stones := new(map[int]int)
	for stone in starting_stones {
		stones[stone] = 1
	}

	for iters := -1; iters < 75; iters += 1 {
		next_stones := new(map[int]int)
		next_stones[1] = stones[0]
		next_stones[0] = 0
		for stone in slice.map_keys(stones^) or_else nil {
			if stone == 0 {
				// Done above.
			} else if has_even_digits(stone) {
				n1, n2 := split_number(stone)
				next_stones[n1] = next_stones[n1] + stones[stone]
				next_stones[n2] = next_stones[n2] + stones[stone]
			} else {
				mstone := stone * 2024
				next_stones[mstone] = next_stones[mstone] + stones[stone]
			}
		}

		if (iters + 1 == 25) {
			// Part 1
			fmt.println(map_sum(stones))
		}

		if (iters + 1 == 75) {
			// Part 2
			fmt.println(map_sum(stones))
		}

		stones = next_stones
	}
}

has_even_digits :: proc(n: int) -> bool {
	return len(fmt.aprint(n)) % 2 == 0
}

split_number :: proc(n: int) -> (int, int) {
	s := fmt.aprint(n)
	p := len(s) / 2
	return strconv.atoi(s[:p]), strconv.atoi(s[p:])
}

map_sum :: proc(m: ^map[int]int) -> int {
	result := 0
	for c in slice.map_values(m^) or_else nil {
		result += c
	}
	return result
}
