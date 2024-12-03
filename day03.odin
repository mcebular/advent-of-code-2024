package day03

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:text/regex"

main :: proc() {
	content, ok := os.read_entire_file("input/day03.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	memory := string(content)

	re_mul, _ := regex.create_by_user("/mul\\((\\d+),(\\d+)\\)/g")
	re_do, _ := regex.create_by_user("/do\\(\\)/g")
	re_dont, _ := regex.create_by_user("/don't\\(\\)/g")

	result1 := 0
	result2 := 0

	next_pos := 0
	mul_enabled := true

	for true {
		match_mul, match_found_mul := regex.match(re_mul, memory[next_pos:])
		match_do, match_found_do := regex.match(re_do, memory[next_pos:])
		match_dont, match_found_dont := regex.match(re_dont, memory[next_pos:])
		if !match_found_mul {
			break
		}

		actual_match := match_mul
		if match_found_do && match_do.pos[0][0] < actual_match.pos[0][0] {
			actual_match = match_do
		}

		if match_found_dont && match_dont.pos[0][0] < actual_match.pos[0][0] {
			actual_match = match_dont
		}

		if match_found_do && actual_match.pos[0][0] == match_do.pos[0][0] {
			mul_enabled = true
		} else if match_found_dont && actual_match.pos[0][0] == match_dont.pos[0][0] {
			mul_enabled = false
		} else { 	// actual_match == match_mul
			n1 := strconv.atoi(
				memory[next_pos + actual_match.pos[1][0]:next_pos + actual_match.pos[1][1]],
			)
			n2 := strconv.atoi(
				memory[next_pos + actual_match.pos[2][0]:next_pos + actual_match.pos[2][1]],
			)
			result1 += n1 * n2
			if mul_enabled {
				result2 += n1 * n2
			}
		}

		next_pos += actual_match.pos[0][1]
	}

	// Part 1
	fmt.println(result1)

	// Part 2
	fmt.println(result2)
}
